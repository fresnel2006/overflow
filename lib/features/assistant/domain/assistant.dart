enum ChatRole { user, assistant }

class ChatMessage {
  const ChatMessage({required this.role, required this.text, required this.time, this.failed = false});

  final ChatRole role;
  final String text;
  final DateTime time;

  /// Message de l'utilisateur dont la reponse a echoue (bouton reessayer).
  final bool failed;

  ChatMessage copyWith({bool? failed}) => ChatMessage(role: role, text: text, time: time, failed: failed ?? this.failed);
}

/// Situation de l'utilisateur transmise a l'IA pour des reponses adaptees.
class AssistantContext {
  const AssistantContext({this.commune, this.situation, this.alertToExplain});

  final String? commune;

  /// Resume des mesures et alertes en cours.
  final String? situation;

  /// Description d'une alerte a expliquer.
  final String? alertToExplain;

  String describe() => [
    if (commune != null) 'Zone suivie par l\'utilisateur : $commune, Abidjan.',
    if (situation != null) 'Situation actuelle : $situation',
    if (alertToExplain != null) 'Alerte a expliquer : $alertToExplain',
  ].join('\n');
}

abstract interface class AssistantRepository {
  /// [history] se termine par le message de l'utilisateur.
  Future<String> reply(List<ChatMessage> history, AssistantContext context);

  /// false pour le mode hors ligne / demonstration.
  bool get isConnectedToAi;
}
