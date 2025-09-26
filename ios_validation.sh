#!/bin/bash

# iOS Build Readiness Validation Script for Zeeky Social
# Run this script to verify iOS setup before building

echo "🔍 Validating iOS Firebase Integration for Zeeky Social..."
echo

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Run this script from the project root directory"
    exit 1
fi

# Check iOS directory exists
if [ ! -d "ios" ]; then
    echo "❌ Error: iOS directory not found"
    exit 1
fi

echo "✅ Project structure verified"

# Check Podfile
if [ -f "ios/Podfile" ]; then
    echo "✅ Podfile exists"
    if grep -q "Firebase" ios/Podfile; then
        echo "✅ Firebase dependencies found in Podfile"
    else
        echo "❌ Firebase dependencies missing from Podfile"
        exit 1
    fi
else
    echo "❌ Podfile missing"
    exit 1
fi

# Check AppDelegate.swift
if [ -f "ios/Runner/AppDelegate.swift" ]; then
    echo "✅ AppDelegate.swift exists"
    if grep -q "FirebaseApp.configure" ios/Runner/AppDelegate.swift; then
        echo "✅ Firebase initialization found in AppDelegate"
    else
        echo "❌ Firebase initialization missing from AppDelegate"
        exit 1
    fi
else
    echo "❌ AppDelegate.swift missing"
    exit 1
fi

# Check GeneratedPluginRegistrant.swift
if [ -f "ios/Runner/GeneratedPluginRegistrant.swift" ]; then
    echo "✅ GeneratedPluginRegistrant.swift exists"
    if grep -q "FLTFirebase" ios/Runner/GeneratedPluginRegistrant.swift; then
        echo "✅ Firebase plugins registered"
    else
        echo "❌ Firebase plugins not registered"
        exit 1
    fi
else
    echo "❌ GeneratedPluginRegistrant.swift missing"
    exit 1
fi

# Check Info.plist
if [ -f "ios/Runner/Info.plist" ]; then
    echo "✅ Info.plist exists"
    if grep -q "Zeeky Social" ios/Runner/Info.plist; then
        echo "✅ App name updated in Info.plist"
    else
        echo "⚠️  Warning: App name may not be updated in Info.plist"
    fi
    if grep -q "NSCameraUsageDescription" ios/Runner/Info.plist; then
        echo "✅ Camera permissions configured"
    else
        echo "⚠️  Warning: Camera permissions not configured"
    fi
else
    echo "❌ Info.plist missing"
    exit 1
fi

# Check bundle identifier in Xcode project
if grep -q "com.example.myap" ios/Runner.xcodeproj/project.pbxproj; then
    echo "✅ Bundle identifier matches Firebase configuration"
else
    echo "❌ Bundle identifier mismatch with Firebase configuration"
    exit 1
fi

# Check Firebase options
if [ -f "lib/firebase_options.dart" ]; then
    echo "✅ Firebase options exist"
    if grep -q "iosProvider.*deviceCheck" lib/main.dart; then
        echo "✅ iOS App Check provider configured"
    else
        echo "❌ iOS App Check provider not configured"
        exit 1
    fi
else
    echo "❌ Firebase options missing"
    exit 1
fi

echo
echo "🎉 iOS Firebase Integration Validation Complete!"
echo
echo "Next steps to build for iOS:"
echo "1. Install CocoaPods dependencies: cd ios && pod install"
echo "2. Open in Xcode: open ios/Runner.xcworkspace"
echo "3. Build for iOS: flutter build ios"
echo "4. Run on device/simulator: flutter run -d ios"
echo
echo "⚠️  Note: Building for iOS requires macOS with Xcode installed"