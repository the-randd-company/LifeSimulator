import 'package:flutter_test/flutter_test.dart';
import 'package:life_simulator/main.dart';

void main() {
  testWidgets('Welcome screen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifeSimulatorApp());

    // Verify that the welcome screen is displayed
    expect(find.text('Life Simulator'), findsOneWidget);
    expect(find.text('Welcome to Life Simulator'), findsOneWidget);
    expect(find.text('Enter your name'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
  });
}