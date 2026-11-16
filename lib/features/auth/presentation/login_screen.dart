import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import 'auth_providers.dart';
import 'widgets/auth_widgets.dart';

/// Connexion par SMS ou Google (maquette 2).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  var _sending = false;
  var _google = false;
  String? _phoneError;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final l = context.l10n;
    final phone = toE164(_phone.text);
    setState(() {
      _phoneError = phone == null ? l.authErrorInvalidPhone : null;
      _error = null;
    });
    if (phone == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      final v = await ref.read(authRepositoryProvider).sendOtp(phone);
      if (mounted) context.push(Routes.otp, extra: v);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = describeError(l, e).message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    final l = context.l10n;
    setState(() {
      _google = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      // La redirection vers l'accueil (ou le choix de zone) est faite par le routeur.
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
    final demo = ref.watch(appConfigProvider).useMocks;
    return AuthScaffold(
      title: l.authLoginTitle,
      subtitle: Text(l.authLoginSubtitle),
      card: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          PhoneField(controller: _phone, errorText: _phoneError, onSubmitted: (_) => _sendCode()),
          const SizedBox(height: 18),
          PrimaryButton(label: l.authSendCode, color: AppColors.brand, loading: _sending, onPressed: _google ? null : _sendCode),
          const OrDivider(),
          OutlinePillButton(label: l.authContinueGoogle, leading: const GoogleLogo(), loading: _google, onPressed: _sending ? null : _signInWithGoogle),
          FormErrorText(_error),
          if (demo) ...[
            const SizedBox(height: 14),
            Text(l.authLoginDemoHint, textAlign: TextAlign.center, style: AppText.caption),
          ],
        ],
      ),
      footer: AuthFooterLink(text: l.authNoAccount, link: l.authCreateAccount, onTap: () => context.pushReplacement(Routes.register)),
    );
  }
}
