import 'models.dart';

/// Geometrie des sites et scenarios de crue simules (produits par le backend / jumeau web).
abstract interface class TwinRepository {
  Future<List<FloodDataset>> loadSites();
}
