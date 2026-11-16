import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/severity_style.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/buttons.dart';
import '../../water_levels/presentation/station_providers.dart';
import '../../water_levels/presentation/widgets/station_row.dart';
import '../domain/risk_zone.dart';

/// Fiche d'une zone a risque, ouverte au toucher sur la carte.
class ZoneSheet extends ConsumerWidget {
  const ZoneSheet({super.key, required this.zone});
  final RiskZone zone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final stations = (ref.watch(stationsProvider).value ?? const []).where((s) => zone.stationIds.contains(s.id)).toList();

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: zone.risk.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                  child: Icon(LucideIcons.mapPin, color: zone.risk.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(zone.name, style: AppText.h3),
                      const SizedBox(height: 6),
                      StatusPill(label: zone.risk.label(l), color: zone.risk.color, background: zone.risk.color.withValues(alpha: 0.12), dot: zone.risk.color),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(zone.description, style: AppText.body),
            if (zone.lastFloodAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(l.mapZoneLastFlood(Fmt.date(zone.lastFloodAt!)), style: AppText.caption),
                ],
              ),
            ],
            const SizedBox(height: 18),
            Text(l.mapZoneStations, style: AppText.title),
            const SizedBox(height: 8),
            if (stations.isEmpty)
              Text(l.mapZoneNoStation, style: AppText.bodyMuted)
            else
              Container(
                decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Column(
                  children: [
                    for (final (i, s) in stations.indexed) ...[
                      if (i > 0) const Divider(indent: 16, endIndent: 16),
                      StationRow(
                        station: s,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push(Routes.station(s.id));
                        },
                      ),
                    ],
                  ],
                ),
              ),
            if (zone.twinSiteId != null) ...[
              const SizedBox(height: 20),
              PrimaryButton(
                label: l.mapTwin,
                icon: LucideIcons.box,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(Routes.twin(site: zone.twinSiteId, station: stations.firstOrNull?.id));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
