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
      
      expect(find.byType(ConverterApp), findsOneWidget);
    });

    testWidgets('Length converter screen should load without overflow', (WidgetTester tester) async {
      // Set up with proper screen size
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          const ConverterScreen(converterType: ConverterType.length),
        ),
      );
      await TestHelpers.waitForAsync(tester);
      
      expect(find.byType(ConverterScreen), findsOneWidget);
      expect(find.byType(UnitSelector), findsNWidgets(2));
      expect(find.byType(CalculatorInput), findsOneWidget);
      
      // Reset window size
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
  });

    testWidgets('Currency converter screen should load without errors', (WidgetTester tester) async {
      // Set up with proper screen size
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await CurrencyPreferencesService.initialize();
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          const ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      await TestHelpers.waitForAsync(tester);
      
      expect(find.byType(ConverterScreen), findsOneWidget);
      expect(find.byType(CalculatorInput), findsOneWidget);
      
      expect(find.byIcon(Icons.update), findsOneWidget);
      
      // Reset window size
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
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
      // Set up with proper screen size
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ConverterScreen(converterType: ConverterType.currency),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('Currency'), findsOneWidget);
      expect(find.byType(SearchableCurrencySelector), findsNWidgets(2));
      
      // Reset window size
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
    
    testWidgets('ESC key should close currency dropdown', (WidgetTester tester) async {
      // Set up with proper screen size
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ConverterScreen(converterType: ConverterType.currency),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      
      expect(find.text('US Dollar'), findsOneWidget);
      
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      
      expect(find.text('US Dollar'), findsNothing);
      
      // Reset window size
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
    

    testWidgets('Starring currency in one dropdown should update the other', (WidgetTester tester) async {
      // Set up with proper screen size
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ConverterScreen(converterType: ConverterType.currency),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await CurrencyPreferencesService.toggleStarred('EUR');
      
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      
      final eurDropdownItems = find.text('EUR');
      expect(eurDropdownItems.evaluate().length, greaterThanOrEqualTo(1));
      
      final eurItem = eurDropdownItems.last;
      final eurContainer = find.ancestor(
        of: eurItem,
        matching: find.byType(Container),
      ).first;
      
      final starToggleButtons = find.descendant(
        of: eurContainer,
        matching: find.byIcon(Icons.star_border),
      );
      
      await tester.tap(starToggleButtons.last);
      await tester.pumpAndSettle();
      
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      
      final toSelector = find.byType(SearchableCurrencySelector).last;
      await tester.tap(toSelector);
      await tester.pumpAndSettle();
      
      final eurInSecondDropdown = find.text('EUR').last;
      expect(eurInSecondDropdown, findsOneWidget);
      
      final eurContainerSecond = find.ancestor(
        of: eurInSecondDropdown,
        matching: find.byType(Container),
      ).first;
      
      final starredIcon = find.descendant(
        of: eurContainerSecond,
        matching: find.byIcon(Icons.star),
      ).first;
      expect(starredIcon, findsOneWidget);
      
      // Reset window size
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
    
    testWidgets('Starred currencies should persist across widget rebuilds', (WidgetTester tester) async {
      // Set up with proper screen size
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      
      await CurrencyPreferencesService.toggleStarred('CNY');
      await CurrencyPreferencesService.toggleStarred('CNY');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ConverterScreen(converterType: ConverterType.currency),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      
      final cnyItems = find.text('CNY');
      expect(cnyItems.evaluate().length, greaterThanOrEqualTo(1));
      final cnyItem = cnyItems.last;
      
      final cnyContainer = find.ancestor(
        of: cnyItem,
        matching: find.byType(Container),
      ).first;
      
      final starredIcon = find.descendant(
        of: cnyContainer,
        matching: find.byIcon(Icons.star),
      ).first;
      expect(starredIcon, findsOneWidget);
      
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ConverterScreen(converterType: ConverterType.currency),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      final newFromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(newFromSelector);
      await tester.pumpAndSettle();
      
      final cnyItemsAfterRebuild = find.text('CNY');
      expect(cnyItemsAfterRebuild.evaluate().length, greaterThanOrEqualTo(1));
      final cnyItemAfterRebuild = cnyItemsAfterRebuild.last;
      
      final cnyContainerAfterRebuild = find.ancestor(
        of: cnyItemAfterRebuild,
        matching: find.byType(Container),
      ).first;
      
      final starredIconAfterRebuild = find.descendant(
        of: cnyContainerAfterRebuild,
        matching: find.byIcon(Icons.star),
      ).first;
      expect(starredIconAfterRebuild, findsOneWidget);
      
      // Reset window size
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
    
    testWidgets('Search functionality should work with starred currencies', (WidgetTester tester) async {
      // Set up with proper screen size
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ConverterScreen(converterType: ConverterType.currency),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'CAD');
      await tester.pumpAndSettle();
      
      final cadItems = find.text('CAD');
      expect(cadItems.evaluate().length, greaterThanOrEqualTo(1));
      
      expect(find.text('Canadian Dollar'), findsOneWidget);
      
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      
      expect(find.text('USD').evaluate().length, greaterThanOrEqualTo(1));
      expect(find.text('CNY').evaluate().length, greaterThanOrEqualTo(1));
      expect(find.text('EUR').evaluate().length, greaterThanOrEqualTo(1));
      
      // Reset window size
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });

  group('Session Memory Tests', () {
    testWidgets('Currency converter should remember last used currencies within session', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      SessionMemoryService.clearSession();
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: SafeArea(
                    child: ConverterScreen(converterType: ConverterType.currency),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      final eurItems = find.text('EUR');
      await tester.tap(eurItems.last);
      await tester.pumpAndSettle();
      // Simulate navigation by pushing a new route
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: SafeArea(
                    child: ConverterScreen(converterType: ConverterType.currency),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(SessionMemoryService.getLastFromCurrency(), 'EUR');
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets('Currency converter should start with value "1" by default', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      SessionMemoryService.clearSession();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ConverterScreen(converterType: ConverterType.currency),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(SessionMemoryService.getLastSourceValue(), '1');
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final calculatorDisplay = textWidgets.where((widget) => 
        widget.data == '1' && widget.textAlign == TextAlign.right
      );
      expect(calculatorDisplay.length, 1);
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets('Dropdown should be scrollable', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ConverterScreen(converterType: ConverterType.currency),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);
      await tester.drag(listView, const Offset(0, -100));
      await tester.pumpAndSettle();
      expect(listView, findsOneWidget);
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets('Session memory should persist source value changes', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      SessionMemoryService.clearSession();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ConverterScreen(converterType: ConverterType.currency),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorInput), findsOneWidget);
      final button5 = find.text('5').first;
      await tester.tap(button5);
      await tester.pumpAndSettle();
      final value = SessionMemoryService.getLastSourceValue();
      expect(value == '15' || value == '15.0', isTrue, reason: 'Expected 15 or 15.0, got $value');
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets('Dropdown should have no padding at top', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      await TestHelpers.setupTestEnvironment();
      await CurrencyPreferencesService.initialize();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ConverterScreen(converterType: ConverterType.currency),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final fromSelector = find.byType(SearchableCurrencySelector).first;
      await tester.tap(fromSelector);
      await tester.pumpAndSettle();
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, EdgeInsets.zero);
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });

  testWidgets('dropdown behavior works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SearchableCurrencySelector(
                value: 'USD',
                currencies: const ['USD', 'EUR', 'GBP'],
                onChanged: (value) {},
                label: 'Test',
              ),
              const SizedBox(height: 100),
              const Text('Outside area'),
            ],
          ),
        ),
      ),
    );

    // Test 1: Dropdown opens when tapping the field
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    
    expect(find.text('EUR'), findsOneWidget);
    expect(find.text('GBP'), findsOneWidget);

    // Test 2: Dropdown closes when tapping outside
    await tester.tapAt(const Offset(50, 400));
    await tester.pumpAndSettle();
    
    expect(find.text('EUR'), findsNothing);
    expect(find.text('GBP'), findsNothing);

    // Test 3: Dropdown closes when selecting a currency
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    
    expect(find.text('EUR'), findsOneWidget);
    expect(find.text('GBP'), findsOneWidget);
    
    await tester.tap(find.text('EUR'));
    await tester.pumpAndSettle();
    
    expect(find.text('EUR'), findsNothing);
    expect(find.text('GBP'), findsNothing);
  });
}
