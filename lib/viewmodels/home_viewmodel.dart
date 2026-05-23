import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantasy_f1_app/data/models/fantasy_team_model.dart';
import 'package:fantasy_f1_app/data/services/league_service.dart';

class HomeViewModel extends ChangeNotifier {
  final LeagueService _leagueService = LeagueService();
  final _supabase = Supabase.instance.client;

  // État
  bool isLoading = false;
  String? error;

  List<FantasyTeam> leagues = [];
  List<Map<String, dynamic>> topDrivers = [];
  List<Map<String, dynamic>> topTeams = [];
  int racesCompleted = 0;
  Map<String, dynamic>? nextRace;

  // Chargement initial
  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await Future.wait([_loadLeagues(), _loadRaces(), _loadPerformers()]);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLeagues() async {
    leagues = await _leagueService.getUserLeagues();
  }

  Future<void> _loadRaces() async {
    // Courses complétées
    final completedRaces = await _supabase
        .from('races')
        .select('id')
        .eq('status', 'completed');
    racesCompleted = (completedRaces as List).length;

    // Prochain GP
    nextRace = await _supabase
        .from('races')
        .select()
        .eq('status', 'upcoming')
        .order('race_date', ascending: true)
        .limit(1)
        .maybeSingle();
  }

  Future<void> _loadPerformers() async {
    final driversRaw = await _supabase
        .from('drivers')
        .select(
          'first_name, last_name, headshot_url, rating_history, teams(color_hex)',
        )
        .not('rating_history', 'eq', '{}');

    final teamsRaw = await _supabase
        .from('teams')
        .select('name, color_hex, rating_history')
        .not('rating_history', 'eq', '{}');

    final allDrivers = List<Map<String, dynamic>>.from(driversRaw as List);
    final allTeams = List<Map<String, dynamic>>.from(teamsRaw as List);

    allDrivers.sort(
      (a, b) => _lastNScore(
        b['rating_history'] as List?,
      ).compareTo(_lastNScore(a['rating_history'] as List?)),
    );

    allTeams.sort(
      (a, b) => _lastNScore(
        b['rating_history'] as List?,
      ).compareTo(_lastNScore(a['rating_history'] as List?)),
    );

    topDrivers = allDrivers.take(3).toList();
    topTeams = allTeams.take(3).toList();
  }

  // Score des n dernières courses
  double _lastNScore(List? history) {
    if (history == null || history.isEmpty) return 0;
    final recent = history.length > racesCompleted
        ? history.sublist(history.length - racesCompleted)
        : history;
    return recent.fold(0.0, (sum, val) => sum + (val as num).toDouble());
  }

  // Score pour un item donné (utilisé dans la View)
  double scoreFor(List? history) => _lastNScore(history);
}
