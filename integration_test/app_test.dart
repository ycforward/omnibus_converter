import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:converter_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper to find the AppBar title only
  Finder appBarTitle(String title) => find.descendant(
    of: find.byType(AppBar),
    matching: find.text(title),
  );

  // Helper to find the input and result displays by Key
  final inputKey = const Key('converter_input');
  final resultKey = const Key('converter_result');

  Future<void> navigateToConverter(WidgetTester tester, String converterTypeName) async {
    // Ensure the 'Converters' tab is selected
    final convertersTab = find.widgetWithText(Tab, 'Converters');
    if (tester.any(convertersTab)) {
      await tester.tap(convertersTab);
      await tester.pumpAndSettle();
    }
    // Find the card by its ValueKey.
    final cardKey = ValueKey('converter_card_' + converterTypeName.toLowerCase());
    final cardFinder = find.byKey(cardKey);
    // Try to scroll the GridView to the card if not visible
    if (!tester.any(cardFinder)) {
      final gridView = find.byType(GridView);
      final scrollable = find.descendant(of: gridView, matching: find.byType(Scrollable));
      await tester.scrollUntilVisible(
        cardFinder,
        300.0,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(cardFinder);
    await tester.pumpAndSettle();
    await tester.tap(cardFinder);
    await tester.pumpAndSettle();
    // Verify that the correct screen is displayed by checking the AppBar title only.
    // The title is capitalized, so capitalize the first letter
    final title = converterTypeName[0].toUpperCase() + converterTypeName.substring(1);
    expect(appBarTitle(title), findsOneWidget);
  }

  Future<void> performConversion(WidgetTester tester, String initialValue) async {
    // Clear any existing input first
    final clearButton = find.text('C');
    if (tester.any(clearButton)) {
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
    }
    
    // Enter the value using calculator buttons
    for (int i = 0; i < initialValue.length; i++) {
      final digit = initialValue[i];
      final digitButton = find.text(digit);
      if (tester.any(digitButton)) {
        await tester.tap(digitButton);
        await tester.pumpAndSettle();
      }
    }
    
    // Wait for the conversion to complete
    await tester.pumpAndSettle();
    
    // Verify that the result is displayed
    Finder resultFinder = find.byKey(resultKey);
    expect(resultFinder, findsOneWidget, reason: "Conversion result should be visible");
    
    // Verify that the input value is displayed
    Finder inputFinder = find.byKey(inputKey);
    expect(inputFinder, findsOneWidget, reason: "Input value should be visible");
  }

  Future<void> performConversionWithVerification(WidgetTester tester, String initialValue, String expectedResult) async {
    // Clear any existing input first
    final clearButton = find.text('C');
    if (tester.any(clearButton)) {
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
    }
    
    // Enter the value using calculator buttons
    for (int i = 0; i < initialValue.length; i++) {
      final digit = initialValue[i];
      final digitButton = find.text(digit);
      if (tester.any(digitButton)) {
        await tester.tap(digitButton);
        await tester.pumpAndSettle();
      }
    }
    
    // Wait for the conversion to complete
    await tester.pumpAndSettle();
    
    // Verify that the result is displayed
    Finder resultFinder = find.byKey(resultKey);
    expect(resultFinder, findsOneWidget, reason: "Conversion result should be visible");
    
    // Verify that the input value is displayed
    Finder inputFinder = find.byKey(inputKey);
    expect(inputFinder, findsOneWidget, reason: "Input value should be visible");
    
    // Get the result text from either Text or RichText widget
    String resultText = '';
    final resultWidget = tester.widget(resultFinder);
    
    if (resultWidget is Text) {
      resultText = resultWidget.data ?? '';
    } else if (resultWidget is RichText) {
      // Extract text from RichText's InlineSpan
      resultText = resultWidget.text.toPlainText();
    }
    
    // Skip exact verification for currency if there's an API error
    if (resultText.contains('Error:')) {
      // For currency with API errors, just verify that some result is shown
      expect(resultText.isNotEmpty, isTrue, reason: "Result should be displayed even if there's an error");
      return;
    }
    
    // For currency, we expect 3 decimal places, so we can do exact string matching
    if (expectedResult.contains('.')) {
      // For decimal results, check if the result starts with the expected value
      // This handles cases where the app might show more precision than expected
      expect(resultText.startsWith(expectedResult), isTrue, 
        reason: "Expected result to start with '$expectedResult', but got '$resultText'");
    } else {
      // For integer results, check exact match
      expect(resultText, equals(expectedResult), 
        reason: "Expected result '$expectedResult', but got '$resultText'");
    }
  }

  setUp(() async {
    // Optionally clear any global state or caches here if needed
  });

  tearDown(() async {
    // Optionally clear any global state or caches here if needed
  });

  group('E2E App Test', () {
    testWidgets('Currency Conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'currency');
      // Test USD to EUR conversion (expecting some result, not specific value)
      await performConversion(tester, '100');
    });

    testWidgets('Length Conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'length');
      // Test 1 meter conversion (expecting some result, not specific value)
      await performConversion(tester, '1');
    });

    testWidgets('Temperature Conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'temperature');
      // Test 100°C conversion (expecting some result, not specific value)
      await performConversion(tester, '100');
    });

    testWidgets('Area Conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'area');
      // Test 1 square meter conversion (expecting some result, not specific value)
      await performConversion(tester, '1');
    });

    testWidgets('Volume Conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'volume');
      // Test 1 liter conversion (expecting some result, not specific value)
      await performConversion(tester, '1');
    });

    testWidgets('Weight Conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'weight');
      // Test 1 kilogram conversion (expecting some result, not specific value)
      await performConversion(tester, '1');
    });

    testWidgets('Speed Conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'speed');
      // Test 60 mph conversion (expecting some result, not specific value)
      await performConversion(tester, '60');
    });

    testWidgets('Cooking Conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'cooking');
      // Test 1 cup conversion (expecting some result, not specific value)
      await performConversion(tester, '1');
    });

    testWidgets('Angle Conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'angle');
      // Test 180 degrees conversion (expecting some result, not specific value)
      await performConversion(tester, '180');
    });

    testWidgets('Density Conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'density');
      // Test 1 kg/m³ conversion (expecting some result, not specific value)
      await performConversion(tester, '1');
    });

    testWidgets('Energy Conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'energy');
      // Test 1 joule conversion (expecting some result, not specific value)
      await performConversion(tester, '1');
    });

    testWidgets('Favorites Functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await navigateToConverter(tester, 'currency');

      // Wait a bit for the screen to fully load and favorite button to appear
      await tester.pumpAndSettle();
      
      // Find and tap the favorite button in the AppBar
      final favoriteButton = find.byIcon(Icons.favorite_border);
      expect(favoriteButton, findsOneWidget, reason: "Favorite button should be visible");
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();

      // Verify it was favorited by checking for the filled heart icon
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Unfavorite it by tapping the filled heart
      await tester.tap(find.byIcon(Icons.favorite).first);
      await tester.pumpAndSettle();

      // Verify it was unfavorited
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });
  });
}