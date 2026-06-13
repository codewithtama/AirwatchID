import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/air_quality.dart';
import '../models/forecast.dart';
import '../../core/constants.dart';

class OpenMeteoService {
  final http.Client _client;

  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();

  Future<AirQualityData> fetchAirQuality({
    required double latitude,
    required double longitude,
    required String cityName,
  }) async {
    final uri = Uri.parse(AppConstants.airQualityBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly': AppConstants.airQualityHourlyParams,
        'timezone': 'auto',
        'forecast_days': '2',
      },
    );

    final response = await _client.get(uri).timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw AirQualityApiException(
        'API error ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseResponse(json, cityName, latitude, longitude);
  }

  Future<List<DailyForecast>> fetchForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(AppConstants.airQualityBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly': 'pm2_5,pm10,ozone,nitrogen_dioxide',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    final response = await _client.get(uri).timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw AirQualityApiException(
        'Forecast API error ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseForecast(json);
  }

  List<DailyForecast> _parseForecast(Map<String, dynamic> json) {
    final hourly = json['hourly'] as Map<String, dynamic>;
    final times = (hourly['time'] as List).cast<String>();
    final pm25 = _toDoubleList(hourly['pm2_5'] as List);
    final pm10 = _toDoubleList(hourly['pm10'] as List);
    final ozone = _toDoubleList(hourly['ozone'] as List);
    final no2 = _toDoubleList(hourly['nitrogen_dioxide'] as List);

    // Group by date
    final Map<String, List<int>> dateGroups = {};
    for (int i = 0; i < times.length; i++) {
      final dateStr = times[i].substring(0, 10);
      dateGroups.putIfAbsent(dateStr, () => []).add(i);
    }

    return dateGroups.entries.map((entry) {
      final indices = entry.value;
      return DailyForecast.fromHourly(
        date: DateTime.parse(entry.key),
        pm25Values: indices.map((i) => pm25[i]).toList(),
        pm10Values: indices.map((i) => pm10[i]).toList(),
        ozoneValues: indices.map((i) => ozone[i]).toList(),
        no2Values: indices.map((i) => no2[i]).toList(),
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  AirQualityData _parseResponse(
    Map<String, dynamic> json,
    String cityName,
    double lat,
    double lng,
  ) {
    final hourly = json['hourly'] as Map<String, dynamic>;
    final times = (hourly['time'] as List).cast<String>();
    final pm25List = _toDoubleList(hourly['pm2_5'] as List);
    final pm10List = _toDoubleList(hourly['pm10'] as List);
    final coList = _toDoubleList(hourly['carbon_monoxide'] as List);
    final no2List = _toDoubleList(hourly['nitrogen_dioxide'] as List);
    final o3List = _toDoubleList(hourly['ozone'] as List);
    final dustList = _toDoubleList(hourly['dust'] as List);

    final snapshots = <HourlySnapshot>[];
    for (int i = 0; i < times.length; i++) {
      snapshots.add(HourlySnapshot(
        time: DateTime.parse(times[i]),
        pm25: pm25List[i],
        pm10: pm10List[i],
        carbonMonoxide: coList[i],
        nitrogenDioxide: no2List[i],
        ozone: o3List[i],
        dust: dustList[i],
      ));
    }

    return AirQualityData(
      cityName: cityName,
      latitude: lat,
      longitude: lng,
      hourlySnapshots: snapshots,
      fetchedAt: DateTime.now(),
    );
  }

  List<double> _toDoubleList(List<dynamic> raw) {
    return raw.map((e) => e == null ? 0.0 : (e as num).toDouble()).toList();
  }

  Future<List<GeocodingResult>> searchCity(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(AppConstants.geocodingBaseUrl).replace(
      queryParameters: {
        'name': query.trim(),
        'count': '5',
        'language': 'id',
        'format': 'json',
      },
    );

    final response = await _client.get(uri).timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode != 200) {
      throw AirQualityApiException(
        'Geocoding error ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List?;
    if (results == null) return [];

    return results
        .cast<Map<String, dynamic>>()
        .map(GeocodingResult.fromJson)
        .toList();
  }
}

class AirQualityApiException implements Exception {
  final String message;
  AirQualityApiException(this.message);

  @override
  String toString() => 'AirQualityApiException: $message';
}
