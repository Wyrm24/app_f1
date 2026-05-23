import 'package:fantasy_f1_app/views/widgets/custom_app_bar.dart';

import 'package:fantasy_f1_app/views/widgets/liquid_navbar.dart';
import 'package:flutter/material.dart';

import 'package:fantasy_f1_app/data/notifiers.dart';
import 'package:fantasy_f1_app/views/pages/home_page.dart';
import 'package:fantasy_f1_app/views/pages/profile_page.dart';
import 'package:fantasy_f1_app/views/pages/league_page.dart';
import 'package:fantasy_f1_app/views/pages/quiz_page.dart';

List<Widget> pages = [
  const HomePage(),
  const LeaguePage(),
  const QuizPage(),
  const ProfilPage(),
];
List<String> pageTitles = ["Home", "League", "Quiz", "Profile"];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, value, child) {
        return Scaffold(
          // On étend le body pour que le contenu passe sous la nav bar glassmorphic
          extendBody: true,

          appBar: CustomAppBar(title: pageTitles[value]),

          // On remplace CustomNavBar par notre LiquidNavBar
          bottomNavigationBar: LiquidNavBar(
            currentIndex: value,
            onTabSelected: (int index) {
              // On met à jour le notifier pour changer de page
              selectedPageNotifier.value = index;
            },
          ),

          body: pages.elementAt(value),
        );
      },
    );
  }
}
