import '../models/converter_type.dart';
import 'exchange_rate_service.dart';

class ConversionService {
  // Exchange rates will be fetched from API
  Map<String, double>? _exchangeRates;
  bool _isLoadingRates = false;

  List<String> getUnits(ConverterType type) {
    switch (type) {
      case ConverterType.currency:
        return _getCurrencyUnits();
      case ConverterType.length:
        return ['Meter', 'Kilometer', 'Centimeter', 'Millimeter', 'Mile', 'Yard', 'Foot', 'Inch'];
      case ConverterType.weight:
        return ['Kilogram', 'Gram', 'Pound', 'Ounce', 'Ton', 'Stone'];
      case ConverterType.temperature:
        return ['Celsius', 'Fahrenheit', 'Kelvin'];
      case ConverterType.volume:
        return ['Liter', 'Milliliter', 'Gallon', 'Quart', 'Pint', 'Cup', 'Fluid Ounce'];
      case ConverterType.area:
        return ['Square Meter', 'Square Kilometer', 'Square Mile', 'Acre', 'Square Yard', 'Square Foot'];
      case ConverterType.speed:
        return ['Miles per Hour', 'Kilometers per Hour', 'Meters per Second', 'Knots', 'Feet per Second'];
      case ConverterType.cooking:
        return ['Tablespoon', 'Teaspoon', 'Cup', 'Pint', 'Quart', 'Gallon', 'Fluid Ounce', 'Milliliter', 'Liter'];
      case ConverterType.angle:
        return ['Degree', 'Radian', 'Gradian'];
      case ConverterType.density:
        return ['Kilogram per Cubic Meter', 'Gram per Cubic Centimeter', 'Pound per Cubic Foot'];
      case ConverterType.energy:
        return ['Joule', 'Kilojoule', 'Calorie', 'Kilocalorie', 'Watt Hour', 'Kilowatt Hour'];
    }
  }

  Future<double> convert(ConverterType type, double value, String fromUnit, String toUnit) async {
    if (fromUnit == toUnit) return value;

    switch (type) {
      case ConverterType.currency:
        return await _convertCurrency(value, fromUnit, toUnit);
      case ConverterType.length:
        return _convertLength(value, fromUnit, toUnit);
      case ConverterType.weight:
        return _convertWeight(value, fromUnit, toUnit);
      case ConverterType.temperature:
        return _convertTemperature(value, fromUnit, toUnit);
      case ConverterType.volume:
        return _convertVolume(value, fromUnit, toUnit);
      case ConverterType.area:
        return _convertArea(value, fromUnit, toUnit);
      case ConverterType.speed:
        return _convertSpeed(value, fromUnit, toUnit);
      case ConverterType.cooking:
        return _convertCooking(value, fromUnit, toUnit);
      case ConverterType.angle:
        return _convertAngle(value, fromUnit, toUnit);
      case ConverterType.density:
        return _convertDensity(value, fromUnit, toUnit);
      case ConverterType.energy:
        return _convertEnergy(value, fromUnit, toUnit);
    }
  }

