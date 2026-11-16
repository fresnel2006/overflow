import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/domain/severity.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/api_station_repository.dart';
import '../data/mock_station_repository.dart';
import '../domain/station.dart';
import '../domain/station_repository.dart';

final stationRepositoryProvider = Provider<StationRepository>((ref) {
  final c = ref.watch(appConfigProvider);
  if (c.useMocks) return MockStationRepository(refreshInterval: c.refreshInterval);
  final api = ref.watch(apiClientProvider);
  if (c.firebaseEnabled && c.realtimeSource == RealtimeSource.firestore) {
    return FirestoreStationRepository(api, refreshInterval: c.refreshInterval);
  }
  return ApiStationRepository(api, refreshInterval: c.refreshInterval);
});

/// Toutes les stations, mises a jour en continu (rafraichissement automatique).
final stationsProvider = StreamProvider<List<Station>>((ref) => ref.watch(stationRepositoryProvider).watchStations());

/// Une station, derivee du flux temps reel.
final stationByIdProvider = Provider.family<AsyncValue<Station?>, String>(
  (ref, id) => ref.watch(stationsProvider).whenData((list) => list.where((s) => s.id == id).firstOrNull),
);

final stationHistoryProvider = FutureProvider.autoDispose.family<List<WaterReading>, String>(
  (ref, id) => ref.watch(stationRepositoryProvider).fetchHistory(id),
);

/// Stations de la commune suivie.
final myZoneStationsProvider = Provider<AsyncValue<List<Station>>>((ref) {
  final commune = ref.watch(userCommuneProvider);
  return ref.watch(stationsProvider).whenData((l) => l.where((s) => s.commune == commune).toList());
});

/// Pire niveau de gravite mesure dans la commune suivie.
final myZoneSeverityProvider = Provider<Severity?>((ref) {
  final list = ref.watch(myZoneStationsProvider).value;
  if (list == null || list.isEmpty) return list == null ? null : Severity.normal;
  return list.map((s) => s.severity).reduce((a, b) => a > b ? a : b);
});
