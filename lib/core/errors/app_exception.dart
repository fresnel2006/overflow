/// Erreurs metier remontees aux ecrans. Les messages affiches sont traduits dans la couche presentation.
sealed class AppException implements Exception {
  const AppException([this.details]);
  final String? details;

  @override
  String toString() => '$runtimeType${details == null ? '' : ': $details'}';
}

/// Pas de connexion, delai depasse, serveur injoignable.
class NetworkException extends AppException {
  const NetworkException([super.details]);
}

/// Session expiree ou absente.
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.details]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.details]);
}

/// Donnees saisies refusees (code OTP invalide, champ manquant...).
class ValidationException extends AppException {
  const ValidationException(this.code, [String? details]) : super(details);
  final String code;
}

class ServerException extends AppException {
  const ServerException({this.statusCode, String? details}) : super(details);
  final int? statusCode;
}

/// Fonction non disponible dans la configuration courante (ex: Firebase non configure).
class UnavailableException extends AppException {
  const UnavailableException([super.details]);
}
