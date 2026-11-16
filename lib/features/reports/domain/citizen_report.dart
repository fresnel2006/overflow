import '../../../core/utils/formatters.dart';

enum ReportType {
  blockedDrain,
  floodedRoad,
  other;

  String get apiName => switch (this) {
    ReportType.blockedDrain => 'blocked_drain',
    ReportType.floodedRoad => 'flooded_road',
    ReportType.other => 'other',
  };

  static ReportType fromName(String? v) => switch (v) {
    'blocked_drain' => ReportType.blockedDrain,
    'flooded_road' => ReportType.floodedRoad,
    _ => ReportType.other,
  };
}

/// Cycle de vie d'un signalement cote autorites.
enum ReportStatus {
  sent,
  inReview,
  inProgress,
  resolved,
  rejected;

  String get apiName => switch (this) {
    ReportStatus.sent => 'sent',
    ReportStatus.inReview => 'in_review',
    ReportStatus.inProgress => 'in_progress',
    ReportStatus.resolved => 'resolved',
    ReportStatus.rejected => 'rejected',
  };

  static ReportStatus fromName(String? v) => ReportStatus.values.where((s) => s.apiName == v).firstOrNull ?? ReportStatus.sent;
}

class ReportStatusEvent {
  const ReportStatusEvent(this.status, this.at, [this.note]);

  final ReportStatus status;
  final DateTime at;
  final String? note;

  factory ReportStatusEvent.fromJson(Map<String, dynamic> j) =>
      ReportStatusEvent(ReportStatus.fromName(j['status'] as String?), parseDate(j['at']), j['note'] as String?);
}

class CitizenReport {
  const CitizenReport({
    required this.id,
    required this.type,
    required this.description,
    required this.commune,
    required this.status,
    required this.createdAt,
    this.lat,
    this.lon,
    this.photoUrl,
    this.localPhotoPath,
    this.history = const [],
  });

  final String id;
  final ReportType type;
  final String description;
  final String commune;
  final ReportStatus status;
  final DateTime createdAt;
  final double? lat;
  final double? lon;
  final String? photoUrl;

  /// Photo prise sur l'appareil (avant ou sans envoi au serveur).
  final String? localPhotoPath;
  final List<ReportStatusEvent> history;

  factory CitizenReport.fromJson(Map<String, dynamic> j) => CitizenReport(
    id: j['id'].toString(),
    type: ReportType.fromName(j['type'] as String?),
    description: (j['description'] as String?) ?? '',
    commune: (j['commune'] as String?) ?? '',
    status: ReportStatus.fromName(j['status'] as String?),
    createdAt: parseDate(j['created_at']),
    lat: (j['lat'] as num?)?.toDouble(),
    lon: (j['lon'] as num?)?.toDouble(),
    photoUrl: j['photo_url'] as String?,
    history: [for (final h in (j['history'] as List?) ?? const []) ReportStatusEvent.fromJson(h as Map<String, dynamic>)],
  );
}

/// Donnees saisies dans le formulaire "Signaler un probleme".
class NewReport {
  const NewReport({required this.type, required this.description, required this.commune, this.lat, this.lon, this.photoPath});

  final ReportType type;
  final String description;
  final String commune;
  final double? lat;
  final double? lon;
  final String? photoPath;

  Map<String, dynamic> toJson({String? photoUrl}) => {
    'type': type.apiName,
    'description': description,
    'commune': commune,
    'lat': lat,
    'lon': lon,
    'photo_url': ?photoUrl,
  };
}
