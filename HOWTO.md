# Omnibus Converter - Development Guide

This guide covers common operations for developing, testing, and releasing the Omnibus Converter app.

## 📱 App Store Screenshots

### Taking Screenshots for App Store

```bash
# Run the screenshot automation script
./app_store_screenshots/take_app_store_screenshots_flow.sh
```

**What it does:**
- Takes screenshots on all required iPhone and iPad simulators
- Saves screenshots to `app_store_screenshots/` directory
- Includes latest device models (iPhone 16 Pro Max, iPad Pro 13-inch M4, etc.)

**Prerequisites:**
- Xcode installed with iOS simulators
- Flutter app running in simulator
- ImageMagick installed (`brew install imagemagick`)

**Visual Guide:**
1. Open iOS Simulator
2. Run your Flutter app: `flutter run`
3. Navigate to key screens (Home, Converter, Settings)
4. Run the screenshot script
5. Upload screenshots to App Store Connect

## 🎨 App Icon Generation

### Generating App Icons from Custom Design

```bash
# Generate all app icons from your custom app_icon.png
./create_conversion_icon.sh
```

**What it does:**
- Creates 1024x1024 App Store icon with solid background (no transparency)
- Generates all iOS icon sizes (20x20 to 1024x1024)
- Creates Android icon sizes (48x48 to 192x192)
- Preserves transparency for device icons
- Updates support website icon

**Icon Strategy:**
- **App Store (1024x1024)**: Solid white background, RGB format
- **Device icons**: Preserve transparency from original design
- **Android icons**: All sizes with transparency

**Prerequisites:**
- `app_icon.png` in project root (your custom design)
- ImageMagick installed (`brew install imagemagick`)

**Visual Guide:**
1. Place your `app_icon.png` in project root
2. Run the icon generation script
3. Verify icons are created in correct locations:
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Android: `android/app/src/main/res/mipmap-*/`
   - Website: `support_website/app-icon.png`

## 🌐 Support Website Deployment

### Manual Deployment to Netlify

```bash
# Deploy support website to Netlify
./deploy-netlify.sh
```

**What it does:**
- Deploys `support_website/` folder to Netlify
- Uses existing site ID for non-interactive deployment
- Updates live website at `omnibus-converter.netlify.app`

**Prerequisites:**
- Netlify CLI installed (`npm install -g netlify-cli`)
- Logged in to Netlify (`netlify login`)

### Automated Deployment (GitHub Actions)

The website automatically deploys when changes are pushed to:
- `support_website/**` files
- `.github/workflows/**` files

**Setup required:**
1. Add `NETLIFY_AUTH_TOKEN` to GitHub repository secrets
2. Add `NETLIFY_SITE_ID` to GitHub repository secrets

**Visual Guide:**
1. Make changes to `support_website/` files
2. Commit and push to GitHub
3. Check GitHub Actions tab for deployment status
4. Verify changes at `omnibus-converter.netlify.app`

## 🧪 Running Tests

### Local Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

### Automated Testing (GitHub Actions)

Tests run automatically on:
- Push to `main` or `master` branch
- Pull requests to `main` or `master` branch

**What's tested:**
- Code analysis (`flutter analyze`)
- Unit tests (`flutter test`)
- Integration tests (`flutter test integration_test/`)
- iOS build simulation
- Android build simulation

## 📦 App Store Release

### Building for App Store

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build ios --release
```

### Uploading to App Store Connect

**Option 1: Xcode Organizer (Recommended)**
1. Open Xcode → Window → Organizer
2. Select your archive
3. Click "Distribute App"
4. Choose "App Store Connect" → "Upload"

**Option 2: Command Line**
```bash
cd ios
xcodebuild -exportArchive -archivePath Runner.xcarchive -exportOptionsPlist exportOptions.plist -exportPath ./build
```

### Version Management

```bash
# Update version in pubspec.yaml
version: 1.0.1+2  # Format: version+build_number

# Commit version changes
git add pubspec.yaml
git commit -m "Bump version to 1.0.1+2"
```

**Visual Guide:**
1. Update version in `pubspec.yaml`
2. Clean and rebuild app
3. Archive in Xcode (Product → Archive)
4. Upload via Organizer
5. Submit for review in App Store Connect

## 🔧 Development Setup

### Prerequisites

```bash
# Install Flutter
brew install flutter

# Install Xcode (for iOS development)
# Download from App Store

# Install ImageMagick (for icon generation)
brew install imagemagick

# Install Netlify CLI (for website deployment)
npm install -g netlify-cli
```

### Project Structure

```
converter_app/
├── lib/                    # Flutter app source code
├── ios/                    # iOS-specific files
├── android/                # Android-specific files
├── support_website/        # Support website files
├── app_store_screenshots/  # Screenshot automation
├── create_conversion_icon.sh  # Icon generation script
├── deploy-netlify.sh      # Website deployment script
└── .github/workflows/     # GitHub Actions
```

### Common Commands

```bash
# Development
flutter run                 # Run app in debug mode
flutter run --release       # Run app in release mode
flutter doctor              # Check Flutter installation

# Testing
flutter test               # Run all tests
flutter analyze            # Analyze code

# Building
flutter build ios          # Build iOS app
flutter build apk          # Build Android app
flutter build web          # Build web app

# Deployment
./deploy-netlify.sh       # Deploy website
./create_conversion_icon.sh  # Generate icons
```

## 🚨 Troubleshooting

### Git LFS Issues

If you encounter large file errors:
```bash
# Remove large files from tracking
git rm -r --cached ios/Runner.xcarchive/
git add .gitignore
git commit -m "Remove large build artifacts"
```

### Icon Generation Issues

If icons aren't generating correctly:
```bash
# Check ImageMagick installation
magick --version

# Verify source icon exists
ls -la app_icon.png

# Regenerate icons
./create_conversion_icon.sh
```

### App Store Upload Issues

If upload fails:
1. Verify 1024x1024 icon is RGB (not RGBA)
2. Check icon dimensions are exactly 1024x1024
3. Ensure no transparency in App Store icon
4. Verify all required icon sizes are present

### Website Deployment Issues

If Netlify deployment fails:
1. Check Netlify CLI is installed and logged in
2. Verify site ID is correct
3. Check GitHub Actions secrets are set
4. Review deployment logs in Netlify dashboard

## 📋 Checklist for Release

- [ ] Update version in `pubspec.yaml`
- [ ] Generate app icons: `./create_conversion_icon.sh`
- [ ] Take App Store screenshots: `./app_store_screenshots/take_app_store_screenshots_flow.sh`
- [ ] Run tests: `flutter test`
- [ ] Build release: `flutter build ios --release`
- [ ] Archive in Xcode
- [ ] Upload to App Store Connect
- [ ] Deploy website updates: `./deploy-netlify.sh`
- [ ] Submit for App Store review

## 🔗 Useful Links

- **App Store Connect**: https://appstoreconnect.apple.com
- **Support Website**: https://omnibus-converter.netlify.app
- **GitHub Repository**: https://github.com/ycforward/omnibus_converter
- **Flutter Documentation**: https://docs.flutter.dev
- **Apple Developer Guidelines**: https://developer.apple.com/design/human-interface-guidelines/app-icons 