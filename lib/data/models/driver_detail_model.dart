// Driver Model

import 'package:fantasy_f1_app/data/models/driver_performance_model.dart';

class DriverModel {
  final String name;
  final String team;
  final String nationality;
  final String flagEmoji;
  final int totalPoints;
  final int currentRanking;
  final int wins;
  final int podiums;
  final List<DriverPerformanceModel> lastPerformances;

  const DriverModel({
    required this.name,
    required this.team,
    required this.nationality,
    required this.flagEmoji,
    required this.totalPoints,
    required this.currentRanking,
    required this.wins,
    required this.podiums,
    required this.lastPerformances,
  });
}
