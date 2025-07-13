import 'package:flutter/material.dart';
import '../models/converter_type.dart';
import '../services/conversion_service.dart';
import '../services/exchange_rate_service.dart';
import '../services/session_memory_service.dart';
import '../services/favorites_service.dart';

import '../widgets/unit_selector.dart';
import '../widgets/searchable_currency_selector.dart';
import '../widgets/calculator_input.dart';

class ConverterScreen extends StatefulWidget {
  final ConverterType converterType;

  const ConverterScreen({super.key, required this.converterType});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final ConversionService _conversionService = ConversionService();
  final FavoritesService _favoritesService = FavoritesService.instance;
  
  String _fromUnit = '';
  String _toUnit = '';
  String _result = '';
  String _sourceValue = '';
  bool _isLoading = false;
  bool _isFavorite = false;
  bool _isRefreshing = false;
  
  // Key to force rebuild of currency selectors when starred currencies change
  Key _fromSelectorKey = UniqueKey();
  Key _toSelectorKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initializeUnits();
    _initializeSourceValue();
    
    // Perform initial conversion if we have a source value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sourceValue.isNotEmpty) {
        _convertLive(_sourceValue);
      }
      _checkFavoriteStatus();
    });
  }

  void _initializeUnits() {
    final units = _conversionService.getUnits(widget.converterType);
    if (units.isNotEmpty) {
      if (widget.converterType == ConverterType.currency) {
        // Use session memory if available, otherwise use defaults
        if (SessionMemoryService.hasRememberedCurrencies()) {
          final lastFrom = SessionMemoryService.getLastFromCurrency();
          final lastTo = SessionMemoryService.getLastToCurrency();
          
          // Verify the remembered currencies are still available
          if (lastFrom != null && lastTo != null && 
              units.contains(lastFrom) && units.contains(lastTo)) {
            _fromUnit = lastFrom;
            _toUnit = lastTo;
          } else {
            _setDefaultCurrencies(units);
          }
        } else {
          _setDefaultCurrencies(units);
        }
      } else {
        // For other conversions, use first two units
        _fromUnit = units.first;
        _toUnit = units.length > 1 ? units[1] : units.first;
      }
    }
  }

  void _setDefaultCurrencies(List<String> units) {
    // Set default currency conversion to USD → CNY
    _fromUnit = units.contains('USD') ? 'USD' : units.first;
    _toUnit = units.contains('CNY') ? 'CNY' : (units.length > 1 ? units[1] : units.first);
  }

  void _initializeSourceValue() {
    if (widget.converterType == ConverterType.currency) {
      // Use remembered source value or default to "1"
      _sourceValue = SessionMemoryService.getLastSourceValue();
    } else {
      // All other converter types should also start with "1"
      _sourceValue = '1';
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (_fromUnit.isNotEmpty && _toUnit.isNotEmpty) {
      final isFavorite = await _favoritesService.isFavorite(
        widget.converterType,
        _fromUnit,
        _toUnit,
      );
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_fromUnit.isEmpty || _toUnit.isEmpty) return;

    final success = await _favoritesService.toggleFavorite(
      widget.converterType,
      _fromUnit,
      _toUnit,
    );

    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _refreshExchangeRates() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Clear the cache to force fresh data
      await ExchangeRateService.clearCache();
      
      // Fetch fresh rates
      await ExchangeRateService.getExchangeRates();
      
      // Perform conversion again with fresh rates
      if (_sourceValue.isNotEmpty) {
        _convertLive(_sourceValue);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exchange rates refreshed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing rates: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }
  
  void _onStarredCurrencyChanged() {
    // Force rebuild of both currency selectors to update starred status
    if (mounted) {
      setState(() {
        _fromSelectorKey = UniqueKey();
        _toSelectorKey = UniqueKey();
      });
    }
  }

  void _onCalculatorChanged(String value) {
    setState(() {
      _sourceValue = value;
    });
    
    // Remember the source value for currency conversions
    if (widget.converterType == ConverterType.currency) {
      SessionMemoryService.rememberSourceValue(value);
    }
    
    _convertLive(value);
  }

  void _convertLive(String value) {
    // Handle empty value
    if (value.isEmpty) {
      setState(() {
        _result = '';
      });
      return;
    }
    
    final input = double.tryParse(value);
    if (input == null) {
      setState(() {
        _result = '';
      });
      return;
    }
    
    // Always perform conversion, even for 0 (e.g., 0°C = 32°F)
    setState(() {
      _isLoading = true;
    });
    
    _performConversion(input);
  }

  Future<void> _performConversion(double input) async {
    try {
      final result = await _conversionService.convert(
        widget.converterType,
        input,
        _fromUnit,
        _toUnit,
      );
      
      if (mounted) {
        setState(() {
          _result = _formatResult(result);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    
    // Remember the new currency pair for currency conversions
    if (widget.converterType == ConverterType.currency) {
      SessionMemoryService.rememberCurrencyPair(_fromUnit, _toUnit);
    }
    
    _convertLive(_sourceValue);
    _checkFavoriteStatus();
  }

  void _onFromUnitChanged(String? value) {
    if (value != null) {
      setState(() {
        _fromUnit = value;
      });
      
      // Remember the new currency pair for currency conversions
      if (widget.converterType == ConverterType.currency) {
        SessionMemoryService.rememberCurrencyPair(_fromUnit, _toUnit);
      }
      
      _convertLive(_sourceValue);
      _checkFavoriteStatus();
    }
  }

  void _onToUnitChanged(String? value) {
    if (value != null) {
      setState(() {
        _toUnit = value;
      });
      
      // Remember the new currency pair for currency conversions
      if (widget.converterType == ConverterType.currency) {
        SessionMemoryService.rememberCurrencyPair(_fromUnit, _toUnit);
      }
      
      _convertLive(_sourceValue);
      _checkFavoriteStatus();
    }
  }

  String _formatResult(double result) {
    if (widget.converterType == ConverterType.currency) {
      // Always show three decimal places for currency
      return result.toStringAsFixed(3);
    }
    // Handle very large numbers with scientific notation
    if (result.abs() >= 1e12) {
      return result.toStringAsExponential(2);
    }
    // For normal numbers, use appropriate decimal places
    if (result.abs() >= 1000) {
      // Large numbers: use fewer decimal places
      return result.toStringAsFixed(0);
    } else if (result.abs() >= 1) {
      // Medium numbers: use 2 decimal places
      return result.toStringAsFixed(2);
    } else {
      // Small numbers: use up to 4 decimal places but remove trailing zeros
      String formatted = result.toStringAsFixed(4);
      // Remove trailing zeros
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
      return formatted;
    }
  }

  String _formatDisplayValue(String value) {
    if (value.isEmpty || value == '0') return '0';
    
    final double? number = double.tryParse(value);
    if (number == null) return value;
    
    // Handle very large numbers with scientific notation
    if (number.abs() >= 1e9) {
      return number.toStringAsExponential(2);
    }
    
    // Add thousand separators for large numbers
    if (number.abs() >= 1000) {
      final parts = value.split('.');
      final intPart = parts[0];
      final decPart = parts.length > 1 ? '.${parts[1]}' : '';
      
      // Add commas every 3 digits
      final formatted = intPart.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
      
      return formatted + decPart;
    }
    
    return value;
  }

  String _formatDisplayValueForLargeNumbers(String value) {
    if (value.isEmpty || value == '0') return '0';
    
    final double? number = double.tryParse(value);
    if (number == null) return value;
    
    // For very large numbers, use formatted display with thousand separators
    // instead of scientific notation to avoid display issues
    if (number.abs() >= 1000) {
      final parts = value.split('.');
      final intPart = parts[0];
      final decPart = parts.length > 1 ? '.${parts[1]}' : '';
      
      // Add commas every 3 digits
      final formatted = intPart.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
      
      return formatted + decPart;
    }
    
    return value;
  }

  String _getUnitAbbreviation(String unit) {
    switch (unit) {
      // Length units
      case 'Meter': return 'm';
      case 'Kilometer': return 'km';
      case 'Centimeter': return 'cm';
      case 'Millimeter': return 'mm';
      case 'Mile': return 'mi';
      case 'Yard': return 'yd';
      case 'Foot': return 'ft';
      case 'Inch': return 'in';
      
      // Weight units
      case 'Kilogram': return 'kg';
      case 'Gram': return 'g';
      case 'Pound': return 'lb';
      case 'Ounce': return 'oz';
      case 'Ton': return 't';
      case 'Stone': return 'st';
      
      // Temperature units
      case 'Celsius': return '°C';
      case 'Fahrenheit': return '°F';
      case 'Kelvin': return 'K';
      
      // Volume units
      case 'Liter': return 'L';
      case 'Milliliter': return 'mL';
      case 'Gallon': return 'gal';
      case 'Quart': return 'qt';
      case 'Pint': return 'pt';
      case 'Cup': return 'cup';
      case 'Fluid Ounce': return 'fl oz';
      
      // Area units
      case 'Square Meter': return 'm²';
      case 'Square Kilometer': return 'km²';
      case 'Square Mile': return 'mi²';
      case 'Acre': return 'ac';
      case 'Square Yard': return 'yd²';
      case 'Square Foot': return 'ft²';
      
      // Speed units
      case 'Miles per Hour': return 'mph';
      case 'Kilometers per Hour': return 'km/h';
      case 'Meters per Second': return 'm/s';
      case 'Knots': return 'kn';
      case 'Feet per Second': return 'ft/s';
      
      // Cooking units
      case 'Tablespoon': return 'tbsp';
      case 'Teaspoon': return 'tsp';
      
      // Angle units
      case 'Degree': return '°';
      case 'Radian': return 'rad';
      case 'Gradian': return 'grad';
      
      // Density units
      case 'Kilogram per Cubic Meter': return 'kg/m³';
      case 'Gram per Cubic Centimeter': return 'g/cm³';
      case 'Pound per Cubic Foot': return 'lb/ft³';
      
      // Energy units
      case 'Joule': return 'J';
      case 'Kilojoule': return 'kJ';
      case 'Calorie': return 'cal';
      case 'Kilocalorie': return 'kcal';
      case 'Watt Hour': return 'Wh';
      case 'Kilowatt Hour': return 'kWh';
      
      // Default: return the unit as-is if no abbreviation found
      default: return unit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.converterType.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Source unit selector row
              Row(
                children: [
                  Expanded(
                    child: widget.converterType == ConverterType.currency
                        ? SearchableCurrencySelector(
                            key: _fromSelectorKey,
                            value: _fromUnit,
                            currencies: _conversionService.getUnits(widget.converterType),
                            onChanged: _onFromUnitChanged,
                            label: 'From',
                            onStarredChanged: _onStarredCurrencyChanged,
                          )
                        : UnitSelector(
                            value: _fromUnit,
                            units: _conversionService.getUnits(widget.converterType),
                            onChanged: _onFromUnitChanged,
                            label: 'From',
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Source value box
              Container(
                height: 80,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatDisplayValueForLargeNumbers(_sourceValue.isEmpty ? '0' : _sourceValue),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Swap button row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _swapUnits,
                    icon: const Icon(Icons.swap_vert),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Target unit selector row
              Row(
                children: [
                  Expanded(
                    child: widget.converterType == ConverterType.currency
                        ? SearchableCurrencySelector(
                            key: _toSelectorKey,
                            value: _toUnit,
                            currencies: _conversionService.getUnits(widget.converterType),
                            onChanged: _onToUnitChanged,
                            label: 'To',
                            onStarredChanged: _onStarredCurrencyChanged,
                          )
                        : UnitSelector(
                            value: _toUnit,
                            units: _conversionService.getUnits(widget.converterType),
                            onChanged: _onToUnitChanged,
                            label: 'To',
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Target value box
              Container(
                height: 80,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _formatDisplayValueForLargeNumbers(_result.isEmpty ? '0' : _result),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Calculator section fills remaining space, accounting for info section
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: CalculatorInput(
                        initialValue: _sourceValue,
                        onExpressionEvaluated: (value) {
                          _onCalculatorChanged(value);
                        },
                        onExpressionChanged: (value) {
                          _onCalculatorChanged(value);
                        },
                      ),
                    ),
                    
                    // Compact info section for currency
                    if (widget.converterType == ConverterType.currency) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.update,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                ExchangeRateService.getLastFetchTimeFormatted() ??
                                    'No exchange rates available',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _isRefreshing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 1.5),
                                  )
                                : IconButton(
                                    onPressed: _refreshExchangeRates,
                                    icon: const Icon(Icons.refresh),
                                    iconSize: 16,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                    tooltip: 'Refresh exchange rates',
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
} 