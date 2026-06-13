import 'package:hive/hive.dart';

part 'air_quality.g.dart';

@HiveType(typeId: 0)
class HourlyAirQuality extends HiveObject {
  @HiveField(0)
  late String time;

  @HiveField(1)
  late double pm25;

  @HiveField(2)
  late double pm10;

  @HiveField(3)
  late double carbonMonoxide;

  @HiveField(4)
  late double nitrogenDioxide;

  @HiveField(5)
  late double ozone;

  @HiveField(6)
  late double dust;

  HourlyAirQuality({
    required this.time,
    required this.pm25,
    required this.pm10,
    required this.carbonMonoxide,
    required this.nitrogenDioxide,
    required this.ozone,
    required this.dust,
  });
}

@HiveType(typeId: 1)
class CachedAirQualityData extends HiveObject {
  @HiveField(0)
  late String cityKey;

  @HiveField(1)
  late double latitude;

  @HiveField(2)
  late double longitude;

  @HiveField(3)
  late List<HourlyAirQuality> hourly;

  @HiveField(4)
  late String cachedAt;

  @HiveField(5)
  late String cityName;

  CachedAirQualityData({
    required this.cityKey,
    required this.latitude,
    required this.longitude,
    required this.hourly,
    required this.cachedAt,
    required this.cityName,
  });
}

class AirQualityData {
  final String cityName;
  final double latitude;
  final double longitude;
  final List<HourlySnapshot> hourlySnapshots;
  final DateTime fetchedAt;

  const AirQualityData({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.hourlySnapshots,
    required this.fetchedAt,
  });

  HourlySnapshot get current {
    final now = DateTime.now();
    HourlySnapshot? closest;
    Duration minDiff = const Duration(days: 365);

    for (final s in hourlySnapshots) {
      final diff = now.difference(s.time).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = s;
      }
    }
    return closest ?? hourlySnapshots.last;
  }
}

class HourlySnapshot {
  final DateTime time;
  final double pm25;
  final double pm10;
  final double carbonMonoxide;
  final double nitrogenDioxide;
  final double ozone;
  final double dust;

  const HourlySnapshot({
    required this.time,
    required this.pm25,
    required this.pm10,
    required this.carbonMonoxide,
    required this.nitrogenDioxide,
    required this.ozone,
    required this.dust,
  });
}

class GeocodingResult {
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  const GeocodingResult({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  String get displayName =>
      admin1 != null ? '$name, $admin1' : '$name, $country';

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      name: json['name'] as String,
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
