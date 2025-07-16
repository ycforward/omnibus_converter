#!/bin/bash

# Reliable App Store Screenshot Generator
# Uses integration test framework for precise navigation and screenshots

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCREENSHOTS_DIR="app_store_screenshots"
TEMP_TEST_DIR="temp_screenshot_tests"

# Primary devices for App Store screenshots
PRIMARY_DEVICES=(
    "iPhone 16 Pro Max"
    "iPhone 16"
    "iPhone SE (3rd generation)"
)

# iOS versions to test
IOS_VERSIONS=(
    "18.0"
    "17.0"
)

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create screenshot test for a specific scenario
create_screenshot_test() {
    local scenario="$1"
    local test_file="$TEMP_TEST_DIR/screenshot_${scenario}_test.dart"
    
    cat > "$test_file" << EOF
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:converter_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Take screenshot: $scenario', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Navigate to specific scenario
    switch ('$scenario') {
      case 'home_screen':
        // App starts on home screen, no navigation needed
        break;
        
      case 'currency_converter':
        // Navigate to currency converter
        final currencyCard = find.byKey(const ValueKey('converter_card_currency'));
        await tester.ensureVisible(currencyCard);
        await tester.pumpAndSettle();
        await tester.tap(currencyCard);
        await tester.pumpAndSettle();
        break;
        
      case 'length_converter':
        // Navigate to length converter
        final lengthCard = find.byKey(const ValueKey('converter_card_length'));
        await tester.ensureVisible(lengthCard);
        await tester.pumpAndSettle();
        await tester.tap(lengthCard);
        await tester.pumpAndSettle();
        break;
        
      case 'temperature_converter':
        // Navigate to temperature converter
        final tempCard = find.byKey(const ValueKey('converter_card_temperature'));
        await tester.ensureVisible(tempCard);
        await tester.pumpAndSettle();
        await tester.tap(tempCard);
        await tester.pumpAndSettle();
        break;
        
      case 'favorites_tab':
        // Navigate to favorites tab
        final favoritesTab = find.widgetWithText(Tab, 'Favorites');
        await tester.tap(favoritesTab);
        await tester.pumpAndSettle();
        break;
        
      case 'unit_selection':
        // Navigate to currency converter and open unit selection
        final currencyCard = find.byKey(const ValueKey('converter_card_currency'));
        await tester.ensureVisible(currencyCard);
        await tester.pumpAndSettle();
        await tester.tap(currencyCard);
        await tester.pumpAndSettle();
        
        // Tap on unit selector to open modal
        final unitSelector = find.byType(InkWell).first;
        await tester.tap(unitSelector);
        await tester.pumpAndSettle();
        break;
        
      case 'calculator_input':
        // Navigate to currency converter and show calculator
        final currencyCard = find.byKey(const ValueKey('converter_card_currency'));
        await tester.ensureVisible(currencyCard);
        await tester.pumpAndSettle();
        await tester.tap(currencyCard);
        await tester.pumpAndSettle();
        
        // Enter some value to show calculator interface
        final digitButton = find.text('1');
        await tester.tap(digitButton);
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('0'));
        await tester.pumpAndSettle();
        break;
    }
    
    // Wait for UI to settle
    await tester.pumpAndSettle();
    
    // Take screenshot
    await tester.pumpAndSettle();
  });
}
EOF
}

# Take screenshot for a specific device and scenario
take_screenshot() {
    local device_name="$1"
    local ios_version="$2"
    local scenario="$3"
    
    local screenshot_path="$SCREENSHOTS_DIR/${device_name}_${ios_version}_${scenario}.png"
    local test_file="$TEMP_TEST_DIR/screenshot_${scenario}_test.dart"
    
    log_info "Taking screenshot: $scenario on $device_name (iOS $ios_version)"
    
    # Create the test file
    create_screenshot_test "$scenario"
    
    # Run the test and take screenshot
    if flutter test "$test_file" -d "$device_name" --screenshot="$screenshot_path"; then
        log_success "Screenshot saved: $screenshot_path"
    else
        log_error "Failed to take screenshot: $screenshot_path"
    fi
}

# Main execution
main() {
    log_info "Starting reliable App Store screenshot generation..."
    
    # Create directories
    mkdir -p "$SCREENSHOTS_DIR"
    mkdir -p "$TEMP_TEST_DIR"
    
    # Check Flutter installation
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Get available devices
    log_info "Available devices:"
    flutter devices
    
    # Screenshot scenarios
    SCENARIOS=(
        "home_screen"
        "currency_converter"
        "length_converter"
        "temperature_converter"
        "favorites_tab"
        "unit_selection"
        "calculator_input"
    )
    
    # Take screenshots for primary devices
    for device in "${PRIMARY_DEVICES[@]}"; do
        log_info "Processing device: $device"
        
        for scenario in "${SCENARIOS[@]}"; do
            take_screenshot "$device" "18.0" "$scenario"
        done
    done
    
    # Clean up
    rm -rf "$TEMP_TEST_DIR"
    
    log_success "Screenshot generation completed!"
    log_info "Screenshots saved in: $SCREENSHOTS_DIR"
    
    # Generate summary
    echo ""
    echo "=== SCREENSHOT SUMMARY ==="
    echo "Devices tested:"
    for device in "${PRIMARY_DEVICES[@]}"; do
        echo "  - $device"
    done
    echo ""
    echo "Scenarios captured:"
    for scenario in "${SCENARIOS[@]}"; do
        echo "  - $scenario"
    done
    echo ""
    echo "=== APP STORE SUBMISSION TIPS ==="
    echo "1. Use iPhone 16 Pro Max screenshots for main App Store listing"
    echo "2. Required screenshots:"
    echo "   - home_screen (shows app overview)"
    echo "   - currency_converter (shows active conversion)"
    echo "   - unit_selection (shows unit picker)"
    echo "3. Optional but recommended:"
    echo "   - calculator_input (shows input interface)"
    echo "   - favorites_tab (shows favorites feature)"
    echo "4. Screenshot requirements:"
    echo "   - PNG format"
    echo "   - No device frames (use simulator screenshots)"
    echo "   - No status bar text (use clean simulator)"
    echo "   - Show actual app content, not placeholder text"
}

# Run main function
main "$@" 