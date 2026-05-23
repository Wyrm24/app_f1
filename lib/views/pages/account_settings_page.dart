import 'package:flutter/material.dart';

import 'profile_widgets.dart';

class AccountSettingsPage extends StatefulWidget {
  final Map<String, dynamic>? initialProfile;
  const AccountSettingsPage({super.key, this.initialProfile});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _pseudoController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _pseudoController.text = widget.initialProfile?['pseudo'] ?? '';
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      // Logique pour update sur Supabase (à adapter selon ton service)
      // await SupabaseAuthService.instance.updateProfile(pseudo: _pseudoController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Settings"),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                "SAVE",
                style: TextStyle(
                  color: Color(0xFFE10600),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ProfileSectionTitle(title: "Public Identity"),
            const SizedBox(height: 12),
            ProfileCardContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _pseudoController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    hintText: "Enter your racer name",
                    border: InputBorder.none,
                    icon: Icon(Icons.edit_outlined),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
