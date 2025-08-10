#!/bin/bash

echo "======================================================================"
echo "WeatherPants Project Diagnostic Tool"
echo "======================================================================"
echo

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check function
check_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        echo "  Fix: $3"
    fi
}

# 1. Check if we're in the right directory
echo "1. Checking project structure..."
if [ -f "app/build.gradle" ] && [ -f "settings.gradle" ]; then
    check_status 0 "Project structure looks correct"
else
    check_status 1 "Not in project root directory" "Run this script from the project root"
    exit 1
fi

# 2. Check AndroidManifest.xml
echo
echo "2. Checking AndroidManifest.xml..."
if [ -f "app/src/main/AndroidManifest.xml" ]; then
    if grep -q 'package=' "app/src/main/AndroidManifest.xml"; then
        check_status 1 "AndroidManifest.xml has deprecated package attribute" "Remove package attribute from manifest"
        echo -e "${YELLOW}  This is a critical issue that will cause build failure${NC}"
    else
        check_status 0 "AndroidManifest.xml is correct (no package attribute)"
    fi
else
    check_status 1 "AndroidManifest.xml not found" "Create the manifest file"
fi

# 3. Check MainActivity location
echo
echo "3. Checking MainActivity.kt location..."
if [ -f "app/src/main/java/com/example/weatherpants/MainActivity.kt" ]; then
    check_status 0 "MainActivity.kt is in correct location"
    
    # Check if it has weather functionality
    if grep -q "fetchWeatherData" "app/src/main/java/com/example/weatherpants/MainActivity.kt"; then
        check_status 0 "MainActivity has weather functionality"
    else
        check_status 1 "MainActivity lacks weather functionality" "Update MainActivity with weather API calls"
    fi
elif [ -f "app/src/main/kotlin/com/example/weatherpants/MainActivity.kt" ]; then
    check_status 1 "MainActivity.kt is in wrong directory (kotlin/)" "Move to app/src/main/java/"
else
    check_status 1 "MainActivity.kt not found" "Create MainActivity.kt"
fi

# 4. Check API key configuration
echo
echo "4. Checking API key configuration..."
if [ -f "local.properties" ]; then
    if grep -q "WEATHER_API_KEY" "local.properties"; then
        API_KEY=$(grep "WEATHER_API_KEY" "local.properties" | cut -d'=' -f2 | tr -d ' "')
        if [ "$API_KEY" = "YOUR_API_KEY_HERE" ] || [ -z "$API_KEY" ]; then
            check_status 1 "API key not configured" "Add your OpenWeatherMap API key to local.properties"
        else
            check_status 0 "API key is configured"
            echo "  API key (hidden): ${API_KEY:0:4}...${API_KEY: -4}"
        fi
    else
        check_status 1 "WEATHER_API_KEY not found in local.properties" "Add WEATHER_API_KEY=your_key to local.properties"
    fi
else
    check_status 1 "local.properties not found" "Create local.properties with WEATHER_API_KEY"
fi

# 5. Check build.gradle configuration
echo
echo "5. Checking build.gradle configuration..."
if [ -f "app/build.gradle" ]; then
    # Check for namespace
    if grep -q "namespace 'com.example.weatherpants'" "app/build.gradle"; then
        check_status 0 "Namespace is correctly configured"
    else
        check_status 1 "Namespace not configured" "Add namespace to android block in app/build.gradle"
    fi
    
    # Check for buildConfig feature
    if grep -q "buildConfig true" "app/build.gradle"; then
        check_status 0 "BuildConfig feature is enabled"
    else
        check_status 1 "BuildConfig feature not enabled" "Add buildConfig true to buildFeatures"
    fi
else
    check_status 1 "app/build.gradle not found" "Create app/build.gradle"
fi

