#!/bin/bash

# App Store Screenshot Generator
# This script takes screenshots for App Store submission on different iPhone models
# Following Apple's best practices for universal screenshots

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCREENSHOTS_DIR="app_store_screenshots"
SCREENSHOT_DELAY=3  # Seconds to wait for UI to settle

# Primary devices for App Store screenshots (most common/popular)
# These will be used for the main App Store listing
PRIMARY_DEVICES=(
    "iPhone 16 Pro Max"  # Largest screen, shows full UI
    "iPhone 16"          # Standard size, most common
    "iPhone SE (3rd generation)"  # Smallest screen, shows compact UI
)

# Secondary devices for additional testing (optional)
SECONDARY_DEVICES=(
    "iPhone 16 Pro"
    "iPhone 16 Plus"
    "iPhone 15 Pro"
)

# iOS versions to test (recommended: latest + previous major)
IOS_VERSIONS=(
    "18.0"  # Latest iOS
    "17.0"  # Previous major version
)

# Screenshot scenarios to capture
SCENARIOS=(
    "home_screen"
    "currency_converter"
    "length_converter"
    "temperature_converter"
    "favorites_tab"
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

# Check if device is available
check_device() {
    local device="$1"
    local ios_version="$2"
    
    if xcrun simctl list devices available | grep -q "$device.*$ios_version"; then
        return 0
    else
        return 1
    fi
}

# Get device UDID
get_device_udid() {
    local device="$1"
    local ios_version="$2"
    
    xcrun simctl list devices available | grep "$device.*$ios_version" | head -1 | sed 's/.*(\([^)]*\)).*/\1/'
}

# Take screenshot for a specific scenario
take_scenario_screenshot() {
    local device_name="$1"
    local ios_version="$2"
    local scenario="$3"
    local device_udid="$4"
    
    local screenshot_path="$SCREENSHOTS_DIR/${device_name}_${ios_version}_${scenario}.png"
    
    log_info "Taking screenshot: $scenario on $device_name (iOS $ios_version)"
    
    # Start the app
    flutter run -d "$device_udid" --release &
    local app_pid=$!
    
    # Wait for app to start
    sleep 5
    
    # Navigate to the specific scenario
    case "$scenario" in
        "home_screen")
            # App starts on home screen, no navigation needed
            ;;
        "currency_converter")
            # Navigate to currency converter
            xcrun simctl spawn "$device_udid" xcrun simctl send_input "$device_udid" "tap 200 300"  # Approximate tap on currency card
            sleep 2
            ;;
        "length_converter")
            # Navigate to length converter
            xcrun simctl spawn "$device_udid" xcrun simctl send_input "$device_udid" "tap 200 400"  # Approximate tap on length card
            sleep 2
            ;;
        "temperature_converter")
            # Navigate to temperature converter
            xcrun simctl spawn "$device_udid" xcrun simctl send_input "$device_udid" "tap 200 500"  # Approximate tap on temperature card
            sleep 2
            ;;
        "favorites_tab")
            # Navigate to favorites tab
            xcrun simctl spawn "$device_udid" xcrun simctl send_input "$device_udid" "tap 300 50"  # Approximate tap on favorites tab
            sleep 2
            ;;
    esac
    
    # Wait for UI to settle
    sleep $SCREENSHOT_DELAY
    
    # Take screenshot
    xcrun simctl io "$device_udid" screenshot "$screenshot_path"
    
    # Stop the app
    kill $app_pid 2>/dev/null || true
    sleep 2
    
    if [ -f "$screenshot_path" ]; then
        log_success "Screenshot saved: $screenshot_path"
    else
        log_error "Failed to take screenshot: $screenshot_path"
    fi
}

# Main execution
main() {
    log_info "Starting App Store screenshot generation..."
    
    # Create screenshots directory
    mkdir -p "$SCREENSHOTS_DIR"
    
    # Check Flutter installation
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check Xcode installation
    if ! command -v xcrun &> /dev/null; then
        log_error "Xcode command line tools are not installed"
        exit 1
    fi
    
    log_info "Taking screenshots for primary devices (App Store submission)..."
    
    # Take screenshots for primary devices
    for device in "${PRIMARY_DEVICES[@]}"; do
        for ios_version in "${IOS_VERSIONS[@]}"; do
            if check_device "$device" "$ios_version"; then
                device_udid=$(get_device_udid "$device" "$ios_version")
                log_info "Found device: $device (iOS $ios_version) - UDID: $device_udid"
                
                for scenario in "${SCENARIOS[@]}"; do
                    take_scenario_screenshot "$device" "$ios_version" "$scenario" "$device_udid"
                done
            else
                log_warning "Device not available: $device (iOS $ios_version)"
            fi
        done
    done
    
    log_info "Taking screenshots for secondary devices (additional testing)..."
    
    # Take screenshots for secondary devices (optional)
    for device in "${SECONDARY_DEVICES[@]}"; do
        for ios_version in "${IOS_VERSIONS[@]}"; do
            if check_device "$device" "$ios_version"; then
                device_udid=$(get_device_udid "$device" "$ios_version")
                log_info "Found device: $device (iOS $ios_version) - UDID: $device_udid"
                
                # Only take home screen screenshot for secondary devices
                take_scenario_screenshot "$device" "$ios_version" "home_screen" "$device_udid"
            else
                log_warning "Device not available: $device (iOS $ios_version)"
            fi
        done
    done
    
    log_success "Screenshot generation completed!"
    log_info "Screenshots saved in: $SCREENSHOTS_DIR"
    
    # Generate summary report
    echo ""
    echo "=== SCREENSHOT SUMMARY ==="
    echo "Primary devices (App Store):"
    for device in "${PRIMARY_DEVICES[@]}"; do
        echo "  - $device"
    done
    echo ""
    echo "Secondary devices (testing):"
    for device in "${SECONDARY_DEVICES[@]}"; do
        echo "  - $device"
    done
    echo ""
    echo "iOS versions tested:"
    for version in "${IOS_VERSIONS[@]}"; do
        echo "  - iOS $version"
    done
    echo ""
    echo "Scenarios captured:"
    for scenario in "${SCENARIOS[@]}"; do
        echo "  - $scenario"
    done
    echo ""
    echo "=== APP STORE RECOMMENDATIONS ==="
    echo "1. Use iPhone 16 Pro Max screenshots for App Store listing"
    echo "2. Test on iOS 17+ for broad compatibility"
    echo "3. Include screenshots showing:"
    echo "   - Home screen with converter grid"
    echo "   - Active conversion (e.g., currency)"
    echo "   - Favorites functionality"
    echo "4. Consider adding screenshots for:"
    echo "   - Unit selection modal"
    echo "   - Calculator input interface"
    echo "   - Settings/preferences (if any)"
}

# Run main function
main "$@" 