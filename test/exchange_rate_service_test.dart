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
      test('should return mock rates when no API key is configured', () async {
        // Ensure no API key is set
        dotenv.env['UNIRATE_API_KEY'] = 'your_api_key_here';
        
        final rates = await ExchangeRateService.getExchangeRates();
        
        expect(rates, isNotEmpty);
        expect(rates['USD'], equals(1.0));
        expect(rates['EUR'], isNotNull);
        expect(rates['GBP'], isNotNull);
        expect(rates['JPY'], isNotNull);
      });

      test('should cache rates and return cached data on subsequent calls', () async {
        // Ensure no API key is set to use mock data
        dotenv.env['UNIRATE_API_KEY'] = 'your_api_key_here';
        
        final firstCall = await ExchangeRateService.getExchangeRates();
        final secondCall = await ExchangeRateService.getExchangeRates();
        
        expect(firstCall, equals(secondCall));
        expect(firstCall['USD'], equals(1.0));
      });

      test('should handle invalid API key gracefully', () async {
        dotenv.env['UNIRATE_API_KEY'] = 'invalid_key';
        
        final rates = await ExchangeRateService.getExchangeRates();
        
        expect(rates, isNotEmpty);
        expect(rates['USD'], equals(1.0));
      });
    });

    group('getExchangeRate', () {
      test('should return 1.0 for same currency', () async {
        final rate = await ExchangeRateService.getExchangeRate('USD', 'USD');
        expect(rate, equals(1.0));
      });

      test('should calculate exchange rate between different currencies', () async {
        // Ensure no API key is set to use mock data
        dotenv.env['UNIRATE_API_KEY'] = 'your_api_key_here';
        
        final rate = await ExchangeRateService.getExchangeRate('USD', 'EUR');
        expect(rate, isNotNull);
        expect(rate, greaterThan(0));
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
        // Ensure no API key is set to use mock data
        dotenv.env['UNIRATE_API_KEY'] = 'your_api_key_here';
        
        // First call to populate cache
        await ExchangeRateService.getExchangeRates();
        
        // Clear cache
        ExchangeRateService.clearCache();
        
        // Second call should fetch fresh data
        final rates = await ExchangeRateService.getExchangeRates();
        expect(rates, isNotEmpty);
        expect(rates['USD'], equals(1.0));
      });
    });

    group('API response parsing', () {
      test('should return valid mock rates structure', () async {
        // Ensure no API key is set to use mock data
        dotenv.env['UNIRATE_API_KEY'] = 'your_api_key_here';
        
        final rates = await ExchangeRateService.getExchangeRates();
        expect(rates['USD'], equals(1.0));
        expect(rates['EUR'], equals(0.85));
        expect(rates['GBP'], equals(0.73));
        expect(rates['JPY'], equals(110.0));
      });
    });
  });
} 