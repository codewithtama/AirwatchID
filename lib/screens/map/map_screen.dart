import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/air_quality_provider.dart';
import '../../providers/location_provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Consumer2<LocationProvider, AirQualityProvider>(
        builder: (_, loc, aq, __) {
          final userLat = loc.latitude ?? -6.2;
          final userLng = loc.longitude ?? 106.8;

          final markers = _buildMarkers(loc, aq);
          final circles = _buildCircles(loc, aq);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(userLat, userLng),
                  initialZoom: 10.0,
                  backgroundColor: const Color(0xFF0D0D0D),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.airwatchid.airwatch_id',
                  ),
                  CircleLayer(circles: circles),
                  MarkerLayer(markers: markers),
                ],
              ),

              // Top bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.map_rounded,
                                size: 16, color: AppTheme.accent),
                            const SizedBox(width: 8),
                            const Text(
                              'Peta Kualitas Udara',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Legend bottom
              Positioned(
                bottom: 24,
                left: 16,
                child: _buildLegend(),
              ),

              // FAB re-center
              Positioned(
                bottom: 24,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    _mapController.move(
                      LatLng(userLat, userLng),
                      10.0,
                    );
                  },
                  backgroundColor: AppTheme.surfaceElevated,
                  foregroundColor: AppTheme.accent,
                  elevation: 4,
                  child: const Icon(Icons.my_location_rounded),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Marker> _buildMarkers(LocationProvider loc, AirQualityProvider aq) {
    final markers = <Marker>[];

    // User location marker
    if (loc.hasLocation && aq.currentData != null) {
      final aqi = aq.currentAqi;
      final level = AqiColors.getLevelFromAqi(aqi);
      markers.add(
        Marker(
          point: LatLng(loc.latitude!, loc.longitude!),
          width: 80,
          height: 60,
          child: _AqiMarker(
            aqi: aqi,
            label: loc.cityName,
            color: level.color,
            isUser: true,
          ),
        ),
      );
    }

    // Compare city markers
    for (final city in aq.compareCities) {
      if (city.data == null) continue;
      final current = city.data!.current;
      final aqi = AqiUtils.computeOverallAqi(
          pm25: current.pm25, pm10: current.pm10);
      final level = AqiColors.getLevelFromAqi(aqi);
      markers.add(
        Marker(
          point: LatLng(city.latitude, city.longitude),
          width: 80,
          height: 60,
          child: _AqiMarker(
            aqi: aqi,
            label: city.cityName.split(',').first,
            color: level.color,
            isUser: false,
          ),
        ),
      );
    }

    return markers;
  }

  List<CircleMarker> _buildCircles(LocationProvider loc, AirQualityProvider aq) {
    final circles = <CircleMarker>[];

    if (loc.hasLocation && aq.currentData != null) {
      final level = AqiColors.getLevelFromAqi(aq.currentAqi);
      circles.add(CircleMarker(
        point: LatLng(loc.latitude!, loc.longitude!),
        radius: 40000,
        useRadiusInMeter: true,
        color: level.color.withValues(alpha: 0.12),
        borderColor: level.color.withValues(alpha: 0.35),
        borderStrokeWidth: 1.5,
      ));
    }

    for (final city in aq.compareCities) {
      if (city.data == null) continue;
      final current = city.data!.current;
      final aqi = AqiUtils.computeOverallAqi(
          pm25: current.pm25, pm10: current.pm10);
      final level = AqiColors.getLevelFromAqi(aqi);
      circles.add(CircleMarker(
        point: LatLng(city.latitude, city.longitude),
        radius: 40000,
        useRadiusInMeter: true,
        color: level.color.withValues(alpha: 0.1),
        borderColor: level.color.withValues(alpha: 0.3),
        borderStrokeWidth: 1,
      ));
    }

    return circles;
  }

  Widget _buildLegend() {
    final levels = [
      ('Baik', AqiColors.baik),
      ('Sedang', AqiColors.sedang),
      ('Tdk Sehat', AqiColors.tidakSehat),
      ('Berbahaya', AqiColors.berbahaya),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: levels.map((l) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: l.$2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l.$1,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AqiMarker extends StatelessWidget {
  final int aqi;
  final String label;
  final Color color;
  final bool isUser;

  const _AqiMarker({
    required this.aqi,
    required this.label,
    required this.color,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isUser ? color : AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: isUser ? 0 : 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                aqi.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isUser ? AppTheme.black : color,
                  height: 1,
                ),
              ),
              Text(
                label.length > 8 ? '${label.substring(0, 7)}…' : label,
                style: TextStyle(
                  fontSize: 8,
                  color: isUser ? AppTheme.black.withValues(alpha: 0.8) : AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(8, 6),
          painter: _TrianglePainter(color: color),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
