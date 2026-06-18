import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' hide Location;

enum LocationStatus { idle, loading, granted, denied, permanentlyDenied, error }

class LocationProvider extends ChangeNotifier {
  LocationStatus _status = LocationStatus.idle;
  double? _latitude;
  double? _longitude;
  String _cityName = 'Lokasi Saya';
  String? _error;

  LocationStatus get status => _status;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String get cityName => _cityName;
  String? get error => _error;

  bool get hasLocation => _latitude != null && _longitude != null;

  Future<void> requestLocation() async {
    _status = LocationStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final permission = await _checkAndRequestPermission();
      if (permission == LocationPermission.denied) {
        _status = LocationStatus.denied;
        notifyListeners();
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _status = LocationStatus.permanentlyDenied;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      await _resolveCity(position.latitude, position.longitude);

      _status = LocationStatus.granted;
    } catch (e, stack) {
      debugPrint('LocationProvider error: $e\n$stack');
      _error = e.toString();
      _status = LocationStatus.error;
    }

    notifyListeners();
  }

  Future<LocationPermission> _checkAndRequestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return LocationPermission.denied;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<void> _resolveCity(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _cityName = p.subAdministrativeArea?.isNotEmpty == true
            ? p.subAdministrativeArea!
            : p.locality?.isNotEmpty == true
                ? p.locality!
                : p.administrativeArea ?? 'Lokasi Saya';
      }
    } catch (_) {
      _cityName = 'Lokasi Saya';
    }
  }

  void setManualLocation({
    required double latitude,
    required double longitude,
    required String cityName,
  }) {
    _latitude = latitude;
    _longitude = longitude;
    _cityName = cityName;
    _status = LocationStatus.granted;
    _error = null;
    notifyListeners();
  }
}
