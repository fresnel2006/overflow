import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';

/// Squelettes gris animes pendant le chargement d'une liste.
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.count = 4, this.itemHeight = 76, this.padding = const EdgeInsets.all(20)});

  final int count;
  final double itemHeight;
  final EdgeInsetsGeometry padding;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Chargement',
    child: FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
      child: ListView.separated(
        padding: widget.padding,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.count,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => Container(
          height: widget.itemHeight,
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg)),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: 140, color: AppColors.surfaceMuted),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 90, color: AppColors.surfaceMuted),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.6)));
}

/// Message centre avec icone et action (erreur, liste vide, hors ligne).
class MessageView extends StatelessWidget {
  const MessageView({super.key, required this.icon, required this.title, this.message, this.actionLabel, this.onAction, this.iconColor = AppColors.primary, this.compact = false});

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color iconColor;
  final bool compact;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: compact ? 16 : 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 52 : 68,
            height: compact ? 52 : 68,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: compact ? 24 : 30),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppText.h3, textAlign: TextAlign.center),
          if (message != null) ...[const SizedBox(height: 6), Text(message!, style: AppText.bodyMuted, textAlign: TextAlign.center)],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            SizedBox(width: 200, child: PrimaryButton(label: actionLabel!, onPressed: onAction, height: 46, icon: LucideIcons.refreshCw)),
          ],
        ],
      ),
    ),
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry, this.compact = false});

  final Object error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final d = describeError(l, error);
    return MessageView(
      icon: d.offline ? LucideIcons.wifiOff : LucideIcons.circleAlert,
      iconColor: d.offline ? AppColors.textSecondary : AppColors.danger,
      title: d.title,
      message: d.message,
      actionLabel: onRetry == null ? null : l.commonRetry,
      onAction: onRetry,
      compact: compact,
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message, this.icon = LucideIcons.inbox, this.compact = false});

  final String message;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) => MessageView(icon: icon, title: message, iconColor: AppColors.textMuted, compact: compact);
}

/// Affiche les trois etats d'un AsyncValue. Si des donnees existent deja (rafraichissement en
/// echec, perte de connexion), on les garde a l'ecran plutot que d'afficher l'erreur.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({super.key, required this.value, required this.data, this.onRetry, this.loading, this.compact = false});

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final Widget? loading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (value.hasValue) return data(value.requireValue);
    if (value.hasError) return ErrorView(error: value.error!, onRetry: onRetry, compact: compact);
    return loading ?? const SkeletonList();
  }
}
