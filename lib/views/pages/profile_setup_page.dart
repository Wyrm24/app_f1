import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantasy_f1_app/views/widget_tree.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _pseudoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _client = Supabase.instance.client;

  File? _avatarFile;
  String? _selectedFlagCode;
  bool _isLoading = false;
  String? _errorMessage;
  int _step = 0;

  @override
  void dispose() {
    _pseudoController.dispose();
    super.dispose();
  }

  // ── Image picker ─────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _avatarFile = File(picked.path));
  }

  // ── Upload avatar ─────────────────────────────────────────────
  // Chemin : {userId}/avatar.{ext}
  // La policy RLS vérifie que le 1er segment = auth.uid() → ça matche.
  Future<String?> _uploadAvatar(String userId) async {
    if (_avatarFile == null) return null;
    final ext = _avatarFile!.path.split('.').last.toLowerCase();
    final path = '$userId/avatar.$ext'; // ← dossier = userId

    await _client.storage
        .from('profiles')
        .upload(
          path,
          _avatarFile!,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('profiles').getPublicUrl(path);
  }

  // ── Sauvegarde finale ─────────────────────────────────────────
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final user = _client.auth.currentUser!;
    String? avatarUrl;

    // Upload avatar — on continue même si ça échoue
    try {
      avatarUrl = await _uploadAvatar(user.id);
    } on StorageException catch (e) {
      debugPrint('[ProfileSetup] Storage error (non-bloquant): ${e.message}');
    }

    // Sauvegarde profil
    try {
      await _client.from('profiles').upsert({
        'id': user.id,
        'pseudo': _pseudoController.text.trim(),
        'email': user.email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (_selectedFlagCode != null) 'flag_code': _selectedFlagCode,
      });

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WidgetTree()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _errorMessage = 'Error saving profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Navigation ────────────────────────────────────────────────
  void _nextStep() {
    if (_step == 0 && !_formKey.currentState!.validate()) return;
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _saveProfile();
    }
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) => SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.08, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: _buildStep(),
                  ),
                ),
              ),
            ),
            _buildNavButtons(),
          ],
        ),
      ),
    );
  }

  // ── Progress bar ──────────────────────────────────────────────
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 8),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: i <= _step
                    ? const Color(0xFFE10600)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepPseudo();
      case 1:
        return _stepAvatar();
      case 2:
        return _stepFlag();
      default:
        return const SizedBox();
    }
  }

  // ── STEP 1 : Pseudo ───────────────────────────────────────────
  Widget _stepPseudo() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _badge("STEP 01 / 03"),
        const SizedBox(height: 16),
        const Text(
          'Choose your\ndriver name.',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This is how other racers will know you.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
        const SizedBox(height: 36),
        TextFormField(
          controller: _pseudoController,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _nextStep(),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'e.g. max_racing_33',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F7F7),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            prefixIcon: const Icon(
              Icons.alternate_email,
              color: Color(0xFFE10600),
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE10600),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE10600),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE10600),
                width: 1.5,
              ),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (v.trim().length < 3) return 'At least 3 characters';
            if (v.contains(' ')) return 'No spaces allowed';
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
              return 'Letters, numbers and _ only';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        Text(
          'Letters, numbers and underscores only.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  // ── STEP 2 : Avatar ───────────────────────────────────────────
  Widget _stepAvatar() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _badge("STEP 02 / 03"),
        const SizedBox(height: 16),
        const Text(
          'Add your\nphoto.',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Optional — you can skip this step.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
        const SizedBox(height: 40),

        // Avatar preview
        Center(
          child: GestureDetector(
            onTap: _showImageSourceSheet,
            child: Stack(
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF3F3F3),
                    border: Border.all(
                      color: _avatarFile != null
                          ? const Color(0xFFE10600)
                          : Colors.grey.shade200,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: _avatarFile != null
                        ? Image.file(_avatarFile!, fit: BoxFit.cover)
                        : Icon(
                            Icons.person,
                            size: 56,
                            color: Colors.grey.shade300,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE10600),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _sourceButton(
                Icons.photo_library_outlined,
                "Gallery",
                () => _pickImage(ImageSource.gallery),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _sourceButton(
                Icons.camera_alt_outlined,
                "Camera",
                () => _pickImage(ImageSource.camera),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── STEP 3 : Drapeau ──────────────────────────────────────────
  Widget _stepFlag() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _badge("STEP 03 / 03"),
        const SizedBox(height: 16),
        const Text(
          'Your\ncountry.',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Represent your nation on the grid.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
        const SizedBox(height: 28),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: _countries.length,
          itemBuilder: (context, i) {
            final c = _countries[i];
            final selected = _selectedFlagCode == c['code'];
            return GestureDetector(
              onTap: () => setState(() => _selectedFlagCode = c['code']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFEEEE)
                      : const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFE10600)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(c['flag']!, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 3),
                    Text(
                      c['code']!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? const Color(0xFFE10600)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFFE10600),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Nav buttons ───────────────────────────────────────────────
  Widget _buildNavButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
      child: Row(
        children: [
          if (_step > 0) ...[
            SizedBox(
              width: 52,
              height: 52,
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: BorderSide(color: Colors.grey.shade200),
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
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE10600),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
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
                            _step == 2 ? "Let's race! 🏁" : "Continue",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_step < 2) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ],
                      ),
              ),
            ),
          ),
          if (_step == 1) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => setState(() => _step++),
              child: Text(
                "Skip",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
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

  Widget _sourceButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(
                "Choose from gallery",
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
                "Take a photo",
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

  // ── Pays ──────────────────────────────────────────────────────
  static const List<Map<String, String>> _countries = [
    {'code': 'AR', 'flag': '🇦🇷'},
    {'code': 'AU', 'flag': '🇦🇺'},
    {'code': 'AT', 'flag': '🇦🇹'},
    {'code': 'BE', 'flag': '🇧🇪'},
    {'code': 'BR', 'flag': '🇧🇷'},
    {'code': 'CA', 'flag': '🇨🇦'},
    {'code': 'CN', 'flag': '🇨🇳'},
    {'code': 'DK', 'flag': '🇩🇰'},
    {'code': 'FI', 'flag': '🇫🇮'},
    {'code': 'FR', 'flag': '🇫🇷'},
    {'code': 'DE', 'flag': '🇩🇪'},
    {'code': 'HU', 'flag': '🇭🇺'},
    {'code': 'IT', 'flag': '🇮🇹'},
    {'code': 'JP', 'flag': '🇯🇵'},
    {'code': 'MX', 'flag': '🇲🇽'},
    {'code': 'MC', 'flag': '🇲🇨'},
    {'code': 'NL', 'flag': '🇳🇱'},
    {'code': 'NZ', 'flag': '🇳🇿'},
    {'code': 'NO', 'flag': '🇳🇴'},
    {'code': 'PL', 'flag': '🇵🇱'},
    {'code': 'PT', 'flag': '🇵🇹'},
    {'code': 'ES', 'flag': '🇪🇸'},
    {'code': 'SE', 'flag': '🇸🇪'},
    {'code': 'CH', 'flag': '🇨🇭'},
    {'code': 'GB', 'flag': '🇬🇧'},
    {'code': 'US', 'flag': '🇺🇸'},
    {'code': 'AE', 'flag': '🇦🇪'},
    {'code': 'SA', 'flag': '🇸🇦'},
    {'code': 'TH', 'flag': '🇹🇭'},
    {'code': 'RU', 'flag': '🇷🇺'},
  ];
}
