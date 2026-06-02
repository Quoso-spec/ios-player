#!/bin/bash

# SaltPlayeriOS Setup Script
# Run this script on macOS to generate the Xcode project

echo "=== Salt Player iOS Setup ==="

# Check if XcodeGen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "XcodeGen is not installed."
    echo "Installing XcodeGen via Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install xcodegen
fi

# Navigate to project directory
cd "$(dirname "$0")" || exit

# Generate Xcode project
echo "Generating Xcode project..."
xcodegen generate

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Project generated successfully! ==="
    echo ""
    echo "Next steps:"
    echo "1. Open SaltPlayeriOS.xcodeproj in Xcode"
    echo "2. Select your development team in Signing & Capabilities"
    echo "3. Build and run (Cmd+R)"
    echo ""
else
    echo "Failed to generate project."
    exit 1
fi
