#!/bin/bash

# Bluesnooze Build Script
# This script builds the Bluesnooze macOS application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="Bluesnooze"
SCHEME_NAME="Bluesnooze"
WORKSPACE_OR_PROJECT="Bluesnooze.xcodeproj"
BUILD_DIR="build"
ARCHIVE_DIR="$BUILD_DIR/archives"
EXPORT_DIR="$BUILD_DIR/export"

# Build configuration (can be overridden)
CONFIGURATION="${CONFIGURATION:-Release}"
CARTHAGE_PLATFORM="${CARTHAGE_PLATFORM:-Mac}"

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies with Carthage
install_dependencies() {
    print_status "Installing dependencies with Carthage..."
    
    if ! command_exists carthage; then
        print_error "Carthage is not installed. Please install it first:"
        print_error "brew install carthage"
        exit 1
    fi
    
    if [ -f "Cartfile" ]; then
        print_status "Running carthage bootstrap..."
        # Use traditional frameworks instead of xcframeworks for compatibility with older project setup
        carthage bootstrap --platform $CARTHAGE_PLATFORM --no-use-binaries
        print_success "Dependencies installed successfully"
    else
        print_warning "No Cartfile found, skipping dependency installation"
    fi
}

# Function to clean build directory
clean_build() {
    print_status "Cleaning build directory..."
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
    fi
    mkdir -p "$BUILD_DIR"
    mkdir -p "$ARCHIVE_DIR"
    mkdir -p "$EXPORT_DIR"
    print_success "Build directory cleaned"
}

# Function to run SwiftLint if available
run_linting() {
    if command_exists swiftlint; then
        print_status "Running SwiftLint..."
        swiftlint
        print_success "Linting completed"
    else
        print_warning "SwiftLint not found, skipping linting"
    fi
}

# Function to build the app
build_app() {
    print_status "Building $PROJECT_NAME with configuration: $CONFIGURATION..."
    
    # For development builds, disable code signing to avoid certificate issues
    local code_sign_args=""
    if [ "$SKIP_CODESIGN" = true ]; then
        code_sign_args="CODE_SIGN_IDENTITY=\"\" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO"
        print_warning "Code signing disabled - app will not be distributable"
    fi
    
    eval xcodebuild \
        -project "$WORKSPACE_OR_PROJECT" \
        -scheme "$SCHEME_NAME" \
        -configuration "$CONFIGURATION" \
        -archivePath "$ARCHIVE_DIR/$PROJECT_NAME.xcarchive" \
        $code_sign_args \
        archive
    
    if [ $? -eq 0 ]; then
        print_success "Build completed successfully"
    else
        print_error "Build failed"
        exit 1
    fi
}

# Function to export the app
export_app() {
    print_status "Exporting application..."
    
    # Create export options plist based on code signing status
    if [ "$SKIP_CODESIGN" = true ]; then
        cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>-</string>
</dict>
</plist>
EOF
    else
        cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF
    fi

    xcodebuild \
        -archivePath "$ARCHIVE_DIR/$PROJECT_NAME.xcarchive" \
        -exportPath "$EXPORT_DIR" \
        -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
        -exportArchive
    
    if [ $? -eq 0 ]; then
        print_success "Export completed successfully"
        print_success "Application available at: $EXPORT_DIR/$PROJECT_NAME.app"
    else
        print_error "Export failed"
        exit 1
    fi
}

# Function to open the build directory
open_build_dir() {
    if [ -d "$EXPORT_DIR" ]; then
        print_status "Opening build directory..."
        open "$EXPORT_DIR"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --clean         Clean build directory before building"
    echo "  --skip-deps         Skip dependency installation"
    echo "  --skip-lint         Skip SwiftLint"
    echo "  --skip-export       Build archive only, don't export app"
    echo "  --skip-codesign     Skip code signing (for development builds)"
    echo "  --debug             Build with Debug configuration"
    echo "  --open              Open build directory after completion"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  CONFIGURATION       Build configuration (Release|Debug)"
    echo "  CARTHAGE_PLATFORM   Carthage platform (Mac)"
    echo ""
    echo "Note: If you encounter code signing errors, use --skip-codesign for development builds."
}

# Parse command line arguments
CLEAN=false
SKIP_DEPS=false
SKIP_LINT=false
SKIP_EXPORT=false
SKIP_CODESIGN=false
OPEN_DIR=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--clean)
            CLEAN=true
            shift
            ;;
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --skip-lint)
            SKIP_LINT=true
            shift
            ;;
        --skip-export)
            SKIP_EXPORT=true
            shift
            ;;
        --skip-codesign)
            SKIP_CODESIGN=true
            shift
            ;;
        --debug)
            CONFIGURATION="Debug"
            shift
            ;;
        --open)
            OPEN_DIR=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main build process
print_status "Starting build process for $PROJECT_NAME..."
print_status "Configuration: $CONFIGURATION"

# Check if Xcode command line tools are installed
if ! command_exists xcodebuild; then
    print_error "Xcode command line tools are not installed"
    print_error "Please run: xcode-select --install"
    exit 1
fi

# Auto-detect code signing availability
if [ "$SKIP_CODESIGN" = false ]; then
    if ! security find-identity -v -p codesigning | grep -q "Mac Developer\|Apple Development"; then
        print_warning "No valid code signing certificate found"
        print_warning "Automatically enabling --skip-codesign for development build"
        SKIP_CODESIGN=true
    fi
fi

# Clean if requested
if [ "$CLEAN" = true ]; then
    clean_build
fi

# Install dependencies
if [ "$SKIP_DEPS" = false ]; then
    install_dependencies
fi

# Run linting
if [ "$SKIP_LINT" = false ]; then
    run_linting
fi

# Build the app
build_app

# Export the app
if [ "$SKIP_EXPORT" = false ]; then
    export_app
fi

# Open build directory if requested
if [ "$OPEN_DIR" = true ]; then
    open_build_dir
fi

print_success "Build process completed!"

if [ "$SKIP_EXPORT" = false ] && [ -f "$EXPORT_DIR/$PROJECT_NAME.app/Contents/MacOS/$PROJECT_NAME" ]; then
    print_success "Built application: $EXPORT_DIR/$PROJECT_NAME.app"
    print_status "You can now run: open '$EXPORT_DIR/$PROJECT_NAME.app'"
fi 