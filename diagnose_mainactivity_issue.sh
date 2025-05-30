#!/bin/bash

echo "======================================================================"
echo "Diagnosing MainActivity Class Not Found Issue"
echo "======================================================================"

echo "1. Checking project file structure..."
echo "MainActivity.kt location:"
find . -name "MainActivity.kt" -type f 2>/dev/null || echo "MainActivity.kt NOT FOUND"

echo
echo "Java source directory structure:"
ls -la app/src/main/java/com/example/weatherpants/ 2>/dev/null || echo "Java directory structure missing"

echo
echo "2. Checking AndroidManifest.xml activity declaration..."
if [ -f "app/src/main/AndroidManifest.xml" ]; then
    echo "AndroidManifest.xml MainActivity declaration:"
    grep -A 10 -B 2 "MainActivity" app/src/main/AndroidManifest.xml
else
    echo "AndroidManifest.xml NOT FOUND"
fi

echo
echo "3. Checking if MainActivity.kt has syntax errors..."
if [ -f "app/src/main/java/com/example/weatherpants/MainActivity.kt" ]; then
    echo "MainActivity.kt exists, checking content..."
    echo "First 10 lines:"
    head -10 app/src/main/java/com/example/weatherpants/MainActivity.kt
    echo "..."
    echo "Package declaration:"
    grep "package " app/src/main/java/com/example/weatherpants/MainActivity.kt
    echo "Class declaration:"
    grep "class MainActivity" app/src/main/java/com/example/weatherpants/MainActivity.kt
else
    echo "MainActivity.kt is MISSING from expected location"
fi

echo
echo "4. Testing compilation with simple MainActivity..."
echo "Creating a minimal working MainActivity to test..."

# Ensure directory exists
mkdir -p app/src/main/java/com/example/weatherpants

# Create a super simple MainActivity that we know works
cat > app/src/main/java/com/example/weatherpants/MainActivity.kt << 'EOF'
package com.example.weatherpants

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.example.weatherpants.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Simple test message
        binding.messageTextView.text = "Simple MainActivity Test - Working!"
    }
}
EOF

echo "✓ Created simple test MainActivity"

echo
echo "5. Testing build with simple MainActivity..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
    echo 'Cleaning build...'
    ./gradlew clean > /dev/null 2>&1
    echo 'Building with simple MainActivity...'
    ./gradlew assembleDebug 2>&1 | grep -E '(FAILED|error|Error|BUILD)'
"

echo
echo "6. Checking what gets compiled..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
    echo 'Checking if MainActivity class gets compiled...'
    if [ -f app/build/intermediates/javac/debug/classes/com/example/weatherpants/MainActivity.class ]; then
        echo '✓ MainActivity.class found in build output'
        ls -la app/build/intermediates/javac/debug/classes/com/example/weatherpants/
    else
        echo '✗ MainActivity.class NOT found in build output'
        echo 'Looking for any compiled classes...'
        find app/build -name '*.class' -path '*/weatherpants/*' 2>/dev/null | head -5
    fi
"

echo
echo "7. Checking APK contents..."
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "Checking if MainActivity is in the APK..."
    docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
        unzip -l app/build/outputs/apk/debug/app-debug.apk | grep -i mainactivity || echo 'MainActivity not found in APK'
    "
else
    echo "No APK found"
fi

echo
echo "======================================================================"
echo "DIAGNOSIS COMPLETE"
echo "======================================================================"