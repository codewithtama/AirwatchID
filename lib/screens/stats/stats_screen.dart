import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/air_quality_provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Statistik & Riwayat'),
        backgroundColor: AppTheme.black,
        elevation: 0,
      ),
      body: Consumer<AirQualityProvider>(
        builder: (_, aq, __) {
          if (aq.currentData == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Buka halaman Beranda untuk memuat data statistik.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            );
          }

          final dailyAvgs = aq.getDailyAverages();
          final snapshots = aq.currentData!.hourlySnapshots
              .reversed
              .take(48)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(dailyAvgs),
                const SizedBox(height: 24),
                _buildHeatmapSection(dailyAvgs),
                const SizedBox(height: 24),
                _buildTrendSection(snapshots),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(Map<DateTime, int> dailyAvgs) {
    if (dailyAvgs.isEmpty) return const SizedBox();

    final values = dailyAvgs.values.toList();
    final avgAll = values.reduce((a, b) => a + b) ~/ values.length;
    final best = values.reduce((a, b) => a < b ? a : b);
    final worst = values.reduce((a, b) => a > b ? a : b);

    final bestDay = dailyAvgs.entries
        .firstWhere((e) => e.value == best)
        .key;
    final worstDay = dailyAvgs.entries
        .firstWhere((e) => e.value == worst)
        .key;

    return Row(
      children: [
        _SummaryCard(
          label: 'Rata-rata',
          value: avgAll.toString(),
          sub: 'AQI',
          color: AqiColors.getLevelFromAqi(avgAll).color,
        ),
        const SizedBox(width: 10),
        _SummaryCard(
          label: 'Terbaik',
          value: best.toString(),
          sub: AqiUtils.formatDate(bestDay),
          color: AqiColors.baik,
          icon: Icons.arrow_downward_rounded,
        ),
        const SizedBox(width: 10),
        _SummaryCard(
          label: 'Terburuk',
          value: worst.toString(),
          sub: AqiUtils.formatDate(worstDay),
          color: AqiColors.berbahaya,
          icon: Icons.arrow_upward_rounded,
        ),
      ],
    );
  }

  Widget _buildHeatmapSection(Map<DateTime, int> dailyAvgs) {
    if (dailyAvgs.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HEATMAP AQI HARIAN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textTertiary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 8),
                child: Row(
                  children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                      .map((d) => Expanded(
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              _HeatmapGrid(dailyAvgs: dailyAvgs),
              const SizedBox(height: 12),
              // Color legend
              Row(
                children: [
                  const Text(
                    'Baik',
                    style: TextStyle(fontSize: 10, color: AppTheme.textTertiary),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            AqiColors.baik,
                            AqiColors.sedang,
                            AqiColors.tidakSehat,
                            AqiColors.berbahaya,
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Berbahaya',
                    style: TextStyle(fontSize: 10, color: AppTheme.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendSection(List<dynamic> snapshots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RIWAYAT 48 JAM',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textTertiary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshots.length,
          itemBuilder: (_, i) {
            final snap = snapshots[i];
            final aqi = AqiUtils.computeOverallAqi(
                pm25: snap.pm25, pm10: snap.pm10);
            final level = AqiColors.getLevelFromAqi(aqi);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 36,
                    decoration: BoxDecoration(
                      color: level.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AqiUtils.formatDateTime(snap.time),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        Text(
                          level.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: level.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    aqi.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: level.color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData? icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 2),
                ],
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 9,
                color: AppTheme.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final Map<DateTime, int> dailyAvgs;

  const _HeatmapGrid({required this.dailyAvgs});

  @override
  Widget build(BuildContext context) {
    if (dailyAvgs.isEmpty) return const SizedBox();

    final sorted = dailyAvgs.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Find first Monday before or on first date
    final firstDate = sorted.first.key;
    final offset = (firstDate.weekday - 1) % 7; // 0=Mon
    final allDates = <DateTime?>[];
    for (int i = 0; i < offset; i++) {
      allDates.add(null);
    }
    for (final e in sorted) {
      allDates.add(e.key);
    }
    // Pad to complete last row
    while (allDates.length % 7 != 0) {
      allDates.add(null);
    }

    final rows = allDates.length ~/ 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: rows * 7,
      itemBuilder: (_, i) {
        final date = allDates[i];
        if (date == null) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }

        final aqi = dailyAvgs[date] ?? 0;
        final level = AqiColors.getLevelFromAqi(aqi);
        final isToday = date.day == DateTime.now().day &&
            date.month == DateTime.now().month;

        return Tooltip(
          message: '${AqiUtils.formatDate(date)}\nAQI: $aqi',
          child: Container(
            decoration: BoxDecoration(
              color: aqi == 0
                  ? AppTheme.border
                  : level.color.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
              border: isToday
                  ? Border.all(color: AppTheme.textPrimary, width: 1.5)
                  : null,
            ),
            child: isToday
                ? const Center(
                    child: Icon(Icons.circle,
                        size: 4, color: AppTheme.textPrimary),
                  )
                : null,
          ),
        );
      },
    );
  }
}
