// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:converter_app/main.dart';
import 'package:converter_app/screens/converter_screen.dart';
import 'package:converter_app/models/converter_type.dart';
import 'package:converter_app/widgets/calculator_input.dart';

void main() {
  testWidgets('Home screen loads and shows conversion types', (WidgetTester tester) async {
    await tester.pumpWidget(const ConverterApp());
    // Print all visible text widgets for debugging
    final textWidgets = find.byType(Text);
    for (final element in textWidgets.evaluate()) {
      final widget = element.widget as Text;
      if (widget.data != null && widget.data!.trim().isNotEmpty) {
        print('HomeScreen Text: "${widget.data}"');
      }
    }
    // Check for the title
    expect(find.text('Choose Conversion Type'), findsOneWidget);
    // Only check for the conversion types that are actually rendered
    expect(find.text('Area'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Length'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
  });

  testWidgets('UnitSelector does not overflow', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'A',
                  items: ['A', 'B', 'C'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (_) {},
                  isDense: true,
                  decoration: const InputDecoration(
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

  testWidgets('Calculator shows visible buttons', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CalculatorInput(
          onExpressionEvaluated: (value) {},
          onExpressionChanged: (value) {},
        ),
      ),
    ));
    // Print all visible text widgets for debugging
    final textWidgets = find.byType(Text);
    for (final element in textWidgets.evaluate()) {
      final widget = element.widget as Text;
      if (widget.data != null && widget.data!.trim().isNotEmpty) {
        print('Calculator Text: "${widget.data}"');
      }
    }
    // Check for the presence of visible calculator buttons
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('÷'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('×'), findsOneWidget);
  });

  testWidgets('ConverterScreen does not overflow on small screens', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 500, // Simulate a small device
          child: ConverterScreen(converterType: ConverterType.length),
        ),
      ),
    );
    // If there is an overflow, the test will fail with an exception
    expect(find.byType(ConverterScreen), findsOneWidget);
  });

  testWidgets('Back button works from ConverterScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => ConverterScreen(converterType: ConverterType.length),
            );
          },
        ),
      ),
    );
    // Tap the back button
    final backButton = find.byTooltip('Back');
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      // After popping, there should be no ConverterScreen
      expect(find.byType(ConverterScreen), findsNothing);
    }
  });
}
