import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// Firebase Auth (SMS et Google) + profil dans Firestore : users/{uid}
/// { full_name, phone, email, commune, created_at }.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final _profileUpdates = StreamController<AppUser?>.broadcast();

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _db.collection('users').doc(uid);

  Future<AppUser> _loadProfile(User user, {String? fullName}) async {
    final ref = _doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      final created = AppUser(
        id: user.uid,
        fullName: fullName ?? user.displayName ?? '',
        phone: user.phoneNumber,
        email: user.email,
        createdAt: DateTime.now(),
      );
      await ref.set({..._toDoc(created), 'created_at': FieldValue.serverTimestamp()});
      return created;
    }
    final d = snap.data()!;
    if (fullName != null && fullName.isNotEmpty && d['full_name'] != fullName) {
      await ref.update({'full_name': fullName});
      d['full_name'] = fullName;
    }
    return AppUser(
      id: user.uid,
      fullName: (d['full_name'] as String?) ?? user.displayName ?? '',
      phone: (d['phone'] as String?) ?? user.phoneNumber,
      email: (d['email'] as String?) ?? user.email,
      commune: d['commune'] as String?,
      createdAt: (d['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> _toDoc(AppUser u) => {'full_name': u.fullName, 'phone': u.phone, 'email': u.email, 'commune': u.commune};

  @override
  Stream<AppUser?> authStateChanges() {
    final fromAuth = _auth.authStateChanges().asyncMap((u) async {
      if (u == null) return null;
      try {
        return await _loadProfile(u);
      } on FirebaseException {
        // Profil injoignable (hors ligne) : on garde une session minimale.
        return AppUser(id: u.uid, fullName: u.displayName ?? '', phone: u.phoneNumber, email: u.email);
      }
    });
    final out = StreamController<AppUser?>();
    final subs = <StreamSubscription<AppUser?>>[];
    out.onListen = () {
      subs
        ..add(fromAuth.listen(out.add, onError: out.addError))
        ..add(_profileUpdates.stream.listen(out.add));
    };
    out.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
    };
    return out.stream;
  }

  @override
  Future<PhoneVerification> sendOtp(String phoneE164, {String? fullName, int? resendToken}) {
    final completer = Completer<PhoneVerification>();
    _auth.verifyPhoneNumber(
      phoneNumber: phoneE164,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        // Android peut lire le SMS automatiquement : la session s'ouvre sans saisie.
        final result = await _auth.signInWithCredential(credential);
        if (result.user != null) _profileUpdates.add(await _loadProfile(result.user!, fullName: fullName));
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) completer.completeError(_mapAuthError(e));
      },
      codeSent: (verificationId, token) {
        if (!completer.isCompleted) {
          completer.complete(PhoneVerification(phone: phoneE164, verificationId: verificationId, sentAt: DateTime.now(), resendToken: token, fullName: fullName));
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }

  @override
  Future<AppUser> verifyOtp(PhoneVerification verification, String code) async {
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verification.verificationId, smsCode: code);
      final result = await _auth.signInWithCredential(credential);
      final user = await _loadProfile(result.user!, fullName: verification.fullName);
      _profileUpdates.add(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final result = await _auth.signInWithProvider(GoogleAuthProvider());
      final user = await _loadProfile(result.user!);
      _profileUpdates.add(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  @override
  Future<AppUser> updateProfile({String? fullName, String? email, String? commune}) async {
    final u = _auth.currentUser;
    if (u == null) throw const UnauthorizedException();
    final updates = <String, dynamic>{'full_name': ?fullName, 'email': ?email, 'commune': ?commune};
    try {
      await _doc(u.uid).set(updates, SetOptions(merge: true));
      if (fullName != null) await u.updateDisplayName(fullName);
    } on FirebaseException catch (e) {
      throw NetworkException(e.message);
    }
    final profile = await _loadProfile(u);
    _profileUpdates.add(profile);
    return profile;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<String?> idToken() async => _auth.currentUser?.getIdToken();

  static AppException _mapAuthError(FirebaseAuthException e) => switch (e.code) {
    'invalid-phone-number' => const ValidationException('invalid-phone'),
    'invalid-verification-code' => const ValidationException('invalid-code'),
    'session-expired' || 'code-expired' => const ValidationException('expired-code'),
    'too-many-requests' || 'quota-exceeded' => const ValidationException('too-many-requests'),
    'web-context-canceled' || 'canceled' || 'user-cancelled' => const ValidationException('cancelled'),
    'network-request-failed' => NetworkException(e.message),
    _ => ServerException(details: '${e.code}: ${e.message}'),
  };
}
