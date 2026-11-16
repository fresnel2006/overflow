import 'package:flutter/material.dart';

/// Couleurs relevees sur les maquettes Overflow.
abstract final class AppColors {
  // Marque
  static const brand = Color(0xFF3599E5); // ecrans d'accueil et d'authentification
  static const brandSoft = Color(0xFFE6F2FF);
  static const primary = Color(0xFF0B5ED7); // boutons et elements actifs de l'application
  static const primaryDark = Color(0xFF0A4FB8);
  static const primarySoft = Color(0xFFE3EEFD);
  static const heroStart = Color(0xFF3B82F6);
  static const heroEnd = Color(0xFF0B5ED7);

  // Surfaces
  static const background = Color(0xFFF1F5F9);
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF2F6FA);
  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFEDF1F5);

  // Textes
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);

  // Statuts
  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFDCFCE7);
  static const warning = Color(0xFFEAB308);
  static const warningText = Color(0xFFA16207);
  static const warningSoft = Color(0xFFFEF3C7);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEE2E2);

  // Ecran d'alerte
  static const alertRed = Color(0xFFDC2626);
  static const alertRedDark = Color(0xFF9C1B1B);

  // Carte
  static const riskHigh = Color(0xFFEF4444);
  static const riskMedium = Color(0xFFEAB308);
  static const riskLow = Color(0xFF3B82F6);
}