# 6. Check Docker setup (if using Docker)
echo
echo "6. Checking Docker setup..."
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        check_status 0 "Docker is installed and running"
        
        if [ -f "Dockerfile" ]; then
            check_status 0 "Dockerfile exists"
        else
            check_status 1 "Dockerfile not found" "Create Dockerfile for consistent build environment"
        fi
    else
        check_status 1 "Docker daemon not running" "Start Docker daemon: sudo systemctl start docker"
    fi
else
    echo -e "${YELLOW}  Docker not installed (optional for local builds)${NC}"
fi

# 7. Check Gradle wrapper
echo
echo "7. Checking Gradle wrapper..."
if [ -f "gradlew" ]; then
    if [ -x "gradlew" ]; then
        check_status 0 "Gradle wrapper exists and is executable"
    else
        check_status 1 "Gradle wrapper not executable" "Run: chmod +x gradlew"
    fi
else
    check_status 1 "Gradle wrapper not found" "Generate with: gradle wrapper"
fi

# 8. Check for common resource issues
echo
echo "8. Checking resources..."
if [ -f "app/src/main/res/layout/activity_main.xml" ]; then
    check_status 0 "Main layout file exists"
else
    check_status 1 "Main layout file missing" "Create activity_main.xml"
fi

if [ -f "app/src/main/res/values/strings.xml" ]; then
    check_status 0 "Strings resource file exists"
else
    check_status 1 "Strings resource file missing" "Create strings.xml"
fi

# 9. Try a test build
echo
echo "9. Attempting test build..."
if [ -x "./gradlew" ]; then
    echo "Running: ./gradlew tasks --no-daemon"
    ./gradlew tasks --no-daemon > /tmp/gradle_test.log 2>&1
    if [ $? -eq 0 ]; then
        check_status 0 "Gradle can run successfully"
    else
        check_status 1 "Gradle execution failed" "Check /tmp/gradle_test.log for details"
        echo "  Last 10 lines of error log:"
        tail -10 /tmp/gradle_test.log | sed 's/^/    /'
    fi
else
    echo -e "${YELLOW}  Skipping test build (gradlew not executable)${NC}"
fi

# Summary
echo
echo "======================================================================"
echo "DIAGNOSTIC SUMMARY"
echo "======================================================================"

# Count issues
CRITICAL_ISSUES=0
if [ -f "app/src/main/AndroidManifest.xml" ] && grep -q 'package=' "app/src/main/AndroidManifest.xml"; then
    ((CRITICAL_ISSUES++))
    echo -e "${RED}CRITICAL:${NC} AndroidManifest.xml has package attribute (must be removed)"
fi

if [ ! -f "app/src/main/java/com/example/weatherpants/MainActivity.kt" ]; then
    ((CRITICAL_ISSUES++))
    echo -e "${RED}CRITICAL:${NC} MainActivity.kt not in correct location"
fi

if [ -f "local.properties" ]; then
    API_KEY=$(grep "WEATHER_API_KEY" "local.properties" 2>/dev/null | cut -d'=' -f2 | tr -d ' "')
    if [ "$API_KEY" = "YOUR_API_KEY_HERE" ] || [ -z "$API_KEY" ]; then
        echo -e "${YELLOW}WARNING:${NC} API key not configured (app will build but won't fetch weather)"
    fi
else
    echo -e "${YELLOW}WARNING:${NC} local.properties missing"
fi

if [ $CRITICAL_ISSUES -eq 0 ]; then
    echo -e "${GREEN}No critical issues found!${NC}"
    echo
    echo "To fix this project, run the fix script:"
    echo "  chmod +x weatherpants-fix.sh"
    echo "  ./weatherpants-fix.sh"
else
    echo
    echo -e "${RED}Found $CRITICAL_ISSUES critical issue(s) that will prevent building.${NC}"
    echo
    echo "To automatically fix all issues, run:"
    echo "  chmod +x weatherpants-fix.sh"
    echo "  ./weatherpants-fix.sh"
fi

echo "======================================================================"