import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/headers.dart';
import '../../alerts/presentation/alert_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import 'settings_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  var _testing = false;

  Future<void> _testAlert() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _testing = true);
    try {
      await ref.read(alertRepositoryProvider).requestTestAlert(ref.read(userCommuneProvider));
      messenger.showSnackBar(SnackBar(content: Text(l.settingsTestAlertSent)));
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l, e).message)));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);
    final config = ref.watch(appConfigProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          PageHeader(title: l.settingsTitle, fallback: Routes.profile),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                SectionTitle(l.settingsNotifications, padding: const EdgeInsets.only(bottom: 10)),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _SwitchRow(icon: LucideIcons.bellRing, title: l.settingsPushAlerts, subtitle: l.settingsPushAlertsDesc, value: prefs.push, onChanged: (v) => notifier.update(prefs.copyWith(push: v))),
                      const Divider(indent: 16, endIndent: 16),
                      _SwitchRow(icon: LucideIcons.bell, title: l.settingsVigilance, subtitle: l.settingsVigilanceDesc, value: prefs.vigilance, onChanged: (v) => notifier.update(prefs.copyWith(vigilance: v))),
                      const Divider(indent: 16, endIndent: 16),
                      _SwitchRow(icon: LucideIcons.globe, title: l.settingsAllZones, subtitle: l.settingsAllZonesDesc, value: prefs.allCommunes, onChanged: (v) => notifier.update(prefs.copyWith(allCommunes: v))),
                      const Divider(indent: 16, endIndent: 16),
                      _SwitchRow(icon: LucideIcons.messageSquareText, title: l.settingsSms, subtitle: l.settingsSmsDesc, value: prefs.sms, onChanged: (v) => notifier.update(prefs.copyWith(sms: v))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                OutlinePillButton(
                  label: l.settingsTestAlert,
                  loading: _testing,
                  leading: const Icon(LucideIcons.siren, size: 18, color: AppColors.primary),
                  onPressed: _testAlert,
                ),
                SectionTitle(l.settingsData),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _InfoRow(icon: LucideIcons.radio, title: l.settingsDataSource, value: config.useMocks ? l.settingsDataMock : l.settingsDataLive),
                      const Divider(indent: 16, endIndent: 16),
                      _InfoRow(icon: LucideIcons.globe, title: l.settingsLanguage, value: l.settingsLanguageValue),
                    ],
                  ),
                ),
                SectionTitle(l.settingsAbout),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _InfoRow(icon: LucideIcons.info, title: l.settingsVersion, value: '1.0.0'),
                      const Divider(indent: 16, endIndent: 16),
                      InkWell(
                        onTap: () => context.push(Routes.terms),
                        child: _InfoRow(icon: LucideIcons.fileText, title: l.settingsTerms, value: '', chevron: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.title.copyWith(fontWeight: FontWeight.w500)),
                  Text(subtitle, style: AppText.caption),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.value, this.chevron = false});
  final IconData icon;
  final String title;
  final String value;
  final bool chevron;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: AppText.title.copyWith(fontWeight: FontWeight.w500))),
        Text(value, style: AppText.bodyMuted),
        if (chevron) const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
      ],
    ),
  );
}
