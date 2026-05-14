// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/weather_card.dart';
import '../widgets/detail_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/sun_card.dart';
import '../widgets/firebase_status_banner.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherModel? _weather;
  List<ForecastEntry> _forecast = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _recentSearches = [];
  bool _useCelsius = true; // unit toggle
  FirebaseStatus _firebaseStatus = FirebaseStatus.checking;

  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
    _loadWeather('Lahore');
    _loadRecentSearches();
  }

  // Checks if Firestore is reachable and updates the banner
  Future<void> _checkFirebaseStatus() async {
    setState(() => _firebaseStatus = FirebaseStatus.checking);
    final count = await _weatherService.getSearchCount();
    if (mounted) {
      setState(() {
        _firebaseStatus =
            count >= 0 ? FirebaseStatus.connected : FirebaseStatus.error;
      });
    }
  }

  Future<void> _loadWeather(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _weatherService.getWeatherByCity(city),
        _weatherService.getForecast(city),
      ]);

      if (mounted) {
        setState(() {
          _weather = results[0] as WeatherModel;
          _forecast = results[1] as List<ForecastEntry>;
          _isLoading = false;
        });
        _loadRecentSearches();
        // Re-check Firebase status after each search (confirms write worked)
        _checkFirebaseStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRecentSearches() async {
    final searches = await _weatherService.getRecentSearches();
    if (mounted) setState(() => _recentSearches = searches);
  }

  void _onSearch() {
    final city = _searchController.text.trim();
    if (city.isNotEmpty) {
      _loadWeather(city);
      _searchController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  // Converts temperature based on selected unit
  String formatTemp(double celsius) {
    if (_useCelsius) return '${celsius.toStringAsFixed(0)}°C';
    final f = celsius * 9 / 5 + 32;
    return '${f.toStringAsFixed(0)}°F';
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _weather?.gradientColors ??
        ['#0A2342', '#1565C0', '#1E88E5'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient.map(_hexToColor).toList(),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              FirebaseStatusBanner(status: _firebaseStatus),
              _buildSearchBar(),
              if (_recentSearches.isNotEmpty) _buildRecentChips(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.wb_cloudy_outlined, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          const Text(
            'WeatherNow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          // Celsius / Fahrenheit toggle
          GestureDetector(
            onTap: () => setState(() => _useCelsius = !_useCelsius),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _useCelsius ? '°C  |  °F' : '°C  |  °F',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // History button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(
                    weatherService: _weatherService,
                    onCitySelected: _loadWeather,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.history, color: Colors.white70, size: 22),
            tooltip: 'Search History',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
                prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white38),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.white.withOpacity(0.15),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _onSearch,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(11),
                child: Icon(Icons.search, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SizedBox(
        height: 30,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _recentSearches.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final city = _recentSearches[i];
            return GestureDetector(
              onTap: () => _loadWeather(city),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, size: 11, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      city,
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(height: 14),
            Text('Loading weather...', style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, color: Colors.white38, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _loadWeather('Lahore'),
                icon: const Icon(Icons.refresh, color: Colors.white70),
                label: const Text('Try Again', style: TextStyle(color: Colors.white70)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white30),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_weather != null) {
      return RefreshIndicator(
        onRefresh: () => _loadWeather(_weather!.cityName),
        color: Colors.white,
        backgroundColor: Colors.white12,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              WeatherCard(weather: _weather!, useCelsius: _useCelsius, formatTemp: formatTemp),
              const SizedBox(height: 16),
              DetailCard(weather: _weather!),
              const SizedBox(height: 16),
              if (_forecast.isNotEmpty) ...[
                ForecastCard(forecast: _forecast, useCelsius: _useCelsius, formatTemp: formatTemp),
                const SizedBox(height: 16),
              ],
              SunCard(weather: _weather!),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, color: Colors.white.withOpacity(0.2), size: 72),
          const SizedBox(height: 16),
          Text(
            'Search for a city',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
