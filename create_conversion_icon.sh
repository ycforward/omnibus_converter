#!/bin/bash

echo "🎨 Creating conversion-themed app icon with light purple and white..."

# Create output directories
mkdir -p ios_icons
mkdir -p android_icons

# Create a conversion-themed icon with light purple background and white elements
echo "📱 Generating iOS icons..."

# 1024x1024 base icon with conversion design
magick -size 1024x1024 xc:'#f3f4f6' \
  -fill '#8b5cf6' -draw "rectangle 0,0 1024,1024" \
  -fill white -draw "rectangle 200,200 824,824" \
  -fill '#8b5cf6' -draw "rectangle 220,220 804,804" \
  -fill white -draw "rectangle 240,240 784,784" \
  -fill '#8b5cf6' -draw "polygon 300,300 400,300 400,400 300,400" \
  -fill '#8b5cf6' -draw "circle 600,350 600,300" \
  -fill white -stroke '#8b5cf6' -strokewidth 8 -draw "line 450,350 550,350" \
  -fill '#8b5cf6' -draw "polygon 540,340 550,350 540,360" \
  -fill '#8b5cf6' -draw "polygon 460,340 450,350 460,360" \
  -fill white -stroke '#8b5cf6' -strokewidth 8 -draw "line 450,450 550,450" \
  -fill '#8b5cf6' -draw "polygon 540,440 550,450 540,460" \
  -fill '#8b5cf6' -draw "polygon 460,440 450,450 460,460" \
  -fill '#8b5cf6' -pointsize 48 -gravity center -annotate +0+200 "CONVERT" \
  -fill '#8b5cf6' -pointsize 24 -gravity center -annotate +0+280 "Length • Area • Volume • Weight • Temperature • Currency" \
  ios_icons/Icon-App-1024x1024@1x.png

# Generate all iOS sizes
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
echo "🤖 Generating Android icons..."
magick ios_icons/Icon-App-1024x1024@1x.png -resize 48x48 android_icons/ic_launcher-mdpi.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 72x72 android_icons/ic_launcher-hdpi.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 96x96 android_icons/ic_launcher-xhdpi.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 144x144 android_icons/ic_launcher-xxhdpi.png
magick ios_icons/Icon-App-1024x1024@1x.png -resize 192x192 android_icons/ic_launcher-xxxhdpi.png

echo "✅ All conversion-themed icons generated successfully!"
echo "📁 iOS icons saved in: ios_icons/"
echo "📁 Android icons saved in: android_icons/" 