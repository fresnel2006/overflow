import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/flood_logic.dart';
import '../../domain/models.dart';

class FloodViewerState {
  const FloodViewerState({
    this.dataset,
    this.activeScenarioId,
    this.timeIndex = 0,
    this.playing = false,
    this.layers = const LayerVisibility(),
    this.viewMode = ViewMode.view3d,
    this.theme = FloodTheme.light,
    this.heading = 0,
    this.ready = false,
  });

  final FloodDataset? dataset;
  final String? activeScenarioId;

  /// Index fractionnaire dans la frise.
  final double timeIndex;
  final bool playing;
  final LayerVisibility layers;
  final ViewMode viewMode;
  final FloodTheme theme;
  final double heading;
  final bool ready;

  List<Scenario> get scenarios => dataset?.scenarios ?? const [];
  List<TimelineStep>? get timeline => dataset?.timeline;
  int get maxIndex => maxTimeIndex(timeline);
  Map<String, double> get levels => levelsAt(scenarios, timeline, timeIndex);
  DateTime? get time => timeAt(timeline, timeIndex);
  Scenario? get activeScenario => scenarios.where((s) => s.id == activeScenarioId).firstOrNull;

  RiskInfo? get risk {
    final main = dataset?.mainBuilding;
    final id = activeScenarioId;
    if (main == null || id == null) return null;
    return riskFor(levels[id] ?? 0, main.groundFloorOffsetM);
  }

  FloodViewerState copyWith({
    FloodDataset? dataset,
    String? activeScenarioId,
    double? timeIndex,
    bool? playing,
    LayerVisibility? layers,
    ViewMode? viewMode,
    FloodTheme? theme,
    double? heading,
    bool? ready,
  }) => FloodViewerState(
    dataset: dataset ?? this.dataset,
    activeScenarioId: activeScenarioId ?? this.activeScenarioId,
    timeIndex: timeIndex ?? this.timeIndex,
    playing: playing ?? this.playing,
    layers: layers ?? this.layers,
    viewMode: viewMode ?? this.viewMode,
    theme: theme ?? this.theme,
    heading: heading ?? this.heading,
    ready: ready ?? this.ready,
  );
}

/// Etat de l'UI native (legende, frise, calques, camera). La scene web ne fait que suivre.
class FloodViewerNotifier extends Notifier<FloodViewerState> {
  /// Pas de temps par seconde pendant la lecture.
  static const speed = 2.2;

  @override
  FloodViewerState build() => const FloodViewerState();

  void setDataset(FloodDataset d) {
    final keep = d.scenarios.any((s) => s.id == state.activeScenarioId);
    final first = state.dataset == null;
    state = state.copyWith(
      dataset: d,
      activeScenarioId: keep ? state.activeScenarioId : d.scenarios.firstOrNull?.id,
      timeIndex: first ? maxTimeIndex(d.timeline).toDouble() : state.timeIndex.clamp(0, maxTimeIndex(d.timeline)).toDouble(),
      playing: false,
    );
  }

  void setReady() => state = state.copyWith(ready: true);

  void setActiveScenario(String id) => state = state.copyWith(activeScenarioId: id);

  void setTimeIndex(double i) => state = state.copyWith(timeIndex: i.clamp(0, state.maxIndex).toDouble());

  void togglePlay() {
    if (state.timeline == null) return;
    if (!state.playing && state.timeIndex >= state.maxIndex - 1e-3) {
      state = state.copyWith(timeIndex: 0, playing: true);
    } else {
      state = state.copyWith(playing: !state.playing);
    }
  }

  void pause() => state = state.copyWith(playing: false);

  /// Avance la lecture de dt secondes (appele par le Ticker du widget).
  void tick(double dt) {
    if (!state.playing) return;
    final next = state.timeIndex + dt * speed;
    if (next >= state.maxIndex) {
      state = state.copyWith(timeIndex: state.maxIndex.toDouble(), playing: false);
    } else {
      state = state.copyWith(timeIndex: next);
    }
  }

  void step(int dir) {
    final t = state.timeIndex;
    final next = dir > 0 ? (t + 1e-6).floor() + 1 : (t - 1e-6).ceil() - 1;
    state = state.copyWith(timeIndex: next.clamp(0, state.maxIndex).toDouble(), playing: false);
  }

  void goToPeak() => state = state.copyWith(timeIndex: peakIndex(state.timeline, state.activeScenarioId).toDouble(), playing: false);

  void setLayers(LayerVisibility l) => state = state.copyWith(layers: l);

  void setViewMode(ViewMode m) => state = state.copyWith(viewMode: m);

  void setTheme(FloodTheme t) => state = state.copyWith(theme: t);

  void toggleTheme() => setTheme(state.theme == FloodTheme.dark ? FloodTheme.light : FloodTheme.dark);

  void setHeading(double h) => state = state.copyWith(heading: h);
}

final floodViewerProvider = NotifierProvider.autoDispose<FloodViewerNotifier, FloodViewerState>(FloodViewerNotifier.new);
