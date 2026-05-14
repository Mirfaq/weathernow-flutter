// lib/models/weather_model.dart

class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int windDegree;
  final String description;
  final String icon;
  final int visibility;
  final int pressure;
  final int sunrise;   // Unix timestamp
  final int sunset;    // Unix timestamp
  final int cloudiness; // percentage
  final DateTime fetchedAt;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDegree,
    required this.description,
    required this.icon,
    required this.visibility,
    required this.pressure,
    required this.sunrise,
    required this.sunset,
    required this.cloudiness,
    required this.fetchedAt,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Unknown',
      country: json['sys']?['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDegree: (json['wind']?['deg'] ?? 0) as int,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      visibility: (json['visibility'] as num).toInt(),
      pressure: json['main']['pressure'] as int,
      sunrise: (json['sys']?['sunrise'] ?? 0) as int,
      sunset: (json['sys']?['sunset'] ?? 0) as int,
      cloudiness: (json['clouds']?['all'] ?? 0) as int,
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'cityName': cityName,
      'country': country,
      'temperatureCelsius': tempCelsius.toStringAsFixed(1),
      'humidity': humidity,
      'windSpeed': windSpeed,
      'description': description,
      'icon': icon,
      'pressure': pressure,
      'searchedAt': fetchedAt.toIso8601String(),
    };
  }

  // Kelvin to Celsius
  double get tempCelsius => temperature - 273.15;
  double get feelsLikeCelsius => feelsLike - 273.15;
  double get tempMinCelsius => tempMin - 273.15;
  double get tempMaxCelsius => tempMax - 273.15;

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  // Wind direction as a compass label
  String get windDirection {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[((windDegree + 22.5) / 45).floor() % 8];
  }

  // Sunrise and sunset as formatted time strings
  String get sunriseTime {
    final dt = DateTime.fromMillisecondsSinceEpoch(sunrise * 1000);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String get sunsetTime {
    final dt = DateTime.fromMillisecondsSinceEpoch(sunset * 1000);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Whether it is currently daytime
  bool get isDaytime {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= sunrise && now <= sunset;
  }

  // Background gradient based on weather condition and time
  List<String> get gradientColors {
    final code = icon.replaceAll('d', '').replaceAll('n', '');
    if (!isDaytime) return ['#0A0A2A', '#1A1A4E', '#2D2D7A'];
    switch (code) {
      case '01': return ['#1565C0', '#1E88E5', '#42A5F5']; // clear sky
      case '02':
      case '03':
      case '04': return ['#37474F', '#546E7A', '#78909C']; // clouds
      case '09':
      case '10': return ['#1A237E', '#283593', '#3949AB']; // rain
      case '11': return ['#212121', '#37474F', '#4A148C']; // thunderstorm
      case '13': return ['#546E7A', '#78909C', '#B0BEC5']; // snow
      case '50': return ['#455A64', '#607D8B', '#78909C']; // mist
      default:   return ['#0D47A1', '#1565C0', '#1976D2'];
    }
  }
}

// Model for 5-day forecast entries
class ForecastEntry {
  final DateTime dateTime;
  final double tempCelsius;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  ForecastEntry({
    required this.dateTime,
    required this.tempCelsius,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory ForecastEntry.fromJson(Map<String, dynamic> json) {
    final tempK = (json['main']['temp'] as num).toDouble();
    return ForecastEntry(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      tempCelsius: tempK - 273.15,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  String get dayLabel {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dateTime.weekday % 7];
  }

  String get timeLabel {
    return '${dateTime.hour.toString().padLeft(2, '0')}:00';
  }
}
