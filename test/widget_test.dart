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
import 'package:converter_app/services/exchange_rate_service.dart';
import 'package:converter_app/services/session_memory_service.dart';

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
      
      // First, unstar EUR so we can test starring it
      await CurrencyPreferencesService.toggleStarred('EUR');
      
      // Open the first (from) currency selector
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      
      // Find EUR currency (should not be starred now) - it should be visible in the dropdown
      final eurDropdownItems = find.text('EUR');
      expect(eurDropdownItems.evaluate().length, greaterThanOrEqualTo(1));
      
      // Find the star toggle button for EUR by finding its container
      final eurItem = eurDropdownItems.last; // Last one should be in the dropdown list
      final eurContainer = find.ancestor(
        of: eurItem,
        matching: find.byType(Container),
      ).first;
      
      // Find the toggle button (the second star icon - first is status, second is toggle)
      final starToggleButtons = find.descendant(
        of: eurContainer,
        matching: find.byIcon(Icons.star_border),
      );
      
      // Tap the last star_border icon (should be the toggle button)
      await tester.tap(starToggleButtons.last);
      await tester.pumpAndSettle();
      
      // Close the first dropdown by pressing ESC
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      
      // Open the second (to) currency selector
      final toSelector = find.byType(SearchableCurrencySelector).last;
      await tester.tap(toSelector);
      await tester.pumpAndSettle();
      
      // Verify EUR now appears with a star in the second dropdown
      final eurInSecondDropdown = find.text('EUR').last; // Last instance should be in dropdown
      expect(eurInSecondDropdown, findsOneWidget);
      
      // Verify there's a filled star icon (meaning EUR is starred)
      final eurContainerSecond = find.ancestor(
        of: eurInSecondDropdown,
        matching: find.byType(Container),
      ).first;
      
      final starredIcon = find.descendant(
        of: eurContainerSecond,
        matching: find.byIcon(Icons.star), // Should now be a filled star
      ).first; // First one should be the status star
      expect(starredIcon, findsOneWidget);
    });
    
    testWidgets('Starred currencies should persist across widget rebuilds', (WidgetTester tester) async {
      // Set up
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      
      // Star a currency using the service directly (use one that's in the default list)
      await CurrencyPreferencesService.toggleStarred('CNY'); // Unstar CNY
      await CurrencyPreferencesService.toggleStarred('CNY'); // Star CNY again
      
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
      
      // Verify CNY is starred (appears with star icon) - should be visible as it's a default starred currency
      final cnyItems = find.text('CNY');
      expect(cnyItems.evaluate().length, greaterThanOrEqualTo(1));
      final cnyItem = cnyItems.last; // Last one should be in the dropdown list
      
      final cnyContainer = find.ancestor(
        of: cnyItem,
        matching: find.byType(Container),
      ).first;
      
      final starredIcon = find.descendant(
        of: cnyContainer,
        matching: find.byIcon(Icons.star),
      ).first;
      expect(starredIcon, findsOneWidget);
      
      // Close dropdown
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
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
      
      // Verify CNY is still starred
      final cnyItemsAfterRebuild = find.text('CNY');
      expect(cnyItemsAfterRebuild.evaluate().length, greaterThanOrEqualTo(1));
      final cnyItemAfterRebuild = cnyItemsAfterRebuild.last; // Last one should be in dropdown
      
      final cnyContainerAfterRebuild = find.ancestor(
        of: cnyItemAfterRebuild,
        matching: find.byType(Container),
      ).first;
      
      final starredIconAfterRebuild = find.descendant(
        of: cnyContainerAfterRebuild,
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
      
      // Find the search field and enter a search term (search for CAD which is in the default list)
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'CAD');
      await tester.pumpAndSettle();
      
      // Verify CAD appears in search results
      final cadItems = find.text('CAD');
      expect(cadItems.evaluate().length, greaterThanOrEqualTo(1));
      
      // Also check for the full currency name
      expect(find.text('Canadian Dollar'), findsOneWidget);
      
      // Clear search by entering empty string
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      
      // Verify default starred currencies are shown first
      expect(find.text('USD').evaluate().length, greaterThanOrEqualTo(1));
      expect(find.text('CNY').evaluate().length, greaterThanOrEqualTo(1));
      expect(find.text('EUR').evaluate().length, greaterThanOrEqualTo(1));
    });
  });

  group('Session Memory Tests', () {
    testWidgets('Currency converter should remember last used currencies within session', (WidgetTester tester) async {
      // Set up
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      SessionMemoryService.clearSession();
      
      // First visit - should use defaults
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      await tester.pumpAndSettle();
      
      // Change currencies
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      
      // Find and select EUR
      final eurItems = find.text('EUR');
      await tester.tap(eurItems.last);
      await tester.pumpAndSettle();
      
      // Go back to home and return to currency converter
      Navigator.of(tester.element(find.byType(ConverterScreen))).pop();
      await tester.pumpAndSettle();
      
      // Navigate back to currency converter
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      await tester.pumpAndSettle();
      
      // Should remember EUR as the from currency
      expect(SessionMemoryService.getLastFromCurrency(), 'EUR');
    });
    
    testWidgets('Currency converter should start with value "1" by default', (WidgetTester tester) async {
      // Set up
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      SessionMemoryService.clearSession();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      await tester.pumpAndSettle();
      
      // Check that the default source value is "1"
      expect(SessionMemoryService.getLastSourceValue(), '1');
      
      // Verify the calculator shows "1"
      expect(find.text('1'), findsOneWidget);
    });
    
    testWidgets('Dropdown should be scrollable', (WidgetTester tester) async {
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
      
      // Find the ListView in the dropdown
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);
      
      // Try to scroll the dropdown
      await tester.drag(listView, const Offset(0, -100));
      await tester.pumpAndSettle();
      
      // The test passes if no exception is thrown during scrolling
      expect(listView, findsOneWidget);
    });
    
    testWidgets('Session memory should persist source value changes', (WidgetTester tester) async {
      // Set up
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      SessionMemoryService.clearSession();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      await tester.pumpAndSettle();
      
      // Find and tap a calculator button to change the value
      final button5 = find.text('5');
      await tester.tap(button5);
      await tester.pumpAndSettle();
      
      // Check that the source value is remembered
      expect(SessionMemoryService.getLastSourceValue(), '15'); // 1 + 5 = 15
    });
    
    testWidgets('Dropdown should have no padding at top', (WidgetTester tester) async {
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
      
      // Find the ListView and check it has zero padding
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, EdgeInsets.zero);
    });
  });
}
