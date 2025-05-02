#!/bin/bash

# --- setup.sh ---
# This script initializes the WeatherPants Android project structure,
# creates necessary files, and sets up the Git repository.

echo "Creating WeatherPants project structure..."

# Create root project folder (assuming you run this script INSIDE the desired root folder)
PROJECT_ROOT="." # Current directory
APP_NAME="WeatherPants"

# Create standard Android project directories
mkdir -p "${PROJECT_ROOT}/app/src/main/java/com/example/weatherpants"
mkdir -p "${PROJECT_ROOT}/app/src/main/res/layout"
mkdir -p "${PROJECT_ROOT}/app/src/main/res/values"
mkdir -p "${PROJECT_ROOT}/app/src/main/res/drawable" # For images/icons later
mkdir -p "${PROJECT_ROOT}/gradle/wrapper"
mkdir -p "${PROJECT_ROOT}/scripts" # For our build/helper scripts

echo "Creating initial project files..."

# --- .gitignore ---
# Specifies intentionally untracked files that Git should ignore.
# This is crucial to keep the repository clean and avoid committing
# generated files, build outputs, local configurations, and sensitive data.
cat << EOF > "${PROJECT_ROOT}/.gitignore"
# Generated build files
*.apk
*.aab
*.ap_
*.a_

# Built output directories
/build
/app/build

# Local configuration files
local.properties
.gradle/
*.iml
.idea/
*.keystore
*.jks

# Mac OS files
.DS_Store

# Log files
*.log

# Android Studio profiling data
captures/
*.hprof
EOF

# --- README.md ---
# The main documentation entry point for the repository.
# Should explain what the project is, how to set it up, and how to use it.
cat << EOF > "${PROJECT_ROOT}/README.md"
# WeatherPants Android App

This app tells you whether or not you should wear pants based on the current weather.

## Setup and Usage

Please refer to INSTRUCTIONS.md for detailed setup, build, and deployment instructions.
EOF

# --- INSTRUCTIONS.md (Placeholder - Full version below) ---
touch "${PROJECT_ROOT}/INSTRUCTIONS.md" # We'll populate this later

# --- Project build.gradle (Top Level) ---
# Configures build settings applicable to all modules in the project.
cat << EOF > "${PROJECT_ROOT}/build.gradle"
// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    ext.kotlin_version = '1.9.23' // Example version, check latest stable
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.4.0' // Example version, check latest stable
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:\$kotlin_version"

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF

# --- app/build.gradle (App Module Level) ---
# Configures build settings specific to the 'app' module.
# This is where app dependencies, SDK versions, and application ID are defined.
cat << EOF > "${PROJECT_ROOT}/app/build.gradle"
plugins {
    id 'com.android.application'
    id 'kotlin-android'
}

android {
    namespace 'com.example.weatherpants' // Important for resource linking
    compileSdk 34 // Target Android API level for compilation (Android 14)

    defaultConfig {
        applicationId "com.example.weatherpants"
        minSdk 24 // Minimum Android API level required to run (Android 7.0)
        targetSdk 34 // Target Android API level the app is tested against
        versionCode 1
        versionName "1.0"

        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"

        // IMPORTANT: Add this placeholder for the API key
        // We will load the actual key from local.properties (which is in .gitignore)
        buildConfigField("String", "WEATHER_API_KEY", "\"YOUR_API_KEY_HERE\"")
    }

    buildTypes {
        release {
            minifyEnabled false // Set to true for production builds to shrink code/resources
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            // For release, you'd ideally load the key securely, maybe from CI/CD env vars
            // buildConfigField("String", "WEATHER_API_KEY", "\"\${System.env.WEATHER_API_KEY}\"")
        }
        debug {
             // Debug builds can use the key from local.properties
            // The line below ensures BuildConfig picks up the value from local.properties
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
         viewBinding true // Enables easier view access
         buildConfig true // Enables access to BuildConfig fields like the API key
    }
}

// Function to safely read API key from local.properties
// Create a local.properties file in the project root (it's ignored by git)
// Add the line: WEATHER_API_KEY="YOUR_ACTUAL_API_KEY"
def getApiKey(String propertyName) {
    Properties properties = new Properties()
    def localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        properties.load(localPropertiesFile.newDataInputStream())
        def apiKey = properties.getProperty(propertyName)
        if (apiKey != null) {
            return "\\\"" + apiKey + "\\\"" // Return quoted string for BuildConfig
        }
    }
    // Return a default value or throw an error if the key is mandatory for debug builds
    println("Warning: API Key not found in local.properties. Using default placeholder.")
    return "\"DEFAULT_API_KEY_MISSING\""
}


