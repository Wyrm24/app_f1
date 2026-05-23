import 'dart:ui'; // Obligatoire pour BackdropFilter
import 'package:fantasy_f1_app/core/theme.dart';
import 'package:fantasy_f1_app/data/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Couleur de base du fond flou : sombre ou clair selon le thème
    final navColor = isDark
        ? Colors.black.withOpacity(0.4)
        : Colors.white.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: navColor, // adapté
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: selectedPageNotifier,
              builder: (context, currentIndex, child) {
                return ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: navColor, // adapté
                      child: CupertinoTabBar(
                        currentIndex: currentIndex,
                        backgroundColor: Colors.transparent,
                        activeColor: F1Theme.f1Red,
                        inactiveColor: colorScheme.onSurface.withOpacity(0.5),
                        border: Border(
                          top: BorderSide(
                            color: CupertinoColors.systemGrey4.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        onTap: (index) {
                          selectedPageNotifier.value = index;
                        },
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.house_fill),
                            label: 'Home',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.flag_fill),
                            label: 'League',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.question_circle_fill),
                            label: 'Quiz',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.person_fill),
                            label: 'Profile',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
