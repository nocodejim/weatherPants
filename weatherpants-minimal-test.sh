#!/bin/bash

echo "======================================================================"
echo "Creating Minimal Test Version of WeatherPants (No API Required)"
echo "======================================================================"
echo "This version will work without an API key to verify the app builds"
echo

# Create a simple MainActivity that doesn't need an API key
echo "Creating minimal MainActivity.kt..."
mkdir -p app/src/main/java/com/example/weatherpants
cat > app/src/main/java/com/example/weatherpants/MainActivity.kt << 'EOF'
package com.example.weatherpants

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.weatherpants.databinding.ActivityMainBinding
import kotlin.random.Random

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Simulate weather with random temperature
        simulateWeather()
    }

    private fun simulateWeather() {
        // Generate random temperature between 30 and 90°F
        val randomTemp = Random.nextInt(30, 91)
        val pantsThreshold = 60
        
        val message = buildString {
            appendLine("WeatherPants Test Mode")
            appendLine()
            appendLine("Simulated Temperature: ${randomTemp}°F")
            appendLine()
            if (randomTemp < pantsThreshold) {
                appendLine("🥶 It's cold! Wear pants!")
            } else {
                appendLine("☀️ It's warm! No pants needed!")
            }
            appendLine()
            appendLine("(This is a test version - no API required)")
        }
        
        binding.messageTextView.text = message
    }
}
EOF
echo "✓ Minimal MainActivity created"

# Create simple layout
echo "Creating simple layout..."
mkdir -p app/src/main/res/layout
cat > app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="16dp"
    tools:context=".MainActivity">

    <TextView
        android:id="@+id/messageTextView"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Loading..."
        android:textSize="18sp"
        android:gravity="center"
        android:textAlignment="center"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
EOF
echo "✓ Layout created"

# Create minimal build.gradle without API key logic
echo "Creating minimal app/build.gradle..."
cat > app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
    id 'kotlin-android'
}

android {
    namespace 'com.example.weatherpants'
    compileSdk 34

    defaultConfig {
        applicationId "com.example.weatherpants"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"

        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = '1.8'
    }
    buildFeatures {
        viewBinding true
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.13.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.12.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'

    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
EOF
echo "✓ Minimal build.gradle created"

# Fix AndroidManifest.xml
echo "Fixing AndroidManifest.xml..."
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.WeatherPants"
        tools:targetApi="31">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

    </application>

</manifest>
EOF
echo "✓ AndroidManifest.xml fixed"

# Ensure required resource files exist
echo "Creating required resource files..."
mkdir -p app/src/main/res/values

if [ ! -f "app/src/main/res/values/strings.xml" ]; then
cat > app/src/main/res/values/strings.xml << 'EOF'
<resources>
    <string name="app_name">WeatherPants</string>
</resources>
EOF
fi

if [ ! -f "app/src/main/res/values/colors.xml" ]; then
cat > app/src/main/res/values/colors.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="purple_200">#FFBB86FC</color>
    <color name="purple_500">#FF6200EE</color>
    <color name="purple_700">#FF3700B3</color>
    <color name="teal_200">#FF03DAC5</color>
    <color name="teal_700">#FF018786</color>
    <color name="black">#FF000000</color>
    <color name="white">#FFFFFFFF</color>
</resources>
EOF
fi

if [ ! -f "app/src/main/res/values/themes.xml" ]; then
cat > app/src/main/res/values/themes.xml << 'EOF'
<resources xmlns:tools="http://schemas.android.com/tools">
    <style name="Theme.WeatherPants" parent="Theme.MaterialComponents.DayNight.DarkActionBar">
        <item name="colorPrimary">@color/purple_500</item>
        <item name="colorPrimaryVariant">@color/purple_700</item>
        <item name="colorOnPrimary">@color/white</item>
        <item name="colorSecondary">@color/teal_200</item>
        <item name="colorSecondaryVariant">@color/teal_700</item>
        <item name="colorOnSecondary">@color/black</item>
        <item name="android:statusBarColor" tools:targetApi="l">?attr/colorPrimaryVariant</item>
    </style>
</resources>
EOF
fi
echo "✓ Resource files created"

# Clean and build
echo
echo "Cleaning previous build artifacts..."
rm -rf app/build build .gradle 2>/dev/null || true

echo
echo "======================================================================"
echo "Building minimal test version..."
echo "======================================================================"

# Make gradlew executable
chmod +x ./gradlew 2>/dev/null || true

# Try to build
./gradlew clean assembleDebug

BUILD_EXIT_CODE=$?

echo
echo "======================================================================"
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "🎉 SUCCESS! Minimal test version built successfully!"
    echo
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        echo "✅ Test APK created:"
        ls -lh app/build/outputs/apk/debug/app-debug.apk
        echo
        echo "This test version works without an API key."
        echo "Once this works, you can run the full fix script to add weather functionality."
    fi
else
    echo "❌ Build failed even with minimal version."
    echo
    echo "This indicates a fundamental project setup issue."
    echo "Please check:"
    echo "1. Java/JDK is installed (version 11 or 17)"
    echo "2. Android SDK is available"
    echo "3. Gradle wrapper is properly configured"
fi
echo "======================================================================">