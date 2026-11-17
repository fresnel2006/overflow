import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/app_config.dart';
import '../../../core/domain/commune.dart';
import '../../../core/domain/severity.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/severity_style.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/state_views.dart';
import '../../emergency/presentation/emergency_sheet.dart';
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
  // Les pastilles des capteurs n'apparaissent qu'en vue rapprochee pour ne pas couvrir les zones.
  static const _stationZoom = 14.0;
  var _showStations = false;
  GeoPoint? _me;
  Place? _myPlace;
  var _resolvingPlace = false;
  String? _handledFocus;
  // Lieux Mapbox correspondant a la recherche (en plus des zones a risque).
  List<Place> _places = const [];
  String _placesQuery = '';

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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ZoneSheet(zone: zone),
    );
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
      setState(() {
        _me = p;
        _myPlace = null;
        _resolvingPlace = true;
      });
      _map.move(LatLng(p.lat, p.lon), 16.5);
      // Adresse exacte (rue, quartier, commune) via Mapbox.
      final place = await ref.read(geocodingServiceProvider).reverse(p.lat, p.lon);
      if (mounted) setState(() => _myPlace = place);
    } on LocationException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.reason == LocationFailure.unavailable ? l.mapLocationError : l.mapLocationDenied)));
    } finally {
      if (mounted) {
        setState(() {
          _locating = false;
          _resolvingPlace = false;
        });
      }
    }
  }

  Future<void> _searchPlaces(String query) async {
    final q = query.trim();
    _placesQuery = q;
    if (q.length < 3) {
      if (_places.isNotEmpty) setState(() => _places = const []);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 350)); // attend la fin de la frappe
    if (!mounted || q != _placesQuery) return;
    final found = await ref.read(geocodingServiceProvider).search(q);
    if (mounted && q == _placesQuery) setState(() => _places = found);
  }

  void _goToPlace(Place p) {
    _searchFocus.unfocus();
    _search.text = p.name;
    setState(() => _places = const []);
    _map.move(LatLng(p.lat, p.lon), 16);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final zones = ref.watch(zonesProvider);
    final stations = ref.watch(stationsProvider);
    final zoneList = zones.value ?? const <RiskZone>[];
    final stationList = stations.value ?? const <Station>[];
    if (zones.hasValue && stations.hasValue) _applyFocus(zoneList, stationList);
    final mapbox = ref.watch(appConfigProvider).mapboxToken;

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
              onPositionChanged: (camera, _) {
                final show = camera.zoom >= _stationZoom;
                if (show != _showStations) setState(() => _showStations = show);
              },
            ),
            children: [
              if (mapbox.isNotEmpty)
                TileLayer(
                  urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/${_satellite ? 'satellite-streets-v12' : 'streets-v12'}/tiles/256/{z}/{x}/{y}{r}?access_token={token}',
                  additionalOptions: {'token': mapbox},
                  userAgentPackageName: 'ci.esatic.overflow',
                  retinaMode: RetinaMode.isHighDensity(context),
                  maxNativeZoom: 20,
                )
              else if (_satellite) ...[
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
                  if (_me?.accuracyM != null)
                    CircleMarker(
                      point: LatLng(_me!.lat, _me!.lon),
                      radius: _me!.accuracyM!,
                      useRadiusInMeter: true,
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderColor: AppColors.primary.withValues(alpha: 0.5),
                      borderStrokeWidth: 1,
                    ),
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
                  if (_showStations)
                    for (final s in stationList)
                      Marker(
                        point: LatLng(s.lat, s.lon),
                        width: 30,
                        height: 30,
                        child: _StationDot(station: s, onTap: () => context.push(Routes.station(s.id))),
                      ),
                  for (final z in zoneList)
                    Marker(
                      // En vue rapprochee, le pin est decale pour laisser voir le capteur au centre.
                      point: _showStations ? LatLng(z.lat + 0.0012, z.lon) : LatLng(z.lat, z.lon),
                      width: 40,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: _ZonePin(color: z.risk.color, label: z.name, onTap: () => _openZone(z)),
                    ),
                  if (_me != null) Marker(point: LatLng(_me!.lat, _me!.lon), width: 22, height: 22, child: const _MeDot()),
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
                  _SearchBar(
                    controller: _search,
                    focusNode: _searchFocus,
                    onChanged: (q) {
                      setState(() {});
                      _searchPlaces(q);
                    },
                  ),
                  if (_searchFocus.hasFocus && _search.text.trim().isNotEmpty)
                    _SearchResults(
                      zones: zoneList.where((z) => matchesQuery('${z.name} ${z.commune}', _search.text.trim())).take(4).toList(),
                      places: _places,
                      onSelectPlace: _goToPlace,
                      onSelect: (z) {
                        _search.text = z.name;
                        _map.move(LatLng(z.lat, z.lon), 14.5);
                        _openZone(z);
                      },
                    ),
                  if (_me != null && !_searchFocus.hasFocus) ...[
                    const SizedBox(height: 10),
                    _MyPositionCard(
                      point: _me!,
                      place: _myPlace,
                      loading: _resolvingPlace,
                      onTap: () => _map.move(LatLng(_me!.lat, _me!.lon), 17),
                      onClose: () => setState(() {
                        _me = null;
                        _myPlace = null;
                      }),
                    ),
                  ],
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
                        const SizedBox(height: 10),
                        CircleIconButton(
                          icon: LucideIcons.siren,
                          tooltip: l.mapEmergency,
                          background: AppColors.danger,
                          iconColor: Colors.white,
                          onPressed: () => showEmergencySheet(context),
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

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _LegendCard(updatedAt: stationList.isEmpty ? null : stationList.first.updatedAt, satellite: _satellite, mapbox: mapbox.isNotEmpty),
          ),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    ),
  );
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.zones, required this.onSelect, this.places = const [], this.onSelectPlace});
  final List<RiskZone> zones;
  final ValueChanged<RiskZone> onSelect;
  final List<Place> places;
  final ValueChanged<Place>? onSelectPlace;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
    child: zones.isEmpty && places.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.l10n.mapNoResult, style: AppText.bodyMuted),
          )
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
              for (final p in places)
                ListTile(
                  dense: true,
                  leading: const Icon(LucideIcons.mapPinned, color: AppColors.primary, size: 20),
                  title: Text(p.name, style: AppText.title.copyWith(fontSize: 13.5)),
                  subtitle: Text(p.address, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => onSelectPlace?.call(p),
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
      child: Icon(
        Icons.location_on,
        size: 40,
        color: color,
        shadows: const [Shadow(color: Color(0x55000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
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
  const _LegendCard({required this.updatedAt, required this.satellite, this.mapbox = false});
  final DateTime? updatedAt;
  final bool satellite;
  final bool mapbox;

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
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(color: r.color, shape: BoxShape.circle),
                    ),
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
              Text(mapbox ? '© Mapbox © OpenStreetMap' : (satellite ? '© Esri, OpenStreetMap' : '© OpenStreetMap'), style: AppText.caption.copyWith(fontSize: 9, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Vous etes ici" : adresse exacte (Mapbox) et precision du GPS.
class _MyPositionCard extends StatelessWidget {
  const _MyPositionCard({required this.point, required this.place, required this.loading, required this.onTap, required this.onClose});
  final GeoPoint point;
  final Place? place;
  final bool loading;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final coords = '${point.lat.toStringAsFixed(5)}, ${point.lon.toStringAsFixed(5)}';
    final accuracy = point.accuracyM == null ? null : l.mapAccuracy(point.accuracyM!.round());
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.navigation, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.mapYouAreHere, style: AppText.caption.copyWith(fontSize: 11)),
                      if (loading)
                        Text(l.mapFindingAddress, style: AppText.title.copyWith(fontSize: 13.5, color: AppColors.textSecondary))
                      else
                        Text(place?.address ?? coords, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.title.copyWith(fontSize: 13.5)),
                      Text([if (place != null) coords, ?accuracy].join(' · '), style: AppText.caption.copyWith(fontSize: 10.5)),
                    ],
                  ),
                ),
                IconButton(tooltip: l.commonClose, onPressed: onClose, icon: const Icon(LucideIcons.x, size: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
