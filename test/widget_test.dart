import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('game boots to the main menu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const RunnerApp());
    // Let the game finish loading and show the menu overlay.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(find.text('NIGHTFALL NINJA'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });
}
