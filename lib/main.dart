import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/preferences.dart';
import 'features/auth/presentation/auth_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final config = await AppConfig.load();
  debugPrint('[Overflow] $config');

  var effective = config;
  if (config.firebaseEnabled && !config.useMocks) {
    try {
      await Firebase.initializeApp(options: config.firebaseOptions);
    } catch (e) {
      // Configuration Firebase invalide : l'application reste utilisable sans Firebase.
      debugPrint('[Overflow] Firebase indisponible : $e');
      effective = AppConfig(
        useMocks: config.useMocks,
        apiBaseUrl: config.apiBaseUrl,
        refreshInterval: config.refreshInterval,
        realtimeSource: RealtimeSource.polling,
        geminiApiKey: config.geminiApiKey,
        geminiModel: config.geminiModel,
        aiProxyUrl: config.aiProxyUrl,
      );
    }
  }

  final results = await Future.wait([SharedPreferences.getInstance(), initializeDateFormatting('fr')]);
  final prefs = results.first as SharedPreferences;

  runApp(
    ProviderScope(
      // Pas de nouvelle tentative automatique : chaque ecran propose son bouton "Reessayer".
      retry: (_, _) => null,
      overrides: [
        appConfigProvider.overrideWithValue(effective),
        sharedPreferencesProvider.overrideWithValue(prefs),
        authTokenProvider.overrideWith((ref) => () => ref.read(authRepositoryProvider).idToken()),
      ],
      child: const OverflowApp(),
    ),
  );
  if (kDebugMode && effective.useMocks) debugPrint('[Overflow] Données de démonstration actives (USE_MOCKS=true).');
}
