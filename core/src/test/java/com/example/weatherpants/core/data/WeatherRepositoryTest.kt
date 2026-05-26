package com.example.weatherpants.core.data

import com.example.weatherpants.core.model.Location
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Assume.assumeTrue
import org.junit.Before
import org.junit.Test
import java.io.File
import java.util.Properties

class WeatherRepositoryTest {

    private var apiKey: String? = null

    @Before
    fun setUp() {
        val properties = Properties()
        val possibleFiles = listOf(
            File("local.properties"),
            File("../local.properties"),
            File("../../local.properties")
        )
        val localPropertiesFile = possibleFiles.firstOrNull { it.exists() }
        if (localPropertiesFile != null) {
            localPropertiesFile.inputStream().use { properties.load(it) }
            apiKey = properties.getProperty("WEATHER_API_KEY")?.trim('"')
        }
        
        if (apiKey.isNullOrEmpty()) {
            apiKey = System.getenv("WEATHER_API_KEY")
        }
    }

    @Test
    fun testRealFetchWeather() = runBlocking {
        // Skip if API key is not set or using placeholder
        val isKeyValid = !apiKey.isNullOrEmpty() && apiKey != "YOUR_API_KEY_HERE" && apiKey != "YOUR_ACTUAL_SECRET_API_KEY_FROM_OPENWEATHERMAP"
        assumeTrue("API Key is missing, skipping integration test", isKeyValid)

        val repository = WeatherRepositoryImpl(apiKey = apiKey!!)
        val lebanon = Location(latitude = 39.43, longitude = -84.21, name = "Lebanon, OH")
        
        val weather = repository.fetchWeather(lebanon)
        
        assertNotNull(weather)
        println("Fetched temperature: ${weather.temperature}, condition: ${weather.condition}, isPantsWeather: ${weather.isPantsWeather}")
        
        // Assert temperature is in a realistic range
        assertTrue("Temperature ${weather.temperature} out of bounds", weather.temperature > -100.0 && weather.temperature < 150.0)
    }
}
