import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/alert_repositories.dart';
import '../data/awareness_repositories.dart';
import '../domain/alert_repository.dart';
import '../domain/awareness_article.dart';
import '../domain/flood_alert.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  final c = ref.watch(appConfigProvider);
  if (c.useMocks) return MockAlertRepository();
  return ApiAlertRepository(ref.watch(apiClientProvider), pollInterval: c.refreshInterval);
});

final awarenessRepositoryProvider = Provider<AwarenessRepository>((ref) {
  if (ref.watch(appConfigProvider).useMocks) return MockAwarenessRepository();
  return ApiAwarenessRepository(ref.watch(apiClientProvider));
});

final alertsProvider = FutureProvider<List<FloodAlert>>((ref) => ref.watch(alertRepositoryProvider).fetchAlerts());

final alertByIdProvider = FutureProvider.autoDispose.family<FloodAlert, String>((ref, id) async {
  // Evite un aller-retour reseau si l'alerte est deja dans l'historique.
  final cached = ref.read(alertsProvider).value?.where((a) => a.id == id).firstOrNull;
  return cached ?? ref.watch(alertRepositoryProvider).getAlert(id);
});

final articlesProvider = FutureProvider<List<AwarenessArticle>>((ref) => ref.watch(awarenessRepositoryProvider).fetchArticles());

/// Alertes en cours, toutes communes confondues.
final activeAlertsProvider = Provider<List<FloodAlert>>(
  (ref) => (ref.watch(alertsProvider).value ?? const []).where((a) => a.active).toList(),
);

/// Alerte en cours la plus grave dans la commune suivie.
final myZoneActiveAlertProvider = Provider<FloodAlert?>((ref) {
  final commune = ref.watch(userCommuneProvider);
  final mine = ref.watch(activeAlertsProvider).where((a) => a.commune == commune).toList()
    ..sort((a, b) => b.severity.index.compareTo(a.severity.index));
  return mine.firstOrNull;
});
