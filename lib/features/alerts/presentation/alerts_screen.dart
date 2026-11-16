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
import '../../../core/widgets/pill_chips.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/awareness_article.dart';
import '../domain/flood_alert.dart';
import 'alert_providers.dart';
import 'alert_style.dart';

enum AlertsFilter {
  all,
  myZone,
  floods,
  tips;

  static AlertsFilter fromName(String? v) => switch (v) {
    'zone' => AlertsFilter.myZone,
    'floods' => AlertsFilter.floods,
    'tips' => AlertsFilter.tips,
    _ => AlertsFilter.all,
  };
}

/// Onglet Alertes : "Historique des alertes" (maquette 11) et "Sensibilisation" (maquette 10)
/// partagent la meme rangee de filtres ; le filtre Conseils affiche la sensibilisation.
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key, this.initialFilter = AlertsFilter.all});
  final AlertsFilter initialFilter;

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  late var _filter = widget.initialFilter;

  @override
  void didUpdateWidget(AlertsScreen old) {
    super.didUpdateWidget(old);
    if (old.initialFilter != widget.initialFilter) _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tips = _filter == AlertsFilter.tips;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: tips ? l.alertsAwarenessTitle : l.alertsHistoryTitle, onBack: () => context.go(Routes.home)),
          PillChips<AlertsFilter>(
            items: [
              (AlertsFilter.all, l.alertsFilterAll),
              (AlertsFilter.myZone, l.alertsFilterMyZone),
              (AlertsFilter.floods, l.alertsFilterFloods),
              (AlertsFilter.tips, l.alertsFilterTips),
            ],
            selected: _filter,
            onSelected: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: tips ? const _ArticlesList(key: ValueKey('tips')) : _AlertsList(key: ValueKey(_filter), filter: _filter),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertsList extends ConsumerWidget {
  const _AlertsList({super.key, required this.filter});
  final AlertsFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final commune = ref.watch(userCommuneProvider);
    return AsyncValueView(
      value: ref.watch(alertsProvider),
      onRetry: () => ref.invalidate(alertsProvider),
      data: (all) {
        final list = all.where((a) {
          return switch (filter) {
            AlertsFilter.myZone => a.commune == commune,
            AlertsFilter.floods => a.kind == AlertKind.flood,
            _ => true,
          };
        }).toList();
        return RefreshIndicator(
          onRefresh: () => ref.refresh(alertsProvider.future),
          child: list.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 60),
                    EmptyView(message: filter == AlertsFilter.myZone ? l.alertsEmptyZone : l.alertsEmpty, icon: LucideIcons.bellRing),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => AlertTile(alert: list[i]),
                ),
        );
      },
    );
  }
}

class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.alert});
  final FloodAlert alert;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      onTap: () => context.push(Routes.alert(alert.id)),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconTile(icon: alert.kind.icon, color: alert.kind.color, background: alert.kind.softColor, size: 44, radius: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(alert.kind.label(l), style: AppText.title)),
                    if (alert.active) ...[
                      const SizedBox(width: 8),
                      StatusPill(label: l.alertsActiveBadge, color: AppColors.danger, background: AppColors.dangerSoft, dot: AppColors.danger),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(alert.location.replaceFirst(' - ', ' · '), style: AppText.caption.copyWith(color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(Fmt.dateTime(alert.createdAt), style: AppText.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _ArticlesList extends ConsumerWidget {
  const _ArticlesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return AsyncValueView(
      value: ref.watch(articlesProvider),
      onRetry: () => ref.invalidate(articlesProvider),
      loading: const SkeletonList(itemHeight: 110),
      data: (list) => RefreshIndicator(
        onRefresh: () => ref.refresh(articlesProvider.future),
        child: list.isEmpty
            ? ListView(children: [const SizedBox(height: 60), EmptyView(message: l.awarenessEmpty, icon: LucideIcons.lightbulb)])
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (_, i) => _ArticleCard(article: list[i]),
              ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});
  final AwarenessArticle article;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: () => context.push(Routes.article(article.id)),
    padding: const EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(icon: article.icon.icon, color: AppColors.primary, background: AppColors.primarySoft, size: 84, radius: 14, iconSize: 32),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: AppText.title.copyWith(fontWeight: FontWeight.w700, height: 1.3)),
                const SizedBox(height: 4),
                Text(article.summary, style: AppText.caption.copyWith(fontSize: 11.5), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(Fmt.date(article.publishedAt), style: AppText.caption.copyWith(fontSize: 10.5, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
