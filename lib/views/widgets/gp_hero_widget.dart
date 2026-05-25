import 'dart:async';
import 'package:flutter/material.dart';

class GpHeroWidget extends StatefulWidget {
  final String raceName;
  final String city;
  final String country;
  final String imagePath;
  final DateTime raceDate;
  final VoidCallback onViewDetails;

  const GpHeroWidget({
    super.key,
    required this.raceName,
    required this.city,
    required this.country,
    required this.imagePath,
    required this.raceDate,
    required this.onViewDetails,
  });

  @override
  State<GpHeroWidget> createState() => _GpHeroWidgetState();
}

class _GpHeroWidgetState extends State<GpHeroWidget> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    final diff = widget.raceDate.difference(DateTime.now());
    if (mounted) {
      setState(() => _timeLeft = diff.isNegative ? Duration.zero : diff);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours % 24;
    final minutes = _timeLeft.inMinutes % 60;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // Image de fond
          Hero(
            tag: 'gp-hero-${widget.raceName}',
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: widget.imagePath.startsWith('http')
                  ? Image.network(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallback(),
                    )
                  : Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallback(),
                    ),
            ),
          ),

          // Gradient
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Contenu
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Nom + lieu + countdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.raceName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${widget.city}, ${widget.country}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Countdown pills
                        Row(
                          children: [
                            _Pill(value: days, label: 'd'),
                            const SizedBox(width: 6),
                            _Pill(value: hours, label: 'h'),
                            const SizedBox(width: 6),
                            _Pill(value: minutes, label: 'm'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bouton View details
                  ElevatedButton(
                    onPressed: widget.onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE10600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'View details',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(color: Colors.black87, height: 200);
}

class _Pill extends StatelessWidget {
  final int value;
  final String label;
  const _Pill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '$value$label',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
