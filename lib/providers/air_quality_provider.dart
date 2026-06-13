import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/air_quality.dart';
import '../data/repos/air_quality_repo.dart';
import '../core/constants.dart';
import '../core/utils.dart';

enum AirQualityState { idle, loading, success, error }

class CityCompareData {
  final String cityName;
  final double latitude;
  final double longitude;
  AirQualityData? data;
  String? error;
  bool isLoading;

  CityCompareData({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    this.data,
    this.error,
    this.isLoading = false,
  });
}

class AirQualityProvider extends ChangeNotifier {
  final AirQualityRepo _repo;

  AirQualityState _state = AirQualityState.idle;
  AirQualityData? _currentData;
  String? _error;
  Timer? _refreshTimer;
  int _refreshIntervalMinutes = AppConstants.defaultRefreshIntervalMinutes;
  int _notifThreshold = AppConstants.defaultNotifThreshold;
  final List<CityCompareData> _compareCities = [];

  AirQualityState get state => _state;
  AirQualityData? get currentData => _currentData;
  String? get error => _error;
  int get notifThreshold => _notifThreshold;
  int get refreshIntervalMinutes => _refreshIntervalMinutes;
  List<CityCompareData> get compareCities => List.unmodifiable(_compareCities);

  AirQualityProvider(this._repo);

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notifThreshold =
        prefs.getInt(AppConstants.prefNotifThreshold) ?? AppConstants.defaultNotifThreshold;
    _refreshIntervalMinutes = prefs.getInt(AppConstants.prefRefreshInterval) ??
        AppConstants.defaultRefreshIntervalMinutes;
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefNotifThreshold, _notifThreshold);
    await prefs.setInt(AppConstants.prefRefreshInterval, _refreshIntervalMinutes);
  }

  Future<void> fetch({
    required double latitude,
    required double longitude,
    required String cityName,
    bool forceRefresh = false,
  }) async {
    _state = AirQualityState.loading;
    _error = null;
    notifyListeners();

    try {
      _currentData = await _repo.getAirQuality(
        latitude: latitude,
        longitude: longitude,
        cityName: cityName,
        forceRefresh: forceRefresh,
      );
      _state = AirQualityState.success;
      _scheduleAutoRefresh(latitude, longitude, cityName);
    } catch (e, stack) {
      debugPrint('AirQualityProvider fetch error: $e\n$stack');
      _error = _friendlyError(e);
      _state = AirQualityState.error;
    }

    notifyListeners();
  }

  void _scheduleAutoRefresh(double lat, double lng, String city) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(
      Duration(minutes: _refreshIntervalMinutes),
      () => fetch(latitude: lat, longitude: lng, cityName: city, forceRefresh: true),
    );
  }

  Future<void> addCompareCity({
    required String cityName,
    required double latitude,
    required double longitude,
  }) async {
    if (_compareCities.length >= 3) return;
    if (_compareCities.any((c) => c.cityName == cityName)) return;

    final entry = CityCompareData(
      cityName: cityName,
      latitude: latitude,
      longitude: longitude,
      isLoading: true,
    );
    _compareCities.add(entry);
    notifyListeners();

    try {
      entry.data = await _repo.getAirQuality(
        latitude: latitude,
        longitude: longitude,
        cityName: cityName,
      );
      entry.isLoading = false;
    } catch (e) {
      entry.error = _friendlyError(e);
      entry.isLoading = false;
    }
    notifyListeners();
  }

  void removeCompareCity(int index) {
    if (index >= 0 && index < _compareCities.length) {
      _compareCities.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    await _repo.clearCache();
    _currentData = null;
    _state = AirQualityState.idle;
    notifyListeners();
  }

  void setNotifThreshold(int value) {
    _notifThreshold = value;
    saveSettings();
    notifyListeners();
  }

  void setRefreshInterval(int minutes) {
    _refreshIntervalMinutes = minutes;
    saveSettings();
    notifyListeners();
  }

  int get currentAqi {
    final current = _currentData?.current;
    if (current == null) return 0;
    return AqiUtils.computeOverallAqi(
      pm25: current.pm25,
      pm10: current.pm10,
    );
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('socket') || msg.contains('network') || msg.contains('connection')) {
      return 'Tidak ada koneksi internet. Menampilkan data cache.';
    }
    if (msg.contains('timeout')) {
      return 'Koneksi timeout. Periksa jaringan Anda.';
    }
    return 'Gagal memuat data: $e';
  }

  Future<List<GeocodingResult>> searchCity(String query) {
    return _repo.searchCity(query);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
