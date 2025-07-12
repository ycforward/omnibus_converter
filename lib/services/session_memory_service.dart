class SessionMemoryService {
  static String? _lastFromCurrency;
  static String? _lastToCurrency;
  static String? _lastSourceValue;

  /// Remember the last used currency pair
  static void rememberCurrencyPair(String fromCurrency, String toCurrency) {
    _lastFromCurrency = fromCurrency;
    _lastToCurrency = toCurrency;
  }

  /// Remember the last source value
  static void rememberSourceValue(String value) {
    _lastSourceValue = value;
  }

  /// Get the last used from currency
  static String? getLastFromCurrency() {
    return _lastFromCurrency;
  }

  /// Get the last used to currency
  static String? getLastToCurrency() {
    return _lastToCurrency;
  }

  /// Get the last source value, defaults to "1" if none remembered
  static String getLastSourceValue() {
    if (_lastSourceValue == null || _lastSourceValue!.isEmpty) {
      return '1';
    }
    return _lastSourceValue!;
  }

  /// Check if we have remembered currencies
  static bool hasRememberedCurrencies() {
    return _lastFromCurrency != null && _lastToCurrency != null;
  }

  /// Clear all session memory (for testing)
  static void clearSession() {
    _lastFromCurrency = null;
    _lastToCurrency = null;
    _lastSourceValue = null;
  }
} 