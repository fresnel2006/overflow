import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../domain/app_user.dart';
import 'auth_providers.dart';
import 'widgets/auth_widgets.dart';

/// Verification du code SMS a 6 chiffres (maquette 4).
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.verification});
  final PhoneVerification verification;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _resendDelay = 30;

  final _code = TextEditingController();
  final _focus = FocusNode();
  late PhoneVerification _verification = widget.verification;
  Timer? _timer;
  var _remaining = _resendDelay;
  var _verifying = false;
  var _resending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _code.addListener(() {
      setState(() => _error = null);
      if (_code.text.length == 6 && !_verifying) _verify();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remaining = _resendDelay);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) t.cancel();
      if (mounted) setState(() => _remaining = (_remaining - 1).clamp(0, _resendDelay));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final l = context.l10n;
    if (_code.text.length != 6) {
      setState(() => _error = l.authErrorInvalidCode);
      return;
    }
    setState(() => _verifying = true);
    try {
      await ref.read(authRepositoryProvider).verifyOtp(_verification, _code.text);
      // Le routeur redirige automatiquement une fois la session ouverte.
    } on AppException catch (e) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() => _error = describeError(l, e).message);
      _code.clear();
      _focus.requestFocus();
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    final l = context.l10n;
    setState(() => _resending = true);
    try {
      _verification = await ref.read(authRepositoryProvider).sendOtp(_verification.phone, fullName: _verification.fullName, resendToken: _verification.resendToken);
      _startTimer();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.authOtpResent)));
    } on AppException catch (e) {
      if (mounted) setState(() => _error = describeError(l, e).message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final demo = ref.watch(appConfigProvider).useMocks;
    final mm = (_remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (_remaining % 60).toString().padLeft(2, '0');

    return AuthScaffold(
      title: l.authOtpTitle,
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: l.authOtpSubtitle),
            TextSpan(text: '${Fmt.phone(_verification.phone)}.', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
      card: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.authOtpCodeLabel, style: AppText.title.copyWith(fontSize: 13.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          _OtpBoxes(controller: _code, focusNode: _focus, hasError: _error != null),
          const SizedBox(height: 10),
          Text(l.authOtpValidity, style: AppText.caption),
          FormErrorText(_error),
          const SizedBox(height: 18),
          PrimaryButton(label: l.authOtpVerify, color: AppColors.brand, loading: _verifying, onPressed: _verify),
          const SizedBox(height: 12),
          Center(
            child: TextButton(onPressed: () => context.pop(), child: Text(l.authOtpChangeNumber, style: AppText.link)),
          ),
          const SizedBox(height: 12),
          Text(l.authOtpNotReceived, textAlign: TextAlign.center, style: AppText.bodyMuted.copyWith(fontSize: 12.5)),
          const SizedBox(height: 4),
          Center(
            child: _remaining > 0
                ? Text.rich(
                    TextSpan(
                      style: AppText.bodyMuted.copyWith(fontSize: 12.5, color: AppColors.textPrimary),
                      children: [
                        TextSpan(text: l.authOtpResendIn),
                        TextSpan(text: '$mm:$ss', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()])),
                      ],
                    ),
                  )
                : _resending
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : TextButton(onPressed: _resend, child: Text(l.authOtpResend, style: AppText.link)),
          ),
          if (demo) ...[const SizedBox(height: 10), Text(l.authOtpDemoHint, textAlign: TextAlign.center, style: AppText.caption)],
        ],
      ),
    );
  }
}

/// 6 cases de chiffres pilotees par un champ invisible (copier-coller et remplissage auto du SMS).
class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({required this.controller, required this.focusNode, required this.hasError});

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Champ reel, invisible mais focalisable.
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              showCursor: false,
              enableInteractiveSelection: false,
            ),
          ),
        ),
        GestureDetector(
          onTap: focusNode.requestFocus,
          child: ListenableBuilder(
            listenable: Listenable.merge([controller, focusNode]),
            builder: (context, _) {
              final text = controller.text;
              return Row(
                children: [
                  for (var i = 0; i < 6; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 0.82,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: hasError
                                  ? AppColors.danger
                                  : (focusNode.hasFocus && i == text.length.clamp(0, 5))
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: (focusNode.hasFocus && i == text.length.clamp(0, 5)) ? 1.8 : 1,
                            ),
                          ),
                          child: Text(i < text.length ? text[i] : '', style: AppText.h2.copyWith(fontSize: 22)),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
