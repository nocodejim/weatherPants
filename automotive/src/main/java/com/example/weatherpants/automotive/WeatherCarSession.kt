package com.example.weatherpants.automotive

import android.content.Intent
import androidx.car.app.Session
import androidx.car.app.Screen

class WeatherCarSession : Session() {
    override fun onCreateScreen(intent: Intent): Screen {
        return WeatherCarScreen(carContext)
    }
}
