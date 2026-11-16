import '../../../core/domain/commune.dart';
import '../../../core/domain/severity.dart';
import '../../../core/mock/mock_latency.dart';
import '../../../core/network/api_client.dart';
import '../domain/risk_zone.dart';
import '../domain/zone_repository.dart';

/// Zones a risque fictives (bas-fonds et canaux connus pour deborder a Abidjan).
class MockZoneRepository implements ZoneRepository {
  @override
  Future<List<RiskZone>> fetchZones() async {
    await mockDelay();
    final now = DateTime.now();
    RiskZone z(String id, String name, String commune, double lat, double lon, double r, RiskLevel risk, String desc, List<String> st, int? daysAgo, [String? twin]) =>
        RiskZone(
          id: id,
          name: name,
          commune: commune,
          lat: lat,
          lon: lon,
          radiusM: r,
          risk: risk,
          description: desc,
          stationIds: st,
          lastFloodAt: daysAgo == null ? null : now.subtract(Duration(days: daysAgo)),
          twinSiteId: twin,
        );
    return [
      z('adjame-liberte', 'Adjamé - Liberté', 'Adjamé', 5.3590, -4.0215, 480, RiskLevel.high,
          'Carrefour très fréquenté où les caniveaux saturent dès les premières fortes pluies.', ['adjame'], 12),
      z('plateau-cathedrale', 'Plateau - Cathédrale', 'Plateau', 5.3270, -4.0215, 380, RiskLevel.medium,
          'Ruissellement rapide vers la lagune depuis les voies en pente du Plateau.', [], 40),
      z('gourou', 'Cocody - Bassin du Gourou', 'Cocody', 5.3530, -4.0115, 520, RiskLevel.high,
          'Bassin versant du Gourou : point noir historique des inondations à Abidjan.', ['gourou'], 34, 'cocody'),
      z('baie-cocody', 'Cocody - Baie de Cocody', 'Cocody', 5.3352, -4.0010, 420, RiskLevel.medium,
          'Montée de la lagune Ébrié lors des grandes marées et des fortes pluies.', ['lagune-ebrie'], 60, 'cocody'),
      z('riviera-palmeraie', 'Cocody - Riviera Palmeraie', 'Cocody', 5.3712, -3.9562, 600, RiskLevel.medium,
          'Bas-fond habité où l\'eau stagne après les averses.', ['riviera'], 33, 'cocody'),
      z('koumassi-remblais', 'Koumassi - Remblais', 'Koumassi', 5.2935, -3.9512, 560, RiskLevel.high,
          'Quartier bas proche de la lagune, canal souvent encombré de déchets.', ['koumassi'], 0, 'marcory'),
      z('abobo-anador', 'Abobo - Anador', 'Abobo', 5.4232, -4.0168, 620, RiskLevel.high,
          'Zone d\'habitat dense, ravinements et débordements de caniveaux.', ['abobo'], 30, 'abobo'),
      z('attecoube-sante', 'Attécoubé - Santé', 'Attécoubé', 5.3385, -4.0405, 420, RiskLevel.high,
          'Pentes fortes : risques combinés d\'inondation et de glissement de terrain.', [], 45),
      z('yopougon-sicogi', 'Yopougon - Sicogi', 'Yopougon', 5.3317, -4.0778, 520, RiskLevel.medium,
          'Bas-fond où l\'eau s\'accumule faute d\'évacuation suffisante.', ['sicogi'], 14, 'yopougon'),
      z('yopougon-banco', 'Yopougon - Banco', 'Yopougon', 5.3626, -4.0640, 450, RiskLevel.medium,
          'Abords du canal du Banco, sous surveillance pendant la saison des pluies.', ['banco'], 70, 'yopougon'),
      z('treichville-arras', 'Treichville - Arras', 'Treichville', 5.2938, -4.0055, 400, RiskLevel.low,
          'Rues basses touchées ponctuellement lors des orages.', ['treichville'], 6, 'treichville'),
      z('marcory-zone4', 'Marcory - Zone 4', 'Marcory', 5.2981, -3.9768, 460, RiskLevel.low,
          'Réseau de drainage récent, débordements rares.', ['marcory'], 8, 'marcory'),
      z('port-bouet-vridi', 'Port-Bouët - Vridi', 'Port-Bouët', 5.2558, -3.9649, 500, RiskLevel.low,
          'Proximité du canal de Vridi, surveillance des marées.', ['port-bouet'], 11),
    ];
  }

  @override
  Future<List<Commune>> fetchCommunes() async {
    await mockDelay(150, 300);
    return abidjanCommunes;
  }
}

/// GET /zones -> [RiskZone], GET /communes -> [Commune]
class ApiZoneRepository implements ZoneRepository {
  ApiZoneRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<RiskZone>> fetchZones() async {
    final data = await _api.get<List<dynamic>>('/zones');
    return [for (final j in data) RiskZone.fromJson(j as Map<String, dynamic>)];
  }

  @override
  Future<List<Commune>> fetchCommunes() async {
    final data = await _api.get<List<dynamic>>('/communes');
    return [for (final j in data) Commune.fromJson(j as Map<String, dynamic>)];
  }
}
