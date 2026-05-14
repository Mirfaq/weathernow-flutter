// lib/widgets/weather_card.dart

import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final bool useCelsius;
  final String Function(double) formatTemp;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.useCelsius,
    required this.formatTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('weatherCard'),
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // City name + country
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                weather.country.isNotEmpty
                    ? '${weather.cityName}, ${weather.country}'
                    : weather.cityName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            weather.description.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 12,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 20),

          // Weather icon
          Image.network(
            weather.iconUrl,
            width: 90,
            height: 90,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.wb_sunny_outlined,
              color: Colors.white70,
              size: 80,
            ),
          ),
          const SizedBox(height: 8),

          // Main temperature
          Text(
            formatTemp(weather.tempCelsius),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.w200,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Feels like ${formatTemp(weather.feelsLikeCelsius)}',
            style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 14),
          ),

          const SizedBox(height: 22),
          Divider(color: Colors.white.withOpacity(0.12)),
          const SizedBox(height: 14),

          // Low / High + cloudiness
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(
                icon: Icons.arrow_downward,
                label: 'Low',
                value: formatTemp(weather.tempMinCelsius),
                color: const Color(0xFF90CAF9),
              ),
              _dividerV(),
              _statItem(
                icon: Icons.arrow_upward,
                label: 'High',
                value: formatTemp(weather.tempMaxCelsius),
                color: const Color(0xFFFFCC80),
              ),
              _dividerV(),
              _statItem(
                icon: Icons.cloud_outlined,
                label: 'Clouds',
                value: '${weather.cloudiness}%',
                color: const Color(0xFFB0BEC5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ],
    );
  }

  Widget _dividerV() {
    return Container(width: 1, height: 36, color: Colors.white.withOpacity(0.12));
  }
}
