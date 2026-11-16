import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../twin_palette.dart';
import '../../domain/models.dart';
import '../state/flood_viewer_state.dart';
import 'glass.dart';
import 'icons.dart';

/// Barre d'outils verticale: 2D/3D, reset vue, plein ecran, capture, theme, calques.
class FloodToolbar extends ConsumerWidget {
  const FloodToolbar({
    super.key,
    required this.onViewMode,
    required this.onReset,
    required this.onFullscreen,
    required this.fullscreen,
    required this.onScreenshot,
    required this.onToggleTheme,
    this.onToggleLayers,
    this.layersOpen = false,
  });

  final ValueChanged<ViewMode> onViewMode;
  final VoidCallback onReset;
  final VoidCallback onFullscreen;
  final bool fullscreen;
  final VoidCallback onScreenshot;
  final VoidCallback onToggleTheme;
  final VoidCallback? onToggleLayers;
  final bool layersOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(floodViewerProvider.select((s) => s.viewMode));
    final theme = ref.watch(floodViewerProvider.select((s) => s.theme));
    final fx = Fx.of(context);
    return Glass(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: fx.text.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                for (final m in [ViewMode.view3d, ViewMode.view2d])
                  GestureDetector(
                    onTap: () => onViewMode(m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: 36,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: mode == m ? (fx.dark ? TwinColors.sky : Colors.white) : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: mode == m ? [BoxShadow(color: TwinColors.navy.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 1))] : null,
                      ),
                      child: Text(
                        m == ViewMode.view3d ? '3D' : '2D',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: mode == m ? (fx.dark ? TwinColors.navy : TwinColors.ocean) : fx.muted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          GlassIconButton(tooltip: 'Réinitialiser la vue', onTap: onReset, child: SvgIcon(AppIcon.rotateCcw, color: fx.text)),
          GlassIconButton(
            tooltip: fullscreen ? 'Quitter le plein écran' : 'Plein écran',
            onTap: onFullscreen,
            child: SvgIcon(fullscreen ? AppIcon.minimize : AppIcon.maximize, color: fx.text),
          ),
          GlassIconButton(tooltip: 'Capture d’écran', onTap: onScreenshot, child: SvgIcon(AppIcon.camera, color: fx.text)),
          GlassIconButton(
            tooltip: theme == FloodTheme.dark ? 'Mode clair' : 'Mode sombre',
            onTap: onToggleTheme,
            child: SvgIcon(theme == FloodTheme.dark ? AppIcon.sun : AppIcon.moon, color: fx.text),
          ),
          if (onToggleLayers != null)
            GlassIconButton(
              tooltip: 'Calques',
              active: layersOpen,
              onTap: onToggleLayers!,
              child: SvgIcon(AppIcon.layers, color: layersOpen ? fx.onAccent : fx.text),
            ),
        ],
      ),
    );
  }
}

/// Boussole qui tourne avec la camera (cap recu du web). Un toucher oriente la vue au nord.
class Compass extends ConsumerWidget {
  const Compass({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heading = ref.watch(floodViewerProvider.select((s) => s.heading));
    final fx = Fx.of(context);
    return Tooltip(
      message: 'Orienter vers le nord',
      child: GestureDetector(
        onTap: onTap,
        child: Glass(
          radius: 28,
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Transform.rotate(
              angle: heading * math.pi / 180,
              child: CustomPaint(painter: _CompassPainter(text: fx.text, accent: fx.accent)),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.text, required this.accent});
  final Color text;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = text.withValues(alpha: 0.15),
    );
    final tick = Paint()
      ..color = text.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final len = i % 3 == 0 ? 3.0 : 1.8;
      final d = Offset(math.sin(a), -math.cos(a));
      canvas.drawLine(c + d * (r - 1), c + d * (r - 1 - len), tick);
    }
    final north = Path()
      ..moveTo(c.dx, c.dy - r + 7)
      ..lineTo(c.dx + 4, c.dy)
      ..lineTo(c.dx - 4, c.dy)
      ..close();
    final south = Path()
      ..moveTo(c.dx, c.dy + r - 7)
      ..lineTo(c.dx + 4, c.dy)
      ..lineTo(c.dx - 4, c.dy)
      ..close();
    canvas.drawPath(north, Paint()..color = accent);
    canvas.drawPath(south, Paint()..color = text.withValues(alpha: 0.22));
    canvas.drawCircle(c, 2, Paint()..color = Colors.white);
    final tp = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: text),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - r - tp.height / 2 + 1));
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.text != text || old.accent != accent;
}
