import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'services/exchange_rate_service.dart';
import 'services/currency_preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables with comprehensive error handling
  bool envLoaded = false;
  try {
    await dotenv.load(fileName: ".env");
    print('Successfully loaded .env file');
    envLoaded = true;
  } catch (e) {
    print('Warning: Could not load .env file: $e');
    print('App will continue with mock exchange rates');
  }
  
  // Ensure dotenv is initialized even if file loading fails
  if (!dotenv.isInitialized) {
    dotenv.env.clear();
  }
  
  // Set default values to prevent any crashes
  if (!envLoaded || dotenv.env['UNIRATE_API_KEY'] == null) {
    dotenv.env['UNIRATE_API_KEY'] = 'mock_key';
  }
  if (!envLoaded || dotenv.env['UNIRATE_BASE_URL'] == null) {
    dotenv.env['UNIRATE_BASE_URL'] = 'https://api.unirateapi.com/api';
  }
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize currency preferences and preload exchange rates in background
  print('Initializing currency preferences...');
  CurrencyPreferencesService.initialize().then((_) {
    print('Currency preferences initialized');
  }).catchError((error) {
    print('Currency preferences initialization failed: $error');
  });
  
  print('Starting exchange rate preload...');
  ExchangeRateService.preloadExchangeRates().then((_) {
    print('Exchange rate preload completed');
  }).catchError((error) {
    print('Exchange rate preload failed: $error');
  });
  
  runApp(const ConverterApp());
}

class ConverterApp extends StatelessWidget {
  const ConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
