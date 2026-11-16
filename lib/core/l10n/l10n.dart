import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../domain/severity.dart';
import '../errors/app_exception.dart';

export '../../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension SeverityL10n on Severity {
  String label(AppLocalizations l) => switch (this) {
    Severity.normal => l.severityNormal,
    Severity.vigilance => l.severityVigilance,
    Severity.danger => l.severityDanger,
  };
}

extension RiskL10n on RiskLevel {
  String label(AppLocalizations l) => switch (this) {
    RiskLevel.high => l.riskHigh,
    RiskLevel.medium => l.riskMedium,
    RiskLevel.low => l.riskLow,
  };
}

extension TrendL10n on Trend {
  String label(AppLocalizations l) => switch (this) {
    Trend.rising => l.trendRising,
    Trend.stable => l.trendStable,
    Trend.falling => l.trendFalling,
  };
}

/// Message lisible pour une erreur, selon son type.
({String title, String message, bool offline}) describeError(AppLocalizations l, Object error) => switch (error) {
  NetworkException() => (title: l.errorNetworkTitle, message: l.errorNetworkMessage, offline: true),
  UnauthorizedException() => (title: l.errorGenericTitle, message: l.errorSession, offline: false),
  NotFoundException() => (title: l.errorNotFound, message: l.errorGenericMessage, offline: false),
  UnavailableException() => (title: l.errorGenericTitle, message: l.errorUnavailable, offline: false),
  ValidationException(:final code) => (title: l.errorGenericTitle, message: authErrorMessage(l, code), offline: false),
  _ => (title: l.errorGenericTitle, message: l.errorGenericMessage, offline: false),
};

String authErrorMessage(AppLocalizations l, String code) => switch (code) {
  'invalid-phone' => l.authErrorInvalidPhone,
  'invalid-code' => l.authErrorInvalidCode,
  'expired-code' => l.authErrorExpiredCode,
  'too-many-requests' => l.authErrorTooMany,
  _ => l.errorGenericMessage,
};
