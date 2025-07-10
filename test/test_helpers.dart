import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:converter_app/services/exchange_rate_service.dart';
import 'package:converter_app/services/conversion_service.dart';

/// Test helper class to set up mock environment for widget tests
class TestHelpers {
  /// Initialize test environment with mock values
  static Future<void> setupTestEnvironment() async {
    // Initialize Flutter test binding first
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock SharedPreferences to avoid plugin errors in tests
    _setupSharedPreferencesMock();
    
    // Initialize dotenv if not already initialized
    if (!dotenv.isInitialized) {
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        // If .env file is not available, create a mock environment
        dotenv.env.clear();
      }
    }
    
    // Set up mock environment variables
    dotenv.env['UNIRATE_API_KEY'] = 'test_api_key';
    dotenv.env['UNIRATE_BASE_URL'] = 'https://api.unirateapi.com/api';
    
    // Clear any existing exchange rate cache
    await ExchangeRateService.clearCache();
  }

  /// Set up SharedPreferences mock for testing
  static void _setupSharedPreferencesMock() {
    // Mock data storage
    final Map<String, dynamic> mockPrefs = {};
    
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getAll':
            return mockPrefs;
          case 'setBool':
          case 'setInt':
          case 'setDouble':
          case 'setString':
          case 'setStringList':
            final String key = methodCall.arguments['key'];
            final dynamic value = methodCall.arguments['value'];
            mockPrefs[key] = value;
            return true;
          case 'remove':
            final String key = methodCall.arguments['key'];
            mockPrefs.remove(key);
            return true;
          case 'clear':
            mockPrefs.clear();
            return true;
          default:
            return null;
        }
      },
    );
  }

  /// Create a test app wrapper with proper theme and navigation
  static Widget createTestApp(Widget child) {
    return MaterialApp(
      title: 'Unit Converter Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: child,
    );
  }

  /// Create a test app with navigation support
  static Widget createTestAppWithNavigation(Widget child) {
    return MaterialApp(
      title: 'Unit Converter Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => child,
          );
        },
      ),
    );
  }

  /// Wait for async operations to complete
  static Future<void> waitForAsync(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// Tap a widget and wait for animations
  static Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await waitForAsync(tester);
  }

  /// Enter text and wait for updates
  static Future<void> enterTextAndWait(WidgetTester tester, Finder finder, String text) async {
    await tester.enterText(finder, text);
    await waitForAsync(tester);
  }

  /// Scroll to find a widget
  static Future<void> scrollToFind(WidgetTester tester, Finder finder) async {
    while (finder.evaluate().isEmpty) {
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await waitForAsync(tester);
    }
  }

  /// Check if widget is visible on screen
  static bool isWidgetVisible(Finder finder) {
    return finder.evaluate().isNotEmpty;
  }

  /// Get text from a text widget
  static String? getTextFromWidget(Finder finder) {
    final elements = finder.evaluate();
    if (elements.isEmpty) return null;
    
    final widget = elements.first.widget;
    if (widget is Text) {
      return widget.data;
    }
    return null;
  }

  /// Verify no overflow errors occurred
  static void verifyNoOverflow(WidgetTester tester) {
    final exception = tester.takeException();
    if (exception != null) {
      // Check if it's an overflow exception
      if (exception.toString().contains('RenderFlex overflowed')) {
        fail('UI overflow detected: $exception');
      }
      // Re-throw other exceptions
      throw exception;
    }
  }

  /// Mock the exchange rate service for testing
  static void mockExchangeRateService() {
    // This would be used to mock the service if needed
  }
}

/// Mock ExchangeRateService for testing
class MockExchangeRateService {
  static Map<String, double> _mockRates = {
    'USD': 1.0,
    'EUR': 0.85,
    'GBP': 0.73,
    'JPY': 110.0,
    'CAD': 1.25,
    'AUD': 1.35,
    'CHF': 0.92,
    'CNY': 6.45,
    'INR': 74.5,
    'BRL': 5.2,
  };

  static Future<Map<String, double>> getExchangeRates() async {
    return _mockRates;
  }

  static Future<double?> getExchangeRate(String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return 1.0;
    
    final fromRate = _mockRates[fromCurrency];
    final toRate = _mockRates[toCurrency];
    
    if (fromRate == null || toRate == null) {
      return null;
    }
    
    final usdValue = 1.0 / fromRate;
    return usdValue * toRate;
  }

  static bool get isUsingRealApi => false;
} 