// Driver ViewModel

import 'package:flutter/material.dart';
import 'package:fantasy_f1_app/data/models/driver_detail_model.dart';
import 'package:fantasy_f1_app/data/models/driver_performance_model.dart';

class DriverViewModel extends ChangeNotifier {
  DriverModel? _driver;
  bool _isLoading = false;
  String? _error;

  DriverModel? get driver => _driver;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock data — remplacer par un vrai appel API
  static final Map<String, DriverModel> _mockDrivers = {
    'Max Verstappen': DriverModel(
      name: 'Max Verstappen',
      team: 'Red Bull Racing',
      nationality: 'Néerlandais',
      flagEmoji: '🇳🇱',
      totalPoints: 465,
      currentRanking: 1,
      wins: 6,
      podiums: 8,
      lastPerformances: [
        DriverPerformanceModel(
          raceName: 'BHR',
          raceFlag: '🇧🇭',
          position: 1,
          points: 25,
        ),
        DriverPerformanceModel(
          raceName: 'SAU',
          raceFlag: '🇸🇦',
          position: 2,
          points: 18,
        ),
        DriverPerformanceModel(
          raceName: 'AUS',
          raceFlag: '🇦🇺',
          position: 3,
          points: 15,
        ),
        DriverPerformanceModel(
          raceName: 'JPN',
          raceFlag: '🇯🇵',
          position: 1,
          points: 26,
        ),
        DriverPerformanceModel(
          raceName: 'CHN',
          raceFlag: '🇨🇳',
          position: 1,
          points: 25,
        ),
        DriverPerformanceModel(
          raceName: 'MIA',
          raceFlag: '🇺🇸',
          position: 4,
          points: 12,
        ),
        DriverPerformanceModel(
          raceName: 'ITA',
          raceFlag: '🇮🇹',
          position: 2,
          points: 18,
        ),
        DriverPerformanceModel(
          raceName: 'MON',
          raceFlag: '🇲🇨',
          position: 1,
          points: 25,
        ),
        DriverPerformanceModel(
          raceName: 'ESP',
          raceFlag: '🇪🇸',
          position: 3,
          points: 15,
        ),
        DriverPerformanceModel(
          raceName: 'CAN',
          raceFlag: '🇨🇦',
          position: 1,
          points: 25,
        ),
      ],
    ),
    'Lewis Hamilton': DriverModel(
      name: 'Lewis Hamilton',
      team: 'Ferrari',
      nationality: 'Britannique',
      flagEmoji: '🇬🇧',
      totalPoints: 405,
      currentRanking: 3,
      wins: 4,
      podiums: 7,
      lastPerformances: [
        DriverPerformanceModel(
          raceName: 'BHR',
          raceFlag: '🇧🇭',
          position: 3,
          points: 15,
        ),
        DriverPerformanceModel(
          raceName: 'SAU',
          raceFlag: '🇸🇦',
          position: 1,
          points: 25,
        ),
        DriverPerformanceModel(
          raceName: 'AUS',
          raceFlag: '🇦🇺',
          position: 2,
          points: 18,
        ),
        DriverPerformanceModel(
          raceName: 'JPN',
          raceFlag: '🇯🇵',
          position: 4,
          points: 12,
        ),
        DriverPerformanceModel(
          raceName: 'CHN',
          raceFlag: '🇨🇳',
          position: 3,
          points: 15,
        ),
        DriverPerformanceModel(
          raceName: 'MIA',
          raceFlag: '🇺🇸',
          position: 1,
          points: 26,
        ),
        DriverPerformanceModel(
          raceName: 'ITA',
          raceFlag: '🇮🇹',
          position: 5,
          points: 10,
        ),
        DriverPerformanceModel(
          raceName: 'MON',
          raceFlag: '🇲🇨',
          position: 2,
          points: 18,
        ),
        DriverPerformanceModel(
          raceName: 'ESP',
          raceFlag: '🇪🇸',
          position: 1,
          points: 25,
        ),
        DriverPerformanceModel(
          raceName: 'CAN',
          raceFlag: '🇨🇦',
          position: 3,
          points: 15,
        ),
      ],
    ),
    'Ferrari': DriverModel(
      name: 'Ferrari',
      team: 'Constructeur',
      nationality: 'Italien',
      flagEmoji: '🇮🇹',
      totalPoints: 578,
      currentRanking: 1,
      wins: 7,
      podiums: 12,
      lastPerformances: [
        DriverPerformanceModel(
          raceName: 'BHR',
          raceFlag: '🇧🇭',
          position: 2,
          points: 43,
        ),
        DriverPerformanceModel(
          raceName: 'SAU',
          raceFlag: '🇸🇦',
          position: 1,
          points: 44,
        ),
        DriverPerformanceModel(
          raceName: 'AUS',
          raceFlag: '🇦🇺',
          position: 1,
          points: 43,
        ),
        DriverPerformanceModel(
          raceName: 'JPN',
          raceFlag: '🇯🇵',
          position: 3,
          points: 30,
        ),
        DriverPerformanceModel(
          raceName: 'CHN',
          raceFlag: '🇨🇳',
          position: 2,
          points: 40,
        ),
        DriverPerformanceModel(
          raceName: 'MIA',
          raceFlag: '🇺🇸',
          position: 1,
          points: 44,
        ),
        DriverPerformanceModel(
          raceName: 'ITA',
          raceFlag: '🇮🇹',
          position: 2,
          points: 36,
        ),
        DriverPerformanceModel(
          raceName: 'MON',
          raceFlag: '🇲🇨',
          position: 1,
          points: 43,
        ),
        DriverPerformanceModel(
          raceName: 'ESP',
          raceFlag: '🇪🇸',
          position: 2,
          points: 40,
        ),
        DriverPerformanceModel(
          raceName: 'CAN',
          raceFlag: '🇨🇦',
          position: 3,
          points: 35,
        ),
      ],
    ),
    'Red Bull': DriverModel(
      name: 'Red Bull',
      team: 'Constructeur',
      nationality: 'Autrichien',
      flagEmoji: '🇦🇹',
      totalPoints: 557,
      currentRanking: 2,
      wins: 5,
      podiums: 10,
      lastPerformances: [
        DriverPerformanceModel(
          raceName: 'BHR',
          raceFlag: '🇧🇭',
          position: 1,
          points: 44,
        ),
        DriverPerformanceModel(
          raceName: 'SAU',
          raceFlag: '🇸🇦',
          position: 2,
          points: 40,
        ),
        DriverPerformanceModel(
          raceName: 'AUS',
          raceFlag: '🇦🇺',
          position: 2,
          points: 36,
        ),
        DriverPerformanceModel(
          raceName: 'JPN',
          raceFlag: '🇯🇵',
          position: 1,
          points: 44,
        ),
        DriverPerformanceModel(
          raceName: 'CHN',
          raceFlag: '🇨🇳',
          position: 1,
          points: 44,
        ),
        DriverPerformanceModel(
          raceName: 'MIA',
          raceFlag: '🇺🇸',
          position: 3,
          points: 35,
        ),
        DriverPerformanceModel(
          raceName: 'ITA',
          raceFlag: '🇮🇹',
          position: 1,
          points: 43,
        ),
        DriverPerformanceModel(
          raceName: 'MON',
          raceFlag: '🇲🇨',
          position: 2,
          points: 40,
        ),
        DriverPerformanceModel(
          raceName: 'ESP',
          raceFlag: '🇪🇸',
          position: 3,
          points: 36,
        ),
        DriverPerformanceModel(
          raceName: 'CAN',
          raceFlag: '🇨🇦',
          position: 1,
          points: 44,
        ),
      ],
    ),
  };

  Future<void> loadDriver(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simule un délai réseau
    await Future.delayed(const Duration(milliseconds: 400));

    final result = _mockDrivers[name];

    if (result != null) {
      _driver = result;
    } else {
      _error = 'Pilote introuvable';
    }

    _isLoading = false;
    notifyListeners();
  }
}
