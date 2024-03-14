import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:balloon_pop_game/main.dart';

void main() {
  testWidgets('Tapping a balloon increments score',
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Find the initial score text
    final initialScoreText = find.text('Score: 0');
    expect(initialScoreText, findsOneWidget);

    // Simulate tapping a balloon (assuming GestureDetector is used)
    final firstBalloon = find.byType(GestureDetector).first;
    await tester.tap(firstBalloon);
    await tester.pump(); // Rebuild the widget tree after tap

    // Find the updated score text
    final updatedScoreText = find.text('Score: 2');
    expect(updatedScoreText, findsOneWidget);
    expect(initialScoreText, findsNothing); // Verify initial score is gone
  });
}
