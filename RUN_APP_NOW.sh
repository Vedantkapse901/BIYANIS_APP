#!/bin/bash

# ============================================
# Student Dashboard Mobile App Runner
# ============================================

echo "════════════════════════════════════════"
echo "🚀 Starting Flutter App"
echo "════════════════════════════════════════"
echo ""

# Change to project directory
cd /Users/bhushan/Desktop/PROJECTS/LOGBOOK_APP-main

echo "📱 Step 1: Getting dependencies..."
flutter pub get
echo "✅ Dependencies updated"
echo ""

echo "🔨 Step 2: Running app..."
echo "   Note: Make sure you have:"
echo "   - Android emulator running OR"
echo "   - iOS simulator running OR"
echo "   - Physical device connected"
echo ""

flutter run

echo ""
echo "════════════════════════════════════════"
echo "✅ App Running!"
echo "════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "1. Login with student role"
echo "2. You'll see:"
echo "   - 13 ICSE 10 subjects in tabs"
echo "   - 146 chapters across subjects"
echo "   - 1,091 tasks with numbering"
echo "3. Click subjects to expand chapters"
echo "4. Click chapters to see tasks"
echo ""
echo "Enjoy! 🎓"
