import 'package:flutter_test/flutter_test.dart';
import 'package:converter_app/services/session_memory_service.dart';

void main() {
  group('SessionMemoryService Tests', () {
    const typeKey = 'currency';
    setUp(() {
      // Clear session before each test
      SessionMemoryService.clearSession();
    });

    test('should start with no remembered units', () {
      expect(SessionMemoryService.hasRememberedUnits(typeKey), false);
      expect(SessionMemoryService.getLastFromUnit(typeKey), isNull);
      expect(SessionMemoryService.getLastToUnit(typeKey), isNull);
    });

    test('should remember unit pair', () {
      SessionMemoryService.rememberUnitPair(typeKey, 'USD', 'EUR');
      expect(SessionMemoryService.hasRememberedUnits(typeKey), true);
      expect(SessionMemoryService.getLastFromUnit(typeKey), 'USD');
      expect(SessionMemoryService.getLastToUnit(typeKey), 'EUR');
    });

    test('should remember source value', () {
      expect(SessionMemoryService.getLastSourceValue(typeKey), '1'); // Default
      SessionMemoryService.rememberSourceValue(typeKey, '100');
      expect(SessionMemoryService.getLastSourceValue(typeKey), '100');
      SessionMemoryService.rememberSourceValue(typeKey, '42.5');
      expect(SessionMemoryService.getLastSourceValue(typeKey), '42.5');
    });

    test('should update unit pair when changed', () {
      SessionMemoryService.rememberUnitPair(typeKey, 'USD', 'EUR');
      expect(SessionMemoryService.getLastFromUnit(typeKey), 'USD');
      expect(SessionMemoryService.getLastToUnit(typeKey), 'EUR');
      SessionMemoryService.rememberUnitPair(typeKey, 'GBP', 'JPY');
      expect(SessionMemoryService.getLastFromUnit(typeKey), 'GBP');
      expect(SessionMemoryService.getLastToUnit(typeKey), 'JPY');
    });

    test('should clear session correctly', () {
      SessionMemoryService.rememberUnitPair(typeKey, 'USD', 'EUR');
      SessionMemoryService.rememberSourceValue(typeKey, '100');
      expect(SessionMemoryService.hasRememberedUnits(typeKey), true);
      expect(SessionMemoryService.getLastSourceValue(typeKey), '100');
      SessionMemoryService.clearSession();
      expect(SessionMemoryService.hasRememberedUnits(typeKey), false);
      expect(SessionMemoryService.getLastFromUnit(typeKey), isNull);
      expect(SessionMemoryService.getLastToUnit(typeKey), isNull);
      expect(SessionMemoryService.getLastSourceValue(typeKey), '1'); // Back to default
    });

    test('should handle empty source value correctly', () {
      SessionMemoryService.rememberSourceValue(typeKey, '');
      expect(SessionMemoryService.getLastSourceValue(typeKey), '1'); // Should default to '1'
    });
  });
} 