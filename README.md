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
- **Remembers Last-Used Units**: All converter types remember your last-used units and value for a seamless experience
- **Real-time conversion**: Results update as you type
- **Caching**: Exchange rates are cached for 1 hour to minimize API calls

## UI/UX Highlights

- **Modal Unit Selection**: Tap the unit name to open a modal bottom sheet for easy unit changes
- **Value Display**: Unit name appears at the top of each value box; symbol/abbreviation is shown inline and lighter before/after the value as appropriate
- **Feedback Banners**: Green popup banners provide clear feedback for actions like refreshing rates or starring favorites
- **No Overlap**: Layout is carefully designed to avoid overlap and ensure readability, even for large numbers
- **Consistent Experience**: All converter types share a unified, modern look and feel

## Architecture

- **Client-side calculations**: All unit conversions (except currency) are performed locally using mathematical formulas
- **Real-time API**: Currency conversion uses UniRateAPI for live exchange rates with fallback to mock data
- **Test-driven development**: All changes are accompanied by updated tests; code is only committed when all tests pass
- **All changes are committed only after passing all tests**

## Getting Started

1. Ensure you have Flutter installed and configured
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. (Optional) Set up UniRateAPI for real currency rates (see [API_SETUP.md](API_SETUP.md))
5. Run `flutter run` to start the app

## Testing on iOS Devices & Simulators

- **Recommended Device Coverage:**
  - iPhone SE (small screen)
  - iPhone 8/XR (older hardware, non-notch)
  - iPhone 13/14/15 (modern, notched)
  - iPhone 14/15 Pro Max (largest screens)
- **Best Practice:**
  - Use Xcode simulators to quickly test on all major screen sizes and iOS versions
  - Run Flutter integration/UI tests for core flows
  - Manually spot-check on at least one small, one large, and one recent device
- **App Store Screenshots:**
  - Use simulators to generate required screenshots for all device sizes

## iOS Release Process (Summary)

1. **Prepare for Release:**
   - Update app version/build number in `pubspec.yaml` and Xcode
   - Review app icon, launch images, and metadata
   - Remove debug/test code and sensitive data
2. **Test the Release Build:**
   - Run `flutter build ios --release`
   - Open in Xcode, run on a real device in Release mode
3. **App Store Connect:**
   - Register your app, fill in metadata, privacy, and upload screenshots
4. **Archive & Upload:**
   - In Xcode: Product > Archive > Distribute App > App Store Connect
5. **Submit for Review:**
   - Complete all required info and submit
6. **Release:**
   - Release immediately or schedule after approval

## App Store Screenshot Generation & Testing

### Automated Testing Scripts

**Integration Tests on All iPhone Models:**
```bash
# Test app functionality on all major iPhone models
bash run_ios_tests.sh
```

**Automated Screenshot Generation:**
The app uses Flutter integration tests to automatically navigate through key scenarios and capture screenshots at precise moments. This ensures consistent, high-quality App Store screenshots.

**Screenshot Generation:**
```bash
# Generate App Store screenshots with automated integration test flow
bash take_app_store_screenshots_flow.sh

# Generate screenshots for a specific device
bash take_app_store_screenshots_flow.sh "iPhone 16 Pro Max"
```

### Device & iOS Version Strategy

**Device Compatibility:**
- **Primary**: iPhone 16 Pro Max (for App Store screenshots)
- **Testing**: All major iPhone models (SE to Pro Max)
- **Target**: iOS 16.0+ for maximum user reach

**iOS Version Testing:**
- **Primary**: iOS 18.x (latest features)
- **Compatibility**: iOS 17.x (90% of users)
- **Minimum**: iOS 16.x (95% of users)

### Screenshot Requirements

**Required Screenshots (Minimum 3):**
1. Home screen (app overview)
2. Active conversion (currency/length/temperature)
3. Key feature (unit selection, calculator, favorites)

**Recommended Additional:**
- Unit selection modal
- Calculator input interface
- Favorites tab
- Different converter types

### Best Practices

- **Use iPhone 16 Pro Max screenshots** for main App Store listing
- **Test on iOS 17+** for broad compatibility
- **Generate screenshots using simulators** (no device frames)
- **Show actual app content**, not placeholder text
- **Include multiple converter types** to demonstrate value

For detailed guidance, see [APP_STORE_GUIDE.md](APP_STORE_GUIDE.md).

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
- All converter types remember last-used units and value for user convenience
- All changes are committed only after passing all tests
