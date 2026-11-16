import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/headers.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/weather.dart';
import 'weather_providers.dart';
import 'weather_style.dart';

/// Meteo de la commune suivie (maquette 12).
class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          PageHeader(title: l.weatherTitle),
          Expanded(
            child: AsyncValueView(
              value: ref.watch(weatherProvider),
              onRetry: () => ref.invalidate(weatherProvider),
              data: (w) => RefreshIndicator(
                onRefresh: () => ref.refresh(weatherProvider.future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  children: [
                    _TodayCard(forecast: w),
                    const SizedBox(height: 14),
                    if (w.hourly.isNotEmpty) _HourlyCard(hours: w.hourly),
                    if (w.today.condition.isRainy || w.daily.take(2).any((d) => d.rainProbabilityPct >= 70)) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.umbrella, size: 20, color: AppColors.warningText),
                            const SizedBox(width: 12),
                            Expanded(child: Text(l.weatherRainAdvice, style: AppText.caption.copyWith(color: AppColors.warningText, fontWeight: FontWeight.w500, fontSize: 12.5))),
                          ],
                        ),
                      ),
                    ],
                    SectionTitle(l.weatherForecast5),
                    AppCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          for (final (i, d) in w.daily.indexed) ...[
                            if (i > 0) const Divider(indent: 16, endIndent: 16),
                            _DayRow(day: d),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('${w.commune}, Abidjan · ${l.commonUpdatedAt(Fmt.time(w.updatedAt))}', textAlign: TextAlign.center, style: AppText.caption),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.forecast});
  final WeatherForecast forecast;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = forecast.today;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFDCEBFE), Color(0xFFBBD5FA)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.weatherToday, style: AppText.label.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text('${t.minC.round()}° / ${t.maxC.round()}°', style: AppText.display.copyWith(fontSize: 38, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 2),
                    Text(t.condition.label(l), style: AppText.body.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Icon(t.condition.icon, size: 84, color: AppColors.primary.withValues(alpha: 0.75)),
            ],
          ),
          const SizedBox(height: 16),
          Text(l.weatherConfidence(forecast.confidencePct), style: AppText.label.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: forecast.confidencePct / 100,
              minHeight: 8,
              color: AppColors.primary,
              backgroundColor: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyCard extends StatelessWidget {
  const _HourlyCard({required this.hours});
  final List<HourlyForecast> hours;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    child: Row(
      children: [
        for (final h in hours)
          Expanded(
            child: Column(
              children: [
                Text(Fmt.hour(h.time), style: AppText.caption.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Icon(h.condition.icon, size: 24, color: AppColors.primary),
                const SizedBox(height: 8),
                Text('${h.tempC.round()}°', style: AppText.title.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    ),
  );
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});
  final DailyForecast day;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        SizedBox(width: 48, child: Text(Fmt.dayShort(day.date), style: AppText.title.copyWith(fontWeight: FontWeight.w500))),
        Icon(day.condition.icon, size: 22, color: AppColors.primary),
        const Spacer(),
        Text('${day.minC.round()}° / ${day.maxC.round()}°', style: AppText.body.copyWith(fontWeight: FontWeight.w500)),
        const Spacer(),
        const Icon(LucideIcons.droplet, size: 15, color: AppColors.primary),
        const SizedBox(width: 4),
        SizedBox(
          width: 38,
          child: Text('${day.rainProbabilityPct}%', textAlign: TextAlign.right, style: AppText.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}
