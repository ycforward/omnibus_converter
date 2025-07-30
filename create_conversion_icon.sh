#!/bin/bash

echo "🎨 Creating app icons from custom app_icon.png..."

# Create output directories
mkdir -p ios_icons
mkdir -p android_icons

# Check if the source icon exists
if [ ! -f "app_icon.png" ]; then
    echo "❌ Error: app_icon.png not found in the project root!"
    exit 1
fi

echo "📱 Generating iOS icons from app_icon.png..."

# Resize the source icon to exactly 1024x1024 and remove alpha channel for App Store
magick app_icon.png -resize 1024x1024! -background white -alpha remove -alpha off ios_icons/Icon-App-1024x1024@1x.png

# Generate all iOS sizes from the source icon
magick ios_icons/Icon-App-1024x1024@1x.png -resize 20x20 ios_icons/Icon-App-20x20@1x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 40x40 ios_icons/Icon-App-20x20@2x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 60x60 ios_icons/Icon-App-20x20@3x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 29x29 ios_icons/Icon-App-29x29@1x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 58x58 ios_icons/Icon-App-29x29@2x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 87x87 ios_icons/Icon-App-29x29@3x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 40x40 ios_icons/Icon-App-40x40@1x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 80x80 ios_icons/Icon-App-40x40@2x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 120x120 ios_icons/Icon-App-40x40@3x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 120x120 ios_icons/Icon-App-60x60@2x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 180x180 ios_icons/Icon-App-60x60@3x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 76x76 ios_icons/Icon-App-76x76@1x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 152x152 ios_icons/Icon-App-76x76@2x.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 167x167 ios_icons/Icon-App-83.5x83.5@2x.png

# Android Icon Sizes
echo "🤖 Generating Android icons from app_icon.png..."
magick ios_icons/Icon-App-1024x1024@1x.png -resize 48x48 android_icons/ic_launcher-mdpi.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 72x72 android_icons/ic_launcher-hdpi.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 96x96 android_icons/ic_launcher-xhdpi.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 144x144 android_icons/ic_launcher-xxhdpi.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 192x192 android_icons/ic_launcher-xxxhdpi.png

echo "✅ All icons generated successfully from app_icon.png!"

# Move iOS icons to the correct location
echo "📱 Moving iOS icons to app location..."
cp ios_icons/* ios/Runner/Assets.xcassets/AppIcon.appiconset/

# Move Android icons to the correct locations
echo "🤖 Moving Android icons to app locations..."
cp android_icons/ic_launcher-mdpi.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png
cp android_icons/ic_launcher-hdpi.png android/app/src/main/res/mipmap-hdpi/ic_launcher.png
cp android_icons/ic_launcher-xhdpi.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
cp android_icons/ic_launcher-xxhdpi.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
cp android_icons/ic_launcher-xxxhdpi.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# Update support website icon
echo "🌐 Updating support website icon..."
cp ios_icons/Icon-App-1024x1024@1x.png support_website/app-icon.png

# Clean up temporary folders
echo "🧹 Cleaning up temporary files..."
rm -rf ios_icons android_icons

echo "🎉 Icon generation and deployment complete!"
echo "📱 iOS icons updated in: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "🤖 Android icons updated in: android/app/src/main/res/mipmap-*/"
echo "🌐 Support website icon updated in: support_website/app-icon.png" 