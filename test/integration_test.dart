import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('Integration Tests', () {
    test('should have .env file with API configuration', () {
      final envFile = File('.env');
      expect(envFile.existsSync(), isTrue);
      
      final content = envFile.readAsStringSync();
      expect(content, contains('UNIRATE_API_KEY'));
      expect(content, contains('UNIRATE_BASE_URL'));
    });

    test('should have API_SETUP.md documentation', () {
      final setupFile = File('API_SETUP.md');
      expect(setupFile.existsSync(), isTrue);
      
      final content = setupFile.readAsStringSync();
      expect(content, contains('UniRateAPI'));
      expect(content, contains('Setup Instructions'));
    });

    test('should have updated pubspec.yaml with required dependencies', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);
      
      final content = pubspecFile.readAsStringSync();
      expect(content, contains('http: ^1.1.0'));
      expect(content, contains('flutter_dotenv: ^5.1.0'));
    });

    test('should have ExchangeRateService implementation', () {
      final serviceFile = File('lib/services/exchange_rate_service.dart');
      expect(serviceFile.existsSync(), isTrue);
      
      final content = serviceFile.readAsStringSync();
      expect(content, contains('class ExchangeRateService'));
      expect(content, contains('getExchangeRates'));
      expect(content, contains('getExchangeRate'));
    });

    test('should have updated ConversionService with async support', () {
      final serviceFile = File('lib/services/conversion_service.dart');
      expect(serviceFile.existsSync(), isTrue);
      
      final content = serviceFile.readAsStringSync();
      expect(content, contains('Future<double> convert'));
      expect(content, contains('ExchangeRateService'));
    });

    test('should have updated main.dart with dotenv initialization', () {
      final mainFile = File('lib/main.dart');
      expect(mainFile.existsSync(), isTrue);
      
      final content = mainFile.readAsStringSync();
      expect(content, contains('flutter_dotenv'));
      expect(content, contains('dotenv.load'));
    });

    test('should have updated converter screen with API status', () {
      final screenFile = File('lib/screens/converter_screen.dart');
      expect(screenFile.existsSync(), isTrue);
      
      final content = screenFile.readAsStringSync();
      expect(content, contains('ExchangeRateService'));
      expect(content, contains('isUsingRealApi'));
    });
  });
} 