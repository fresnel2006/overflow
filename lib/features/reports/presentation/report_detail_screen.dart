import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/headers.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/citizen_report.dart';
import 'report_providers.dart';
import 'report_style.dart';

/// Suivi d'un signalement : photo, description, statut et historique de traitement.
class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.reportId});
  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(title: l.reportDetailTitle, fallback: Routes.reports),
            Expanded(
              child: AsyncValueView(
                value: ref.watch(reportByIdProvider(reportId)),
                onRetry: () => ref.invalidate(reportByIdProvider(reportId)),
                data: (r) => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  children: [
                    if (r.localPhotoPath != null || r.photoUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: AspectRatio(
                          aspectRatio: 1.6,
                          child: r.localPhotoPath != null
                              ? Image.file(File(r.localPhotoPath!), fit: BoxFit.cover)
                              : Image.network(
                                  r.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.surfaceMuted, child: Icon(LucideIcons.image, color: AppColors.textMuted)),
                                ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Text(r.type.label(l), style: AppText.h2)),
                        StatusPill(label: r.status.label(l), color: r.status.color, background: r.status.softColor, dot: r.status.color),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${r.commune}, Abidjan · ${Fmt.dateTime(r.createdAt)}', style: AppText.caption),
                    const SizedBox(height: 14),
                    AppCard(child: Text(r.description, style: AppText.body)),
                    SectionTitle(l.reportDetailHistory),
                    AppCard(child: _Timeline(events: r.history.isEmpty ? [ReportStatusEvent(r.status, r.createdAt)] : r.history)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.events});
  final List<ReportStatusEvent> events;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ordered = [...events]..sort((a, b) => b.at.compareTo(a.at));
    return Column(
      children: [
        for (final (i, e) in ordered.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(top: 3),
                      decoration: BoxDecoration(
                        color: i == 0 ? e.status.color : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: e.status.color, width: 2.5),
                      ),
                    ),
                    if (i < ordered.length - 1) Expanded(child: Container(width: 2, color: AppColors.divider)),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.status.label(l), style: AppText.title.copyWith(fontSize: 13.5)),
                        Text(Fmt.dateTime(e.at), style: AppText.caption),
                        if (e.note != null) ...[const SizedBox(height: 4), Text(e.note!, style: AppText.body.copyWith(fontSize: 12.5))],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
