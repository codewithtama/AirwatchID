import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/air_quality_provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Riwayat Data'),
        backgroundColor: AppTheme.black,
        elevation: 0,
      ),
      body: Consumer<AirQualityProvider>(
        builder: (_, aq, __) {
          final data = aq.currentData;
          if (data == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Belum ada riwayat. Buka halaman Beranda terlebih dahulu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            );
          }

          final snapshots = data.hourlySnapshots.reversed.take(48).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshots.length,
            itemBuilder: (_, i) {
              final snap = snapshots[i];
              final aqi = AqiUtils.computeOverallAqi(
                  pm25: snap.pm25, pm10: snap.pm10);
              final level = AqiColors.getLevelFromAqi(aqi);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: level.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AqiUtils.formatDateTime(snap.time),
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            level.label,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: level.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          aqi.toString(),
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: level.color,
                          ),
                        ),
                        const Text(
                          'AQI',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
