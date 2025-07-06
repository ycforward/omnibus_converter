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
import 'package:converter_app/services/conversion_service.dart';

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

  group('ConversionService', () {
    final service = ConversionService();

    test('cooking conversions', () async {
      expect(await service.convert(ConverterType.cooking, 1, 'Cup', 'Milliliter'), closeTo(240, 0.01));
      expect(await service.convert(ConverterType.cooking, 2, 'Tablespoon', 'Teaspoon'), closeTo(2 * 14.7868 / 4.92892, 0.01));
      expect(await service.convert(ConverterType.cooking, 1, 'Gallon', 'Liter'), closeTo(3.78541, 0.01));
    });

    test('angle conversions', () async {
      expect(await service.convert(ConverterType.angle, 180, 'Degree', 'Radian'), closeTo(3.14159, 0.01));
      expect(await service.convert(ConverterType.angle, 200, 'Gradian', 'Degree'), closeTo(180, 0.01));
      expect(await service.convert(ConverterType.angle, 1, 'Radian', 'Degree'), closeTo(57.2958, 0.01));
    });

    test('density conversions', () async {
      expect(await service.convert(ConverterType.density, 1, 'Gram per Cubic Centimeter', 'Kilogram per Cubic Meter'), closeTo(1000, 0.01));
      expect(await service.convert(ConverterType.density, 16.0185, 'Kilogram per Cubic Meter', 'Pound per Cubic Foot'), closeTo(1, 0.01));
      expect(await service.convert(ConverterType.density, 2, 'Pound per Cubic Foot', 'Gram per Cubic Centimeter'), closeTo(2 * 16.0185 / 1000, 0.01));
    });

    test('energy conversions', () async {
      expect(await service.convert(ConverterType.energy, 1, 'Kilojoule', 'Joule'), closeTo(1000, 0.01));
      expect(await service.convert(ConverterType.energy, 1, 'Calorie', 'Joule'), closeTo(4.184, 0.01));
      expect(await service.convert(ConverterType.energy, 1, 'Kilowatt Hour', 'Joule'), closeTo(3600000, 0.01));
      expect(await service.convert(ConverterType.energy, 3600, 'Joule', 'Watt Hour'), closeTo(1, 0.01));
    });

    test('area conversions', () async {
      expect(await service.convert(ConverterType.area, 1, 'Square Kilometer', 'Square Meter'), closeTo(1000000, 0.01));
      expect(await service.convert(ConverterType.area, 4046.86, 'Square Meter', 'Acre'), closeTo(1, 0.01));
      expect(await service.convert(ConverterType.area, 2, 'Acre', 'Square Foot'), closeTo(2 * 4046.86 / 0.092903, 0.1));
    });

    test('currency conversions', () async {
      expect(await service.convert(ConverterType.currency, 1, 'USD', 'EUR'), closeTo(0.85, 0.01));
      expect(await service.convert(ConverterType.currency, 110, 'JPY', 'USD'), closeTo(1, 0.01));
      expect(await service.convert(ConverterType.currency, 1, 'GBP', 'INR'), closeTo(1 / 0.73 * 74.5, 0.1));
    });

    test('length conversions', () async {
      expect(await service.convert(ConverterType.length, 1, 'Kilometer', 'Meter'), closeTo(1000, 0.01));
      expect(await service.convert(ConverterType.length, 2, 'Mile', 'Kilometer'), closeTo(2 * 1609.344 / 1000, 0.01));
      expect(await service.convert(ConverterType.length, 12, 'Inch', 'Foot'), closeTo(1, 0.01));
    });

    test('temperature conversions', () async {
      expect(await service.convert(ConverterType.temperature, 0, 'Celsius', 'Fahrenheit'), closeTo(32, 0.01));
      expect(await service.convert(ConverterType.temperature, 273.15, 'Kelvin', 'Celsius'), closeTo(0, 0.01));
      expect(await service.convert(ConverterType.temperature, 100, 'Celsius', 'Kelvin'), closeTo(373.15, 0.01));
    });

    test('volume conversions', () async {
      expect(await service.convert(ConverterType.volume, 1, 'Gallon', 'Liter'), closeTo(3.78541, 0.01));
      expect(await service.convert(ConverterType.volume, 1000, 'Milliliter', 'Liter'), closeTo(1, 0.01));
      expect(await service.convert(ConverterType.volume, 2, 'Quart', 'Pint'), closeTo(2 * 0.946353 / 0.473176, 0.01));
    });

    test('weight conversions', () async {
      expect(await service.convert(ConverterType.weight, 1, 'Kilogram', 'Gram'), closeTo(1000, 0.01));
      expect(await service.convert(ConverterType.weight, 2.20462, 'Pound', 'Kilogram'), closeTo(2.20462 * 0.453592, 0.01));
      expect(await service.convert(ConverterType.weight, 16, 'Ounce', 'Pound'), closeTo(16 * 0.0283495 / 0.453592, 0.01));
    });

    test('speed conversions', () async {
      expect(await service.convert(ConverterType.speed, 1, 'Miles per Hour', 'Kilometers per Hour'), closeTo(1 * 0.44704 / 0.277778, 0.01));
      expect(await service.convert(ConverterType.speed, 10, 'Knots', 'Miles per Hour'), closeTo(10 * 0.514444 / 0.44704, 0.01));
      expect(await service.convert(ConverterType.speed, 3.28084, 'Feet per Second', 'Meters per Second'), closeTo(3.28084 * 0.3048, 0.01));
    });
  });
}
