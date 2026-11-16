import 'dart:ui';

import 'package:flutter/material.dart';

import '../twin_palette.dart';

/// Couleurs de l'interface selon le theme courant.
class Fx {
  const Fx._(this.dark);
  factory Fx.of(BuildContext context) => Fx._(Theme.of(context).brightness == Brightness.dark);

  final bool dark;
  Color get text => dark ? TwinColors.ice : TwinColors.navy;
  Color get muted => text.withValues(alpha: dark ? 0.62 : 0.56);
  Color get accent => dark ? TwinColors.sky : TwinColors.ocean;
  Color get onAccent => dark ? TwinColors.navy : Colors.white;
  Color get hover => accent.withValues(alpha: dark ? 0.16 : 0.09);
  Color get track => text.withValues(alpha: 0.1);
  Color get fill => dark ? TwinColors.navy.withValues(alpha: 0.66) : Colors.white.withValues(alpha: 0.7);
  Color get border => dark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.75);
  List<BoxShadow> get shadow => [
    BoxShadow(color: (dark ? Colors.black : TwinColors.navy).withValues(alpha: dark ? 0.45 : 0.18), blurRadius: 30, spreadRadius: -12, offset: const Offset(0, 10)),
    BoxShadow(color: (dark ? Colors.black : TwinColors.navy).withValues(alpha: dark ? 0.3 : 0.08), blurRadius: 6, spreadRadius: -2, offset: const Offset(0, 2)),
  ];
}

/// Panneau en verre depoli (BackdropFilter) aux coins arrondis.
class Glass extends StatelessWidget {
  const Glass({super.key, required this.child, this.padding = const EdgeInsets.all(12), this.radius = 16, this.width});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final fx = Fx.of(context);
    final r = BorderRadius.circular(radius);
    return Container(
      width: width,
      decoration: BoxDecoration(borderRadius: r, boxShadow: fx.shadow),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            padding: padding,
            decoration: BoxDecoration(
              color: fx.fill,
              borderRadius: r,
              border: Border.all(color: fx.border),
            ),
            child: DefaultTextStyle.merge(style: TextStyle(color: fx.text), child: child),
          ),
        ),
      ),
    );
  }
}

/// Bouton icone carre (40 px) avec etat actif.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({super.key, required this.child, required this.onTap, required this.tooltip, this.active = false, this.size = 40});

  final Widget child;
  final VoidCallback onTap;
  final String tooltip;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fx = Fx.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            hoverColor: fx.hover,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: active ? fx.accent : Colors.transparent, borderRadius: BorderRadius.circular(14)),
              child: IconTheme.merge(
                data: IconThemeData(color: active ? fx.onAccent : fx.text),
                child: DefaultTextStyle.merge(style: TextStyle(color: active ? fx.onAccent : fx.text.withValues(alpha: 0.85)), child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const sectionTitle = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.05);
