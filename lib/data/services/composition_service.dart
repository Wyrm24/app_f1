import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantasy_f1_app/data/models/composition_model.dart';

const double kBudgetCap = 100.0; // 100M
const int kMaxDrivers = 3;
const int kMaxConstructors = 2;

class CompositionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //Course en cours / prochaine

  // composition_service.dart — getNextRace()
  Future<Map<String, dynamic>?> getNextRace() async {
    final now = DateTime.now().toUtc().toIso8601String();
    print('[DEBUG] getNextRace called, now = $now');
    final data = await _supabase
        .from('races')
        .select()
        .gt('race_date', now)
        .order('race_date', ascending: true)
        .limit(1)
        .maybeSingle();
    print(
      '[DEBUG] getNextRace result = ${data?['name']} / race_date=${data?['race_date']} / pick_deadline=${data?['pick_deadline']}',
    );
    return data;
  }

  // last finished race
  Future<Map<String, dynamic>?> getLastFinishedRace() async {
    final data = await _supabase
        .from('races')
        .select()
        .eq('status', 'finished')
        .order('race_date', ascending: false)
        .limit(1)
        .maybeSingle();
    return data;
  }

  //Deadline

  bool isDeadlinePassed(Map<String, dynamic> race) {
    final deadline = DateTime.parse(race['pick_deadline'] as String).toLocal();
    return DateTime.now().isAfter(deadline);
  }

  //Composition de l'user

  // get team compo or null
  Future<Composition?> getComposition({
    required String fantasyTeamId,
    required String raceId,
  }) async {
    final data = await _supabase
        .from('compositions')
        .select()
        .eq('fantasy_team_id', fantasyTeamId)
        .eq('race_id', raceId)
        .maybeSingle();
    return data != null ? Composition.fromJson(data) : null;
  }

  // get compo with driver/team details
  Future<Map<String, dynamic>?> getCompositionWithDetails({
    required String fantasyTeamId,
    required String raceId,
  }) async {
    final comp = await getComposition(
      fantasyTeamId: fantasyTeamId,
      raceId: raceId,
    );
    if (comp == null) return null;

    // Fetch pilotes et écuries en parallèle
    final results = await Future.wait([
      _supabase
          .from('drivers')
          .select(
            'id, first_name, last_name, name_acronym, headshot_url, price, rating_history, team_id',
          )
          .inFilter('id', comp.driverIds),
      _supabase
          .from('teams')
          .select('id, name, color_hex, constructor_price, rating_history')
          .inFilter('id', comp.constructorIds),
    ]);

    return {
      'composition': comp,
      'drivers': results[0] as List,
      'constructors': results[1] as List,
    };
  }

  // catalogue

  Future<List<Map<String, dynamic>>> getAllDrivers() async {
    final data = await _supabase
        .from('drivers')
        .select(
          'id, first_name, last_name, name_acronym, headshot_url, price, team_id, rating_history, teams(name, color_hex)',
        )
        .order('price', ascending: false);
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<List<Map<String, dynamic>>> getAllTeams() async {
    final data = await _supabase
        .from('teams')
        .select('id, name, color_hex, constructor_price, rating_history')
        .order('constructor_price', ascending: false);
    return List<Map<String, dynamic>>.from(data as List);
  }

  // budget & validation

  double calcBudgetUsed({
    required List<Map<String, dynamic>> selectedDrivers,
    required List<Map<String, dynamic>> selectedTeams,
  }) {
    final driverTotal = selectedDrivers.fold<double>(
      0,
      (sum, d) => sum + (d['price'] as num).toDouble(),
    );
    final teamTotal = selectedTeams.fold<double>(
      0,
      (sum, t) => sum + (t['constructor_price'] as num).toDouble(),
    );
    return driverTotal + teamTotal;
  }

  bool isBudgetValid({
    required List<Map<String, dynamic>> selectedDrivers,
    required List<Map<String, dynamic>> selectedTeams,
  }) {
    return calcBudgetUsed(
          selectedDrivers: selectedDrivers,
          selectedTeams: selectedTeams,
        ) <=
        kBudgetCap;
  }

  // Soumission de la compo

  // submit compo (throws if already submitted or deadline passed)
  Future<Composition> submitComposition({
    required String fantasyTeamId,
    required String raceId,
    required List<String> driverIds,
    required List<String> constructorIds,
  }) async {
    // Double-check : pas déjà soumis
    final existing = await getComposition(
      fantasyTeamId: fantasyTeamId,
      raceId: raceId,
    );
    if (existing != null) {
      throw Exception('You already submitted a team for this race.');
    }

    final data = await _supabase
        .from('compositions')
        .insert({
          'fantasy_team_id': fantasyTeamId,
          'race_id': raceId,
          'driver_ids': driverIds,
          'constructor_ids': constructorIds,
          'points_scored_this_week': 0,
        })
        .select()
        .single();

    return Composition.fromJson(data);
  }

  // Suppression de la compo

  Future<void> deleteComposition({
    required String fantasyTeamId,
    required String raceId,
  }) async {
    await _supabase
        .from('compositions')
        .delete()
        .eq('fantasy_team_id', fantasyTeamId)
        .eq('race_id', raceId);
  }

  // Modification de la compo (remplace les pilotes/écuries)

  Future<Composition> updateComposition({
    required String fantasyTeamId,
    required String raceId,
    required List<String> driverIds,
    required List<String> constructorIds,
  }) async {
    // Upsert — fonctionne que la compo existe ou non
    final data = await _supabase
        .from('compositions')
        .upsert({
          'fantasy_team_id': fantasyTeamId,
          'race_id': raceId,
          'driver_ids': driverIds,
          'constructor_ids': constructorIds,
          'points_scored_this_week': 0,
        }, onConflict: 'fantasy_team_id,race_id')
        .select()
        .maybeSingle();

    if (data == null) throw Exception('Update failed — no row returned');
    return Composition.fromJson(data);
  }
}
