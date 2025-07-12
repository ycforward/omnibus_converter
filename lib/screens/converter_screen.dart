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
          _result = result.toStringAsFixed(4);
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

  String _getUnitDisplayText(String unit) {
    if (widget.converterType == ConverterType.currency) {
      final symbol = SearchableCurrencySelector.getCurrencySymbol(unit);
      if (symbol.isNotEmpty) {
        return symbol; // Just the symbol, not "$ USD"
      }
    }
    return _getUnitAbbreviation(unit);
  }

  String _getUnitAbbreviation(String unit) {
    // Use abbreviations for all unit types
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
              // Unit selectors (now in separate rows)
              Column(
                children: [
                  widget.converterType == ConverterType.currency
                      ? SearchableCurrencySelector(
                          key: _fromSelectorKey,
                          value: _fromUnit,
                          currencies: _conversionService.getUnits(widget.converterType),
                          onChanged: _onFromUnitChanged,
                          label: '',
                          onStarredChanged: _onStarredCurrencyChanged,
                        )
                      : UnitSelector(
                          value: _fromUnit,
                          units: _conversionService.getUnits(widget.converterType),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _fromUnit = value;
                              });
                              _convertLive(_sourceValue);
                              _checkFavoriteStatus();
                            }
                          },
                          label: '',
                          isCurrency: false,
                        ),
                  const SizedBox(height: 8),
                  Center(
                    child: IconButton(
                      onPressed: _swapUnits,
                      icon: const Icon(Icons.swap_horiz),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  widget.converterType == ConverterType.currency
                      ? SearchableCurrencySelector(
                          key: _toSelectorKey,
                          value: _toUnit,
                          currencies: _conversionService.getUnits(widget.converterType),
                          onChanged: _onToUnitChanged,
                          label: '',
                          onStarredChanged: _onStarredCurrencyChanged,
                        )
                      : UnitSelector(
                          value: _toUnit,
                          units: _conversionService.getUnits(widget.converterType),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _toUnit = value;
                              });
                              _convertLive(_sourceValue);
                              _checkFavoriteStatus();
                            }
                          },
                          label: '',
                          isCurrency: false,
                        ),
                ],
              ),
              const SizedBox(height: 24),
              // Source and target value boxes side by side
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16, right: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getUnitDisplayText(_fromUnit),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _sourceValue.isEmpty ? '0' : _sourceValue,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Equals sign between the boxes
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      '=',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16, left: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getUnitDisplayText(_toUnit),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  _result.isEmpty ? '0' : _result,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Calculator section fills all remaining space, no extra box above
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
              
              // Info section for currency
              if (widget.converterType == ConverterType.currency) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.update,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ExchangeRateService.getLastFetchTimeFormatted() ??
                              'No exchange rates available. Please check your internet connection.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isRefreshing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              onPressed: _refreshExchangeRates,
                              icon: const Icon(Icons.refresh),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              tooltip: 'Refresh exchange rates',
                            ),
                    ],
                  ),
                ),
              ],
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