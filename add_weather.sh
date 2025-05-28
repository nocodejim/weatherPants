#!/bin/bash

echo "======================================================================"
echo "Adding Weather Functionality to Working WeatherPants App"
echo "======================================================================"

# Step 1: Update MainActivity.kt with weather functionality
echo "1. Adding weather functionality to MainActivity.kt..."

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
    
    // Volley request queue for network requests
    private val requestQueue: RequestQueue by lazy {
        Volley.newRequestQueue(this.applicationContext)
    }

    // Weather API configuration
    private val apiKey = BuildConfig.WEATHER_API_KEY
    private val latitude = 39.43  // Lebanon, OH
    private val longitude = -84.21
    private val units = "imperial" // Fahrenheit
    private val pantsTemperatureThreshold = 60.0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        Log.d("WeatherPants", "MainActivity created - starting weather fetch")

        // Check if API key is properly configured
        if (apiKey == "YOUR_API_KEY_HERE" || apiKey == "DEFAULT_KEY_MISSING_OR_PROBLEMATIC") {
            Log.e("WeatherPants", "API Key is missing!")
            binding.messageTextView.text = getString(R.string.api_key_missing)
            Toast.makeText(this, "API Key Missing! Check local.properties", Toast.LENGTH_LONG).show()
            return
        }

        // Show loading state and fetch weather
        binding.messageTextView.text = getString(R.string.loading_weather)
        fetchWeatherData()
    }

    private fun fetchWeatherData() {
        Log.i("WeatherPants", "Fetching weather for Lebanon, OH...")
        
        // Construct OpenWeatherMap API URL
        val apiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=$units"
        Log.d("WeatherPants", "API URL: $apiUrl")

        // Create JSON request
        val jsonObjectRequest = JsonObjectRequest(
            Request.Method.GET, 
            apiUrl, 
            null,
            { response ->
                // Success - parse the weather data
                Log.d("WeatherPants", "Weather API response received")
                handleWeatherResponse(response)
            },
            { error ->
                // Error - show error message
                Log.e("WeatherPants", "Weather API error: ${error.message}", error)
                handleWeatherError(error)
            }
        )

        // Add request to queue
        requestQueue.add(jsonObjectRequest)
    }

    private fun handleWeatherResponse(response: org.json.JSONObject) {
        try {
            // Extract temperature from JSON response
            val main = response.getJSONObject("main")
            val temperature = main.getDouble("temp")
            val weatherArray = response.getJSONArray("weather")
            val weather = weatherArray.getJSONObject(0)
            val description = weather.getString("description")
            
            Log.i("WeatherPants", "Temperature: $temperature°F, Description: $description")
            
            // Format temperature display
            val tempFormat = DecimalFormat("#.#")
            val tempText = "${tempFormat.format(temperature)}°F"
            
            // Determine pants recommendation
            val shouldWearPants = temperature < pantsTemperatureThreshold
            val pantsAdvice = if (shouldWearPants) {
                getString(R.string.wear_pants)
            } else {
                getString(R.string.no_pants)
            }
            
            // Update UI with weather info and pants advice
            val displayText = """
                Lebanon, OH
                
                $tempText
                $description
                
                $pantsAdvice
            """.trimIndent()
            
            binding.messageTextView.text = displayText
            
            Log.i("WeatherPants", "Pants advice: $pantsAdvice (temp: $temperature°F, threshold: $pantsTemperatureThreshold°F)")
            
        } catch (e: JSONException) {
            Log.e("WeatherPants", "Error parsing weather JSON", e)
            showError("Error parsing weather data")
        }
    }
    
    private fun handleWeatherError(error: com.android.volley.VolleyError) {
        val errorMessage = when {
            error.networkResponse?.statusCode == 401 -> "Invalid API key"
            error.networkResponse?.statusCode == 404 -> "Location not found" 
            error.message?.contains("timeout", true) == true -> "Network timeout"
            else -> "Network error: ${error.message ?: "Unknown error"}"
        }
        
        Log.e("WeatherPants", "Weather error: $errorMessage")
        showError(errorMessage)
    }

    private fun showError(message: String) {
        binding.messageTextView.text = """
            ❌ Weather Error
            
            $message
            
            Please check your internet connection and try again.
        """.trimIndent()
        
        Toast.makeText(this, message, Toast.LENGTH_LONG).show()
    }
}
EOF

echo "✓ MainActivity.kt updated with weather functionality"

# Step 2: Ensure layout supports the weather display properly
echo
echo "2. Updating layout for better weather display..."

cat > app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="16dp"
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
        android:layout_marginTop="32dp"
        android:layout_marginBottom="24dp"
        android:contentDescription="Weather Icon" />

    <TextView
        android:id="@+id/messageTextView"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:text="Loading weather..."
        android:textSize="18sp"
        android:textAlignment="center"
        android:lineSpacingExtra="4dp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/weatherIconImageView"
        app:layout_constraintWidth_default="spread" />

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

echo "✓ Layout updated for better weather display"

# Step 3: Build and test the updated app
echo
echo "3. Building updated app with weather functionality..."
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env ./scripts/build_apk.sh

BUILD_EXIT_CODE=$?

echo
echo "======================================================================"
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "🎉 SUCCESS! Weather functionality added successfully!"
    echo
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        echo "✅ Updated APK ready:"
        ls -lh app/build/outputs/apk/debug/app-debug.apk
        echo
        echo "📱 Install the updated app:"
        echo "   adb install -r app/build/outputs/apk/debug/app-debug.apk"
        echo "   (The -r flag reinstalls over the existing app)"
        echo
        echo "🌤️  The app should now:"
        echo "   • Show 'Loading weather...' briefly"
        echo "   • Fetch current weather for Lebanon, OH" 
        echo "   • Display temperature and weather description"
        echo "   • Give pants advice based on 60°F threshold"
        echo "   • Show helpful error messages if something goes wrong"
        echo
        echo "🧪 Test scenarios:"
        echo "   • Install and launch (should fetch weather immediately)"
        echo "   • Try with WiFi off (should show network error)"
        echo "   • Check logcat for debug info: adb logcat | grep WeatherPants"
    fi
else
    echo "❌ Build failed. Error details:"
    docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env /bin/bash -c "
        ./gradlew assembleDebug 2>&1 | tail -20
    "
fi
echo "======================================================================"