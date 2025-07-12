import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_conversion.dart';
import '../models/converter_type.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_conversions';
  static FavoritesService? _instance;
  
  // Singleton pattern
  static FavoritesService get instance {
    _instance ??= FavoritesService._internal();
    return _instance!;
  }
  
  FavoritesService._internal();
  
  // Get all favorite conversions
  Future<List<FavoriteConversion>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      return favoritesJson.map((jsonString) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return FavoriteConversion.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }
  
  // Add a favorite conversion
  Future<bool> addFavorite(FavoriteConversion favorite) async {
    try {
      final favorites = await getFavorites();
      
      // Check if already exists
      if (favorites.any((f) => f.id == favorite.id)) {
        return false; // Already exists
      }
      
      favorites.add(favorite);
      await _saveFavorites(favorites);
      return true;
    } catch (e) {
      print('Error adding favorite: $e');
      return false;
    }
  }
  
  // Remove a favorite conversion
  Future<bool> removeFavorite(String favoriteId) async {
    try {
      final favorites = await getFavorites();
      final initialLength = favorites.length;
      
      favorites.removeWhere((f) => f.id == favoriteId);
      
      if (favorites.length < initialLength) {
        await _saveFavorites(favorites);
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }
  
  // Check if a conversion is favorited
  Future<bool> isFavorite(ConverterType converterType, String fromUnit, String toUnit) async {
    try {
      final favorites = await getFavorites();
      final id = FavoriteConversion.generateId(converterType, fromUnit, toUnit);
      return favorites.any((f) => f.id == id);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
  
  // Toggle favorite status
  Future<bool> toggleFavorite(ConverterType converterType, String fromUnit, String toUnit) async {
    try {
      final isCurrentlyFavorite = await isFavorite(converterType, fromUnit, toUnit);
      
      if (isCurrentlyFavorite) {
        final id = FavoriteConversion.generateId(converterType, fromUnit, toUnit);
        return await removeFavorite(id);
      } else {
        final favorite = FavoriteConversion.create(converterType, fromUnit, toUnit);
        return await addFavorite(favorite);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }
  
  // Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      final favorites = await getFavorites();
      return favorites.length;
    } catch (e) {
      print('Error getting favorites count: $e');
      return 0;
    }
  }
  
  // Clear all favorites
  Future<bool> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      return true;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }
  
  // Private method to save favorites to SharedPreferences
  Future<void> _saveFavorites(List<FavoriteConversion> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = favorites.map((f) => jsonEncode(f.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
      rethrow;
    }
  }
} 