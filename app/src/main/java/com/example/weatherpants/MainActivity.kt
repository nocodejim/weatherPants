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
