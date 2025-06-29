# Unit Converter App

A modern Flutter app for converting between different units of measurement.

## Features

- **Currency Conversion**: Convert between major world currencies (with mock rates for demo)
- **Length Conversion**: Meters, kilometers, centimeters, millimeters, miles, yards, feet, inches
- **Weight Conversion**: Kilograms, grams, pounds, ounces, tons, stones
- **Temperature Conversion**: Celsius, Fahrenheit, Kelvin
- **Volume Conversion**: Liters, milliliters, gallons, quarts, pints, cups, fluid ounces
- **Area Conversion**: Square meters, square kilometers, square miles, acres, square yards, square feet
- **Speed Conversion**: Miles per hour, kilometers per hour, meters per second, knots, feet per second
- **Time Conversion**: Seconds, minutes, hours, days, weeks, months, years

## Architecture

- **Client-side calculations**: All unit conversions (except currency) are performed locally using mathematical formulas
- **Mock API**: Currency conversion uses mock exchange rates to simulate API calls
- **Modern UI**: Material Design 3 with clean, intuitive interface
- **Real-time conversion**: Results update as you type

## Getting Started

1. Ensure you have Flutter installed and configured
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Future Enhancements

- Real currency API integration
- More conversion types
- Unit favorites
- History of recent conversions
- Offline mode for all conversions

## Development Notes

- Currency conversion simulates API delay (500ms) to demonstrate loading states
- All conversion factors are based on standard international units
- The app uses Material Design 3 theming for a modern look and feel
