import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../twin_palette.dart';
import '../../domain/flood_logic.dart';
import '../../domain/models.dart';
import '../state/flood_viewer_state.dart';
import 'glass.dart';
import 'icons.dart';

/// Barre de lecture: precedent / lecture / suivant / MAX + frise avec curseur et hydrogramme.
class TimelineBar extends ConsumerStatefulWidget {
  const TimelineBar({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<TimelineBar> createState() => _TimelineBarState();
}

class _TimelineBarState extends ConsumerState<TimelineBar> {
  var _dragging = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(floodViewerProvider);
    final n = ref.read(floodViewerProvider.notifier);
    final timeline = s.timeline;
    if (timeline == null || timeline.length < 2) return const SizedBox.shrink();
    final fx = Fx.of(context);
    final now = s.time!;
    final atPeak = (s.timeIndex - peakIndex(timeline, s.activeScenarioId)).abs() < 1e-3;

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassIconButton(tooltip: 'Pas précédent', onTap: () => n.step(-1), child: SvgIcon(AppIcon.skipBack, color: fx.text)),
        _PlayButton(playing: s.playing, onTap: n.togglePlay),
        GlassIconButton(tooltip: 'Pas suivant', onTap: () => n.step(1), child: SvgIcon(AppIcon.skipForward, color: fx.text)),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatDayTime(now), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFeatures: tabular, height: 1)),
            const SizedBox(height: 4),
            Text('jour heure:min', style: TextStyle(fontSize: 10.5, color: fx.muted, height: 1)),
          ],
        ),
      ],
    );
    final maxButton = _MaxButton(active: atPeak, onTap: n.goToPeak);
    final track = _Track(
      state: s,
      dragging: _dragging,
      onDrag: (v, end) {
        if (!_dragging && !end) n.pause();
        setState(() => _dragging = !end);
        n.setTimeIndex(end ? v.roundToDouble() : v);
      },
    );

    return Glass(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: widget.compact
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [controls, const Spacer(), maxButton]),
                const SizedBox(height: 6),
                track,
              ],
            )
          : Row(
              children: [
                controls,
                const SizedBox(width: 14),
                Expanded(child: track),
                const SizedBox(width: 14),
                maxButton,
              ],
            ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.playing, required this.onTap});
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = Fx.of(context);
    return Tooltip(
      message: playing ? 'Pause' : 'Lecture',
      child: Semantics(
        button: true,
        label: playing ? 'Pause' : 'Lecture',
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: fx.accent,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: fx.accent.withValues(alpha: 0.55), blurRadius: 18, spreadRadius: -6, offset: const Offset(0, 6))],
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: playing
                  ? SvgIcon(AppIcon.pause, key: const ValueKey('pause'), color: fx.onAccent)
                  : Padding(
                      key: const ValueKey('play'),
                      padding: const EdgeInsets.only(left: 2),
                      child: SvgIcon(AppIcon.play, color: fx.onAccent),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MaxButton extends StatelessWidget {
  const _MaxButton({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = Fx.of(context);
    return Tooltip(
      message: 'Aller au pic de crue',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: active ? fx.text : fx.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
          child: Text(
            'MAX',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: active ? (fx.dark ? TwinColors.navy : Colors.white) : fx.accent),
          ),
        ),
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({required this.state, required this.dragging, required this.onDrag});

  final FloodViewerState state;
  final bool dragging;
  final void Function(double index, bool end) onDrag;

  @override
  Widget build(BuildContext context) {
    final fx = Fx.of(context);
    final timeline = state.timeline!;
    final max = state.maxIndex.toDouble();
    final pct = state.timeIndex / max;
    final active = state.activeScenario;
    final days = <(int, String)>[];
    var lastDay = -1;
    for (var i = 0; i < timeline.length; i++) {
      final d = timeline[i].time.day;
      if (d != lastDay) {
        days.add((i, d.toString().padLeft(2, '0')));
        lastDay = d;
      }
    }

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        double indexAt(double dx) => (dx / w).clamp(0.0, 1.0) * max;
        return Semantics(
          slider: true,
          label: 'Instant de la simulation',
          value: formatDayTime(state.time!),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => onDrag(indexAt(d.localPosition.dx), false),
            onTapUp: (_) => onDrag(state.timeIndex, true),
            onHorizontalDragStart: (d) => onDrag(indexAt(d.localPosition.dx), false),
            onHorizontalDragUpdate: (d) => onDrag(indexAt(d.localPosition.dx), false),
            onHorizontalDragEnd: (_) => onDrag(state.timeIndex, true),
            child: SizedBox(
              height: 52,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    bottom: 14,
                    child: CustomPaint(
                      painter: _TrackPainter(
                        timeline: timeline,
                        scenario: active,
                        pct: pct,
                        accent: fx.accent,
                        track: fx.track,
                        tick: fx.dark ? TwinColors.navy.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  for (final (i, label) in days)
                    Positioned(
                      left: (i / max) * w - 10,
                      bottom: 0,
                      width: 20,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: fx.muted, fontFeatures: tabular),
                      ),
                    ),
                  Positioned(
                    left: pct * w - 9,
                    bottom: 14 - 6,
                    child: AnimatedScale(
                      scale: dragging ? 1.25 : 1,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: fx.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: fx.dark ? TwinColors.navy : Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: TwinColors.navy.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                      ),
                    ),
                  ),
                  if (dragging || state.playing)
                    Positioned(
                      left: (pct * w - 34).clamp(-8.0, w - 60),
                      top: -26,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: fx.text, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          formatDayTime(state.time!),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFeatures: tabular, color: fx.dark ? TwinColors.navy : Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Hydrogramme du scenario actif + piste de progression + graduations par pas de temps.
class _TrackPainter extends CustomPainter {
  _TrackPainter({required this.timeline, required this.scenario, required this.pct, required this.accent, required this.track, required this.tick});

  final List<TimelineStep> timeline;
  final Scenario? scenario;
  final double pct;
  final Color accent;
  final Color track;
  final Color tick;

  @override
  void paint(Canvas canvas, Size size) {
    final n = timeline.length - 1;
    final barH = 6.0;
    final barTop = size.height - barH;
    if (scenario != null) {
      final top = timeline.expand((t) => t.levelsByScenario.values).fold<double>(0.01, math.max);
      final color = parseHexColor(scenario!.color);
      final path = Path();
      for (var i = 0; i <= n; i++) {
        final x = i / n * size.width;
        final y = barTop - 2 - ((timeline[i].levelsByScenario[scenario!.id] ?? 0) / top) * (barTop - 6);
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      final area = Path.from(path)
        ..lineTo(size.width, barTop)
        ..lineTo(0, barTop)
        ..close();
      canvas.drawPath(area, Paint()..color = color.withValues(alpha: 0.28));
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    final r = Radius.circular(barH / 2);
    canvas.drawRRect(RRect.fromLTRBR(0, barTop, size.width, size.height, r), Paint()..color = track);
    canvas.drawRRect(RRect.fromLTRBR(0, barTop, size.width * pct, size.height, r), Paint()..color = accent);
    final tp = Paint()..color = tick;
    for (var i = 1; i < n; i++) {
      final x = i / n * size.width;
      canvas.drawRect(Rect.fromLTWH(x - 0.5, barTop + 1.5, 1, 3), tp);
    }
  }

  @override
  bool shouldRepaint(_TrackPainter old) => old.pct != pct || old.scenario != scenario || old.timeline != timeline || old.accent != accent;
}
