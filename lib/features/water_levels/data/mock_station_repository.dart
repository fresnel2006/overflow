import 'dart:async';
import 'dart:math' as math;

import '../../../core/domain/severity.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/mock/mock_latency.dart';
import '../domain/station.dart';
import '../domain/station_repository.dart';

/// Stations fictives d'Abidjan. Les niveaux evoluent doucement a chaque rafraichissement
/// pour simuler le flux des capteurs.
class MockStationRepository implements StationRepository {
  MockStationRepository({this.refreshInterval = const Duration(seconds: 30)}) {
    final now = DateTime.now();
    _stations = [for (final s in _seed) s.copyWith(updatedAt: now.subtract(Duration(minutes: _rng.nextInt(4))))];
  }

  final Duration refreshInterval;
  final _rng = math.Random(7);
  late List<Station> _stations;

  static final _seed = <Station>[
    _s('banco', 'Banco', 'Yopougon', 'Canal du Banco', 5.3626, -4.0640, 68, Trend.stable, twin: 'yopougon'),
    _s('lagune-ebrie', 'Lagune Ébrié', 'Cocody', 'Baie de Cocody', 5.3352, -4.0010, 112, Trend.rising, twin: 'cocody', vig: 100, dng: 160),
    _s('koumassi', 'Koumassi', 'Koumassi', 'Canal de Koumassi - Remblais', 5.2935, -3.9512, 158, Trend.rising, twin: 'marcory'),
    _s('gourou', 'Bassin du Gourou', 'Cocody', 'Carrefour Indénié', 5.3530, -4.0115, 74, Trend.stable, twin: 'cocody'),
    _s('riviera', 'Riviera Palmeraie', 'Cocody', 'Bas-fond de la Palmeraie', 5.3712, -3.9562, 41, Trend.falling, twin: 'cocody'),
    _s('abobo', 'Abobo Anador', 'Abobo', 'Caniveau Anador', 5.4232, -4.0168, 93, Trend.rising, twin: 'abobo'),
    _s('adjame', 'Adjamé Liberté', 'Adjamé', 'Boulevard Nangui Abrogoua', 5.3602, -4.0225, 82, Trend.stable),
    _s('treichville', 'Treichville Arras', 'Treichville', 'Rue 12 - Arras', 5.2938, -4.0055, 55, Trend.stable, twin: 'treichville'),
    _s('marcory', 'Marcory Zone 4', 'Marcory', 'Rue du Canal', 5.2981, -3.9768, 63, Trend.falling, twin: 'marcory'),
    _s('sicogi', 'Yopougon Sicogi', 'Yopougon', 'Bas-fond Sicogi', 5.3317, -4.0778, 104, Trend.falling, twin: 'yopougon'),
    _s('port-bouet', 'Port-Bouët Vridi', 'Port-Bouët', 'Canal de Vridi', 5.2558, -3.9649, 38, Trend.stable, battery: 21),
  ];

  static Station _s(
    String id,
    String name,
    String commune,
    String place,
    double lat,
    double lon,
    double level,
    Trend trend, {
    String? twin,
    double vig = 100,
    double dng = 150,
    int battery = 86,
  }) => Station(
    id: id,
    name: name,
    commune: commune,
    place: place,
    lat: lat,
    lon: lon,
    levelCm: level,
    vigilanceCm: vig,
    dangerCm: dng,
    trend: trend,
    updatedAt: DateTime.now(),
    batteryPct: battery,
    twinSiteId: twin,
  );

  /// Nouvelle mesure pour chaque station : petite variation orientee par la tendance.
  void _tick() {
    final now = DateTime.now();
    _stations = [
      for (final s in _stations)
        () {
          final bias = switch (s.trend) {
            Trend.rising => 1.6,
            Trend.falling => -1.4,
            Trend.stable => 0.0,
          };
          final next = (s.levelCm + bias + (_rng.nextDouble() * 4 - 2)).clamp(12, 230).toDouble();
          // La tendance s'inverse de temps en temps pour rester realiste.
          final flip = _rng.nextDouble() < 0.06;
          final trend = flip ? Trend.values[_rng.nextInt(3)] : s.trend;
          return s.copyWith(levelCm: double.parse(next.toStringAsFixed(0)), trend: trend, updatedAt: now);
        }(),
    ];
  }

  @override
  Stream<List<Station>> watchStations() async* {
    await mockDelay();
    yield List.unmodifiable(_stations);
    await for (final _ in Stream<void>.periodic(refreshInterval)) {
      _tick();
      yield List.unmodifiable(_stations);
    }
  }

  @override
  Future<List<Station>> fetchStations() async {
    await mockDelay();
    return List.unmodifiable(_stations);
  }

  @override
  Future<Station> getStation(String id) async {
    await mockDelay(200, 500);
    return _stations.firstWhere((s) => s.id == id, orElse: () => throw NotFoundException('station $id'));
  }

  @override
  Future<List<WaterReading>> fetchHistory(String stationId, {Duration period = const Duration(hours: 24)}) async {
    await mockDelay();
    final s = _stations.firstWhere((s) => s.id == stationId, orElse: () => throw NotFoundException('station $stationId'));
    final rng = math.Random(stationId.hashCode);
    const step = Duration(minutes: 30);
    final count = period.inMinutes ~/ step.inMinutes;
    final now = DateTime.now();
    // Courbe : base + averse en fin de periode qui rejoint la mesure actuelle.
    final base = s.levelCm * (s.trend == Trend.rising ? 0.55 : s.trend == Trend.falling ? 1.25 : 0.92);
    return [
      for (var i = 0; i <= count; i++)
        () {
          final k = i / count;
          final shape = math.pow(k, 2.2).toDouble();
          final wave = math.sin(k * math.pi * 3 + rng.nextDouble()) * 4;
          final v = i == count ? s.levelCm : base + (s.levelCm - base) * shape + wave + rng.nextDouble() * 3;
          return WaterReading(time: now.subtract(step * (count - i)), levelCm: v.clamp(5, 260).toDouble());
        }(),
    ];
  }
}