dependencies {
    // Core Android libraries
    implementation 'androidx.core:core-ktx:1.13.1' // Kotlin extensions
    implementation 'androidx.appcompat:appcompat:1.6.1' // Compatibility library
    implementation 'com.google.android.material:material:1.12.0' // Material Design components
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4' // Layout manager

    // Networking library (Volley is simple for basic requests)
    implementation 'com.android.volley:volley:1.2.1'

    // Testing libraries (Placeholders for good practice)
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
EOF

# --- local.properties (Placeholder - Ignored by Git!) ---
# This file stores local configuration, like the SDK path and API keys.
# ***NEVER COMMIT THIS FILE TO GIT if it contains secrets!***
cat << EOF > "${PROJECT_ROOT}/local.properties"
## This file is automatically generated by Android Studio.
# Do not modify this file -- YOUR CHANGES WILL BE ERASED!
#
# This file must *NOT* be checked into Version Control Systems,
# as it contains information specific to your local configuration.
#
# Location of the SDK. This is only used by Gradle.
# For customization when using a Version Control System, please read the
# header note.
# sdk.dir=/path/to/your/android/sdk <= Android Studio usually sets this

# *** Add your Weather API Key here ***
WEATHER_API_KEY="PASTE_YOUR_OPENWEATHERMAP_API_KEY_HERE"
EOF

# --- app/proguard-rules.pro ---
# ProGuard rules for code shrinking and obfuscation (especially for release builds).
cat << EOF > "${PROJECT_ROOT}/app/proguard-rules.pro"
# Add project specific ProGuard rules here.
# By default, the flags in this file are applied to duplicates specified in
# build.gradle. It is recommended to define common flags in that file and sync
# Linked Executables when adding unique flags to this file.
# You can find general rules for popular libraries at
# https://github.com/Mailcloud/proguard-android-sample
# Add any project specific keep options here:

# If you use libraries like Retrofit, Gson, etc., you might need specific rules
# For Volley, usually no specific rules are needed unless you use reflection heavily

# Keep application classes for stack traces
-keep class com.example.weatherpants.** { *; }
EOF

# --- settings.gradle ---
# Declares the modules included in the build.
cat << EOF > "${PROJECT_ROOT}/settings.gradle"
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "WeatherPants"
include ':app'
EOF

# --- AndroidManifest.xml ---
# Core configuration file for the Android app. Declares components, permissions, etc.
cat << EOF > "${PROJECT_ROOT}/app/src/main/AndroidManifest.xml"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.example.weatherpants">

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

# --- Placeholder Resource Files ---
# Strings used in the app (good for localization)
cat << EOF > "${PROJECT_ROOT}/app/src/main/res/values/strings.xml"
<resources>
    <string name="app_name">WeatherPants</string>
    <string name="loading_weather">Loading weather...</string>
    <string name="temperature_label">Current Temperature:</string>
    <string name="pants_advice_label">Pants Advice:</string>
    <string name="wear_pants">YES! Wear Pants!</string>
    <string name="no_pants">NO! Enjoy the freedom!</string>
    <string name="error_fetching_weather">Could not fetch weather data.</string>
    <string name="api_key_missing">API Key Missing!</string>
</resources>
EOF

# App theme/styles
cat << EOF > "${PROJECT_ROOT}/app/src/main/res/values/themes.xml"
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

# Color definitions
cat << EOF > "${PROJECT_ROOT}/app/src/main/res/values/colors.xml"
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

# Placeholder rules for backup and data extraction (generated by default)
mkdir -p "${PROJECT_ROOT}/app/src/main/res/xml"
cat << EOF > "${PROJECT_ROOT}/app/src/main/res/xml/backup_rules.xml"
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="database" path="."/>
    <exclude domain="sharedpref" path="."/>
    <exclude domain="external" path="."/>
    <exclude domain="root" path="."/>
</full-backup-content>
EOF

cat << EOF > "${PROJECT_ROOT}/app/src/main/res/xml/data_extraction_rules.xml"
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        </cloud-backup>
    <device-transfer>
        </device-transfer>
</data-extraction-rules>
EOF

# --- Placeholder Activity Layout (activity_main.xml) ---
cat << EOF > "${PROJECT_ROOT}/app/src/main/res/layout/activity_main.xml"
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity"
    android:padding="16dp">

    <TextView
        android:id="@+id/textViewLocation"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Weather for: Lebanon, OH"
        android:textSize="18sp"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        android:layout_marginBottom="24dp"/>

    <TextView
        android:id="@+id/textViewTempLabel"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/temperature_label"
        android:textSize="16sp"
        app:layout_constraintTop_toBottomOf="@id/textViewLocation"
        app:layout_constraintStart_toStartOf="parent"
        android:layout_marginTop="24dp"/>

    <TextView
        android:id="@+id/textViewTemperature"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:text="@string/loading_weather"
        android:textSize="24sp"
        android:textStyle="bold"
        app:layout_constraintTop_toBottomOf="@id/textViewTempLabel"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        android:layout_marginTop="8dp"
        android:gravity="center_horizontal"/>

    <TextView
        android:id="@+id/textViewAdviceLabel"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/pants_advice_label"
        android:textSize="16sp"
        app:layout_constraintTop_toBottomOf="@id/textViewTemperature"
        app:layout_constraintStart_toStartOf="parent"
        android:layout_marginTop="32dp"/>

    <TextView
        android:id="@+id/textViewPantsAdvice"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:text="..."
        android:textSize="34sp"
        android:textStyle="bold"
        android:textColor="@color/purple_700"
        app:layout_constraintTop_toBottomOf="@id/textViewAdviceLabel"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        android:layout_marginTop="8dp"
        android:gravity="center_horizontal"/>

    <ProgressBar
        android:id="@+id/progressBar"
        style="?android:attr/progressBarStyle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:visibility="gone"
        tools:visibility="visible"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# --- Placeholder MainActivity.kt ---
cat << EOF > "${PROJECT_ROOT}/app/src/main/java/com/example/weatherpants/MainActivity.kt"
package com.example.weatherpants

import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.TextView
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

    // --- Explanation: View Binding ---
    // View Binding is a feature that makes it easier to interact with views (like TextViews, Buttons)
    // defined in your XML layout file (activity_main.xml).
    // It generates a binding class (ActivityMainBinding) that holds direct references to those views.
    // This replaces the older 'findViewById' method, reducing boilerplate code and potential errors.
    private lateinit var binding: ActivityMainBinding

    // --- Explanation: RequestQueue (Volley) ---
    // Volley is an HTTP library for Android that simplifies network requests.
    // A RequestQueue manages the network requests, handling threading and caching.
    // We initialize it lazily, meaning it's created only when first needed.
    private val requestQueue: RequestQueue by lazy {
        Volley.newRequestQueue(this.applicationContext)
    }

    // --- Explanation: API Key Handling ---
    // It is VERY BAD PRACTICE to hardcode API keys directly in the source code.
    // We use Gradle's buildConfigField (in app/build.gradle) to make the API key
    // available via the generated BuildConfig class.
    // The actual key is stored in 'local.properties', which is listed in '.gitignore'
    // so it's NEVER committed to version control (like Git).
    // This keeps your secret key safe!
    private val apiKey = BuildConfig.WEATHER_API_KEY

    // --- Explanation: Location (Hardcoded for Simplicity) ---
    // For this example, we're hardcoding the location (Lat/Lon for Lebanon, OH).
    // A real app would use GPS (requiring location permissions) or allow user input.
    private val latitude = 39.43
    private val longitude = -84.21
    private val units = "imperial" // Use "metric" for Celsius

    // --- Explanation: Pants Threshold ---
    // The temperature (in Fahrenheit for 'imperial' units) below which we suggest wearing pants.
    private val pantsTemperatureThreshold = 60.0 // Degrees Fahrenheit

    // --- Explanation: onCreate ---
    // This is the first function called when the activity (screen) is created.
    // It's where you typically set up the layout and initialize components.
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Inflate the layout using View Binding
        binding = ActivityMainBinding.inflate(layoutInflater)
        val view = binding.root
        setContentView(view) // Set the inflated layout as the activity's content

        Log.d("WeatherPants", "MainActivity created.") // Basic logging

        // Check if the API key is missing (using the placeholder value)
        if (apiKey == "YOUR_API_KEY_HERE" || apiKey == "DEFAULT_API_KEY_MISSING") {
             Log.e("WeatherPants", "API Key is missing! Please set it in local.properties.")
             binding.textViewTemperature.text = getString(R.string.api_key_missing)
             binding.textViewPantsAdvice.text = "Cannot fetch weather."
             Toast.makeText(this, "API Key Missing!", Toast.LENGTH_LONG).show()
             // Optionally disable fetching or show a clearer error message
             return // Stop further execution in onCreate
        }


        // Fetch weather data when the activity starts
        fetchWeatherData()
    }

    // --- Explanation: fetchWeatherData ---
    // This function constructs the API request URL and sends it using Volley.
    private fun fetchWeatherData() {
        Log.i("WeatherPants", "Fetching weather data...")
        binding.progressBar.visibility = View.VISIBLE // Show loading indicator
        binding.textViewTemperature.text = getString(R.string.loading_weather)
        binding.textViewPantsAdvice.text = "..."

        // Construct the OpenWeatherMap API URL
        // Example URL: https://api.openweathermap.org/data/2.5/weather?lat=39.43&lon=-84.21&appid=YOUR_KEY&units=imperial
        val apiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=$units"

        // Create a JSON Object Request using Volley
        val jsonObjectRequest = JsonObjectRequest(
            Request.Method.GET, apiUrl, null,
            { response ->
                // --- Success Callback ---
                Log.d("WeatherPants", "API Response: ${response.toString()}")
                binding.progressBar.visibility = View.GONE // Hide loading indicator
                try {
                    // --- Explanation: Parsing JSON ---
                    // The API returns data in JSON format (JavaScript Object Notation).
                    // We need to navigate the JSON structure to extract the values we need.
                    // OpenWeatherMap nests the temperature under the 'main' object.
                    val main = response.getJSONObject("main")
                    val temp = main.getDouble("temp") // Get temperature

                    // Update the UI with the temperature
                    val tempFormat = DecimalFormat("#.#") // Format to one decimal place
                    binding.textViewTemperature.text = "${tempFormat.format(temp)} ${if (units == "imperial") "°F" else "°C"}"

                    // Decide whether to wear pants
                    decidePants(temp)

                } catch (e: JSONException) {
                    // Handle errors during JSON parsing
                    Log.e("WeatherPants", "Error parsing JSON response", e)
                    showError()
                }
            },
            { error ->
                // --- Error Callback ---
                Log.e("WeatherPants", "Volley Error: ${error.message}", error)
                binding.progressBar.visibility = View.GONE // Hide loading indicator
                showError()
            }
        )

        // Add the request to the RequestQueue to execute it
        requestQueue.add(jsonObjectRequest)
    }

    // --- Explanation: decidePants ---
    // Simple logic to determine the pants advice based on temperature.
    private fun decidePants(temperature: Double) {
        val shouldWearPants = temperature < pantsTemperatureThreshold

        if (shouldWearPants) {
            binding.textViewPantsAdvice.text = getString(R.string.wear_pants)
            binding.textViewPantsAdvice.setTextColor(getColor(R.color.purple_700)) // Example color
            Log.i("WeatherPants", "Advice: Wear pants! Temp: $temperature")
        } else {
            binding.textViewPantsAdvice.text = getString(R.string.no_pants)
            binding.textViewPantsAdvice.setTextColor(getColor(R.color.teal_700)) // Example color
            Log.i("WeatherPants", "Advice: No pants needed. Temp: $temperature")
        }
    }

    // --- Explanation: showError ---
    // Helper function to display a generic error message on the UI.
    private fun showError() {
        binding.textViewTemperature.text = getString(R.string.error_fetching_weather)
        binding.textViewPantsAdvice.text = "" // Clear advice on error
        Toast.makeText(this, getString(R.string.error_fetching_weather), Toast.LENGTH_SHORT).show()
    }

    // --- Explanation: Logging ---
    // Android provides a Log class (android.util.Log) for logging messages.
    // Levels: d (debug), i (info), w (warning), e (error), v (verbose).
    // You can view these logs using Android Studio's Logcat window or 'adb logcat' command.
    // Logging is ESSENTIAL for debugging and monitoring your app.
}
EOF

