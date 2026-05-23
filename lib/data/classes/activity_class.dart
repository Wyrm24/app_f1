class Activity {
  final String activity;
  final double availability;
  final String type;
  final int participants;
  final double price;
  final String accessibility;
  final String duration;
  final bool kidFriendly;
  final String link;
  final String key;

  const Activity({
    required this.activity,
    required this.availability,
    required this.type,
    required this.participants,
    required this.price,
    required this.accessibility,
    required this.duration,
    required this.kidFriendly,
    required this.link,
    required this.key,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activity: json['activity'] as String,
      availability: (json['availability'] as num).toDouble(),
      type: json['type'] as String,
      participants: json['participants'] as int,
      price: (json['price'] as num).toDouble(),
      accessibility: json['accessibility'] as String,
      duration: json['duration'] as String,
      kidFriendly: json['kidFriendly'] as bool,
      link: json['link'] as String,
      key: json['key'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity': activity,
      'availability': availability,
      'type': type,
      'participants': participants,
      'price': price,
      'accessibility': accessibility,
      'duration': duration,
      'kidFriendly': kidFriendly,
      'link': link,
      'key': key,
    };
  }
}
