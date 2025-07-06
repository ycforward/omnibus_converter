import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ExchangeRateService {
  static const String _baseUrl = 'https://api.unirateapi.com/api';
  static const Duration _cacheDuration = Duration(hours: 1);
  
  static Map<String, double> _cachedRates = {};
  static DateTime? _lastFetchTime;
  static bool _isLoading = false;

  /// Get exchange rates for all supported currencies
  static Future<Map<String, double>> getExchangeRates() async {
    // Return cached rates if they're still valid
    if (_isValidCache()) {
      return _cachedRates;
    }

    // Prevent multiple simultaneous requests
    if (_isLoading) {
      // Wait for the ongoing request to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _cachedRates;
    }

    _isLoading = true;

    try {
      final apiKey = dotenv.env['UNIRATE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
        // Fallback to mock rates if no API key is configured
        return _getMockRates();
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/rates?api_key=$apiKey&from=USD'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = _parseExchangeRates(data);
        
        // Cache the rates
        _cachedRates = rates;
        _lastFetchTime = DateTime.now();
        
        return rates;
      } else {
        // Fallback to mock rates on API error
        print('API Error: ${response.statusCode} - ${response.body}');
        return _getMockRates();
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
      return _getMockRates();
    } finally {
      _isLoading = false;
    }
  }

  /// Get exchange rate for a specific currency pair
  static Future<double?> getExchangeRate(String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return 1.0;
    
    final rates = await getExchangeRates();
    final fromRate = rates[fromCurrency];
    final toRate = rates[toCurrency];
    
    if (fromRate == null || toRate == null) {
      return null;
    }
    
    // Convert to USD first, then to target currency
    final usdValue = 1.0 / fromRate;
    return usdValue * toRate;
  }

  /// Check if cached rates are still valid
  static bool _isValidCache() {
    if (_lastFetchTime == null || _cachedRates.isEmpty) {
      return false;
    }
    
    final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
    return timeSinceLastFetch < _cacheDuration;
  }

  /// Parse exchange rates from API response
  static Map<String, double> _parseExchangeRates(Map<String, dynamic> data) {
    final rates = <String, double>{};
    
    // Handle UniRateAPI response format
    if (data.containsKey('rates')) {
      final ratesData = data['rates'] as Map<String, dynamic>;
      ratesData.forEach((currency, rate) {
        if (rate is num) {
          rates[currency] = rate.toDouble();
        }
      });
    }
    
    // Always include USD as base currency
    rates['USD'] = 1.0;
    
    return rates;
  }

  /// Get mock exchange rates as fallback
  static Map<String, double> _getMockRates() {
    return {
      'USD': 1.0,
      'EUR': 0.85,
      'GBP': 0.73,
      'JPY': 110.0,
      'CAD': 1.25,
      'AUD': 1.35,
      'CHF': 0.92,
      'CNY': 6.45,
      'INR': 74.5,
      'BRL': 5.2,
    };
  }

  /// Clear cache to force fresh data fetch
  static void clearCache() {
    _cachedRates.clear();
    _lastFetchTime = null;
  }

  /// Check if we're using real API or mock data
  static bool get isUsingRealApi {
    final apiKey = dotenv.env['UNIRATE_API_KEY'];
    return apiKey != null && 
           apiKey.isNotEmpty && 
           apiKey != 'your_api_key_here';
  }
} 