import 'station.dart';

/// Acces aux stations de mesure et a leurs releves.
abstract interface class StationRepository {
  /// Flux temps reel : emet la liste complete a chaque nouvelle mesure.
  Stream<List<Station>> watchStations();

  Future<List<Station>> fetchStations();

  Future<Station> getStation(String id);

  /// Releves de la periode, du plus ancien au plus recent.
  Future<List<WaterReading>> fetchHistory(String stationId, {Duration period = const Duration(hours: 24)});
}
