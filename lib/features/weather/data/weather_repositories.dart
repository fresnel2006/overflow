import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../../../core/mock/mock_latency.dart';
import '../../../core/network/api_client.dart';
import '../domain/weather.dart';

/// Previsions fictives typiques de la saison des pluies a Abidjan.
class MockWeatherRepository implements WeatherRepository {
  @override
  Future<WeatherForecast> fetchForecast({required String commune, required double lat, required double lon}) async {
    await mockDelay();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    const hourlyConditions = [WeatherCondition.cloudy, WeatherCondition.rain, WeatherCondition.rain, WeatherCondition.cloudy];
    const hourlyTemps = [27.0, 26.0, 25.0, 25.0];
    const days = [
      (WeatherCondition.rain, 25.0, 29.0, 82),
      (WeatherCondition.rain, 24.0, 28.0, 78),
      (WeatherCondition.cloudy, 25.0, 29.0, 71),
      (WeatherCondition.clear, 25.0, 30.0, 68),
      (WeatherCondition.cloudy, 25.0, 31.0, 64),
    ];
    return WeatherForecast(
      commune: commune,
      today: DailyForecast(date: today, minC: 26, maxC: 30, condition: WeatherCondition.rain, rainProbabilityPct: 85),
      confidencePct: 87,
      hourly: [
        for (var i = 0; i < 4; i++) HourlyForecast(time: firstHour.add(Duration(hours: i * 3)), tempC: hourlyTemps[i], condition: hourlyConditions[i]),
      ],
      daily: [
        for (var i = 0; i < days.length; i++)
          DailyForecast(date: today.add(Duration(days: i + 1)), condition: days[i].$1, minC: days[i].$2, maxC: days[i].$3, rainProbabilityPct: days[i].$4),
      ],
      updatedAt: now,
    );
  }
}

/// Previsions reelles via Open-Meteo (gratuit, sans cle). Remplacable par une route FastAPI
/// si le backend agrege ses propres donnees (SODEXAM, modeles locaux).
class OpenMeteoWeatherRepository implements WeatherRepository {
  OpenMeteoWeatherRepository({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://api.open-meteo.com/v1', connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 15)));

  final Dio _dio;

  @override
  Future<WeatherForecast> fetchForecast({required String commune, required double lat, required double lon}) async {
    final Map<String, dynamic> j;
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'hourly': 'temperature_2m,weather_code',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
          'timezone': 'Africa/Abidjan',
          'forecast_days': 6,
        },
      );
      j = r.data!;
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }

    final daily = j['daily'] as Map<String, dynamic>;
    final dates = (daily['time'] as List).cast<String>();
    final days = [
      for (var i = 0; i < dates.length; i++)
        DailyForecast(
          date: DateTime.parse(dates[i]),
          condition: WeatherCondition.fromWmo((daily['weather_code'][i] as num).toInt()),
          minC: (daily['temperature_2m_min'][i] as num).toDouble(),
          maxC: (daily['temperature_2m_max'][i] as num).toDouble(),
          rainProbabilityPct: ((daily['precipitation_probability_max'][i] as num?) ?? 0).toInt(),
        ),
    ];

    final hourly = j['hourly'] as Map<String, dynamic>;
    final times = (hourly['time'] as List).cast<String>();
    final now = DateTime.now();
    final upcoming = <HourlyForecast>[];
    for (var i = 0; i < times.length && upcoming.length < 4; i++) {
      final t = DateTime.parse(times[i]);
      // Un point toutes les 3 heures a partir de l'heure suivante.
      if (t.isAfter(now) && (upcoming.isEmpty || t.difference(upcoming.last.time).inHours >= 3)) {
        upcoming.add(HourlyForecast(time: t, tempC: (hourly['temperature_2m'][i] as num).toDouble(), condition: WeatherCondition.fromWmo((hourly['weather_code'][i] as num).toInt())));
      }
    }

    final today = days.first;
    // Open-Meteo ne fournit pas d'indice de confiance : on l'estime a partir de la nettete de la
    // probabilite de pluie (proche de 0 ou de 100 % = prevision plus sure).
    final confidence = (55 + (today.rainProbabilityPct - 50).abs() * 0.85).round();
    return WeatherForecast(
      commune: commune,
      today: today,
      confidencePct: math.min(98, confidence),
      hourly: upcoming,
      daily: days.skip(1).take(5).toList(),
      updatedAt: now,
    );
  }
}
