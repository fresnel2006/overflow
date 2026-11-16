import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/domain/commune.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/headers.dart';
import '../../../core/widgets/pill_chips.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/auth_providers.dart';
import 'station_providers.dart';
import 'widgets/station_row.dart';

/// Toutes les stations de mesure ("Voir toutes les stations" depuis l'accueil).
class StationsScreen extends ConsumerStatefulWidget {
  const StationsScreen({super.key});

  @override
  ConsumerState<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends ConsumerState<StationsScreen> {
  var _query = '';
  var _mine = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final commune = ref.watch(userCommuneProvider);
    final stations = ref.watch(stationsProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          PageHeader(title: l.stationsTitle),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(hintText: l.stationsSearchHint, prefixIcon: const Icon(LucideIcons.search, size: 19, color: AppColors.textSecondary)),
            ),
          ),
          PillChips<bool>(items: [(false, l.stationsFilterAll), (true, l.stationsFilterMyZone)], selected: _mine, onSelected: (v) => setState(() => _mine = v)),
          const SizedBox(height: 12),
          Expanded(
            child: AsyncValueView(
              value: stations,
              onRetry: () => ref.invalidate(stationsProvider),
              data: (all) {
                final list = all
                    .where((s) => !_mine || s.commune == commune)
                    .where((s) => _query.isEmpty || matchesQuery('${s.name} ${s.commune} ${s.place}', _query))
                    .toList()
                  ..sort((a, b) => b.severity.index != a.severity.index ? b.severity.index.compareTo(a.severity.index) : a.name.compareTo(b.name));
                if (list.isEmpty) return EmptyView(message: l.stationsEmpty, icon: LucideIcons.radar);
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(stationsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => AppCard(
                      padding: EdgeInsets.zero,
                      child: StationRow(station: list[i], showCommune: true, onTap: () => context.push(Routes.station(list[i].id))),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
