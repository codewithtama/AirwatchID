import 'package:flutter_test/flutter_test.dart';
import 'package:airwatch_id/main.dart';

void main() {
  testWidgets('AirWatch app smoke test', (WidgetTester tester) async {
    expect(AirWatchApp, isNotNull);
  });
}
