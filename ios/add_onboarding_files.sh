#!/bin/bash

# Script to add onboarding files to Xcode project
# Run this script from the ios directory

echo "Adding onboarding files to Xcode project..."

PROJECT_DIR="/Users/bizhan/Documents/aitucup/ios"
PROJECT_FILE="$PROJECT_DIR/MuscleUp.xcodeproj/project.pbxproj"

# Check if project exists
if [ ! -f "$PROJECT_FILE" ]; then
    echo "Error: Project file not found at $PROJECT_FILE"
    exit 1
fi

echo "Opening Xcode project..."
open "$PROJECT_DIR/MuscleUp.xcodeproj"

echo ""
echo "============================================"
echo "MANUAL STEPS REQUIRED IN XCODE:"
echo "============================================"
echo ""
echo "1. In Xcode Project Navigator (left sidebar):"
echo "   - Right-click on 'MuscleUp' folder"
echo "   - Select 'Add Files to MuscleUp...'"
echo ""
echo "2. Navigate to and add these directories:"
echo "   📁 Models/"
echo "      - OnboardingData.swift"
echo ""
echo "   📁 DesignSystem/"
echo "      - MuscleUpDesign.swift"
echo ""
echo "   📁 Views/Onboarding/"
echo "      - WelcomeScreen.swift"
echo "      - GoalSelectionScreen.swift"
echo "      - FitnessLevelScreen.swift"
echo "      - UserParametersScreen.swift"
echo "      - HowItWorksScreen.swift"
echo "      - PlanGenerationScreen.swift"
echo "      - PlanReadyScreen.swift"
echo "      - OnboardingContainerView.swift"
echo ""
echo "3. When adding files, make sure to:"
echo "   ✅ Check 'Copy items if needed'"
echo "   ✅ Select 'MuscleUp' target"
echo "   ✅ Select 'Create groups'"
echo ""
echo "4. Build the project (Cmd + B)"
echo ""
echo "============================================"
echo ""
echo "Files are located at:"
echo "$PROJECT_DIR/MuscleUp/"
echo ""
echo "Press Enter when you've added all files to continue..."
read

echo "Testing build..."
cd "$PROJECT_DIR"
xcodebuild -project MuscleUp.xcodeproj -scheme MuscleUp -destination 'platform=iOS Simulator,name=iPhone 15' clean build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "You can now run the app and see the onboarding flow."
    echo "To test onboarding again, delete and reinstall the app."
else
    echo ""
    echo "⚠️  Build failed. Please check Xcode for errors."
    echo ""
    echo "Common issues:"
    echo "- Make sure all .swift files are added to the MuscleUp target"
    echo "- Check that there are no duplicate files"
    echo "- Verify all files are in the correct groups"
fi
