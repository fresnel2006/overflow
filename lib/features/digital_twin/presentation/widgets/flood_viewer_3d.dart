import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../domain/flood_logic.dart';
import '../../domain/models.dart';
import '../controller/flood_viewer_controller.dart';
import '../state/flood_viewer_state.dart';
import 'glass.dart';
import 'icons.dart';
import 'legend.dart';
import 'panels.dart';
import 'timeline_bar.dart';
import 'toolbar.dart';

/// Viewer 3D reutilisable: la scene est dans une WebView (Three.js), toute l'UI est native.
class FloodViewer3D extends ConsumerStatefulWidget {
  const FloodViewer3D({
    super.key,
    required this.controller,
    required this.dataset,
    this.theme = FloodTheme.light,
    this.sites = const [],
    this.onSiteChanged,
    this.onScenarioChange,
    this.onTimeChange,
    this.onThemeChanged,
    this.leading,
    this.bottomAccessory,
    this.followLatest = false,
  });

  final FloodViewerController controller;
  final FloodDataset dataset;
  final FloodTheme theme;

  /// Affiche sous la carte du site (ex: bouton retour).
  final Widget? leading;

  /// Affiche au-dessus de la legende (ex: choix temps reel / simulations).
  final Widget? bottomAccessory;

  /// Mode temps reel : a chaque nouveau jeu de donnees, la frise se place sur la derniere mesure.
  final bool followLatest;

  /// Sites proposes dans la carte du site (optionnel).
  final List<FloodDataset> sites;
  final ValueChanged<FloodDataset>? onSiteChanged;
  final ValueChanged<Scenario>? onScenarioChange;

  /// Appele a chaque nouveau pas de temps (index entier).
  final void Function(TimelineStep step, int index)? onTimeChange;
  final ValueChanged<FloodTheme>? onThemeChanged;

  @override
  ConsumerState<FloodViewer3D> createState() => _FloodViewer3DState();
}

