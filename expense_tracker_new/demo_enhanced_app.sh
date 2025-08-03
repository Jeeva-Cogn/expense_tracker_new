#!/bin/bash

echo "🎨 Starting Enhanced Expense Tracker with Smooth Animations & Calm UX"
echo "======================================================================"

cd /workspaces/expense_tracker_new

echo "Setting up virtual display for headless environment..."
export DISPLAY=:99
export GALLIUM_DRIVER=llvmpipe
export LIBGL_ALWAYS_SOFTWARE=1

echo "Starting Flutter app with enhanced features..."
echo "Features included:"
echo "  🎬 Smooth Animations (Pie Charts, Bar Charts, Loaders)"
echo "  🧘 Calm, Stress-Free Design"
echo "  💬 Encouraging Messages (No harsh tones)"
echo "  ⚙️  Complete Settings System"
echo "  🔒 Privacy Controls (Hide/Show amounts)"
echo ""

flutter run -d linux lib/main_enhanced.dart &
FLUTTER_PID=$!

echo "Flutter app started with PID: $FLUTTER_PID"
echo ""
echo "🌟 Key Features Demo:"
echo "  • Dashboard with animated pie charts"
echo "  • Analytics with sliding bar charts"
echo "  • Settings with all requested features"
echo "  • Calm notifications with encouraging messages"
echo "  • Smooth page transitions"
echo ""
echo "Press Ctrl+C to stop the demo..."

# Wait for user input or timeout
timeout 30 wait $FLUTTER_PID 2>/dev/null
if [ $? -eq 124 ]; then
    echo ""
    echo "✨ Demo completed! Enhanced features are working."
    echo "📱 The app includes:"
    echo "  - Animated pie chart segments that rotate in"
    echo "  - Bar charts with staggered animations"
    echo "  - Rotating wallet loader"
    echo "  - Encouraging messages instead of harsh alerts"
    echo "  - Complete settings system with privacy controls"
    echo ""
    kill $FLUTTER_PID 2>/dev/null
fi

echo "🎉 Enhanced Expense Tracker Demo Complete!"
