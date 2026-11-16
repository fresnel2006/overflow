import 'dart:math' as math;

/// Commune (ou ville) suivie par Overflow.
class Commune {
  const Commune({required this.id, required this.name, required this.city, required this.lat, required this.lon});

  final String id;
  final String name;
  final String city;
  final double lat;
  final double lon;

  String get label => '$name, $city';

  factory Commune.fromJson(Map<String, dynamic> j) => Commune(
    id: j['id'] as String,
    name: j['name'] as String,
    city: (j['city'] as String?) ?? 'Abidjan',
    lat: (j['lat'] as num).toDouble(),
    lon: (j['lon'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'city': city, 'lat': lat, 'lon': lon};

  @override
  bool operator ==(Object other) => other is Commune && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Communes du district d'Abidjan (centres approximatifs). Sert de repli hors ligne
/// et pour deduire la commune d'une position GPS sans service de geocodage.
const abidjanCommunes = [
  Commune(id: 'abobo', name: 'Abobo', city: 'Abidjan', lat: 5.4180, lon: -4.0200),
  Commune(id: 'adjame', name: 'Adjamé', city: 'Abidjan', lat: 5.3600, lon: -4.0230),
  Commune(id: 'anyama', name: 'Anyama', city: 'Abidjan', lat: 5.4950, lon: -4.0520),
  Commune(id: 'attecoube', name: 'Attécoubé', city: 'Abidjan', lat: 5.3350, lon: -4.0420),
  Commune(id: 'bingerville', name: 'Bingerville', city: 'Abidjan', lat: 5.3550, lon: -3.8850),
  Commune(id: 'cocody', name: 'Cocody', city: 'Abidjan', lat: 5.3600, lon: -3.9700),
  Commune(id: 'koumassi', name: 'Koumassi', city: 'Abidjan', lat: 5.2950, lon: -3.9500),
  Commune(id: 'marcory', name: 'Marcory', city: 'Abidjan', lat: 5.3020, lon: -3.9800),
  Commune(id: 'plateau', name: 'Plateau', city: 'Abidjan', lat: 5.3240, lon: -4.0180),
  Commune(id: 'port-bouet', name: 'Port-Bouët', city: 'Abidjan', lat: 5.2560, lon: -3.9260),
  Commune(id: 'songon', name: 'Songon', city: 'Abidjan', lat: 5.3150, lon: -4.2650),
  Commune(id: 'treichville', name: 'Treichville', city: 'Abidjan', lat: 5.2930, lon: -4.0030),
  Commune(id: 'yopougon', name: 'Yopougon', city: 'Abidjan', lat: 5.3450, lon: -4.0850),
];

Commune? communeByName(String? name, [List<Commune> list = abidjanCommunes]) {
  if (name == null) return null;
  final n = _fold(name);
  return list.where((c) => _fold(c.name) == n || c.id == n).firstOrNull;
}

/// Commune la plus proche d'une position.
Commune nearestCommune(double lat, double lon, [List<Commune> list = abidjanCommunes]) {
  return list.reduce((a, b) => distanceMeters(lat, lon, a.lat, a.lon) <= distanceMeters(lat, lon, b.lat, b.lon) ? a : b);
}

/// Distance haversine en metres.
double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = math.pow(math.sin(dLat / 2), 2) + math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.sqrt(a));
}

double _rad(double d) => d * math.pi / 180;

String _fold(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[éèêë]'), 'e')
    .replaceAll(RegExp('[àâ]'), 'a')
    .replaceAll(RegExp('[ôö]'), 'o')
    .replaceAll(RegExp('[îï]'), 'i')
    .replaceAll(RegExp('[ûü]'), 'u')
    .replaceAll(' ', '-')
    .trim();

/// Recherche insensible aux accents et a la casse.
bool matchesQuery(String text, String query) => _fold(text).contains(_fold(query));
