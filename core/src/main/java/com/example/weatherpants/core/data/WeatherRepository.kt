package com.example.weatherpants.core.data

import com.example.weatherpants.core.model.Location
import com.example.weatherpants.core.model.Weather

interface WeatherRepository {
    suspend fun fetchWeather(location: Location): Weather
}
