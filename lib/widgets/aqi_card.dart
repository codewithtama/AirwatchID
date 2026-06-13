import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';

class AqiCircleIndicator extends StatefulWidget {
  final int aqi;
  final double size;
  final bool animate;

  const AqiCircleIndicator({
    super.key,
    required this.aqi,
    this.size = 200,
    this.animate = true,
  });

  @override
  State<AqiCircleIndicator> createState() => _AqiCircleIndicatorState();
}

class _AqiCircleIndicatorState extends State<AqiCircleIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _initAnimations();
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  void _initAnimations() {
    final progress = math.min(widget.aqi / 300.0, 1.0);
    _progressAnim = Tween<double>(begin: 0.0, end: progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    final level = AqiColors.getLevelFromAqi(widget.aqi);
    _colorAnim = ColorTween(
      begin: AppTheme.border,
      end: level.color,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AqiCircleIndicator old) {
    super.didUpdateWidget(old);
    if (old.aqi != widget.aqi) {
      _initAnimations();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = AqiColors.getLevelFromAqi(widget.aqi);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _AqiPainter(
              progress: _progressAnim.value,
              color: _colorAnim.value ?? level.color,
              bgColor: AppTheme.border,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    level.icon,
                    style: TextStyle(fontSize: widget.size * 0.12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.aqi.toString(),
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: widget.size * 0.22,
                      fontWeight: FontWeight.w700,
                      color: _colorAnim.value ?? level.color,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'AQI',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: widget.size * 0.07,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AqiPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _AqiPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;
    final strokeWidth = size.width * 0.06;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, strokeWidth * 0.5);

    const startAngle = math.pi * 0.75;
    const totalAngle = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalAngle,
      false,
      bgPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalAngle * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_AqiPainter old) =>
      old.progress != progress || old.color != color;
}
