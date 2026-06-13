import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/models/air_quality.dart';
import '../core/theme.dart';
import '../core/utils.dart';

class TrendChart extends StatelessWidget {
  final List<HourlySnapshot> snapshots;
  final String pollutant; // 'pm25', 'pm10', 'o3', 'no2', 'co'

  const TrendChart({
    super.key,
    required this.snapshots,
    this.pollutant = 'pm25',
  });

  List<FlSpot> _buildSpots() {
    final relevant = snapshots.take(24).toList();
    return relevant.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      double value;
      switch (pollutant) {
        case 'pm10':
          value = s.pm10;
        case 'o3':
          value = s.ozone;
        case 'no2':
          value = s.nitrogenDioxide;
        case 'co':
          value = s.carbonMonoxide / 100;
        default:
          value = s.pm25;
      }
      return FlSpot(i.toDouble(), value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();
    if (spots.isEmpty) return const SizedBox.shrink();

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final chartMax = (maxY * 1.3).clamp(10.0, double.infinity);

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppTheme.border,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 6,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= snapshots.length) return const SizedBox();
                  return Text(
                    AqiUtils.formatHour(snapshots[idx].time),
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      color: AppTheme.textTertiary,
                    ),
                  );
                },
              ),
            ),
          ),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: 0,
          maxY: chartMax,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppTheme.accent,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accent.withOpacity(0.3),
                    AppTheme.accent.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppTheme.surfaceElevated,
              tooltipRoundedRadius: 8,
              getTooltipItems: (spots) => spots.map((s) {
                final idx = s.spotIndex;
                final label = idx < snapshots.length
                    ? AqiUtils.formatHour(snapshots[idx].time)
                    : '';
                return LineTooltipItem(
                  '$label\n${s.y.toStringAsFixed(1)}',
                  const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
