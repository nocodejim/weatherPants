package com.example.weatherpants

import android.content.Context
import android.os.Bundle
import android.widget.SeekBar
import androidx.appcompat.app.AppCompatActivity
import com.example.weatherpants.databinding.ActivitySettingsBinding

class SettingsActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySettingsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySettingsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val sharedPreferences = getSharedPreferences("WeatherPantsPrefs", Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()

        // Load the saved threshold, default to 60
        val savedThreshold = sharedPreferences.getInt("pantsThreshold", 60)
        binding.temperatureSeekBar.progress = savedThreshold
        binding.temperatureValue.text = "${savedThreshold}°F"

        binding.temperatureSeekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                binding.temperatureValue.text = "${progress}°F"
            }

            override fun onStartTrackingTouch(seekBar: SeekBar?) {
                // Not needed
            }

            override fun onStopTrackingTouch(seekBar: SeekBar?) {
                seekBar?.let {
                    editor.putInt("pantsThreshold", it.progress)
                    editor.apply()
                }
            }
        })
    }
}