class _FloodViewer3DState extends ConsumerState<FloodViewer3D> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  final _subs = <StreamSubscription<Object>>[];
  DateTime _lastTimeSent = DateTime.fromMillisecondsSinceEpoch(0);
  var _fullscreen = false;
  var _layersOpen = false;
  var _capturing = false;

  FloodViewerController get _c => widget.controller;
  FloodViewerNotifier get _n => ref.read(floodViewerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _subs
      ..add(_c.onScenarioChange.listen((id) => _n.setActiveScenario(id)))
      ..add(_c.onCameraChange.listen((e) => _n.setHeading(e.heading)));
    ref.listenManual(floodViewerProvider, _onState);
    // Pas de modification de provider pendant la construction de l'arbre.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _n.setDataset(widget.dataset);
      _n.setTheme(widget.theme);
      _c.ready.then((_) {
        if (!mounted) return;
        _n.setReady();
        _pushAll();
      });
    });
  }

  @override
  void didUpdateWidget(FloodViewer3D old) {
    super.didUpdateWidget(old);
    final datasetChanged = old.dataset != widget.dataset;
    final themeChanged = old.theme != widget.theme;
    if (!datasetChanged && !themeChanged) return;
    // Riverpod interdit de modifier un provider pendant la construction de l'arbre.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (datasetChanged) {
        _n.setDataset(widget.dataset);
        if (widget.followLatest) _n.setTimeIndex(ref.read(floodViewerProvider).maxIndex.toDouble());
      }
      if (themeChanged) _n.setTheme(widget.theme);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    for (final s in _subs) {
      s.cancel();
    }
    if (_fullscreen) SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (ref.read(floodViewerProvider).playing) _n.tick(dt.clamp(0, 0.1));
  }

  void _pushAll() {
    final s = ref.read(floodViewerProvider);
    if (s.dataset == null) return;
    _c.setScenarios(s.dataset!);
    _c.setTheme(s.theme);
    _c.setLayers(s.layers);
    if (s.activeScenarioId != null) _c.setScenario(s.activeScenarioId!);
    _c.setTime(s.timeIndex);
    _c.setViewMode(s.viewMode);
  }

  /// Etat natif -> scene web (+ callbacks publics).
  void _onState(FloodViewerState? prev, FloodViewerState next) {
    if (!next.ready) return;
    if (prev == null || !prev.ready) return;
    if (prev.dataset != next.dataset && next.dataset != null) _c.setScenarios(next.dataset!);
    if (prev.theme != next.theme) _c.setTheme(next.theme);
    if (prev.layers != next.layers) _c.setLayers(next.layers);
    if (prev.viewMode != next.viewMode) _c.setViewMode(next.viewMode);
    if (prev.activeScenarioId != next.activeScenarioId && next.activeScenarioId != null) {
      _c.setScenario(next.activeScenarioId!);
      final sc = next.activeScenario;
      if (sc != null) widget.onScenarioChange?.call(sc);
    }
    if (prev.timeIndex != next.timeIndex) {
      // Pendant la lecture: ~30 messages/s, le web lisse entre deux.
      final now = DateTime.now();
      if (!next.playing || now.difference(_lastTimeSent).inMilliseconds >= 33 || next.timeIndex >= next.maxIndex) {
        _lastTimeSent = now;
        _c.setTime(next.timeIndex);
      }
      final i = next.timeIndex.round();
      if (i != prev.timeIndex.round() && next.timeline != null) widget.onTimeChange?.call(next.timeline![i], i);
    }
  }

  void _toggleTheme() {
    _n.toggleTheme();
    widget.onThemeChanged?.call(ref.read(floodViewerProvider).theme);
  }

  void _toggleFullscreen() {
    setState(() => _fullscreen = !_fullscreen);
    SystemChrome.setEnabledSystemUIMode(_fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
  }

  Future<void> _screenshot() async {
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      final bytes = await _c.screenshot();
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _CapturePreview(bytes: bytes, dataset: ref.read(floodViewerProvider).dataset, time: ref.read(floodViewerProvider).time),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Capture impossible : $e')));
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = ref.watch(floodViewerProvider.select((s) => s.ready));
    return LayoutBuilder(
      builder: (context, box) {
        final phone = box.maxWidth < 600;
        final wide = box.maxWidth >= 1100;
        final pad = phone ? 12.0 : 16.0;

        return Stack(
          children: [
            Positioned.fill(
              child: WebViewWidget(
                controller: _c.webView,
                gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
              ),
            ),
            // Voile pendant le chargement de la scene.
            Positioned.fill(
              child: IgnorePointer(
                ignoring: ready,
                child: AnimatedOpacity(
                  opacity: ready ? 0 : 1,
                  duration: const Duration(milliseconds: 500),
                  child: ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5))),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(pad),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SiteCard(collapsible: phone, sites: widget.sites, onSiteChanged: widget.onSiteChanged),
                          if (widget.leading != null) ...[const SizedBox(height: 12), widget.leading!],
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FloodToolbar(
                            onViewMode: _n.setViewMode,
                            onReset: _c.resetCamera,
                            fullscreen: _fullscreen,
                            onFullscreen: _toggleFullscreen,
                            onScreenshot: _screenshot,
                            onToggleTheme: _toggleTheme,
                            onToggleLayers: wide ? null : () => setState(() => _layersOpen = !_layersOpen),
                            layersOpen: _layersOpen,
                          ),
                          const SizedBox(height: 12),
                          Compass(onTap: _c.faceNorth),
                        ],
                      ),
                    ),
                    if (!wide)
                      Positioned(
                        right: phone ? 60 : 64,
                        top: 0,
                        child: IgnorePointer(
                          ignoring: !_layersOpen,
                          child: AnimatedSlide(
                            offset: _layersOpen ? Offset.zero : const Offset(0.05, 0),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: AnimatedOpacity(
                              opacity: _layersOpen ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: LayerPicker(onChanged: _n.setLayers),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.bottomAccessory != null) ...[widget.bottomAccessory!, const SizedBox(height: 8)],
                          if (phone) ...[
                            ScenarioLegend(compact: true, onSelect: _n.setActiveScenario),
                            const SizedBox(height: 8),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!phone) ...[ScenarioLegend(onSelect: _n.setActiveScenario), const SizedBox(width: 12)],
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 820),
                                    child: TimelineBar(compact: phone || box.maxWidth < 900),
                                  ),
                                ),
                              ),
                              if (wide) ...[const SizedBox(width: 12), LayerPicker(onChanged: _n.setLayers)],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Apercu de la capture + partage (share_plus).
class _CapturePreview extends StatelessWidget {
  const _CapturePreview({required this.bytes, required this.dataset, required this.time});

  final Uint8List bytes;
  final FloodDataset? dataset;
  final DateTime? time;

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final dir = await getTemporaryDirectory();
    final stamp = time == null ? '' : '-${formatDayTime(time!).replaceAll(RegExp('[ :]'), '')}';
    final commune = (dataset?.site?.commune ?? 'site').split(' ').first.toLowerCase();
    final file = File('${dir.path}/overflow-$commune$stamp.png');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: 'Overflow - risque d’inondation, ${dataset?.site?.name ?? ''} (${dataset?.site?.commune ?? 'Abidjan'})',
        sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fx = Fx.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Glass(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Capture de la vue', style: sectionTitle)),
                  GlassIconButton(tooltip: 'Fermer', size: 36, onTap: () => Navigator.of(context).pop(), child: SvgIcon(AppIcon.close, color: fx.text)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.55),
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) => FilledButton.icon(
                  onPressed: () => _share(context),
                  icon: SvgIcon(AppIcon.share, color: fx.onAccent),
                  label: const Text('Partager la capture'),
                  style: FilledButton.styleFrom(
                    backgroundColor: fx.accent,
                    foregroundColor: fx.onAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
