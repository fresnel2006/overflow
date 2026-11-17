import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

enum LocationFailure { serviceDisabled, denied, deniedForever, unavailable }

class LocationException implements Exception {
  const LocationException(this.reason);
  final LocationFailure reason;
}

class GeoPoint {
  const GeoPoint(this.lat, this.lon, {this.accuracyM});
  final double lat;
  final double lon;

  /// Rayon d'incertitude du GPS, en metres (null si inconnu).
  final double? accuracyM;
}

/// Position GPS de l'appareil, avec gestion des autorisations.
class LocationService {
  Future<GeoPoint> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) throw const LocationException(LocationFailure.serviceDisabled);
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) throw const LocationException(LocationFailure.denied);
    if (perm == LocationPermission.deniedForever) throw const LocationException(LocationFailure.deniedForever);
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 15)),
      );
      return GeoPoint(p.latitude, p.longitude, accuracyM: p.accuracy);
    } catch (_) {
      // Repli sur la derniere position connue (utile avec un GPS lent).
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return GeoPoint(last.latitude, last.longitude, accuracyM: last.accuracy);
      throw const LocationException(LocationFailure.unavailable);
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
