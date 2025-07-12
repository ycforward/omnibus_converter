import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:converter_app/models/favorite_conversion.dart';
import 'package:converter_app/models/converter_type.dart';
import 'package:converter_app/services/favorites_service.dart';

void main() {
  group('FavoriteConversion Model Tests', () {
    test('should create a favorite conversion correctly', () {
      final favorite = FavoriteConversion.create(
        ConverterType.currency,
        'USD',
        'EUR',
      );

      expect(favorite.converterType, ConverterType.currency);
      expect(favorite.fromUnit, 'USD');
      expect(favorite.toUnit, 'EUR');
      expect(favorite.id, 'currency_USD_EUR');
      expect(favorite.displayTitle, 'Currency: USD → EUR');
    });

    test('should generate unique IDs correctly', () {
      final id1 = FavoriteConversion.generateId(ConverterType.currency, 'USD', 'EUR');
      final id2 = FavoriteConversion.generateId(ConverterType.length, 'Meter', 'Foot');
      final id3 = FavoriteConversion.generateId(ConverterType.currency, 'EUR', 'USD');

      expect(id1, 'currency_USD_EUR');
      expect(id2, 'length_Meter_Foot');
      expect(id3, 'currency_EUR_USD');
      expect(id1, isNot(equals(id2)));
      expect(id1, isNot(equals(id3)));
    });

    test('should serialize to/from JSON correctly', () {
      final original = FavoriteConversion.create(
        ConverterType.temperature,
        'Celsius',
        'Fahrenheit',
      );

      final json = original.toJson();
      final restored = FavoriteConversion.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.converterType, original.converterType);
      expect(restored.fromUnit, original.fromUnit);
      expect(restored.toUnit, original.toUnit);
      expect(restored.createdAt.millisecondsSinceEpoch, 
             original.createdAt.millisecondsSinceEpoch);
    });

    test('should handle equality correctly', () {
      final favorite1 = FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR');
      final favorite2 = FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR');
      final favorite3 = FavoriteConversion.create(ConverterType.currency, 'EUR', 'USD');

      expect(favorite1, equals(favorite2));
      expect(favorite1, isNot(equals(favorite3)));
      expect(favorite1.hashCode, equals(favorite2.hashCode));
    });
  });

  group('FavoritesService Tests', () {
    late FavoritesService favoritesService;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      favoritesService = FavoritesService.instance;
    });

    test('should start with empty favorites list', () async {
      final favorites = await favoritesService.getFavorites();
      expect(favorites, isEmpty);
    });

    test('should add a favorite correctly', () async {
      final favorite = FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR');
      final success = await favoritesService.addFavorite(favorite);
      
      expect(success, isTrue);
      
      final favorites = await favoritesService.getFavorites();
      expect(favorites, hasLength(1));
      expect(favorites.first.id, favorite.id);
    });

    test('should not add duplicate favorites', () async {
      final favorite1 = FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR');
      final favorite2 = FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR');
      
      final success1 = await favoritesService.addFavorite(favorite1);
      final success2 = await favoritesService.addFavorite(favorite2);
      
      expect(success1, isTrue);
      expect(success2, isFalse);
      
      final favorites = await favoritesService.getFavorites();
      expect(favorites, hasLength(1));
    });

    test('should remove a favorite correctly', () async {
      final favorite = FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR');
      await favoritesService.addFavorite(favorite);
      
      final success = await favoritesService.removeFavorite(favorite.id);
      expect(success, isTrue);
      
      final favorites = await favoritesService.getFavorites();
      expect(favorites, isEmpty);
    });

    test('should return false when removing non-existent favorite', () async {
      final success = await favoritesService.removeFavorite('non_existent_id');
      expect(success, isFalse);
    });

    test('should check if conversion is favorite correctly', () async {
      final favorite = FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR');
      await favoritesService.addFavorite(favorite);
      
      final isFavorite1 = await favoritesService.isFavorite(ConverterType.currency, 'USD', 'EUR');
      final isFavorite2 = await favoritesService.isFavorite(ConverterType.currency, 'EUR', 'USD');
      
      expect(isFavorite1, isTrue);
      expect(isFavorite2, isFalse);
    });

    test('should toggle favorite status correctly', () async {
      // Initially not favorite
      final isFavorite1 = await favoritesService.isFavorite(ConverterType.currency, 'USD', 'EUR');
      expect(isFavorite1, isFalse);
      
      // Toggle to favorite
      final success1 = await favoritesService.toggleFavorite(ConverterType.currency, 'USD', 'EUR');
      expect(success1, isTrue);
      
      final isFavorite2 = await favoritesService.isFavorite(ConverterType.currency, 'USD', 'EUR');
      expect(isFavorite2, isTrue);
      
      // Toggle back to not favorite
      final success2 = await favoritesService.toggleFavorite(ConverterType.currency, 'USD', 'EUR');
      expect(success2, isTrue);
      
      final isFavorite3 = await favoritesService.isFavorite(ConverterType.currency, 'USD', 'EUR');
      expect(isFavorite3, isFalse);
    });

    test('should get favorites count correctly', () async {
      expect(await favoritesService.getFavoritesCount(), 0);
      
      await favoritesService.addFavorite(FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR'));
      expect(await favoritesService.getFavoritesCount(), 1);
      
      await favoritesService.addFavorite(FavoriteConversion.create(ConverterType.length, 'Meter', 'Foot'));
      expect(await favoritesService.getFavoritesCount(), 2);
    });

    test('should clear all favorites correctly', () async {
      await favoritesService.addFavorite(FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR'));
      await favoritesService.addFavorite(FavoriteConversion.create(ConverterType.length, 'Meter', 'Foot'));
      
      expect(await favoritesService.getFavoritesCount(), 2);
      
      final success = await favoritesService.clearAllFavorites();
      expect(success, isTrue);
      
      expect(await favoritesService.getFavoritesCount(), 0);
    });

    test('should handle multiple different converter types', () async {
      final currencyFavorite = FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR');
      final lengthFavorite = FavoriteConversion.create(ConverterType.length, 'Meter', 'Foot');
      final tempFavorite = FavoriteConversion.create(ConverterType.temperature, 'Celsius', 'Fahrenheit');
      
      await favoritesService.addFavorite(currencyFavorite);
      await favoritesService.addFavorite(lengthFavorite);
      await favoritesService.addFavorite(tempFavorite);
      
      final favorites = await favoritesService.getFavorites();
      expect(favorites, hasLength(3));
      
      final types = favorites.map((f) => f.converterType).toSet();
      expect(types, contains(ConverterType.currency));
      expect(types, contains(ConverterType.length));
      expect(types, contains(ConverterType.temperature));
    });

    test('should persist favorites across service instances', () async {
      final favorite = FavoriteConversion.create(ConverterType.currency, 'USD', 'EUR');
      await favoritesService.addFavorite(favorite);
      
      // Create a new service instance (simulating app restart)
      final newService = FavoritesService.instance;
      final favorites = await newService.getFavorites();
      
      expect(favorites, hasLength(1));
      expect(favorites.first.id, favorite.id);
    });
  });
} 