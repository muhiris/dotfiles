#!/bin/bash

# Script to setup OBS virtual camera and open Snapchat web
# Usage: sudo ./setup-snapchat.sh

echo "Step 1: Restarting v4l2loopback service..."
systemctl restart v4l2loopback.service

if [ $? -eq 0 ]; then
    echo "✓ v4l2loopback service restarted successfully"
else
    echo "✗ Failed to restart v4l2loopback service"
    exit 1
fi

# Wait a moment for the service to fully start
sleep 2

echo ""
echo "Step 2: Opening OBS Studio with Virtual Camera..."
# Run OBS as the actual user using su to switch to user context
su $SUDO_USER -c "flatpak run --branch=stable --arch=x86_64 --command=obs com.obsproject.Studio --startvirtualcam &"

echo ""
echo "Step 3: Opening Google Chrome with Snapchat..."
su $SUDO_USER -c "google-chrome https://snapchat.com/web &"

echo ""
echo "✓ All done!"
echo "✓ OBS is running with Virtual Camera enabled"
echo "✓ Chrome should now be opening Snapchat Web"
echo "Make sure to allow camera permissions in Chrome when prompted."
