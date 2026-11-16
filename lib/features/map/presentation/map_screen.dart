import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/domain/commune.dart';
import '../../../core/domain/severity.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/severity_style.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/state_views.dart';
import '../../water_levels/domain/station.dart';
import '../../water_levels/presentation/station_providers.dart';
import '../domain/risk_zone.dart';
import 'zone_providers.dart';
import 'zone_sheet.dart';

/// Carte des zones a risque et des capteurs (maquette 7).
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.focusZoneId, this.focusStationId});

  /// Identifiant de zone ou nom de commune a centrer.
  final String? focusZoneId;
  final String? focusStationId;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const _abidjan = LatLng(5.335, -4.005);

  final _map = MapController();
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  var _ready = false;
  var _satellite = true;
  var _locating = false;
  LatLng? _me;
  String? _handledFocus;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(MapScreen old) {
    super.didUpdateWidget(old);
    if (old.focusZoneId != widget.focusZoneId || old.focusStationId != widget.focusStationId) _handledFocus = null;
  }

  @override
  void dispose() {
    _map.dispose();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Centre la carte sur la zone ou la station demandee (lien depuis l'accueil, une alerte, une station).
  void _applyFocus(List<RiskZone> zones, List<Station> stations) {
    final key = '${widget.focusZoneId}|${widget.focusStationId}';
    if (!_ready || _handledFocus == key || (widget.focusZoneId == null && widget.focusStationId == null)) return;
    _handledFocus = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.focusStationId != null) {
        final s = stations.where((s) => s.id == widget.focusStationId).firstOrNull;
        if (s == null) return;
        _map.move(LatLng(s.lat, s.lon), 15);
        final zone = zones.where((z) => z.stationIds.contains(s.id)).firstOrNull;
        if (zone != null) _openZone(zone);
        return;
      }
      final f = widget.focusZoneId!;
      final zone = zones.where((z) => z.id == f).firstOrNull ?? zones.where((z) => z.commune == f).firstOrNull;
      if (zone != null) {
        _map.move(LatLng(zone.lat, zone.lon), 14.5);
        _openZone(zone);
      } else {
        final c = communeByName(f);
        if (c != null) _map.move(LatLng(c.lat, c.lon), 14);
      }
    });
  }

  void _openZone(RiskZone zone) {
    _searchFocus.unfocus();
    showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, builder: (_) => ZoneSheet(zone: zone));
  }

  void _onMapTap(LatLng p, List<RiskZone> zones) {
    // La plus petite zone contenant le point (zones imbriquees).
    final hits = zones.where((z) => z.contains(p.latitude, p.longitude)).toList()..sort((a, b) => a.radiusM.compareTo(b.radiusM));
    if (hits.isNotEmpty) _openZone(hits.first);
  }

  void _zoom(double delta) {
    final cam = _map.camera;
    _map.move(cam.center, (cam.zoom + delta).clamp(3, 18));
  }

  Future<void> _locate() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _locating = true);
    try {
      final p = await ref.read(locationServiceProvider).current();
      final me = LatLng(p.lat, p.lon);
      setState(() => _me = me);
      _map.move(me, 15);
    } on LocationException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.reason == LocationFailure.unavailable ? l.mapLocationError : l.mapLocationDenied)));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final zones = ref.watch(zonesProvider);
    final stations = ref.watch(stationsProvider);
    final zoneList = zones.value ?? const <RiskZone>[];
    final stationList = stations.value ?? const <Station>[];
    if (zones.hasValue && stations.hasValue) _applyFocus(zoneList, stationList);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _abidjan,
              initialZoom: 12.4,
              minZoom: 9,
              maxZoom: 18,
              backgroundColor: const Color(0xFFDDE6EE),
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
              onMapReady: () => setState(() => _ready = true),
              onTap: (_, p) => _onMapTap(p, zoneList),
            ),
            children: [
              if (_satellite) ...[
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'ci.esatic.overflow',
                  maxNativeZoom: 18,
                ),
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'ci.esatic.overflow',
                  maxNativeZoom: 18,
                ),
              ] else
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'ci.esatic.overflow', maxNativeZoom: 19),
              CircleLayer(
                circles: [
                  for (final z in zoneList)
                    CircleMarker(
                      point: LatLng(z.lat, z.lon),
                      radius: z.radiusM,
                      useRadiusInMeter: true,
                      color: z.risk.color.withValues(alpha: 0.32),
                      borderColor: z.risk.color.withValues(alpha: 0.9),
                      borderStrokeWidth: 1.5,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  for (final s in stationList)
                    Marker(
                      point: LatLng(s.lat, s.lon),
                      width: 30,
                      height: 30,
                      child: _StationDot(station: s, onTap: () => context.push(Routes.station(s.id))),
                    ),
                  for (final z in zoneList)
                    Marker(
                      point: LatLng(z.lat, z.lon),
                      width: 40,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: _ZonePin(color: z.risk.color, label: z.name, onTap: () => _openZone(z)),
                    ),
                  if (_me != null) Marker(point: _me!, width: 22, height: 22, child: const _MeDot()),
                ],
              ),
            ],
          ),

          // Recherche + controles.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SearchBar(controller: _search, focusNode: _searchFocus, onChanged: (_) => setState(() {})),
                  if (_searchFocus.hasFocus && _search.text.trim().isNotEmpty)
                    _SearchResults(
                      zones: zoneList.where((z) => matchesQuery('${z.name} ${z.commune}', _search.text.trim())).take(6).toList(),
                      onSelect: (z) {
                        _search.text = z.name;
                        _map.move(LatLng(z.lat, z.lon), 14.5);
                        _openZone(z);
                      },
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: AppShadows.soft),
                          child: Column(
                            children: [
                              IconButton(tooltip: l.mapZoomIn, onPressed: () => _zoom(1), icon: const Icon(LucideIcons.plus, size: 20)),
                              Container(width: 24, height: 1, color: AppColors.divider),
                              IconButton(tooltip: l.mapZoomOut, onPressed: () => _zoom(-1), icon: const Icon(LucideIcons.minus, size: 20)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _locating
                            ? Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(11),
                                decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              )
                            : CircleIconButton(icon: LucideIcons.locateFixed, tooltip: l.mapMyPosition, iconColor: AppColors.primary, onPressed: _locate),
                        const SizedBox(height: 10),
                        CircleIconButton(
                          icon: LucideIcons.layers,
                          tooltip: _satellite ? l.mapPlan : l.mapSatellite,
                          onPressed: () => setState(() => _satellite = !_satellite),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Etats de chargement et d'erreur des zones.
          if (zones.isLoading && !zones.hasValue) const Positioned(top: 0, bottom: 0, left: 0, right: 0, child: IgnorePointer(child: LoadingView())),
          if (zones.hasError && !zones.hasValue)
            Positioned(
              left: 16,
              right: 16,
              top: 140,
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: ErrorView(error: zones.error!, compact: true, onRetry: () => ref.invalidate(zonesProvider)),
              ),
            ),

          Positioned(left: 16, right: 16, bottom: 16, child: _LegendCard(updatedAt: stationList.isEmpty ? null : stationList.first.updatedAt, satellite: _satellite)),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.focusNode, required this.onChanged});
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: AppShadows.card),
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: AppText.body,
      decoration: InputDecoration(
        hintText: context.l10n.mapSearchHint,
        prefixIcon: const Icon(LucideIcons.search, size: 19, color: AppColors.textSecondary),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: context.l10n.commonClose,
                icon: const Icon(LucideIcons.x, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                  focusNode.unfocus();
                },
              ),
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    ),
  );
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.zones, required this.onSelect});
  final List<RiskZone> zones;
  final ValueChanged<RiskZone> onSelect;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
    child: zones.isEmpty
        ? Padding(padding: const EdgeInsets.all(16), child: Text(context.l10n.mapNoResult, style: AppText.bodyMuted))
        : Column(
            children: [
              for (final z in zones)
                ListTile(
                  dense: true,
                  leading: Icon(LucideIcons.mapPin, color: z.risk.color, size: 20),
                  title: Text(z.name, style: AppText.title.copyWith(fontSize: 13.5)),
                  subtitle: Text(z.risk.label(context.l10n), style: AppText.caption),
                  onTap: () => onSelect(z),
                ),
            ],
          ),
  );
}

