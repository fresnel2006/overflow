import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/storage/preferences.dart';
import '../data/firebase_auth_repository.dart';
import '../data/mock_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  // Sans Firebase configure, la connexion reste simulee meme si les donnees viennent de l'API.
  if (config.useMocks || !config.firebaseEnabled) return MockAuthRepository(ref.watch(sharedPreferencesProvider));
  return FirebaseAuthRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) => ref.watch(authRepositoryProvider).authStateChanges());

final currentUserProvider = Provider<AppUser?>((ref) => ref.watch(authStateProvider).value);

/// Commune suivie par l'utilisateur (Cocody par defaut avant le choix).
final userCommuneProvider = Provider<String>((ref) => ref.watch(currentUserProvider)?.commune ?? 'Cocody');
