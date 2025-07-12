import 'converter_type.dart';

class FavoriteConversion {
  final String id;
  final ConverterType converterType;
  final String fromUnit;
  final String toUnit;
  final DateTime createdAt;

  FavoriteConversion({
    required this.id,
    required this.converterType,
    required this.fromUnit,
    required this.toUnit,
    required this.createdAt,
  });

  // Factory constructor for creating from JSON
  factory FavoriteConversion.fromJson(Map<String, dynamic> json) {
    return FavoriteConversion(
      id: json['id'] as String,
      converterType: ConverterType.values.firstWhere(
        (type) => type.name == json['converterType'],
      ),
      fromUnit: json['fromUnit'] as String,
      toUnit: json['toUnit'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'converterType': converterType.name,
      'fromUnit': fromUnit,
      'toUnit': toUnit,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Generate a unique ID for a conversion pair
  static String generateId(ConverterType converterType, String fromUnit, String toUnit) {
    return '${converterType.name}_${fromUnit}_$toUnit';
  }

  // Create a new favorite conversion
  static FavoriteConversion create(ConverterType converterType, String fromUnit, String toUnit) {
    return FavoriteConversion(
      id: generateId(converterType, fromUnit, toUnit),
      converterType: converterType,
      fromUnit: fromUnit,
      toUnit: toUnit,
      createdAt: DateTime.now(),
    );
  }

  // Get display title for this conversion
  String get displayTitle {
    return '${converterType.title}: $fromUnit → $toUnit';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteConversion &&
        other.id == id &&
        other.converterType == converterType &&
        other.fromUnit == fromUnit &&
        other.toUnit == toUnit;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        converterType.hashCode ^
        fromUnit.hashCode ^
        toUnit.hashCode;
  }
} 