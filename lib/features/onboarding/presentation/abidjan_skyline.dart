import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Vue d'Abidjan : photo si assets/images/splash_abidjan.jpg existe, sinon illustration
/// (tours du Plateau, lagune Ebrie, pont et vegetation) dessinee en vectoriel.
class AbidjanSkyline extends StatelessWidget {
  const AbidjanSkyline({super.key});

  @override
  Widget build(BuildContext context) => ShaderMask(
    // Fondu vers le ciel bleu en haut de l'image.
    shaderCallback: (r) => const LinearGradient(begin: Alignment.topCenter, end: Alignment.center, colors: [Colors.transparent, Colors.white]).createShader(r),
    blendMode: BlendMode.dstIn,
    child: Image.asset(
      'assets/images/splash_abidjan.jpg',
      fit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
      errorBuilder: (_, _, _) => const CustomPaint(painter: _SkylinePainter(), size: Size.infinite),
    ),
  );
}

class _SkylinePainter extends CustomPainter {
  const _SkylinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizon = h * 0.52;

    // Tours du Plateau en arriere-plan.
    final far = Paint()..color = const Color(0xFF8DB9DE);
    final near = Paint()..color = const Color(0xFF6F9FCB);
    final rng = math.Random(4);
    var x = w * 0.18;
    while (x < w * 0.86) {
      final bw = 12 + rng.nextDouble() * 20;
      final bh = 30 + rng.nextDouble() * (h * 0.32);
      canvas.drawRect(Rect.fromLTWH(x, horizon - bh, bw, bh), rng.nextBool() ? far : near);
      x += bw + 2 + rng.nextDouble() * 6;
    }
    // Tour emblematique (pyramide).
    final pyramid = Path()
      ..moveTo(w * 0.47, horizon)
      ..lineTo(w * 0.5, horizon - h * 0.42)
      ..lineTo(w * 0.53, horizon)
      ..close();
    canvas.drawPath(pyramid, Paint()..color = const Color(0xFF5E8FBF));

    // Lagune.
    final water = Rect.fromLTWH(0, horizon, w, h - horizon);
    canvas.drawRect(water, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF4F95CF), Color(0xFF2D6FA8)]).createShader(water));
    final shine = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1.5;
    for (var i = 0; i < 14; i++) {
      final y = horizon + 8 + i * (h - horizon) / 16;
      final sx = rng.nextDouble() * w;
      canvas.drawLine(Offset(sx, y), Offset(sx + 20 + rng.nextDouble() * 40, y), shine);
    }

    // Pont sur la lagune.
    final bridge = Paint()
      ..color = const Color(0xFFE8EEF5)
      ..strokeWidth = 3;
    final by = horizon + (h - horizon) * 0.22;
    canvas.drawLine(Offset(0, by), Offset(w * 0.62, by - 6), bridge);
    for (var i = 0; i < 9; i++) {
      final px = i * w * 0.07;
      canvas.drawLine(Offset(px, by - i * 0.66), Offset(px, by + 8), bridge..strokeWidth = 1.5);
    }

    // Vegetation au premier plan.
    final green = [const Color(0xFF2F7D3A), const Color(0xFF3E9447), const Color(0xFF256A30)];
    for (var i = 0; i < 26; i++) {
      final cx = rng.nextDouble() * w;
      final cy = h - rng.nextDouble() * h * 0.22;
      canvas.drawCircle(Offset(cx, cy), 16 + rng.nextDouble() * 26, Paint()..color = green[i % 3]);
    }
    // Toits clairs entre les arbres.
    for (var i = 0; i < 8; i++) {
      final rx = rng.nextDouble() * w;
      final ry = h - h * 0.12 - rng.nextDouble() * h * 0.1;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rx, ry, 22, 12), const Radius.circular(2)), Paint()..color = const Color(0xFFF1E6D6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
