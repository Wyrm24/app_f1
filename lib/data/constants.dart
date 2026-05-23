import 'package:flutter/material.dart';

class KConstants {
  static const String themeModeKey = 'IsDarkKey';
  static const double verticalPadding = 15;
}

class KTextStyle {
  static const TextStyle titleTealText = TextStyle(
    color: Colors.teal,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle descriptionText = TextStyle(fontSize: 16.0);

  // Section titles
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
  );
  static const TextStyle sectionSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE10600),
    letterSpacing: 0.8,
  );
}

class KValue {
  static const String basicLayout = "Basic Layout";
  static const String cleanUi = "Clean UI";
  static const String fixBugs = "Fix Bugs";
  static const String keyConcepts = "Key Concetps";
}
