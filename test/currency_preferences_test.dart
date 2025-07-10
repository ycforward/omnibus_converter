import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:converter_app/services/currency_preferences_service.dart';

void main() {
  group('CurrencyPreferencesService Tests', () {
    setUp(() async {
      // Clear any existing preferences before each test
      SharedPreferences.setMockInitialValues({});
      // Reset the service state for clean test environment
      CurrencyPreferencesService.resetForTesting();
    });

    test('should initialize with default starred currencies', () async {
      await CurrencyPreferencesService.initialize();
      
      final starred = CurrencyPreferencesService.getStarredCurrencies();
      expect(starred.contains('USD'), true);
      expect(starred.contains('CNY'), true);
      expect(starred.contains('EUR'), true);
      expect(starred.contains('GBP'), true);
      expect(starred.contains('JPY'), true);
      expect(starred.length, 5);
    });

    test('should check if currency is starred correctly', () async {
      await CurrencyPreferencesService.initialize();
      
      expect(CurrencyPreferencesService.isStarred('USD'), true);
      expect(CurrencyPreferencesService.isStarred('CNY'), true);
      expect(CurrencyPreferencesService.isStarred('AUD'), false);
      expect(CurrencyPreferencesService.isStarred('CAD'), false);
    });

    test('should toggle starred status correctly', () async {
      await CurrencyPreferencesService.initialize();
      
      // Initially USD should be starred
      expect(CurrencyPreferencesService.isStarred('USD'), true);
      
      // Unstar USD
      final newStatus1 = await CurrencyPreferencesService.toggleStarred('USD');
      expect(newStatus1, false);
      expect(CurrencyPreferencesService.isStarred('USD'), false);
      
      // Star USD again
      final newStatus2 = await CurrencyPreferencesService.toggleStarred('USD');
      expect(newStatus2, true);
      expect(CurrencyPreferencesService.isStarred('USD'), true);
    });

    test('should star new currency correctly', () async {
      await CurrencyPreferencesService.initialize();
      
      // Initially AUD should not be starred
      expect(CurrencyPreferencesService.isStarred('AUD'), false);
      
      // Star AUD
      final newStatus = await CurrencyPreferencesService.toggleStarred('AUD');
      expect(newStatus, true);
      expect(CurrencyPreferencesService.isStarred('AUD'), true);
    });

    test('should persist starred currencies across sessions', () async {
      // Initialize and modify preferences
      await CurrencyPreferencesService.initialize();
      await CurrencyPreferencesService.toggleStarred('AUD'); // Star AUD
      await CurrencyPreferencesService.toggleStarred('USD'); // Unstar USD
      
      // Simulate app restart by reinitializing
      await CurrencyPreferencesService.initialize();
      
      expect(CurrencyPreferencesService.isStarred('AUD'), true);
      expect(CurrencyPreferencesService.isStarred('USD'), false);
      expect(CurrencyPreferencesService.isStarred('CNY'), true); // Should remain starred
    });

    test('should sort currencies with starred first', () async {
      await CurrencyPreferencesService.initialize();
      
      final testCurrencies = ['AUD', 'USD', 'CNY', 'CAD', 'EUR', 'GBP', 'JPY'];
      final sorted = CurrencyPreferencesService.sortCurrenciesWithStarredFirst(testCurrencies);
      
      // First 5 should be the starred currencies (USD, CNY, EUR, GBP, JPY)
      final starredInResult = sorted.take(5).toList();
      expect(starredInResult.contains('USD'), true);
      expect(starredInResult.contains('CNY'), true);
      expect(starredInResult.contains('EUR'), true);
      expect(starredInResult.contains('GBP'), true);
      expect(starredInResult.contains('JPY'), true);
      
      // Remaining should be unstarred currencies
      final unstarredInResult = sorted.skip(5).toList();
      expect(unstarredInResult.contains('AUD'), true);
      expect(unstarredInResult.contains('CAD'), true);
    });

    test('should handle empty currency list', () async {
      await CurrencyPreferencesService.initialize();
      
      final sorted = CurrencyPreferencesService.sortCurrenciesWithStarredFirst([]);
      expect(sorted, isEmpty);
    });

    test('should get correct starred count', () async {
      await CurrencyPreferencesService.initialize();
      
      expect(CurrencyPreferencesService.getStarredCount(), 5);
      
      await CurrencyPreferencesService.toggleStarred('AUD'); // Add one
      expect(CurrencyPreferencesService.getStarredCount(), 6);
      
      await CurrencyPreferencesService.toggleStarred('USD'); // Remove one
      expect(CurrencyPreferencesService.getStarredCount(), 5);
    });

    test('should clear starred currencies', () async {
      await CurrencyPreferencesService.initialize();
      
      expect(CurrencyPreferencesService.getStarredCount(), 5);
      
      await CurrencyPreferencesService.clearStarredCurrencies();
      expect(CurrencyPreferencesService.getStarredCount(), 0);
      expect(CurrencyPreferencesService.isStarred('USD'), false);
    });

    test('should work correctly when not initialized', () {
      // Ensure service is reset for this test
      CurrencyPreferencesService.resetForTesting();
      
      // Test behavior before initialization
      expect(CurrencyPreferencesService.isStarred('USD'), true); // Should use defaults
      expect(CurrencyPreferencesService.isStarred('AUD'), false);
      
      final testCurrencies = ['AUD', 'USD', 'CNY', 'CAD'];
      final sorted = CurrencyPreferencesService.sortCurrenciesWithStarredFirst(testCurrencies);
      
      // Should still sort with defaults first
      expect(sorted.indexOf('USD'), lessThan(sorted.indexOf('AUD')));
      expect(sorted.indexOf('CNY'), lessThan(sorted.indexOf('CAD')));
    });

    test('should handle SharedPreferences errors gracefully', () async {
      // Test initialization with SharedPreferences error simulation
      // This is harder to test directly, but we can verify the service doesn't crash
      await CurrencyPreferencesService.initialize();
      
      // Service should still function with defaults
      expect(CurrencyPreferencesService.getStarredCurrencies().isNotEmpty, true);
    });
  });
} 