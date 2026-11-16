import '../../../core/domain/commune.dart';
import 'risk_zone.dart';

abstract interface class ZoneRepository {
  Future<List<RiskZone>> fetchZones();

  /// Communes proposees au choix de la zone suivie.
  Future<List<Commune>> fetchCommunes();
}
