package com.example.weatherpants.automotive

import android.content.pm.PackageManager
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.Action
import androidx.car.app.model.Pane
import androidx.car.app.model.PaneTemplate
import androidx.car.app.model.Row
import androidx.car.app.model.Template
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.example.weatherpants.core.data.WeatherRepository
import com.example.weatherpants.core.data.WeatherRepositoryImpl
import com.example.weatherpants.core.model.Location
import com.example.weatherpants.core.model.Weather
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import kotlinx.coroutines.launch
import java.text.DecimalFormat

class WeatherCarScreen(carContext: CarContext) : Screen(carContext) {

    private val repository: WeatherRepository = WeatherRepositoryImpl(apiKey = BuildConfig.WEATHER_API_KEY)
    private val fusedLocationClient: FusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(carContext)

    private var isLoading = true
    private var weather: Weather? = null
    private var errorMessage: String? = null
    private var locationName = carContext.getString(R.string.loading_weather)

    init {
        fetchLocationAndWeather()
    }

    private fun fetchLocationAndWeather() {
        isLoading = true
        weather = null
        errorMessage = null
        invalidate()

        if (ContextCompat.checkSelfPermission(
                carContext,
                android.Manifest.permission.ACCESS_COARSE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            fusedLocationClient.lastLocation
                .addOnSuccessListener { location: android.location.Location? ->
                    if (location != null) {
                        val loc = Location(
                            latitude = location.latitude,
                            longitude = location.longitude,
                            name = carContext.getString(R.string.current_location)
                        )
                        locationName = loc.name
                        loadWeather(loc)
                    } else {
                        useFallback()
                    }
                }
                .addOnFailureListener {
                    useFallback()
                }
        } else {
            useFallback()
        }
    }

    private fun useFallback() {
        val fallback = Location(
            latitude = 39.43,
            longitude = -84.21,
            name = carContext.getString(R.string.location_lebanon)
        )
        locationName = fallback.name
        loadWeather(fallback)
    }

    private fun loadWeather(location: Location) {
        lifecycleScope.launch {
            try {
                weather = repository.fetchWeather(location)
                isLoading = false
                errorMessage = null
            } catch (e: Exception) {
                isLoading = false
                errorMessage = e.message ?: "Unknown error"
            }
            invalidate()
        }
    }

    override fun onGetTemplate(): Template {
        if (isLoading) {
            val pane = Pane.Builder()
                .setLoading(true)
                .build()
            return PaneTemplate.Builder(pane)
                .setHeaderAction(Action.APP_ICON)
                .setTitle(locationName)
                .build()
        }

        val err = errorMessage
        if (err != null) {
            val pane = Pane.Builder()
                .addRow(
                    Row.Builder()
                        .setTitle(carContext.getString(R.string.error_fetching_weather))
                        .addText(err)
                        .build()
                )
                .addAction(
                    Action.Builder()
                        .setTitle(carContext.getString(R.string.refresh_weather))
                        .setOnClickListener { fetchLocationAndWeather() }
                        .build()
                )
                .build()
            return PaneTemplate.Builder(pane)
                .setHeaderAction(Action.APP_ICON)
                .setTitle(locationName)
                .build()
        }

        val w = weather
        if (w != null) {
            val tempFormat = DecimalFormat("#.#")
            val tempText = "${tempFormat.format(w.temperature)}°F"
            
            val pantsVerdict = if (w.isPantsWeather) {
                carContext.getString(R.string.wear_pants)
            } else {
                carContext.getString(R.string.no_pants)
            }

            val pane = Pane.Builder()
                .addRow(
                    Row.Builder()
                        .setTitle("Temperature & Condition")
                        .addText("$tempText — ${w.condition}")
                        .build()
                )
                .addRow(
                    Row.Builder()
                        .setTitle("Pants Verdict")
                        .addText(pantsVerdict)
                        .build()
                )
                .addAction(
                    Action.Builder()
                        .setTitle(carContext.getString(R.string.refresh_weather))
                        .setOnClickListener { fetchLocationAndWeather() }
                        .build()
                )
                .build()

            return PaneTemplate.Builder(pane)
                .setHeaderAction(Action.APP_ICON)
                .setTitle(locationName)
                .build()
        }

        val emptyPane = Pane.Builder()
            .addRow(Row.Builder().setTitle("No data").build())
            .build()
        return PaneTemplate.Builder(emptyPane).setTitle("WeatherPants").build()
    }
}
