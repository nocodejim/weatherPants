#!/bin/bash

echo "======================================================================"
echo "COMPLETE WeatherPants Project Fix"
echo "======================================================================"
echo "This script fixes ALL identified issues in the WeatherPants project"
echo

# ISSUE 1: Fix AndroidManifest.xml - Remove deprecated package attribute
echo "1. Fixing AndroidManifest.xml (removing package attribute)..."
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET" />
    
    <application
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
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

# ISSUE 2: Fix app/build.gradle with corrected API key handling
# echo "2. Fixing app/build.gradle (API key handling)..."
# cat > app/build.gradle << 'EOF'
# plugins {
#     id 'com.android.application'
#     id 'kotlin-android'
# }

# android {
#     namespace 'com.example.weatherpants'
#     compileSdk 34

#     defaultConfig {
#         applicationId "com.example.weatherpants"
#         minSdk 24
#         targetSdk 34
#         versionCode 1
#         versionName "1.0"

#         testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"

#         // Fixed API key handling
#         buildConfigField("String", "WEATHER_API_KEY", getApiKey())
#     }

#     buildTypes {
#         release {
#             minifyEnabled false
#             proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
#         }
#     }
#     compileOptions {
#         sourceCompatibility JavaVersion.VERSION_1_8
#         targetCompatibility JavaVersion.VERSION_1_8
#     }
#     kotlinOptions {
#         jvmTarget = '1.8'
#     }
#     buildFeatures {
#         viewBinding true
#         buildConfig true
#     }
# }

# // Simplified and fixed API key function
# def getApiKey() {
#     Properties properties = new Properties()
#     File localPropertiesFile = rootProject.file("local.properties")
    
#     if (localPropertiesFile.exists()) {
#         properties.load(localPropertiesFile.newDataInputStream())
#         String apiKey = properties.getProperty("WEATHER_API_KEY", "")
#         if (!apiKey.isEmpty()) {
#             return "\"${apiKey}\""
#         }
#     }
    
#     return "\"YOUR_API_KEY_HERE\""
# }

# dependencies {
#     implementation 'androidx.core:core-ktx:1.13.1'
#     implementation 'androidx.appcompat:appcompat:1.6.1'
#     implementation 'com.google.android.material:material:1.12.0'
#     implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
#     implementation 'com.android.volley:volley:1.2.1'

#     testImplementation 'junit:junit:4.13.2'
#     androidTestImplementation 'androidx.test.ext:junit:1.1.5'
#     androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
# }
# EOF
echo "✓ app/build.gradle fixed"

# ISSUE 3: Fix MainActivity.kt with full weather functionality
echo "3. Creating fully functional MainActivity.kt..."
mkdir -p app/src/main/java/com/example/weatherpants
cat > app/src/main/java/com/example/weatherpants/MainActivity.kt << 'EOF'
package com.example.weatherpants

import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Request
import com.android.volley.RequestQueue
import com.android.volley.toolbox.JsonObjectRequest
import com.android.volley.toolbox.Volley
import com.example.weatherpants.databinding.ActivityMainBinding
import org.json.JSONException
import java.text.DecimalFormat

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private val requestQueue: RequestQueue by lazy {
        Volley.newRequestQueue(this.applicationContext)
    }

    private val apiKey = BuildConfig.WEATHER_API_KEY
    private val latitude = 39.43
    private val longitude = -84.21
    private val units = "imperial"
    private val pantsTemperatureThreshold = 60.0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        Log.d("WeatherPants", "MainActivity created.")

        if (apiKey == "YOUR_API_KEY_HERE") {
            Log.e("WeatherPants", "API Key is missing! Please set it in local.properties.")
            binding.messageTextView.text = getString(R.string.api_key_missing)
            Toast.makeText(this, "API Key Missing! Add WEATHER_API_KEY to local.properties", Toast.LENGTH_LONG).show()
            return
        }

        fetchWeatherData()
    }

    private fun fetchWeatherData() {
        Log.i("WeatherPants", "Fetching weather data...")
        binding.messageTextView.text = getString(R.string.loading_weather)

        val apiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=$units"

        val jsonObjectRequest = JsonObjectRequest(
            Request.Method.GET, apiUrl, null,
            { response ->
                Log.d("WeatherPants", "API Response: ${response.toString()}")
                try {
                    val main = response.getJSONObject("main")
                    val temp = main.getDouble("temp")

                    val tempFormat = DecimalFormat("#.#")
                    val tempText = "${tempFormat.format(temp)}°F"
                    
                    decidePants(temp, tempText)

                } catch (e: JSONException) {
                    Log.e("WeatherPants", "Error parsing JSON response", e)
                    showError()
                }
            },
            { error ->
                Log.e("WeatherPants", "Volley Error: ${error.message}", error)
                showError()
            }
        )

        requestQueue.add(jsonObjectRequest)
    }

    private fun decidePants(temperature: Double, tempText: String) {
        val shouldWearPants = temperature < pantsTemperatureThreshold

        val message = if (shouldWearPants) {
            "$tempText\n\n${getString(R.string.wear_pants)}"
        } else {
            "$tempText\n\n${getString(R.string.no_pants)}"
        }
        
        binding.messageTextView.text = message
        Log.i("WeatherPants", "Temperature: $temperature, Wear pants: $shouldWearPants")
    }

    private fun showError() {
        binding.messageTextView.text = getString(R.string.error_fetching_weather)
        Toast.makeText(this, getString(R.string.error_fetching_weather), Toast.LENGTH_SHORT).show()
    }
}
EOF
echo "✓ MainActivity.kt created with full functionality"

