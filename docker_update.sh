#!/bin/bash

echo "======================================================================"
echo "Fixing and Testing Docker Setup"
echo "======================================================================"

# Step 1: Rebuild the Docker image with the fixed Dockerfile
echo "1. Rebuilding Docker image..."
docker build -t weatherpants-dev-env . || {
    echo "ERROR: Docker build failed"
    exit 1
}

echo "✓ Docker image rebuilt successfully"
echo

# Step 2: Test basic container functionality
echo "2. Testing basic container functionality..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "echo 'Container test successful'; ls -la; pwd"

if [ $? -eq 0 ]; then
    echo "✓ Basic container test passed"
else
    echo "✗ Basic container test failed"
    exit 1
fi
echo

# Step 3: Test script execution with verbose output
echo "3. Testing script execution with verbose output..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
    echo 'Testing script execution...'
    echo 'Current directory:' \$(pwd)
    echo 'Script exists:' \$(ls -la scripts/build_apk.sh)
    echo 'About to execute build script...'
    ./scripts/build_apk.sh
"

if [ $? -eq 0 ]; then
    echo "✓ Script execution test completed"
else
    echo "✗ Script execution had issues (check output above)"
fi
echo

# Step 4: Try the original command that was failing
echo "4. Testing original Docker command..."
echo "Running: docker run --rm -v \"\$(pwd):/app\" -w /app weatherpants-dev-env ./scripts/build_apk.sh"
echo

docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env ./scripts/build_apk.sh

if [ $? -eq 0 ]; then
    echo "✓ Original command now works!"
else
    echo "✗ Original command still has issues"
fi

echo
echo "======================================================================"
echo "Test Complete"
echo "======================================================================"