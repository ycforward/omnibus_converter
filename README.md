# Unit Converter App

A modern Flutter app for converting between different units of measurement.

## Features

- **Currency Conversion**: Convert between major world currencies with real-time exchange rates from UniRateAPI
- **Length, Weight, Temperature, Volume, Area, Speed, Time**: Comprehensive support for all major unit types
- **Modern UI/UX**: Clean, Material Design 3 interface with:
  - Modal bottom sheets for unit selection
  - Value boxes with unit name at top, symbol/abbreviation inline with value
  - Popup banners for feedback (e.g., exchange rate refresh, favorites)
  - Refresh button in app bar for currency rates
  - Calculator input with smart formatting and no redundant expression box for currency
  - Large number formatting with thousand separators
- **Favorites**: Star your favorite currencies for quick access
- **Real-time conversion**: Results update as you type
- **Caching**: Exchange rates are cached for 1 hour to minimize API calls

## UI/UX Highlights

- **Modal Unit Selection**: Tap the unit name to open a modal bottom sheet for easy unit changes
- **Value Display**: Unit name appears at the top of each value box; symbol/abbreviation is shown inline and lighter before the value
- **Feedback Banners**: Green popup banners provide clear feedback for actions like refreshing rates or starring favorites
- **No Overlap**: Layout is carefully designed to avoid overlap and ensure readability, even for large numbers
- **Consistent Experience**: All converter types share a unified, modern look and feel

## Architecture

- **Client-side calculations**: All unit conversions (except currency) are performed locally using mathematical formulas
- **Real-time API**: Currency conversion uses UniRateAPI for live exchange rates with fallback to mock data
- **Test-driven development**: All changes are accompanied by updated tests; code is only committed when all tests pass

## Getting Started

1. Ensure you have Flutter installed and configured
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. (Optional) Set up UniRateAPI for real currency rates (see [API_SETUP.md](API_SETUP.md))
5. Run `flutter run` to start the app

## Future Enhancements

- More conversion types
- Unit favorites
- History of recent conversions
- Offline mode for all conversions
- Additional currency APIs support

## Development Notes

- Currency conversion uses real-time API calls with automatic fallback to mock data
- All conversion factors are based on standard international units
- The app uses Material Design 3 theming for a modern look and feel
- Exchange rates are cached for 1 hour to optimize performance
- UI/UX is iteratively improved based on user feedback and thorough testing
