#!/bin/bash

# Automated App Store Screenshot Script (Integration Test Driven)
# Runs integration_test/screenshot_flow_test.dart, watches for markers, and takes screenshots

set -e

SCREENSHOTS_DIR="app_store_screenshots"
TEST_FILE="integration_test/screenshot_flow.dart"
ALL_DEVICES=(
    "iPad Pro 13-inch (M4)"
    "iPad Pro 11-inch (M4)"
    "iPad Air 13-inch (M3)"
    "iPad Air 11-inch (M3)"
    "iPad (A16)"
    "iPad mini (A17 Pro)"
)
SCENARIOS=(
    "home_screen"
    "currency_converter"
    "length_converter"
    "temperature_converter"
    "favorites_tab"
    "unit_selection"
    "calculator_input"
)

log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}
log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}
log_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}
log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

get_device_udid() {
    local device="$1"
    xcrun simctl list devices available | grep "$device" | head -1 | sed 's/.*(\([A-F0-9-]*\)).*/\1/'
}

main() {
    mkdir -p "$SCREENSHOTS_DIR"
    # If an argument is provided, only use that device
    if [ $# -ge 1 ]; then
        DEVICES=("$1")
    else
        DEVICES=("${ALL_DEVICES[@]}")
    fi
    for device in "${DEVICES[@]}"; do
        log_info "Processing device: $device"
        device_udid=$(get_device_udid "$device")
        if [ -z "$device_udid" ]; then
            log_warning "Device not found: $device"
            continue
        fi
        # Create a subfolder for this device
        device_folder="$SCREENSHOTS_DIR/${device// /_}"
        mkdir -p "$device_folder"
        log_info "Booting simulator $device ($device_udid)"
        xcrun simctl boot "$device_udid" 2>/dev/null || true
        sleep 5
        log_info "Running integration test for $device..."
        # Run the test in the background and capture output
        flutter test "$TEST_FILE" -d "$device" 2>&1 | tee temp_test_output.log &
        test_pid=$!
        # Take screenshots in real time as markers appear
        for scenario in "${SCENARIOS[@]}"; do
            while true; do
                if tail -n 1 temp_test_output.log | grep -- "---SCREENSHOT:$scenario---" > /dev/null; then
                    log_info "Taking screenshot for $scenario on $device..."
                    screenshot_path="$device_folder/${scenario}.png"
                    xcrun simctl io "$device_udid" screenshot "$screenshot_path"
                    if [ -f "$screenshot_path" ]; then
                        log_success "Screenshot saved: $screenshot_path"
                    else
                        log_error "Failed to save screenshot: $screenshot_path"
                    fi
                    break
                fi
                sleep 0.5
            done
        done
        wait $test_pid
        xcrun simctl shutdown "$device_udid" 2>/dev/null || true
    done
    rm -f temp_test_output.log
    log_success "All screenshots complete!"
    log_info "Screenshots saved in: $SCREENSHOTS_DIR"
}

main "$@" 