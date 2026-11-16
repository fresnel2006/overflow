import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../domain/severity.dart';
import 'app_colors.dart';

extension SeverityStyle on Severity {
  Color get color => switch (this) {
    Severity.normal => AppColors.success,
    Severity.vigilance => AppColors.warning,
    Severity.danger => AppColors.danger,
  };

  Color get textColor => switch (this) {
    Severity.normal => AppColors.success,
    Severity.vigilance => AppColors.warningText,
    Severity.danger => AppColors.danger,
  };

  Color get softColor => switch (this) {
    Severity.normal => AppColors.successSoft,
    Severity.vigilance => AppColors.warningSoft,
    Severity.danger => AppColors.dangerSoft,
  };
}

extension RiskStyle on RiskLevel {
  Color get color => switch (this) {
    RiskLevel.high => AppColors.riskHigh,
    RiskLevel.medium => AppColors.riskMedium,
    RiskLevel.low => AppColors.riskLow,
  };
}

extension TrendStyle on Trend {
  IconData get icon => switch (this) {
    Trend.rising => LucideIcons.trendingUp,
    Trend.stable => LucideIcons.moveRight,
    Trend.falling => LucideIcons.trendingDown,
  };
}
