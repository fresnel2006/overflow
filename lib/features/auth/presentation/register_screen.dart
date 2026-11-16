import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import 'auth_providers.dart';
import 'widgets/auth_widgets.dart';

/// Creation de compte (maquette 3).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _termsTap = TapGestureRecognizer();
  final _privacyTap = TapGestureRecognizer();
  var _accepted = false;
  var _sending = false;
  var _google = false;
  String? _nameError;
  String? _phoneError;
  String? _error;

  @override
  void initState() {
    super.initState();
    _termsTap.onTap = () => context.push(Routes.terms);
    _privacyTap.onTap = () => context.push(Routes.terms);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  bool _validate() {
    final l = context.l10n;
    setState(() {
      _nameError = _name.text.trim().length < 3 ? l.authErrorNameRequired : null;
      _phoneError = toE164(_phone.text) == null ? l.authErrorInvalidPhone : null;
      _error = (_nameError == null && _phoneError == null && !_accepted) ? l.authErrorTermsRequired : null;
    });
    return _nameError == null && _phoneError == null && _accepted;
  }

  Future<void> _sendCode() async {
    if (!_validate()) return;
    final l = context.l10n;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      final v = await ref.read(authRepositoryProvider).sendOtp(toE164(_phone.text)!, fullName: _name.text.trim());
      if (mounted) context.push(Routes.otp, extra: v);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = describeError(l, e).message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    final l = context.l10n;
    if (!_accepted) {
      setState(() => _error = l.authErrorTermsRequired);
      return;
    }
    setState(() {
      _google = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } on ValidationException catch (e) {
      if (mounted && e.code != 'cancelled') setState(() => _error = l.authErrorGoogle);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e is NetworkException ? l.errorNetworkMessage : l.authErrorGoogle);
    } finally {
      if (mounted) setState(() => _google = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AuthScaffold(
      title: l.authRegisterTitle,
      subtitle: Text(l.authRegisterSubtitle),
      showBanner: false,
      card: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            IconTextField(
              controller: _name,
              label: l.authFullNameLabel,
              hint: l.authFullNameHint,
              icon: LucideIcons.circleUserRound,
              errorText: _nameError,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: 18),
            PhoneField(controller: _phone, errorText: _phoneError, onSubmitted: (_) => _sendCode()),
            const SizedBox(height: 18),
            PrimaryButton(label: l.authSendCode, color: AppColors.brand, loading: _sending, onPressed: _google ? null : _sendCode),
            const OrDivider(),
            OutlinePillButton(label: l.authContinueGoogle, leading: const GoogleLogo(), loading: _google, onPressed: _sending ? null : _continueWithGoogle),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Checkbox(value: _accepted, onChanged: (v) => setState(() => _accepted = v ?? false)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text.rich(
                      TextSpan(
                        style: AppText.caption.copyWith(fontSize: 12),
                        children: [
                          TextSpan(text: l.authAcceptPrefix),
                          TextSpan(text: l.authTerms, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600), recognizer: _termsTap),
                          TextSpan(text: l.authAnd),
                          TextSpan(text: l.authPrivacy, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600), recognizer: _privacyTap),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            FormErrorText(_error),
          ],
        ),
      ),
      footer: AuthFooterLink(text: l.authHaveAccount, link: l.authSignIn, onTap: () => context.pushReplacement(Routes.login)),
    );
  }
}
