#!/bin/bash

echo "======================================================================"
echo "Complete Docker Fix and Test for WeatherPants"
echo "======================================================================"

# Step 1: Clean up any existing broken images
echo "1. Cleaning up existing Docker images..."
docker rmi weatherpants-dev-env 2>/dev/null || echo "No existing image to remove"

# Step 2: Build the Docker image with the fixed Dockerfile
echo
echo "2. Building Docker image with fixed Dockerfile..."
echo "This may take several minutes for first build..."
docker build -t weatherpants-dev-env . || {
    echo "❌ ERROR: Docker build failed"
    echo "Check the Dockerfile and try again"
    exit 1
}

echo "✅ Docker image built successfully!"

# Step 3: Test basic container functionality
echo
echo "3. Testing basic container functionality..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
    echo '=== Container Environment Test ==='
    echo 'Current directory:' \$(pwd)
    echo 'Java version:'
    java -version 2>&1 | head -3
    echo 'Android SDK location:' \$ANDROID_SDK_ROOT
    echo 'SDK contents:'
    ls -la \$ANDROID_SDK_ROOT 2>/dev/null || echo 'SDK directory not found'
    echo 'Gradlew exists:' \$(ls -la gradlew 2>/dev/null || echo 'gradlew not found')
    echo 'Build script exists:' \$(ls -la scripts/build_apk.sh 2>/dev/null || echo 'build script not found')
    echo '=== Test Complete ==='
"

if [ $? -eq 0 ]; then
    echo "✅ Basic container test passed"
else
    echo "❌ Basic container test failed"
    exit 1
fi

# Step 4: Test Gradle wrapper functionality
echo
echo "4. Testing Gradle wrapper in container..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
    echo 'Testing Gradle wrapper...'
    ./gradlew --version || echo 'Gradle wrapper test failed'
"

# Step 5: Test the actual build script
echo
echo "5. Testing the build script execution..."
echo "This will attempt to build the actual APK..."
echo "Running: docker run --rm -v \"\$(pwd):/app\" -w /app weatherpants-dev-env ./scripts/build_apk.sh"
echo

# Run the actual build command
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env ./scripts/build_apk.sh

BUILD_EXIT_CODE=$?

echo
echo "======================================================================"
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "🎉 SUCCESS! Build completed successfully!"
    echo
    echo "Your APK should be located at:"
    echo "$(pwd)/app/build/outputs/apk/debug/app-debug.apk"
    echo
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        echo "✅ APK file confirmed to exist!"
        ls -lh app/build/outputs/apk/debug/app-debug.apk
    else
        echo "⚠️  APK file not found at expected location"
    fi
else
    echo "❌ Build failed with exit code: $BUILD_EXIT_CODE"
    echo
    echo "Check the build output above for specific errors."
    echo "Common issues:"
    echo "- Missing or invalid API key in local.properties"
    echo "- Gradle dependency download issues"
    echo "- Android SDK component problems"
fi
echo "======================================================================"chomo