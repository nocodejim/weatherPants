#!/bin/bash

echo "======================================================================"
echo "WeatherPants Docker Build Debug Script"
echo "======================================================================"
echo

# Get current directory info
echo "1. CURRENT DIRECTORY INFO:"
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la
echo

# Check if key files exist
echo "2. KEY FILES CHECK:"
files_to_check=("Dockerfile" "scripts/build_apk.sh" "app/build.gradle" "gradlew")
for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
        if [[ "$file" == *".sh" ]] || [[ "$file" == "gradlew" ]]; then
            if [ -x "$file" ]; then
                echo "  └─ Executable: YES"
            else
                echo "  └─ Executable: NO (this could be a problem!)"
            fi
        fi
    else
        echo "✗ $file MISSING"
    fi
done
echo

# Check Docker installation and status
echo "3. DOCKER STATUS:"
if command -v docker &> /dev/null; then
    echo "✓ Docker command found"
    echo "Docker version: $(docker --version)"
    
    # Check if Docker daemon is running
    if docker info &> /dev/null; then
        echo "✓ Docker daemon is running"
    else
        echo "✗ Docker daemon is NOT running or not accessible"
        echo "Try: sudo systemctl start docker"
        exit 1
    fi
else
    echo "✗ Docker command not found"
    exit 1
fi
echo

# Check if the Docker image exists
echo "4. DOCKER IMAGE CHECK:"
if docker images | grep -q "weatherpants-dev-env"; then
    echo "✓ weatherpants-dev-env image found"
    docker images | grep weatherpants-dev-env
else
    echo "✗ weatherpants-dev-env image NOT found"
    echo "You need to build it first with: docker build -t weatherpants-dev-env ."
    
    # Check if Dockerfile exists and show how to build
    if [ -f "Dockerfile" ]; then
        echo "Dockerfile exists. Building image now..."
        docker build -t weatherpants-dev-env . || {
            echo "Docker build failed. Check the Dockerfile."
            exit 1
        }
    else
        echo "Dockerfile is missing!"
        exit 1
    fi
fi
echo

# Test basic Docker functionality
echo "5. BASIC DOCKER CONTAINER TEST:"
echo "Testing if container starts and can access mounted volume..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "echo 'Container started successfully'; ls -la /app; pwd" || {
    echo "✗ Basic container test failed"
    exit 1
}
echo

# Check the build script specifically
echo "6. BUILD SCRIPT ANALYSIS:"
if [ -f "scripts/build_apk.sh" ]; then
    echo "Build script exists. Contents:"
    echo "--- scripts/build_apk.sh ---"
    cat scripts/build_apk.sh
    echo "--- End of script ---"
    echo
    
    # Test script syntax
    echo "Checking script syntax..."
    if bash -n scripts/build_apk.sh; then
        echo "✓ Script syntax is valid"
    else
        echo "✗ Script has syntax errors"
    fi
    echo
    
    # Check if script is executable
    if [ -x "scripts/build_apk.sh" ]; then
        echo "✓ Script is executable"
    else
        echo "✗ Script is not executable. Fixing..."
        chmod +x scripts/build_apk.sh
        echo "✓ Made script executable"
    fi
else
    echo "✗ Build script does not exist!"
fi
echo

# Test running the script with verbose output
echo "7. TESTING SCRIPT EXECUTION:"
echo "Running the build script with verbose output..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
    set -x
    echo 'Current directory inside container:'
    pwd
    echo 'Contents of /app:'
    ls -la /app
    echo 'Checking if script exists:'
    ls -la /app/scripts/build_apk.sh
    echo 'Testing script execution:'
    if [ -f /app/scripts/build_apk.sh ]; then
        echo 'Script file found, attempting to execute...'
        /bin/bash -x /app/scripts/build_apk.sh
    else
        echo 'Script file not found in container'
    fi
" 2>&1 | head -50  # Limit output to first 50 lines to avoid spam
echo

# Check if local.properties exists and has API key
echo "8. API KEY CONFIGURATION:"
if [ -f "local.properties" ]; then
    echo "✓ local.properties exists"
    if grep -q "WEATHER_API_KEY" local.properties; then
        echo "✓ WEATHER_API_KEY found in local.properties"
        # Don't show the actual key for security
        echo "API key is set (not showing value for security)"
    else
        echo "✗ WEATHER_API_KEY not found in local.properties"
    fi
else
    echo "✗ local.properties does not exist"
    echo "Creating a template local.properties file..."
    cat > local.properties << EOF
# Android SDK location (will be set by Android Studio or Docker)
# sdk.dir=/path/to/android/sdk

# Weather API Key - Get this from OpenWeatherMap
WEATHER_API_KEY="YOUR_API_KEY_HERE"
EOF
    echo "✓ Created local.properties template"
fi
echo

# Final test - try to run a simple command in the container
echo "9. FINAL CONTAINER CONNECTIVITY TEST:"
echo "Testing if we can run commands in the container..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
    echo 'Final test successful!'
    echo 'Java version:'
    java -version 2>&1 | head -3
    echo 'Android SDK:'
    if [ -d \$ANDROID_SDK_ROOT ]; then
        echo 'SDK found at: '\$ANDROID_SDK_ROOT
    else
        echo 'SDK not found'
    fi
    echo 'Gradlew test:'
    if [ -f ./gradlew ]; then
        echo 'gradlew exists'
        if ./gradlew --version >/dev/null 2>&1; then
            echo 'gradlew can execute'
        else
            echo 'gradlew execution failed'
        fi
    else
        echo 'gradlew not found'
    fi
"

echo
echo "======================================================================"
echo "DEBUG COMPLETE"
echo "======================================================================"
echo "If the script still fails silently after these checks, please share"
echo "the output above so I can help diagnose the specific issue."