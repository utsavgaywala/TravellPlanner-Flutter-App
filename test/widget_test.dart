import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner_app/main.dart';

void main() {
  testWidgets('App smoke test - renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TravelPlannerApp()),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
