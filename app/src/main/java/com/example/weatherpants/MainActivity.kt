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

        // Simple test message
        binding.messageTextView.text = "Simple MainActivity Test - Working!"
    }
}
