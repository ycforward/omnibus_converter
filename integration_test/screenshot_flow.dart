import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:converter_app/main.dart' as app;

Future<void> pauseForScreenshot(String marker, WidgetTester tester, {int seconds = 3}) async {
  // Print a marker for the script to detect
  // ignore: avoid_print
  print('---SCREENSHOT:$marker---');
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: seconds));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App Store Screenshot Flow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Home screen
    await pauseForScreenshot('home_screen', tester);

    // Currency converter
    final currencyCard = find.byKey(const ValueKey('converter_card_currency'));
    await tester.ensureVisible(currencyCard);
    await tester.pumpAndSettle();
    await tester.tap(currencyCard);
    await tester.pumpAndSettle();
    await pauseForScreenshot('currency_converter', tester);

    // Favorite the current conversion (tap the heart icon)
    final favoriteButton = find.byIcon(Icons.favorite_border);
    if (tester.any(favoriteButton)) {
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();
    }

    // Length converter
    final backButton = find.byTooltip('Back');
    if (tester.any(backButton)) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }
    final lengthCard = find.byKey(const ValueKey('converter_card_length'));
    await tester.ensureVisible(lengthCard);
    await tester.pumpAndSettle();
    await tester.tap(lengthCard);
    await tester.pumpAndSettle();
    await pauseForScreenshot('length_converter', tester);

    // Temperature converter
    if (tester.any(backButton)) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }
    final tempCard = find.byKey(const ValueKey('converter_card_temperature'));
    await tester.ensureVisible(tempCard);
    await tester.pumpAndSettle();
    await tester.tap(tempCard);
    await tester.pumpAndSettle();
    await pauseForScreenshot('temperature_converter', tester);

    // Go back to home screen for favorites tab
    if (tester.any(backButton)) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }

    // Favorites tab
    final favoritesTab = find.widgetWithText(Tab, 'Favorites');
    if (tester.any(favoritesTab)) {
      await tester.tap(favoritesTab);
      await tester.pumpAndSettle();
      await pauseForScreenshot('favorites_tab', tester);
    }

    // Unit selection modal (from currency converter)
    final convertersTab = find.widgetWithText(Tab, 'Converters');
    if (tester.any(convertersTab)) {
      await tester.tap(convertersTab);
      await tester.pumpAndSettle();
    }
    final currencyCard2 = find.byKey(const ValueKey('converter_card_currency'));
    await tester.ensureVisible(currencyCard2);
    await tester.pumpAndSettle();
    await tester.tap(currencyCard2);
    await tester.pumpAndSettle();
    
    // Try to find and tap unit selector
    final unitSelectors = find.byType(InkWell);
    if (unitSelectors.evaluate().isNotEmpty) {
      await tester.tap(unitSelectors.first);
      await tester.pumpAndSettle();
      await pauseForScreenshot('unit_selection', tester);
      // Close modal
      final closeButton = find.byTooltip('Close');
      if (tester.any(closeButton)) {
        await tester.tap(closeButton);
        await tester.pumpAndSettle();
      } else {
        // Try tapping outside modal
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
      }
    }

    // Calculator input (enter 100)
    final digitButton = find.widgetWithText(ElevatedButton, '1');
    if (tester.any(digitButton)) {
      await tester.tap(digitButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, '0'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, '0'));
      await tester.pumpAndSettle();
      await pauseForScreenshot('calculator_input', tester);
    }
  });
} 