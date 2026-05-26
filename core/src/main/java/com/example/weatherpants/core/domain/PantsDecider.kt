package com.example.weatherpants.core.domain

import com.example.weatherpants.core.model.PantsAdvice

object PantsDecider {
    /**
     * Decides whether to wear pants based on the temperature and a configurable threshold.
     */
    fun decide(
        temperature: Double,
        threshold: Double = 60.0
    ): PantsAdvice {
        return if (temperature < threshold) {
            PantsAdvice.WEAR_PANTS
        } else {
            PantsAdvice.NO_PANTS
        }
    }
}
