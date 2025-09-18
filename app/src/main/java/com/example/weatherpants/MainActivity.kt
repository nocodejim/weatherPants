package com.example.weatherpants

import android.animation.ObjectAnimator
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
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

        // Initially hide the weather cards and show loading
        binding.weatherCard.visibility = View.GONE
        binding.adviceCard.visibility = View.GONE
        binding.messageTextView.visibility = View.VISIBLE

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

        // Update UI with weather data
        binding.temperatureTextView.text = tempText
        
        if (shouldWearPants) {
            // Cold weather styling
            binding.rootLayout.background = ContextCompat.getDrawable(this, R.drawable.bg_gradient_cool)
            binding.weatherIconImageView.setImageResource(R.drawable.ic_weather_cold)
            binding.pantsIconImageView.setImageResource(R.drawable.ic_pants_modern)
            binding.adviceTextView.text = getString(R.string.wear_pants)
            binding.adviceTextView.setTextColor(ContextCompat.getColor(this, R.color.cool_gradient_start))
        } else {
            // Warm weather styling
            binding.rootLayout.background = ContextCompat.getDrawable(this, R.drawable.bg_gradient_warm)
            binding.weatherIconImageView.setImageResource(R.drawable.ic_weather_sunny)
            binding.pantsIconImageView.setImageResource(R.drawable.ic_no_pants)
            binding.adviceTextView.text = getString(R.string.no_pants)
            binding.adviceTextView.setTextColor(ContextCompat.getColor(this, R.color.warm_gradient_start))
        }

        // Hide loading message and show weather cards with animation
        binding.messageTextView.visibility = View.GONE
        showWeatherCardsWithAnimation()
        
        Log.i("WeatherPants", "Temperature: $temperature, Wear pants: $shouldWearPants")
    }

    private fun showWeatherCardsWithAnimation() {
        // Show cards
        binding.weatherCard.visibility = View.VISIBLE
        binding.adviceCard.visibility = View.VISIBLE

        // Animate weather card
        binding.weatherCard.alpha = 0f
        binding.weatherCard.translationY = 100f
        ObjectAnimator.ofFloat(binding.weatherCard, "alpha", 0f, 1f).apply {
            duration = 600
            start()
        }
        ObjectAnimator.ofFloat(binding.weatherCard, "translationY", 100f, 0f).apply {
            duration = 600
            start()
        }

        // Animate advice card with slight delay
        binding.adviceCard.alpha = 0f
        binding.adviceCard.translationY = 100f
        ObjectAnimator.ofFloat(binding.adviceCard, "alpha", 0f, 1f).apply {
            duration = 600
            startDelay = 200
            start()
        }
        ObjectAnimator.ofFloat(binding.adviceCard, "translationY", 100f, 0f).apply {
            duration = 600
            startDelay = 200
            start()
        }

        // Animate weather icon rotation
        ObjectAnimator.ofFloat(binding.weatherIconImageView, "rotation", 0f, 360f).apply {
            duration = 1000
            startDelay = 400
            start()
        }
    }

    private fun showError() {
        binding.messageTextView.text = getString(R.string.error_fetching_weather)
        binding.messageTextView.visibility = View.VISIBLE
        binding.weatherCard.visibility = View.GONE
        binding.adviceCard.visibility = View.GONE
        Toast.makeText(this, getString(R.string.error_fetching_weather), Toast.LENGTH_SHORT).show()
    }
}
