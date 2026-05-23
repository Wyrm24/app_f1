import 'package:flutter/material.dart';
import 'package:fantasy_f1_app/data/notifiers.dart';
import 'package:fantasy_f1_app/data/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_widgets.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  void _toggleTheme(bool value) async {
    isDarkNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KConstants.themeModeKey, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preferences")),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const ProfileSectionTitle(title: "Display"),
          const SizedBox(height: 12),

          ProfileCardContainer(
            child: ValueListenableBuilder<bool>(
              valueListenable: isDarkNotifier,
              builder: (context, isDark, child) {
                return SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.amber : Colors.blueGrey,
                  ),
                  title: const Text(
                    "Dark Mode",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isDark ? "Enable light theme" : "Enable dark theme",
                  ),
                  activeColor: const Color(0xFFE10600),
                  value: isDark,
                  onChanged: _toggleTheme, // sauvegarde + notifier
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          const ProfileSectionTitle(title: "Language"),
          const SizedBox(height: 12),

          ProfileCardContainer(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text("App Language"),
              trailing: const Text("English (US)"),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
