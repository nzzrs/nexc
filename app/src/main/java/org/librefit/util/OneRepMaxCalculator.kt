/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.util

/**
 * A utility object for calculating an estimated [one-rep max](https://en.wikipedia.org/wiki/One-repetition_maximum) (1RM).
 * It uses a logic-based approach to select the most appropriate formula(s)
 * based on the number of repetitions.
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

    /**
     * Estimates the one-rep max (1RM) using the most accurate formula(s) based on the number of reps.
     *
     * The logic follows scientific literature:
     * - **1 Rep:** The 1RM is the actual weight lifted.
     * - **2-5 Reps:** The Epley formula is used as it's the most commonly cited and validated formula.
     * - **6+ Reps:** Accuracy decreases in this range. To provide a more balanced and conservative estimate,
     *   this function returns an average of the Epley and Brzycki formulas.
     *
     * @param weight The weight lifted (must be a positive value).
     * @param reps The number of repetitions completed (must be a positive integer).
     * @return The estimated one-rep max as a [Double].
     * @throws IllegalArgumentException if weight or reps are negative.
     */
    fun calculate(weight: Double, reps: Int): Double {
        require(weight >= 0 && reps >= 0) { "Weight and reps must be positive values." }


        // If reps is 1, the 1RM is simply the weight lifted.
        if (reps == 1) {
            return weight
        }

        // Choose the best estimation strategy.
        return when (reps) {
            in 2..5 -> {
                // High-accuracy range: Use Epley formula.
                epley(weight, reps)
            }

            else -> {
                // Lower accuracy range: Average the top two formulas for a balanced estimate.
                (epley(weight, reps) + brzycki(weight, reps)) / 2
            }
        }
    }
}