import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/severity_style.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/headers.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/station.dart';
import 'station_providers.dart';
import 'widgets/level_chart.dart';

/// Detail d'une station : niveau en direct, seuils, courbe 24 h, capteur, acces 3D et carte.
class StationDetailScreen extends ConsumerWidget {
  const StationDetailScreen({super.key, required this.stationId});
  final String stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final station = ref.watch(stationByIdProvider(stationId));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(title: station.value?.name ?? context.l10n.stationsTitle),
            Expanded(
              child: AsyncValueView<Station?>(
                value: station,
                onRetry: () => ref.invalidate(stationsProvider),
                data: (s) => s == null ? const ErrorView(error: NotFoundException()) : _Body(station: s),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.station});
  final Station station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = station;
    final history = ref.watch(stationHistoryProvider(s.id));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(stationsProvider);
        ref.invalidate(stationHistoryProvider(s.id));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(child: Text('${s.commune} - ${s.place}', style: AppText.bodyMuted)),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(l.stationDetailLevel, style: AppText.label),
                    const Spacer(),
                    SeverityBadge(s.severity),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(Fmt.cm(s.levelCm), key: ValueKey(s.levelCm), style: AppText.display.copyWith(color: s.severity.textColor)),
                    ),
                    const Spacer(),
                    Icon(s.trend.icon, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(s.trend.label(l), style: AppText.label.copyWith(color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 14),
                _ThresholdBar(station: s),
                const SizedBox(height: 10),
                Text(l.commonUpdatedAt(Fmt.time(s.updatedAt)), style: AppText.caption),
              ],
            ),
          ),
          SectionTitle(l.station24h),
          AppCard(
            padding: const EdgeInsets.fromLTRB(10, 16, 14, 12),
            child: AsyncValueView(
              value: history,
              compact: true,
              onRetry: () => ref.invalidate(stationHistoryProvider(s.id)),
              loading: const SizedBox(height: 180, child: LoadingView()),
              data: (readings) => readings.length < 2
                  ? EmptyView(message: l.stationNoHistory, icon: LucideIcons.chartLine, compact: true)
                  : LevelChart(readings: readings, vigilanceCm: s.vigilanceCm, dangerCm: s.dangerCm),
            ),
          ),
          SectionTitle(l.stationInfo),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _InfoRow(
                  icon: LucideIcons.radio,
                  label: l.stationSensor,
                  value: s.online ? l.stationSensorOnline : l.stationSensorOffline,
                  valueColor: s.online ? AppColors.success : AppColors.danger,
                ),
                if (s.batteryPct != null) ...[
                  const Divider(indent: 16, endIndent: 16),
                  _InfoRow(
                    icon: s.batteryPct! < 25 ? LucideIcons.batteryLow : LucideIcons.batteryMedium,
                    label: l.stationBattery,
                    value: '${s.batteryPct} %',
                    valueColor: s.batteryPct! < 25 ? AppColors.danger : null,
                  ),
                ],
                const Divider(indent: 16, endIndent: 16),
                _InfoRow(icon: LucideIcons.clock, label: l.stationLastUpdate, value: Fmt.dateTime(s.updatedAt)),
                const Divider(indent: 16, endIndent: 16),
                _InfoRow(icon: LucideIcons.waves, label: l.stationAboveStreet, value: Fmt.meters(s.waterAboveStreetM)),
                const Divider(indent: 16, endIndent: 16),
                _InfoRow(icon: LucideIcons.mapPin, label: l.stationLocation, value: '${s.lat.toStringAsFixed(4)}, ${s.lon.toStringAsFixed(4)}'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (s.twinSiteId != null) ...[
            PrimaryButton(label: l.stationView3d, icon: LucideIcons.box, onPressed: () => context.push(Routes.twin(site: s.twinSiteId, station: s.id))),
            const SizedBox(height: 12),
          ],
          OutlinePillButton(
            label: l.stationSeeOnMap,
            leading: const Icon(LucideIcons.map, size: 18, color: AppColors.primary),
            onPressed: () => context.go(Routes.mapFocus(station: s.id)),
          ),
        ],
      ),
    );
  }
}

/// Jauge horizontale : remplissage du caniveau avec reperes Vigilance et Danger.
class _ThresholdBar extends StatelessWidget {
  const _ThresholdBar({required this.station});
  final Station station;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final max = station.dangerCm * 1.25;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) => SizedBox(
            height: 14,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(7))),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  width: c.maxWidth * station.fillRatio,
                  decoration: BoxDecoration(color: station.severity.color, borderRadius: BorderRadius.circular(7)),
                ),
                for (final (v, color) in [(station.vigilanceCm, AppColors.warning), (station.dangerCm, AppColors.danger)])
                  Positioned(
                    left: (v / max).clamp(0.0, 1.0) * c.maxWidth - 1,
                    top: -3,
                    bottom: -3,
                    child: Container(width: 2.5, color: color),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            _Legend(color: AppColors.warning, text: l.stationVigilanceThreshold(Fmt.cm(station.vigilanceCm))),
            _Legend(color: AppColors.danger, text: l.stationDangerThreshold(Fmt.cm(station.dangerCm))),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 3, color: color),
      const SizedBox(width: 6),
      Text(text, style: AppText.caption),
    ],
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppText.body)),
        Text(value, style: AppText.title.copyWith(fontSize: 13.5, color: valueColor)),
      ],
    ),
  );
}
