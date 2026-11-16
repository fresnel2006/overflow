import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/weather.dart';

extension WeatherStyle on WeatherCondition {
  IconData get icon => switch (this) {
    WeatherCondition.clear => LucideIcons.sun,
    WeatherCondition.partlyCloudy => LucideIcons.cloudSun,
    WeatherCondition.cloudy => LucideIcons.cloud,
    WeatherCondition.drizzle => LucideIcons.cloudDrizzle,
    WeatherCondition.rain => LucideIcons.cloudRain,
    WeatherCondition.heavyRain => LucideIcons.cloudRainWind,
    WeatherCondition.storm => LucideIcons.cloudLightning,
  };

  String label(AppLocalizations l) => switch (this) {
    WeatherCondition.clear => l.weatherClear,
    WeatherCondition.partlyCloudy => l.weatherPartlyCloudy,
    WeatherCondition.cloudy => l.weatherCloudy,
    WeatherCondition.drizzle => l.weatherDrizzle,
    WeatherCondition.rain => l.weatherRain,
    WeatherCondition.heavyRain => l.weatherHeavyRain,
    WeatherCondition.storm => l.weatherStorm,
  };
}
