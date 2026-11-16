import '../../../core/utils/formatters.dart';

enum EmergencyService {
  firefighters,
  medical,
  police,
  gendarmerie,
  civilProtection,
  other;

  static EmergencyService fromName(String? v) => switch (v) {
    'firefighters' => EmergencyService.firefighters,
    'medical' => EmergencyService.medical,
    'police' => EmergencyService.police,
    'gendarmerie' => EmergencyService.gendarmerie,
    'civil_protection' => EmergencyService.civilProtection,
    _ => EmergencyService.other,
  };
}

/// Numero a appeler en cas de danger (annuaire fourni par le backend, par commune si besoin).
class EmergencyContact {
  const EmergencyContact({required this.id, required this.name, required this.number, required this.service, this.description, this.priority = 0});

  final String id;
  final String name;

  /// Numero compose tel quel (court ou complet).
  final String number;
  final EmergencyService service;
  final String? description;

  /// Ordre d'affichage (le plus petit en premier).
  final int priority;

  factory EmergencyContact.fromJson(Map<String, dynamic> j) => EmergencyContact(
    id: j['id'].toString(),
    name: j['name'] as String,
    number: j['number'].toString(),
    service: EmergencyService.fromName(j['service'] as String?),
    description: j['description'] as String?,
    priority: (j['priority'] as num?)?.toInt() ?? 0,
  );
}

/// Appel a l'aide transmis aux autorites (visible sur le dashboard de supervision).
class SosRequest {
  const SosRequest({required this.commune, this.lat, this.lon, this.alertId, this.message, this.phone});

  final String commune;
  final double? lat;
  final double? lon;
  final String? alertId;
  final String? message;
  final String? phone;

  Map<String, dynamic> toJson() => {
    'commune': commune,
    'lat': lat,
    'lon': lon,
    'alert_id': ?alertId,
    'message': ?message,
    'phone': ?phone,
  };
}

class SosReceipt {
  const SosReceipt({required this.id, required this.receivedAt});

  final String id;
  final DateTime receivedAt;

  factory SosReceipt.fromJson(Map<String, dynamic> j) => SosReceipt(id: j['id'].toString(), receivedAt: parseDate(j['received_at']));
}

abstract interface class EmergencyRepository {
  Future<List<EmergencyContact>> fetchContacts({String? commune});

  Future<SosReceipt> sendSos(SosRequest request);
}
