import 'package:fantasy_f1_app/viewmodels/pick_team_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fantasy_f1_app/data/models/composition_model.dart';
import 'package:fantasy_f1_app/viewmodels/league_detail_viewmodel.dart';
import 'package:fantasy_f1_app/views/pages/pick_team_page.dart';

class LeagueDetailPage extends StatefulWidget {
  final String leagueId;
  final String leagueName;
  final String inviteCode;
  final String fantasyTeamId;

  const LeagueDetailPage({
    super.key,
    required this.leagueId,
    required this.leagueName,
    required this.inviteCode,
    required this.fantasyTeamId,
  });

  @override
  State<LeagueDetailPage> createState() => _LeagueDetailPageState();
}

class _LeagueDetailPageState extends State<LeagueDetailPage> {
  @override
  void initState() {
    super.initState();
    // Déclenche le chargement sans logique ici
    Future.microtask(() => context.read<LeagueDetailViewModel>().load());
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite code copied!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _goToPick(Map<String, dynamic> race) async {
    final submitted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => PickTeamViewModel(
            fantasyTeamId: widget.fantasyTeamId,
            raceId: race['id'] as String,
          ),
          child: PickTeamPage(fantasyTeamId: widget.fantasyTeamId, race: race),
        ),
      ),
    );
    if (submitted == true && mounted) {
      context.read<LeagueDetailViewModel>().reload();
    }
  }

  // Ouvrir le pick en mode édition avec la compo pré-remplie
  Future<void> _goToEdit(
    Map<String, dynamic> race,
    Map<String, dynamic> details,
  ) async {
    final drivers = List<Map<String, dynamic>>.from(details['drivers'] as List);
    final teams = List<Map<String, dynamic>>.from(
      details['constructors'] as List,
    );

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => PickTeamViewModel(
            fantasyTeamId: widget.fantasyTeamId,
            raceId: race['id'] as String,
            isEditing: true,
            preselectedDrivers: drivers,
            preselectedTeams: teams,
          ),
          child: PickTeamPage(fantasyTeamId: widget.fantasyTeamId, race: race),
        ),
      ),
    );
    if (updated == true && mounted) {
      context.read<LeagueDetailViewModel>().reload();
    }
  }

  // Confirmation puis suppression de la compo
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete team?'),
        content: const Text(
          'Your composition for this race will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE10600),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<LeagueDetailViewModel>().deleteComposition();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeagueDetailViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<LeagueDetailViewModel>().reload(),
        child: CustomScrollView(
          slivers: [
            // Hero image + titre
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: const Color(0xFFE10600),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.leagueName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/melbourne.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: const Color(0xFFE10600)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (vm.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vm.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Error: ${vm.error}',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              )
            else
              _buildContent(context, vm),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LeagueDetailViewModel vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final medalColors = [
      Colors.amber,
      Colors.grey.shade400,
      Colors.brown.shade300,
    ];

    return SliverList(
      delegate: SliverChildListDelegate([
        // Pick card ou compo soumise
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: vm.nextRace == null
              ? _NoRaceCard()
              : vm.compositionDetails == null
              ? _PickTeamCard(
                  race: vm.nextRace!,
                  isPastDeadline: vm.isPastDeadline,
                  onTap: () => _goToPick(vm.nextRace!),
                )
              : _MyCompositionCard(
                  details: vm.compositionDetails!,
                  race: vm.nextRace!,
                  isPastDeadline: vm.isPastDeadline,
                  onEdit: () => _goToEdit(vm.nextRace!, vm.compositionDetails!),
                  onDelete: _confirmDelete,
                ),
        ),

        // Code d'invitation
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invite Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _copyCode,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE10600),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.inviteCode,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            color: Color(0xFFE10600),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.copy, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Titre membres
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Members',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),

        // Classement
        ...vm.leaderboard.asMap().entries.map((entry) {
          final index = entry.key;
          final team = entry.value;
          final rank = team.rank ?? index + 1;
          final isTop3 = rank <= 3;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: isTop3
                      ? medalColors[rank - 1]
                      : isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFEEEEEE),
                  backgroundImage: team.userAvatarUrl != null
                      ? NetworkImage(team.userAvatarUrl!)
                      : null,
                  child: team.userAvatarUrl == null
                      ? Text(
                          '$rank',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isTop3
                                ? Colors.white
                                : colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  team.teamName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Text(
                  '${team.totalPointsCumulated} pts',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE10600),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 40),
      ]),
    );
  }
}

// Card aucune course

class _NoRaceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            'No upcoming race',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// Card pick team

class _PickTeamCard extends StatelessWidget {
  final Map<String, dynamic> race;
  final bool isPastDeadline;
  final VoidCallback onTap;

  const _PickTeamCard({
    required this.race,
    required this.isPastDeadline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final deadline = DateTime.parse(race['pick_deadline'] as String).toLocal();
    final deadlineStr =
        '${deadline.day}/${deadline.month} ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: isPastDeadline ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPastDeadline
              ? null
              : const LinearGradient(
                  colors: [Color(0xFFE10600), Color(0xFFFF4433)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isPastDeadline
              ? isDark
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFF3F3F3)
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isPastDeadline ? Icons.lock_outline : Icons.sports_score,
              color: isPastDeadline ? Colors.grey : Colors.white,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPastDeadline ? 'Deadline passed' : 'Pick your team!',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isPastDeadline ? Colors.grey : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPastDeadline
                        ? 'No team submitted for ${race['name']}'
                        : 'Deadline: $deadlineStr — ${race['name']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isPastDeadline ? Colors.grey : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPastDeadline)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

// Card composition soumise

class _MyCompositionCard extends StatelessWidget {
  final Map<String, dynamic> details;
  final Map<String, dynamic> race;
  final bool isPastDeadline;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyCompositionCard({
    required this.details,
    required this.race,
    required this.isPastDeadline,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final comp = details['composition'] as Composition;
    final drivers = details['drivers'] as List;
    final constructors = details['constructors'] as List;
    final hasResults = comp.pointsScoredThisWeek > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE10600).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00A651),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Team submitted — ${race['name']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (comp.pointsScoredThisWeek > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE10600),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${comp.pointsScoredThisWeek} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          // Boutons Edit / Delete (masqués si deadline passée ou résultats déjà calculés)
          if (!isPastDeadline && comp.pointsScoredThisWeek == 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit team'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(color: colorScheme.outline),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE10600),
                    side: const BorderSide(color: Color(0xFFE10600)),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 20),

          // Pilotes
          Text(
            'Drivers',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...drivers.map(
            (d) => _DriverRow(
              driver: d as Map<String, dynamic>,
              showScore: hasResults,
            ),
          ),

          const SizedBox(height: 12),

          // Écuries
          Text(
            'Constructors',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...constructors.map(
            (t) => _TeamRow(
              team: t as Map<String, dynamic>,
              showScore: hasResults,
            ),
          ),
        ],
      ),
    );
  }
}

// Ligne pilote

class _DriverRow extends StatelessWidget {
  final Map<String, dynamic> driver;
  final bool showScore;
  const _DriverRow({required this.driver, this.showScore = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final history = driver['rating_history'] as List?;
    final lastScore = (history != null && history.isNotEmpty)
        ? history.last
        : null;

    final trailing = showScore && lastScore != null
        ? Text(
            '${lastScore > 0 ? '+' : ''}$lastScore pts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: lastScore >= 0
                  ? const Color(0xFF00A651)
                  : const Color(0xFFE10600),
            ),
          )
        : Text(
            '${(driver['price'] as num).toStringAsFixed(1)}M',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0F0F0),
            backgroundImage: driver['headshot_url'] != null
                ? NetworkImage(driver['headshot_url'] as String)
                : null,
            child: driver['headshot_url'] == null
                ? Text(
                    driver['name_acronym'] as String? ?? '?',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${driver['first_name']} ${driver['last_name']}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// Ligne écurie

class _TeamRow extends StatelessWidget {
  final Map<String, dynamic> team;
  final bool showScore;
  const _TeamRow({required this.team, this.showScore = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _hexColor(team['color_hex'] as String? ?? '#cccccc');

    final history = team['rating_history'] as List?;
    final lastScore = (history != null && history.isNotEmpty)
        ? history.last
        : null;

    final trailing = showScore && lastScore != null
        ? Text(
            '${lastScore > 0 ? '+' : ''}$lastScore pts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: lastScore >= 0
                  ? const Color(0xFF00A651)
                  : const Color(0xFFE10600),
            ),
          )
        : Text(
            '${(team['constructor_price'] as num).toStringAsFixed(1)}M',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Center(
              child: Text(
                (team['name'] as String).substring(0, 2).toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              team['name'] as String,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// Couleur hex

Color _hexColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  final full = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
  return Color(int.parse(full, radix: 16));
}
