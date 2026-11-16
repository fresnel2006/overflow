import '../../../core/domain/severity.dart';
import '../../../core/utils/formatters.dart';

/// Station de mesure : capteur a ultrasons dans un boitier fixe sur un lampadaire.
class Station {
  const Station({
    required this.id,
    required this.name,
    required this.commune,
    required this.place,
    required this.lat,
    required this.lon,
    required this.levelCm,
    required this.vigilanceCm,
    required this.dangerCm,
    required this.trend,
    required this.updatedAt,
    this.online = true,
    this.batteryPct,
    this.twinSiteId,
    this.streetLevelCm = 100,
  });

  final String id;
  final String name;
  final String commune;

  /// Lieu precis (canal, carrefour, bas-fond).
  final String place;
  final double lat;
  final double lon;

  /// Hauteur d'eau mesuree, en cm depuis le fond du caniveau.
  final double levelCm;
  final double vigilanceCm;
  final double dangerCm;
  final Trend trend;
  final DateTime updatedAt;
  final bool online;
  final int? batteryPct;

  /// Site du jumeau numerique 3D associe (null si le site n'est pas modelise).
  final String? twinSiteId;

  /// Hauteur a partir de laquelle l'eau deborde sur la chaussee (profondeur du caniveau).
  final double streetLevelCm;

  Severity get severity {
    if (levelCm >= dangerCm) return Severity.danger;
    if (levelCm >= vigilanceCm) return Severity.vigilance;
    return Severity.normal;
  }

  /// Eau au-dessus de la chaussee, en metres (utilise par le jumeau numerique).
  double get waterAboveStreetM => ((levelCm - streetLevelCm) / 100).clamp(0, 10).toDouble();

  /// Remplissage relatif par rapport au seuil de danger (0 a 1).
  double get fillRatio => (levelCm / (dangerCm * 1.25)).clamp(0, 1).toDouble();

  Station copyWith({double? levelCm, Trend? trend, DateTime? updatedAt, bool? online}) => Station(
    id: id,
    name: name,
    commune: commune,
    place: place,
    lat: lat,
    lon: lon,
    levelCm: levelCm ?? this.levelCm,
    vigilanceCm: vigilanceCm,
    dangerCm: dangerCm,
    trend: trend ?? this.trend,
    updatedAt: updatedAt ?? this.updatedAt,
    online: online ?? this.online,
    batteryPct: batteryPct,
    twinSiteId: twinSiteId,
    streetLevelCm: streetLevelCm,
  );

  factory Station.fromJson(Map<String, dynamic> j) => Station(
    id: j['id'].toString(),
    name: j['name'] as String,
    commune: j['commune'] as String,
    place: (j['place'] as String?) ?? '',
    lat: (j['lat'] as num).toDouble(),
    lon: (j['lon'] as num).toDouble(),
    levelCm: (j['level_cm'] as num).toDouble(),
    vigilanceCm: (j['vigilance_cm'] as num?)?.toDouble() ?? 100,
    dangerCm: (j['danger_cm'] as num?)?.toDouble() ?? 150,
    trend: Trend.fromName(j['trend'] as String?),
    updatedAt: parseDate(j['updated_at']),
    online: (j['online'] as bool?) ?? true,
    batteryPct: (j['battery_pct'] as num?)?.toInt(),
    twinSiteId: j['twin_site_id'] as String?,
    streetLevelCm: (j['street_level_cm'] as num?)?.toDouble() ?? 100,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'commune': commune,
    'place': place,
    'lat': lat,
    'lon': lon,
    'level_cm': levelCm,
    'vigilance_cm': vigilanceCm,
    'danger_cm': dangerCm,
    'trend': trend.name,
    'updated_at': updatedAt.toIso8601String(),
    'online': online,
    'battery_pct': batteryPct,
    'twin_site_id': twinSiteId,
    'street_level_cm': streetLevelCm,
  };
}

class WaterReading {
  const WaterReading({required this.time, required this.levelCm});

  final DateTime time;
  final double levelCm;

  factory WaterReading.fromJson(Map<String, dynamic> j) =>
      WaterReading(time: parseDate(j['time'] ?? j['t']), levelCm: (j['level_cm'] as num).toDouble());
}
