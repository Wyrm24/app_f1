import 'package:flutter/material.dart';

enum PositionChange { up, down, same }

class LeagueCard extends StatelessWidget {
  final String leagueName;
  final String points;
  final String ranking;
  final String imagePath;
  final PositionChange positionChange;
  final VoidCallback? onTap;

  const LeagueCard({
    super.key,
    required this.leagueName,
    required this.points,
    required this.ranking,
    required this.imagePath,
    required this.positionChange,
    this.onTap,
  });

  Widget _buildPositionIcon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (positionChange) {
      case PositionChange.up:
        return const Icon(Icons.arrow_drop_up, color: Colors.green, size: 22);
      case PositionChange.down:
        return const Icon(Icons.arrow_drop_down, color: Colors.red, size: 22);
      case PositionChange.same:
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isDark ? Colors.white38 : Colors.black26,
            shape: BoxShape.circle,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Couleurs explicites light / dark
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFE0E0E0);
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 74,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(radius: 22, backgroundImage: AssetImage(imagePath)),

              const SizedBox(width: 12),

              // Texte gauche
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leagueName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(points, style: TextStyle(color: subtitleColor)),
                  ],
                ),
              ),

              // Position + classement
              Row(
                children: [
                  _buildPositionIcon(context),
                  const SizedBox(width: 4),
                  Text(
                    ranking,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
