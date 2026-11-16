import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/domain/commune.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../map/presentation/zone_providers.dart';

/// Liste des communes avec recherche et detection par GPS.
class CommunePicker extends ConsumerStatefulWidget {
  const CommunePicker({super.key, required this.selected, required this.onSelected, this.padding = const EdgeInsets.symmetric(horizontal: 20)});

  final String? selected;
  final ValueChanged<Commune> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  ConsumerState<CommunePicker> createState() => _CommunePickerState();
}

class _CommunePickerState extends ConsumerState<CommunePicker> {
  var _query = '';
  var _locating = false;

  Future<void> _locate(List<Commune> communes) async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _locating = true);
    try {
      final p = await ref.read(locationServiceProvider).current();
      final c = nearestCommune(p.lat, p.lon, communes);
      widget.onSelected(c);
      messenger.showSnackBar(SnackBar(content: Text(l.authZoneLocated(c.name))));
    } on LocationException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.reason == LocationFailure.unavailable ? l.mapLocationError : l.mapLocationDenied)));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final communes = ref.watch(communesProvider);
    return AsyncValueView(
      value: communes,
      onRetry: () => ref.invalidate(communesProvider),
      data: (all) {
        final list = all.where((c) => _query.isEmpty || matchesQuery(c.name, _query)).toList();
        return Column(
          children: [
            Padding(
              padding: widget.padding,
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(hintText: l.authZoneSearchHint, prefixIcon: const Icon(LucideIcons.search, size: 19, color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: widget.padding,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _locating ? null : () => _locate(all),
                  icon: _locating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(LucideIcons.locateFixed, size: 18),
                  label: Text(l.authZoneLocate, style: AppText.link),
                ),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? EmptyView(message: l.mapNoResult, icon: LucideIcons.mapPin, compact: true)
                  : ListView.separated(
                      padding: widget.padding.add(const EdgeInsets.only(bottom: 16)),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final c = list[i];
                        final active = c.name == widget.selected;
                        return Material(
                          color: active ? AppColors.primarySoft : AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            side: BorderSide(color: active ? AppColors.primary : AppColors.border),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            onTap: () => widget.onSelected(c),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.mapPin, size: 19, color: active ? AppColors.primary : AppColors.textSecondary),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(c.label, style: AppText.title.copyWith(fontWeight: active ? FontWeight.w600 : FontWeight.w500))),
                                  if (active) const Icon(LucideIcons.circleCheck, size: 20, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
