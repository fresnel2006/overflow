import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/network/api_client.dart';
import '../domain/station.dart';
import '../domain/station_repository.dart';

/// Stations via FastAPI.
///   GET /stations                         -> [Station]
///   GET /stations/{id}                    -> Station
///   GET /stations/{id}/readings?hours=24  -> [{time, level_cm}]
/// Le temps reel est obtenu par interrogation periodique (polling).
class ApiStationRepository implements StationRepository {
  ApiStationRepository(this._api, {this.refreshInterval = const Duration(seconds: 30)});

  final ApiClient _api;
  final Duration refreshInterval;

  @override
  Stream<List<Station>> watchStations() {
    late final StreamController<List<Station>> controller;
    Timer? timer;

    Future<void> poll() async {
      try {
        final list = await fetchStations();
        if (!controller.isClosed) controller.add(list);
      } catch (e, st) {
        // L'erreur est signalee mais le flux continue : la prochaine interrogation peut reussir.
        if (!controller.isClosed) controller.addError(e, st);
      }
    }

    controller = StreamController<List<Station>>(
      onListen: () {
        poll();
        timer = Timer.periodic(refreshInterval, (_) => poll());
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<List<Station>> fetchStations() async {
    final data = await _api.get<List<dynamic>>('/stations');
    return [for (final j in data) Station.fromJson(j as Map<String, dynamic>)];
  }

  @override
  Future<Station> getStation(String id) async => Station.fromJson(await _api.get<Map<String, dynamic>>('/stations/$id'));

  @override
  Future<List<WaterReading>> fetchHistory(String stationId, {Duration period = const Duration(hours: 24)}) async {
    final data = await _api.get<List<dynamic>>('/stations/$stationId/readings', query: {'hours': period.inHours});
    return [for (final j in data) WaterReading.fromJson(j as Map<String, dynamic>)]..sort((a, b) => a.time.compareTo(b.time));
  }
}

/// Variante temps reel : le backend ecrit la derniere mesure de chaque capteur dans la
/// collection Firestore "stations" (un document par station, memes champs que l'API).
/// L'historique reste servi par FastAPI.
class FirestoreStationRepository extends ApiStationRepository {
  FirestoreStationRepository(super.api, {super.refreshInterval, FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<List<Station>> watchStations() => _db.collection('stations').snapshots().map(
    (snap) => [for (final d in snap.docs) Station.fromJson(_normalize({'id': d.id, ...d.data()}))],
  );

  static Map<String, dynamic> _normalize(Map<String, dynamic> j) => {
    for (final e in j.entries) e.key: e.value is Timestamp ? (e.value as Timestamp).toDate().toIso8601String() : e.value,
  };
}
