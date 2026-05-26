package com.example.weatherpants.core.data

import kotlinx.serialization.Serializable

@Serializable
internal data class OpenWeatherResponse(
    val main: MainData,
    val weather: List<WeatherData> = emptyList()
)

@Serializable
internal data class MainData(
    val temp: Double
)

@Serializable
internal data class WeatherData(
    val main: String,
    val description: String
)
