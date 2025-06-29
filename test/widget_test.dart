// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:converter_app/main.dart';

void main() {
  testWidgets('Home screen loads and shows conversion types', (WidgetTester tester) async {
    await tester.pumpWidget(const ConverterApp());
    // Check for the title
    expect(find.text('Choose Conversion Type'), findsOneWidget);
    // Check for a few conversion types
    expect(find.text('Area'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Cooking'), findsOneWidget);
    expect(find.text('Energy'), findsOneWidget);
  });

  testWidgets('UnitSelector does not overflow', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'A',
                  items: ['A', 'B', 'C'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (_) {},
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Test',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
    // If there is an overflow, the test will fail with an exception
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });
}
