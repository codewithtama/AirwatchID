import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'airwatch_aqi';
  static const _channelName = 'Peringatan Kualitas Udara';
  static const _channelDesc = 'Notifikasi saat kualitas udara berubah signifikan';
  static const _morningChannelId = 'airwatch_morning';
  static const _morningChannelName = 'Briefing Pagi';

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    await _createChannels();
    _initialized = true;
  }

  Future<void> _createChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _morningChannelId,
        _morningChannelName,
        description: 'Ringkasan kualitas udara harian',
        importance: Importance.defaultImportance,
      ),
    );
  }

  /// Smart alert: dipicu saat AQI naik ≥ deltaThreshold dalam interval singkat
  Future<void> showSmartAlert({
    required String cityName,
    required int currentAqi,
    required int prevAqi,
    required String levelLabel,
    required String emoji,
  }) async {
    if (!_initialized) await init();
    final delta = currentAqi - prevAqi;
    if (delta <= 0) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      ),
    );

    await _plugin.show(
      1,
      '$emoji AQI Naik Drastis — $cityName',
      'AQI melonjak $delta poin → $currentAqi ($levelLabel). Pertimbangkan untuk tetap di dalam ruangan.',
      details,
    );
    debugPrint('SmartAlert: AQI $prevAqi → $currentAqi (+$delta) di $cityName');
  }

  /// Notif threshold biasa
  Future<void> showThresholdAlert({
    required String cityName,
    required int aqi,
    required String levelLabel,
    required String emoji,
  }) async {
    if (!_initialized) await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _plugin.show(
      2,
      '$emoji AQI Melampaui Batas — $cityName',
      'Kualitas udara: $levelLabel (AQI $aqi). Harap berhati-hati.',
      details,
    );
  }

  /// Morning briefing jam 07:00 setiap hari
  Future<void> scheduleMorningBriefing({
    required String cityName,
    required int aqi,
    required String levelLabel,
  }) async {
    if (!_initialized) await init();

    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      7,
      0,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _morningChannelId,
        _morningChannelName,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _plugin.zonedSchedule(
      3,
      '🌅 Selamat Pagi! Kualitas Udara Hari Ini',
      '$cityName: $levelLabel (AQI $aqi). Rencanakan aktivitas luar ruangan dengan bijak.',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
