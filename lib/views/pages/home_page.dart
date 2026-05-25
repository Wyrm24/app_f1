import 'package:fantasy_f1_app/data/constants.dart';
import 'package:fantasy_f1_app/viewmodels/gp_detail_viewmodel.dart';
import 'package:fantasy_f1_app/viewmodels/league_detail_viewmodel.dart';
import 'package:fantasy_f1_app/views/pages/driver_profile_page.dart';
import 'package:fantasy_f1_app/views/pages/gp_detail_page.dart';
import 'package:fantasy_f1_app/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fantasy_f1_app/data/models/fantasy_team_model.dart';
import 'package:fantasy_f1_app/data/notifiers.dart';
import 'package:fantasy_f1_app/viewmodels/home_viewmodel.dart';
import 'package:fantasy_f1_app/views/widgets/league_card.dart';
import 'package:fantasy_f1_app/views/pages/league_detail_page.dart';

// Transition glissement droite -> gauche
Route _slideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, _, _) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (_, animation, _, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    },
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double verticalPadding = KConstants.verticalPadding;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<HomeViewModel>().load();
      }
    });
  }

  void _openGpDetail(Map<String, dynamic> race) {
    Navigator.push(
      context,
      _slideRoute(
        ChangeNotifierProvider(
          create: (_) => GpDetailViewModel()..initWithRace(race),
          child: const GpDetailPage(),
        ),
      ),
    );
  }

  void _openLeagueDetail(FantasyTeam team) {
    if (team.league == null) return;
    Navigator.push(
      context,
      _slideRoute(
        ChangeNotifierProvider(
          create: (_) => LeagueDetailViewModel(
            leagueId: team.league!.id,
            fantasyTeamId: team.id,
          ),
          child: LeagueDetailPage(
            leagueId: team.league!.id,
            leagueName: team.league!.name,
            inviteCode: team.league!.inviteCode,
            fantasyTeamId: team.id,
          ),
        ),
      ),
    );
  }

  void _openDriverProfile(Map<String, dynamic> data, bool isDriver) {
    Navigator.push(
      context,
      _slideRoute(DriverProfilePage(data: data, isDriver: isDriver)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final nextRace = vm.nextRace;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Next GP
          Padding(
            padding: EdgeInsets.symmetric(horizontal: verticalPadding),
            child: SectionTitleWidget(
              title: 'Next Grand Prix',
              subtitle: nextRace != null
                  ? 'Round ${nextRace['round_number']}'
                  : 'Round ${vm.racesCompleted + 1}',
            ),
          ),
          const SizedBox(height: 10),

          // Card GP hero
          Padding(
            padding: EdgeInsets.symmetric(horizontal: verticalPadding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Image hero
                  Hero(
                    tag: 'gp-hero-${nextRace?['name'] ?? ''}',
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.black87,
                      child: _buildGpImage(nextRace),
                    ),
                  ),

                  // Gradient
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),

                  // Nom GP
                  Positioned(
                    bottom: 50,
                    left: 20,
                    child: Text(
                      nextRace?['name'] ?? 'Next Grand Prix',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Ville
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: Text(
                      nextRace?['city'] ?? '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),

                  // Bouton View details
                  Positioned(
                    bottom: 10,
                    right: 20,
                    child: ElevatedButton(
                      onPressed: nextRace != null
                          ? () => _openGpDetail(nextRace)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE10600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // My Leagues header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: verticalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SectionTitleWidget(title: 'My Leagues'),
                TextButton(
                  onPressed: () => selectedPageNotifier.value = 1,
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      color: Color(0xFFE10600),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Contenu My Leagues
          if (vm.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (vm.leagues.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: verticalPadding),
              child: GestureDetector(
                onTap: () => selectedPageNotifier.value = 1,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Create or join a league',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Column(
              children: vm.leagues.take(2).map((team) {
                final rankStr = team.rank != null && team.totalMembers != null
                    ? '${_ordinal(team.rank!)} out of ${team.totalMembers}'
                    : '—';
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: LeagueCard(
                    leagueName: team.league?.name ?? team.teamName,
                    points: '${team.totalPointsCumulated} pts',
                    ranking: rankStr,
                    imagePath: 'assets/images/melbourne.jpg',
                    positionChange: PositionChange.same,
                    onTap: () => _openLeagueDetail(team),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 30),

          // Top Performers
          Padding(
            padding: EdgeInsets.symmetric(horizontal: verticalPadding),
            child: SectionTitleWidget(
              title: 'Top Fantasy Performers',
              subtitle: vm.racesCompleted > 0
                  ? 'After ${vm.racesCompleted} races'
                  : 'Season standings',
            ),
          ),
          const SizedBox(height: 14),

          if (vm.isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Drivers',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...vm.topDrivers.asMap().entries.map(
              (e) => _PerformerTile.driver(
                rank: e.key + 1,
                data: e.value,
                vm: vm,
                onTap: () => _openDriverProfile(e.value, true),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Constructors',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...vm.topTeams.asMap().entries.map(
              (e) => _PerformerTile.team(
                rank: e.key + 1,
                data: e.value,
                vm: vm,
                onTap: () => _openDriverProfile(e.value, false),
              ),
            ),
          ],

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildGpImage(Map<String, dynamic>? race) {
    final url = race?['hero_image_url'] as String? ?? '';
    if (url.isNotEmpty) {
      return Image.network(
        url,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/images/melbourne.jpg', fit: BoxFit.cover),
      );
    }
    return Image.asset(
      'assets/images/melbourne.jpg',
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}

// Tile top performer
class _PerformerTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> data;
  final HomeViewModel vm;
  final bool isDriver;
  final VoidCallback onTap;

  const _PerformerTile.driver({
    required this.rank,
    required this.data,
    required this.vm,
    required this.onTap,
  }) : isDriver = true;

  const _PerformerTile.team({
    required this.rank,
    required this.data,
    required this.vm,
    required this.onTap,
  }) : isDriver = false;

  Color get _rankColor {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    return Colors.brown.shade300;
  }

  String get _colorHex {
    if (isDriver) {
      final team = data['teams'] as Map<String, dynamic>?;
      return team?['color_hex'] as String? ?? '#cccccc';
    }
    return data['color_hex'] as String? ?? '#cccccc';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final score = vm.scoreFor(data['rating_history'] as List?);
    final scoreColor = score >= 0
        ? const Color(0xFF00A651)
        : const Color(0xFFE10600);
    final teamColor = _hexColor(_colorHex);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        elevation: isDark ? 0 : 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: teamColor.withValues(alpha: 0.08),
          highlightColor: teamColor.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Médaille
                CircleAvatar(
                  radius: 14,
                  backgroundColor: _rankColor,
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Avatar
                if (isDriver)
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF0F0F0),
                    backgroundImage: data['headshot_url'] != null
                        ? NetworkImage(data['headshot_url'] as String)
                        : null,
                    child: data['headshot_url'] == null
                        ? Icon(
                            Icons.person,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          )
                        : null,
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: teamColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: teamColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        (data['name'] as String).substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          color: teamColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(width: 14),

                // Nom
                Expanded(
                  child: Text(
                    isDriver
                        ? '${data['first_name']} ${data['last_name']}'
                        : data['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),

                // Score
                Text(
                  '${score.toStringAsFixed(1)} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Utilitaire couleur hex
Color _hexColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  final full = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
  return Color(int.parse(full, radix: 16));
}
