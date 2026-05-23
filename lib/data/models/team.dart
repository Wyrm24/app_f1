class Team {
  final String id;
  final String name;
  final String? colorHex;
  final double constructorPrice;

  Team({
    required this.id,
    required this.name,
    this.colorHex,
    required this.constructorPrice,
  });

  // Cette "factory" transforme le dictionnaire (JSON) de Supabase en un objet Team
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: json['color_hex'] as String?,
      // On s'assure de bien convertir en 'double' même si Supabase renvoie un 'int'
      constructorPrice: (json['constructor_price'] ?? 0).toDouble(),
    );
  }

  // Pour envoyer des données vers Supabase plus tard
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color_hex': colorHex,
      'constructor_price': constructorPrice,
    };
  }
}
