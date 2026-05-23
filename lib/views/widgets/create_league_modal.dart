import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantasy_f1_app/data/models/fantasy_team_model.dart';
import 'package:fantasy_f1_app/data/services/league_service.dart';
import 'package:fantasy_f1_app/views/widgets/modal_widget.dart';

class CreateLeagueModal extends StatefulWidget {
  final void Function(FantasyTeam) onCreated;
  const CreateLeagueModal({super.key, required this.onCreated});

  @override
  State<CreateLeagueModal> createState() => _CreateLeagueModalState();
}

class _CreateLeagueModalState extends State<CreateLeagueModal> {
  // Étape courante
  int _step = 0;
  static const int _totalSteps = 4;

  final _leagueNameCtrl = TextEditingController();
  final _teamNameCtrl = TextEditingController();
  final _service = LeagueService();
  final _client = Supabase.instance.client;

  // Données collectées
  File? _imageFile;
  bool _isPublic = true;
  int _gpCount = 10;

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _leagueNameCtrl.dispose();
    _teamNameCtrl.dispose();
    super.dispose();
  }

  // Navigation entre étapes
  void _next() {
    if (_step == 0) {
      if (_leagueNameCtrl.text.trim().isEmpty ||
          _teamNameCtrl.text.trim().isEmpty) {
        setState(() => _error = 'Please fill in all fields.');
        return;
      }
    }
    setState(() {
      _error = null;
      if (_step < _totalSteps - 1) _step++;
    });
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  // Upload image vers Supabase
  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;
    final userId = _client.auth.currentUser!.id;
    final ext = _imageFile!.path.split('.').last.toLowerCase();
    final path = '$userId/league_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage
        .from('league-images')
        .upload(
          path,
          _imageFile!,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('league-images').getPublicUrl(path);
  }

  // Soumission finale
  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      String? imageUrl;
      try {
        imageUrl = await _uploadImage();
      } catch (_) {
        // Upload optionnel, on continue sans image
      }

      final team = await _service.createLeague(
        leagueName: _leagueNameCtrl.text.trim(),
        teamName: _teamNameCtrl.text.trim(),
        imageUrl: imageUrl,
        isPublic: _isPublic,
        gpCount: _gpCount,
      );

      if (mounted) {
        widget.onCreated(team);
        _showInviteCode(
          context,
          team.league!.inviteCode,
          _leagueNameCtrl.text.trim(),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // Dialog code d'invitation
  void _showInviteCode(BuildContext ctx, String code, String leagueName) {
    final colorScheme = Theme.of(ctx).colorScheme;
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'League created! 🏎️',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share this code to join "$leagueName":',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: colorScheme.onSurfaceVariant),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Code copied!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE10600),
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // Sélecteur d'image
  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text(
                'Take a photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Dispatch étapes
  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepName();
      case 1:
        return _stepImage();
      case 2:
        return _stepVisibility();
      case 3:
        return _stepGpCount();
      default:
        return const SizedBox();
    }
  }

  // Étape 1 — Nom
  Widget _stepName() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _badge('STEP 01 / 04'),
        const SizedBox(height: 14),
        Text(
          'Name your\nleague.',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Give your league and team a name.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 28),
        ModalTextField(
          controller: _leagueNameCtrl,
          hint: 'League name (ex: Friends F1)',
        ),
        const SizedBox(height: 12),
        ModalTextField(controller: _teamNameCtrl, hint: 'Your team name'),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: Color(0xFFE10600))),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  // Étape 2 — Image
  Widget _stepImage() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _badge('STEP 02 / 04'),
        const SizedBox(height: 14),
        Text(
          'Add a league\ncover image.',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Optional — shown at the top of your league.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 28),

        // Zone image
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _imageFile != null
                    ? const Color(0xFFE10600)
                    : colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap to choose a photo',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        if (_imageFile != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(() => _imageFile = null),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Remove image'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade500),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  // Étape 3 — Visibilité
  Widget _stepVisibility() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _badge('STEP 03 / 04'),
        const SizedBox(height: 14),
        Text(
          'Public or\nprivate?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Private leagues require an invite code to join.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: _VisibilityCard(
                label: 'Public',
                description: 'Anyone can find\nand join.',
                icon: Icons.public,
                selected: _isPublic,
                onTap: () => setState(() => _isPublic = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _VisibilityCard(
                label: 'Private',
                description: 'Invite code\nrequired.',
                icon: Icons.lock_outline,
                selected: !_isPublic,
                onTap: () => setState(() => _isPublic = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Étape 4 — Nombre de GP
  Widget _stepGpCount() {
    final colorScheme = Theme.of(context).colorScheme;
    const options = [5, 10, 15, 24];
    const labels = ['5 GPs', '10 GPs', '15 GPs', 'All GPs'];

    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _badge('STEP 04 / 04'),
        const SizedBox(height: 14),
        Text(
          'How many\nGrand Prix?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Set the season length for your league.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 28),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: List.generate(options.length, (i) {
            final selected = _gpCount == options[i];
            return GestureDetector(
              onTap: () => setState(() => _gpCount = options[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFE10600).withOpacity(0.08)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFE10600)
                        : colorScheme.outlineVariant,
                    width: selected ? 2 : 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: selected
                            ? const Color(0xFFE10600)
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (options[i] == 24)
                      Text(
                        'Full season',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Color(0xFFE10600))),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  // Barre de progression
  Widget _buildProgressBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(_totalSteps, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: i <= _step
                  ? const Color(0xFFE10600)
                  : colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  // Boutons de navigation
  Widget _buildNavButtons() {
    final isLastStep = _step == _totalSteps - 1;
    return Row(
      children: [
        if (_step > 0) ...[
          SizedBox(
            width: 52,
            height: 52,
            child: OutlinedButton(
              onPressed: _prev,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : (isLastStep ? _submit : _next),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE10600),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep ? "Create League 🏁" : "Continue",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!isLastStep) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios, size: 14),
                        ],
                      ],
                    ),
            ),
          ),
        ),
        // Skip sur l'étape image
        if (_step == 1) ...[
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => setState(() => _step++),
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Badge étape
  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE10600),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Barre de progression
                _buildProgressBar(),
                const SizedBox(height: 24),

                // Contenu étape avec animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.06, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(parent: anim, curve: Curves.easeOut),
                        ),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: _buildStep(),
                ),

                const SizedBox(height: 16),
                _buildNavButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Carte Public / Private

class _VisibilityCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE10600).withOpacity(0.08)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFFE10600)
                : colorScheme.outlineVariant,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFFE10600)
                  : colorScheme.onSurfaceVariant,
              size: 26,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: selected
                    ? const Color(0xFFE10600)
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
