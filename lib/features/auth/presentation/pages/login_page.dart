import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _handleLogin(BuildContext context) {
    try {
      final box = Hive.box(AppConstants.hiveSettingsBox);
      final completed = box.get('completed_onboarding', defaultValue: false) as bool;
      if (!completed) {
        context.go('/onboarding');
      } else {
        context.go('/home');
      }
    } catch (_) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background particles
          const _AnimatedBackground(),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Logo
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withAlpha(102), blurRadius: 30, spreadRadius: 4),
                      ],
                    ),
                    child: const Center(
                      child: Text('⚡', style: TextStyle(fontSize: 48)),
                    ),
                  ).animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 1000.ms),

                  const SizedBox(height: 24),

                  // App name
                  Text(
                    'VibeForge',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      foreground: Paint()..shader = LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.3),

                  const SizedBox(height: 8),
                  Text(
                    'Forge Your Best Self',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondaryDark,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                  const Spacer(flex: 2),

                  // Google Sign-In Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.blue)),
                      label: const Text('Sign in with Google', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.2),

                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _handleLogin(context),
                    child: Text('Continue as Guest', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'Your data stays private & encrypted on device',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiaryDark),
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _rand = Random(42);
  late List<_BgParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _particles = List.generate(30, (_) => _BgParticle(
      x: _rand.nextDouble(), y: _rand.nextDouble(),
      size: _rand.nextDouble() * 3 + 1,
      speed: _rand.nextDouble() * 0.02 + 0.005,
      color: AppColors.chartColors[_rand.nextInt(AppColors.chartColors.length)],
    ));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: _BgPainter(_particles, _controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _BgParticle {
  double x, y, size, speed;
  Color color;
  _BgParticle({required this.x, required this.y, required this.size, required this.speed, required this.color});
}

class _BgPainter extends CustomPainter {
  final List<_BgParticle> particles;
  final double t;
  _BgPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.y + p.speed * t * 50) % 1.0;
      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.size,
        Paint()..color = p.color.withAlpha(38)..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => true;
}
