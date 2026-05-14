// lib/widgets/detail_card.dart

import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class DetailCard extends StatelessWidget {
  final WeatherModel weather;

  const DetailCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return _section(
      title: 'Details',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: [
          _tile(Icons.water_drop_outlined, 'Humidity', '${weather.humidity}%', const Color(0xFF64B5F6)),
          _tile(Icons.air, 'Wind', '${weather.windSpeed.toStringAsFixed(1)} m/s  ${weather.windDirection}', const Color(0xFF81C784)),
          _tile(Icons.visibility_outlined, 'Visibility', '${(weather.visibility / 1000).toStringAsFixed(1)} km', const Color(0xFFBA68C8)),
          _tile(Icons.compress, 'Pressure', '${weather.pressure} hPa', const Color(0xFFFFB74D)),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11)),
        ],
      ),
    );
  }
}

Widget _section({required String title, required Widget child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child,
    ],
  );
}
