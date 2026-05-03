// This is a basic Flutter widget test for Student Logbook app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_logbook/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: StudentLogbookApp()));

    // Verify that splash screen text is shown.
    expect(find.text('Student Logbook'), findsWidgets);

    // Wait for the splash screen duration (500ms) and logic
    await tester.pump(const Duration(milliseconds: 600));
    
    // Trigger the navigation and wait for it to finish
    // We use a small duration to advance the animation but not settle infinitely
    await tester.pump(); // Start navigation
    await tester.pump(const Duration(milliseconds: 500)); // Wait for transition animation

    // After splash, it should navigate to Role Selection (assuming no user role is saved)
    // We check for the subtitle text in RoleSelectionScreen
    expect(find.text('Choose your role to get started'), findsOneWidget);
  });
}
