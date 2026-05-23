import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fantasy_f1_app/viewmodels/pick_team_viewmodel.dart';
import 'package:fantasy_f1_app/views/pages/driver_profile_page.dart';

Route _slideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (_, animation, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
    ),
  );
}

double _avgLastN(dynamic ratingHistory, int n) {
  if (ratingHistory == null) return 0;
  final list = (ratingHistory as List)
      .map((e) => (e as num).toDouble())
      .toList();
  if (list.isEmpty) return 0;
  final recent = list.length > n ? list.sublist(list.length - n) : list;
  return recent.fold(0.0, (a, b) => a + b) / recent.length;
}

Widget _scoreBadge(double value) {
  final Color color = value < 25
      ? const Color(0xFFE10600)
      : value < 60
      ? const Color(0xFFF5A623)
      : const Color(0xFF00A651);
  return Container(
    width: 46,
    padding: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      value.toStringAsFixed(0),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    ),
  );
}

class PickTeamPage extends StatefulWidget {
  final String fantasyTeamId;
  final Map<String, dynamic> race;

  const PickTeamPage({
    super.key,
    required this.fantasyTeamId,
    required this.race,
  });

  @override
  State<PickTeamPage> createState() => _PickTeamPageState();
}

class _PickTeamPageState extends State<PickTeamPage>
    with SingleTickerProviderStateMixin {
  // TabController reste dans la View — il a besoin du TickerProvider
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => context.read<PickTeamViewModel>().load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vm = context.read<PickTeamViewModel>();
    final success = vm.isEditing ? await vm.update() : await vm.submit();
    if (success && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PickTeamViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    //final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE10600),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pick Your Team',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.race['name'] as String? ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(
              text: 'Drivers (${vm.selectedDrivers.length}/${vm.maxDrivers})',
            ),
            Tab(text: 'Teams (${vm.selectedTeams.length}/${vm.maxTeams})'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Budget bar
                _BudgetBar(used: vm.budgetUsed, cap: vm.budgetCap),

                // Erreur
                if (vm.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      vm.error!,
                      style: const TextStyle(color: Color(0xFFE10600)),
                    ),
                  ),

                // Listes
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _DriverList(
                        drivers: vm.allDrivers,
                        selected: vm.selectedDrivers,
                        maxReached: vm.selectedDrivers.length >= vm.maxDrivers,
                        budgetRemaining: vm.budgetRemaining,
                        onToggle: vm.toggleDriver,
                      ),
                      _TeamList(
                        teams: vm.allTeams,
                        selected: vm.selectedTeams,
                        maxReached: vm.selectedTeams.length >= vm.maxTeams,
                        budgetRemaining: vm.budgetRemaining,
                        onToggle: vm.toggleTeam,
                      ),
                    ],
                  ),
                ),

                // Bouton submit
                _SubmitBar(
                  isComplete: vm.isSelectionComplete,
                  submitting: vm.isSubmitting,
                  onSubmit: _submit,
                  budgetUsed: vm.budgetUsed,
                  cap: vm.budgetCap,
                  maxDrivers: vm.maxDrivers,
                  maxTeams: vm.maxTeams,
                  isEditing: vm.isEditing,
                ),
              ],
            ),
    );
  }
}

// Budget bar

class _BudgetBar extends StatelessWidget {
  final double used;
  final double cap;

