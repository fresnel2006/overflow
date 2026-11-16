import 'app_user.dart';

/// Codes d'erreur portes par ValidationException :
/// invalid-phone, invalid-code, expired-code, too-many-requests, cancelled.
abstract interface class AuthRepository {
  /// Emet l'utilisateur connecte (ou null) a chaque changement de session ou de profil.
  Stream<AppUser?> authStateChanges();

  /// Envoie le code SMS. [fullName] est fourni lors d'une inscription.
  Future<PhoneVerification> sendOtp(String phoneE164, {String? fullName, int? resendToken});

  Future<AppUser> verifyOtp(PhoneVerification verification, String code);

  Future<AppUser> signInWithGoogle();

  Future<AppUser> updateProfile({String? fullName, String? email, String? commune});

  Future<void> signOut();

  /// Jeton a transmettre a l'API FastAPI (Firebase ID token).
  Future<String?> idToken();
}
