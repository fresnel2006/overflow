import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/citizen_report.dart';

extension ReportTypeStyle on ReportType {
  String label(AppLocalizations l) => switch (this) {
    ReportType.blockedDrain => l.reportTypeBlockedDrain,
    ReportType.floodedRoad => l.reportTypeFloodedRoad,
    ReportType.other => l.reportTypeOther,
  };

  IconData get icon => switch (this) {
    ReportType.blockedDrain => LucideIcons.trash2,
    ReportType.floodedRoad => LucideIcons.waves,
    ReportType.other => LucideIcons.circleAlert,
  };
}

extension ReportStatusStyle on ReportStatus {
  String label(AppLocalizations l) => switch (this) {
    ReportStatus.sent => l.reportStatusSent,
    ReportStatus.inReview => l.reportStatusInReview,
    ReportStatus.inProgress => l.reportStatusInProgress,
    ReportStatus.resolved => l.reportStatusResolved,
    ReportStatus.rejected => l.reportStatusRejected,
  };

  Color get color => switch (this) {
    ReportStatus.sent => AppColors.primary,
    ReportStatus.inReview => AppColors.warningText,
    ReportStatus.inProgress => AppColors.warningText,
    ReportStatus.resolved => AppColors.success,
    ReportStatus.rejected => AppColors.textSecondary,
  };

  Color get softColor => switch (this) {
    ReportStatus.sent => AppColors.primarySoft,
    ReportStatus.inReview => AppColors.warningSoft,
    ReportStatus.inProgress => AppColors.warningSoft,
    ReportStatus.resolved => AppColors.successSoft,
    ReportStatus.rejected => AppColors.surfaceMuted,
  };
}
