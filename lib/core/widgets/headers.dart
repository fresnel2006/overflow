import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';

/// Goutte Overflow (logo sans fond).
class OverflowLogo extends StatelessWidget {
  const OverflowLogo({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/images/overflow_sans_fond.png', width: size, height: size, fit: BoxFit.contain, semanticLabel: 'Overflow');
}

/// Logo + "OverFlow" en bleu (en-tete des ecrans d'authentification et de l'accueil).
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.logoSize = 26, this.fontSize = 18, this.color = AppColors.brand, this.text});

  final double logoSize;
  final double fontSize;
  final Color color;
  final String? text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      OverflowLogo(size: logoSize),
      const SizedBox(width: 6),
      Text(text ?? context.l10n.appName, style: AppText.h2.copyWith(fontSize: fontSize, fontWeight: FontWeight.w700, color: color)),
    ],
  );
}

/// Retour arriere : pop si possible, sinon [fallback].
void goBack(BuildContext context, {String fallback = '/home'}) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}

/// En-tete "<- Titre" des pages secondaires (Sensibilisation, Meteo, Signaler un probleme...).
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.onBack, this.showBack = true, this.trailing, this.fallback = '/home'});

  final String title;
  final VoidCallback? onBack;
  final bool showBack;
  final Widget? trailing;
  final String fallback;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(showBack ? 8 : 20, 22, 12, 14),
    child: Row(
      children: [
        if (showBack)
          IconButton(
            tooltip: context.l10n.commonBack,
            onPressed: onBack ?? () => goBack(context, fallback: fallback),
            icon: const Icon(LucideIcons.arrowLeft, size: 22, color: AppColors.textPrimary),
          ),
        if (showBack) const SizedBox(width: 2),
        Expanded(child: Text(title, style: AppText.h2, overflow: TextOverflow.ellipsis)),
        ?trailing,
      ],
    ),
  );
}

/// En-tete des ecrans d'authentification : bouton retour rond + logo centre.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleIconButton(icon: LucideIcons.arrowLeft, tooltip: context.l10n.commonBack, size: 38, onPressed: onBack ?? () => goBack(context, fallback: '/welcome')),
        ),
        const BrandWordmark(),
      ],
    ),
  );
}
