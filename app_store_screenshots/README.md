# App Store Screenshot Automation

This folder contains the automated screenshot script and the generated screenshots for App Store submission.

## How It Works

- The script `take_app_store_screenshots_flow.sh` runs a special Flutter integration test (`integration_test/screenshot_flow.dart`) that navigates through key app scenarios and prints markers at each screenshot point.
- The script watches for these markers in real time and takes a screenshot of the simulator as soon as each marker appears.
- Screenshots are saved in subfolders by device model (e.g., `iPhone_16_Pro_Max/`).

## Usage

From the project root, run:

```bash
bash app_store_screenshots/take_app_store_screenshots_flow.sh
```

To generate screenshots for a specific device:

```bash
bash app_store_screenshots/take_app_store_screenshots_flow.sh "iPhone 16 Pro Max"
```

## Requirements
- Xcode and iOS simulators installed
- Flutter environment set up
- The integration test file must be present at `integration_test/screenshot_flow.dart`

## What Gets Captured
- Home screen
- Currency converter
- Length converter
- Temperature converter
- Favorites tab (with a favorited conversion)
- Unit selection modal
- Calculator input

## Tips
- You can add or remove devices by editing the `ALL_DEVICES` array in the script.
- The script waits for each scenario to be ready before taking a screenshot, ensuring accurate captures.
- Screenshots are device-native resolution and suitable for App Store submission.

## Troubleshooting
- If screenshots are all of the home screen, make sure the script is running the test in the background and watching the log in real time (this is already handled in the current script).
- If you add new scenarios, update the `SCENARIOS` array in the script and the integration test markers. 