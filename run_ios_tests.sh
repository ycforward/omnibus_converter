
#!/bin/bash

# This script runs Flutter integration tests on a set of representative iOS simulators.
# It boots each simulator before running tests and shuts it down afterward.

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the list of devices to test on.
DEVICES=(
  "iPhone 16 Pro Max"
  "iPhone 16 Pro"
  "iPhone 16"
  "iPhone 16e"
  "iPhone 16 Plus"
  "iPhone 15 Pro"
  "iPhone 14 Plus"
  "iPhone SE (3rd generation)"
)

# The path to the integration test file.
TEST_FILE="integration_test/app_test.dart"

# Loop through each device, boot it, run tests, and shut it down.
for device in "${DEVICES[@]}"
do
  echo "--------------------------------------------------"
  echo "Starting simulator: $device"
  echo "--------------------------------------------------"
  xcrun simctl boot "$device" > /dev/null 2>&1 || true # Boot and ignore errors if already booted
  sleep 5 # Give the simulator a moment to start up

  echo "--------------------------------------------------"
  echo "Running tests on: $device"
  echo "--------------------------------------------------"
  flutter test $TEST_FILE -d "$device"
  echo "Tests on $device completed."

  echo "--------------------------------------------------"
  echo "Shutting down simulator: $device"
  echo "--------------------------------------------------"
  xcrun simctl shutdown "$device" > /dev/null 2>&1 || true # Shutdown and ignore errors
  sleep 2 # Give a moment for shutdown to complete
done

echo "--------------------------------------------------"
echo "All tests passed on all specified devices."
