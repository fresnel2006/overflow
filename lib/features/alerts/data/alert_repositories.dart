import 'dart:async';

import '../../../core/domain/severity.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/mock/mock_latency.dart';
import '../../../core/network/api_client.dart';
import '../domain/alert_repository.dart';
import '../domain/flood_alert.dart';

const defaultInstructions = [
  SafetyInstruction(InstructionIcon.avoid, 'Évitez de vous déplacer près des zones inondées'),
  SafetyInstruction(InstructionIcon.road, 'Ne traversez pas les routes inondées'),
  SafetyInstruction(InstructionIcon.shelter, 'Rejoignez un lieu sûr si nécessaire'),
];

const _vigilanceInstructions = [
  SafetyInstruction(InstructionIcon.water, 'Surveillez le niveau de l\'eau près de chez vous'),
  SafetyInstruction(InstructionIcon.power, 'Mettez vos appareils électriques en hauteur'),
  SafetyInstruction(InstructionIcon.phone, 'Gardez votre téléphone chargé et restez joignable'),
];

/// Historique fictif + simulation d'alertes en direct (bouton "Recevoir une alerte de test").
class MockAlertRepository implements AlertRepository {
  MockAlertRepository() {
    final now = DateTime.now();
    FloodAlert a(String id, AlertKind k, Severity s, String commune, String place, Duration ago, {double? level, Trend t = Trend.stable, bool active = false, String? station}) =>
        FloodAlert(
          id: id,
          kind: k,
          severity: s,
          commune: commune,
          place: place,
          createdAt: now.subtract(ago),
          levelCm: level,
          trend: t,
          active: active,
          stationId: station,
          instructions: switch (k) {
            AlertKind.flood => defaultInstructions,
            AlertKind.warning => _vigilanceInstructions,
            AlertKind.ended => const [],
          },
          message: switch (k) {
            AlertKind.flood => 'Le niveau d\'eau dépasse le seuil de danger. Des débordements sur la chaussée sont en cours.',
            AlertKind.warning => 'Le niveau d\'eau monte et approche du seuil de danger. Restez attentifs.',
            AlertKind.ended => 'Le niveau d\'eau est redescendu sous le seuil de vigilance. Restez prudents aux abords des caniveaux.',
          },
        );
    _alerts = [
      a('al-201', AlertKind.flood, Severity.danger, 'Koumassi', 'Remblais', const Duration(minutes: 25), level: 158, t: Trend.rising, active: true, station: 'koumassi'),
      a('al-198', AlertKind.ended, Severity.normal, 'Cocody', 'Bassin du Gourou', const Duration(days: 2, hours: 20), level: 92, t: Trend.falling, station: 'gourou'),
      a('al-197', AlertKind.flood, Severity.danger, 'Cocody', 'Bassin du Gourou', const Duration(days: 3, hours: 2), level: 182, t: Trend.rising, station: 'gourou'),
      a('al-190', AlertKind.warning, Severity.vigilance, 'Treichville', 'Quartier Arras', const Duration(days: 6, hours: 5), level: 118, t: Trend.rising, station: 'treichville'),
      a('al-184', AlertKind.ended, Severity.normal, 'Marcory', 'Zone Industrielle', const Duration(days: 8, hours: 1), level: 71, t: Trend.falling, station: 'marcory'),
      a('al-176', AlertKind.ended, Severity.normal, 'Port-Bouët', 'Vridi', const Duration(days: 11, hours: 2), level: 66, t: Trend.falling, station: 'port-bouet'),
      a('al-175', AlertKind.flood, Severity.danger, 'Port-Bouët', 'Vridi', const Duration(days: 11, hours: 9), level: 164, t: Trend.rising, station: 'port-bouet'),
      a('al-168', AlertKind.warning, Severity.vigilance, 'Yopougon', 'Sicogi', const Duration(days: 14, hours: 3), level: 121, t: Trend.rising, station: 'sicogi'),
      a('al-150', AlertKind.flood, Severity.danger, 'Abobo', 'Anador', const Duration(days: 30, hours: 6), level: 171, t: Trend.rising, station: 'abobo'),
      a('al-141', AlertKind.warning, Severity.vigilance, 'Cocody', 'Riviera Palmeraie', const Duration(days: 33, hours: 4), level: 109, t: Trend.stable, station: 'riviera'),
    ];
  }

  late List<FloodAlert> _alerts;
  final _incoming = StreamController<FloodAlert>.broadcast();
  var _testCount = 0;

  @override
  Future<List<FloodAlert>> fetchAlerts() async {
    await mockDelay();
    return List.unmodifiable(_alerts);
  }

  @override
  Future<FloodAlert> getAlert(String id) async {
    await mockDelay(150, 400);
    return _alerts.firstWhere((a) => a.id == id, orElse: () => throw NotFoundException('alerte $id'));
  }

  @override
  Stream<FloodAlert> watchIncoming() => _incoming.stream;

  @override
  Future<void> requestTestAlert(String commune) async {
    await mockDelay(400, 700);
    _testCount++;
    final alert = FloodAlert(
      id: 'test-$_testCount-${DateTime.now().millisecondsSinceEpoch}',
      kind: AlertKind.flood,
      severity: Severity.danger,
      commune: commune,
      place: 'Alerte de test',
      createdAt: DateTime.now(),
      levelCm: 182,
      trend: Trend.rising,
      active: true,
      message: 'Ceci est une alerte de test. Aucune inondation réelle n\'est en cours.',
      instructions: defaultInstructions,
    );
    _alerts = [alert, ..._alerts];
    // Delai pour laisser le temps de mettre l'application en arriere-plan si on veut tester la notification.
    Timer(const Duration(seconds: 3), () => _incoming.add(alert));
  }
}

/// FastAPI :
///   GET  /alerts                 -> [FloodAlert]
///   GET  /alerts/{id}            -> FloodAlert
///   GET  /alerts?active=true     -> alertes en cours (interrogees periodiquement)
///   POST /alerts/test {commune}  -> declenche une alerte de test (push + SMS)
class ApiAlertRepository implements AlertRepository {
  ApiAlertRepository(this._api, {this.pollInterval = const Duration(seconds: 30)});

  final ApiClient _api;
  final Duration pollInterval;

  @override
  Future<List<FloodAlert>> fetchAlerts() async {
    final data = await _api.get<List<dynamic>>('/alerts');
    return [for (final j in data) FloodAlert.fromJson(j as Map<String, dynamic>)]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<FloodAlert> getAlert(String id) async => FloodAlert.fromJson(await _api.get<Map<String, dynamic>>('/alerts/$id'));

  @override
  Stream<FloodAlert> watchIncoming() {
    final seen = <String>{};
    var first = true;
    late final StreamController<FloodAlert> controller;
    Timer? timer;

    Future<void> poll() async {
      try {
        final data = await _api.get<List<dynamic>>('/alerts', query: {'active': true});
        for (final j in data) {
          final a = FloodAlert.fromJson(j as Map<String, dynamic>);
          // Les alertes deja actives au demarrage ne sont pas rejouees.
          if (seen.add(a.id) && !first) controller.add(a);
        }
        first = false;
      } catch (_) {
        // Hors ligne : on reessaiera au prochain tour. Les push FCM prennent le relais.
      }
    }

    controller = StreamController<FloodAlert>.broadcast(
      onListen: () {
        poll();
        timer = Timer.periodic(pollInterval, (_) => poll());
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> requestTestAlert(String commune) => _api.post<dynamic>('/alerts/test', data: {'commune': commune});
}
