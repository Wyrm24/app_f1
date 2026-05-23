import 'package:flutter/material.dart';
import 'package:fantasy_f1_app/views/pages/login_page.dart';
import 'package:fantasy_f1_app/views/pages/register_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  // ── Logo / Tag ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE10600),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'FANTASY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Titre principal ──────────────────────────────
                  const Text(
                    'Formula\nOne.',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.05,
                      letterSpacing: -1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Ligne rouge décorative ───────────────────────
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE10600),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Sous-titre ───────────────────────────────────
                  Text(
                    'Build your dream team.\nCompete with friends.\nDominate the season.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Bouton principal : Get Started ───────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE10600),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Get started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Bouton secondaire : Login ────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'I already have an account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
