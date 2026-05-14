// lib/widgets/forecast_card.dart
// Horizontal scrolling 24-hour forecast

import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class ForecastCard extends StatelessWidget {
  final List<ForecastEntry> forecast;
  final bool useCelsius;
  final String Function(double) formatTemp;

  const ForecastCard({
    super.key,
    required this.forecast,
    required this.useCelsius,
    required this.formatTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            '24-HOUR FORECAST',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            itemCount: forecast.length,
            itemBuilder: (context, i) {
              final entry = forecast[i];
              final isFirst = i == 0;
              return _ForecastItem(
                entry: entry,
                isNow: isFirst,
                formatTemp: formatTemp,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ForecastItem extends StatelessWidget {
  final ForecastEntry entry;
  final bool isNow;
  final String Function(double) formatTemp;

  const _ForecastItem({
    required this.entry,
    required this.isNow,
    required this.formatTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isNow ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isNow
            ? Border.all(color: Colors.white.withOpacity(0.25))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            isNow ? 'Now' : entry.timeLabel,
            style: TextStyle(
              color: isNow ? Colors.white : Colors.white54,
              fontSize: 12,
              fontWeight: isNow ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Image.network(
            entry.iconUrl,
            width: 36,
            height: 36,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.wb_sunny_outlined, color: Colors.white54, size: 28),
          ),
          Text(
            formatTemp(entry.tempCelsius),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
