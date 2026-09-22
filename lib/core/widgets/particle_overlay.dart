import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-screen particle celebration overlay.
class ParticleOverlay extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onComplete;
  final Duration duration;

  const ParticleOverlay({
    super.key,
    this.isActive = false,
    this.onComplete,
    this.duration = const Duration(milliseconds: 3000),
  });

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete?.call(); });
    _particles = [];
  }

  @override
  void didUpdateWidget(ParticleOverlay old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _particles = List.generate(80, (_) => _Particle(
        x: _rand.nextDouble(), y: _rand.nextDouble() * 0.3 + 0.3,
        vx: (_rand.nextDouble() - 0.5) * 2, vy: -_rand.nextDouble() * 3 - 1,
        size: _rand.nextDouble() * 6 + 2,
        color: AppColors.chartColors[_rand.nextInt(AppColors.chartColors.length)],
        rotation: _rand.nextDouble() * pi * 2,
        rotSpeed: (_rand.nextDouble() - 0.5) * 4,
        shape: _rand.nextInt(3),
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive && !_controller.isAnimating) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(animation: _controller, builder: (context, child) =>
        CustomPaint(painter: _ParticlePainter(_particles, _controller.value), size: Size.infinite)),
    );
  }
}

class _Particle {
  double x, y, vx, vy, size, rotation, rotSpeed;
  Color color;
  int shape;
  _Particle({required this.x, required this.y, required this.vx, required this.vy,
    required this.size, required this.color, required this.rotation, required this.rotSpeed, required this.shape});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = progress;
      final x = (p.x + p.vx * t * 0.15) * size.width;
      final y = (p.y + p.vy * t * 0.15 + 2 * t * t * 0.1) * size.height;
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      final s = p.size * (1.0 - t * 0.5);
      if (opacity <= 0 || s <= 0) continue;

      final paint = Paint()..color = p.color.withAlpha((opacity * 255).round());
      final glow = Paint()..color = p.color.withAlpha((opacity * 77).round())..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotSpeed * t);
      if (p.shape == 0) { canvas.drawCircle(Offset.zero, s, glow); canvas.drawCircle(Offset.zero, s, paint); }
      else if (p.shape == 1) { final r = Rect.fromCenter(center: Offset.zero, width: s * 2, height: s * 2); canvas.drawRect(r, glow); canvas.drawRect(r, paint); }
      else { final path = Path()..moveTo(0, -s)..lineTo(s * 0.5, 0)..lineTo(0, s)..lineTo(-s * 0.5, 0)..close(); canvas.drawPath(path, glow); canvas.drawPath(path, paint); }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.progress != progress;
}
