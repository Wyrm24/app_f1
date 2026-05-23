import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Modèle météo
class WeatherData {
  final double airTemp;
  final double trackTemp;
  final double windSpeed;
  final int precipitationProbability;
  final int weatherCode;

  const WeatherData({
    required this.airTemp,
    required this.trackTemp,
    required this.windSpeed,
    required this.precipitationProbability,
    required this.weatherCode,
  });

  String get description {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 67) return 'Rainy';
    if (weatherCode <= 77) return 'Snowy';
    return 'Stormy';
  }

  IconData get icon {
    if (weatherCode == 0) return Icons.wb_sunny_rounded;
    if (weatherCode <= 3) return Icons.cloud_queue_rounded;
    if (weatherCode <= 67) return Icons.umbrella_rounded;
    return Icons.thunderstorm_rounded;
  }
}

class GpDetailViewModel extends ChangeNotifier {
  bool isLoadingWeather = false;
  String? error;

  Map<String, dynamic>? race;
  WeatherData? weather;

  // Reçoit la race directement depuis home_page — pas de requête Supabase
  void initWithRace(Map<String, dynamic> raceData) {
    race = raceData;
    notifyListeners();
    _loadWeather();
  }

  // Météo en arrière-plan
  Future<void> _loadWeather() async {
    final lat = race?['latitude'];
    final lng = race?['longitude'];
    if (lat == null || lng == null || lat == 0 || lng == 0) return;

    isLoadingWeather = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lng'
        '&current=temperature_2m,surface_temperature,precipitation_probability,weathercode,windspeed_10m'
        '&timezone=auto',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>;

      weather = WeatherData(
        airTemp: (current['temperature_2m'] as num).toDouble(),
        trackTemp: (current['surface_temperature'] as num).toDouble(),
        windSpeed: (current['windspeed_10m'] as num).toDouble(),
        precipitationProbability: current['precipitation_probability'] as int,
        weatherCode: current['weathercode'] as int,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingWeather = false;
      notifyListeners();
    }
  }

  // Sessions depuis sessions_time jsonb
  List<Map<String, String>> get sessions {
    if (race == null) return [];
    final raw = race!['sessions_time'];
    if (raw == null) return [];

    final Map<String, dynamic> map = raw is String
        ? jsonDecode(raw)
        : raw as Map<String, dynamic>;

    final labels = {
      'fp1': 'Practice 1',
      'fp2': 'Practice 2',
      'fp3': 'Practice 3',
      'sprint_quali': 'Sprint Quali',
      'sprint': 'Sprint',
      'quali': 'Qualifying',
      'race': 'Race',
    };

    return labels.entries
        .where((e) => map.containsKey(e.key) && map[e.key] != null)
        .map((e) {
          final dt = DateTime.parse(map[e.key] as String).toLocal();
          return {
            'label': e.value,
            'day': _formatDay(dt),
            'time': _formatTime(dt),
            'key': e.key,
          };
        })
        .toList();
  }

  // Getters circuit
  String get circuitLength {
    final km = race?['circuit_length_km'];
    if (km == null) return '—';
    return '${(km as num).toStringAsFixed(3)} km';
  }

  int? get laps => race?['laps'] as int?;

  String get raceDateFormatted {
    if (race == null) return '';
    final dt = DateTime.parse(race!['race_date'] as String).toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  DateTime? get raceDateTime {
    if (race == null) return null;
    return DateTime.parse(race!['race_date'] as String).toLocal();
  }

  String _formatDay(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${h}h$m';
  }
}
