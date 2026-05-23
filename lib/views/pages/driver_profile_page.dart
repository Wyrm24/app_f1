// Driver Profile Page

import 'package:flutter/material.dart';

class DriverProfilePage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDriver;

  const DriverProfilePage({
    super.key,
    required this.data,
    required this.isDriver,
  });

  // Nom affiché
  String get _name => isDriver
      ? '${data['first_name']} ${data['last_name']}'
      : data['name'] as String;

  // Couleur d'équipe
  String get _colorHex {
    if (isDriver) {
      final team = data['teams'] as Map<String, dynamic>?;
      return team?['color_hex'] as String? ?? '#E10600';
    }
    return data['color_hex'] as String? ?? '#E10600';
  }

  // Nom d'équipe (pilote seulement)
  String get _teamName {
    final team = data['teams'] as Map<String, dynamic>?;
    return team?['name'] as String? ?? '';
  }

  // rating_history est une List de doubles ou de nums
  List<double> get _history {
    final raw = data['rating_history'];
    if (raw == null) return [];
    final list = raw as List;
    return list.map((e) => (e as num).toDouble()).toList();
  }

  // 10 derniers points pour le graphique
  List<_RacePoint> get _racePoints {
    final h = _history;
    if (h.isEmpty) return [];
    final recent = h.length > 10 ? h.sublist(h.length - 10) : h;
    return recent.asMap().entries.map((e) {
      return _RacePoint(
        label: 'R${h.length - recent.length + e.key + 1}',
        points: e.value,
      );
    }).toList();
  }

  double get _totalPoints => _history.fold(0.0, (sum, v) => sum + v);

  double get _bestRace {
    final h = _history;
    if (h.isEmpty) return 0;
    return h.reduce((a, b) => a > b ? a : b);
  }

  // Courses avec score >= 15 pts
  int get _topFinishes => _history.where((v) => v >= 15).length;

  @override
  Widget build(BuildContext context) {
    final accentColor = _hexColor(_colorHex);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildHeader(accentColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(accentColor, colorScheme, isDark),
                  const SizedBox(height: 20),
                  if (isDriver) ...[
                    _buildInfoCard(colorScheme, isDark),
                    const SizedBox(height: 20),
                  ],
                  _buildChart(accentColor, colorScheme, isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header gradient avec photo
  Widget _buildHeader(Color accentColor) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: accentColor,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Photo ou initiales
                if (isDriver && data['headshot_url'] != null)
                  CircleAvatar(
                    radius: 44,
                    backgroundImage: NetworkImage(
                      data['headshot_url'] as String,
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    child: Text(
                      _name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),
                Text(
                  _name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isDriver && _teamName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _teamName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Trois stats clés
  Widget _buildStatsRow(Color accent, ColorScheme cs, bool isDark) {
    return Row(
      children: [
        _StatCard(
          label: 'Total pts',
          value: _totalPoints.toStringAsFixed(0),
          icon: Icons.star_rounded,
          accent: accent,
          isDark: isDark,
          cs: cs,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Meilleure course',
          value: _bestRace.toStringAsFixed(0),
          icon: Icons.emoji_events_rounded,
          accent: accent,
          isDark: isDark,
          cs: cs,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Top résultats',
          value: '$_topFinishes',
          icon: Icons.workspace_premium_rounded,
          accent: accent,
          isDark: isDark,
          cs: cs,
        ),
      ],
    );
  }

  // Infos pilote (nationalité, numéro, équipe)
  Widget _buildInfoCard(ColorScheme cs, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final nationality = data['nationality'] as String?;
    final number = data['number'] as int?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          if (nationality != null) ...[
            _InfoRow(
              icon: Icons.public,
              label: 'Nationalité',
              value: nationality,
              cs: cs,
            ),
            const Divider(height: 20),
          ],
          if (number != null) ...[
            _InfoRow(
              icon: Icons.tag,
              label: 'Numéro',
              value: '#$number',
              cs: cs,
            ),
            const Divider(height: 20),
          ],
          if (_teamName.isNotEmpty)
            _InfoRow(
              icon: Icons.groups_rounded,
              label: 'Équipe',
              value: _teamName,
              cs: cs,
            ),
        ],
      ),
    );
  }

  // Graphique en barres
  Widget _buildChart(Color accent, ColorScheme cs, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final points = _racePoints;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '10 dernières courses',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Points marqués par GP',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 20),
          if (points.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Aucune donnée disponible',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            )
          else
            _BarChart(points: points, accent: accent, cs: cs),
        ],
      ),
    );
  }
}

// Graphique en barres custom — pas de dépendance externe
class _BarChart extends StatelessWidget {
  final List<_RacePoint> points;
  final Color accent;
  final ColorScheme cs;

  const _BarChart({
    required this.points,
    required this.accent,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = points
        .map((p) => p.points.abs())
        .fold(0.0, (a, b) => a > b ? a : b);
    final scale = maxVal == 0 ? 1.0 : maxVal;

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((p) {
          final isMax = p.points.abs() == maxVal && maxVal > 0;
          final ratio = p.points.abs() / scale;
          final barColor = p.points >= 0
              ? (isMax ? accent : accent.withOpacity(0.3))
              : Colors.red.withOpacity(0.6);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Valeur au-dessus
                  Text(
                    p.points.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isMax ? accent : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Barre animée
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      height: (140 * ratio).clamp(4.0, 140.0),
                      color: barColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Label course
                  Text(
                    p.label,
                    style: TextStyle(fontSize: 8, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Carte statistique
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final bool isDark;
  final ColorScheme cs;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Ligne d'info
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

// Modèle interne point/course
class _RacePoint {
  final String label;
  final double points;
  const _RacePoint({required this.label, required this.points});
}

// Utilitaire couleur hex
Color _hexColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  final full = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
  return Color(int.parse(full, radix: 16));
}
