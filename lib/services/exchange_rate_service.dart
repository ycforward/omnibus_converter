import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRateService {
  static const String _baseUrl = 'https://api.unirateapi.com/api';
  static const Duration _cacheDuration = Duration(minutes: 10); // 10 minute cache for fresh rates
  static const String _cacheKey = 'exchange_rates_cache';
  static const String _cacheTimeKey = 'exchange_rates_cache_time';
  
  static Map<String, double> _cachedRates = {};
  static DateTime? _lastFetchTime;
  static bool _isLoading = false;
  static bool _isPreloading = false;

  /// Preload exchange rates on app startup (non-blocking)
  static Future<void> preloadExchangeRates() async {
    if (_isPreloading || _isLoading) return;
    
    _isPreloading = true;
    try {
      // First, try to load from persistent cache
      await _loadFromPersistentCache();
      
      // If cache is still valid, we're done
      if (_isValidCache()) {
        print('Loaded valid exchange rates from cache');
        return;
      }
      
      // If cache is invalid or empty, fetch fresh data in background
      print('Cache invalid or empty, fetching fresh exchange rates...');
      await _fetchFreshRates();
    } catch (e) {
      print('Error during preload: $e');
      // Keep any existing cached rates, don't add mock rates
    } finally {
      _isPreloading = false;
    }
  }

  /// Get exchange rates (uses cached data if available)
  static Future<Map<String, double>> getExchangeRates() async {
    // If we have valid cached rates, return them immediately
    if (_isValidCache()) {
      return _cachedRates;
    }

    // If we're already loading, wait for it
    if (_isLoading) {
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _cachedRates;
    }

    // Load from persistent cache first
    if (_cachedRates.isEmpty) {
      await _loadFromPersistentCache();
    }

    // If we still don't have valid cache, fetch fresh data
    if (!_isValidCache()) {
      await _fetchFreshRates();
    }

    return _cachedRates;
  }

  /// Load cached rates from SharedPreferences
  static Future<void> _loadFromPersistentCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final cacheTimeString = prefs.getString(_cacheTimeKey);
      
      if (cachedData != null && cacheTimeString != null) {
        final cacheTime = DateTime.parse(cacheTimeString);
        final timeSinceCache = DateTime.now().difference(cacheTime);
        
        if (timeSinceCache < _cacheDuration) {
          final Map<String, dynamic> ratesJson = json.decode(cachedData);
          _cachedRates = ratesJson.map((key, value) => MapEntry(key, value.toDouble()));
          _lastFetchTime = cacheTime;
          print('Loaded ${_cachedRates.length} exchange rates from persistent cache');
        } else {
          print('Persistent cache expired, will fetch fresh data');
        }
      }
    } catch (e) {
      print('Error loading from persistent cache: $e');
    }
  }

  /// Save rates to SharedPreferences
  static Future<void> _saveToPersistentCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = json.encode(_cachedRates);
      await prefs.setString(_cacheKey, ratesJson);
      await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
      print('Saved exchange rates to persistent cache');
    } catch (e) {
      print('Error saving to persistent cache: $e');
    }
  }

  /// Fetch fresh rates from API
  static Future<void> _fetchFreshRates() async {
    if (_isLoading) return;
    
    _isLoading = true;
    try {
      final apiKey = dotenv.env['UNIRATE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here' || apiKey == 'mock_key') {
        // Don't set mock rates, just return - keep any existing cached rates
        print('No valid API key configured, keeping existing cached rates');
        return;
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
        
        // Cache the rates in memory and persistently
        _cachedRates = rates;
        _lastFetchTime = DateTime.now();
        await _saveToPersistentCache();
        
        print('Fetched ${rates.length} fresh exchange rates from API');
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        // Keep existing cache if available, don't add mock rates
      }
    } catch (e) {
      print('Error fetching fresh exchange rates: $e');
      // Keep existing cache if available, don't add mock rates
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



  /// Clear cache to force fresh data fetch
  static Future<void> clearCache() async {
    _cachedRates.clear();
    _lastFetchTime = null;
    
    // Also clear persistent cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimeKey);
    } catch (e) {
      print('Error clearing persistent cache: $e');
    }
  }

  /// Check if we're using real API or mock data
  static bool get isUsingRealApi {
    final apiKey = dotenv.env['UNIRATE_API_KEY'];
    return apiKey != null && 
           apiKey.isNotEmpty && 
           apiKey != 'your_api_key_here' &&
           apiKey != 'mock_key';
  }

  /// Get available currency codes from cache (synchronous)
  static List<String> getCachedCurrencies() {
    return _cachedRates.keys.toList();
  }

  /// Check if we have cached rates available
  static bool get hasCachedRates => _cachedRates.isNotEmpty;

  /// Get formatted fetch time for display
  static String? getLastFetchTimeFormatted() {
    if (_lastFetchTime == null) return null;
    
    final now = DateTime.now();
    final diff = now.difference(_lastFetchTime!);
    
    if (diff.inMinutes < 1) {
      return 'Exchange rates updated just now';
    } else if (diff.inMinutes < 60) {
      return 'Exchange rates updated ${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    } else if (diff.inHours < 24) {
      return 'Exchange rates updated ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'Exchange rates updated ${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
  }

  /// Get current cache status for debugging
  static Map<String, dynamic> getCacheStatus() {
    return {
      'hasCache': _cachedRates.isNotEmpty,
      'cacheSize': _cachedRates.length,
      'lastFetchTime': _lastFetchTime?.toIso8601String(),
      'isValid': _isValidCache(),
      'isLoading': _isLoading,
      'isPreloading': _isPreloading,
      'isUsingRealApi': isUsingRealApi,
    };
  }
} 