import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendease/widgets/stat_card.dart';

void main() {
  testWidgets('StatCard renders title, value, subtitle and triggers onTap callback', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatCard(
            title: 'Present Today',
            value: '42',
            subtitle: '84% attendance',
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verify Title and Value are visible
    expect(find.text('Present Today'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('84% attendance'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Tap the card and verify callback
    await tester.tap(find.byType(StatCard));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
