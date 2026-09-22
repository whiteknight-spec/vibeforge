import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated floating orb that fills/glows based on daily completion %.
class ProgressOrb extends StatefulWidget {
  final double completionRate;
  final int completedCount;
  final int totalCount;

  const ProgressOrb({
    super.key,
    required this.completionRate,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  State<ProgressOrb> createState() => _ProgressOrbState();
}

class _ProgressOrbState extends State<ProgressOrb> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fillController;
  late Animation<double> _pulseAnim;
  late Animation<double> _fillAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _fillController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fillAnim = Tween<double>(begin: 0, end: widget.completionRate).animate(CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic));
    _fillController.forward();
  }

  @override
  void didUpdateWidget(ProgressOrb old) {
    super.didUpdateWidget(old);
    if (old.completionRate != widget.completionRate) {
      _fillAnim = Tween<double>(begin: _fillAnim.value, end: widget.completionRate)
          .animate(CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic));
      _fillController.forward(from: 0);
    }
  }

  @override
  void dispose() { _pulseController.dispose(); _fillController.dispose(); super.dispose(); }

  Color _orbColor(double rate) {
    if (rate >= 1.0) return AppColors.success;
    if (rate >= 0.5) return AppColors.primary;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _fillAnim]),
      builder: (context, child) {
        final fill = _fillAnim.value;
        final color = _orbColor(fill);
        return Transform.scale(
          scale: _pulseAnim.value,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withAlpha((fill * 100).round()), blurRadius: 30 + fill * 20, spreadRadius: fill * 8),
                BoxShadow(color: color.withAlpha((fill * 40).round()), blurRadius: 60, spreadRadius: fill * 12),
              ],
            ),
            child: CustomPaint(
              painter: _OrbPainter(fillRate: fill, color: color),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(fill * 100).round()}%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        shadows: [Shadow(color: color.withAlpha(153), blurRadius: 12)],
                      ),
                    ),
                    Text(
                      '${widget.completedCount}/${widget.totalCount}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double fillRate;
  final Color color;
  _OrbPainter({required this.fillRate, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    canvas.drawCircle(center, radius, Paint()..color = AppColors.surfaceAltDark);

    // Fill arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -pi / 2, 2 * pi * fillRate, true, Paint()..color = color.withAlpha(51));

    // Border ring
    canvas.drawCircle(center, radius - 2, Paint()
      ..color = color.withAlpha(77)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);

    // Progress arc
    canvas.drawArc(rect.deflate(2), -pi / 2, 2 * pi * fillRate, false, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) => old.fillRate != fillRate || old.color != color;
}
