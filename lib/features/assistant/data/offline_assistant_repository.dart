import '../../../core/mock/mock_latency.dart';
import '../domain/assistant.dart';

/// Reponses preparees, utilisees sans cle Gemini ou en mode demonstration.
/// Couvre les questions les plus frequentes pour que l'ecran reste utile hors ligne.
class OfflineAssistantRepository implements AssistantRepository {
  @override
  bool get isConnectedToAi => false;

  @override
  Future<String> reply(List<ChatMessage> history, AssistantContext context) async {
    await mockDelay(700, 1200);
    final q = history.last.text.toLowerCase();

    if (context.alertToExplain != null && (q.contains('expli') || q.contains('alerte') || history.length == 1)) {
      return 'Cette alerte signifie que le capteur installé près de chez vous mesure un niveau d\'eau élevé.\n\n'
          '- Vigilance : l\'eau monte et approche du débordement. Restez attentifs.\n'
          '- Danger : l\'eau déborde ou va déborder sur la chaussée.\n\n'
          'Que faire maintenant :\n'
          '- Évitez les caniveaux, ravins et bas-fonds.\n'
          '- Ne traversez pas une route inondée.\n'
          '- Mettez vos papiers et appareils électriques en hauteur.\n'
          '- En cas de danger immédiat, appelez le 180 (sapeurs-pompiers).';
    }
    if (q.contains('kit') || q.contains('sac') || q.contains('prépar') || q.contains('prepar')) {
      return 'Pour la saison des pluies, préparez un sac d\'urgence :\n'
          '- Eau potable et nourriture pour 2 jours\n'
          '- Lampe torche, piles et batterie externe chargée\n'
          '- Médicaments et trousse de premiers soins\n'
          '- Copies de vos pièces d\'identité dans une pochette étanche\n\n'
          'Gardez-le dans un endroit en hauteur, connu de toute la famille.';
    }
    if (q.contains('caniveau') || q.contains('déchet') || q.contains('dechet') || q.contains('bouch')) {
      return 'Un caniveau bouché est l\'une des premières causes d\'inondation dans les quartiers.\n\n'
          '- Ne jetez pas de déchets dans les caniveaux.\n'
          '- Signalez-le dans l\'onglet Signalement avec une photo : la mairie est prévenue.\n'
          '- Ne descendez jamais dans un caniveau pendant la pluie.';
    }
    if (q.contains('niveau') || q.contains('vigilance') || q.contains('danger') || q.contains('normal')) {
      return 'Les capteurs Overflow mesurent la hauteur d\'eau dans les caniveaux en temps réel :\n'
          '- Normal : l\'eau s\'écoule bien.\n'
          '- Vigilance : le niveau monte, restez attentifs et évitez les bas-fonds.\n'
          '- Danger : l\'eau déborde, suivez les consignes et éloignez-vous des zones basses.';
    }
    if (q.contains('voiture') || q.contains('route') || q.contains('travers') || q.contains('moto')) {
      return 'Ne traversez jamais une route inondée, même si l\'eau semble basse.\n\n'
          '- 30 cm d\'eau suffisent à emporter une voiture.\n'
          '- 15 cm d\'eau en mouvement peuvent faire tomber un adulte.\n'
          '- Faites demi-tour et attendez que l\'eau baisse.';
    }
    final where = context.commune == null ? '' : ' à ${context.commune}';
    return 'En cas de forte pluie$where :\n'
        '- Suivez les alertes Overflow de votre zone.\n'
        '- Éloignez-vous des caniveaux et des bas-fonds.\n'
        '- Coupez le courant si l\'eau entre dans la maison.\n'
        '- Rejoignez un lieu sûr et surélevé.\n'
        '- Urgence : sapeurs-pompiers 180, SAMU 185.\n\n'
        'Vous pouvez me demander d\'expliquer une alerte ou comment préparer un kit d\'urgence.';
  }
}
