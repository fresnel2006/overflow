import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/banners.dart';
import '../../../../core/widgets/headers.dart';

/// Gabarit commun des ecrans Connexion, Creer un compte et Verification OTP.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, required this.subtitle, required this.card, this.footer, this.onBack, this.showBanner = true});

  final String title;
  final Widget subtitle;
  final Widget card;
  final Widget? footer;
  final VoidCallback? onBack;
  final bool showBanner;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight - 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthHeader(onBack: onBack),
                        const SizedBox(height: 28),
                        Text(title, style: AppText.h1),
                        const SizedBox(height: 8),
                        DefaultTextStyle.merge(style: AppText.bodyMuted, child: subtitle),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 22),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.card),
                          child: card,
                        ),
                        if (footer != null) ...[const SizedBox(height: 24), footer!],
                        const SizedBox(height: 24),
                        if (showBanner) const AuthInfoBanner(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Pas encore de compte ? Creer un compte"
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({super.key, required this.text, required this.link, required this.onTap});
  final String text;
  final String link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text('$text ', style: AppText.bodyMuted),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Text(link, style: AppText.link),
        ),
      ),
    ],
  );
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Text(context.l10n.commonOr, textAlign: TextAlign.center, style: AppText.caption.copyWith(fontSize: 12.5)),
  );
}

/// Formate la saisie en "07 00 00 00 00" (10 chiffres).
class IvorianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('225') && digits.length > 10) digits = digits.substring(3);
    if (digits.length > 10) digits = digits.substring(0, 10);
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i.isEven) buf.write(' ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Numero saisi -> format E.164 (+225XXXXXXXXXX), ou null si incomplet.
String? toE164(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  return digits.length == 10 ? '+225$digits' : null;
}

/// Champ "Numero de telephone" avec indicatif +225.
class PhoneField extends StatelessWidget {
  const PhoneField({super.key, required this.controller, this.errorText, this.onSubmitted, this.autofocus = false});

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [IvorianPhoneFormatter()],
      onSubmitted: onSubmitted,
      style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.3),
      decoration: InputDecoration(
        labelText: l.authPhoneLabel,
        hintText: l.authPhoneHint,
        errorText: errorText,
        errorMaxLines: 2,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('+225', style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              Container(width: 1, height: 22, color: AppColors.border),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}

/// Champ texte avec icone (Nom complet, e-mail).
class IconTextField extends StatelessWidget {
  const IconTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    enabled: enabled,
    keyboardType: keyboardType,
    textCapitalization: textCapitalization,
    autofillHints: autofillHints,
    textInputAction: TextInputAction.next,
    style: AppText.body.copyWith(fontSize: 14.5, fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Icon(icon, size: 19, color: AppColors.primary),
      fillColor: enabled ? AppColors.surface : AppColors.surfaceMuted,
    ),
  );
}

/// Message d'erreur sous un formulaire.
class FormErrorText extends StatelessWidget {
  const FormErrorText(this.message, {super.key});
  final String? message;

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: const Duration(milliseconds: 200),
    child: message == null
        ? const SizedBox(width: double.infinity)
        : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.circleAlert, size: 16, color: AppColors.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(message!, style: AppText.caption.copyWith(color: AppColors.danger, fontSize: 12.5)),
                ),
              ],
            ),
          ),
  );
}
