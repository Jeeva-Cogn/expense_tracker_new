#!/bin/bash

# 🤖 AI Analysis Demo Script
# Automated setup and launch for the AI Analysis and Savings Advice feature
# Handles headless environment by creating virtual display

set -e  # Exit on any error

echo "🤖 AI Analysis Demo Setup Starting..."
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Check Flutter doctor
print_status "Running Flutter doctor..."
flutter doctor

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

print_status "🚀 Launching AI Analysis Demo..."
echo ""
echo "==============================================="
echo "🤖 AI ANALYSIS & SAVINGS ADVICE DEMO"
echo "==============================================="
echo "✨ Features to explore:"
echo "  • Smart expense pattern analysis"
echo "  • Personalized savings advice"  
echo "  • Achievement recognition system"
echo "  • IST (Indian Standard Time) timestamping"
echo "  • Beautiful animated interface"
echo ""
echo "📱 Demo Options:"
echo "  • Quick Demo: Basic expense data"
echo "  • Rich Demo: Comprehensive spending patterns"
echo ""
echo "⏱️ All timestamps shown in Asia/Kolkata timezone"
echo "==============================================="
echo ""

# Run the AI Analysis demo
if flutter run lib/ai_analysis_complete.dart -d linux; then
    print_success "Demo completed successfully! 🎉"
else
    print_error "Demo failed to run. Check the error messages above."
    exit 1
fi

print_success "🤖 AI Analysis Demo finished!"
echo ""
echo "📊 What you experienced:"
echo "  ✅ Intelligent expense analysis with IST timestamps"
echo "  ✅ Personalized savings suggestions"
echo "  ✅ Achievement recognition and motivation"
echo "  ✅ Beautiful animated user interface"
echo ""
echo "🎯 Ready for integration into your main app!"
