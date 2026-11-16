import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../twin_palette.dart';
import '../../domain/flood_logic.dart';
import '../state/flood_viewer_state.dart';
import 'glass.dart';
import 'icons.dart';

/// Legende "Choisir un scenario": carte (tablette) ou pastilles defilantes (telephone).
class ScenarioLegend extends ConsumerStatefulWidget {
  const ScenarioLegend({super.key, this.compact = false, required this.onSelect});

  final bool compact;
  final ValueChanged<String> onSelect;

  @override
  ConsumerState<ScenarioLegend> createState() => _ScenarioLegendState();
}

class _ScenarioLegendState extends ConsumerState<ScenarioLegend> {
  var _open = true;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(floodViewerProvider);
    final fx = Fx.of(context);
    final levels = s.levels;

    if (widget.compact) {
      return SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: s.scenarios.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final sc = s.scenarios[i];
            final on = sc.id == s.activeScenarioId;
            return Semantics(
              selected: on,
              button: true,
              child: GestureDetector(
                onTap: () => widget.onSelect(sc.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: on ? fx.accent.withValues(alpha: 0.7) : Colors.transparent, width: 2),
                  ),
                  child: Glass(
                    radius: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        _Dot(color: parseHexColor(sc.color)),
                        const SizedBox(width: 8),
                        Text(sc.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Text(formatMeters(levels[sc.id] ?? 0), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFeatures: tabular)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Glass(
      width: 296,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: Row(
                children: [
                  const Expanded(child: Text('Choisir un scénario', style: sectionTitle)),
                  AnimatedRotation(
                    turns: _open ? 0 : -0.25,
                    duration: const Duration(milliseconds: 300),
                    child: SvgIcon(AppIcon.chevronDown, size: 16, color: fx.muted),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_open
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final sc in s.scenarios)
                        _Row(
                          label: sc.label,
                          color: parseHexColor(sc.color),
                          value: formatMeters(levels[sc.id] ?? 0),
                          active: sc.id == s.activeScenarioId,
                          onTap: () => widget.onSelect(sc.id),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Text(
                          'Hauteur d’eau au pied du bâtiment, par rapport au terrain naturel.',
                          style: TextStyle(fontSize: 11, height: 1.35, color: fx.muted),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.color, required this.value, required this.active, required this.onTap});

  final String label;
  final Color color;
  final String value;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = Fx.of(context);
    final weight = active ? FontWeight.w600 : FontWeight.w500;
    return Semantics(
      selected: active,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(color: active ? fx.hover : Colors.transparent, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedScale(
                        scale: active ? 1 : 0.7,
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedOpacity(
                          opacity: active ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
                          ),
                        ),
                      ),
                      _Dot(color: color),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: weight)),
                ),
                Text(value, style: TextStyle(fontSize: 12.5, fontWeight: weight, fontFeatures: tabular)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
    ),
  );
}
