import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Rangee de filtres en pilules (Tous, Ma zone, Inondations, Conseils).
class PillChips<T> extends StatelessWidget {
  const PillChips({super.key, required this.items, required this.selected, required this.onSelected, this.padding = const EdgeInsets.symmetric(horizontal: 20), this.scrollable = true});

  final List<(T, String)> items;
  final T selected;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final (value, label) in items)
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _Chip(label: label, active: value == selected, onTap: () => onSelected(value)),
        ),
    ];
    if (!scrollable) return Padding(padding: padding, child: Wrap(runSpacing: 8, children: chips));
    return SizedBox(
      height: 38,
      child: ListView(scrollDirection: Axis.horizontal, padding: padding, children: chips),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: active,
    button: true,
    child: Material(
      color: active ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(side: BorderSide(color: active ? AppColors.primary : AppColors.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: AppText.label.copyWith(color: active ? Colors.white : AppColors.textPrimary, fontWeight: active ? FontWeight.w600 : FontWeight.w500),
          ),
        ),
      ),
    ),
  );
}
