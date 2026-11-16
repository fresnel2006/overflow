import '../../../core/mock/mock_latency.dart';
import '../../../core/network/api_client.dart';
import '../domain/alert_repository.dart';
import '../domain/awareness_article.dart';

class MockAwarenessRepository implements AwarenessRepository {
  @override
  Future<List<AwarenessArticle>> fetchArticles() async {
    await mockDelay();
    final now = DateTime.now();
    return [
      AwarenessArticle(
        id: 'dechets',
        title: 'Ne jetez pas les déchets dans les caniveaux !',
        summary: 'Les déchets bouchent les caniveaux et favorisent les inondations.',
        icon: ArticleIcon.waste,
        publishedAt: now.subtract(const Duration(days: 2)),
        paragraphs: const [
          'À Abidjan, une grande partie des inondations de quartier commence par un caniveau bouché. Sachets plastiques, bouteilles et ordures empêchent l\'eau de pluie de s\'écouler : elle déborde alors sur la chaussée et dans les maisons.',
          'Un caniveau propre peut évacuer plusieurs fois plus d\'eau qu\'un caniveau encombré. Chaque geste compte, surtout pendant la grande saison des pluies, de mai à juillet.',
        ],
        tips: const [
          'Utilisez les bacs et les points de collecte de votre quartier.',
          'Participez aux journées de curage organisées par la mairie.',
          'Signalez un caniveau bouché dans l\'onglet Signalement.',
        ],
      ),
      AwarenessArticle(
        id: 'gestes',
        title: '5 gestes simples pour se protéger',
        summary: 'Découvrez nos conseils pour réduire les risques en saison des pluies.',
        icon: ArticleIcon.shield,
        publishedAt: now.subtract(const Duration(days: 4)),
        paragraphs: const [
          'Quelques précautions prises avant la saison des pluies réduisent fortement les dégâts et les risques pour votre famille.',
        ],
        tips: const [
          'Rangez vos papiers importants dans une pochette étanche, en hauteur.',
          'Surélevez les appareils électriques et les réserves de nourriture.',
          'Repérez à l\'avance un lieu sûr et surélevé près de chez vous.',
          'Préparez un sac d\'urgence : lampe, eau potable, médicaments, chargeur.',
          'Activez les alertes Overflow pour votre zone d\'habitation.',
        ],
      ),
      AwarenessArticle(
        id: 'que-faire',
        title: 'Que faire en cas d\'alerte inondation ?',
        summary: 'Les bons réflexes pour vous mettre en sécurité rapidement.',
        icon: ArticleIcon.warning,
        publishedAt: now.subtract(const Duration(days: 9)),
        paragraphs: const [
          'Quand une alerte Danger est émise pour votre zone, l\'eau peut monter très vite. Ne prenez aucun risque.',
          '30 cm d\'eau suffisent à emporter une voiture et 15 cm d\'eau en mouvement peuvent faire tomber un adulte.',
        ],
        tips: const [
          'Coupez le courant si l\'eau approche de votre maison.',
          'Ne traversez jamais une route ou un pont inondé, à pied comme en voiture.',
          'Éloignez-vous des caniveaux, des ravins et des bas-fonds.',
          'Montez à l\'étage ou rejoignez un lieu sûr.',
          'Appelez le 180 (sapeurs-pompiers) en cas de danger immédiat.',
        ],
      ),
      AwarenessArticle(
        id: 'niveaux',
        title: 'Comprendre les niveaux de vigilance',
        summary: 'Normal, vigilance, danger : ce que signifie chaque niveau.',
        icon: ArticleIcon.levels,
        publishedAt: now.subtract(const Duration(days: 16)),
        paragraphs: const [
          'Les capteurs Overflow mesurent la hauteur d\'eau dans les caniveaux et les bas-fonds en temps réel. Chaque station a ses propres seuils, fixés selon la profondeur du caniveau.',
          'Normal : l\'eau s\'écoule correctement. Vigilance : le niveau monte et approche du débordement, restez attentifs. Danger : l\'eau déborde ou va déborder, suivez les consignes de sécurité.',
        ],
      ),
      AwarenessArticle(
        id: 'kit',
        title: 'Préparer son kit d\'urgence',
        summary: 'Le contenu idéal d\'un sac prêt à partir pendant la saison des pluies.',
        icon: ArticleIcon.kit,
        publishedAt: now.subtract(const Duration(days: 24)),
        paragraphs: const ['Gardez ce sac dans un endroit facile d\'accès et connu de toute la famille.'],
        tips: const [
          'Eau potable et biscuits pour 2 jours',
          'Lampe torche et piles, batterie externe chargée',
          'Trousse de premiers soins et médicaments habituels',
          'Copies des pièces d\'identité dans une pochette étanche',
        ],
      ),
    ];
  }
}

/// GET /awareness -> [AwarenessArticle]
class ApiAwarenessRepository implements AwarenessRepository {
  ApiAwarenessRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<AwarenessArticle>> fetchArticles() async {
    final data = await _api.get<List<dynamic>>('/awareness');
    return [for (final j in data) AwarenessArticle.fromJson(j as Map<String, dynamic>)];
  }
}
