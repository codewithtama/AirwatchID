import '../../core/utils.dart';

class DailyForecast {
  final DateTime date;
  final double avgPm25;
  final double avgPm10;
  final double avgOzone;
  final double avgNo2;
  final int aqi;

  const DailyForecast({
    required this.date,
    required this.avgPm25,
    required this.avgPm10,
    required this.avgOzone,
    required this.avgNo2,
    required this.aqi,
  });

  factory DailyForecast.fromHourly({
    required DateTime date,
    required List<double> pm25Values,
    required List<double> pm10Values,
    required List<double> ozoneValues,
    required List<double> no2Values,
  }) {
    double avg(List<double> list) {
      final valid = list.where((v) => v > 0).toList();
      if (valid.isEmpty) return 0;
      return valid.reduce((a, b) => a + b) / valid.length;
    }

    final avgPm25 = avg(pm25Values);
    final avgPm10 = avg(pm10Values);

    return DailyForecast(
      date: date,
      avgPm25: avgPm25,
      avgPm10: avgPm10,
      avgOzone: avg(ozoneValues),
      avgNo2: avg(no2Values),
      aqi: AqiUtils.computeOverallAqi(pm25: avgPm25, pm10: avgPm10),
    );
  }
}
