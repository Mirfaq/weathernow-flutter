// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weather_model.dart';

class WeatherService {
  // Get your free key at: https://openweathermap.org -> My API Keys
  static const String _apiKey = '96e2350b2c584d28bf9a15b8f205ae72';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------------------------------------------------------
  // WEATHER API
  // ------------------------------------------------------------------

  Future<WeatherModel> getWeatherByCity(String cityName) async {
    final url = Uri.parse('$_baseUrl/weather?q=$cityName&appid=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final weather = WeatherModel.fromJson(json.decode(response.body));
        _saveSearchToFirestore(weather);
        return weather;
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check the city name.');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Update it in weather_service.dart.');
      } else {
        throw Exception('Request failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Returns up to 8 forecast entries (every 3 hours, next 24h)
  Future<List<ForecastEntry>> getForecast(String cityName) async {
    final url = Uri.parse(
      '$_baseUrl/forecast?q=$cityName&appid=$_apiKey&cnt=8',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> list = jsonData['list'];
        return list
            .map((item) => ForecastEntry.fromJson(item))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ------------------------------------------------------------------
  // FIRESTORE
  // ------------------------------------------------------------------

  // Saves each search to the "searches" collection
  void _saveSearchToFirestore(WeatherModel weather) {
    _firestore
        .collection('searches')
        .add(weather.toFirestoreMap())
        .then((_) {
      // ignore: avoid_print
      print('[Firebase] Saved: ${weather.cityName}');
    }).catchError((e) {
      // ignore: avoid_print
      print('[Firebase] Save error: $e');
    });
  }

  // Returns the 5 most recently searched unique cities
  Future<List<String>> getRecentSearches() async {
    try {
      final snapshot = await _firestore
          .collection('searches')
          .orderBy('searchedAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => doc['cityName'] as String)
          .toSet()
          .take(5)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Returns search count from Firestore (used for Firebase status check)
  Future<int> getSearchCount() async {
  try {
    final snapshot = await _firestore
        .collection('searches')
        .limit(1)
        .get();
    return snapshot.docs.length;
  } catch (e) {
    return -1;
  }
}

  // Returns all search history entries for the history screen
  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    try {
      final snapshot = await _firestore
          .collection('searches')
          .orderBy('searchedAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Deletes a specific search history entry by document ID
  Future<void> deleteSearchEntry(String docId) async {
    await _firestore.collection('searches').doc(docId).delete();
  }

  // Clears all search history
  Future<void> clearSearchHistory() async {
    final snapshot = await _firestore.collection('searches').get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
