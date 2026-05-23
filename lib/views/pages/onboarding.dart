import 'package:flutter/material.dart';
import 'package:fantasy_f1_app/data/constants.dart';
import 'package:fantasy_f1_app/views/pages/login_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20.0),

                SizedBox(height: 20.0),
                Text(
                  'Flutter isoj jjjqf jhofhqsh fhuhsqfu hsh uhu hhuhusoqjsqjooo',
                  style: KTextStyle.descriptionText,
                  textAlign: TextAlign.justify,
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginPage();
                        },
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 40.0),
                  ),
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
