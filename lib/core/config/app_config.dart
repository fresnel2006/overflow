import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RealtimeSource { polling, firestore }

/// Configuration lue dans assets/config/app.env, surchargeable par --dart-define.
/// Aucune cle n'est ecrite en dur dans le code.
class AppConfig {
  const AppConfig({
    required this.useMocks,
    required this.apiBaseUrl,
    required this.refreshInterval,
    required this.realtimeSource,
    required this.geminiApiKey,
    required this.geminiModel,
    required this.aiProxyUrl,
    this.mapboxToken = '',
    this.firebaseOptions,
  });

  final bool useMocks;
  final String apiBaseUrl;
  final Duration refreshInterval;
  final RealtimeSource realtimeSource;
  final String geminiApiKey;
  final String geminiModel;
  final String aiProxyUrl;

  /// Jeton public Mapbox : fond de carte, adresse exacte de l'utilisateur et recherche d'adresses.
  final String mapboxToken;

  /// Null si Firebase n'est pas configure.
  final FirebaseOptions? firebaseOptions;

  bool get firebaseEnabled => firebaseOptions != null;
  bool get hasMapbox => mapboxToken.isNotEmpty;
  bool get hasGemini => geminiApiKey.isNotEmpty || aiProxyUrl.isNotEmpty;

  static const envAsset = 'assets/config/app.env';

  static Future<AppConfig> load() async {
    await dotenv.load(fileName: envAsset, isOptional: true);
    final firebase = _firebaseOptions();
    return AppConfig(
      useMocks: _read('USE_MOCKS', _defineUseMocks, 'true').toLowerCase() != 'false',
      apiBaseUrl: _read('API_BASE_URL', _defineApiBaseUrl, 'http://10.0.2.2:8000/api/v1'),
      refreshInterval: Duration(seconds: int.tryParse(_read('REFRESH_INTERVAL_SECONDS', _defineRefresh, '30')) ?? 30),
      realtimeSource: _read('REALTIME_SOURCE', _defineRealtime, 'polling') == 'firestore' ? RealtimeSource.firestore : RealtimeSource.polling,
      geminiApiKey: _read('GEMINI_API_KEY', _defineGeminiKey, ''),
      geminiModel: _read('GEMINI_MODEL', _defineGeminiModel, 'gemini-2.5-flash'),
      aiProxyUrl: _read('AI_PROXY_URL', _defineAiProxy, ''),
      mapboxToken: _read('MAPBOX_TOKEN', _defineMapbox, ''),
      firebaseOptions: firebase,
    );
  }

  // --dart-define a la priorite sur le fichier .env.
  static const _defineUseMocks = String.fromEnvironment('USE_MOCKS');
  static const _defineApiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const _defineRefresh = String.fromEnvironment('REFRESH_INTERVAL_SECONDS');
  static const _defineRealtime = String.fromEnvironment('REALTIME_SOURCE');
  static const _defineGeminiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _defineGeminiModel = String.fromEnvironment('GEMINI_MODEL');
  static const _defineAiProxy = String.fromEnvironment('AI_PROXY_URL');
  static const _defineMapbox = String.fromEnvironment('MAPBOX_TOKEN');
  static const _defineFbApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _defineFbAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _defineFbSender = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _defineFbProject = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _defineFbBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const _defineFbIosBundle = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  static String _read(String key, String define, String fallback) {
    if (define.isNotEmpty) return define;
    final fromFile = dotenv.isInitialized ? dotenv.maybeGet(key)?.trim() : null;
    return (fromFile == null || fromFile.isEmpty) ? fallback : fromFile;
  }

  static FirebaseOptions? _firebaseOptions() {
    final apiKey = _read('FIREBASE_API_KEY', _defineFbApiKey, '');
    final appId = _read('FIREBASE_APP_ID', _defineFbAppId, '');
    final sender = _read('FIREBASE_MESSAGING_SENDER_ID', _defineFbSender, '');
    final project = _read('FIREBASE_PROJECT_ID', _defineFbProject, '');
    if (apiKey.isEmpty || appId.isEmpty || sender.isEmpty || project.isEmpty) return null;
    final bucket = _read('FIREBASE_STORAGE_BUCKET', _defineFbBucket, '');
    final iosBundle = _read('FIREBASE_IOS_BUNDLE_ID', _defineFbIosBundle, '');
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: sender,
      projectId: project,
      storageBucket: bucket.isEmpty ? null : bucket,
      iosBundleId: iosBundle.isEmpty ? null : iosBundle,
    );
  }

  @override
  String toString() => 'AppConfig(mocks: $useMocks, api: $apiBaseUrl, firebase: $firebaseEnabled, gemini: $hasGemini, mapbox: $hasMapbox, debug: $kDebugMode)';
}

/// Surcharge dans main() avec la configuration chargee.
final appConfigProvider = Provider<AppConfig>((ref) => throw UnimplementedError('appConfigProvider doit etre surcharge dans main()'));
