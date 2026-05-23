class FantasyLeague {
  final String id;
  final String name;
  final String inviteCode;
  final String creatorId;

  const FantasyLeague({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.creatorId,
  });

  factory FantasyLeague.fromJson(Map<String, dynamic> json) {
    return FantasyLeague(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['invite_code'] as String,
      creatorId: json['creator_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'invite_code': inviteCode,
    'creator_id': creatorId,
  };
}
