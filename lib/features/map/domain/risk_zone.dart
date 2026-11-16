import '../../../core/domain/commune.dart';
import '../../../core/domain/severity.dart';
import '../../../core/utils/formatters.dart';

/// Zone a risque d'inondation, classee par les autorites (cartographie des bas-fonds, historique).
class RiskZone {
  const RiskZone({
    required this.id,
    required this.name,
    required this.commune,
    required this.lat,
    required this.lon,
    required this.radiusM,
    required this.risk,
    required this.description,
    this.stationIds = const [],
    this.lastFloodAt,
    this.twinSiteId,
  });

  final String id;
  final String name;
  final String commune;
  final double lat;
  final double lon;
  final double radiusM;
  final RiskLevel risk;
  final String description;
  final List<String> stationIds;
  final DateTime? lastFloodAt;
  final String? twinSiteId;

  bool contains(double lat, double lon) => distanceMeters(this.lat, this.lon, lat, lon) <= radiusM;

  factory RiskZone.fromJson(Map<String, dynamic> j) => RiskZone(
    id: j['id'].toString(),
    name: j['name'] as String,
    commune: j['commune'] as String,
    lat: (j['lat'] as num).toDouble(),
    lon: (j['lon'] as num).toDouble(),
    radiusM: (j['radius_m'] as num).toDouble(),
    risk: RiskLevel.fromName(j['risk'] as String?),
    description: (j['description'] as String?) ?? '',
    stationIds: ((j['station_ids'] as List?) ?? const []).map((e) => e.toString()).toList(),
    lastFloodAt: j['last_flood_at'] == null ? null : parseDate(j['last_flood_at']),
    twinSiteId: j['twin_site_id'] as String?,
  );
}
