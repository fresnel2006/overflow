import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/severity_style.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/headers.dart';
import '../../../core/widgets/state_views.dart';
import '../../emergency/presentation/emergency_sheet.dart';
import '../data/alert_repositories.dart';
import '../domain/flood_alert.dart';
import 'alert_providers.dart';
import 'alert_style.dart';

/// Ecran d'alerte plein ecran (maquette 8). Rouge pour une inondation, orange pour une
/// vigilance, vert pour une fin d'alerte.
class AlertDetailScreen extends ConsumerWidget {
  const AlertDetailScreen({super.key, required this.alertId});
  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alert = ref.watch(alertByIdProvider(alertId));
    final colors = alert.value?.kind.gradient ?? AlertKind.flood.gradient;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors)),
          child: SafeArea(
            child: alert.when(
              skipLoadingOnRefresh: true,
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (e, _) => Column(
                children: [
                  _CloseRow(onClose: () => goBack(context, fallback: Routes.alerts)),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl)),
                      child: ErrorView(error: e, onRetry: () => ref.invalidate(alertByIdProvider(alertId))),
                    ),
                  ),
                ],
              ),
              data: (a) => _Content(alert: a),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseRow extends StatelessWidget {
  const _CloseRow({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: IconButton(tooltip: context.l10n.commonClose, onPressed: onClose, icon: const Icon(LucideIcons.x, color: Colors.white, size: 24)),
    ),
  );
}

class _Content extends StatelessWidget {
  const _Content({required this.alert});
  final FloodAlert alert;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final accent = alert.kind.gradient.last;
    final instructions = alert.instructions.isEmpty && alert.kind == AlertKind.flood ? defaultInstructions : alert.instructions;

    return Column(
      children: [
        _CloseRow(onClose: () => goBack(context, fallback: Routes.alerts)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(alert.kind.icon, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 18),
                Text(alert.kind.screenTitle(l), textAlign: TextAlign.center, style: AppText.h1.copyWith(color: Colors.white, fontSize: 27)),
                const SizedBox(height: 6),
                Text(alert.location, textAlign: TextAlign.center, style: AppText.body.copyWith(color: Colors.white.withValues(alpha: 0.92), fontSize: 15)),
                const SizedBox(height: 4),
                Text(l.alertIssuedAt(Fmt.dateTime(alert.createdAt)), textAlign: TextAlign.center, style: AppText.caption.copyWith(color: Colors.white.withValues(alpha: 0.75))),
                const SizedBox(height: 22),
                if (alert.levelCm != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.alertLevel, style: AppText.caption.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                              Text(Fmt.cm(alert.levelCm!), style: AppText.h1.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        Icon(alert.trend.icon, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(alert.trend.label(l), style: AppText.label.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                if (alert.message != null) ...[
                  const SizedBox(height: 14),
                  Text(alert.message!, style: AppText.body.copyWith(color: Colors.white)),
                ],
                if (instructions.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.alertInstructions, style: AppText.h3),
                        const SizedBox(height: 12),
                        for (final i in instructions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), shape: BoxShape.circle),
                                  child: Icon(i.icon.icon, size: 18, color: accent),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: Text(i.text, style: AppText.body.copyWith(fontSize: 13))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                if (alert.active && alert.kind != AlertKind.ended) ...[
                  PrimaryButton(
                    label: l.emergencyCallButton,
                    icon: LucideIcons.phoneCall,
                    color: AppColors.alertRedDark,
                    onPressed: () => showEmergencySheet(context, alertId: alert.id),
                  ),
                  const SizedBox(height: 12),
                ],
                PrimaryButton(
                  label: l.alertSeeMap,
                  color: Colors.white,
                  foreground: accent,
                  onPressed: () => context.go(Routes.mapFocus(station: alert.stationId, zone: alert.stationId == null ? alert.commune : null)),
                ),
                const SizedBox(height: 12),
                OutlinePillButton(
                  label: l.alertExplainAi,
                  foreground: accent,
                  leading: Icon(LucideIcons.sparkles, size: 18, color: accent),
                  onPressed: () => context.push(Routes.assistant(alertId: alert.id)),
                ),
                if (alert.stationId != null)
                  Center(
                    child: TextButton(
                      onPressed: () => context.push(Routes.station(alert.stationId!)),
                      child: Text(l.alertSeeStation, style: AppText.link.copyWith(color: Colors.white, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
