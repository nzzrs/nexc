/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
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
import com.airbnb.lottie.compose.LottieConstants
import com.airbnb.lottie.compose.animateLottieCompositionAsState
import com.airbnb.lottie.compose.rememberLottieComposition
import com.airbnb.lottie.compose.rememberLottieDynamicProperties
import com.airbnb.lottie.compose.rememberLottieDynamicProperty
import org.nexc.R

@Composable
fun StreakLottie(streak: Int) {
    val primaryColor = MaterialTheme.colorScheme.primary
        .copy(alpha = 0.5f + 0.5f * (streak / 52f))
        .toArgb()

    val inversePrimaryColor = MaterialTheme.colorScheme.inversePrimary.toArgb()

    val composition by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.streak_lottie))

    val progress by animateLottieCompositionAsState(
        composition = composition,
        isPlaying = streak != 0,
        speed = (streak / 26f).coerceIn(0.05f, 2f),
        iterations = LottieConstants.IterateForever
    )

    val dynamicProperties = rememberLottieDynamicProperties(
        rememberLottieDynamicProperty(
            property = LottieProperty.GRADIENT_COLOR,
            value = arrayOf(primaryColor, primaryColor, inversePrimaryColor),
            keyPath = arrayOf("Shape Layer 1", "Shape 1", "Gradient Fill 1")
        )
    )
    LottieAnimation(
        modifier = Modifier.fillMaxWidth(),
        composition = composition,
        progress = { progress },
        dynamicProperties = dynamicProperties
    )
}