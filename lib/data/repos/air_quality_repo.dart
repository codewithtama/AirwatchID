import 'package:hive_flutter/hive_flutter.dart';
import '../models/air_quality.dart';
import '../models/forecast.dart';
import '../api/open_meteo_service.dart';
import '../../core/constants.dart';

class AirQualityRepo {
  final OpenMeteoService _service;
  Box<CachedAirQualityData>? _box;

  AirQualityRepo({OpenMeteoService? service})
      : _service = service ?? OpenMeteoService();

  Future<void> init() async {
    _box = await Hive.openBox<CachedAirQualityData>(
        AppConstants.hiveBoxAirQuality);
  }

  Future<AirQualityData> getAirQuality({
    required double latitude,
    required double longitude,
    required String cityName,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}';

    if (!forceRefresh) {
      final cached = _readCache(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final data = await _service.fetchAirQuality(
        latitude: latitude,
        longitude: longitude,
        cityName: cityName,
      );
      await _writeCache(cacheKey, data);
      return data;
    } catch (e) {
      final cached = _readCache(cacheKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  AirQualityData? _readCache(String key) {
    final box = _box;
    if (box == null) return null;
    final cached = box.get(key);
    if (cached == null) return null;

    final age = DateTime.now()
        .difference(DateTime.parse(cached.cachedAt));
    if (age.inHours > 2) return null;

    final snapshots = cached.hourly.map((h) {
      return HourlySnapshot(
        time: DateTime.parse(h.time),
        pm25: h.pm25,
        pm10: h.pm10,
        carbonMonoxide: h.carbonMonoxide,
        nitrogenDioxide: h.nitrogenDioxide,
        ozone: h.ozone,
        dust: h.dust,
      );
    }).toList();

    return AirQualityData(
      cityName: cached.cityName,
      latitude: cached.latitude,
      longitude: cached.longitude,
      hourlySnapshots: snapshots,
      fetchedAt: DateTime.parse(cached.cachedAt),
    );
  }

  Future<void> _writeCache(String key, AirQualityData data) async {
    final box = _box;
    if (box == null) return;

    final hourly = data.hourlySnapshots.map((s) {
      return HourlyAirQuality(
        time: s.time.toIso8601String(),
        pm25: s.pm25,
        pm10: s.pm10,
        carbonMonoxide: s.carbonMonoxide,
        nitrogenDioxide: s.nitrogenDioxide,
        ozone: s.ozone,
        dust: s.dust,
      );
    }).toList();

    await box.put(
      key,
      CachedAirQualityData(
        cityKey: key,
        latitude: data.latitude,
        longitude: data.longitude,
        hourly: hourly,
        cachedAt: DateTime.now().toIso8601String(),
        cityName: data.cityName,
      ),
    );
  }

  Future<void> clearCache() async {
    await _box?.clear();
  }

  Future<List<GeocodingResult>> searchCity(String query) {
    return _service.searchCity(query);
  }

  List<String> getCachedCityNames() {
    return _box?.values.map((c) => c.cityName).toSet().toList() ?? [];
  }

  Future<List<DailyForecast>> fetchForecast({
    required double latitude,
    required double longitude,
  }) {
    return _service.fetchForecast(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
