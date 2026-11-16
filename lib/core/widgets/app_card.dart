import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Carte blanche arrondie avec ombre douce, cliquable si [onTap] est fourni.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16), this.radius = AppRadius.lg, this.color = AppColors.surface, this.border});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: r, boxShadow: AppShadows.card, border: border),
      child: Material(
        color: color,
        borderRadius: r,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

/// Carree arrondie coloree contenant une icone (listes d'alertes, conseils, menu).
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, required this.color, required this.background, this.size = 44, this.radius = 12, this.iconSize});

  final IconData icon;
  final Color color;
  final Color background;
  final double size;
  final double radius;
  final double? iconSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(radius)),
    child: Icon(icon, color: color, size: iconSize ?? size * 0.48),
  );
}

/// Titre de section ("Niveau d'eau en temps reel", "Statut de ma zone").
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing, this.padding = const EdgeInsets.fromLTRB(0, 22, 0, 12)});

  final String text;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      children: [
        Expanded(child: Text(text, style: AppText.h3)),
        ?trailing,
      ],
    ),
  );
}
