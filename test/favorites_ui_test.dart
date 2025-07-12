import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:converter_app/screens/favorites_screen.dart';
import 'package:converter_app/models/favorite_conversion.dart';
import 'package:converter_app/models/converter_type.dart';
import 'package:converter_app/services/favorites_service.dart';

void main() {
  group('FavoritesScreen UI Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should show empty state when no favorites', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      expect(find.text('No Favorite Conversions'), findsOneWidget);
      expect(find.text('Add conversions to your favorites from any converter screen'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should show Edit button when favorites exist', (WidgetTester tester) async {
      // Add a favorite first
      final favoritesService = FavoritesService.instance;
      await favoritesService.addFavorite(
        FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR'),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('1 favorite'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
    });

    testWidgets('should toggle edit mode when Edit button is tapped', (WidgetTester tester) async {
      // Add a favorite first
      final favoritesService = FavoritesService.instance;
      await favoritesService.addFavorite(
        FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR'),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Initially should show Edit button and chevron icon
      expect(find.text('Edit'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.text('Clear All'), findsNothing);

      // Tap Edit button
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Should now show Done button, delete button, and Clear All button
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('should exit edit mode when Done button is tapped', (WidgetTester tester) async {
      // Add a favorite first
      final favoritesService = FavoritesService.instance;
      await favoritesService.addFavorite(
        FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR'),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Verify we're in edit mode
      expect(find.text('Done'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      // Tap Done button
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Should return to normal mode
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Done'), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.text('Clear All'), findsNothing);
    });

    testWidgets('should disable tap navigation in edit mode', (WidgetTester tester) async {
      // Add a favorite first
      final favoritesService = FavoritesService.instance;
      await favoritesService.addFavorite(
        FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: const FavoritesScreen(),
          routes: {
            '/converter': (context) => const Scaffold(body: Text('Converter Screen')),
          },
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Try to tap on the favorite item
      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();

      // Should not navigate to converter screen
      expect(find.text('Converter Screen'), findsNothing);
    });

    testWidgets('should show multiple favorites with proper pluralization', (WidgetTester tester) async {
      // Add multiple favorites
      final favoritesService = FavoritesService.instance;
      await favoritesService.addFavorite(
        FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR'),
      );
      await favoritesService.addFavorite(
        FavoriteConversion.create(ConverterType.length, 'Meter', 'Foot'),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      expect(find.text('2 favorites'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Length'), findsOneWidget);
    });

    testWidgets('should remove favorite when delete button is tapped in edit mode', (WidgetTester tester) async {
      // Add a favorite first
      final favoritesService = FavoritesService.instance;
      await favoritesService.addFavorite(
        FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR'),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No Favorite Conversions'), findsOneWidget);
    });
  });
} 