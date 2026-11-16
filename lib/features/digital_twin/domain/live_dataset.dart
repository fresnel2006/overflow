import 'dart:math' as math;

import '../../water_levels/domain/station.dart';
import 'models.dart';

const liveScenarioId = 'live';

/// Construit un jeu de donnees "temps reel" pour la scene 3D a partir des mesures du capteur :
/// - le scenario "Mesure capteur" suit l'eau au-dessus de la chaussee releve par la station ;
/// - la frise reprend l'historique du capteur (un pas toutes les [step]) ;
/// - les scenarios simules (crue 30 ans, 100 ans...) restent visibles comme reperes fixes.
FloodDataset buildLiveDataset({
  required FloodDataset base,
  required Station station,
  required List<WaterReading> history,
  required String liveLabel,
  Duration step = const Duration(hours: 2),
}) {
  double above(double levelCm) => double.parse(((levelCm - station.streetLevelCm) / 100).clamp(0, 10).toStringAsFixed(3));

  final sampled = <WaterReading>[];
  for (final r in history) {
    if (sampled.isEmpty || r.time.difference(sampled.last.time) >= step) sampled.add(r);
  }
  // Le dernier pas est toujours la mesure la plus recente de la station.
  final now = WaterReading(time: station.updatedAt, levelCm: station.levelCm);
  if (sampled.isNotEmpty && now.time.difference(sampled.last.time) < step ~/ 2) sampled.removeLast();
  sampled.add(now);

  final live = Scenario(
    id: liveScenarioId,
    label: liveLabel,
    color: '#0B5ED7',
    waterLevelM: sampled.map((r) => above(r.levelCm)).fold(0.0, math.max),
    description: '${station.name} - ${station.place}',
  );

  return FloodDataset(
    // Meme identifiant que le site : le selecteur de site de la vue 3D s'appuie dessus.
    id: base.id,
    site: base.site,
    buildings: base.buildings,
    scenarios: [live, ...base.scenarios],
    timeline: [
      for (final r in sampled)
        TimelineStep(
          t: r.time.toUtc().toIso8601String(),
          levelsByScenario: {liveScenarioId: above(r.levelCm), for (final s in base.scenarios) s.id: s.waterLevelM},
        ),
    ],
  );
}
