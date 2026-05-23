import 'package:flutter/material.dart';
import 'package:fantasy_f1_app/data/models/fantasy_team_model.dart';
import 'package:fantasy_f1_app/data/models/fantasy_league_model.dart';
import 'package:fantasy_f1_app/data/services/league_service.dart';
import 'package:fantasy_f1_app/views/widgets/modal_widget.dart';

class JoinLeagueModal extends StatefulWidget {
  final void Function(FantasyTeam) onJoined;
  const JoinLeagueModal({super.key, required this.onJoined});

  @override
  State<JoinLeagueModal> createState() => _JoinLeagueModalState();
}

class _JoinLeagueModalState extends State<JoinLeagueModal> {
  final _codeCtrl = TextEditingController();
  final _teamNameCtrl = TextEditingController();
  final _service = LeagueService();
  bool _loading = false;
  bool _previewing = false;
  FantasyLeague? _preview;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _teamNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _doPreview() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _previewing = true;
      _error = null;
      _preview = null;
    });
    try {
      final league = await _service.previewLeague(code);
      setState(() {
        _preview = league;
        _previewing = false;
        if (league == null) _error = 'No league found with this code.';
      });
    } catch (e) {
      setState(() {
        _previewing = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _submit() async {
    final teamName = _teamNameCtrl.text.trim();
    if (teamName.isEmpty) {
      setState(() => _error = 'Please enter your team name.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final team = await _service.joinLeague(
        inviteCode: _codeCtrl.text.trim(),
        teamName: teamName,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onJoined(team);
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModalShell(
      title: 'Join a League',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ModalTextField(
                  controller: _codeCtrl,
                  hint: 'Invite code (ex: F1-A3K9PX)',
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _previewing ? null : _doPreview,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _previewing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Search'),
              ),
            ],
          ),
          if (_preview != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE10600), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Color(0xFFE10600)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _preview!.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ModalTextField(controller: _teamNameCtrl, hint: 'Your team name'),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Color(0xFFE10600))),
          ],
          if (_preview != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE10600),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Join League',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
