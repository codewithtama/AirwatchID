import 'dart:math' as math;
import 'package:intl/intl.dart';

class AqiUtils {
  AqiUtils._();

  /// Calculates US AQI from PM2.5 concentration (µg/m³)
  static int pm25ToAqi(double pm25) {
    if (pm25 < 0) return 0;
    return _linearInterpolate(pm25, [
      [0, 12.0, 0, 50],
      [12.1, 35.4, 51, 100],
      [35.5, 55.4, 101, 150],
      [55.5, 150.4, 151, 200],
      [150.5, 250.4, 201, 300],
      [250.5, 350.4, 301, 400],
      [350.5, 500.4, 401, 500],
    ]);
  }

  /// Calculates AQI from PM10 concentration
  static int pm10ToAqi(double pm10) {
    if (pm10 < 0) return 0;
    return _linearInterpolate(pm10, [
      [0, 54, 0, 50],
      [55, 154, 51, 100],
      [155, 254, 101, 150],
      [255, 354, 151, 200],
      [355, 424, 201, 300],
      [425, 504, 301, 400],
      [505, 604, 401, 500],
    ]);
  }

  static int _linearInterpolate(
      double concentration, List<List<num>> breakpoints) {
    for (final bp in breakpoints) {
      final cLow = bp[0].toDouble();
      final cHigh = bp[1].toDouble();
      final iLow = bp[2].toDouble();
      final iHigh = bp[3].toDouble();
      if (concentration >= cLow && concentration <= cHigh) {
        return ((iHigh - iLow) / (cHigh - cLow) * (concentration - cLow) +
                iLow)
            .round();
      }
    }
    return 500;
  }

  /// Returns overall AQI from multiple pollutant readings
  static int computeOverallAqi({
    required double pm25,
    required double pm10,
  }) {
    final aqis = <int>[
      pm25ToAqi(pm25),
      pm10ToAqi(pm10),
    ];
    return aqis.reduce(math.max);
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id').format(dt);
  }

  static String formatHour(DateTime dt) {
    return DateFormat('HH:mm', 'id').format(dt);
  }

  static String formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy', 'id').format(dt);
  }

  static String formatPollutantValue(double value, String unit) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k $unit';
    }
    return '${value.toStringAsFixed(1)} $unit';
  }
}
