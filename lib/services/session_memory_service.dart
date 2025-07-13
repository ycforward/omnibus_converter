class SessionMemoryService {
  static final Map<String, String> _lastFromUnit = {};
  static final Map<String, String> _lastToUnit = {};
  static final Map<String, String> _lastSourceValue = {};

  /// Remember the last used unit pair for a converter type
  static void rememberUnitPair(String converterType, String fromUnit, String toUnit) {
    _lastFromUnit[converterType] = fromUnit;
    _lastToUnit[converterType] = toUnit;
  }

  /// Remember the last source value for a converter type
  static void rememberSourceValue(String converterType, String value) {
    _lastSourceValue[converterType] = value;
  }

  /// Get the last used from unit for a converter type
  static String? getLastFromUnit(String converterType) {
    return _lastFromUnit[converterType];
  }

  /// Get the last used to unit for a converter type
  static String? getLastToUnit(String converterType) {
    return _lastToUnit[converterType];
  }

  /// Get the last source value for a converter type, defaults to "1" if none remembered
  static String getLastSourceValue(String converterType) {
    final value = _lastSourceValue[converterType];
    if (value == null || value.isEmpty) {
      return '1';
    }
    return value;
  }

  /// Check if we have remembered units for a converter type
  static bool hasRememberedUnits(String converterType) {
    return _lastFromUnit[converterType] != null && _lastToUnit[converterType] != null;
  }

  /// Clear all session memory (for testing)
  static void clearSession() {
    _lastFromUnit.clear();
    _lastToUnit.clear();
    _lastSourceValue.clear();
  }
} 