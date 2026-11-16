import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/headers.dart';
import '../../auth/presentation/auth_providers.dart';
import 'widgets/commune_picker.dart';

/// Ma zone d'habitation : commune dont on recoit les alertes.
class ZoneScreen extends ConsumerStatefulWidget {
  const ZoneScreen({super.key});

  @override
  ConsumerState<ZoneScreen> createState() => _ZoneScreenState();
}

class _ZoneScreenState extends ConsumerState<ZoneScreen> {
  late String? _selected = ref.read(currentUserProvider)?.commune;
  var _saving = false;

  Future<void> _save() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).updateProfile(commune: _selected);
      messenger.showSnackBar(SnackBar(content: Text(l.profileZoneUpdated(_selected!))));
      if (mounted) goBack(context, fallback: Routes.profile);
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l, e).message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = ref.watch(currentUserProvider)?.commune;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: l.profileZone, fallback: Routes.profile),
          Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 14), child: Text(l.authZoneSubtitle, style: AppText.bodyMuted)),
          Expanded(child: CommunePicker(selected: _selected, onSelected: (c) => setState(() => _selected = c.name))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: PrimaryButton(label: l.commonSave, loading: _saving, onPressed: _selected == null || _selected == current ? null : _save),
          ),
        ],
      ),
    );
  }
}
