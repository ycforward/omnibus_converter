import 'package:flutter/material.dart';
import '../models/favorite_conversion.dart';
import '../services/favorites_service.dart';
import '../widgets/searchable_currency_selector.dart';
import 'converter_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService.instance;
  List<FavoriteConversion> _favorites = [];
  bool _isLoading = true;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await _favoritesService.getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading favorites: $e')),
        );
      }
    }
  }

  Future<void> _removeFavorite(FavoriteConversion favorite) async {
    final success = await _favoritesService.removeFavorite(favorite.id);
    if (success) {
      setState(() {
        _favorites.removeWhere((f) => f.id == favorite.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorite removed'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error removing favorite'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Favorites'),
          content: const Text('Are you sure you want to remove all favorite conversions?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await _favoritesService.clearAllFavorites();
      if (success) {
        setState(() {
          _favorites.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All favorites cleared'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _navigateToConverter(FavoriteConversion favorite) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConverterScreen(converterType: favorite.converterType),
      ),
    );
  }

  String _getUnitDisplayText(FavoriteConversion favorite, String unit) {
    if (favorite.converterType.name == 'currency') {
      final symbol = SearchableCurrencySelector.getCurrencySymbol(unit);
      if (symbol.isNotEmpty) {
        return '$symbol ($unit)';
      }
    }
    return unit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorite Conversions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add conversions to your favorites from any converter screen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return Column(
      children: [
        if (_favorites.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_favorites.length} favorite${_favorites.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    if (_isEditMode)
                      TextButton.icon(
                        onPressed: _clearAllFavorites,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All'),
                      ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditMode = !_isEditMode;
                        });
                      },
                      child: Text(_isEditMode ? 'Done' : 'Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _favorites.length,
            itemBuilder: (context, index) {
              final favorite = _favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    favorite.converterType.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(favorite.converterType.title),
                  subtitle: Text(
                    '${_getUnitDisplayText(favorite, favorite.fromUnit)} → ${_getUnitDisplayText(favorite, favorite.toUnit)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isEditMode)
                        IconButton(
                          onPressed: () => _removeFavorite(favorite),
                          icon: const Icon(Icons.delete_outline),
                          color: Theme.of(context).colorScheme.error,
                        ),
                      if (!_isEditMode)
                        const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: _isEditMode ? null : () => _navigateToConverter(favorite),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 