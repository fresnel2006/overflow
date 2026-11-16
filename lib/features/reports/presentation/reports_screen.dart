import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

/// Onglet Signalement : acces rapide au formulaire et suivi de mes signalements.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final reports = ref.watch(myReportsProvider);
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(myReportsProvider.future),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: PageHeader(title: l.reportTabTitle, showBack: false)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Material(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push(Routes.newReport),
                    child: Ink(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.heroStart, AppColors.heroEnd])),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.reportCtaTitle, style: AppText.h3.copyWith(color: Colors.white, fontSize: 18)),
                                const SizedBox(height: 6),
                                Text(l.reportCtaSubtitle, style: AppText.caption.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), shape: BoxShape.circle),
                            child: const Icon(LucideIcons.camera, color: Colors.white, size: 26),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: SectionTitle(l.reportMyReports)),
            ),
            ...switch (reports) {
              AsyncValue(hasValue: true, :final value) =>
                value!.isEmpty
                    ? [SliverToBoxAdapter(child: EmptyView(message: l.reportEmpty, icon: LucideIcons.fileText))]
                    : [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          sliver: SliverList.separated(
                            itemCount: value.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (_, i) => ReportTile(report: value[i]),
                          ),
                        ),
                      ],
              AsyncValue(:final error?) => [SliverToBoxAdapter(child: ErrorView(error: error, compact: true, onRetry: () => ref.invalidate(myReportsProvider)))],
              _ => [const SliverToBoxAdapter(child: SkeletonList(count: 3))],
            },
          ],
        ),
      ),
    );
  }
}

class ReportTile extends StatelessWidget {
  const ReportTile({super.key, required this.report});
  final CitizenReport report;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      onTap: () => context.push(Routes.report(report.id)),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ReportThumb(report: report, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.type.label(l), style: AppText.title),
                const SizedBox(height: 2),
                Text('${report.commune} · ${Fmt.dateTime(report.createdAt)}', style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                StatusPill(label: report.status.label(l), color: report.status.color, background: report.status.softColor, dot: report.status.color),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

/// Miniature : photo locale, photo distante ou icone du type.
class ReportThumb extends StatelessWidget {
  const ReportThumb({super.key, required this.report, this.size = 56});
  final CitizenReport report;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = IconTile(icon: report.type.icon, color: AppColors.primary, background: AppColors.primarySoft, size: size, radius: 12);
    Widget? image;
    if (report.localPhotoPath != null) {
      image = Image.file(File(report.localPhotoPath!), fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback);
    } else if (report.photoUrl != null) {
      image = Image.network(report.photoUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback);
    }
    if (image == null) return fallback;
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: size, height: size, child: image));
  }
}
