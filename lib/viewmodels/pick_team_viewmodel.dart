import 'package:flutter/material.dart';
import 'package:fantasy_f1_app/data/services/composition_service.dart';

class PickTeamViewModel extends ChangeNotifier {
  final CompositionService _service = CompositionService();

  final String fantasyTeamId;
  final String raceId;
  final bool isEditing;

  // Pré-sélection pour le mode édition
  final List<Map<String, dynamic>> _preselectedDrivers;
  final List<Map<String, dynamic>> _preselectedTeams;

  PickTeamViewModel({
    required this.fantasyTeamId,
    required this.raceId,
    this.isEditing = false,
    List<Map<String, dynamic>> preselectedDrivers = const [],
    List<Map<String, dynamic>> preselectedTeams = const [],
  }) : _preselectedDrivers = preselectedDrivers,
       _preselectedTeams = preselectedTeams;

  // État chargement
  bool isLoading = true;
  bool isSubmitting = false;
  String? error;

  // Données
  List<Map<String, dynamic>> allDrivers = [];
  List<Map<String, dynamic>> allTeams = [];

  // Sélection
  final List<Map<String, dynamic>> selectedDrivers = [];
  final List<Map<String, dynamic>> selectedTeams = [];

  // Constantes budget
  double get budgetCap => kBudgetCap;
  int get maxDrivers => kMaxDrivers;
  int get maxTeams => kMaxConstructors;

  // Budget calculé
  double get budgetUsed => _service.calcBudgetUsed(
    selectedDrivers: selectedDrivers,
    selectedTeams: selectedTeams,
  );

  double get budgetRemaining => budgetCap - budgetUsed;

  bool canAfford(double price) => budgetRemaining >= price;

  // Sélection complète
  bool get isSelectionComplete =>
      selectedDrivers.length == maxDrivers && selectedTeams.length == maxTeams;

  // Chargement des données
  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getAllDrivers(),
        _service.getAllTeams(),
      ]);
      allDrivers = results[0];
      allTeams = results[1];

      // Pré-sélection en mode édition — on matche par id
      if (isEditing && _preselectedDrivers.isNotEmpty) {
        final ids = _preselectedDrivers.map((d) => d['id']).toSet();
        selectedDrivers
          ..clear()
          ..addAll(allDrivers.where((d) => ids.contains(d['id'])));
      }
      if (isEditing && _preselectedTeams.isNotEmpty) {
        final ids = _preselectedTeams.map((t) => t['id']).toSet();
        selectedTeams
          ..clear()
          ..addAll(allTeams.where((t) => ids.contains(t['id'])));
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Toggle driver
  void toggleDriver(Map<String, dynamic> driver) {
    final isSelected = selectedDrivers.any((d) => d['id'] == driver['id']);
    if (isSelected) {
      selectedDrivers.removeWhere((d) => d['id'] == driver['id']);
    } else if (selectedDrivers.length < maxDrivers &&
        canAfford((driver['price'] as num).toDouble())) {
      selectedDrivers.add(driver);
    }
    notifyListeners();
  }

  // Toggle team
  void toggleTeam(Map<String, dynamic> team) {
    final isSelected = selectedTeams.any((t) => t['id'] == team['id']);
    if (isSelected) {
      selectedTeams.removeWhere((t) => t['id'] == team['id']);
    } else if (selectedTeams.length < maxTeams &&
        canAfford((team['constructor_price'] as num).toDouble())) {
      selectedTeams.add(team);
    }
    notifyListeners();
  }

  // Soumission
  Future<bool> submit() async {
    if (!isSelectionComplete) return false;

    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      await _service.submitComposition(
        fantasyTeamId: fantasyTeamId,
        raceId: raceId,
        driverIds: selectedDrivers.map((d) => d['id'] as String).toList(),
        constructorIds: selectedTeams.map((t) => t['id'] as String).toList(),
      );
      return true;
    } catch (e) {
      error = e.toString();
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // Modification de la compo existante
  Future<bool> update() async {
    if (!isSelectionComplete) return false;

    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      await _service.updateComposition(
        fantasyTeamId: fantasyTeamId,
        raceId: raceId,
        driverIds: selectedDrivers.map((d) => d['id'] as String).toList(),
        constructorIds: selectedTeams.map((t) => t['id'] as String).toList(),
      );
      return true;
    } catch (e) {
      error = e.toString();
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // Suppression de la compo
  Future<bool> delete() async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      await _service.deleteComposition(
        fantasyTeamId: fantasyTeamId,
        raceId: raceId,
      );
      return true;
    } catch (e) {
      error = e.toString();
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // Pré-remplir la sélection depuis une compo existante
  void prefillSelection({
    required List<Map<String, dynamic>> drivers,
    required List<Map<String, dynamic>> teams,
  }) {
    selectedDrivers
      ..clear()
      ..addAll(drivers);
    selectedTeams
      ..clear()
      ..addAll(teams);
    notifyListeners();
  }
}
