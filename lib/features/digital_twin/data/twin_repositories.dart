import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/network/api_client.dart';
import '../domain/models.dart';
import '../domain/twin_repository.dart';

/// Sites 3D embarques (assets/data/twin_sites_abidjan.json) : fonctionne hors ligne.
class AssetTwinRepository implements TwinRepository {
  const AssetTwinRepository({this.assetPath = 'assets/data/twin_sites_abidjan.json'});

  final String assetPath;

  @override
  Future<List<FloodDataset>> loadSites() async {
    final raw = jsonDecode(await rootBundle.loadString(assetPath)) as Map<String, dynamic>;
    return [for (final s in raw['sites'] as List) FloodDataset.fromJson(s as Map<String, dynamic>)];
  }
}

/// GET /twin/sites -> [FloodDataset] (meme format JSON que le dashboard web).
/// Si l'API est injoignable, on retombe sur les sites embarques pour garder la vue 3D utilisable.
class ApiTwinRepository implements TwinRepository {
  ApiTwinRepository(this._api, {this.fallback = const AssetTwinRepository()});

  final ApiClient _api;
  final TwinRepository fallback;

  @override
  Future<List<FloodDataset>> loadSites() async {
    try {
      final data = await _api.get<List<dynamic>>('/twin/sites');
      return [for (final s in data) FloodDataset.fromJson(s as Map<String, dynamic>)];
    } catch (_) {
      return fallback.loadSites();
    }
  }
}
