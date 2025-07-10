import 'package:shared_preferences/shared_preferences.dart';

class CurrencyPreferencesService {
  static const String _starredCurrenciesKey = 'starred_currencies';
  static const List<String> _defaultStarredCurrencies = ['USD', 'CNY', 'EUR', 'GBP', 'JPY'];
  
  static Set<String> _starredCurrencies = {};
  static bool _isInitialized = false;

  /// Initialize the service by loading starred currencies from storage
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final starredList = prefs.getStringList(_starredCurrenciesKey);
      
      if (starredList != null && starredList.isNotEmpty) {
        _starredCurrencies = starredList.toSet();
      } else {
        // Set default starred currencies on first run
        _starredCurrencies = _defaultStarredCurrencies.toSet();
        await _saveStarredCurrencies();
      }
      
      _isInitialized = true;
      print('Loaded ${_starredCurrencies.length} starred currencies: ${_starredCurrencies.join(", ")}');
    } catch (e) {
      print('Error loading starred currencies: $e');
      // Fallback to defaults
      _starredCurrencies = _defaultStarredCurrencies.toSet();
      _isInitialized = true;
    }
  }

  /// Get the list of starred currencies
  static Set<String> getStarredCurrencies() {
    if (!_isInitialized) {
      // Return defaults if not initialized
      return _defaultStarredCurrencies.toSet();
    }
    return _starredCurrencies;
  }

  /// Check if a currency is starred
  static bool isStarred(String currency) {
    if (!_isInitialized) {
      return _defaultStarredCurrencies.contains(currency);
    }
    return _starredCurrencies.contains(currency);
  }

  /// Toggle the starred status of a currency
  static Future<bool> toggleStarred(String currency) async {
    await initialize(); // Ensure initialized
    
    bool wasStarred = _starredCurrencies.contains(currency);
    
    if (wasStarred) {
      _starredCurrencies.remove(currency);
    } else {
      _starredCurrencies.add(currency);
    }
    
    await _saveStarredCurrencies();
    print('${wasStarred ? "Unstarred" : "Starred"} currency: $currency');
    
    return !wasStarred; // Return new starred status
  }

  /// Save starred currencies to SharedPreferences
  static Future<void> _saveStarredCurrencies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_starredCurrenciesKey, _starredCurrencies.toList());
    } catch (e) {
      print('Error saving starred currencies: $e');
    }
  }

  /// Get currencies sorted with starred ones first
  static List<String> sortCurrenciesWithStarredFirst(List<String> currencies) {
    if (!_isInitialized) {
      // If not initialized, just ensure defaults are first
      final starred = currencies.where((c) => _defaultStarredCurrencies.contains(c)).toList();
      final unstarred = currencies.where((c) => !_defaultStarredCurrencies.contains(c)).toList();
      
      // Sort starred currencies by default order
      starred.sort((a, b) => _defaultStarredCurrencies.indexOf(a).compareTo(_defaultStarredCurrencies.indexOf(b)));
      unstarred.sort();
      
      return [...starred, ...unstarred];
    }

    final starred = currencies.where((c) => _starredCurrencies.contains(c)).toList();
    final unstarred = currencies.where((c) => !_starredCurrencies.contains(c)).toList();
    
    // Sort starred currencies alphabetically, unstarred currencies alphabetically
    starred.sort();
    unstarred.sort();
    
    return [...starred, ...unstarred];
  }

  /// Clear all starred currencies (for testing/reset)
  static Future<void> clearStarredCurrencies() async {
    _starredCurrencies.clear();
    await _saveStarredCurrencies();
  }

  /// Reset service state (for testing)
  static void resetForTesting() {
    _starredCurrencies.clear();
    _isInitialized = false;
  }

  /// Get count of starred currencies
  static int getStarredCount() {
    return _starredCurrencies.length;
  }
} 