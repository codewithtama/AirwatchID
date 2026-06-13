import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/air_quality_provider.dart';
import '../../widgets/pollutant_row.dart';
import '../../widgets/trend_chart.dart';
import '../../core/theme.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String _selectedPollutant = 'pm25';

  static const _pollutants = [
    ('pm25', 'PM2.5'),
    ('pm10', 'PM10'),
    ('o3', 'O₃'),
    ('no2', 'NO₂'),
    ('co', 'CO'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Detail Polutan'),
        backgroundColor: AppTheme.black,
        elevation: 0,
      ),
      body: Consumer<AirQualityProvider>(
        builder: (_, aq, __) {
          final data = aq.currentData;
          if (data == null) {
            return const Center(
              child: Text(
                'Belum ada data. Buka halaman Beranda terlebih dahulu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sora',
                  color: AppTheme.textSecondary,
                ),
              ),
            );
          }

          final current = data.current;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Tren 24 Jam'),
                const SizedBox(height: 8),

                // Pollutant selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _pollutants.map((p) {
                      final isSelected = _selectedPollutant == p.$1;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPollutant = p.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accent
                                : AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.accent
                                  : AppTheme.border,
                            ),
                          ),
                          child: Text(
                            p.$2,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppTheme.black
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: TrendChart(
                    snapshots: data.hourlySnapshots,
                    pollutant: _selectedPollutant,
                  ),
                ),
                const SizedBox(height: 28),

                _buildSectionTitle('Konsentrasi Saat Ini'),
                const SizedBox(height: 16),

                PollutantRow(
                  data: PollutantRowData(
                    name: 'PM2.5 (Partikel Halus)',
                    shortName: 'PM2.5',
                    value: current.pm25,
                    unit: 'µg/m³',
                    maxValue: 250,
                  ),
                ),
                PollutantRow(
                  data: PollutantRowData(
                    name: 'PM10 (Partikel Kasar)',
                    shortName: 'PM10',
                    value: current.pm10,
                    unit: 'µg/m³',
                    maxValue: 500,
                  ),
                ),
                PollutantRow(
                  data: PollutantRowData(
                    name: 'Ozon (O₃)',
                    shortName: 'O3',
                    value: current.ozone,
                    unit: 'µg/m³',
                    maxValue: 300,
                  ),
                ),
                PollutantRow(
                  data: PollutantRowData(
                    name: 'Nitrogen Dioksida (NO₂)',
                    shortName: 'NO2',
                    value: current.nitrogenDioxide,
                    unit: 'µg/m³',
                    maxValue: 200,
                  ),
                ),
                PollutantRow(
                  data: PollutantRowData(
                    name: 'Karbon Monoksida (CO)',
                    shortName: 'CO',
                    value: current.carbonMonoxide,
                    unit: 'µg/m³',
                    maxValue: 15400,
                  ),
                ),
                PollutantRow(
                  data: PollutantRowData(
                    name: 'Debu (Dust)',
                    shortName: 'Dust',
                    value: current.dust,
                    unit: 'µg/m³',
                    maxValue: 500,
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Sora',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
