#!/bin/bash

# Simple App Store Screenshot Generator
# Uses simulator commands and manual navigation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCREENSHOTS_DIR="app_store_screenshots"

# Primary devices for App Store screenshots
PRIMARY_DEVICES=(
    "iPhone 16 Pro Max"
    "iPhone 16"
    "iPhone SE (3rd generation)"
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

# Get device UDID
get_device_udid() {
    local device="$1"
    xcrun simctl list devices available | grep "$device" | head -1 | sed 's/.*(\([^)]*\)).*/\1/'
}

# Take screenshot using simulator
take_simulator_screenshot() {
    local device_udid="$1"
    local screenshot_path="$2"
    
    xcrun simctl io "$device_udid" screenshot "$screenshot_path"
}

# Main execution
main() {
    log_info "Starting simple App Store screenshot generation..."
    
    # Create screenshots directory
    mkdir -p "$SCREENSHOTS_DIR"
    
    # Check Xcode installation
    if ! command -v xcrun &> /dev/null; then
        log_error "Xcode command line tools are not installed"
        exit 1
    fi
    
    # Check Flutter installation
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    log_info "Available simulators:"
    xcrun simctl list devices available | grep "iPhone"
    
    # Take screenshots for each device
    for device in "${PRIMARY_DEVICES[@]}"; do
        log_info "Processing device: $device"
        
        # Get device UDID
        device_udid=$(get_device_udid "$device")
        
        if [ -z "$device_udid" ]; then
            log_warning "Device not found: $device"
            continue
        fi
        
        log_info "Found device UDID: $device_udid"
        
        # Boot the simulator
        log_info "Booting simulator..."
        xcrun simctl boot "$device_udid" 2>/dev/null || true
        
        # Wait for simulator to be ready
        sleep 5
        
        # Take home screen screenshot
        log_info "Taking home screen screenshot..."
        home_screenshot="$SCREENSHOTS_DIR/${device// /_}_home_screen.png"
        take_simulator_screenshot "$device_udid" "$home_screenshot"
        
        if [ -f "$home_screenshot" ]; then
            log_success "Home screen screenshot saved: $home_screenshot"
        else
            log_error "Failed to take home screen screenshot"
        fi
        
        # Instructions for manual screenshots
        echo ""
        echo "=== MANUAL SCREENSHOT INSTRUCTIONS FOR $device ==="
        echo "1. Open the app in the simulator"
        echo "2. Navigate to each scenario and take screenshots:"
        echo "   - Currency converter (tap Currency card)"
        echo "   - Length converter (tap Length card)"
        echo "   - Temperature converter (tap Temperature card)"
        echo "   - Favorites tab (tap Favorites tab)"
        echo "   - Unit selection (tap unit selector)"
        echo "   - Calculator input (enter some numbers)"
        echo ""
        echo "3. Use Cmd+S in simulator to take screenshots"
        echo "4. Save screenshots to: $SCREENSHOTS_DIR"
        echo "5. Name them: ${device// /_}_<scenario>.png"
        echo ""
        
        # Shutdown simulator
        xcrun simctl shutdown "$device_udid" 2>/dev/null || true
    done
    
    log_success "Screenshot generation completed!"
    log_info "Screenshots saved in: $SCREENSHOTS_DIR"
    
    # Generate summary
    echo ""
    echo "=== SCREENSHOT SUMMARY ==="
    echo "Devices processed:"
    for device in "${PRIMARY_DEVICES[@]}"; do
        echo "  - $device"
    done
    echo ""
    echo "=== NEXT STEPS ==="
    echo "1. Open each simulator manually"
    echo "2. Run: flutter run -d <device_udid>"
    echo "3. Navigate to each scenario"
    echo "4. Take screenshots using Cmd+S"
    echo "5. Save with descriptive names"
    echo ""
    echo "=== RECOMMENDED SCREENSHOTS ==="
    echo "Required:"
    echo "  - home_screen.png (app overview)"
    echo "  - currency_converter.png (active conversion)"
    echo "  - unit_selection.png (unit picker)"
    echo ""
    echo "Optional:"
    echo "  - calculator_input.png (input interface)"
    echo "  - favorites_tab.png (favorites feature)"
    echo "  - length_converter.png (different converter)"
    echo "  - temperature_converter.png (different converter)"
    echo ""
    echo "=== APP STORE REQUIREMENTS ==="
    echo "- Use iPhone 16 Pro Max screenshots for main listing"
    echo "- PNG format, no device frames"
    echo "- Show actual app content, not placeholders"
    echo "- Minimum 3 screenshots required"
}

# Run main function
main "$@" 