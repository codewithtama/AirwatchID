class AppConstants {
  AppConstants._();

  static const String airQualityBaseUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  static const String airQualityHourlyParams =
      'pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,ozone,dust';

  static const String appName = 'AirWatch ID';
  static const String hiveBoxAirQuality = 'air_quality_cache';
  static const String hiveBoxSettings = 'settings';

  static const String prefNotifThreshold = 'notif_threshold';
  static const String prefRefreshInterval = 'refresh_interval';

  static const int defaultNotifThreshold = 100;
  static const int defaultRefreshIntervalMinutes = 30;

  static const int aqiBaik = 50;
  static const int aqiSedang = 100;
  static const int aqiTidakSehatSensitif = 150;
  static const int aqiTidakSehat = 200;
  static const int aqiSangatTidakSehat = 300;
}
