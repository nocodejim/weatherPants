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