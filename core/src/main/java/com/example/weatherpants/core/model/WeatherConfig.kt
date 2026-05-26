package com.example.weatherpants.core.model

data class WeatherConfig(
    val threshold: Double = 60.0,
    val units: String = "imperial"
)