# ISSUE 4: Fix Dockerfile
echo "4. Fixing Dockerfile..."
cat > Dockerfile << 'EOF'
FROM ubuntu:22.04

LABEL maintainer="Audj <audjpodge@buckeye90.com>"
LABEL description="Android build environment for WeatherPants app"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    wget \
    unzip \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_COMMAND_LINE_TOOLS_VERSION=11076708
ENV ANDROID_BUILD_TOOLS_VERSION=34.0.0
ENV ANDROID_PLATFORM_VERSION=34

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMAND_LINE_TOOLS_VERSION}_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/build-tools/${ANDROID_BUILD_TOOLS_VERSION}:$PATH

RUN yes | sdkmanager --licenses > /dev/null || true && \
    sdkmanager "platforms;android-${ANDROID_PLATFORM_VERSION}" \
               "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
               "platform-tools"

WORKDIR /app

CMD ["/bin/bash"]
EOF
echo "✓ Dockerfile fixed"

# ISSUE 5: Fix layout file to use simpler binding
echo "5. Fixing activity_main.xml layout..."
cat > app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <ImageView
        android:id="@+id/weatherIconImageView"
        android:layout_width="96dp"
        android:layout_height="96dp"
        android:src="@drawable/ic_placeholder_weather"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintBottom_toTopOf="@id/messageTextView"
        app:layout_constraintVertical_chainStyle="packed"
        android:layout_marginBottom="16dp"
        android:contentDescription="Weather Icon" />

    <TextView
        android:id="@+id/messageTextView"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/loading_weather"
        android:textSize="20sp"
        android:gravity="center"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/weatherIconImageView" />

</androidx.constraintlayout.widget.ConstraintLayout>
EOF
echo "✓ Layout file fixed"

# ISSUE 6: Ensure gradle.properties exists
echo "6. Creating gradle.properties..."
cat > gradle.properties << 'EOF'
android.useAndroidX=true
android.enableJetifier=true
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.nonTransitiveRClass=true
EOF
echo "✓ gradle.properties created"

# ISSUE 7: Create/update local.properties template if it doesn't exist
if [ ! -f "local.properties" ]; then
    echo "7. Creating local.properties template..."
    cat > local.properties << 'EOF'
# SDK location (will be set automatically by Android Studio or Docker)
# sdk.dir=/path/to/android/sdk

# Weather API Key - Get this from OpenWeatherMap.org
# 1. Go to https://openweathermap.org/api
# 2. Sign up for a free account
# 3. Get your API key
# 4. Replace YOUR_API_KEY_HERE with your actual key
WEATHER_API_KEY=YOUR_API_KEY_HERE
EOF
    echo "✓ local.properties template created"
    echo
    echo "⚠️  IMPORTANT: Edit local.properties and add your OpenWeatherMap API key!"
else
    echo "7. local.properties already exists, skipping..."
fi

# Clean previous build artifacts
echo
echo "8. Cleaning previous build artifacts..."
rm -rf app/build build .gradle 2>/dev/null || true
echo "✓ Build artifacts cleaned"

# Test the build
echo
echo "======================================================================"
echo "Testing the build..."
echo "======================================================================"

# Check if we should use Docker or local build
if command -v docker &> /dev/null && [ -f "Dockerfile" ]; then
    echo "Using Docker build environment..."
    
    # Build Docker image
    echo "Building Docker image..."
    docker build -t weatherpants-dev-env . || {
        echo "❌ Docker build failed"
        exit 1
    }
    
    # Run the build
    echo "Running build in Docker..."
    docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env ./scripts/build_apk.sh
    BUILD_EXIT_CODE=$?
else
    echo "Using local build environment..."
    
    # Make gradlew executable
    chmod +x ./gradlew 2>/dev/null || true
    
    # Run the build
    ./gradlew clean assembleDebug
    BUILD_EXIT_CODE=$?
fi

echo
echo "======================================================================"
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "🎉 SUCCESS! Build completed successfully!"
    echo
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        echo "✅ APK created successfully:"
        ls -lh app/build/outputs/apk/debug/app-debug.apk
        echo
        echo "You can now install the APK on your device:"
        echo "  adb install app/build/outputs/apk/debug/app-debug.apk"
    fi
else
    echo "❌ Build failed. Please check the errors above."
    echo
    echo "Common issues to check:"
    echo "1. Did you add your OpenWeatherMap API key to local.properties?"
    echo "2. Is Docker running (if using Docker build)?"
    echo "3. Is Java/Android SDK properly installed (if using local build)?"
fi
echo "======================================================================"