// lib/widgets/forecast_card.dart (SunCard)
// Sunrise / Sunset card with a visual arc progress bar

import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class SunCard extends StatelessWidget {
  final WeatherModel weather;

  const SunCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    // Calculate how far through the day we are (0.0 to 1.0)
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final totalDayLength = weather.sunset - weather.sunrise;
    double progress = totalDayLength > 0
        ? ((now - weather.sunrise) / totalDayLength).clamp(0.0, 1.0)
        : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'SUN',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              // Arc progress
              SizedBox(
                height: 80,
                child: CustomPaint(
                  painter: _SunArcPainter(progress: progress),
                  size: const Size(double.infinity, 80),
                ),
              ),
              const SizedBox(height: 16),
              // Sunrise and Sunset times
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sunTime(
                    icon: Icons.wb_twilight,
                    label: 'Sunrise',
                    time: weather.sunriseTime,
                    color: const Color(0xFFFFCC80),
                  ),
                  Text(
                    weather.isDaytime ? 'Daytime' : 'Nighttime',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                  _sunTime(
                    icon: Icons.nightlight_round,
                    label: 'Sunset',
                    time: weather.sunsetTime,
                    color: const Color(0xFF90CAF9),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sunTime({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11)),
      ],
    );
  }
}

// Custom painter draws a half-circle arc with a sun indicator dot
class _SunArcPainter extends CustomPainter {
  final double progress;

  _SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    // Background arc (full half circle)
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159, // start at left (180 deg)
      3.14159, // sweep to right (360 deg)
      false,
      bgPaint,
    );

    // Progress arc
    final fgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFCC80), Color(0xFFFF8F00)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159,
      3.14159 * progress,
      false,
      fgPaint,
    );

    // Sun dot at current position
    final angle = 3.14159 + 3.14159 * progress;
    final dotX = center.dx + radius * (progress < 0.01 ? -1 : (progress > 0.99 ? 1 : 1)) * (angle > 3.14159 * 1.5 ? 1 : -1).toDouble();
    // Simpler: compute dot position from angle
    final sunX = center.dx + radius * -1 * (1 - 2 * progress); // approx
    final sunY = center.dy - radius * (4 * progress * (1 - progress)); // parabola approx

    final dotPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(sunX, sunY), 8, dotPaint);

    // Glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX, sunY), 14, glowPaint);
  }

  @override
  bool shouldRepaint(_SunArcPainter old) => old.progress != progress;
}
