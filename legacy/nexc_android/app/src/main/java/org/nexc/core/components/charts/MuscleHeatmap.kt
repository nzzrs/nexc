/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.components.charts

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import org.nexc.R
import org.nexc.core.enums.exercise.Muscle
import org.nexc.core.util.Formatter

@Composable
fun MuscleHeatmap(
    muscleVolumeMap: Map<Muscle, Double>,
    modifier: Modifier = Modifier
) {
    val maxVolume = muscleVolumeMap.values.maxOrNull() ?: 1.0
    val frontMuscles = listOf(
        Muscle.ABDOMINALS, Muscle.ADDUCTORS, Muscle.BICEPS, Muscle.CHEST,
        Muscle.QUADRICEPS, Muscle.SHOULDERS, Muscle.NECK, Muscle.FOREARMS, Muscle.TRAPS
    )
    val backMuscles = listOf(
        Muscle.ABDUCTORS, Muscle.CALVES, Muscle.GLUTES, Muscle.HAMSTRINGS,
        Muscle.LATS, Muscle.LOWER_BACK, Muscle.MIDDLE_BACK, Muscle.SHOULDERS,
        Muscle.TRAPS, Muscle.TRICEPS, Muscle.FOREARMS
    )

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            BodySilhouette(
                title = stringResource(R.string.front),
                muscles = frontMuscles,
                muscleVolumeMap = muscleVolumeMap,
                maxVolume = maxVolume,
                bodyRes = R.drawable.hm_body_front
            )
            BodySilhouette(
                title = stringResource(R.string.back),
                muscles = backMuscles,
                muscleVolumeMap = muscleVolumeMap,
                maxVolume = maxVolume,
                bodyRes = R.drawable.hm_body_back
            )
        }
    }
}

@Composable
private fun BodySilhouette(
    title: String,
    muscles: List<Muscle>,
    muscleVolumeMap: Map<Muscle, Double>,
    maxVolume: Double,
    bodyRes: Int
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 8.dp)
        )
        Box(modifier = Modifier.size(200.dp)) {
            // Base Body
            Image(
                painter = painterResource(id = bodyRes),
                contentDescription = null,
                modifier = Modifier.fillMaxSize(),
                colorFilter = ColorFilter.tint(MaterialTheme.colorScheme.surfaceVariant)
            )

            // Muscles
            muscles.forEach { muscle ->
                val volume = muscleVolumeMap[muscle] ?: 0.0
                if (volume > 0) {
                    val intensity = (volume / maxVolume).toFloat().coerceIn(0.1f, 1f)
                    
                    // Heat color interpolation: Yellow -> Orange -> Red
                    val heatColor = when {
                        intensity < 0.5f -> androidx.compose.ui.graphics.lerp(
                            Color(0xFFFFF176), // Light Yellow
                            Color(0xFFFFB74D), // Orange
                            intensity * 2
                        )
                        else -> androidx.compose.ui.graphics.lerp(
                            Color(0xFFFFB74D), // Orange
                            Color(0xFFD32F2F), // Dark Red
                            (intensity - 0.5f) * 2
                        )
                    }
                    
                    Image(
                        painter = painterResource(id = Formatter.muscleToHeatmapVectorId(muscle)),
                        contentDescription = null,
                        modifier = Modifier.fillMaxSize(),
                        colorFilter = ColorFilter.tint(heatColor)
                    )
                }
            }
        }
    }
}
