#!/bin/bash

# Test script for Bluesnooze icon toggle functionality

APP_ID="com.oliverpeate.Bluesnooze"

echo "🔍 Testing Bluesnooze Icon Toggle Functionality"
echo "=============================================="

# Function to check if app is running
check_app_running() {
    if pgrep -f "Bluesnooze.app" > /dev/null; then
        echo "✅ Bluesnooze is running"
        return 0
    else
        echo "❌ Bluesnooze is not running"
        return 1
    fi
}

# Function to get current setting
get_current_setting() {
    local hideIcon=$(defaults read $APP_ID hideIcon 2>/dev/null || echo "false")
    echo "Current hideIcon setting: $hideIcon"
}

# Function to toggle setting
toggle_setting() {
    local current=$(defaults read $APP_ID hideIcon 2>/dev/null || echo "false")
    
    if [ "$current" = "1" ] || [ "$current" = "true" ]; then
        echo "🔄 Setting hideIcon to false..."
        defaults write $APP_ID hideIcon -bool false
    else
        echo "🔄 Setting hideIcon to true..."
        defaults write $APP_ID hideIcon -bool true
    fi
    
    # Wait a moment for the change to be processed
    sleep 1
    get_current_setting
}

echo ""
echo "Step 1: Check if app is running"
check_app_running

echo ""
echo "Step 2: Check current setting"
get_current_setting

echo ""
echo "Step 3: Toggle the setting (this should change the icon visibility)"
echo "📝 Note: Watch the menu bar for the Bluesnooze icon to appear/disappear"
toggle_setting

echo ""
echo "Step 4: Wait 3 seconds then toggle again"
sleep 3
toggle_setting

echo ""
echo "Test completed! The icon should have toggled twice."
echo "If you didn't see any changes, there might be an issue with the implementation." 