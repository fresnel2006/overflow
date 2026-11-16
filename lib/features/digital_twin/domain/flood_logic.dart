import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'models.dart';

/// Portage Dart de core/timeline.ts, core/risk.ts et core/format.ts (memes resultats que le web).

int maxTimeIndex(List<TimelineStep>? timeline) => math.max(0, (timeline?.length ?? 1) - 1);

/// Hauteurs par scenario a un index fractionnaire de la frise.
Map<String, double> levelsAt(List<Scenario> scenarios, List<TimelineStep>? timeline, double index) {
  if (timeline == null || timeline.isEmpty) return {for (final s in scenarios) s.id: s.waterLevelM};
  final i = index.clamp(0, timeline.length - 1).toDouble();
  final a = timeline[i.floor()];
  final b = timeline[i.ceil()];
  final k = i - i.floor();
  return {
    for (final s in scenarios)
      s.id: () {
        final la = a.levelsByScenario[s.id] ?? 0;
        final lb = b.levelsByScenario[s.id] ?? la;
        return la + (lb - la) * k;
      }(),
  };
}

DateTime? timeAt(List<TimelineStep>? timeline, double index) {
  if (timeline == null || timeline.isEmpty) return null;
  final i = index.clamp(0, timeline.length - 1).toDouble();
  final a = timeline[i.floor()].time.millisecondsSinceEpoch;
  final b = timeline[i.ceil()].time.millisecondsSinceEpoch;
  return DateTime.fromMillisecondsSinceEpoch((a + (b - a) * (i - i.floor())).round(), isUtc: true);
}

int peakIndex(List<TimelineStep>? timeline, [String? scenarioId]) {
  if (timeline == null || timeline.isEmpty) return 0;
  var best = 0;
  var bestV = double.negativeInfinity;
  for (var i = 0; i < timeline.length; i++) {
    final l = timeline[i].levelsByScenario;
    final v = scenarioId != null ? (l[scenarioId] ?? 0) : l.values.fold<double>(0, math.max);
    if (v > bestV + 1e-6) {
      bestV = v;
      best = i;
    }
  }
  return best;
}

String _two(int n) => n.toString().padLeft(2, '0');

/// "02 18:00" (jour heure:min, heure d'Abidjan = UTC).
String formatDayTime(DateTime t) => '${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';

/// 1.54 -> "1,54 m".
String formatMeters(double v) => '${math.max(0, v).toStringAsFixed(2).replaceAll('.', ',')} m';

String formatCoord(double v, String pos, String neg) => '${v.abs().toStringAsFixed(4).replaceAll('.', ',')}° ${v >= 0 ? pos : neg}';

enum RiskLevel { faible, modere, eleve, critique }

class RiskStep {
  const RiskStep(this.level, this.label, this.color, this.fromM);
  final RiskLevel level;
  final String label;
  final Color color;
  final double fromM;
}

const riskSteps = [
  RiskStep(RiskLevel.faible, 'Faible', Color(0xFF3E9C8A), double.negativeInfinity),
  RiskStep(RiskLevel.modere, 'Modéré', Color(0xFFD6B35C), 0),
  RiskStep(RiskLevel.eleve, 'Élevé', Color(0xFFD2504A), 0.5),
  RiskStep(RiskLevel.critique, 'Critique', Color(0xFFB3263A), 1.2),
];

class RiskInfo {
  const RiskInfo({required this.step, required this.aboveFloorM, required this.ratio, required this.message});
  final RiskStep step;
  final double aboveFloorM;
  final double ratio;
  final String message;
}

/// Seuils (m au-dessus du plancher): < 0 faible, 0 - 0,5 modere, 0,5 - 1,2 eleve, > 1,2 critique.
RiskInfo riskFor(double waterLevelM, double groundFloorOffsetM) {
  final above = waterLevelM - groundFloorOffsetM;
  var step = riskSteps.first;
  for (final s in riskSteps) {
    if (above >= s.fromM) step = s;
  }
  final message = waterLevelM <= 0.01
      ? 'Pas d’eau au pied du bâtiment'
      : above < 0
      ? 'Eau sous le niveau du plancher'
      : 'Eau dans le rez-de-chaussée';
  return RiskInfo(step: step, aboveFloorM: above, ratio: ((above + 0.5) / 2.5).clamp(0, 1).toDouble(), message: message);
}

Color parseHexColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
}
