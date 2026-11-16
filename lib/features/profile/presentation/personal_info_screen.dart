import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/headers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/widgets/auth_widgets.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late final _name = TextEditingController(text: ref.read(currentUserProvider)?.fullName ?? '');
  late final _email = TextEditingController(text: ref.read(currentUserProvider)?.email ?? '');
  late final _phone = TextEditingController(text: Fmt.phone(ref.read(currentUserProvider)?.phone ?? ''));
  var _saving = false;
  String? _nameError;
  String? _emailError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final name = _name.text.trim();
    final email = _email.text.trim();
    setState(() {
      _nameError = name.length < 3 ? l.authErrorNameRequired : null;
      _emailError = email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) ? l.profileInvalidEmail : null;
    });
    if (_nameError != null || _emailError != null) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authRepositoryProvider).updateProfile(fullName: name, email: email.isEmpty ? null : email);
      messenger.showSnackBar(SnackBar(content: Text(l.profileSaved)));
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
    final hasPhone = ref.watch(currentUserProvider)?.phone != null;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          PageHeader(title: l.profilePersonalInfo, fallback: Routes.profile),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                IconTextField(controller: _name, label: l.authFullNameLabel, icon: LucideIcons.circleUserRound, errorText: _nameError, textCapitalization: TextCapitalization.words),
                const SizedBox(height: 18),
                IconTextField(controller: _email, label: l.profileEmailLabel, hint: l.profileEmailHint, icon: LucideIcons.mail, errorText: _emailError, keyboardType: TextInputType.emailAddress),
                if (hasPhone) ...[
                  const SizedBox(height: 18),
                  IconTextField(controller: _phone, label: l.authPhoneLabel, icon: LucideIcons.phone, enabled: false),
                  const SizedBox(height: 6),
                  Text(l.profilePhoneReadonly, style: AppText.caption),
                ],
                const SizedBox(height: 28),
                PrimaryButton(label: l.commonSave, loading: _saving, onPressed: _save),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