# --- Gradle Wrapper Files (Essential for consistent builds) ---
# You would typically generate these with './gradlew wrapper' command
# For setup, we include minimal placeholders or fetch them.
# Fetching is more robust if internet is available during setup.

echo "Attempting to download Gradle wrapper..."
# Check if gradle is installed, if not, attempt download
if command -v gradle &> /dev/null; then
    echo "Gradle found, generating wrapper..."
    (cd "${PROJECT_ROOT}" && gradle wrapper --gradle-version 8.4) # Adjust version as needed
    # Ensure gradlew is executable
     chmod +x "${PROJECT_ROOT}/gradlew"
else
   echo "WARNING: Gradle command not found. Cannot automatically generate wrapper."
   echo "Please install Gradle or run './gradlew' from an existing project to download it."
   echo "Creating placeholder gradlew files. Build might fail until wrapper is present."
   # Create placeholder files if gradle isn't available
   touch "${PROJECT_ROOT}/gradlew"
   touch "${PROJECT_ROOT}/gradlew.bat"
   mkdir -p "${PROJECT_ROOT}/gradle/wrapper"
   cat << EOF > "${PROJECT_ROOT}/gradle/wrapper/gradle-wrapper.properties"
# Placeholder - Distribution URL will be determined by build system or needs manual setup
# distributionBase=GRADLE_USER_HOME
# distributionPath=wrapper/dists
# zipStoreBase=GRADLE_USER_HOME
# zipStorePath=wrapper/dists
# distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-bin.zip # Example
EOF
   # Make gradlew executable (even if placeholder)
    chmod +x "${PROJECT_ROOT}/gradlew"
fi


# --- Create build script placeholder ---
touch "${PROJECT_ROOT}/scripts/build_apk.sh"
chmod +x "${PROJECT_ROOT}/scripts/build_apk.sh" # Make it executable

# --- Create Dockerfile placeholder ---
touch "${PROJECT_ROOT}/Dockerfile"

echo "Initializing Git repository..."
git init
git add .
git commit -m "Initial project structure setup for WeatherPants"

echo "------------------------------------------------------------------"
echo "WeatherPants project initialized!"
echo "------------------------------------------------------------------"
echo "IMPORTANT NEXT STEPS:"
echo "1. Edit 'local.properties' and add your OpenWeatherMap API key:"
echo "   WEATHER_API_KEY=\"YOUR_ACTUAL_API_KEY\""
echo "2. Review the generated files, especially 'app/build.gradle' for versions."
echo "3. Populate 'scripts/build_apk.sh', 'Dockerfile', and 'INSTRUCTIONS.md' (templates provided in documentation)."
echo "4. If Gradle wrapper wasn't generated automatically, run './gradlew tasks' inside the project directory to download it."
echo "------------------------------------------------------------------"

exit 0