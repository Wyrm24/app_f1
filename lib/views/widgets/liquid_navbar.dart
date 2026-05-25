import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fantasy_f1_app/views/widgets/navbar_button.dart';

class LiquidNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const LiquidNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Largeur réelle de la navbar (écran - padding horizontal)
    final double navbarWidth = MediaQuery.of(context).size.width - 40;
    final double itemWidth = navbarWidth / 4;

    final List<Map<String, dynamic>> tabs = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.flag_rounded, 'label': 'League'},
      {'icon': Icons.help_outline_rounded, 'label': 'Quiz'},
      {'icon': Icons.person_rounded, 'label': 'Profil'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: isDark
                    ? const Color.fromARGB(
                        255,
                        202,
                        201,
                        201,
                      ).withValues(alpha: 0.18)
                    : const Color.fromARGB(
                        255,
                        101,
                        101,
                        101,
                      ).withValues(alpha: 0.86),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Pilule indicatrice
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  left: currentIndex * itemWidth + itemWidth / 2 - 32,
                  top: 10,
                  child: Container(
                    width: 64,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE10600).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFE10600).withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                  ),
                ),

                // Boutons
                Row(
                  children: List.generate(tabs.length, (index) {
                    return Expanded(
                      child: NavBarButton(
                        icon: tabs[index]['icon'],
                        label: tabs[index]['label'],
                        isSelected: currentIndex == index,
                        onTap: () => onTabSelected(index),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
