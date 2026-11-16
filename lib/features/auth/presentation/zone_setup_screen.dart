import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/headers.dart';
import '../../profile/presentation/widgets/commune_picker.dart';
import 'auth_providers.dart';

/// Premiere connexion : choix de la commune suivie avant d'entrer dans l'application.
class ZoneSetupScreen extends ConsumerStatefulWidget {
  const ZoneSetupScreen({super.key});

  @override
  ConsumerState<ZoneSetupScreen> createState() => _ZoneSetupScreenState();
}

class _ZoneSetupScreenState extends ConsumerState<ZoneSetupScreen> {
  String? _selected;
  var _saving = false;

  Future<void> _confirm() async {
    final l = context.l10n;
    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).updateProfile(commune: _selected);
      // Le routeur envoie vers l'accueil des que le profil contient une commune.
    } on AppException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(l, e).message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 0), child: Align(alignment: Alignment.centerLeft, child: BrandWordmark())),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.authZoneTitle, style: AppText.h1),
                  const SizedBox(height: 6),
                  Text(l.authZoneSubtitle, style: AppText.bodyMuted),
                ],
              ),
            ),
            Expanded(child: CommunePicker(selected: _selected, onSelected: (c) => setState(() => _selected = c.name))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(label: l.authZoneConfirm, loading: _saving, onPressed: _selected == null ? null : _confirm),
            ),
          ],
        ),
      ),
    );
  }
}
