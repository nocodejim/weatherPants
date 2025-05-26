package com.example.weatherpants

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.example.weatherpants.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Simple initial message
        binding.messageTextView.text = "Welcome to WeatherPants!\n\nBasic app is working!"
    }
}
