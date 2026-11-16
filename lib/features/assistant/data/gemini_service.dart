import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/assistant.dart';

const overflowSystemPrompt = '''
Tu es l'assistant de l'application Overflow, qui aide les habitants d'Abidjan et de Côte d'Ivoire face aux inondations.
Règles :
- Réponds en français simple et clair, en phrases courtes. Beaucoup d'utilisateurs ne sont pas à l'aise avec la technologie.
- Donne en priorité des consignes de sécurité concrètes et adaptées au contexte ivoirien (caniveaux, bas-fonds, saison des pluies de mai à juillet et d'octobre à novembre).
- Pour expliquer une alerte : dis ce que signifie le niveau (Normal, Vigilance, Danger), ce qui se passe, puis ce qu'il faut faire maintenant.
- En cas de danger immédiat, rappelle d'appeler les sapeurs-pompiers au 180 ou le SAMU au 185.
- Ne fais pas de prévision que les données ne permettent pas. Si tu ne sais pas, dis-le.
- 120 mots maximum. Utilise des listes à puces avec "-" quand c'est utile. Pas d'emojis, pas de tiret long.
''';

/// Appel direct a l'API Gemini (generateContent). La cle vient de la configuration (.env),
/// jamais du code. En production, preferez [ProxyAssistantRepository] pour garder la cle cote serveur.
class GeminiAssistantRepository implements AssistantRepository {
  GeminiAssistantRepository({required this.apiKey, required this.model, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 45),
            ),
          );

  final String apiKey;
  final String model;
  final Dio _dio;

  @override
  bool get isConnectedToAi => true;

  @override
  Future<String> reply(List<ChatMessage> history, AssistantContext context) async {
    final ctx = context.describe();
    final body = {
      'systemInstruction': {
        'parts': [
          {'text': ctx.isEmpty ? overflowSystemPrompt : '$overflowSystemPrompt\nContexte :\n$ctx'},
        ],
      },
      'contents': [
        for (final m in history.where((m) => !m.failed || m == history.last))
          {
            'role': m.role == ChatRole.user ? 'user' : 'model',
            'parts': [
              {'text': m.text},
            ],
          },
      ],
      'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 800},
    };
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '/models/$model:generateContent',
        data: body,
        options: Options(headers: {'x-goog-api-key': apiKey, 'Content-Type': 'application/json'}),
      );
      final candidates = (r.data?['candidates'] as List?) ?? const [];
      if (candidates.isEmpty) throw const ServerException(details: 'Réponse Gemini vide');
      final parts = ((candidates.first as Map)['content']?['parts'] as List?) ?? const [];
      final text = parts.map((p) => (p as Map)['text'] ?? '').join().trim();
      if (text.isEmpty) throw const ServerException(details: 'Réponse Gemini vide');
      return cleanAiText(text);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }
}

/// Route FastAPI qui relaie vers Gemini : POST {url} {messages: [{role, text}], context} -> {reply}
class ProxyAssistantRepository implements AssistantRepository {
  ProxyAssistantRepository(this._api, this.url);

  final ApiClient _api;
  final String url;

  @override
  bool get isConnectedToAi => true;

  @override
  Future<String> reply(List<ChatMessage> history, AssistantContext context) async {
    final data = await _api.post<Map<String, dynamic>>(
      url,
      data: {
        'messages': [
          for (final m in history) {'role': m.role.name, 'text': m.text},
        ],
        'context': context.describe(),
      },
    );
    return cleanAiText((data['reply'] as String?) ?? '');
  }
}

/// Retire le markdown gras et remplace les tirets longs (regle de l'interface).
String cleanAiText(String s) => s.replaceAll('**', '').replaceAll('—', '-').replaceAll('–', '-').replaceAll(RegExp(r'^\* ', multiLine: true), '- ').trim();
