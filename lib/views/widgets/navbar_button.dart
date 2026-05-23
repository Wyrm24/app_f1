import 'package:flutter/material.dart';

class NavBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavBarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = const Color(0xFFE10600);
    final inactiveColor = isDark ? Colors.white54 : Colors.black45;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône avec animation de scale
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 3),
            // Label animé
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
