package com.example.weatherpants

import android.animation.ObjectAnimator
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.example.weatherpants.core.data.WeatherRepository
import com.example.weatherpants.core.data.WeatherRepositoryImpl
import com.example.weatherpants.core.model.Location
import com.example.weatherpants.core.model.Weather
import com.example.weatherpants.databinding.ActivityMainBinding
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import kotlinx.coroutines.launch
import java.text.DecimalFormat

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var viewModel: WeatherViewModel

    private val apiKey = BuildConfig.WEATHER_API_KEY

    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted: Boolean ->
        if (isGranted) {
            getLastKnownLocation()
        } else {
            useFallbackLocation()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        Log.d("WeatherPants", "MainActivity created.")

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        val repository: WeatherRepository = WeatherRepositoryImpl(apiKey = apiKey)
        val factory = WeatherViewModelFactory(repository)
        viewModel = ViewModelProvider(this, factory)[WeatherViewModel::class.java]

        // Setup refresh button click listener
        binding.refreshButton.setOnClickListener {
            checkLocationPermissionAndFetch()
        }

        // Setup lifecycle observer for UI state
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.uiState.collect { state ->
                    renderUiState(state)
                }
            }
        }

        if (apiKey == "YOUR_API_KEY_HERE") {
            Log.e("WeatherPants", "API Key is missing! Please set it in local.properties.")
            binding.messageTextView.text = getString(R.string.api_key_missing)
            Toast.makeText(this, "API Key Missing! Add WEATHER_API_KEY to local.properties", Toast.LENGTH_LONG).show()
            return
        }

        checkLocationPermissionAndFetch()
    }

    private fun checkLocationPermissionAndFetch() {
        when {
            ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.ACCESS_COARSE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED -> {
                getLastKnownLocation()
            }
            else -> {
                requestPermissionLauncher.launch(android.Manifest.permission.ACCESS_COARSE_LOCATION)
            }
        }
    }

    private fun getLastKnownLocation() {
        if (ActivityCompat.checkSelfPermission(
                this,
                android.Manifest.permission.ACCESS_COARSE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            useFallbackLocation()
            return
        }

        fusedLocationClient.lastLocation
            .addOnSuccessListener { location: android.location.Location? ->
                if (location != null) {
                    val loc = Location(
                        latitude = location.latitude,
                        longitude = location.longitude,
                        name = getString(R.string.current_location)
                    )
                    binding.locationTextView.text = loc.name
                    viewModel.fetchWeather(loc)
                } else {
                    useFallbackLocation()
                }
            }
            .addOnFailureListener {
                useFallbackLocation()
            }
    }

    private fun useFallbackLocation() {
        val fallback = Location(
            latitude = 39.43,
            longitude = -84.21,
            name = getString(R.string.location_lebanon)
        )
        binding.locationTextView.text = fallback.name
        viewModel.fetchWeather(fallback)
    }

    private fun renderUiState(state: UiState) {
        when (state) {
            is UiState.Loading -> {
                binding.weatherCard.visibility = View.GONE
                binding.adviceCard.visibility = View.GONE
                binding.refreshButton.visibility = View.GONE
                binding.messageTextView.text = getString(R.string.loading_weather)
                binding.messageTextView.visibility = View.VISIBLE
            }
            is UiState.Success -> {
                binding.messageTextView.visibility = View.GONE
                displayWeatherData(state.weather)
            }
            is UiState.Error -> {
                showError(state.message)
            }
        }
    }

    private fun displayWeatherData(weather: Weather) {
        val tempFormat = DecimalFormat("#.#")
        val tempText = "${tempFormat.format(weather.temperature)}°F"
        binding.temperatureTextView.text = tempText

        if (weather.isPantsWeather) {
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

        // Show cards and button
        binding.weatherCard.visibility = View.VISIBLE
        binding.adviceCard.visibility = View.VISIBLE
        binding.refreshButton.visibility = View.VISIBLE

        showWeatherCardsWithAnimation()
    }

    private fun showWeatherCardsWithAnimation() {
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

        // Animate refresh button
        binding.refreshButton.alpha = 0f
        binding.refreshButton.scaleX = 0f
        binding.refreshButton.scaleY = 0f
        ObjectAnimator.ofFloat(binding.refreshButton, "alpha", 0f, 1f).apply {
            duration = 400
            startDelay = 800
            start()
        }
        ObjectAnimator.ofFloat(binding.refreshButton, "scaleX", 0f, 1f).apply {
            duration = 400
            startDelay = 800
            start()
        }
        ObjectAnimator.ofFloat(binding.refreshButton, "scaleY", 0f, 1f).apply {
            duration = 400
            startDelay = 800
            start()
        }

        // Animate weather icon rotation
        ObjectAnimator.ofFloat(binding.weatherIconImageView, "rotation", 0f, 360f).apply {
            duration = 1000
            startDelay = 400
            start()
        }
    }

    private fun showError(message: String) {
        Log.e("WeatherPants", "Error: $message")
        binding.messageTextView.text = getString(R.string.error_fetching_weather)
        binding.messageTextView.visibility = View.VISIBLE
        binding.weatherCard.visibility = View.GONE
        binding.adviceCard.visibility = View.GONE
        binding.refreshButton.visibility = View.VISIBLE
        Toast.makeText(this, getString(R.string.error_fetching_weather), Toast.LENGTH_SHORT).show()
    }
}
