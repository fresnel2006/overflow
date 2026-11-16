enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  drizzle,
  rain,
  heavyRain,
  storm;

  /// Codes meteo WMO (Open-Meteo).
  static WeatherCondition fromWmo(int code) => switch (code) {
    0 => WeatherCondition.clear,
    1 || 2 => WeatherCondition.partlyCloudy,
    3 || 45 || 48 => WeatherCondition.cloudy,
    51 || 53 || 55 || 56 || 57 => WeatherCondition.drizzle,
    61 || 63 || 66 || 80 || 81 => WeatherCondition.rain,
    65 || 67 || 82 => WeatherCondition.heavyRain,
    95 || 96 || 99 => WeatherCondition.storm,
    _ => WeatherCondition.cloudy,
  };

  static WeatherCondition fromName(String? v) => WeatherCondition.values.where((e) => e.name == v).firstOrNull ?? WeatherCondition.cloudy;

  bool get isRainy => index >= WeatherCondition.drizzle.index;
}

class HourlyForecast {
  const HourlyForecast({required this.time, required this.tempC, required this.condition});
  final DateTime time;
  final double tempC;
  final WeatherCondition condition;
}

class DailyForecast {
  const DailyForecast({required this.date, required this.minC, required this.maxC, required this.condition, required this.rainProbabilityPct});
  final DateTime date;
  final double minC;
  final double maxC;
  final WeatherCondition condition;
  final int rainProbabilityPct;
}

class WeatherForecast {
  const WeatherForecast({
    required this.commune,
    required this.today,
    required this.confidencePct,
    required this.hourly,
    required this.daily,
    required this.updatedAt,
  });

  final String commune;
  final DailyForecast today;

  /// Indice de confiance de la prevision du jour (0 a 100).
  final int confidencePct;
  final List<HourlyForecast> hourly;

  /// Prochains jours (sans aujourd'hui).
  final List<DailyForecast> daily;
  final DateTime updatedAt;
}

abstract interface class WeatherRepository {
  Future<WeatherForecast> fetchForecast({required String commune, required double lat, required double lon});
}
