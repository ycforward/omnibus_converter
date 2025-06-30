import 'package:flutter/material.dart';

class UnitSelector extends StatelessWidget {
  final String value;
  final List<String> units;
  final Function(String?) onChanged;
  final String label;

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CHF': 'CHF',
    'CNY': '¥',
    'INR': '₹',
    'BRL': 'R\$',
  };

  static const Map<String, String> _unitAbbreviations = {
    // Area
    'Square Meter': 'm²',
    'Square Kilometer': 'km²',
    'Square Mile': 'mi²',
    'Acre': 'ac',
    'Square Yard': 'yd²',
    'Square Foot': 'ft²',
    // Length
    'Meter': 'm',
    'Kilometer': 'km',
    'Centimeter': 'cm',
    'Millimeter': 'mm',
    'Mile': 'mi',
    'Yard': 'yd',
    'Foot': 'ft',
    'Inch': 'in',
    // Weight
    'Kilogram': 'kg',
    'Gram': 'g',
    'Pound': 'lb',
    'Ounce': 'oz',
    'Ton': 't',
    'Stone': 'st',
    // Temperature
    'Celsius': '°C',
    'Fahrenheit': '°F',
    'Kelvin': 'K',
    // Volume
    'Liter': 'L',
    'Milliliter': 'mL',
    'Gallon': 'gal',
    'Quart': 'qt',
    'Pint': 'pt',
    'Cup': 'cup',
    'Fluid Ounce': 'fl oz',
    // Speed
    'Miles per Hour': 'mph',
    'Kilometers per Hour': 'km/h',
    'Meters per Second': 'm/s',
    'Knots': 'kn',
    'Feet per Second': 'ft/s',
    // Cooking
    'Tablespoon': 'tbsp',
    'Teaspoon': 'tsp',
    // Angle
    'Degree': '°',
    'Radian': 'rad',
    'Gradian': 'gon',
    // Density
    'Kilogram per Cubic Meter': 'kg/m³',
    'Gram per Cubic Centimeter': 'g/cm³',
    'Pound per Cubic Foot': 'lb/ft³',
    // Energy
    'Joule': 'J',
    'Kilojoule': 'kJ',
    'Calorie': 'cal',
    'Kilocalorie': 'kcal',
    'Watt Hour': 'Wh',
    'Kilowatt Hour': 'kWh',
  };

  String _getUnitDisplay(String unit) {
    if (_currencySymbols.containsKey(unit)) {
      return '${_currencySymbols[unit]} $unit';
    }
    if (_unitAbbreviations.containsKey(unit)) {
      return '${_unitAbbreviations[unit]} ($unit)';
    }
    return unit;
  }

  const UnitSelector({
    super.key,
    required this.value,
    required this.units,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value.isNotEmpty ? value : null,
        items: units.map((unit) {
          return DropdownMenuItem<String>(
            value: unit,
            child: Text(
              _getUnitDisplay(unit),
              style: TextStyle(
                fontWeight: value == unit ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
        ),
        style: Theme.of(context).textTheme.titleMedium,
        isExpanded: true,
        isDense: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.primary,
        ),
        dropdownColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
} 