import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Bouton principal en pilule (Recevoir le code SMS, Envoyer, Commencer...).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.loading = false, this.color = AppColors.primary, this.foreground = Colors.white, this.icon, this.height = 54});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color color;
  final Color foreground;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: onPressed == null ? 0.55 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(height), boxShadow: enabled ? AppShadows.button(color) : null),
        child: Material(
          color: color,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Center(
                child: loading
                    ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: foreground))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[Icon(icon, size: 19, color: foreground), const SizedBox(width: 8)],
                          Flexible(child: Text(label, style: AppText.button.copyWith(color: foreground), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bouton blanc a bord fin (Continuer avec Google, actions secondaires).
class OutlinePillButton extends StatelessWidget {
  const OutlinePillButton({super.key, required this.label, required this.onPressed, this.leading, this.loading = false, this.foreground = AppColors.primary, this.height = 50});

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool loading;
  final Color foreground;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: loading ? null : onPressed,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: loading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: foreground))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leading != null) ...[leading!, const SizedBox(width: 10)],
                      Flexible(
                        child: Text(label, overflow: TextOverflow.ellipsis, style: AppText.button.copyWith(fontSize: 13.5, color: foreground)),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Logo "G" officiel (vectoriel).
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 18});
  final double size;

  static const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
<path fill="#FFC107" d="M43.6 20.1H42V20H24v8h11.3C33.7 32.7 29.2 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 13 4 4 13 4 24s9 20 20 20 20-9 20-20c0-1.3-.1-2.6-.4-3.9z"/>
<path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 15.1 19 12 24 12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 16.3 4 9.7 8.3 6.3 14.7z"/>
<path fill="#4CAF50" d="M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2C29.2 35.1 26.7 36 24 36c-5.2 0-9.6-3.3-11.3-8l-6.5 5C9.5 39.6 16.2 44 24 44z"/>
<path fill="#1976D2" d="M43.6 20.1H42V20H24v8h11.3c-.8 2.2-2.2 4.2-4.1 5.6l6.2 5.2C37 39.2 44 34 44 24c0-1.3-.1-2.6-.4-3.9z"/>
</svg>''';

  @override
  Widget build(BuildContext context) => SvgPicture.string(_svg, width: size, height: size);
}

/// Bouton rond blanc (retour, zoom, localisation).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, required this.onPressed, required this.tooltip, this.size = 40, this.iconColor = AppColors.textPrimary, this.background = AppColors.surface, this.shadow = true});

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final Color iconColor;
  final Color background;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: shadow ? AppShadows.soft : null),
        child: Material(
          color: background,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(width: size, height: size, child: Icon(icon, size: size * 0.48, color: iconColor)),
          ),
        ),
      ),
    );
  }
}
