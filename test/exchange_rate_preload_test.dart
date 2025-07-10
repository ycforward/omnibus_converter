import 'package:flutter_test/flutter_test.dart';
import 'package:converter_app/services/exchange_rate_service.dart';
import 'test_helpers.dart';

void main() {
  group('Exchange Rate Preloading Tests', () {
    setUp(() async {
      await TestHelpers.setupTestEnvironment();
    });

    test('should preload exchange rates successfully', () async {
      // Clear cache first
      await ExchangeRateService.clearCache();
      
      // Verify cache is empty
      var status = ExchangeRateService.getCacheStatus();
      expect(status['hasCache'], false);
      expect(status['cacheSize'], 0);
      
      // Preload exchange rates
      await ExchangeRateService.preloadExchangeRates();
      
      // Verify cache is populated
      status = ExchangeRateService.getCacheStatus();
      expect(status['hasCache'], true);
      expect(status['cacheSize'], greaterThan(0));
      
      // Verify we have cached currencies
      final currencies = ExchangeRateService.getCachedCurrencies();
      expect(currencies.isNotEmpty, true);
      expect(currencies.contains('USD'), true);
    });

    test('should use cached rates for fast access', () async {
      // Preload first
      await ExchangeRateService.preloadExchangeRates();
      
      // Measure time for first call (should be fast since cached)
      final stopwatch = Stopwatch()..start();
      final rates1 = await ExchangeRateService.getExchangeRates();
      stopwatch.stop();
      final firstCallTime = stopwatch.elapsedMilliseconds;
      
      // Reset stopwatch for second call
      stopwatch.reset();
      stopwatch.start();
      final rates2 = await ExchangeRateService.getExchangeRates();
      stopwatch.stop();
      final secondCallTime = stopwatch.elapsedMilliseconds;
      
      // Both calls should return same data
      expect(rates1.length, rates2.length);
      expect(rates1['USD'], rates2['USD']);
      
      // Both calls should be fast (under 50ms since they use cache)
      expect(firstCallTime, lessThan(50));
      expect(secondCallTime, lessThan(50));
      
      print('First call: ${firstCallTime}ms, Second call: ${secondCallTime}ms');
    });

    test('should handle currency conversion with preloaded rates', () async {
      // Preload rates
      await ExchangeRateService.preloadExchangeRates();
      
      // Test currency conversion
      final rate = await ExchangeRateService.getExchangeRate('USD', 'EUR');
      expect(rate, isNotNull);
      expect(rate, isA<double>());
      expect(rate! > 0, true);
      
      // Test same currency conversion
      final sameRate = await ExchangeRateService.getExchangeRate('USD', 'USD');
      expect(sameRate, 1.0);
    });

    test('should persist cache across service calls', () async {
      // Clear cache first
      await ExchangeRateService.clearCache();
      
      // Preload and get initial cache status
      await ExchangeRateService.preloadExchangeRates();
      final initialStatus = ExchangeRateService.getCacheStatus();
      final initialTime = initialStatus['lastFetchTime'];
      
      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Make another call - should use cache
      await ExchangeRateService.getExchangeRates();
      final laterStatus = ExchangeRateService.getCacheStatus();
      final laterTime = laterStatus['lastFetchTime'];
      
      // Cache timestamp should be the same (no new fetch)
      expect(laterTime, equals(initialTime));
      expect(laterStatus['hasCache'], true);
    });

    test('should provide cache status information', () async {
      await ExchangeRateService.preloadExchangeRates();
      
      final status = ExchangeRateService.getCacheStatus();
      
      expect(status, isA<Map<String, dynamic>>());
      expect(status.containsKey('hasCache'), true);
      expect(status.containsKey('cacheSize'), true);
      expect(status.containsKey('lastFetchTime'), true);
      expect(status.containsKey('isValid'), true);
      expect(status.containsKey('isLoading'), true);
      expect(status.containsKey('isPreloading'), true);
      expect(status.containsKey('isUsingRealApi'), true);
      
      expect(status['hasCache'], true);
      expect(status['cacheSize'], greaterThan(0));
      expect(status['isLoading'], false);
      expect(status['isPreloading'], false);
    });
  });
} 