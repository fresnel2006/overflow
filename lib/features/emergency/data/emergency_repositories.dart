import '../../../core/mock/mock_latency.dart';
import '../../../core/network/api_client.dart';
import '../domain/emergency.dart';

/// Numeros d'urgence nationaux de Cote d'Ivoire, embarques pour fonctionner sans reseau.
/// A faire valider par les autorites partenaires ; le backend peut les remplacer ou en ajouter
/// (numeros des casernes et commissariats de la commune, par exemple).
const defaultEmergencyContacts = [
  EmergencyContact(
    id: 'gspm',
    name: 'Sapeurs-pompiers (GSPM)',
    number: '180',
    service: EmergencyService.firefighters,
    description: 'Sauvetage, personnes bloquées par l\'eau, évacuation',
    priority: 0,
  ),
  EmergencyContact(id: 'samu', name: 'SAMU', number: '185', service: EmergencyService.medical, description: 'Blessés, malaises, urgence médicale', priority: 1),
  EmergencyContact(id: 'police', name: 'Police secours', number: '110', service: EmergencyService.police, description: 'Sécurité, circulation, personnes en danger', priority: 2),
  EmergencyContact(id: 'police-170', name: 'Police secours (2e numéro)', number: '170', service: EmergencyService.police, priority: 3),
  EmergencyContact(id: 'gendarmerie', name: 'Gendarmerie', number: '111', service: EmergencyService.gendarmerie, priority: 4),
];

class MockEmergencyRepository implements EmergencyRepository {
  @override
  Future<List<EmergencyContact>> fetchContacts({String? commune}) async {
    await mockDelay(150, 300);
    return defaultEmergencyContacts;
  }

  @override
  Future<SosReceipt> sendSos(SosRequest request) async {
    await mockDelay(700, 1200);
    return SosReceipt(id: 'SOS-${DateTime.now().millisecondsSinceEpoch % 100000}', receivedAt: DateTime.now());
  }
}

/// FastAPI :
///   GET  /emergency-contacts?commune=Cocody -> [EmergencyContact]
///   POST /sos {commune, lat, lon, alert_id, message, phone} -> {id, received_at}
class ApiEmergencyRepository implements EmergencyRepository {
  ApiEmergencyRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<EmergencyContact>> fetchContacts({String? commune}) async {
    try {
      final data = await _api.get<List<dynamic>>('/emergency-contacts', query: {'commune': ?commune});
      final list = [for (final j in data) EmergencyContact.fromJson(j as Map<String, dynamic>)]..sort((a, b) => a.priority.compareTo(b.priority));
      return list.isEmpty ? defaultEmergencyContacts : list;
    } catch (_) {
      // En situation d'urgence, les numeros doivent toujours s'afficher, meme hors ligne.
      return defaultEmergencyContacts;
    }
  }

  @override
  Future<SosReceipt> sendSos(SosRequest request) async =>
      SosReceipt.fromJson(await _api.post<Map<String, dynamic>>('/sos', data: request.toJson()));
}
