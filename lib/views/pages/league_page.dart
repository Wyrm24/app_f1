import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fantasy_f1_app/data/models/fantasy_team_model.dart';
import 'package:fantasy_f1_app/viewmodels/league_viewmodel.dart';
import 'package:fantasy_f1_app/viewmodels/league_detail_viewmodel.dart';
import 'package:fantasy_f1_app/views/widgets/league_card.dart';
import 'package:fantasy_f1_app/views/pages/league_detail_page.dart';
import 'package:fantasy_f1_app/views/widgets/create_league_modal.dart';
import 'package:fantasy_f1_app/views/widgets/join_league_modal.dart';

class LeaguePage extends StatefulWidget {
  const LeaguePage({super.key});

  @override
  State<LeaguePage> createState() => _LeaguePageState();
}

class _LeaguePageState extends State<LeaguePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<LeagueViewModel>().load();
      }
    });
  }

  void _showCreateModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateLeagueModal(
        onCreated: (_) => context.read<LeagueViewModel>().load(),
      ),
    );
  }

  void _showJoinModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JoinLeagueModal(
        onJoined: (_) => context.read<LeagueViewModel>().load(),
      ),
    );
  }

  void _goToDetail(FantasyTeam team) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => LeagueDetailViewModel(
            leagueId: team.leagueId,
            fantasyTeamId: team.id,
          ),
          child: LeagueDetailPage(
            leagueId: team.leagueId,
            leagueName: team.league?.name ?? team.teamName,
            inviteCode: team.league?.inviteCode ?? '',
            fantasyTeamId: team.id,
          ),
        ),
      ),
    );
  }

  void _confirmLeave(FantasyTeam team) {
    final vm = context.read<LeagueViewModel>();
    final isCreator = vm.isCreator(team);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCreator ? 'Delete league?' : 'Leave league?'),
        content: Text(
          isCreator
              ? 'You are the creator. Deleting "${team.league?.name}" will remove it for all members.'
              : 'You will leave "${team.league?.name}". Your team and points will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE10600),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await vm.leaveLeague(team.leagueId);
              } catch (e) {
                _showError(e.toString());
              }
            },
            child: Text(isCreator ? 'Delete' : 'Leave'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE10600),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeagueViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Boutons Create / Join
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showCreateModal,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE10600),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showJoinModal,
                        icon: Icon(Icons.search, color: colorScheme.onSurface),
                        label: Text(
                          'Join',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // Titre section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'My Leagues',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Liste des ligues
              if (vm.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (vm.error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'Error: ${vm.error}',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                )
              else if (vm.leagues.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Text(
                      'No leagues yet.\nCreate one or join with a code!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: vm.leagues.map((team) {
                      final rankStr =
                          team.rank != null && team.totalMembers != null
                          ? '${vm.ordinal(team.rank!)} out of ${team.totalMembers}'
                          : '—';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onLongPress: () => _confirmLeave(team),
                          child: LeagueCard(
                            leagueName: team.league?.name ?? team.teamName,
                            points: '${team.totalPointsCumulated} pts',
                            ranking: rankStr,
                            imagePath: 'assets/images/melbourne.jpg',
                            positionChange: PositionChange.same,
                            onTap: () => _goToDetail(team),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
