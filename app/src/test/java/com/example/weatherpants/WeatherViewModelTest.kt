package com.example.weatherpants

import com.example.weatherpants.core.data.WeatherRepository
import com.example.weatherpants.core.model.Location
import com.example.weatherpants.core.model.Weather
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class WeatherViewModelTest {

    private val testDispatcher = StandardTestDispatcher()

    private class FakeWeatherRepository(val result: Result<Weather>) : WeatherRepository {
        override suspend fun fetchWeather(location: Location): Weather {
            return result.getOrThrow()
        }
    }

    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun testViewModelEmitsSuccessState() = runTest(testDispatcher) {
        val expectedWeather = Weather(
            temperature = 72.0,
            condition = "Sunny",
            isPantsWeather = false
        )
        val repository = FakeWeatherRepository(Result.success(expectedWeather))
        val viewModel = WeatherViewModel(repository)
        
        viewModel.fetchWeather(Location(39.43, -84.21, "Lebanon, OH"))
        
        testDispatcher.scheduler.advanceUntilIdle()
        
        val state = viewModel.uiState.value
        assertTrue(state is UiState.Success)
        assertEquals(expectedWeather, (state as UiState.Success).weather)
    }

    @Test
    fun testViewModelEmitsErrorState() = runTest(testDispatcher) {
        val repository = FakeWeatherRepository(Result.failure(Exception("API Error")))
        val viewModel = WeatherViewModel(repository)
        
        viewModel.fetchWeather(Location(39.43, -84.21, "Lebanon, OH"))
        
        testDispatcher.scheduler.advanceUntilIdle()
        
        val state = viewModel.uiState.value
        assertTrue(state is UiState.Error)
        assertEquals("API Error", (state as UiState.Error).message)
    }
}
