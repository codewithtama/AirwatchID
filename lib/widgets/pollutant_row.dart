import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';

class PollutantRowData {
  final String name;
  final String shortName;
  final double value;
  final String unit;
  final double maxValue;

  const PollutantRowData({
    required this.name,
    required this.shortName,
    required this.value,
    required this.unit,
    required this.maxValue,
  });

  double get normalizedValue => (value / maxValue).clamp(0.0, 1.0);
}

class PollutantRow extends StatefulWidget {
  final PollutantRowData data;
  final bool animate;

  const PollutantRow({
    super.key,
    required this.data,
    this.animate = true,
  });

  @override
  State<PollutantRow> createState() => _PollutantRowState();
}

class _PollutantRowState extends State<PollutantRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _widthAnim = Tween<double>(begin: 0, end: widget.data.normalizedValue)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.animate) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _barColor() {
    final ratio = widget.data.normalizedValue;
    if (ratio < 0.33) return AqiColors.baik;
    if (ratio < 0.66) return AqiColors.sedang;
    if (ratio < 0.85) return AqiColors.tidakSehat;
    return AqiColors.berbahaya;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.data.name,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                AqiUtils.formatPollutantValue(widget.data.value, widget.data.unit),
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _barColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _widthAnim,
            builder: (_, __) {
              return LayoutBuilder(builder: (ctx, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Container(
                      height: 6,
                      width: constraints.maxWidth * _widthAnim.value,
                      decoration: BoxDecoration(
                        color: _barColor(),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: _barColor().withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
            },
          ),
        ],
      ),
    );
  }
}

