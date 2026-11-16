import '../../../core/domain/severity.dart';
import '../../../core/utils/formatters.dart';

/// Type d'alerte affiche dans l'historique : Inondation, Alerte (vigilance) ou Fin d'alerte.
enum AlertKind {
  flood,
  warning,
  ended;

  static AlertKind fromName(String? v) => switch (v) {
    'flood' => AlertKind.flood,
    'ended' => AlertKind.ended,
    _ => AlertKind.warning,
  };
}

/// Pictogramme d'une consigne de securite.
enum InstructionIcon {
  avoid,
  road,
  shelter,
  power,
  phone,
  water;

  static InstructionIcon fromName(String? v) => InstructionIcon.values.where((e) => e.name == v).firstOrNull ?? InstructionIcon.avoid;
}

class SafetyInstruction {
  const SafetyInstruction(this.icon, this.text);

  final InstructionIcon icon;
  final String text;

  factory SafetyInstruction.fromJson(Map<String, dynamic> j) => SafetyInstruction(InstructionIcon.fromName(j['icon'] as String?), j['text'] as String);
}

class FloodAlert {
  const FloodAlert({
    required this.id,
    required this.kind,
    required this.severity,
    required this.commune,
    required this.place,
    required this.createdAt,
    this.levelCm,
    this.trend = Trend.stable,
    this.message,
    this.instructions = const [],
    this.stationId,
    this.active = false,
  });

  final String id;
  final AlertKind kind;
  final Severity severity;
  final String commune;
  final String place;
  final DateTime createdAt;
  final double? levelCm;
  final Trend trend;
  final String? message;
  final List<SafetyInstruction> instructions;
  final String? stationId;

  /// Alerte en cours (non levee).
  final bool active;

  String get location => place.isEmpty ? commune : '$commune - $place';

  factory FloodAlert.fromJson(Map<String, dynamic> j) => FloodAlert(
    id: j['id'].toString(),
    kind: AlertKind.fromName(j['kind'] as String?),
    severity: Severity.fromName(j['severity'] as String?),
    commune: j['commune'] as String,
    place: (j['place'] as String?) ?? '',
    createdAt: parseDate(j['created_at']),
    levelCm: (j['level_cm'] as num?)?.toDouble(),
    trend: Trend.fromName(j['trend'] as String?),
    message: j['message'] as String?,
    instructions: [for (final i in (j['instructions'] as List?) ?? const []) SafetyInstruction.fromJson(i as Map<String, dynamic>)],
    stationId: j['station_id'] as String?,
    active: (j['active'] as bool?) ?? false,
  );
}
