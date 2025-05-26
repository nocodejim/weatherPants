#!/bin/bash

echo "======================================================================"
echo "Fixing Compilation Error with Simplified MainActivity"
echo "======================================================================"

# Replace the complex MainActivity with a simple working version first
echo "1. Creating simplified MainActivity.kt that will definitely compile..."

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

        // Simple initial message
        binding.messageTextView.text = "Welcome to WeatherPants!\n\nBasic app is working!"
    }
}
EOF

echo "✓ Simplified MainActivity.kt created"

# Test the build
echo
echo "2. Testing build with simplified MainActivity..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env ./scripts/build_apk.sh

BUILD_EXIT_CODE=$?

echo
echo "======================================================================"
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "🎉 SUCCESS! Basic app builds successfully!"
    echo
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        echo "✅ APK created:"
        ls -lh app/build/outputs/apk/debug/app-debug.apk
        echo
        echo "You can now install this basic version with:"
        echo "adb install app/build/outputs/apk/debug/app-debug.apk"
        echo
        echo "Once this basic version works, we can add the weather functionality."
    fi
else
    echo "❌ Still failing. Getting detailed error..."
    docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
        ./gradlew assembleDebug --stacktrace 2>&1 | grep -A 10 -B 5 'FAILED\|error:'
    "
fi
echo "======================================================================"