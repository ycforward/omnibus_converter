import 'package:flutter_test/flutter_test.dart';
import 'package:converter_app/services/session_memory_service.dart';

void main() {
  group('SessionMemoryService Tests', () {
    setUp(() {
      // Clear session before each test
      SessionMemoryService.clearSession();
    });

    test('should start with no remembered currencies', () {
      expect(SessionMemoryService.hasRememberedCurrencies(), false);
      expect(SessionMemoryService.getLastFromCurrency(), isNull);
      expect(SessionMemoryService.getLastToCurrency(), isNull);
    });

    test('should remember currency pair', () {
      SessionMemoryService.rememberCurrencyPair('USD', 'EUR');
      
      expect(SessionMemoryService.hasRememberedCurrencies(), true);
      expect(SessionMemoryService.getLastFromCurrency(), 'USD');
      expect(SessionMemoryService.getLastToCurrency(), 'EUR');
    });

    test('should remember source value', () {
      expect(SessionMemoryService.getLastSourceValue(), '1'); // Default
      
      SessionMemoryService.rememberSourceValue('100');
      expect(SessionMemoryService.getLastSourceValue(), '100');
      
      SessionMemoryService.rememberSourceValue('42.5');
      expect(SessionMemoryService.getLastSourceValue(), '42.5');
    });

    test('should update currency pair when changed', () {
      SessionMemoryService.rememberCurrencyPair('USD', 'EUR');
      expect(SessionMemoryService.getLastFromCurrency(), 'USD');
      expect(SessionMemoryService.getLastToCurrency(), 'EUR');
      
      SessionMemoryService.rememberCurrencyPair('GBP', 'JPY');
      expect(SessionMemoryService.getLastFromCurrency(), 'GBP');
      expect(SessionMemoryService.getLastToCurrency(), 'JPY');
    });

    test('should clear session correctly', () {
      SessionMemoryService.rememberCurrencyPair('USD', 'EUR');
      SessionMemoryService.rememberSourceValue('100');
      
      expect(SessionMemoryService.hasRememberedCurrencies(), true);
      expect(SessionMemoryService.getLastSourceValue(), '100');
      
      SessionMemoryService.clearSession();
      
      expect(SessionMemoryService.hasRememberedCurrencies(), false);
      expect(SessionMemoryService.getLastFromCurrency(), isNull);
      expect(SessionMemoryService.getLastToCurrency(), isNull);
      expect(SessionMemoryService.getLastSourceValue(), '1'); // Back to default
    });

    test('should handle empty source value correctly', () {
      SessionMemoryService.rememberSourceValue('');
      expect(SessionMemoryService.getLastSourceValue(), '1'); // Should default to '1'
    });
  });
} 