import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/domain/commune.dart';
import '../../../core/network/api_client.dart';
import '../data/zone_repositories.dart';
import '../domain/risk_zone.dart';
import '../domain/zone_repository.dart';

final zoneRepositoryProvider = Provider<ZoneRepository>((ref) {
  if (ref.watch(appConfigProvider).useMocks) return MockZoneRepository();
  return ApiZoneRepository(ref.watch(apiClientProvider));
});

final zonesProvider = FutureProvider<List<RiskZone>>((ref) => ref.watch(zoneRepositoryProvider).fetchZones());

/// Liste des communes ; repli sur la liste embarquee si l'API est injoignable.
final communesProvider = FutureProvider<List<Commune>>((ref) async {
  try {
    final list = await ref.watch(zoneRepositoryProvider).fetchCommunes();
    return list.isEmpty ? abidjanCommunes : list;
  } catch (_) {
    return abidjanCommunes;
  }
});
