import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/headers.dart';

/// Conditions d'utilisation et politique de confidentialite.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(title: l.termsTitle, fallback: '/welcome'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                children: [AppCard(child: Text(l.termsBody, style: AppText.body))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
