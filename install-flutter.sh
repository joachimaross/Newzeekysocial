#!/bin/bash
set -e

echo "🚀 Installing Flutter SDK..."

# Download Flutter stable branch
git clone https://github.com/flutter/flutter.git --depth 1 -b stable

# Add Flutter to PATH for this build
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter --version
flutter doctor

echo "✅ Flutter is ready!"