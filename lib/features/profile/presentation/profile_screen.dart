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
import '../../../core/widgets/headers.dart';
import '../../auth/presentation/auth_providers.dart';

/// Mon profil (maquette 13).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.profileLogoutConfirmTitle),
        content: Text(l.profileLogoutConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.profileLogout, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (ok == true) await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          // L'en-tete a deja sa propre marge de 20 : on compense celle de la liste.
          Transform.translate(offset: const Offset(-20, 0), child: PageHeader(title: l.profileTitle, showBack: false)),
          AppCard(
            onTap: () => context.go(Routes.personalInfo),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  child: Text(user.initials, style: AppText.h2.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName.isEmpty ? Fmt.phone(user.phone ?? '') : user.fullName, style: AppText.h3.copyWith(fontSize: 17)),
                      const SizedBox(height: 2),
                      Text(
                        user.email ?? (user.phone == null ? l.profileNoEmail : Fmt.phone(user.phone!)),
                        style: AppText.caption.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('${user.commune ?? '-'}, Abidjan', style: AppText.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _MenuRow(icon: LucideIcons.user, label: l.profilePersonalInfo, onTap: () => context.go(Routes.personalInfo)),
                const Divider(indent: 16, endIndent: 16),
                _MenuRow(icon: LucideIcons.mapPin, label: l.profileZone, subtitle: user.commune == null ? l.profileNoZone : '${user.commune}, Abidjan', onTap: () => context.go(Routes.zone)),
                const Divider(indent: 16, endIndent: 16),
                _MenuRow(icon: LucideIcons.slidersHorizontal, label: l.profileSettings, onTap: () => context.go(Routes.settings)),
                const Divider(indent: 16, endIndent: 16),
                _MenuRow(icon: LucideIcons.circleHelp, label: l.profileHelp, onTap: () => context.go(Routes.help)),
                const Divider(indent: 16, endIndent: 16),
                _MenuRow(icon: LucideIcons.logOut, label: l.profileLogout, color: AppColors.danger, showChevron: false, onTap: () => _logout(context, ref)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, required this.onTap, this.subtitle, this.color = AppColors.textPrimary, this.showChevron = true});

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color color;
  final bool showChevron;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color == AppColors.textPrimary ? AppColors.primary : color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.title.copyWith(fontWeight: FontWeight.w500, color: color)),
                if (subtitle != null) Text(subtitle!, style: AppText.caption),
              ],
            ),
          ),
          if (showChevron) const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
        ],
      ),
    ),
  );
}
