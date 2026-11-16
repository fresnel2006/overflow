import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

abstract final class AppRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
}

abstract final class AppShadows {
  static const card = [BoxShadow(color: Color(0x140F172A), blurRadius: 18, offset: Offset(0, 6), spreadRadius: -6)];
  static const soft = [BoxShadow(color: Color(0x0F0F172A), blurRadius: 8, offset: Offset(0, 2))];
  static List<BoxShadow> button(Color c) => [BoxShadow(color: c.withValues(alpha: 0.32), blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -4)];
}

/// Styles de texte (Poppins).
abstract final class AppText {
  static const family = 'Poppins';
  static const _tab = [FontFeature.tabularFigures()];

  static const display = TextStyle(fontFamily: family, fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.15);
  static const h1 = TextStyle(fontFamily: family, fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.25);
  static const h2 = TextStyle(fontFamily: family, fontSize: 19, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3);
  static const h3 = TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.35);
  static const title = TextStyle(fontFamily: family, fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.35);
  static const body = TextStyle(fontFamily: family, fontSize: 13.5, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5);
  static const bodyMuted = TextStyle(fontFamily: family, fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5);
  static const caption = TextStyle(fontFamily: family, fontSize: 11.5, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.4);
  static const label = TextStyle(fontFamily: family, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.3);
  static const button = TextStyle(fontFamily: family, fontSize: 15, fontWeight: FontWeight.w600, height: 1.2);
  static const link = TextStyle(fontFamily: family, fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary);
  static const value = TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFeatures: _tab);
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.brand,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: AppText.family);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkRipple.splashFactory,
      textTheme: base.textTheme.apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary, fontFamily: AppText.family),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppText.h2,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppText.body.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        hintStyle: AppText.body.copyWith(color: AppColors.textMuted),
        labelStyle: AppText.body.copyWith(color: AppColors.textSecondary),
        floatingLabelStyle: AppText.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
        border: _outline(AppColors.border),
        enabledBorder: _outline(AppColors.border),
        focusedBorder: _outline(AppColors.primary, 1.6),
        errorBorder: _outline(AppColors.danger),
        focusedErrorBorder: _outline(AppColors.danger, 1.6),
        errorStyle: AppText.caption.copyWith(color: AppColors.danger),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: AppColors.textMuted, width: 1.4),
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.border),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.border,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        titleTextStyle: AppText.h3,
        contentTextStyle: AppText.bodyMuted,
      ),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.primary, selectionHandleColor: AppColors.primary),
    );
  }

  static OutlineInputBorder _outline(Color c, [double w = 1]) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: c, width: w));
}
