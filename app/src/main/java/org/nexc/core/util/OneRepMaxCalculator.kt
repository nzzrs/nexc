/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.util

import org.nexc.core.enums.userPreferences.OneRepMaxFormula
import kotlin.math.exp
import kotlin.math.pow

/**
 * A utility object for calculating an estimated [one-rep max](https://en.wikipedia.org/wiki/One-repetition_maximum) (1RM).
 * It uses several scientifically validated formulas.
 */
object OneRepMaxCalculator {

    /**
     * Calculates the Epley (1985) 1RM estimate.
     * This is one of the most widely validated and used formulas.
     */
    private fun epley(weight: Double, reps: Int): Double {
        return weight * (1 + (reps / 30f))
    }

    /**
     * Calculates the Brzycki (1993) 1RM estimate.
     */
    private fun brzycki(weight: Double, reps: Int): Double {
        return weight * 36 / (37 - reps)
    }

    private fun mcglothin(weight: Double, reps: Int): Double = (100 * weight) / (101.3 - 2.67123 * reps)

    private fun lombardi(weight: Double, reps: Int): Double = weight * reps.toDouble().pow(0.1)

    private fun mayhew(weight: Double, reps: Int): Double = (100 * weight) / (52.2 + (41.9 * exp(-0.055 * reps)))

    private fun oConner(weight: Double, reps: Int): Double = weight * (1 + reps / 40.0)

    private fun wathen(weight: Double, reps: Int): Double = (100 * weight) / (48.8 + (53.8 * exp(-0.075 * reps)))

    /**
     * Estimates the one-rep max (1RM) using the specified formula.
     *
     * @param weight The weight lifted (must be a positive value).
     * @param reps The number of repetitions completed (must be a positive integer).
     * @param formula The [OneRepMaxFormula] to use for the calculation.
     * @return The estimated one-rep max as a [Double].
     */
    fun calculate(weight: Double, reps: Int, formula: OneRepMaxFormula = OneRepMaxFormula.BALANCED): Double {
        require(weight >= 0 && reps >= 0) { "Weight and reps must be positive values." }

        if (reps == 0) return 0.0
        if (reps == 1) return weight

        return when (formula) {
            OneRepMaxFormula.BALANCED -> {
                if (reps in 2..5) epley(weight, reps)
                else (epley(weight, reps) + brzycki(weight, reps)) / 2
            }
            OneRepMaxFormula.EPLEY -> epley(weight, reps)
            OneRepMaxFormula.BRZYCKI -> brzycki(weight, reps)
            OneRepMaxFormula.MCGLOTHIN -> mcglothin(weight, reps)
            OneRepMaxFormula.LOMBARDI -> lombardi(weight, reps)
            OneRepMaxFormula.MAYHEW -> mayhew(weight, reps)
            OneRepMaxFormula.O_CONNER -> oConner(weight, reps)
            OneRepMaxFormula.WATHEN -> wathen(weight, reps)
        }
    }
}