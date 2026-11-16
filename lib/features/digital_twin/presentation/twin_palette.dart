import 'dart:ui';

/// Palette du jumeau numerique, alignee sur les couleurs de l'application.
abstract final class TwinColors {
  static const navy = Color(0xFF0F172A);
  static const ocean = Color(0xFF0B5ED7);
  static const sky = Color(0xFF7FB6F0);
  static const ice = Color(0xFFE6F0FB);
  static const sand = Color(0xFFF2D9A6);
}

/// Chiffres tabulaires pour les valeurs.
const tabular = [FontFeature.tabularFigures()];
