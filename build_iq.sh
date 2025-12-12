#!/bin/bash
set -e

# Use SDK 8.3.0 (tested and working)
SDK_PATH="/home/ciq/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-8.3.0-2025-09-22-5813687a0"
if [ ! -d "$SDK_PATH" ]; then
    echo "ERROR: SDK 8.3.0 not found at $SDK_PATH"
    echo "Trying SDK 8.4.0 as fallback..."
    SDK_PATH="/home/ciq/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-8.4.0-2025-12-03-5122605dc"
    if [ ! -d "$SDK_PATH" ]; then
        echo "ERROR: No SDK found!"
        exit 1
    fi
fi

# Update the 'current' symlink
ln -sfn "$SDK_PATH" /home/ciq/.Garmin/ConnectIQ/Sdks/current

# Set environment variables
export PATH="/home/ciq/.Garmin/ConnectIQ/Sdks/current/bin:$PATH"
export MB_HOME="/home/ciq/.Garmin/ConnectIQ"

# Verify SDK version
echo "Using SDK version: $(monkeyc --version)"

# Clean old build artifacts
rm -f bin/YourProject.iq 2>/dev/null || true

# Build the IQ package
echo "Building IQ package..."
monkeyc -e -w -r \
  -o bin/YourProject.iq \
  -y /home/ciq/.Garmin/ConnectIQ/developer.der \
  -f monkey.jungle

if [ -f bin/YourProject.iq ]; then
    echo ""
    echo "✅ BUILD SUCCESSFUL!"
    ls -lh bin/YourProject.iq
    echo ""
    echo "You can now upload bin/YourProject.iq to the Garmin Connect IQ Store!"
else
    echo "❌ BUILD FAILED!"
    exit 1
fi
