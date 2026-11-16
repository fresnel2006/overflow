import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../network/connectivity_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Bandeau bleu clair "Ensemble, anticipons les inondations." en bas des ecrans d'authentification.
class AuthInfoBanner extends StatelessWidget {
  const AuthInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(
        children: [
          const Icon(LucideIcons.shieldCheck, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.authBannerTitle, style: AppText.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(l.authBannerSubtitle, style: AppText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bandeau affiche en haut de l'application quand l'appareil perd le reseau.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.isOffline;
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: !offline
          ? const SizedBox(width: double.infinity)
          : Material(
              color: AppColors.textPrimary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.wifiOff, size: 16, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(child: Text(context.l10n.offlineBanner, style: AppText.caption.copyWith(color: Colors.white))),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
