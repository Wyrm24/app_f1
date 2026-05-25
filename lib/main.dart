import 'package:fantasy_f1_app/viewmodels/league_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantasy_f1_app/data/constants.dart';
import 'package:fantasy_f1_app/data/notifiers.dart';
import 'package:fantasy_f1_app/views/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fantasy_f1_app/core/theme.dart';
import 'package:provider/provider.dart';
import 'package:fantasy_f1_app/viewmodels/home_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'VIDE',
  );
  const supabaseKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'VIDE',
  );
  debugPrint('==============URL: $supabaseUrl');
  debugPrint('==============KEY: $supabaseKey');

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  // await Supabase.initialize(
  //   url: 'https://yzonecxeqbtdijrbywue.supabase.co',
  //   anonKey:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl6b25lY3hlcWJ0ZGlqcmJ5d3VlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzNDE2MDcsImV4cCI6MjA4ODkxNzYwN30.1Ij9sWreDJZW1H0Cn9v6_TsXYLO5p0QMZBLbgGBHLc8',
  // );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    initThemeMode();
    super.initState();
  }

  void initThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? repeat = prefs.getBool(KConstants.themeModeKey);
    isDarkNotifier.value = repeat ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => LeagueViewModel()),
      ],
      child: ValueListenableBuilder(
        valueListenable: isDarkNotifier,
        builder: (context, isDark, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: F1Theme.lightTheme,
            darkTheme: F1Theme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
