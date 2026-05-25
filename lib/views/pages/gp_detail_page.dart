import 'package:fantasy_f1_app/viewmodels/gp_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GpDetailPage extends StatelessWidget {
  const GpDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GpDetailViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          _GpSliverAppBar(vm: vm),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _CountdownCard(vm: vm, cardColor: cardColor),
                  const SizedBox(height: 12),
                  _CircuitCard(vm: vm, cardColor: cardColor),
                  const SizedBox(height: 12),

                  // Météo — skeleton pendant le chargement en arrière-plan
                  vm.isLoadingWeather
                      ? _WeatherSkeleton(cardColor: cardColor)
                      : _WeatherCard(vm: vm, cardColor: cardColor),

                  const SizedBox(height: 12),
                  _ScheduleCard(vm: vm, cardColor: cardColor),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Hero sliver
class _GpSliverAppBar extends StatelessWidget {
  final GpDetailViewModel vm;
  const _GpSliverAppBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final raceName = vm.race?['name'] ?? 'Grand Prix';
    final city = vm.race?['city'] ?? '';
    final heroUrl = vm.race?['hero_image_url'] ?? '';

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFFE10600),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
      ],
      title: Text(
        raceName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image — tag partagé avec GpHeroWidget
            Hero(tag: 'gp-hero-$raceName', child: _buildHeroImage(heroUrl)),

            // Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            // Nom + ville
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    raceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    city,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(String url) {
    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(color: Colors.black87),
      );
    }
    return Image.asset('assets/images/melbourne.jpg', fit: BoxFit.cover);
  }
}

// Countdown
class _CountdownCard extends StatelessWidget {
  final GpDetailViewModel vm;
  final Color cardColor;
  const _CountdownCard({required this.vm, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final raceDate = vm.raceDateTime;
    final timeLeft = raceDate != null
        ? raceDate.difference(DateTime.now())
        : Duration.zero;
    final d = timeLeft.inDays;
    final h = timeLeft.inHours % 24;
    final m = timeLeft.inMinutes % 60;

    return _Card(
      cardColor: cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: Color(0xFFE10600),
          ),
          const SizedBox(width: 8),
          Text(
            vm.raceDateFormatted,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 20, color: Colors.grey.shade300),
          const SizedBox(width: 16),
          _CountdownChip(value: d, label: 'd'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('|', style: TextStyle(color: Colors.grey)),
          ),
          _CountdownChip(value: h, label: 'h'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('|', style: TextStyle(color: Colors.grey)),
          ),
          _CountdownChip(value: m, label: 'm'),
        ],
      ),
    );
  }
}

class _CountdownChip extends StatelessWidget {
  final int value;
  final String label;
  const _CountdownChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$value$label',
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
    );
  }
}

// Circuit
class _CircuitCard extends StatelessWidget {
  final GpDetailViewModel vm;
  final Color cardColor;
  const _CircuitCard({required this.vm, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final circuitName = vm.race?['circuit_name'] ?? '';
    final circuitType = vm.race?['circuit_type'] ?? '';
    final imageUrl = vm.race?['circuit_image_url'] ?? '';

    return _Card(
      cardColor: cardColor,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  circuitName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Tracé circuit recoloré en rouge
                imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 110,
                        color: const Color(0xFFE10600),
                        colorBlendMode: BlendMode.srcIn,
                        errorBuilder: (_, _, _) => const _CircuitPlaceholder(),
                      )
                    : const _CircuitPlaceholder(),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _CircuitStat(label: 'Distance', value: vm.circuitLength),
              const SizedBox(height: 16),
              _CircuitStat(
                label: 'Laps',
                value: vm.laps != null ? '${vm.laps}' : '—',
              ),
              const SizedBox(height: 16),
              _CircuitStat(
                label: 'Type',
                value: circuitType.isNotEmpty ? circuitType : '—',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircuitPlaceholder extends StatelessWidget {
  const _CircuitPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 110,
      child: Icon(Icons.map_outlined, size: 48, color: Color(0xFFE10600)),
    );
  }
}

class _CircuitStat extends StatelessWidget {
  final String label;
  final String value;
  const _CircuitStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

// Météo
class _WeatherCard extends StatelessWidget {
  final GpDetailViewModel vm;
  final Color cardColor;
  const _WeatherCard({required this.vm, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final w = vm.weather;

    return _Card(
      cardColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          const Text(
            'Weather Forecast',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          w == null
              ? const Text(
                  'No weather data',
                  style: TextStyle(color: Colors.grey),
                )
              : Row(
                  children: [
                    Icon(w.icon, color: Colors.orange, size: 36),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.description,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${w.airTemp.toStringAsFixed(0)}° air',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Précipitations
                    _WeatherStat(
                      icon: Icons.water_drop_outlined,
                      value: '${w.precipitationProbability}%',
                    ),
                    const SizedBox(width: 16),

                    // Vent
                    _WeatherStat(
                      icon: Icons.air,
                      value: '${w.windSpeed.toStringAsFixed(0)} km/h',
                    ),
                    const SizedBox(width: 16),

                    // Temp piste
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE10600).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${w.trackTemp.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE10600),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _WeatherStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// Skeleton météo pendant le chargement
class _WeatherSkeleton extends StatelessWidget {
  final Color cardColor;
  const _WeatherSkeleton({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return _Card(
      cardColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weather Forecast',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Shimmer(width: 36, height: 36, radius: 18),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(width: 80, height: 12),
                  const SizedBox(height: 6),
                  _Shimmer(width: 50, height: 10),
                ],
              ),
              const Spacer(),
              _Shimmer(width: 40, height: 40, radius: 8),
            ],
          ),
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _Shimmer({required this.width, required this.height, this.radius = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// Schedule
class _ScheduleCard extends StatelessWidget {
  final GpDetailViewModel vm;
  final Color cardColor;
  const _ScheduleCard({required this.vm, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final sessions = vm.sessions;

    return _Card(
      cardColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            const Text(
              'No sessions available',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...sessions.map((s) => _SessionRow(session: s)),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final Map<String, String> session;
  const _SessionRow({required this.session});

  bool get _isRace => session['key'] == 'race';
  bool get _isSprint => session['key'] == 'sprint';

  @override
  Widget build(BuildContext context) {
    final accent = _isRace || _isSprint;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 18,
            color: accent ? const Color(0xFFE10600) : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              session['label']!,
              style: TextStyle(
                fontWeight: accent ? FontWeight.w800 : FontWeight.w500,
                color: accent ? const Color(0xFFE10600) : null,
              ),
            ),
          ),
          Text(
            session['day']!,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(width: 12),
          Text(
            session['time']!,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: accent ? const Color(0xFFE10600) : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Card réutilisable
class _Card extends StatelessWidget {
  final Color cardColor;
  final Widget child;
  const _Card({required this.cardColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
