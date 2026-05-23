import 'package:fantasy_f1_app/data/constants.dart';
import 'package:flutter/material.dart';

class SectionTitleWidget extends StatelessWidget {
  const SectionTitleWidget({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    // Détection du thème
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Barre rouge
        Container(
          width: 4,
          height: subtitle != null ? 42 : 30,
          decoration: BoxDecoration(
            color: const Color(0xFFE10600),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),

        // Titre et sous-titre
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: KTextStyle.sectionTitle),
            if (subtitle != null)
              Text(subtitle!.toUpperCase(), style: KTextStyle.sectionSubtitle),
          ],
        ),

        // Damier
        const SizedBox(width: 5),
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            isDark ? const Color.fromARGB(255, 255, 255, 255) : Colors.black,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            'assets/images/damier_clair.png',
            height: 15,
            opacity: AlwaysStoppedAnimation(isDark ? 0.35 : 0.35),
          ),
        ),
      ],
    );
  }
}
