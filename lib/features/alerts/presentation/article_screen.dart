import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/headers.dart';
import '../../../core/widgets/state_views.dart';
import 'alert_providers.dart';
import 'alert_style.dart';

/// Fiche de sensibilisation complete.
class ArticleScreen extends ConsumerWidget {
  const ArticleScreen({super.key, required this.articleId});
  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final articles = ref.watch(articlesProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(title: l.alertsAwarenessTitle, fallback: Routes.alertsFilter('tips')),
            Expanded(
              child: AsyncValueView(
                value: articles,
                onRetry: () => ref.invalidate(articlesProvider),
                data: (list) {
                  final a = list.where((a) => a.id == articleId).firstOrNull;
                  if (a == null) return const ErrorView(error: NotFoundException());
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    children: [
                      IconTile(icon: a.icon.icon, color: AppColors.primary, background: AppColors.primarySoft, size: 64, radius: 16),
                      const SizedBox(height: 16),
                      Text(a.title, style: AppText.h1.copyWith(fontSize: 22)),
                      const SizedBox(height: 6),
                      Text(Fmt.date(a.publishedAt), style: AppText.caption),
                      const SizedBox(height: 16),
                      Text(a.summary, style: AppText.body.copyWith(fontWeight: FontWeight.w500)),
                      for (final p in a.paragraphs) ...[const SizedBox(height: 12), Text(p, style: AppText.body)],
                      if (a.tips.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.awarenessKeyPoints, style: AppText.h3),
                              const SizedBox(height: 10),
                              for (final t in a.tips)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(padding: EdgeInsets.only(top: 2), child: Icon(LucideIcons.circleCheck, size: 18, color: AppColors.success)),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(t, style: AppText.body)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      OutlinePillButton(
                        label: l.awarenessAskAi,
                        leading: const Icon(LucideIcons.sparkles, size: 18, color: AppColors.primary),
                        onPressed: () => context.push(Routes.assistant(question: a.title)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
