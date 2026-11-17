import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/domain/severity.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/severity_style.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/headers.dart';
import '../../../core/widgets/state_views.dart';
import '../../alerts/domain/flood_alert.dart';
import '../../alerts/presentation/alert_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../emergency/presentation/emergency_providers.dart';
import '../../emergency/presentation/emergency_sheet.dart';
import '../../emergency/presentation/voice_guide.dart';
import '../../water_levels/domain/station.dart';
import '../../water_levels/presentation/station_providers.dart';
import '../../water_levels/presentation/widgets/station_row.dart';
import '../../weather/presentation/weather_providers.dart';
import '../../weather/presentation/weather_style.dart';

/// Accueil (maquette 5) : situation de la zone, niveaux en temps reel, statut de la zone.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(stationsProvider)
      ..invalidate(alertsProvider)
      ..invalidate(weatherProvider);
    await ref.read(stationsProvider.future).catchError((_) => const <Station>[]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final commune = ref.watch(userCommuneProvider);
    final stations = ref.watch(stationsProvider);
    final zoneAlert = ref.watch(myZoneActiveAlertProvider);
    final zoneSeverity = ref.watch(myZoneSeverityProvider);
    final otherAlerts = ref.watch(activeAlertsProvider).where((a) => a.commune != commune).length;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      const BrandWordmark(text: 'Overflow', fontSize: 20, logoSize: 28),
                      const Spacer(),
                      const _WeatherChip(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _ZoneChip(commune: commune, onTap: () => context.go(Routes.zone)),
                  ),
                  const SizedBox(height: 14),
                  _SituationCard(
                    alert: zoneAlert,
                    severity: zoneAlert?.severity ?? zoneSeverity,
                    updatedAt: stations.value?.map((s) => s.updatedAt).fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a),
                    onTap: () => zoneAlert != null ? context.push(Routes.alert(zoneAlert.id)) : context.go(Routes.alertsFilter('zone')),
                  ),
                  if (ref.watch(inDangerZoneProvider)) ...[
                    const SizedBox(height: 12),
                    _EmergencyBanner(alertId: zoneAlert?.id),
                    const SizedBox(height: 10),
                    const VoiceGuideButton(),
                  ],
                  if (otherAlerts > 0) ...[
                    const SizedBox(height: 10),
                    _OtherAlertsLink(count: otherAlerts),
                  ],
                  SectionTitle(l.homeRealtimeTitle),
                  AsyncValueView(
                    value: stations,
                    compact: true,
                    onRetry: () => ref.invalidate(stationsProvider),
                    loading: const SkeletonList(count: 3, itemHeight: 64, padding: EdgeInsets.zero),
                    data: (list) => list.isEmpty
                        ? EmptyView(message: l.homeNoStations, icon: LucideIcons.radar, compact: true)
                        : AppCard(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                for (final (i, s) in list.take(3).indexed) ...[
                                  if (i > 0) const Divider(indent: 16, endIndent: 16),
                                  StationRow(station: s, onTap: () => context.push(Routes.station(s.id))),
                                ],
                              ],
                            ),
                          ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => context.go(Routes.stations),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l.homeSeeAllStations, style: AppText.link),
                          const SizedBox(width: 2),
                          const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                  SectionTitle(l.homeZoneStatusTitle, padding: const EdgeInsets.fromLTRB(0, 6, 0, 12)),
                  _ZoneStatusCard(commune: commune, severity: zoneAlert?.severity ?? zoneSeverity),
                  const SizedBox(height: 16),
                  const _QuickActions(),
                  const SizedBox(height: 16),
                  AppCard(
                    onTap: () => context.push(Routes.assistant()),
                    child: Row(
                      children: [
                        const IconTile(icon: LucideIcons.sparkles, color: AppColors.primary, background: AppColors.primarySoft),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.homeAssistantTitle, style: AppText.title),
                              const SizedBox(height: 2),
                              Text(l.homeAssistantSubtitle, style: AppText.caption),
                            ],
                          ),
                        ),
                        const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  const _ZoneChip({required this.commune, required this.onTap});
  final String commune;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: const StadiumBorder(),
    elevation: 0,
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.mapPin, size: 15, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(commune, style: AppText.label.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ),
  );
}

