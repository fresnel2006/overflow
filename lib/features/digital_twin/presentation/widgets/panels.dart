
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../twin_palette.dart';
import '../../domain/flood_logic.dart';
import '../../domain/models.dart';
import '../state/flood_viewer_state.dart';
import 'glass.dart';
import 'icons.dart';

/// Selecteur de calques (cases a cocher).
class LayerPicker extends ConsumerWidget {
  const LayerPicker({super.key, required this.onChanged});

  final ValueChanged<LayerVisibility> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(floodViewerProvider.select((s) => s.layers));
    final items = <(String, bool, LayerVisibility Function(bool))>[
      ('Bâtiments', l.buildings, (v) => l.copyWith(buildings: v)),
      ('Eau', l.water, (v) => l.copyWith(water: v)),
      ('Règles', l.rulers, (v) => l.copyWith(rulers: v)),
      ('Étiquettes', l.labels, (v) => l.copyWith(labels: v)),
    ];
    return Glass(
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(padding: EdgeInsets.fromLTRB(4, 0, 4, 6), child: Text('Calques', style: sectionTitle)),
          for (final (label, on, next) in items) _CheckRow(label: label, value: on, onTap: () => onChanged(next(!on))),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label, required this.value, required this.onTap});
  final String label;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = Fx.of(context);
    return Semantics(
      checked: value,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: value ? fx.accent : (fx.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: value ? fx.accent : fx.text.withValues(alpha: 0.25)),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    opacity: value ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: SvgIcon(AppIcon.check, size: 12, strokeWidth: 3, color: fx.onAccent),
                  ),
                ),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Jauge Faible / Modere / Eleve / Critique selon l'eau au-dessus du rez-de-chaussee.
class RiskGauge extends ConsumerWidget {
  const RiskGauge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final risk = ref.watch(floodViewerProvider.select((s) => s.risk));
    if (risk == null) return const SizedBox.shrink();
    final fx = Fx.of(context);
    final idx = riskSteps.indexOf(risk.step);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text('RISQUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.7, color: fx.muted)),
            const Spacer(),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: risk.step.color, fontFamily: DefaultTextStyle.of(context).style.fontFamily),
              child: Text(risk.step.label),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, c) => SizedBox(
            height: 14,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Row(
                  children: [
                    for (var i = 0; i < riskSteps.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 6,
                          decoration: BoxDecoration(color: i <= idx ? riskSteps[i].color : fx.track, borderRadius: BorderRadius.circular(3)),
                        ),
                      ),
                    ],
                  ],
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  left: risk.ratio * c.maxWidth - 7,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: risk.step.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: fx.dark ? TwinColors.navy : Colors.white, width: 2.5),
                      boxShadow: [BoxShadow(color: TwinColors.navy.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 1))],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < riskSteps.length; i++)
              Text(riskSteps[i].label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: i == idx ? fx.text : fx.muted)),
          ],
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: risk.message,
            children: [
              if (risk.aboveFloorM > 0) ...[
                const TextSpan(text: ' : '),
                TextSpan(
                  text: formatMeters(risk.aboveFloorM),
                  style: TextStyle(fontWeight: FontWeight.w600, color: fx.text, fontFeatures: tabular),
                ),
                const TextSpan(text: ' au-dessus du plancher'),
              ],
            ],
          ),
          style: TextStyle(fontSize: 11.5, height: 1.35, color: fx.text.withValues(alpha: 0.78)),
        ),
      ],
    );
  }
}

/// Carte du site (haut gauche): nom, commune, plan d'eau, coordonnees, jauge de risque.
class SiteCard extends ConsumerStatefulWidget {
  const SiteCard({super.key, required this.collapsible, this.sites = const [], this.onSiteChanged});

  final bool collapsible;
  final List<FloodDataset> sites;
  final ValueChanged<FloodDataset>? onSiteChanged;

  @override
  ConsumerState<SiteCard> createState() => _SiteCardState();
}

class _SiteCardState extends ConsumerState<SiteCard> {
  late var _open = !widget.collapsible;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(floodViewerProvider);
    final fx = Fx.of(context);
    final site = s.dataset?.site;
    final risk = s.risk;
    final expanded = !widget.collapsible || _open;
    // Au premier rendu Android la taille peut valoir 0: on borne pour ne jamais passer en negatif.
    final width = (MediaQuery.sizeOf(context).width - 96).clamp(200.0, 300.0);

    return Glass(
      width: width,
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.collapsible ? () => setState(() => _open = !_open) : null,
            child: Row(
              children: [
                const BrandMark(size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.collapsible ? 'OVERFLOW' : 'OVERFLOW - ALERTE INONDATION',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: fx.accent),
                      ),
                      Text(
                        site?.name ?? 'Bâtiment',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2),
                      ),
                    ],
                  ),
                ),
                if (widget.collapsible) ...[
                  if (!_open && risk != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: risk.step.color, borderRadius: BorderRadius.circular(10)),
                      child: Text(risk.step.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: SvgIcon(AppIcon.chevronDown, size: 16, color: fx.muted),
                  ),
                ],
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !expanded
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.sites.length > 1 && s.dataset != null) ...[const SizedBox(height: 12), _SitePicker(sites: widget.sites, current: s.dataset!, onChanged: widget.onSiteChanged)],
                      if (site != null) ...[
                        const SizedBox(height: 12),
                        _InfoLine(icon: AppIcon.mapPin, text: '${site.commune}, Abidjan'),
                        if (site.waterBody != null) ...[const SizedBox(height: 4), _InfoLine(icon: AppIcon.waves, text: site.waterBody!)],
                        if (site.lat != null && site.lon != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 22, top: 4),
                            child: Text(
                              '${formatCoord(site.lat!, 'N', 'S')} - ${formatCoord(site.lon!, 'E', 'O')}',
                              style: TextStyle(fontSize: 11, color: fx.muted, fontFeatures: tabular),
                            ),
                          ),
                      ],
                      const SizedBox(height: 12),
                      Divider(height: 1, color: fx.text.withValues(alpha: 0.08)),
                      const SizedBox(height: 12),
                      const RiskGauge(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});
  final AppIcon icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SvgIcon(icon, size: 14, color: Fx.of(context).accent),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    ],
  );
}

class _SitePicker extends StatelessWidget {
  const _SitePicker({required this.sites, required this.current, required this.onChanged});
  final List<FloodDataset> sites;
  final FloodDataset current;
  final ValueChanged<FloodDataset>? onChanged;

  @override
  Widget build(BuildContext context) {
    final fx = Fx.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: fx.dark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fx.text.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current.id,
          isExpanded: true,
          borderRadius: BorderRadius.circular(14),
          dropdownColor: fx.dark ? TwinColors.navy : Colors.white,
          icon: SvgIcon(AppIcon.chevronDown, size: 15, color: fx.muted),
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: fx.text, fontFamily: DefaultTextStyle.of(context).style.fontFamily),
          items: [
            for (final s in sites)
              DropdownMenuItem(
                value: s.id,
                child: Text('${s.site?.commune ?? s.id} - ${s.site?.name ?? ''}', overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (id) => onChanged?.call(sites.firstWhere((s) => s.id == id)),
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Image.asset('assets/images/overflow_sans_fond.png', fit: BoxFit.contain, semanticLabel: 'Overflow'),
  );
}
