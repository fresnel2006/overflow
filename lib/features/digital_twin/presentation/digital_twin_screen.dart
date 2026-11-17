import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/headers.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../water_levels/domain/station.dart';
import '../../water_levels/presentation/station_providers.dart';
import '../domain/live_dataset.dart';
import '../domain/models.dart';
import 'controller/flood_viewer_controller.dart';
import 'state/flood_viewer_state.dart';
import 'twin_palette.dart';
import 'twin_providers.dart';
import 'widgets/flood_viewer_3d.dart';
import 'widgets/glass.dart';

enum TwinMode { live, scenarios }

/// Jumeau numerique 3D (maquette 6). Integre le viewer Three.js existant et le relie aux
/// donnees du backend : en mode "Temps reel", l'eau de la scene suit la mesure du capteur
/// associe au site et se met a jour a chaque nouvelle mesure ; en mode "Simulations",
/// les scenarios de crue calcules par le backend sont affiches.
class DigitalTwinScreen extends ConsumerStatefulWidget {
  const DigitalTwinScreen({super.key, this.siteId, this.stationId});

  final String? siteId;
  final String? stationId;

  @override
  ConsumerState<DigitalTwinScreen> createState() => _DigitalTwinScreenState();
}

class _DigitalTwinScreenState extends ConsumerState<DigitalTwinScreen> {
  final _controller = FloodViewerController();
  var _theme = FloodTheme.light;
  var _mode = TwinMode.live;
  String? _siteId;
  String? _stationId;

  // Cache du jeu "temps reel" : le viewer ne doit recevoir un nouveau jeu que si les mesures changent.
  Object? _liveKey;
  // Site + station pour lesquels la mesure capteur a deja ete selectionnee.
  String? _liveActivatedFor;
  FloodDataset? _liveDataset;

