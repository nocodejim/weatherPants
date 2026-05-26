package com.example.weatherpants

import com.example.weatherpants.core.model.Weather

sealed class UiState {
    object Loading : UiState()
    data class Success(val weather: Weather) : UiState()
    data class Error(val message: String) : UiState()
}
