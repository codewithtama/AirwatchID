import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/air_quality_provider.dart';
import '../../data/models/forecast.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Prakiraan 7 Hari'),
        backgroundColor: AppTheme.black,
        elevation: 0,
      ),
      body: Consumer<AirQualityProvider>(
        builder: (_, aq, __) {
          if (aq.forecastLoading && aq.forecast.isEmpty) {
            return _buildShimmer();
          }
          if (aq.forecast.isEmpty) {
            return _buildEmpty(aq);
          }
          return _buildContent(aq.forecast);
        },
      ),
    );
  }

  Widget _buildContent(List<DailyForecast> forecast) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bar chart overview
          _buildBarChart(forecast),
          const SizedBox(height: 28),

          const Text(
            'DETAIL HARIAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),

          // Day cards
          ...forecast.map((f) => _buildDayCard(f)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<DailyForecast> forecast) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prediksi AQI Mingguan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 300,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppTheme.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i >= forecast.length) return const SizedBox();
                        final isToday = i == 0;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            isToday
                                ? 'Hari\nIni'
                                : AqiUtils.formatDate(forecast[i].date)
                                    .split(' ')
                                    .first,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: isToday
                                  ? AppTheme.accent
                                  : AppTheme.textTertiary,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: forecast.asMap().entries.map((e) {
                  final f = e.value;
                  final level = AqiColors.getLevelFromAqi(f.aqi);
                  final isToday = e.key == 0;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: f.aqi.toDouble(),
                        color: level.color,
                        width: isToday ? 22 : 16,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 300,
                          color: AppTheme.border,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(DailyForecast f) {
    final level = AqiColors.getLevelFromAqi(f.aqi);
    final isToday = f.date.day == DateTime.now().day &&
        f.date.month == DateTime.now().month;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday
            ? level.color.withValues(alpha: 0.08)
            : AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? level.color.withValues(alpha: 0.4) : AppTheme.border,
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Text(
                  isToday ? 'Hari\nIni' : _dayName(f.date.weekday),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isToday ? level.color : AppTheme.textTertiary,
                    height: 1.2,
                  ),
                ),
                if (!isToday) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${f.date.day}/${f.date.month}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Emoji + label
          Text(level.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: level.color,
                  ),
                ),
                Text(
                  'PM2.5 ${f.avgPm25.toStringAsFixed(1)} · PM10 ${f.avgPm10.toStringAsFixed(1)} µg/m³',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // AQI badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: level.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              f.aqi.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: level.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[(weekday - 1) % 7];
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceCard,
      highlightColor: AppTheme.surfaceElevated,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              5,
              (_) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AirQualityProvider aq) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_outlined, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              aq.state == AirQualityState.idle
                  ? 'Buka Beranda terlebih dahulu\nuntuk memuat prakiraan.'
                  : 'Data prakiraan belum tersedia.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