class _ZonePin extends StatelessWidget {
  const _ZonePin({required this.color, required this.label, required this.onTap});
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: onTap,
      child: Icon(Icons.location_on, size: 40, color: color, shadows: const [Shadow(color: Color(0x55000000), blurRadius: 6, offset: Offset(0, 2))]),
    ),
  );
}

class _StationDot extends StatelessWidget {
  const _StationDot({required this.station, required this.onTap});
  final Station station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${station.name} ${Fmt.cm(station.levelCm)}',
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: station.severity.color, width: 2.5),
          boxShadow: AppShadows.soft,
        ),
        child: Icon(LucideIcons.droplet, size: 14, color: station.severity == Severity.normal ? AppColors.primary : station.severity.color),
      ),
    ),
  );
}

class _MeDot extends StatelessWidget {
  const _MeDot();

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 4)],
    ),
  );
}

class _LegendCard extends StatelessWidget {
  const _LegendCard({required this.updatedAt, required this.satellite});
  final DateTime? updatedAt;
  final bool satellite;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.mapLegend, style: AppText.title.copyWith(fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              for (final r in [RiskLevel.high, RiskLevel.medium, RiskLevel.low])
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 9, height: 9, decoration: BoxDecoration(color: r.color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(r.label(l), style: AppText.caption.copyWith(color: AppColors.textPrimary)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(l.mapLastUpdate(Fmt.time(updatedAt ?? DateTime.now())), style: AppText.caption.copyWith(fontSize: 10.5))),
              Text(satellite ? '© Esri, OpenStreetMap' : '© OpenStreetMap', style: AppText.caption.copyWith(fontSize: 9, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
