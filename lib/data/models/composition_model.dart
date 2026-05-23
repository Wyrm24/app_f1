class Composition {
  final String id;
  final String fantasyTeamId;
  final String raceId;
  final List<String> driverIds;
  final List<String> constructorIds;
  final int pointsScoredThisWeek;
  final DateTime? createdAt;

  // Relations jointes
  final List<Map<String, dynamic>>? drivers;
  final List<Map<String, dynamic>>? constructors;

  const Composition({
    required this.id,
    required this.fantasyTeamId,
    required this.raceId,
    required this.driverIds,
    required this.constructorIds,
    required this.pointsScoredThisWeek,
    this.createdAt,
    this.drivers,
    this.constructors,
  });

  factory Composition.fromJson(Map<String, dynamic> json) {
    return Composition(
      id: json['id'] as String,
      fantasyTeamId: json['fantasy_team_id'] as String,
      raceId: json['race_id'] as String,
      driverIds: List<String>.from(json['driver_ids'] as List),
      constructorIds: List<String>.from(json['constructor_ids'] as List),
      pointsScoredThisWeek:
          (json['points_scored_this_week'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
