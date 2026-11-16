import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/awareness_article.dart';
import '../domain/flood_alert.dart';

extension AlertKindStyle on AlertKind {
  String label(AppLocalizations l) => switch (this) {
    AlertKind.flood => l.alertKindFlood,
    AlertKind.warning => l.alertKindWarning,
    AlertKind.ended => l.alertKindEnded,
  };

  String screenTitle(AppLocalizations l) => switch (this) {
    AlertKind.flood => l.alertScreenFlood,
    AlertKind.warning => l.alertScreenWarning,
    AlertKind.ended => l.alertScreenEnded,
  };

  IconData get icon => switch (this) {
    AlertKind.flood => LucideIcons.triangleAlert,
    AlertKind.warning => LucideIcons.bell,
    AlertKind.ended => LucideIcons.circleCheck,
  };

  Color get color => switch (this) {
    AlertKind.flood => AppColors.danger,
    AlertKind.warning => AppColors.warningText,
    AlertKind.ended => AppColors.success,
  };

  Color get softColor => switch (this) {
    AlertKind.flood => AppColors.dangerSoft,
    AlertKind.warning => AppColors.warningSoft,
    AlertKind.ended => AppColors.successSoft,
  };

  /// Degrade de l'ecran plein ecran.
  List<Color> get gradient => switch (this) {
    AlertKind.flood => const [Color(0xFFE53935), AppColors.alertRedDark],
    AlertKind.warning => const [Color(0xFFF59E0B), Color(0xFFB45309)],
    AlertKind.ended => const [Color(0xFF22C55E), Color(0xFF15803D)],
  };
}

extension InstructionIconStyle on InstructionIcon {
  IconData get icon => switch (this) {
    InstructionIcon.avoid => LucideIcons.triangleAlert,
    InstructionIcon.road => LucideIcons.map,
    InstructionIcon.shelter => LucideIcons.mapPin,
    InstructionIcon.power => LucideIcons.zap,
    InstructionIcon.phone => LucideIcons.phone,
    InstructionIcon.water => LucideIcons.waves,
  };
}

extension ArticleIconStyle on ArticleIcon {
  IconData get icon => switch (this) {
    ArticleIcon.waste => LucideIcons.trash2,
    ArticleIcon.shield => LucideIcons.shield,
    ArticleIcon.warning => LucideIcons.triangleAlert,
    ArticleIcon.levels => LucideIcons.chartColumn,
    ArticleIcon.kit => LucideIcons.lifeBuoy,
    ArticleIcon.drain => LucideIcons.waves,
  };
}
