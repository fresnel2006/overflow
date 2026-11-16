import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/mock/mock_latency.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// Authentification simulee : tout code a 6 chiffres est accepte, sauf 000000 (pour tester l'erreur).
/// La session et les comptes crees sont conserves dans SharedPreferences.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._prefs) {
    final raw = _prefs.getString(_sessionKey);
    _user = raw == null ? null : AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static const _sessionKey = 'mock_auth.session';
  static const _accountsKey = 'mock_auth.accounts';

  /// Compte de demonstration : se connecter avec le +225 07 00 00 00 00.
  static const demoPhone = '+2250700000000';

  final SharedPreferences _prefs;
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  Map<String, dynamic> get _accounts {
    final raw = _prefs.getString(_accountsKey);
    final map = raw == null ? <String, dynamic>{} : jsonDecode(raw) as Map<String, dynamic>;
    map.putIfAbsent(
      demoPhone,
      () => const AppUser(id: 'demo-user', fullName: 'Traoré Ange Fresnel', phone: demoPhone, email: 'angefresnel@gmail.com', commune: 'Cocody').toJson(),
    );
    return map;
  }

  Future<void> _saveAccount(AppUser u) async {
    if (u.phone == null) return;
    final map = _accounts..[u.phone!] = u.toJson();
    await _prefs.setString(_accountsKey, jsonEncode(map));
  }

  Future<void> _setUser(AppUser? u) async {
    _user = u;
    if (u == null) {
      await _prefs.remove(_sessionKey);
    } else {
      await _prefs.setString(_sessionKey, jsonEncode(u.toJson()));
      await _saveAccount(u);
    }
    _controller.add(u);
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  Future<PhoneVerification> sendOtp(String phoneE164, {String? fullName, int? resendToken}) async {
    await mockDelay(600, 1100);
    if (!RegExp(r'^\+225\d{10}$').hasMatch(phoneE164)) throw const ValidationException('invalid-phone');
    return PhoneVerification(phone: phoneE164, verificationId: 'mock-${DateTime.now().millisecondsSinceEpoch}', sentAt: DateTime.now(), fullName: fullName, resendToken: 1);
  }

  @override
  Future<AppUser> verifyOtp(PhoneVerification verification, String code) async {
    await mockDelay(600, 1000);
    if (!RegExp(r'^\d{6}$').hasMatch(code) || code == '000000') throw const ValidationException('invalid-code');
    if (DateTime.now().difference(verification.sentAt) > const Duration(minutes: 5)) throw const ValidationException('expired-code');

    final existing = _accounts[verification.phone];
    final AppUser user;
    if (existing != null && !verification.isSignUp) {
      user = AppUser.fromJson(existing as Map<String, dynamic>);
    } else {
      final previous = existing == null ? null : AppUser.fromJson(existing as Map<String, dynamic>);
      user = AppUser(
        id: previous?.id ?? 'user-${verification.phone.hashCode.abs()}',
        fullName: verification.fullName ?? previous?.fullName ?? '',
        phone: verification.phone,
        email: previous?.email,
        commune: previous?.commune,
        createdAt: previous?.createdAt ?? DateTime.now(),
      );
    }
    await _setUser(user);
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await mockDelay(800, 1300);
    const user = AppUser(id: 'google-demo', fullName: 'Traoré Ange Fresnel', email: 'angefresnel@gmail.com');
    final saved = _prefs.getString('mock_auth.google');
    final u = saved == null ? user : AppUser.fromJson(jsonDecode(saved) as Map<String, dynamic>);
    await _setUser(u);
    return u;
  }

  @override
  Future<AppUser> updateProfile({String? fullName, String? email, String? commune}) async {
    await mockDelay(300, 600);
    final u = _user;
    if (u == null) throw const UnauthorizedException();
    final next = u.copyWith(fullName: fullName, email: email, commune: commune);
    if (next.phone == null) await _prefs.setString('mock_auth.google', jsonEncode(next.toJson()));
    await _setUser(next);
    return next;
  }

  @override
  Future<void> signOut() async {
    await mockDelay(150, 300);
    await _setUser(null);
  }

  @override
  Future<String?> idToken() async => _user == null ? null : 'mock-token-${_user!.id}';
}
