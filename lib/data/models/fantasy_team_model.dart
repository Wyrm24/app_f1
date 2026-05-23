import 'package:fantasy_f1_app/data/models/fantasy_league_model.dart';

class FantasyTeam {
  final String id;
  final String userId;
  final String leagueId;
  final String teamName;
  final int totalPointsCumulated;

  final FantasyLeague? league;
  final String? userPseudo;
  final String? userAvatarUrl;

  int? rank;
  int? totalMembers;

  FantasyTeam({
    required this.id,
    required this.userId,
    required this.leagueId,
    required this.teamName,
    required this.totalPointsCumulated,
    this.league,
    this.userPseudo,
    this.userAvatarUrl,
    this.rank,
    this.totalMembers,
  });

  factory FantasyTeam.fromJson(Map<String, dynamic> json) {
    return FantasyTeam(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      leagueId: json['league_id'] as String,
      teamName: json['team_name'] as String,
      totalPointsCumulated:
          (json['total_points_cumulated'] as num?)?.toInt() ?? 0,
      league: json['fantasy_leagues'] != null
          ? FantasyLeague.fromJson(
              json['fantasy_leagues'] as Map<String, dynamic>,
            )
          : null,
      userPseudo: json['profiles'] != null
          ? (json['profiles'] as Map<String, dynamic>)['pseudo'] as String?
          : null,
      userAvatarUrl: json['profiles'] != null
          ? (json['profiles'] as Map<String, dynamic>)['avatar_url'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'league_id': leagueId,
    'team_name': teamName,
    'total_points_cumulated': totalPointsCumulated,
  };
}