  const _BudgetBar({required this.used, required this.cap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final ratio = (used / cap).clamp(0.0, 1.0);
    final isOver = used > cap;
    final color = isOver ? const Color(0xFFE10600) : const Color(0xFF00A651);

    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${used.toStringAsFixed(1)}M / ${cap.toStringAsFixed(0)}M',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// Liste drivers

class _DriverList extends StatelessWidget {
  final List<Map<String, dynamic>> drivers;
  final List<Map<String, dynamic>> selected;
  final bool maxReached;
  final double budgetRemaining;
  final void Function(Map<String, dynamic>) onToggle;

  const _DriverList({
    required this.drivers,
    required this.selected,
    required this.maxReached,
    required this.budgetRemaining,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Driver',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(
                width: 46,
                child: Text(
                  'L5',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 4),
              const SizedBox(
                width: 46,
                child: Text(
                  'L10',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 6),
              const SizedBox(
                width: 46,
                child: Text(
                  'Budget',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 26),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];
              final isSelected = selected.any((d) => d['id'] == driver['id']);
              final price = (driver['price'] as num).toDouble();
              final canAfford = budgetRemaining >= price || isSelected;
              final isDisabled = !isSelected && (maxReached || !canAfford);

              final teamColor = driver['teams'] != null
                  ? _hexColor(
                      driver['teams']['color_hex'] as String? ?? '#cccccc',
                    )
                  : Colors.grey;

              return Opacity(
                opacity: isDisabled ? 0.4 : 1.0,
                child: GestureDetector(
                  onTap: isDisabled ? null : () => onToggle(driver),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: const Color(0xFFE10600), width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Barre couleur écurie
                          Container(
                            width: 4,
                            height: 50,
                            decoration: BoxDecoration(
                              color: teamColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Photo
                          CircleAvatar(
                            radius: 24,
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                      title: Text(
                        '${driver['first_name']} ${driver['last_name']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        driver['teams'] != null
                            ? driver['teams']['name'] as String
                            : '',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _scoreBadge(_avgLastN(driver['rating_history'], 5)),
                          const SizedBox(width: 4),
                          _scoreBadge(_avgLastN(driver['rating_history'], 10)),
                          const SizedBox(width: 6),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${price.toStringAsFixed(1)}M',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFE10600),
                                  size: 16,
                                ),
                            ],
                          ),
                          const SizedBox(width: 2),
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.push(
                              context,
                              _slideRoute(
                                DriverProfilePage(data: driver, isDriver: true),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Liste teams

class _TeamList extends StatelessWidget {
  final List<Map<String, dynamic>> teams;
  final List<Map<String, dynamic>> selected;
  final bool maxReached;
  final double budgetRemaining;
  final void Function(Map<String, dynamic>) onToggle;

  const _TeamList({
    required this.teams,
    required this.selected,
    required this.maxReached,
    required this.budgetRemaining,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Constructor',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(
                width: 46,
                child: Text(
                  'L5',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 4),
              const SizedBox(
                width: 46,
                child: Text(
                  'L10',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 6),
              const SizedBox(
                width: 46,
                child: Text(
                  'Budget',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 26),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final isSelected = selected.any((t) => t['id'] == team['id']);
              final price = (team['constructor_price'] as num).toDouble();
              final canAfford = budgetRemaining >= price || isSelected;
              final isDisabled = !isSelected && (maxReached || !canAfford);

              final teamColor = _hexColor(
                team['color_hex'] as String? ?? '#cccccc',
              );

              return Opacity(
                opacity: isDisabled ? 0.4 : 1.0,
                child: GestureDetector(
                  onTap: isDisabled ? null : () => onToggle(team),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: const Color(0xFFE10600), width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: teamColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: teamColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            (team['name'] as String)
                                .substring(0, 2)
                                .toUpperCase(),
                            style: TextStyle(
                              color: teamColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        team['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _scoreBadge(_avgLastN(team['rating_history'], 5)),
                          const SizedBox(width: 4),
                          _scoreBadge(_avgLastN(team['rating_history'], 10)),
                          const SizedBox(width: 6),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${price.toStringAsFixed(1)}M',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFE10600),
                                  size: 16,
                                ),
                            ],
                          ),
                          const SizedBox(width: 2),
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.push(
                              context,
                              _slideRoute(
                                DriverProfilePage(data: team, isDriver: false),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Barre de soumission

class _SubmitBar extends StatelessWidget {
  final bool isComplete;
  final bool submitting;
  final VoidCallback onSubmit;
  final double budgetUsed;
  final double cap;
  final int maxDrivers;
  final int maxTeams;
  final bool isEditing;

  const _SubmitBar({
    required this.isComplete,
    required this.submitting,
    required this.onSubmit,
    required this.budgetUsed,
    required this.cap,
    required this.maxDrivers,
    required this.maxTeams,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: (isComplete && !submitting) ? onSubmit : null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE10600),
            disabledBackgroundColor: isDark
                ? const Color(0xFF2A2A2A)
                : Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isComplete
                      ? 'Submit Team — ${budgetUsed.toStringAsFixed(1)}M used'
                      : 'Select $maxDrivers drivers & $maxTeams teams',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }
}

// Helper couleur hex

Color _hexColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  final full = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
  return Color(int.parse(full, radix: 16));
}
