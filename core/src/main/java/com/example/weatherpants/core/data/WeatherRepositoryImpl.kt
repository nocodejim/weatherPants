package com.example.weatherpants.core.data

import com.example.weatherpants.core.domain.PantsDecider
import com.example.weatherpants.core.model.Location
import com.example.weatherpants.core.model.Weather
import com.example.weatherpants.core.model.WeatherConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.IOException

class WeatherRepositoryImpl(
    private val apiKey: String,
    private val config: WeatherConfig = WeatherConfig(),
    private val baseUrl: String = "https://api.openweathermap.org/data/2.5/weather"
) : WeatherRepository {

    private val okHttpClient = OkHttpClient()
    private val json = Json { ignoreUnknownKeys = true }

    override suspend fun fetchWeather(location: Location): Weather = withContext(Dispatchers.IO) {
        val url = "$baseUrl?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=${config.units}"
        
        val request = Request.Builder()
            .url(url)
            .build()

        okHttpClient.newCall(request).execute().use { response ->
            if (!response.isSuccessful) {
                throw IOException("Unexpected HTTP response code: ${response.code}")
            }
            val bodyString = response.body?.string() ?: throw IOException("Empty response body")
            val openWeatherResponse = json.decodeFromString<OpenWeatherResponse>(bodyString)
            
            val temp = openWeatherResponse.main.temp
            val condition = openWeatherResponse.weather.firstOrNull()?.main ?: "Unknown"
            val advice = PantsDecider.decide(temp, config.threshold)
            
            Weather(
                temperature = temp,
                condition = condition,
                isPantsWeather = (advice == com.example.weatherpants.core.model.PantsAdvice.WEAR_PANTS)
            )
        }
    }
}
