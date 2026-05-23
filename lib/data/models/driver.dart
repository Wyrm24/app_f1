class Driver {
  final String id;
  final String? teamId;
  final String firstName;
  final String lastName;
  final int? driverNumber;
  final String? photoPath;
  final double price;
  final List<double> ratingHistory;

  Driver({
    required this.id,
    this.teamId,
    required this.firstName,
    required this.lastName,
    this.driverNumber,
    this.photoPath,
    required this.price,
    required this.ratingHistory,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      teamId: json['team_id'] as String?,
      firstName: json['first_name'] ?? 'Inconnu',
      lastName: json['last_name'] ?? '',
      driverNumber: json['driver_number'] as int?,
      photoPath: json['photo_path'] as String?,
      price: (json['price'] ?? 0).toDouble(),
      // On gère la conversion de la liste (array) Supabase vers une List Dart
      ratingHistory: json['rating_history'] != null
          ? List<double>.from(json['rating_history'].map((x) => x.toDouble()))
          : [],
    );
  }

  // Petit bonus pour afficher le nom complet facilement dans l'UI
  String get fullName => '$firstName $lastName';
}
