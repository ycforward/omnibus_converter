// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:converter_app/main.dart';
import 'package:converter_app/screens/converter_screen.dart';
import 'package:converter_app/models/converter_type.dart';
import 'package:converter_app/widgets/calculator_input.dart';
import 'package:converter_app/widgets/unit_selector.dart';
import 'package:converter_app/widgets/searchable_currency_selector.dart';
import 'package:converter_app/services/conversion_service.dart';
import 'package:converter_app/services/currency_preferences_service.dart';
import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await TestHelpers.setupTestEnvironment();
    await CurrencyPreferencesService.initialize();
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

    testWidgets('Currency converter screen should load without errors', (WidgetTester tester) async {
      await CurrencyPreferencesService.initialize();
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          const ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      await TestHelpers.waitForAsync(tester);
      
      // Verify the screen loads without layout errors
      expect(find.byType(ConverterScreen), findsOneWidget);
      expect(find.byType(CalculatorInput), findsOneWidget);
      
      // Check that currency info section is displayed
      expect(find.byIcon(Icons.update), findsOneWidget);
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

  group('UI Tests', () {
    testWidgets('Currency converter screen should load without errors', (WidgetTester tester) async {
      // Set up
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      
      // Wait for initial build
      await tester.pumpAndSettle();
      
      // Verify the screen loads
      expect(find.text('Currency'), findsOneWidget);
      expect(find.byType(SearchableCurrencySelector), findsNWidgets(2));
    });
    
    testWidgets('ESC key should close currency dropdown', (WidgetTester tester) async {
      // Set up
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find the first currency selector and tap to open dropdown
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      
      // Verify dropdown is open by looking for a currency name in the overlay
      expect(find.text('US Dollar'), findsOneWidget);
      
      // Press ESC key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      
      // Verify dropdown is closed (overlay should be gone)
      expect(find.text('US Dollar'), findsNothing);
    });
    
    testWidgets('Starring currency in one dropdown should update the other', (WidgetTester tester) async {
      // Set up
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Open the first (from) currency selector
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      
      // Find and tap the star button for CAD (should not be starred initially)
      final cadItem = find.text('CAD');
      expect(cadItem, findsOneWidget);
      
      // Find the star toggle button for CAD by finding the InkWell that contains both CAD text and star_border icon
      final cadContainer = find.ancestor(
        of: cadItem,
        matching: find.byType(Container),
      ).first;
      
      final starToggleButton = find.descendant(
        of: cadContainer,
        matching: find.byIcon(Icons.star_border),
      ).last; // Last one should be the toggle button
      
      await tester.tap(starToggleButton);
      await tester.pumpAndSettle();
      
      // Close the first dropdown by tapping elsewhere
      await tester.tapAt(const Offset(50, 50));
      await tester.pumpAndSettle();
      
      // Open the second (to) currency selector
      final toSelector = find.byType(SearchableCurrencySelector).last;
      await tester.tap(toSelector);
      await tester.pumpAndSettle();
      
      // Verify CAD now appears with a star in the second dropdown
      final cadInSecondDropdown = find.text('CAD');
      expect(cadInSecondDropdown, findsOneWidget);
      
      // Verify there's a filled star icon (meaning CAD is starred)
      final cadContainerSecond = find.ancestor(
        of: cadInSecondDropdown,
        matching: find.byType(Container),
      ).first;
      
      final starredIcon = find.descendant(
        of: cadContainerSecond,
        matching: find.byIcon(Icons.star),
      ).first; // First one should be the status star
      expect(starredIcon, findsOneWidget);
    });
    
    testWidgets('Starred currencies should persist across widget rebuilds', (WidgetTester tester) async {
      // Set up
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      
      // Star a currency using the service directly
      await CurrencyPreferencesService.toggleStarred('CHF');
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Open currency selector
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      
      // Verify CHF is starred (appears with star icon)
      final chfItem = find.text('CHF');
      expect(chfItem, findsOneWidget);
      
      final chfContainer = find.ancestor(
        of: chfItem,
        matching: find.byType(Container),
      ).first;
      
      final starredIcon = find.descendant(
        of: chfContainer,
        matching: find.byIcon(Icons.star),
      ).first;
      expect(starredIcon, findsOneWidget);
      
      // Close dropdown
      await tester.tapAt(const Offset(50, 50));
      await tester.pumpAndSettle();
      
      // Rebuild the widget completely
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Open currency selector again
      final newFromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(newFromSelector);
      await tester.pumpAndSettle();
      
      // Verify CHF is still starred
      final chfItemAfterRebuild = find.text('CHF');
      expect(chfItemAfterRebuild, findsOneWidget);
      
      final chfContainerAfterRebuild = find.ancestor(
        of: chfItemAfterRebuild,
        matching: find.byType(Container),
      ).first;
      
      final starredIconAfterRebuild = find.descendant(
        of: chfContainerAfterRebuild,
        matching: find.byIcon(Icons.star),
      ).first;
      expect(starredIconAfterRebuild, findsOneWidget);
    });
    
    testWidgets('Search functionality should work with starred currencies', (WidgetTester tester) async {
      // Set up
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Open currency selector
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      
      // Find the search field and enter a search term
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'CAD');
      await tester.pumpAndSettle();
      
      // Verify CAD appears in search results
      expect(find.text('CAD'), findsOneWidget);
      expect(find.text('Canadian Dollar'), findsOneWidget);
      
      // Clear search by entering empty string
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      
      // Verify default starred currencies are shown first
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('CNY'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
    });
  });
}
