import '../../../core/utils/formatters.dart';

class AppUser {
  const AppUser({required this.id, required this.fullName, this.phone, this.email, this.commune, this.createdAt});

  final String id;
  final String fullName;

  /// Format E.164 : +2250700000000
  final String? phone;
  final String? email;

  /// Commune suivie (zone d'habitation). Null tant que l'utilisateur ne l'a pas choisie.
  final String? commune;
  final DateTime? createdAt;

  bool get needsZone => commune == null || commune!.isEmpty;
  String get initials => Fmt.initials(fullName);

  AppUser copyWith({String? fullName, String? phone, String? email, String? commune}) => AppUser(
    id: id,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    commune: commune ?? this.commune,
    createdAt: createdAt,
  );

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'].toString(),
    fullName: (j['full_name'] as String?) ?? '',
    phone: j['phone'] as String?,
    email: j['email'] as String?,
    commune: j['commune'] as String?,
    createdAt: j['created_at'] == null ? null : parseDate(j['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'phone': phone,
    'email': email,
    'commune': commune,
    'created_at': createdAt?.toIso8601String(),
  };
}

/// Etape intermediaire entre l'envoi du SMS et la saisie du code.
class PhoneVerification {
  const PhoneVerification({required this.phone, required this.verificationId, required this.sentAt, this.resendToken, this.fullName});

  final String phone;
  final String verificationId;
  final DateTime sentAt;
  final int? resendToken;

  /// Renseigne lors d'une inscription.
  final String? fullName;

  bool get isSignUp => fullName != null;
}