  List<String> _getCurrencyUnits() {
    // Return a default list of currencies if rates haven't been loaded yet
    if (_exchangeRates == null) {
      return ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'INR', 'BRL'];
    }
    return _exchangeRates!.keys.toList();
  }

  Future<void> _ensureExchangeRatesLoaded() async {
    if (_exchangeRates == null && !_isLoadingRates) {
      _isLoadingRates = true;
      try {
        _exchangeRates = await ExchangeRateService.getExchangeRates();
      } finally {
        _isLoadingRates = false;
      }
    }
  }

  Future<double> _convertCurrency(double value, String fromUnit, String toUnit) async {
    await _ensureExchangeRatesLoaded();
    
    final fromRate = _exchangeRates?[fromUnit];
    final toRate = _exchangeRates?[toUnit];
    
    if (fromRate == null || toRate == null) {
      throw Exception('Invalid currency unit: $fromUnit or $toUnit');
    }
    
    // Convert to USD first, then to target currency
    final usdValue = value / fromRate;
    return usdValue * toRate;
  }

  double _convertLength(double value, String fromUnit, String toUnit) {
    // Convert to meters first
    double meters = _lengthToMeters(value, fromUnit);
    return _metersToLength(meters, toUnit);
  }

  double _lengthToMeters(double value, String unit) {
    switch (unit) {
      case 'Meter': return value;
      case 'Kilometer': return value * 1000;
      case 'Centimeter': return value / 100;
      case 'Millimeter': return value / 1000;
      case 'Mile': return value * 1609.344;
      case 'Yard': return value * 0.9144;
      case 'Foot': return value * 0.3048;
      case 'Inch': return value * 0.0254;
      default: throw Exception('Invalid length unit');
    }
  }

  double _metersToLength(double meters, String unit) {
    switch (unit) {
      case 'Meter': return meters;
      case 'Kilometer': return meters / 1000;
      case 'Centimeter': return meters * 100;
      case 'Millimeter': return meters * 1000;
      case 'Mile': return meters / 1609.344;
      case 'Yard': return meters / 0.9144;
      case 'Foot': return meters / 0.3048;
      case 'Inch': return meters / 0.0254;
      default: throw Exception('Invalid length unit');
    }
  }

  double _convertWeight(double value, String fromUnit, String toUnit) {
    // Convert to kilograms first
    double kg = _weightToKg(value, fromUnit);
    return _kgToWeight(kg, toUnit);
  }

  double _weightToKg(double value, String unit) {
    switch (unit) {
      case 'Kilogram': return value;
      case 'Gram': return value / 1000;
      case 'Pound': return value * 0.453592;
      case 'Ounce': return value * 0.0283495;
      case 'Ton': return value * 1000;
      case 'Stone': return value * 6.35029;
      default: throw Exception('Invalid weight unit');
    }
  }

  double _kgToWeight(double kg, String unit) {
    switch (unit) {
      case 'Kilogram': return kg;
      case 'Gram': return kg * 1000;
      case 'Pound': return kg / 0.453592;
      case 'Ounce': return kg / 0.0283495;
      case 'Ton': return kg / 1000;
      case 'Stone': return kg / 6.35029;
      default: throw Exception('Invalid weight unit');
    }
  }

  double _convertTemperature(double value, String fromUnit, String toUnit) {
    // Convert to Celsius first
    double celsius = _temperatureToCelsius(value, fromUnit);
    return _celsiusToTemperature(celsius, toUnit);
  }

  double _temperatureToCelsius(double value, String unit) {
    switch (unit) {
      case 'Celsius': return value;
      case 'Fahrenheit': return (value - 32) * 5 / 9;
      case 'Kelvin': return value - 273.15;
      default: throw Exception('Invalid temperature unit');
    }
  }

  double _celsiusToTemperature(double celsius, String unit) {
    switch (unit) {
      case 'Celsius': return celsius;
      case 'Fahrenheit': return celsius * 9 / 5 + 32;
      case 'Kelvin': return celsius + 273.15;
      default: throw Exception('Invalid temperature unit');
    }
  }

  double _convertVolume(double value, String fromUnit, String toUnit) {
    // Convert to liters first
    double liters = _volumeToLiters(value, fromUnit);
    return _litersToVolume(liters, toUnit);
  }

  double _volumeToLiters(double value, String unit) {
    switch (unit) {
      case 'Liter': return value;
      case 'Milliliter': return value / 1000;
      case 'Gallon': return value * 3.78541;
      case 'Quart': return value * 0.946353;
      case 'Pint': return value * 0.473176;
      case 'Cup': return value * 0.236588;
      case 'Fluid Ounce': return value * 0.0295735;
      default: throw Exception('Invalid volume unit');
    }
  }

  double _litersToVolume(double liters, String unit) {
    switch (unit) {
      case 'Liter': return liters;
      case 'Milliliter': return liters * 1000;
      case 'Gallon': return liters / 3.78541;
      case 'Quart': return liters / 0.946353;
      case 'Pint': return liters / 0.473176;
      case 'Cup': return liters / 0.236588;
      case 'Fluid Ounce': return liters / 0.0295735;
      default: throw Exception('Invalid volume unit');
    }
  }

  double _convertArea(double value, String fromUnit, String toUnit) {
    // Convert to square meters first
    double sqMeters = _areaToSqMeters(value, fromUnit);
    return _sqMetersToArea(sqMeters, toUnit);
  }

  double _areaToSqMeters(double value, String unit) {
    switch (unit) {
      case 'Square Meter': return value;
      case 'Square Kilometer': return value * 1000000;
      case 'Square Mile': return value * 2589988.11;
      case 'Acre': return value * 4046.86;
      case 'Square Yard': return value * 0.836127;
      case 'Square Foot': return value * 0.092903;
      default: throw Exception('Invalid area unit');
    }
  }

  double _sqMetersToArea(double sqMeters, String unit) {
    switch (unit) {
      case 'Square Meter': return sqMeters;
      case 'Square Kilometer': return sqMeters / 1000000;
      case 'Square Mile': return sqMeters / 2589988.11;
      case 'Acre': return sqMeters / 4046.86;
      case 'Square Yard': return sqMeters / 0.836127;
      case 'Square Foot': return sqMeters / 0.092903;
      default: throw Exception('Invalid area unit');
    }
  }

  double _convertSpeed(double value, String fromUnit, String toUnit) {
    // Convert to meters per second first
    double mps = _speedToMps(value, fromUnit);
    return _mpsToSpeed(mps, toUnit);
  }

  double _speedToMps(double value, String unit) {
    switch (unit) {
      case 'Meters per Second': return value;
      case 'Miles per Hour': return value * 0.44704;
      case 'Kilometers per Hour': return value * 0.277778;
      case 'Knots': return value * 0.514444;
      case 'Feet per Second': return value * 0.3048;
      default: throw Exception('Invalid speed unit');
    }
  }

  double _mpsToSpeed(double mps, String unit) {
    switch (unit) {
      case 'Meters per Second': return mps;
      case 'Miles per Hour': return mps / 0.44704;
      case 'Kilometers per Hour': return mps / 0.277778;
      case 'Knots': return mps / 0.514444;
      case 'Feet per Second': return mps / 0.3048;
      default: throw Exception('Invalid speed unit');
    }
  }

  // --- Cooking conversions (volume) ---
  double _convertCooking(double value, String fromUnit, String toUnit) {
    // Convert to milliliters first
    double ml = _cookingToMl(value, fromUnit);
    return _mlToCooking(ml, toUnit);
  }

  double _cookingToMl(double value, String unit) {
    switch (unit) {
      case 'Milliliter': return value;
      case 'Liter': return value * 1000;
      case 'Cup': return value * 240;
      case 'Pint': return value * 473.176;
      case 'Quart': return value * 946.353;
      case 'Gallon': return value * 3785.41;
      case 'Fluid Ounce': return value * 29.5735;
      case 'Tablespoon': return value * 14.7868;
      case 'Teaspoon': return value * 4.92892;
      default: throw Exception('Invalid cooking unit');
    }
  }

  double _mlToCooking(double ml, String unit) {
    switch (unit) {
      case 'Milliliter': return ml;
      case 'Liter': return ml / 1000;
      case 'Cup': return ml / 240;
      case 'Pint': return ml / 473.176;
      case 'Quart': return ml / 946.353;
      case 'Gallon': return ml / 3785.41;
      case 'Fluid Ounce': return ml / 29.5735;
      case 'Tablespoon': return ml / 14.7868;
      case 'Teaspoon': return ml / 4.92892;
      default: throw Exception('Invalid cooking unit');
    }
  }

  // --- Angle conversions ---
  double _convertAngle(double value, String fromUnit, String toUnit) {
    // Convert to degrees first
    double degrees = _angleToDegrees(value, fromUnit);
    return _degreesToAngle(degrees, toUnit);
  }

  double _angleToDegrees(double value, String unit) {
    switch (unit) {
      case 'Degree': return value;
      case 'Radian': return value * 180 / 3.141592653589793;
      case 'Gradian': return value * 0.9;
      default: throw Exception('Invalid angle unit');
    }
  }

  double _degreesToAngle(double degrees, String unit) {
    switch (unit) {
      case 'Degree': return degrees;
      case 'Radian': return degrees * 3.141592653589793 / 180;
      case 'Gradian': return degrees / 0.9;
      default: throw Exception('Invalid angle unit');
    }
  }

  // --- Density conversions ---
  double _convertDensity(double value, String fromUnit, String toUnit) {
    // Convert to kg/m³ first
    double kgm3 = _densityToKgm3(value, fromUnit);
    return _kgm3ToDensity(kgm3, toUnit);
  }

  double _densityToKgm3(double value, String unit) {
    switch (unit) {
      case 'Kilogram per Cubic Meter': return value;
      case 'Gram per Cubic Centimeter': return value * 1000;
      case 'Pound per Cubic Foot': return value * 16.0185;
      default: throw Exception('Invalid density unit');
    }
  }

  double _kgm3ToDensity(double kgm3, String unit) {
    switch (unit) {
      case 'Kilogram per Cubic Meter': return kgm3;
      case 'Gram per Cubic Centimeter': return kgm3 / 1000;
      case 'Pound per Cubic Foot': return kgm3 / 16.0185;
      default: throw Exception('Invalid density unit');
    }
  }

  // --- Energy conversions ---
  double _convertEnergy(double value, String fromUnit, String toUnit) {
    // Convert to joules first
    double joules = _energyToJoules(value, fromUnit);
    return _joulesToEnergy(joules, toUnit);
  }

  double _energyToJoules(double value, String unit) {
    switch (unit) {
      case 'Joule': return value;
      case 'Kilojoule': return value * 1000;
      case 'Calorie': return value * 4.184;
      case 'Kilocalorie': return value * 4184;
      case 'Watt Hour': return value * 3600;
      case 'Kilowatt Hour': return value * 3600000;
      default: throw Exception('Invalid energy unit');
    }
  }

  double _joulesToEnergy(double joules, String unit) {
    switch (unit) {
      case 'Joule': return joules;
      case 'Kilojoule': return joules / 1000;
      case 'Calorie': return joules / 4.184;
      case 'Kilocalorie': return joules / 4184;
      case 'Watt Hour': return joules / 3600;
      case 'Kilowatt Hour': return joules / 3600000;
      default: throw Exception('Invalid energy unit');
    }
  }
} 