  @override
  void initState() {
    super.initState();
    _siteId = widget.siteId;
    _stationId = widget.stationId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  FloodDataset _pickSite(List<FloodDataset> sites, List<Station> stations) {
    final byId = sites.where((s) => s.id == _siteId).firstOrNull;
    if (byId != null) return byId;
    final station = stations.where((s) => s.id == _stationId).firstOrNull;
    final fromStation = sites.where((s) => s.id == station?.twinSiteId).firstOrNull;
    if (fromStation != null) return fromStation;
    final commune = ref.read(userCommuneProvider).toLowerCase();
    return sites.where((s) => (s.site?.commune ?? s.id).toLowerCase().contains(commune)).firstOrNull ?? sites.first;
  }

  /// Station reliee au site : celle demandee si elle correspond, sinon la plus haute du site.
  Station? _pickStation(FloodDataset site, List<Station> stations) {
    final linked = stations.where((s) => s.twinSiteId == site.id).toList();
    if (linked.isEmpty) return null;
    return linked.where((s) => s.id == _stationId).firstOrNull ?? (linked..sort((a, b) => b.levelCm.compareTo(a.levelCm))).first;
  }

  FloodDataset _liveFor(FloodDataset base, Station station, List<WaterReading> history, String label) {
    final key = (base.id, station.id, station.levelCm, station.updatedAt, history.length, history.isEmpty ? null : history.last.time);
    if (key != _liveKey || _liveDataset == null) {
      _liveKey = key;
      _liveDataset = buildLiveDataset(base: base, station: station, history: history, liveLabel: label);
    }
    return _liveDataset!;
  }

  void _setMode(TwinMode m) {
    setState(() {
      _mode = m;
      if (m == TwinMode.live) _liveActivatedFor = null;
    });
  }

  /// Une fois le jeu temps reel transmis au viewer (2 frames), selectionne la mesure capteur
  /// et place la frise sur la derniere mesure.
  void _activateLive(String key) {
    if (_liveActivatedFor == key) return;
    _liveActivatedFor = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final n = ref.read(floodViewerProvider.notifier);
        n.setActiveScenario(liveScenarioId);
        n.setTimeIndex(ref.read(floodViewerProvider).maxIndex.toDouble());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final sites = ref.watch(twinSitesProvider);
    final stations = ref.watch(stationsProvider).value ?? const <Station>[];
    final dark = _theme == FloodTheme.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Theme(
        data: _twinTheme(dark),
        child: Scaffold(
          backgroundColor: dark ? TwinColors.navy : TwinColors.ice,
          body: sites.when(
            loading: () => const LoadingView(),
            error: (e, _) => SafeArea(
              child: Column(
                children: [
                  PageHeader(title: l.twinTitle),
                  Expanded(child: ErrorView(error: e, onRetry: () => ref.invalidate(twinSitesProvider))),
                ],
              ),
            ),
            data: (list) {
              if (list.isEmpty) {
                return SafeArea(child: Column(children: [PageHeader(title: l.twinTitle), Expanded(child: EmptyView(message: l.twinNoSites, icon: LucideIcons.box))]));
              }
              final site = _pickSite(list, stations);
              final station = _pickStation(site, stations);
              final history = station == null ? null : ref.watch(stationHistoryProvider(station.id)).value;
              final live = _mode == TwinMode.live && station != null && history != null;
              final dataset = live ? _liveFor(site, station, history, l.twinLiveLabel) : site;
              if (live) _activateLive('${site.id}|${station.id}');

              return FloodViewer3D(
                controller: _controller,
                dataset: dataset,
                sites: list,
                theme: _theme,
                followLatest: live,
                onThemeChanged: (t) => setState(() => _theme = t),
                onSiteChanged: (s) => setState(() {
                  _siteId = s.id;
                  _stationId = null;
                }),
                leading: _BackButton(tooltip: l.commonBack, onTap: () => goBack(context)),
                bottomAccessory: _ModeSwitch(
                  mode: _mode,
                  liveAvailable: station != null,
                  loadingLive: _mode == TwinMode.live && station != null && history == null,
                  onChanged: _setMode,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  ThemeData _twinTheme(bool dark) {
    final base = AppTheme.light();
    if (!dark) return base;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppText.family,
      colorScheme: ColorScheme.fromSeed(seedColor: TwinColors.ocean, brightness: Brightness.dark, primary: TwinColors.sky),
    );
  }
}

/// Bouton retour bien visible : pastille blanche pleine avec ombre, quel que soit le fond 3D.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = Fx.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: fx.shadow),
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(LucideIcons.arrowLeft, size: 22, color: TwinColors.navy),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Choix Temps reel / Simulations, en verre depoli comme le reste de l'interface 3D.
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.liveAvailable, required this.loadingLive, required this.onChanged});

  final TwinMode mode;
  final bool liveAvailable;
  final bool loadingLive;
  final ValueChanged<TwinMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fx = Fx.of(context);
    if (!liveAvailable) {
      return Glass(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(LucideIcons.info, size: 16, color: fx.muted),
            const SizedBox(width: 8),
            Expanded(child: Text(l.twinNoSensor, style: TextStyle(fontSize: 12, color: fx.text))),
          ],
        ),
      );
    }
    Widget seg(TwinMode m, IconData icon, String label) {
      final active = mode == m;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(color: active ? fx.accent : Colors.transparent, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (m == TwinMode.live && loadingLive && active)
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: fx.onAccent))
                else
                  Icon(icon, size: 15, color: active ? fx.onAccent : fx.text),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: active ? fx.onAccent : fx.text)),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: '${l.twinLive} / ${l.twinScenarios}',
      child: Glass(
        padding: const EdgeInsets.all(4),
        radius: 15,
        child: Row(
          children: [
            seg(TwinMode.live, LucideIcons.radio, l.twinLive),
            seg(TwinMode.scenarios, LucideIcons.layers, l.twinScenarios),
          ],
        ),
      ),
    );
  }
}
