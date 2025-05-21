package com.example.weatherpants

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.example.weatherpants.databinding.ActivityMainBinding // Assuming view binding and activity_main.xml

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Initially, set a simple text.
        // Later, this will be updated with weather data or an error message.
        binding.messageTextView.text = "Welcome to WeatherPants!"
    }
}
