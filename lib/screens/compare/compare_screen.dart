import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/air_quality_provider.dart';
import '../../data/models/air_quality.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _searchController = TextEditingController();
  List<GeocodingResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results =
          await context.read<AirQualityProvider>().searchCity(query);
      setState(() => _searchResults = results);
    } catch (_) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _addCity(GeocodingResult result) async {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    setState(() => _searchResults = []);

    await context.read<AirQualityProvider>().addCompareCity(
          cityName: result.displayName,
          latitude: result.latitude,
          longitude: result.longitude,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Bandingkan Kota'),
        backgroundColor: AppTheme.black,
        elevation: 0,
      ),
      body: Consumer<AirQualityProvider>(
        builder: (_, aq, __) {
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari kota (maks. 3 kota)...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textTertiary),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.accent,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),

              // Search results
              if (_searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppTheme.border),
                    itemBuilder: (_, i) {
                      final r = _searchResults[i];
                      return ListTile(
                        leading: const Icon(Icons.location_city_rounded,
                            color: AppTheme.textTertiary, size: 20),
                        title: Text(
                          r.name,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          r.admin1 != null
                              ? '${r.admin1}, ${r.country}'
                              : r.country,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        onTap: () => _addCity(r),
                      );
                    },
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (aq.compareCities.isEmpty)
                        _buildEmpty()
                      else ...[
                        ...aq.compareCities.asMap().entries.map((e) {
                          return _buildCityCard(e.value, e.key, aq);
                        }),
                        if (aq.compareCities.length > 1)
                          _buildBarChart(aq.compareCities),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCityCard(CityCompareData city, int index, AirQualityProvider aq) {
    int aqi = 0;
    if (city.data != null) {
      final current = city.data!.current;
      aqi = AqiUtils.computeOverallAqi(pm25: current.pm25, pm10: current.pm10);
    }
    final level = AqiColors.getLevelFromAqi(aqi);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: city.isLoading
              ? AppTheme.border
              : level.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Color dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: city.isLoading ? AppTheme.border : level.color,
              boxShadow: city.isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: level.color.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.cityName,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (city.isLoading)
                  const Text('Memuat...',
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          color: AppTheme.textTertiary))
                else if (city.error != null)
                  Text(
                    'Gagal memuat',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        color: AqiColors.tidakSehat),
                  )
                else
                  Text(
                    level.label,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      color: level.color,
                    ),
                  ),
              ],
            ),
          ),
          if (city.isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppTheme.accent),
            )
          else
            Text(
              aqi.toString(),
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: level.color,
              ),
            ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => aq.removeCompareCity(index),
            child: const Icon(Icons.close_rounded,
                size: 18, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<CityCompareData> cities) {
    final ready = cities.where((c) => c.data != null && !c.isLoading).toList();
    if (ready.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 8),
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
            'Perbandingan AQI',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
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
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= ready.length) return const SizedBox();
                        final name = ready[i].cityName.split(',').first;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            name.length > 10 ? '${name.substring(0, 8)}…' : name,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 10,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: ready.asMap().entries.map((e) {
                  final city = e.value;
                  final current = city.data!.current;
                  final aqi = AqiUtils.computeOverallAqi(
                      pm25: current.pm25, pm10: current.pm10);
                  final level = AqiColors.getLevelFromAqi(aqi);
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: aqi.toDouble(),
                        color: level.color,
                        width: 28,
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

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.compare_arrows_rounded,
              size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: 20),
          const Text(
            'Tambah hingga 3 kota\nuntuk dibandingkan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

