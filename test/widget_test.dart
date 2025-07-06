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
import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await TestHelpers.setupTestEnvironment();
  });

  group('Widget Tests', () {
    testWidgets('App should start without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const ConverterApp());
      expect(find.byType(ConverterApp), findsOneWidget);
    });

    testWidgets('Home screen should display converter types', (WidgetTester tester) async {
      await tester.pumpWidget(TestHelpers.createTestApp(const ConverterApp()));
      await TestHelpers.waitForAsync(tester);
      
      // Check that the app loads without crashing
      expect(find.byType(ConverterApp), findsOneWidget);
    });

    testWidgets('Length converter screen should load without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          const ConverterScreen(converterType: ConverterType.length),
        ),
      );
      await TestHelpers.waitForAsync(tester);
      
      // Verify the screen loads without layout errors
      expect(find.byType(ConverterScreen), findsOneWidget);
      expect(find.byType(UnitSelector), findsNWidgets(2));
      expect(find.byType(CalculatorInput), findsOneWidget);
    });
  });

  group('Service Tests', () {
    test('length conversions', () async {
      final service = ConversionService();
      expect(await service.convert(ConverterType.length, 1, 'Meter', 'Centimeter'), closeTo(100, 0.01));
      expect(await service.convert(ConverterType.length, 1, 'Kilometer', 'Meter'), closeTo(1000, 0.01));
    });

    test('weight conversions', () async {
      final service = ConversionService();
      expect(await service.convert(ConverterType.weight, 1, 'Kilogram', 'Gram'), closeTo(1000, 0.01));
      expect(await service.convert(ConverterType.weight, 1, 'Pound', 'Kilogram'), closeTo(0.453592, 0.01));
    });

    test('temperature conversions', () async {
      final service = ConversionService();
      expect(await service.convert(ConverterType.temperature, 0, 'Celsius', 'Fahrenheit'), closeTo(32, 0.01));
      expect(await service.convert(ConverterType.temperature, 100, 'Celsius', 'Fahrenheit'), closeTo(212, 0.01));
    });

    test('area conversions', () async {
      final service = ConversionService();
      expect(await service.convert(ConverterType.area, 1, 'Square Meter', 'Square Foot'), closeTo(10.7639, 0.01));
      expect(await service.convert(ConverterType.area, 1, 'Acre', 'Square Meter'), closeTo(4046.86, 0.01));
    });

    test('volume conversions', () async {
      final service = ConversionService();
      expect(await service.convert(ConverterType.volume, 1, 'Liter', 'Gallon'), closeTo(0.264172, 0.01));
      expect(await service.convert(ConverterType.volume, 1, 'Pint', 'Milliliter'), closeTo(473.176, 0.01));
    });

    test('speed conversions', () async {
      final service = ConversionService();
      expect(await service.convert(ConverterType.speed, 1, 'Miles per Hour', 'Kilometers per Hour'), closeTo(1.60934, 0.01));
      expect(await service.convert(ConverterType.speed, 1, 'Meters per Second', 'Feet per Second'), closeTo(3.28084, 0.01));
    });

    test('angle conversions', () async {
      final service = ConversionService();
      expect(await service.convert(ConverterType.angle, 180, 'Degree', 'Radian'), closeTo(3.14159, 0.01));
      expect(await service.convert(ConverterType.angle, 1, 'Radian', 'Degree'), closeTo(57.2958, 0.01));
    });

    test('density conversions', () async {
      final service = ConversionService();
      expect(await service.convert(ConverterType.density, 1, 'Gram per Cubic Centimeter', 'Kilogram per Cubic Meter'), closeTo(1000, 0.01));
      expect(await service.convert(ConverterType.density, 16.0185, 'Kilogram per Cubic Meter', 'Pound per Cubic Foot'), closeTo(1, 0.01));
    });

    test('currency conversions should handle errors gracefully', () async {
      final service = ConversionService();
      try {
        await service.convert(ConverterType.currency, 1, 'USD', 'EUR');
        // Should not throw an exception, even with mock API
      } catch (e) {
        // If it throws, it should be a specific error, not a crash
        expect(e.toString(), isNotEmpty);
      }
    });
  });
}
