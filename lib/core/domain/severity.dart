/// Niveau de gravite d'une mesure ou d'une alerte (affiche : Normal, Vigilance, Danger).
enum Severity {
  normal,
  vigilance,
  danger;

  static Severity fromName(String? v) => switch (v?.toLowerCase()) {
    'danger' || 'critical' || 'critique' => Severity.danger,
    'vigilance' || 'warning' || 'watch' => Severity.vigilance,
    _ => Severity.normal,
  };

  bool operator >(Severity other) => index > other.index;
}

/// Niveau de risque d'une zone sur la carte.
enum RiskLevel {
  low,
  medium,
  high;

  static RiskLevel fromName(String? v) => switch (v?.toLowerCase()) {
    'high' || 'eleve' || 'élevé' => RiskLevel.high,
    'medium' || 'moyen' => RiskLevel.medium,
    _ => RiskLevel.low,
  };
}

enum Trend {
  rising,
  stable,
  falling;

  static Trend fromName(String? v) => switch (v?.toLowerCase()) {
    'rising' || 'up' => Trend.rising,
    'falling' || 'down' => Trend.falling,
    _ => Trend.stable,
  };
}
