import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantasy_f1_app/views/pages/welcome_page.dart';
import 'package:fantasy_f1_app/views/widget_tree.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lineController;
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _exitController;

  late Animation<double> _lineWidth;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _lineWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
        );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _exitOpacity = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeIn));
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _lineController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    await _exitController.forward();

    if (!mounted) return;

    final hasSession = Supabase.instance.client.auth.currentSession != null;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            hasSession ? const WidgetTree() : const WelcomePage(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _lineController.dispose();
    _logoController.dispose();
    _taglineController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // On récupère les couleurs du thème actuel
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const f1Red = Color(0xFFE10600); // Le rouge F1 reste constant

    return FadeTransition(
      opacity: _exitOpacity,
      child: Scaffold(
        // Fond adaptatif (Blanc en Light, Noir en Dark)
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo FANTASY
              SlideTransition(
                position: _logoSlide,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Text(
                    'FANTASY',
                    style: TextStyle(
                      // Texte noir en Light, blanc en Dark
                      color: colorScheme.onSurface,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Ligne rouge animée
              AnimatedBuilder(
                animation: _lineWidth,
                builder: (context, _) {
                  return Container(
                    width: 260 * _lineWidth.value,
                    height: 3,
                    decoration: BoxDecoration(
                      color: f1Red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // F1
              SlideTransition(
                position: _logoSlide,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: const Text(
                    'F1',
                    style: TextStyle(
                      color: f1Red,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      height: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tagline
              SlideTransition(
                position: _taglineSlide,
                child: FadeTransition(
                  opacity: _taglineOpacity,
                  child: Text(
                    'Build your team. Own the race.',
                    style: TextStyle(
                      // Utilise la couleur de texte secondaire du thème avec opacité
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 13,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
