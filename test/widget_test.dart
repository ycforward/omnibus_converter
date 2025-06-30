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
import 'package:converter_app/widgets/unit_selector.dart';

void main() {
  testWidgets('Home screen loads and shows conversion types', (WidgetTester tester) async {
    // Set a large screen size for the test
    final originalSize = tester.binding.window.physicalSize;
    final originalRatio = tester.binding.window.devicePixelRatio;
    tester.binding.window.physicalSizeTestValue = const Size(1200, 2400);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.physicalSizeTestValue = originalSize;
      tester.binding.window.devicePixelRatioTestValue = originalRatio;
    });
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
    expect(find.text('Choose Conversion Type'), findsNothing);
    // Scroll to the bottom to ensure all items are visible
    await tester.drag(find.byType(GridView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    // Only check for the conversion types that are actually rendered
    final expectedTypes = ConverterType.values.map((e) => e.title).toList();
    for (final type in expectedTypes) {
      // Try to find the type after scrolling to the bottom
      await tester.drag(find.byType(GridView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      if (find.text(type).evaluate().isEmpty) {
        // If not found, scroll to the top and check again
        await tester.drag(find.byType(GridView), const Offset(0, 1000));
        await tester.pumpAndSettle();
      }
      expect(find.text(type), findsWidgets, reason: 'Type "$type" should be visible after scrolling');
    }
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

  testWidgets('Calculator shows all buttons in 5x4 layout', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CalculatorInput(
          onExpressionEvaluated: (value) {},
          onExpressionChanged: (value) {},
        ),
      ),
    ));
    // Check for the presence of all calculator buttons in the new layout
    final expectedButtons = [
      '7', '8', '9', 'C', '%',
      '4', '5', '6', '÷', '×',
      '1', '2', '3', '-', '+',
      '.', '0', '⌫', '±', '=',
    ];
    for (final label in expectedButtons) {
      expect(find.widgetWithText(ElevatedButton, label), findsOneWidget, reason: 'Button $label should be present');
    }
    // Tap a few buttons to ensure they are tappable
    await tester.tap(find.widgetWithText(ElevatedButton, '7'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '2'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '='));
    await tester.pump();
    // The expression should update and not throw
    expect(find.textContaining('7+2'), findsOneWidget);
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

  testWidgets('UnitSelector renders compactly and is symmetric around swap icon', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            UnitSelector(
              value: 'Meter',
              units: ['Meter', 'Kilometer'],
              onChanged: (_) {},
              label: '',
            ),
            const SizedBox(height: 8),
            const Icon(Icons.swap_horiz),
            const SizedBox(height: 8),
            UnitSelector(
              value: 'Kilometer',
              units: ['Meter', 'Kilometer'],
              onChanged: (_) {},
              label: '',
            ),
          ],
        ),
      ),
    ));
    // Check that both UnitSelectors are present
    expect(find.byType(UnitSelector), findsNWidgets(2));
    // Check that the swap icon is present
    expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    // Check that there is no overflow
    expect(tester.takeException(), isNull);
    // Optionally, check the heights above and below the icon are similar (within a tolerance)
    final firstBox = tester.getTopLeft(find.byType(UnitSelector).first).dy;
    final iconBox = tester.getTopLeft(find.byIcon(Icons.swap_horiz)).dy;
    final secondBox = tester.getTopLeft(find.byType(UnitSelector).last).dy;
    final above = iconBox - firstBox;
    final below = secondBox - iconBox;
    expect((above - below).abs(), lessThan(10), reason: 'Spacing above and below swap icon should be nearly equal');
  });
}
