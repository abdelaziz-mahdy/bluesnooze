#!/bin/bash

# Toggle Icon Script for Bluesnooze
# This script helps test the hideIcon functionality without needing app restarts

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

APP_ID="com.oliverpeate.Bluesnooze"

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check current hideIcon setting
check_current_setting() {
    local hideIcon=$(defaults read $APP_ID hideIcon 2>/dev/null || echo "false")
    echo $hideIcon
}

# Function to show current status
show_status() {
    local current=$(check_current_setting)
    print_status "Current hideIcon setting: $current"
    
    if [ "$current" = "1" ] || [ "$current" = "true" ]; then
        print_status "Icon is currently HIDDEN"
    else
        print_status "Icon is currently VISIBLE"
    fi
}

# Function to hide icon
hide_icon() {
    print_status "Hiding the Bluesnooze icon..."
    defaults write $APP_ID hideIcon -bool true
    print_success "Icon hidden. The change should take effect immediately without restarting the app."
}

# Function to show icon
show_icon() {
    print_status "Showing the Bluesnooze icon..."
    defaults delete $APP_ID hideIcon 2>/dev/null || defaults write $APP_ID hideIcon -bool false
    print_success "Icon shown. The change should take effect immediately without restarting the app."
}

# Function to toggle icon
toggle_icon() {
    local current=$(check_current_setting)
    
    if [ "$current" = "1" ] || [ "$current" = "true" ]; then
        show_icon
    else
        hide_icon
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  hide      Hide the Bluesnooze icon"
    echo "  show      Show the Bluesnooze icon"
    echo "  toggle    Toggle the icon visibility"
    echo "  status    Show current icon status"
    echo "  help      Show this help message"
    echo ""
    echo "If no command is provided, 'toggle' will be used."
}

# Main logic
case "${1:-toggle}" in
    hide)
        hide_icon
        ;;
    show)
        show_icon
        ;;
    toggle)
        toggle_icon
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_usage
        exit 0
        ;;
    *)
        echo "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac

echo ""
show_status 