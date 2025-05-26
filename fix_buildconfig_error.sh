#!/bin/bash

echo "======================================================================"
echo "Fixing BuildConfig API Key Generation Error"
echo "======================================================================"

# The error shows that the generated BuildConfig.java has:
# public static final String WEATHER_API_KEY = \"3a7ab9b9e0fb8efbc4320ec5173d9ce1\";
# The backslashes are being literally included, making invalid Java syntax.

echo "1. Fixing the getApiKey function in app/build.gradle..."

# Replace the entire app/build.gradle with the corrected version
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

        // Fixed API key handling - no extra escaping needed
        buildConfigField("String", "WEATHER_API_KEY", getApiKey("WEATHER_API_KEY"))
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            buildConfigField("String", "WEATHER_API_KEY", getApiKey("WEATHER_API_KEY"))
        }
        debug {
            // Inherits from defaultConfig
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
         buildConfig true
    }
}

// FIXED: Corrected getApiKey function - removed extra escaping
def getApiKey(String propertyName) {
    Properties properties = new Properties()
    File localPropertiesFile = rootProject.file("local.properties")

    if (localPropertiesFile.exists()) {
        try {
            localPropertiesFile.withInputStream { stream ->
                properties.load(stream)
            }
            def apiKey = properties.getProperty(propertyName)

            if (apiKey != null && !apiKey.trim().isEmpty()) {
                println("INFO: Using API Key for '" + propertyName + "' from local.properties.")
                // FIXED: Just return quoted string - buildConfigField handles escaping automatically
                return '"' + apiKey.trim() + '"'
            } else {
                println("WARNING: API Key for '" + propertyName + "' in local.properties is null or empty.")
            }
        } catch (Exception e) {
            println("WARNING: Could not read local.properties file for API Key '" + propertyName + "'. Error: " + e.getMessage())
        }
    } else {
        println("WARNING: local.properties file not found in project root. Cannot read API Key '" + propertyName + "'.")
    }

    println("WARNING: Using default placeholder for API Key '" + propertyName + "'. The app may not function correctly.")
    return '"DEFAULT_KEY_MISSING_OR_PROBLEMATIC"'
}

dependencies {
    implementation 'androidx.core:core-ktx:1.13.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.12.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'

    implementation 'com.android.volley:volley:1.2.1'

    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
EOF

echo "✓ Fixed app/build.gradle"

# Clean and rebuild
echo
echo "2. Cleaning previous build artifacts..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env ./gradlew clean

echo
echo "3. Testing the build with fixed API key handling..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env ./scripts/build_apk.sh

BUILD_EXIT_CODE=$?

echo
echo "======================================================================"
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "🎉 SUCCESS! Build completed with fixed API key handling!"
    echo
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        echo "✅ APK created successfully:"
        ls -lh app/build/outputs/apk/debug/app-debug.apk
        echo
        echo "Now you can sideload this working APK!"
        echo "Command: adb install app/build/outputs/apk/debug/app-debug.apk"
    fi
else
    echo "❌ Still failing. Checking what BuildConfig generates now..."
    docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
        find app/build -name 'BuildConfig.java' -exec cat {} \; 2>/dev/null | head -20
    "
fi
echo "======================================================================"