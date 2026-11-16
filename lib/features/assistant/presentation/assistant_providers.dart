import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../data/gemini_service.dart';
import '../data/offline_assistant_repository.dart';
import '../domain/assistant.dart';

/// Priorite : proxy FastAPI (cle cote serveur) > Gemini direct (cle .env) > reponses hors ligne.
final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  final c = ref.watch(appConfigProvider);
  if (c.aiProxyUrl.isNotEmpty) return ProxyAssistantRepository(ref.watch(apiClientProvider), c.aiProxyUrl);
  if (c.geminiApiKey.isNotEmpty) return GeminiAssistantRepository(apiKey: c.geminiApiKey, model: c.geminiModel);
  return OfflineAssistantRepository();
});
