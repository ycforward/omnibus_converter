import 'package:flutter/material.dart';
import '../models/converter_type.dart';
import '../services/conversion_service.dart';
import '../services/exchange_rate_service.dart';
import '../services/session_memory_service.dart';
import '../services/favorites_service.dart';
import '../services/currency_preferences_service.dart';

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
      final typeKey = widget.converterType.name;
      if (SessionMemoryService.hasRememberedUnits(typeKey)) {
        final lastFrom = SessionMemoryService.getLastFromUnit(typeKey);
        final lastTo = SessionMemoryService.getLastToUnit(typeKey);
        if (lastFrom != null && lastTo != null && units.contains(lastFrom) && units.contains(lastTo)) {
          _fromUnit = lastFrom;
          _toUnit = lastTo;
          return;
        }
      }
      // Fallback to defaults
      if (widget.converterType == ConverterType.currency) {
        _setDefaultCurrencies(units);
      } else {
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
    final typeKey = widget.converterType.name;
    _sourceValue = SessionMemoryService.getLastSourceValue(typeKey);
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
            backgroundColor: Colors.green, // Use green for consistency
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
          SnackBar(
            content: Text('Exchange rates refreshed'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing rates: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
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
    // Remember the source value for this converter type
    SessionMemoryService.rememberSourceValue(widget.converterType.name, value);
    _convertLive(value);
  }

  void _convertLive(String value) {
    final input = double.tryParse(value.isEmpty ? '0' : value);
    if (input == null) {
      setState(() {
        _result = '';
      });
      return;
    }
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
    // Remember the new unit pair for this converter type
    SessionMemoryService.rememberUnitPair(widget.converterType.name, _fromUnit, _toUnit);
    _convertLive(_sourceValue);
    _checkFavoriteStatus();
  }

  void _onFromUnitChanged(String? value) {
    if (value != null) {
      setState(() {
        _fromUnit = value;
      });
      // Remember the new unit pair for this converter type
      SessionMemoryService.rememberUnitPair(widget.converterType.name, _fromUnit, _toUnit);
      _convertLive(_sourceValue);
      _checkFavoriteStatus();
    }
  }

  void _onToUnitChanged(String? value) {
    if (value != null) {
      setState(() {
        _toUnit = value;
      });
      // Remember the new unit pair for this converter type
      SessionMemoryService.rememberUnitPair(widget.converterType.name, _fromUnit, _toUnit);
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
    // instead of scientific notation to be more user-friendly
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

  void _showUnitSelector(bool isSource) {
    final List<String> units = _conversionService.getUnits(widget.converterType);
    final String currentUnit = isSource ? _fromUnit : _toUnit;
    final String label = isSource ? 'From' : 'To';

    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600; // iPad compatibility mode threshold
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(isLargeScreen ? 24.0 : 20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * (isLargeScreen ? 0.6 : 0.7),
          padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
          child: Column(
            children: [
              Text(
                'Select $label Unit',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: isLargeScreen ? 24.0 : null,
                ),
              ),
              SizedBox(height: isLargeScreen ? 24.0 : 16.0),
              Expanded(
                child: widget.converterType == ConverterType.currency
                    ? _CurrencyListWidget(
                        currencies: units,
                        currentUnit: currentUnit,
                        onChanged: (String? value) {
                          if (value != null) {
                            if (isSource) {
                              _onFromUnitChanged(value);
                            } else {
                              _onToUnitChanged(value);
                            }
                          }
                          Navigator.of(context).pop();
                        },
                        onStarredChanged: _onStarredCurrencyChanged,
                      )
                    : ListView.builder(
                        itemCount: units.length,
                        itemBuilder: (context, index) {
                          final unit = units[index];
                          final isSelected = unit == currentUnit;
                          return ListTile(
                            title: Text(unit),
                            subtitle: Text(_getUnitAbbreviation(unit)),
                            trailing: isSelected ? const Icon(Icons.check) : null,
                            selected: isSelected,
                            onTap: () {
                              if (isSource) {
                                _onFromUnitChanged(unit);
                              } else {
                                _onToUnitChanged(unit);
                              }
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper to get full unit name for all types
  String _getUnitFullName(String unit) {
    if (widget.converterType == ConverterType.currency) {
      return unit;
    }
    // For other types, show the full unit name (e.g., Meter, Foot)
    // If abbreviation is present, show only the full name
    switch (unit) {
      case 'Meter': return 'Meter';
      case 'Foot': return 'Foot';
      case 'Kilometer': return 'Kilometer';
      case 'Centimeter': return 'Centimeter';
      case 'Millimeter': return 'Millimeter';
      case 'Mile': return 'Mile';
      case 'Yard': return 'Yard';
      case 'Inch': return 'Inch';
      case 'Kilogram': return 'Kilogram';
      case 'Gram': return 'Gram';
      case 'Pound': return 'Pound';
      case 'Ounce': return 'Ounce';
      case 'Ton': return 'Ton';
      case 'Stone': return 'Stone';
      case 'Celsius': return 'Celsius';
      case 'Fahrenheit': return 'Fahrenheit';
      case 'Kelvin': return 'Kelvin';
      case 'Liter': return 'Liter';
      case 'Milliliter': return 'Milliliter';
      case 'Gallon': return 'Gallon';
      case 'Quart': return 'Quart';
      case 'Pint': return 'Pint';
      case 'Cup': return 'Cup';
      case 'Fluid Ounce': return 'Fluid Ounce';
      case 'Square Meter': return 'Square Meter';
      case 'Square Kilometer': return 'Square Kilometer';
      case 'Square Mile': return 'Square Mile';
      case 'Acre': return 'Acre';
      case 'Square Yard': return 'Square Yard';
      case 'Square Foot': return 'Square Foot';
      case 'Miles per Hour': return 'Miles per Hour';
      case 'Kilometers per Hour': return 'Kilometers per Hour';
      case 'Meters per Second': return 'Meters per Second';
      case 'Knots': return 'Knots';
      case 'Feet per Second': return 'Feet per Second';
      case 'Tablespoon': return 'Tablespoon';
      case 'Teaspoon': return 'Teaspoon';
      case 'Degree': return 'Degree';
      case 'Radian': return 'Radian';
      case 'Gradian': return 'Gradian';
      case 'Kilogram per Cubic Meter': return 'Kilogram per Cubic Meter';
      case 'Gram per Cubic Centimeter': return 'Gram per Cubic Centimeter';
      case 'Pound per Cubic Foot': return 'Pound per Cubic Foot';
      case 'Joule': return 'Joule';
      case 'Kilojoule': return 'Kilojoule';
      case 'Calorie': return 'Calorie';
      case 'Kilocalorie': return 'Kilocalorie';
      case 'Watt Hour': return 'Watt Hour';
      case 'Kilowatt Hour': return 'Kilowatt Hour';
      default: return unit;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600; // iPad compatibility mode threshold
    
    // Responsive padding and spacing
    final horizontalPadding = isLargeScreen ? 32.0 : 16.0;
    final verticalPadding = isLargeScreen ? 24.0 : 16.0;
    final containerHeight = isLargeScreen ? 140.0 : 120.0;
    final borderRadius = isLargeScreen ? 16.0 : 12.0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.converterType.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Refresh button for currency conversions
          if (widget.converterType == ConverterType.currency)
            IconButton(
              onPressed: _isRefreshing ? null : _refreshExchangeRates,
              icon: _isRefreshing 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              tooltip: 'Refresh exchange rates',
            ),
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
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Source value box with integrated unit selector - First row
              Container(
                height: containerHeight, // Responsive height
                margin: EdgeInsets.only(bottom: isLargeScreen ? 24.0 : 16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    // Unit selector as clickable header (unit name only)
                    InkWell(
                      onTap: () => _showUnitSelector(true), // true for source unit
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isLargeScreen ? 16.0 : 12.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.13), // slightly more contrast
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadius),
                            topRight: Radius.circular(borderRadius),
                          ),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getUnitFullName(_fromUnit),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: isLargeScreen ? 18.0 : null,
                              ),
                          ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.black38,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Value display with symbol/abbreviation inline
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isLargeScreen ? 20.0 : 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // For currency: symbol before value
                              if (widget.converterType == ConverterType.currency) ...[
                          Text(
                                  _getUnitDisplayText(_fromUnit) + ' ',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.normal,
                                    fontSize: isLargeScreen ? 22.0 : null,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _formatDisplayValueForLargeNumbers(_sourceValue.isEmpty ? '0' : _sourceValue),
                                    key: const Key('converter_input'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isLargeScreen ? 22.0 : null,
                            ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ] else ...[
                                // For other units: value first, then abbreviation (positioned next to value)
                                Flexible(
                                  child: RichText(
                                    key: const Key('converter_input'),
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: _formatDisplayValueForLargeNumbers(_sourceValue.isEmpty ? '0' : _sourceValue),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontSize: isLargeScreen ? 22.0 : null,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' ' + _getUnitDisplayText(_fromUnit),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.normal,
                                            fontSize: isLargeScreen ? 22.0 : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Vertical swap button - Second row
              Container(
                margin: EdgeInsets.only(bottom: isLargeScreen ? 24.0 : 16.0),
                child: Center(
                  child: IconButton(
                    onPressed: _swapUnits,
                    icon: const Icon(Icons.swap_vert), // Changed to vertical
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      padding: EdgeInsets.all(isLargeScreen ? 16.0 : 12.0),
                    ),
                  ),
                ),
              ),
              
              // Result value box with integrated unit selector - Third row
              Container(
                height: containerHeight, // Responsive height
                margin: EdgeInsets.only(bottom: isLargeScreen ? 24.0 : 16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Unit selector as clickable header (unit name only)
                    InkWell(
                      onTap: () => _showUnitSelector(false), // false for target unit
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isLargeScreen ? 16.0 : 12.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.13), // slightly more contrast
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadius),
                            topRight: Radius.circular(borderRadius),
                          ),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getUnitFullName(_toUnit),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: isLargeScreen ? 18.0 : null,
                              ),
                          ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.black38,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Value display with symbol/abbreviation inline
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isLargeScreen ? 20.0 : 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // For currency: symbol before value
                                    if (widget.converterType == ConverterType.currency) ...[
                                      Text(
                                        _getUnitDisplayText(_toUnit) + ' ',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.normal,
                                          fontSize: isLargeScreen ? 22.0 : null,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          _formatDisplayValueForLargeNumbers(_result.isEmpty ? '0' : _result),
                                          key: const Key('converter_result'),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isLargeScreen ? 22.0 : null,
                                  ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                ),
                                    ] else ...[
                                      // For other units: value first, then abbreviation (positioned next to value)
                                      Flexible(
                                        child: RichText(
                                          key: const Key('converter_result'),
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: _formatDisplayValueForLargeNumbers(_result.isEmpty ? '0' : _result),
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).colorScheme.onSurface,
                                                  fontSize: isLargeScreen ? 22.0 : null,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' ' + _getUnitDisplayText(_toUnit),
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: isLargeScreen ? 22.0 : null,
                                                ),
                  ),
                ],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Calculator input - Third row
              Expanded(
                child: CalculatorInput(
                  onExpressionEvaluated: _convertLive,
                  onExpressionChanged: _onCalculatorChanged,
                  initialValue: _sourceValue,
                  hideExpression: true,
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

// Simple currency list widget for use inside modal
class _CurrencyListWidget extends StatefulWidget {
  final List<String> currencies;
  final String currentUnit;
  final Function(String?) onChanged;
  final VoidCallback onStarredChanged;

  const _CurrencyListWidget({
    required this.currencies,
    required this.currentUnit,
    required this.onChanged,
    required this.onStarredChanged,
  });

  @override
  State<_CurrencyListWidget> createState() => _CurrencyListWidgetState();
}

class _CurrencyListWidgetState extends State<_CurrencyListWidget> {
  late List<String> _filteredCurrencies;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = _getSortedCurrencies();
  }

  List<String> _getSortedCurrencies() {
    return CurrencyPreferencesService.sortCurrenciesWithStarredFirst(widget.currencies);
  }

  void _filterCurrencies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = _getSortedCurrencies();
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredCurrencies = widget.currencies.where((currency) {
          final currencyLower = currency.toLowerCase();
          final currencyName = SearchableCurrencySelector.getCurrencyName(currency)?.toLowerCase() ?? '';
          return currencyLower.contains(lowerQuery) || currencyName.contains(lowerQuery);
        }).toList();

        // Sort filtered results with starred first, then by relevance
        _filteredCurrencies.sort((a, b) {
          final aStarred = CurrencyPreferencesService.isStarred(a);
          final bStarred = CurrencyPreferencesService.isStarred(b);
          
          if (aStarred && !bStarred) return -1;
          if (!aStarred && bStarred) return 1;
          
          // If both have same starred status, sort by relevance (exact match first)
          final aExact = a.toLowerCase() == lowerQuery;
          final bExact = b.toLowerCase() == lowerQuery;
          
          if (aExact && !bExact) return -1;
          if (!aExact && bExact) return 1;
          
          return a.compareTo(b);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search currencies...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: _filterCurrencies,
        ),
        const SizedBox(height: 16),
        // Currency list
        Expanded(
          child: ListView.builder(
            itemCount: _filteredCurrencies.length,
            itemBuilder: (context, index) {
              final currency = _filteredCurrencies[index];
              final isSelected = currency == widget.currentUnit;
              final isStarred = CurrencyPreferencesService.isStarred(currency);
              final symbol = SearchableCurrencySelector.getCurrencySymbol(currency);
              final name = SearchableCurrencySelector.getCurrencyName(currency) ?? '';

              return ListTile(
                title: Row(
                  children: [
                    if (symbol.isNotEmpty) ...[
                      Text(
                        symbol,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      currency,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                subtitle: name.isNotEmpty ? Text(name) : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Star toggle
                    InkWell(
                      onTap: () async {
                        await CurrencyPreferencesService.toggleStarred(currency);
                        setState(() {
                          _filteredCurrencies = _getSortedCurrencies();
                        });
                        widget.onStarredChanged();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isStarred ? Icons.star : Icons.star_border,
                          size: 18,
                          color: isStarred 
                              ? Colors.amber 
                              : Theme.of(context).colorScheme.outline.withOpacity(0.7),
                        ),
                      ),
                    ),
                    // Check mark for selected
                    if (isSelected) const Icon(Icons.check),
                  ],
                ),
                selected: isSelected,
                onTap: () => widget.onChanged(currency),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 