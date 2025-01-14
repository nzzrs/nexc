/*
 * Copyright (c) 2024-2025. LibreFit
 *
 * This file is part of LibreFit
 *
 * LibreFit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * LibreFit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with LibreFit.  If not, see <https://www.gnu.org/licenses/>.
 */

package org.librefit.ui.components.animations

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.toArgb
import com.airbnb.lottie.LottieProperty
import com.airbnb.lottie.compose.LottieAnimation
import com.airbnb.lottie.compose.LottieCompositionSpec
import com.airbnb.lottie.compose.animateLottieCompositionAsState
import com.airbnb.lottie.compose.rememberLottieComposition
import com.airbnb.lottie.compose.rememberLottieDynamicProperties
import com.airbnb.lottie.compose.rememberLottieDynamicProperty
import org.librefit.R

@Composable
fun StatsLottie() {
    val color = MaterialTheme.colorScheme.primary.toArgb()

    val composition by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.stats_lottie))

    val progress by animateLottieCompositionAsState(composition)

    val dynamicProperties = rememberLottieDynamicProperties(
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 2 Outlines", "Group 1", "Fill 1") // First dot
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 4 Outlines", "Group 1", "Fill 1") // Second dot
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 3 Outlines", "Group 1", "Fill 1") // Third dot
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 5 Outlines", "Group 1", "Fill 1") // Fourth dot
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 14 Outlines", "Group 1", "Fill 1") // Fifth line
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.STROKE_COLOR,
            value = color,
            keyPath = arrayOf("Layer 12 Outlines 6", "Group 1", "Stroke 1") // Fourth line
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.STROKE_COLOR,
            value = color,
            keyPath = arrayOf("Layer 12 Outlines 5", "Group 1", "Stroke 1") // Third line
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.STROKE_COLOR,
            value = color,
            keyPath = arrayOf("Layer 12 Outlines 2", "Group 1", "Stroke 1") // Second line
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.STROKE_COLOR,
            value = color,
            keyPath = arrayOf("Layer 12 Outlines", "Group 1", "Stroke 1") // First line
        )
    )
    LottieAnimation(
        modifier = Modifier.fillMaxWidth(0.9f),
        composition = composition,
        progress = { progress },
        dynamicProperties = dynamicProperties
    )
}