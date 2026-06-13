import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';

class ShareCard extends StatelessWidget {
  final String cityName;
  final int aqi;
  final double pm25;
  final double pm10;
  final DateTime fetchedAt;

  const ShareCard({
    super.key,
    required this.cityName,
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.fetchedAt,
  });

  @override
  Widget build(BuildContext context) {
    final level = AqiColors.getLevelFromAqi(aqi);

    return Container(
      width: 360,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: level.color.withValues(alpha: 0.3), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            level.color.withValues(alpha: 0.12),
            AppTheme.black,
            AppTheme.surfaceCard,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: level.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AirWatch ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: level.color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                AqiUtils.formatDateTime(fetchedAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // City
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 14, color: AppTheme.textTertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  cityName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Big AQI
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                level.icon,
                style: const TextStyle(fontSize: 44),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aqi.toString(),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: level.color,
                      height: 1,
                    ),
                  ),
                  Text(
                    'AQI',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: level.color.withValues(alpha: 0.7),
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: level.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              level.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: level.color,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Container(height: 1, color: AppTheme.border),
          const SizedBox(height: 16),

          // Pollutant mini stats
          Row(
            children: [
              _StatChip('PM2.5', pm25.toStringAsFixed(1), 'µg/m³'),
              const SizedBox(width: 10),
              _StatChip('PM10', pm10.toStringAsFixed(1), 'µg/m³'),
            ],
          ),
          const SizedBox(height: 16),

          // Advice
          Text(
            level.advice,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatChip(this.label, this.value, this.unit);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textTertiary)),
            const SizedBox(height: 2),
            Text('$value $unit',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                )),
          ],
        ),
      ),
    );
  }
}

/// Renders ShareCard to PNG and shares it
class ShareService {
  ShareService._();

  static Future<void> shareAqiCard({
    required BuildContext context,
    required String cityName,
    required int aqi,
    required double pm25,
    required double pm10,
    required DateTime fetchedAt,
  }) async {
    final repaintKey = GlobalKey();

    // Build the card in an overlay to capture it
    final overlay = OverlayEntry(
      builder: (_) => Material(
        color: Colors.transparent,
        child: Center(
          child: RepaintBoundary(
            key: repaintKey,
            child: ShareCard(
              cityName: cityName,
              aqi: aqi,
              pm25: pm25,
              pm10: pm10,
              fetchedAt: fetchedAt,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final boundary = repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/airwatch_aqi_$cityName.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Kualitas udara di $cityName saat ini AQI $aqi. Pantau via AirWatch ID!',
      );
    } finally {
      overlay.remove();
    }
  }
}
