import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantasy_f1_app/data/models/fantasy_league_model.dart';
import 'package:fantasy_f1_app/data/models/fantasy_team_model.dart';

class LeagueService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // helpers

  String get currentUserId => _currentUserId;

  String get _currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.id;
  }

  // gen unique invite code (F1-XXXXXX)
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no confusing chars
    final rand = Random.secure();
    final code = List.generate(
      6,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
    return 'F1-$code';
  }

  // create league

  // create league + creator team
  // return creator team
  Future<FantasyTeam> createLeague({
    required String leagueName,
    required String teamName,
    String? imageUrl,
    bool isPublic = true,
    int gpCount = 10,
  }) async {
    final userId = _currentUserId;
    String inviteCode;

    // ensure unique code (retry on collision)
    do {
      inviteCode = _generateInviteCode();
    } while (await _inviteCodeExists(inviteCode));

    // 1. insert league
    final leagueData = await _supabase
        .from('fantasy_leagues')
        .insert({
          'name': leagueName,
          'invite_code': inviteCode,
          'creator_id': userId,
          'image_url': imageUrl,
          'is_public': isPublic,
          'gp_count': gpCount,
        })
        .select()
        .single();

    final league = FantasyLeague.fromJson(leagueData);

    // 2. insert creator team
    final teamData = await _supabase
        .from('fantasy_teams')
        .insert({
          'user_id': userId,
          'league_id': league.id,
          'team_name': teamName,
          'total_points_cumulated': 0,
        })
        .select()
        .single();

    return FantasyTeam.fromJson({...teamData, 'fantasy_leagues': leagueData});
  }

  Future<bool> _inviteCodeExists(String code) async {
    final result = await _supabase
        .from('fantasy_leagues')
        .select('id')
        .eq('invite_code', code)
        .maybeSingle();
    return result != null;
  }

  // join league

  /// Cherche une ligue par [inviteCode] sans la rejoindre (prévisualisation).
  Future<FantasyLeague?> previewLeague(String inviteCode) async {
    final data = await _supabase
        .from('fantasy_leagues')
        .select()
        .eq('invite_code', inviteCode.toUpperCase())
        .maybeSingle();

    return data != null ? FantasyLeague.fromJson(data) : null;
  }

  /// Rejoint une ligue via son [inviteCode] et crée le [teamName] du joueur.
  /// Lance une exception si le code est invalide ou si l'user est déjà membre.
  Future<FantasyTeam> joinLeague({
    required String inviteCode,
    required String teamName,
  }) async {
    final userId = _currentUserId;

    // 1. Trouver la ligue
    final leagueData = await _supabase
        .from('fantasy_leagues')
        .select()
        .eq('invite_code', inviteCode.toUpperCase())
        .maybeSingle();

    if (leagueData == null) {
      throw Exception('Invalid invite code. No league found.');
    }

    final league = FantasyLeague.fromJson(leagueData);

    // 2. Vérifier que l'user n'est pas déjà dans cette ligue
    final existing = await _supabase
        .from('fantasy_teams')
        .select('id')
        .eq('user_id', userId)
        .eq('league_id', league.id)
        .maybeSingle();

    if (existing != null) {
      throw Exception('You are already a member of "${league.name}".');
    }

    // 3. Créer le fantasy_team
    final teamData = await _supabase
        .from('fantasy_teams')
        .insert({
          'user_id': userId,
          'league_id': league.id,
          'team_name': teamName,
          'total_points_cumulated': 0,
        })
        .select()
        .single();

    return FantasyTeam.fromJson({...teamData, 'fantasy_leagues': leagueData});
  }

  // ─── Ligues de l'utilisateur courant ───────────────────────────────────────

  /// Retourne toutes les ligues de l'user avec son rang dans chacune.
  Future<List<FantasyTeam>> getUserLeagues() async {
    final userId = _currentUserId;

    final data = await _supabase
        .from('fantasy_teams')
        .select('*, fantasy_leagues(*)')
        .eq('user_id', userId)
        .order('total_points_cumulated', ascending: false);

    final teams = (data as List)
        .map((e) => FantasyTeam.fromJson(e as Map<String, dynamic>))
        .toList();

    // Calculer le rang pour chaque ligue en parallèle
    await Future.wait(teams.map((team) => _attachRank(team)));

    return teams;
  }

  /// Calcule et attache le rang + nombre de membres au [team].
  Future<void> _attachRank(FantasyTeam team) async {
    final leaderboard = await getLeagueLeaderboard(team.leagueId);
    team.totalMembers = leaderboard.length;
    team.rank = leaderboard.indexWhere((t) => t.userId == team.userId) + 1;
  }

  // ─── Classement d'une ligue ─────────────────────────────────────────────────

  /// Retourne le classement complet d'une ligue, trié par points décroissants.
  /// Chaque [FantasyTeam] inclut le pseudo et avatar du joueur.
  Future<List<FantasyTeam>> getLeagueLeaderboard(String leagueId) async {
    final data = await _supabase
        .from('fantasy_teams')
        .select('*, profiles(pseudo, avatar_url)')
        .eq('league_id', leagueId)
        .order('total_points_cumulated', ascending: false);

    final teams = (data as List)
        .map((e) => FantasyTeam.fromJson(e as Map<String, dynamic>))
        .toList();

    // Attacher le rang (index 0-based + 1)
    for (var i = 0; i < teams.length; i++) {
      teams[i].rank = i + 1;
      teams[i].totalMembers = teams.length;
    }

    return teams;
  }

  // ─── Quitter une ligue ──────────────────────────────────────────────────────

  /// Quitte une ligue.
  /// Si l'user est le créateur, **supprime la ligue entière** (cascade sur fantasy_teams).
  /// Sinon, supprime seulement son fantasy_team.
  Future<void> leaveLeague(String leagueId) async {
    final userId = _currentUserId;

    // Vérifier si l'user est le créateur
    final leagueData = await _supabase
        .from('fantasy_leagues')
        .select('creator_id')
        .eq('id', leagueId)
        .single();

    if (leagueData['creator_id'] == userId) {
      // Supprimer la ligue (pense à activer ON DELETE CASCADE sur fantasy_teams.league_id dans Supabase)
      await _supabase.from('fantasy_leagues').delete().eq('id', leagueId);
    } else {
      // Supprimer uniquement le fantasy_team de l'user
      await _supabase
          .from('fantasy_teams')
          .delete()
          .eq('user_id', userId)
          .eq('league_id', leagueId);
    }
  }

  // ─── Renommer son équipe ────────────────────────────────────────────────────

  /// Met à jour le nom d'équipe de l'user dans une ligue donnée.
  Future<void> renameTeam({
    required String leagueId,
    required String newTeamName,
  }) async {
    final userId = _currentUserId;

    await _supabase
        .from('fantasy_teams')
        .update({'team_name': newTeamName})
        .eq('user_id', userId)
        .eq('league_id', leagueId);
  }

  // ─── Infos d'une ligue ──────────────────────────────────────────────────────

  /// Retourne les détails d'une ligue par son id.
  Future<FantasyLeague> getLeagueById(String leagueId) async {
    final data = await _supabase
        .from('fantasy_leagues')
        .select()
        .eq('id', leagueId)
        .single();

    return FantasyLeague.fromJson(data);
  }
}
