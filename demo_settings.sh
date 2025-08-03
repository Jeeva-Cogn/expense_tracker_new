#!/bin/bash

# 🔧 Settings Demo Script
# Showcases the comprehensive Settings Section with all requested features

set -e  # Exit on any error

echo "🔧 Settings Demo Starting..."
echo "==============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
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

print_feature() {
    echo -e "${PURPLE}[FEATURE]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the Flutter project root."
    exit 1
fi

print_status "Checking Flutter installation..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_warning "Flutter not found. Installing Flutter..."
    
    # Install Flutter
    cd ~
    git clone https://github.com/flutter/flutter.git -b stable
    echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    export PATH="$HOME/flutter/bin:$PATH"
    
    print_success "Flutter installed successfully!"
else
    print_success "Flutter is already installed"
fi

print_status "Installing Flutter dependencies..."
flutter pub get

# Check if we're in a headless environment (no DISPLAY)
if [ -z "$DISPLAY" ]; then
    print_warning "No display detected. Setting up virtual display..."
    
    # Start Xvfb (X Virtual Framebuffer)
    export DISPLAY=:99
    Xvfb :99 -screen 0 1024x768x24 &
    XVFB_PID=$!
    
    # Wait a moment for Xvfb to start
    sleep 2
    
    print_success "Virtual display created on :99"
    
    # Function to cleanup on exit
    cleanup() {
        print_status "Cleaning up virtual display..."
        kill $XVFB_PID 2>/dev/null || true
    }
    trap cleanup EXIT
fi

print_status "Building Flutter application for Linux..."
flutter config --enable-linux-desktop
flutter build linux --debug

print_success "Build completed successfully!"

print_status "🚀 Launching Settings Demo..."
echo ""
echo "==============================================="
echo "🔧 COMPREHENSIVE SETTINGS SECTION DEMO"
echo "==============================================="
echo ""
print_feature "✅ Monthly Budget - Set spending limits with privacy controls"
print_feature "✅ Daily Budget - Configure daily spending targets"  
print_feature "✅ Categories - Manage expense categories dynamically"
print_feature "✅ Notification Preferences - Smart budget alerts"
print_feature "✅ SMS Auto-Detection - Toggle bank transaction parsing"
print_feature "✅ Amount Privacy - Eye icon to hide/show budget amounts"
echo ""
echo "🎨 UI Features:"
echo "  • Beautiful animated interface with Material Design 3"
echo "  • Dark/Light theme switching"
echo "  • Profile management with avatar"
echo "  • Advanced settings (Biometric, Cloud Sync, Backup)"
echo "  • Category-specific notification controls"
echo "  • Budget alert threshold slider"
echo ""
echo "⚡ Demo Highlights:"
echo "  • Interactive budget setting with privacy toggle"
echo "  • Dynamic category management (add/remove chips)"
echo "  • Comprehensive notification preferences"
echo "  • Real-time settings persistence with Hive"
echo "  • Provider state management for reactive UI"
echo ""
echo "==============================================="
echo ""

# Run the Settings demo
if flutter run lib/settings_demo.dart -d linux; then
    print_success "Settings Demo completed successfully! 🎉"
else
    print_error "Settings Demo failed to run. Check the error messages above."
    exit 1
fi

print_success "🔧 Settings Demo finished!"
echo ""
echo "📊 What you experienced:"
echo "  ✅ Complete Settings Section with all requested features"
echo "  ✅ Monthly & Daily Budget configuration with privacy controls"
echo "  ✅ Dynamic category management system"
echo "  ✅ Comprehensive notification preferences"
echo "  ✅ SMS auto-detection toggle functionality"
echo "  ✅ Beautiful animated Material Design 3 interface"
echo ""
echo "🎯 All settings features are fully implemented and ready!"