class _WeatherChip extends ConsumerWidget {
  const _WeatherChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(weatherProvider).value;
    return Material(
      color: AppColors.surface,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => context.go(Routes.weather),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(w?.today.condition.icon ?? LucideIcons.cloudSun, size: 17, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(w == null ? context.l10n.homeQuickWeather : '${w.today.maxC.round()}°', style: AppText.label.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte bleue "Situation actuelle" ; rouge ou orange si une alerte touche la zone.
class _SituationCard extends StatelessWidget {
  const _SituationCard({required this.alert, required this.severity, required this.updatedAt, required this.onTap});

  final FloodAlert? alert;
  final Severity? severity;
  final DateTime? updatedAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = severity ?? Severity.normal;
    final (colors, title, icon) = switch (s) {
      Severity.danger => (const [Color(0xFFEF4444), AppColors.alertRedDark], l.homeAlertActive, LucideIcons.triangleAlert),
      Severity.vigilance => (const [Color(0xFFF59E0B), Color(0xFFB45309)], l.homeVigilanceActive, LucideIcons.bellRing),
      Severity.normal => (const [AppColors.heroStart, AppColors.heroEnd], l.homeNoAlert, LucideIcons.check),
    };
    return Semantics(
      button: true,
      label: '${l.homeSituation}. $title',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
            boxShadow: AppShadows.button(colors.last),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.homeSituation, style: AppText.caption.copyWith(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(title, style: AppText.h3.copyWith(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.25)),
                    if (alert != null) ...[
                      const SizedBox(height: 4),
                      Text(alert!.location, style: AppText.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      l.commonUpdatedAt(Fmt.time(updatedAt ?? DateTime.now())),
                      style: AppText.caption.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Acces direct aux secours quand la zone suivie est inondee.
class _EmergencyBanner extends StatelessWidget {
  const _EmergencyBanner({this.alertId});
  final String? alertId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      onTap: () => showEmergencySheet(context, alertId: alertId),
      border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      child: Row(
        children: [
          const IconTile(icon: LucideIcons.siren, color: Colors.white, background: AppColors.danger, size: 46, radius: 23),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.emergencyBannerTitle, style: AppText.title.copyWith(color: AppColors.danger)),
                const SizedBox(height: 2),
                Text(l.emergencyBannerSubtitle, style: AppText.caption),
              ],
            ),
          ),
          const Icon(LucideIcons.phoneCall, color: AppColors.danger, size: 22),
        ],
      ),
    );
  }
}

class _OtherAlertsLink extends StatelessWidget {
  const _OtherAlertsLink({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(AppRadius.md),
    onTap: () => context.go(Routes.alerts),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(
        children: [
          const Icon(LucideIcons.triangleAlert, size: 16, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(child: Text(context.l10n.homeOtherAlerts(count), style: AppText.label.copyWith(color: AppColors.danger, fontWeight: FontWeight.w600))),
          const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.danger),
        ],
      ),
    ),
  );
}

class _ZoneStatusCard extends StatelessWidget {
  const _ZoneStatusCard({required this.commune, required this.severity});
  final String commune;
  final Severity? severity;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = severity ?? Severity.normal;
    final subtitle = switch (s) {
      Severity.normal => l.homeZoneNoFlood,
      Severity.vigilance => l.homeZoneVigilance,
      Severity.danger => l.homeZoneDanger,
    };
    return AppCard(
      onTap: () => context.go(Routes.mapFocus(zone: commune)),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: s == Severity.normal ? AppColors.primarySoft : s.softColor, shape: BoxShape.circle),
            child: Icon(LucideIcons.target, color: s == Severity.normal ? AppColors.primary : s.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(commune, style: AppText.title.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppText.caption),
              ],
            ),
          ),
          SeverityBadge(s),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final actions = [
      (LucideIcons.cloudRain, l.homeQuickWeather, () => context.go(Routes.weather)),
      (LucideIcons.box, l.homeQuick3d, () => context.push(Routes.twin())),
      (LucideIcons.sparkles, l.homeQuickAssistant, () => context.push(Routes.assistant())),
      (LucideIcons.camera, l.homeQuickReport, () => context.push(Routes.newReport)),
    ];
    return Row(
      children: [
        for (final (i, a) in actions.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: AppCard(
              onTap: a.$3,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Column(
                children: [
                  Icon(a.$1, color: AppColors.primary, size: 22),
                  const SizedBox(height: 6),
                  Text(a.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
