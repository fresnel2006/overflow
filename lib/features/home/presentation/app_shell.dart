import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/banners.dart';
import '../../alerts/presentation/alert_providers.dart';
import '../../emergency/presentation/emergency_providers.dart';
import '../../emergency/presentation/emergency_sheet.dart';
import '../../emergency/presentation/voice_guide.dart';

/// Squelette des 5 onglets : Accueil, Carte, Alertes, Signalement, Profil.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final alertInZone = ref.watch(myZoneActiveAlertProvider) != null;
    // Des que la zone suivie passe en danger, les consignes de securite sont lues a voix haute.
    ref.listen(inDangerZoneProvider, (was, now) {
      if (now && was != true) ref.read(voiceGuideProvider.notifier).speak(l.voiceGuidance);
    });
    final items = [
      (LucideIcons.house, l.navHome, false),
      (LucideIcons.map, l.navMap, false),
      (LucideIcons.bell, l.navAlerts, alertInZone),
      (LucideIcons.shield, l.navReport, false),
      (LucideIcons.circleUserRound, l.navProfile, false),
    ];
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: shell),
        ],
      ),
      // Visible uniquement quand la zone suivie est en danger.
      floatingActionButton: const SosButton(),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: items[i].$1,
                      label: items[i].$2,
                      badge: items[i].$3,
                      active: shell.currentIndex == i,
                      // Re-toucher l'onglet actif revient a sa racine.
                      onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap, this.badge = false});

  final IconData icon;
  final String label;
  final bool active;
  final bool badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      selected: active,
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 22, color: color),
                if (badge)
                  Positioned(
                    right: -3,
                    top: -2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption.copyWith(fontSize: 10.5, color: color, fontWeight: active ? FontWeight.w600 : FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
