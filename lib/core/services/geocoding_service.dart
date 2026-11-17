import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../domain/commune.dart';

/// Une adresse trouvee par Mapbox.
class Place {
  const Place({required this.name, required this.address, required this.lat, required this.lon, this.commune});

  /// Libelle court (rue, lieu ou quartier).
  final String name;

  /// Adresse complete lisible (rue, quartier, commune).
  final String address;
  final double lat;
  final double lon;

  /// Commune d'Abidjan reconnue dans l'adresse, si elle en fait partie.
  final Commune? commune;
}

/// Adresses Mapbox (API Search v6) : adresse exacte d'une position GPS et recherche de lieux a Abidjan.
/// Sans jeton Mapbox, ou hors connexion, les methodes renvoient null / une liste vide.
class GeocodingService {
  GeocodingService(this._token) : _dio = Dio(BaseOptions(baseUrl: 'https://api.mapbox.com/search/geocode/v6', connectTimeout: _timeout, receiveTimeout: _timeout));

  static const _timeout = Duration(seconds: 8);
  // Grand Abidjan (ouest, sud, est, nord) : les recherches restent dans la ville.
  static const _bbox = '-4.40,5.15,-3.80,5.62';
  static const _abidjanCenter = '-4.005,5.335';

  final String _token;
  final Dio _dio;

  bool get enabled => _token.isNotEmpty;

  /// Adresse exacte de la position (null si introuvable).
  Future<Place?> reverse(double lat, double lon) async {
    if (!enabled) return null;
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '/reverse',
        queryParameters: {'longitude': lon, 'latitude': lat, 'language': 'fr', 'limit': 1, 'access_token': _token},
      );
      final features = (r.data?['features'] as List?) ?? const [];
      return features.isEmpty ? null : _place(features.first as Map<String, dynamic>, lat, lon);
    } on DioException {
      return null;
    }
  }

  /// Lieux et adresses d'Abidjan correspondant a [query].
  Future<List<Place>> search(String query) async {
    if (!enabled || query.trim().length < 3) return const [];
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '/forward',
        queryParameters: {
          'q': query.trim(),
          'country': 'ci',
          'bbox': _bbox,
          'proximity': _abidjanCenter,
          'language': 'fr',
          'limit': 5,
          'access_token': _token,
        },
      );
      final features = (r.data?['features'] as List?) ?? const [];
      return [for (final f in features) ?_place(f as Map<String, dynamic>, null, null)];
    } on DioException {
      return const [];
    }
  }

  Place? _place(Map<String, dynamic> f, double? lat, double? lon) {
    final p = (f['properties'] as Map?)?.cast<String, dynamic>() ?? const {};
    final coords = (p['coordinates'] as Map?)?.cast<String, dynamic>();
    final la = lat ?? (coords?['latitude'] as num?)?.toDouble();
    final lo = lon ?? (coords?['longitude'] as num?)?.toDouble();
    if (la == null || lo == null) return null;

    final ctx = (p['context'] as Map?)?.cast<String, dynamic>() ?? const {};
    String? ctxName(String k) => ((ctx[k] as Map?)?['name'] as String?)?.trim();
    final street = ctxName('street') ?? ctxName('address');
    final neighborhood = ctxName('neighborhood');
    final locality = ctxName('locality');
    final place = ctxName('place');

    // La commune est souvent la "locality" (Cocody, Yopougon...), parfois le quartier ou la ville.
    final commune = [locality, place, neighborhood].map(communeByName).nonNulls.firstOrNull ??
        (place?.toLowerCase().contains('abidjan') ?? false ? nearestCommune(la, lo) : null);

    final name = (p['name'] as String?)?.trim();
    final parts = <String>[
      ?(street ?? name),
      ?neighborhood,
      ?(commune?.name ?? locality),
    ];
    final address = parts.toSet().where((s) => s.isNotEmpty).join(', ');
    final full = (p['full_address'] as String?)?.trim();
    return Place(
      name: name ?? street ?? neighborhood ?? commune?.name ?? '',
      address: address.isNotEmpty ? address : (full ?? (p['place_formatted'] as String?) ?? ''),
      lat: la,
      lon: lo,
      commune: commune,
    );
  }
}

final geocodingServiceProvider = Provider<GeocodingService>((ref) => GeocodingService(ref.watch(appConfigProvider).mapboxToken));
