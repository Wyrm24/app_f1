import 'package:flutter/material.dart';

// ── HEADER (Avatar + Pseudo + Stats) ──────────────────────────
class ProfileHeader extends StatelessWidget {
  final String pseudo;
  final String? avatarUrl;
  final String? flagCode;

  const ProfileHeader({
    super.key,
    required this.pseudo,
    this.avatarUrl,
    this.flagCode,
  });

  String _flagEmoji(String code) {
    return code.toUpperCase().split('').map((c) {
      return String.fromCharCode(c.codeUnitAt(0) - 0x41 + 0x1F1E6);
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE10600), width: 2.5),
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: isDark
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFFF3F3F3),
              backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null || avatarUrl!.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 38,
                      color: isDark ? Colors.white54 : Colors.grey,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 20),

          // Pseudo + Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        pseudo,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: onSurface,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (flagCode != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        _flagEmoji(flagCode!),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _FollowStat(value: "67", label: "followers"),
                    const SizedBox(width: 24),
                    _FollowStat(value: "82", label: "following"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowStat extends StatelessWidget {
  final String value;
  final String label;

  const _FollowStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: onSurface.withValues(alpha: 0.5), // Gris dynamique
          ),
        ),
      ],
    );
  }
}

// ── TITRE DE SECTION ──────────────────────────────────────────
class ProfileSectionTitle extends StatelessWidget {
  final String title;
  const ProfileSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            height: 14,
            child: CustomPaint(painter: _CheckeredPainter(context)),
          ),
        ],
      ),
    );
  }
}

class _CheckeredPainter extends CustomPainter {
  final BuildContext context;
  _CheckeredPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paintColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.15);
    final paint = Paint()..color = paintColor;

    const cellSize = 7.0;
    for (int row = 0; row < (size.height / cellSize).ceil(); row++) {
      for (int col = 0; col < (size.width / cellSize).ceil(); col++) {
        if ((row + col) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── CARTE DE STATS & TROPHÉES ─────────────────────────────────
class ProfileCardContainer extends StatelessWidget {
  final Widget child;
  const ProfileCardContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    // On éclaircit légèrement le fond en Dark Mode pour détacher la carte du fond
    final cardColor = isDark ? const Color(0xFF141414) : surfaceColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCardContainer(
      child: Row(
        children: [
          _buildStatBox(context, "45", "teams created", borderRight: true),
          _buildStatBox(context, "165", "correct answers"),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    BuildContext context,
    String value,
    String label, {
    bool borderRight = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: Border(
            right: borderRight
                ? BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  )
                : BorderSide.none,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTrophyCard extends StatelessWidget {
  const ProfileTrophyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ProfileCardContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTrophy('🥇', '×1', onSurface),
            _buildTrophy('🥈', '×5', onSurface),
            _buildTrophy('🥉', '×11', onSurface),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophy(String emoji, String count, Color textColor) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 6),
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

// ── RÉGLAGES (Settings) ───────────────────────────────────────
class ProfileSettingsItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDestructive;
  final VoidCallback onTap;

  const ProfileSettingsItem({
    super.key,
    required this.label,
    required this.icon,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFFE10600)
        : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        size: 20,
      ),
    );
  }
}

class ProfileSettingsDivider extends StatelessWidget {
  const ProfileSettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      indent: 18,
      endIndent: 18,
      color: isDark ? Colors.white12 : Colors.grey.shade100,
    );
  }
}
