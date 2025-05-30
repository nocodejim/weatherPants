#!/bin/bash

echo "======================================================================"
echo "Fixing Kotlin Class Packaging Issue"
echo "======================================================================"

echo "The issue: Kotlin classes compile but don't get packaged into the APK"
echo "Fix: Update build.gradle files to properly handle Kotlin compilation"

# Fix 1: Update top-level build.gradle
echo
echo "1. Fixing top-level build.gradle..."
cat > build.gradle << 'EOF'
buildscript {
    ext.kotlin_version = '1.9.23'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.3.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF

# Fix 2: Update app-level build.gradle with proper Kotlin configuration
echo "2. Fixing app/build.gradle with proper Kotlin configuration..."
cat > app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
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
        buildConfigField("String", "WEATHER_API_KEY", getApiKey("WEATHER_API_KEY"))
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            buildConfigField("String", "WEATHER_API_KEY", getApiKey("WEATHER_API_KEY"))
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

    println("WARNING: Using default placeholder for API Key '" + propertyName + "'.")
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

echo "✓ Updated build.gradle files with proper Kotlin plugin"

# Fix 3: Clean build and test
echo
echo "3. Cleaning and rebuilding with fixed configuration..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
    echo 'Cleaning all build artifacts...'
    ./gradlew clean
    
    echo 'Building with fixed Kotlin configuration...'
    ./gradlew assembleDebug --info 2>&1 | grep -E '(BUILD|MainActivity|kotlin|Task.*compile)'
"

echo
echo "4. Verifying MainActivity gets packaged correctly..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
    echo 'Checking compiled classes...'
    find app/build -name 'MainActivity.class' 2>/dev/null
    
    echo 'Checking APK contents for MainActivity...'
    if [ -f app/build/outputs/apk/debug/app-debug.apk ]; then
        unzip -l app/build/outputs/apk/debug/app-debug.apk | grep -i mainactivity
        if [ \$? -eq 0 ]; then
            echo '✅ MainActivity found in APK!'
        else
            echo '❌ MainActivity still missing from APK'
        fi
    else
        echo 'No APK generated'
    fi
"

BUILD_EXIT_CODE=$?

echo
echo "======================================================================"
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "🎉 SUCCESS! Kotlin packaging should now be fixed!"
    echo
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        echo "✅ APK generated with fixed Kotlin configuration:"
        ls -lh app/build/outputs/apk/debug/app-debug.apk
        echo
        echo "📱 Install the fixed app:"
        echo "   adb install -r app/build/outputs/apk/debug/app-debug.apk"
        echo
        echo "This should now work without the ClassNotFoundException!"
    fi
else
    echo "❌ Build still has issues. Checking error details..."
    echo "Let's see what the build output shows:"
    docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env ./gradlew assembleDebug --stacktrace | tail -20
fi
echo "======================================================================"