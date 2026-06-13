import 'package:flutter/material.dart';
import '../core/theme.dart';

class HealthAdviceCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String advice;
  final Color levelColor;

  const HealthAdviceCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.advice,
    required this.levelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: levelColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: levelColor.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Udara',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textTertiary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: levelColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: levelColor,
                  boxShadow: [
                    BoxShadow(
                      color: levelColor.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: AppTheme.border,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 48,
                decoration: BoxDecoration(
                  color: levelColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  advice,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                    height: 1.6,
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

