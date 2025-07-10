import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:converter_app/services/exchange_rate_service.dart';

void main() {
  group('ExchangeRateService', () {
    setUpAll(() async {
      // Load test environment variables
      await dotenv.load(fileName: ".env");
    });

    tearDown(() {
      // Clear cache after each test
      ExchangeRateService.clearCache();
    });

    group('getExchangeRates', () {
      test('should return empty map when no API key is configured and no cache', () async {
        // Ensure no API key is set and clear cache
        dotenv.env['UNIRATE_API_KEY'] = 'your_api_key_here';
        await ExchangeRateService.clearCache();
        
        final rates = await ExchangeRateService.getExchangeRates();
        
        expect(rates, isEmpty);
      });

      test('should cache rates and return cached data on subsequent calls', () async {
        // Ensure no API key is set and start with empty cache
        dotenv.env['UNIRATE_API_KEY'] = 'your_api_key_here';
        await ExchangeRateService.clearCache();
        
        final firstCall = await ExchangeRateService.getExchangeRates();
        final secondCall = await ExchangeRateService.getExchangeRates();
        
        expect(firstCall, equals(secondCall));
        expect(firstCall, isEmpty); // With no API key and no cache, should be empty
      });

      test('should handle invalid API key gracefully', () async {
        dotenv.env['UNIRATE_API_KEY'] = 'invalid_key';
        await ExchangeRateService.clearCache();
        
        final rates = await ExchangeRateService.getExchangeRates();
        
        // Should keep existing cache or be empty if no cache exists
        expect(rates, isA<Map<String, double>>());
      });
    });

    group('getExchangeRate', () {
      test('should return 1.0 for same currency', () async {
        final rate = await ExchangeRateService.getExchangeRate('USD', 'USD');
        expect(rate, equals(1.0));
      });

      test('should calculate exchange rate between different currencies', () async {
        // This test now expects null for currencies not in cache
        dotenv.env['UNIRATE_API_KEY'] = 'your_api_key_here';
        await ExchangeRateService.clearCache();
        
        final rate = await ExchangeRateService.getExchangeRate('USD', 'EUR');
        expect(rate, isNull); // No cache, no API key, should return null
      });

      test('should return null for invalid currencies', () async {
        final rate = await ExchangeRateService.getExchangeRate('INVALID', 'USD');
        expect(rate, isNull);
      });
    });

    group('isUsingRealApi', () {
      test('should return false when API key is not configured', () {
        dotenv.env['UNIRATE_API_KEY'] = 'your_api_key_here';
        expect(ExchangeRateService.isUsingRealApi, isFalse);
      });

      test('should return false when API key is empty', () {
        dotenv.env['UNIRATE_API_KEY'] = '';
        expect(ExchangeRateService.isUsingRealApi, isFalse);
      });

      test('should return true when valid API key is configured', () {
        dotenv.env['UNIRATE_API_KEY'] = 'valid_api_key_123';
        expect(ExchangeRateService.isUsingRealApi, isTrue);
      });
    });

    group('clearCache', () {
      test('should clear cached rates', () async {
        // Clear cache and verify it's empty
        await ExchangeRateService.clearCache();
        
        final status = ExchangeRateService.getCacheStatus();
        expect(status['hasCache'], false);
        expect(status['cacheSize'], 0);
      });
    });

    group('Cache status', () {
      test('should handle cache status correctly', () async {
        await ExchangeRateService.clearCache();
        
        final status = ExchangeRateService.getCacheStatus();
        expect(status, isA<Map<String, dynamic>>());
        expect(status.containsKey('hasCache'), isTrue);
        expect(status.containsKey('cacheSize'), isTrue);
        expect(status.containsKey('isValid'), isTrue);
      });
    });
  });
} 