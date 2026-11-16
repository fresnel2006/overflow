import 'awareness_article.dart';
import 'flood_alert.dart';

abstract interface class AlertRepository {
  /// Historique, de la plus recente a la plus ancienne.
  Future<List<FloodAlert>> fetchAlerts();

  Future<FloodAlert> getAlert(String id);

  /// Alertes recues en direct pendant que l'application est ouverte.
  Stream<FloodAlert> watchIncoming();

  /// Demande au backend l'envoi d'une alerte de test (SMS, push) pour la commune.
  Future<void> requestTestAlert(String commune);
}

abstract interface class AwarenessRepository {
  Future<List<AwarenessArticle>> fetchArticles();
}
