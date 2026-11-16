import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/domain/commune.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/weather_repositories.dart';
import '../domain/weather.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  if (ref.watch(appConfigProvider).useMocks) return MockWeatherRepository();
  return OpenMeteoWeatherRepository();
});

/// Previsions pour la commune suivie.
final weatherProvider = FutureProvider<WeatherForecast>((ref) {
  final name = ref.watch(userCommuneProvider);
  final c = communeByName(name) ?? abidjanCommunes.firstWhere((c) => c.id == 'plateau');
  return ref.watch(weatherRepositoryProvider).fetchForecast(commune: c.name, lat: c.lat, lon: c.lon);
});
