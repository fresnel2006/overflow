import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/badges.dart';
import '../../domain/station.dart';

/// Ligne "Banco / Mis a jour 14:20 / 68 cm / Normal" (accueil et liste des stations).
class StationRow extends StatelessWidget {
  const StationRow({super.key, required this.station, this.onTap, this.showCommune = false});

  final Station station;
  final VoidCallback? onTap;
  final bool showCommune;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.name, style: AppText.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    showCommune ? '${station.commune} · ${l.commonUpdatedAt(Fmt.time(station.updatedAt))}' : l.commonUpdatedAt(Fmt.time(station.updatedAt)),
                    style: AppText.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(Fmt.cm(station.levelCm), key: ValueKey(station.levelCm), style: AppText.value),
                ),
                const SizedBox(height: 4),
                SeverityBadge(station.severity),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
