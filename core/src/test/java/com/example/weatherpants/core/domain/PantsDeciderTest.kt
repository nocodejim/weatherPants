package com.example.weatherpants.core.domain

import com.example.weatherpants.core.model.PantsAdvice
import org.junit.Assert.assertEquals
import org.junit.Test

class PantsDeciderTest {

    @Test
    fun testPantsDecisionBoundary() {
        // Below threshold (59.9) -> WEAR_PANTS
        assertEquals(PantsAdvice.WEAR_PANTS, PantsDecider.decide(59.9, threshold = 60.0))
        
        // Exactly threshold -> NO_PANTS
        assertEquals(PantsAdvice.NO_PANTS, PantsDecider.decide(60.0, threshold = 60.0))
        
        // Above threshold -> NO_PANTS
        assertEquals(PantsAdvice.NO_PANTS, PantsDecider.decide(60.1, threshold = 60.0))
    }

    @Test
    fun testCustomThreshold() {
        assertEquals(PantsAdvice.WEAR_PANTS, PantsDecider.decide(49.9, threshold = 50.0))
        assertEquals(PantsAdvice.NO_PANTS, PantsDecider.decide(50.0, threshold = 50.0))
        assertEquals(PantsAdvice.NO_PANTS, PantsDecider.decide(55.0, threshold = 50.0))
    }
}
