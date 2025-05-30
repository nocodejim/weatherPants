package com.example.weatherpants

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import com.android.volley.Request
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.example.weatherpants.databinding.ActivityMainBinding
import org.json.JSONObject
import java.text.DecimalFormat

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    companion object {
        private const val API_ENDPOINT = "https://api.openweathermap.org/data/2.5/weather"
        private const val CITY_ID = "5160397" // Lebanon, OH
        private const val PANTS_THRESHOLD_F = 60.0
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        fetchWeatherData()
    }

    private fun fetchWeatherData() {
        val apiKey = BuildConfig.WEATHER_API_KEY
        if (apiKey == "DEFAULT_KEY_MISSING_OR_PROBLEMATIC" || apiKey.isEmpty()) {
            binding.temperatureTextView.text = "Error: API Key Missing. Please configure in local.properties."
            Log.w("WeatherPantsLog", "API Key is missing or problematic.")
            return
        }

        val queue = Volley.newRequestQueue(this)
        val url = "$API_ENDPOINT?id=$CITY_ID&appid=$apiKey&units=imperial"

        val stringRequest = StringRequest(
            Request.Method.GET, url,
            { response ->
                Log.d("WeatherPantsLog", "Raw response: $response")
                try {
                    val jsonResponse = JSONObject(response)
                    val temperature = jsonResponse.getJSONObject("main").getDouble("temp")
                    updateUIWithWeather(temperature)
                } catch (e: Exception) {
                    Log.e("WeatherPantsLog", "JSON parsing error", e)
                    binding.temperatureTextView.text = "Error: Failed to parse weather data."
                    binding.messageTextView.text = "Response format might have changed."
                    binding.pantsIconImageView.visibility = View.GONE
                }
            },
            { error ->
                Log.e("WeatherPantsLog", "Volley error: $error")
                binding.temperatureTextView.text = "Error: Failed to fetch weather."
                binding.messageTextView.text = "Please check connection or API key."
                binding.pantsIconImageView.visibility = View.GONE
            })

        queue.add(stringRequest)
    }

    private fun updateUIWithWeather(temperature: Double) {
        val df = DecimalFormat("#.#")
        binding.temperatureTextView.text = "${df.format(temperature)}°F"

        if (temperature <= PANTS_THRESHOLD_F) {
            binding.messageTextView.text = "WeatherPants says: Wear Pants!"
            binding.pantsIconImageView.setImageResource(R.drawable.ic_pants_emoji)
            binding.pantsIconImageView.visibility = View.VISIBLE
        } else {
            binding.messageTextView.text = "WeatherPants says: No Pants!"
            binding.pantsIconImageView.visibility = View.GONE
        }
    }
}
