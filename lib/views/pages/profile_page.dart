import 'package:fantasy_f1_app/data/constants.dart';
import 'package:fantasy_f1_app/views/pages/account_settings_page.dart';
import 'package:fantasy_f1_app/views/pages/preferences_page.dart';
import 'package:fantasy_f1_app/views/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:fantasy_f1_app/data/notifiers.dart';
import 'package:fantasy_f1_app/views/pages/welcome_page.dart';
import 'package:fantasy_f1_app/data/services/supabase_auth_service.dart';

import 'profile_widgets.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  double get verticalPadding => KConstants.verticalPadding;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await SupabaseAuthService.instance.getProfile();
      if (mounted) setState(() => _profile = data);
    } catch (e) {
      debugPrint('[ProfilPage] Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await SupabaseAuthService.instance.signOut();
    selectedPageNotifier.value = 0;
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE10600)),
      );
    }

    final pseudo = _profile?['pseudo'] as String? ?? 'Racer';
    final avatarUrl = _profile?['avatar_url'] as String?;
    final flagCode = _profile?['flag_code'] as String?;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: verticalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 24),

            // AVATAR + PSEUDO + FLAG
            ProfileHeader(
              pseudo: pseudo,
              avatarUrl: avatarUrl,
              flagCode: flagCode,
            ),

            const SizedBox(height: 28),

            //STATISTICS
            const SectionTitleWidget(title: "Statistics"),
            const SizedBox(height: 12),
            const ProfileStatsCard(),

            const SizedBox(height: 28),

            //LEAGUES TROPHIES
            const SectionTitleWidget(title: "Leagues Trophies"),
            const SizedBox(height: 12),
            const ProfileTrophyCard(),

            const SizedBox(height: 28),

            //SETTING
            ProfileCardContainer(
              child: Column(
                children: [
                  ProfileSettingsItem(
                    label: "Account settings",
                    icon: Icons.person_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AccountSettingsPage(initialProfile: _profile),
                        ),
                      ).then(
                        (_) => _loadProfile(),
                      ); // Recharge le profil au retour
                    },
                  ),
                  const ProfileSettingsDivider(),
                  ProfileSettingsItem(
                    label: "Notification",
                    icon: Icons.notifications_outlined,
                    onTap: () {
                      // Future Notification Page
                    },
                  ),
                  const ProfileSettingsDivider(),
                  ProfileSettingsItem(
                    label: "Preferences",
                    icon: Icons.tune_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PreferencesPage(),
                        ),
                      );
                    },
                  ),
                  const ProfileSettingsDivider(),
                  ProfileSettingsItem(
                    label: "Log out",
                    icon: Icons.logout,
                    isDestructive: true,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
