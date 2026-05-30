/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.components.animations

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
import org.nexc.R

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
        modifier = Modifier.fillMaxWidth(),
        composition = composition,
        progress = { progress },
        dynamicProperties = dynamicProperties
    )
}