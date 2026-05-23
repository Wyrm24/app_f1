import 'package:flutter/material.dart';
import 'package:fantasy_f1_app/data/models/fantasy_team_model.dart';
import 'package:fantasy_f1_app/data/services/league_service.dart';
import 'package:fantasy_f1_app/data/services/composition_service.dart';

class LeagueDetailViewModel extends ChangeNotifier {
  final LeagueService _leagueService = LeagueService();
  final CompositionService _compService = CompositionService();

  // Paramètres de la ligue
  final String leagueId;
  final String fantasyTeamId;

  LeagueDetailViewModel({required this.leagueId, required this.fantasyTeamId});

  // État
  bool isLoading = false;
  String? error;

  List<FantasyTeam> leaderboard = [];
  Map<String, dynamic>? nextRace;
  Map<String, dynamic>? compositionDetails;

  // Deadline dépassée (calculée à partir de nextRace)
  bool get isPastDeadline =>
      nextRace != null && _compService.isDeadlinePassed(nextRace!);

  // Chargement des données
  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _leagueService.getLeagueLeaderboard(leagueId),
        _compService.getNextRace(),
      ]);

      leaderboard = results[0] as List<FantasyTeam>;
      nextRace = results[1] as Map<String, dynamic>?;
      print('[DEBUG] nextRace set to = ${nextRace?['name']}');

      if (nextRace != null) {
        compositionDetails = await _compService.getCompositionWithDetails(
          fantasyTeamId: fantasyTeamId,
          raceId: nextRace!['id'] as String,
        );
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Rechargement après soumission d'une équipe
  Future<void> reload() => load();

  // Suppression de la compo du prochain GP
  Future<void> deleteComposition() async {
    if (nextRace == null) return;
    await _compService.deleteComposition(
      fantasyTeamId: fantasyTeamId,
      raceId: nextRace!['id'] as String,
    );
    compositionDetails = null;
    notifyListeners();
  }
}
