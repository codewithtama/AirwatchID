import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/air_quality_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/aqi_card.dart';
import '../../widgets/health_advice_card.dart';
import '../../widgets/share_card.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    final loc = context.read<LocationProvider>();
    final aq = context.read<AirQualityProvider>();

    if (!loc.hasLocation) {
      await loc.requestLocation();
    }

    if (loc.hasLocation) {
      await aq.fetch(
        latitude: loc.latitude!,
        longitude: loc.longitude!,
        cityName: loc.cityName,
        forceRefresh: forceRefresh,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: RefreshIndicator(
        onRefresh: () => _loadData(forceRefresh: true),
        color: AppTheme.accent,
        backgroundColor: AppTheme.surfaceElevated,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildBody(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.black,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Consumer<LocationProvider>(
          builder: (_, loc, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AirWatch ID',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: AppTheme.accent),
                    const SizedBox(width: 4),
                    Text(
                      loc.cityName,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        Consumer2<LocationProvider, AirQualityProvider>(
          builder: (ctx, loc, aq, __) {
            final hasData = aq.currentData != null;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasData) ...[
                  IconButton(
                    icon: const Icon(Icons.share_rounded,
                        size: 20, color: AppTheme.textSecondary),
                    onPressed: () {
                      final data = aq.currentData!;
                      final current = data.current;
                      final aqi = AqiUtils.computeOverallAqi(
                          pm25: current.pm25, pm10: current.pm10);
                      ShareService.shareAqiCard(
                        context: ctx,
                        cityName: loc.cityName,
                        aqi: aqi,
                        pm25: current.pm25,
                        pm10: current.pm10,
                        fetchedAt: data.fetchedAt,
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      AqiUtils.formatDateTime(aq.currentData!.fetchedAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.settings_rounded,
                      size: 20, color: AppTheme.textSecondary),
                  onPressed: () {
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (ctx) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer2<LocationProvider, AirQualityProvider>(
      builder: (_, loc, aq, __) {
        if (loc.status == LocationStatus.loading ||
            aq.state == AirQualityState.loading) {
          return _buildShimmer();
        }

        if (loc.status == LocationStatus.denied ||
            loc.status == LocationStatus.permanentlyDenied) {
          return _buildPermissionError(loc);
        }

        if (aq.state == AirQualityState.error && aq.currentData == null) {
          return _buildError(aq.error ?? 'Terjadi kesalahan');
        }

        if (aq.currentData == null) {
          return _buildNoData();
        }

        return _buildContent(aq);
      },
    );
  }

  Widget _buildContent(AirQualityProvider aq) {
    final data = aq.currentData!;
    final current = data.current;
    final aqi = AqiUtils.computeOverallAqi(pm25: current.pm25, pm10: current.pm10);
    final level = AqiColors.getLevelFromAqi(aqi);

    return Column(
      children: [
        // AQI Circle
        Center(
          child: AqiCircleIndicator(aqi: aqi, size: 220),
        ),
        const SizedBox(height: 32),

        // Health Advice
        HealthAdviceCard(
          emoji: level.icon,
          label: level.label,
          advice: level.advice,
          levelColor: level.color,
        ),
        const SizedBox(height: 24),

        // Quick Stats
        Row(
          children: [
            _buildStatChip('PM2.5', '${current.pm25.toStringAsFixed(1)} µg/m³'),
            const SizedBox(width: 12),
            _buildStatChip('PM10', '${current.pm10.toStringAsFixed(1)} µg/m³'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatChip('O₃', '${current.ozone.toStringAsFixed(1)} µg/m³'),
            const SizedBox(width: 12),
            _buildStatChip('NO₂', '${current.nitrogenDioxide.toStringAsFixed(1)} µg/m³'),
          ],
        ),
        const SizedBox(height: 24),

        // Offline note
        if (aq.state == AirQualityState.error && aq.currentData != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AqiColors.sedang.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AqiColors.sedang.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 16, color: AqiColors.sedang),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mode offline — data dari cache',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      color: AqiColors.sedang,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                color: AppTheme.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceCard,
      highlightColor: AppTheme.surfaceElevated,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 220,
            height: 220,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceCard,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionError(LocationProvider loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(Icons.location_off_rounded,
                size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 20),
            const Text(
              'Izin Lokasi Diperlukan',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AirWatch ID memerlukan akses lokasi\nuntuk menampilkan kualitas udara di sekitar Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Izinkan Akses Lokasi',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadData(forceRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(Icons.air, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 20),
            const Text(
              'Mengambil data lokasi...',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

