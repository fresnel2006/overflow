/// Format d'entree du viewer (identique au JSON du projet React).
/// Repere local en metres: x vers l'est, z vers le sud (nord = -z), y vers le haut;
/// y = 0 est le terrain naturel au pied du batiment principal.
library;

typedef Vec2 = (double x, double z);

enum FloodTheme { light, dark }

enum ViewMode { view2d, view3d }

class Scenario {
  const Scenario({required this.id, required this.label, required this.color, required this.waterLevelM, this.description});

  final String id;
  final String label;

  /// Couleur "#RRGGBB".
  final String color;

  /// Hauteur d'eau au pic (m au-dessus du terrain naturel).
  final double waterLevelM;
  final String? description;

  factory Scenario.fromJson(Map<String, dynamic> j) => Scenario(
    id: j['id'] as String,
    label: j['label'] as String,
    color: j['color'] as String,
    waterLevelM: (j['waterLevelM'] as num).toDouble(),
    description: j['description'] as String?,
  );

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'color': color, 'waterLevelM': waterLevelM, 'description': ?description};
}

enum RoofType { gable, flat }

class BuildingSpec {
  const BuildingSpec({
    required this.id,
    required this.footprint,
    required this.heightM,
    required this.roof,
    required this.groundFloorOffsetM,
    this.name,
    this.main = false,
    this.facadeEdge,
    this.rulerCorners,
  });

  final String id;
  final String? name;

  /// Emprise [x, z] en metres (4 points pour un toit a 2 pentes).
  final List<Vec2> footprint;

  /// Hauteur des murs jusqu'a l'egout du toit.
  final double heightM;
  final RoofType roof;

  /// Plancher du rez-de-chaussee au-dessus du terrain.
  final double groundFloorOffsetM;
  final bool main;
  final int? facadeEdge;
  final List<int>? rulerCorners;

  factory BuildingSpec.fromJson(Map<String, dynamic> j) => BuildingSpec(
    id: j['id'] as String,
    name: j['name'] as String?,
    footprint: [
      for (final p in (j['footprint'] as List).cast<List>()) ((p[0] as num).toDouble(), (p[1] as num).toDouble()),
    ],
    heightM: (j['heightM'] as num).toDouble(),
    roof: j['roof'] == 'flat' ? RoofType.flat : RoofType.gable,
    groundFloorOffsetM: (j['groundFloorOffsetM'] as num).toDouble(),
    main: j['main'] == true,
    facadeEdge: j['facadeEdge'] as int?,
    rulerCorners: (j['rulerCorners'] as List?)?.cast<int>(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': ?name,
    'footprint': [
      for (final p in footprint) [p.$1, p.$2],
    ],
    'heightM': heightM,
    'roof': roof.name,
    'groundFloorOffsetM': groundFloorOffsetM,
    'main': main,
    'facadeEdge': ?facadeEdge,
    'rulerCorners': ?rulerCorners,
  };
}

class TimelineStep {
  const TimelineStep({required this.t, required this.levelsByScenario});

  /// Instant ISO 8601 (sans fuseau = UTC, l'heure d'Abidjan).
  final String t;
  final Map<String, double> levelsByScenario;

  DateTime get time => DateTime.parse(RegExp(r'([zZ]|[+-]\d\d:?\d\d)$').hasMatch(t) ? t : '${t}Z').toUtc();

  factory TimelineStep.fromJson(Map<String, dynamic> j) => TimelineStep(
    t: j['t'] as String,
    levelsByScenario: (j['levelsByScenario'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble())),
  );

  Map<String, dynamic> toJson() => {'t': t, 'levelsByScenario': levelsByScenario};
}

class SiteInfo {
  const SiteInfo({required this.name, required this.commune, this.waterBody, this.lat, this.lon});

  final String name;
  final String commune;
  final String? waterBody;
  final double? lat;
  final double? lon;

  factory SiteInfo.fromJson(Map<String, dynamic> j) => SiteInfo(
    name: j['name'] as String,
    commune: j['commune'] as String,
    waterBody: j['waterBody'] as String?,
    lat: (j['lat'] as num?)?.toDouble(),
    lon: (j['lon'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {'name': name, 'commune': commune, 'waterBody': ?waterBody, 'lat': ?lat, 'lon': ?lon};
}

class FloodDataset {
  const FloodDataset({required this.id, required this.scenarios, required this.buildings, this.timeline, this.site});

  final String id;
  final List<Scenario> scenarios;
  final List<BuildingSpec> buildings;
  final List<TimelineStep>? timeline;
  final SiteInfo? site;

  BuildingSpec? get mainBuilding => buildings.where((b) => b.main).firstOrNull ?? buildings.firstOrNull;

  factory FloodDataset.fromJson(Map<String, dynamic> j) => FloodDataset(
    id: (j['id'] as String?) ?? 'site',
    site: j['site'] == null ? null : SiteInfo.fromJson(j['site'] as Map<String, dynamic>),
    scenarios: [for (final s in j['scenarios'] as List) Scenario.fromJson(s as Map<String, dynamic>)],
    buildings: [for (final b in j['buildings'] as List) BuildingSpec.fromJson(b as Map<String, dynamic>)],
    timeline: (j['timeline'] as List?)?.map((s) => TimelineStep.fromJson(s as Map<String, dynamic>)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'site': ?site?.toJson(),
    'scenarios': [for (final s in scenarios) s.toJson()],
    'buildings': [for (final b in buildings) b.toJson()],
    'timeline': ?timeline?.map((s) => s.toJson()).toList(),
  };
}

class LayerVisibility {
  const LayerVisibility({this.buildings = true, this.water = true, this.rulers = true, this.labels = true});

  final bool buildings;
  final bool water;
  final bool rulers;
  final bool labels;

  LayerVisibility copyWith({bool? buildings, bool? water, bool? rulers, bool? labels}) => LayerVisibility(
    buildings: buildings ?? this.buildings,
    water: water ?? this.water,
    rulers: rulers ?? this.rulers,
    labels: labels ?? this.labels,
  );

  Map<String, dynamic> toJson() => {'buildings': buildings, 'water': water, 'rulers': rulers, 'labels': labels};
}
