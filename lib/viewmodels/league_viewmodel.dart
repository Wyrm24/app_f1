import 'package:flutter/material.dart';
import 'package:fantasy_f1_app/data/models/fantasy_team_model.dart';
import 'package:fantasy_f1_app/data/services/league_service.dart';

class LeagueViewModel extends ChangeNotifier {
  final LeagueService _service = LeagueService();

  // État
  bool isLoading = false;
  String? error;
  List<FantasyTeam> leagues = [];

  // Vrai si l'user courant est le créateur d'une ligue
  bool isCreator(FantasyTeam team) =>
      team.league?.creatorId == _service.currentUserId;

  // Chargement de la liste des ligues
  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      leagues = await _service.getUserLeagues();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Quitter ou supprimer une ligue
  Future<void> leaveLeague(String leagueId) async {
    await _service.leaveLeague(leagueId);
    await load();
  }

  // Ordinal helper
  String ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}
