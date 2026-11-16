import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/headers.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final emergency = [(LucideIcons.siren, l.helpFirefighters, '180'), (LucideIcons.activity, l.helpSamu, '185'), (LucideIcons.shield, l.helpPolice, '110')];
    final faq = [(l.helpQ1, l.helpA1), (l.helpQ2, l.helpA2), (l.helpQ3, l.helpA3), (l.helpQ4, l.helpA4)];

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          PageHeader(title: l.helpTitle, fallback: Routes.profile),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                SectionTitle(l.helpEmergency, padding: const EdgeInsets.only(bottom: 10)),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      for (final (i, e) in emergency.indexed) ...[
                        if (i > 0) const Divider(indent: 16, endIndent: 16),
                        ListTile(
                          leading: IconTile(icon: e.$1, color: AppColors.danger, background: AppColors.dangerSoft, size: 38, radius: 19),
                          title: Text(e.$2, style: AppText.title.copyWith(fontWeight: FontWeight.w500)),
                          trailing: Text(e.$3, style: AppText.h3.copyWith(color: AppColors.danger)),
                          onTap: () {
                            // Copie du numero : le composeur n'est pas ouvert automatiquement.
                            Clipboard.setData(ClipboardData(text: e.$3));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${e.$2} : ${e.$3}')));
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                SectionTitle(l.helpFaq),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: Column(
                      children: [
                        for (final (q, a) in faq)
                          ExpansionTile(
                            title: Text(q, style: AppText.title.copyWith(fontWeight: FontWeight.w500, fontSize: 13.5)),
                            iconColor: AppColors.primary,
                            collapsedIconColor: AppColors.textMuted,
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                            children: [Text(a, style: AppText.bodyMuted)],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OverflowLogo(size: 30),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.helpAbout, style: AppText.caption.copyWith(fontSize: 12))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
