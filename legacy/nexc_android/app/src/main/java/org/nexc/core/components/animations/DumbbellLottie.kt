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
fun DumbbellLottie() {
    val color = MaterialTheme.colorScheme.primary.toArgb()

    val composition by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.dumbbell_lottie))

    val progress by animateLottieCompositionAsState(
        composition = composition,
        speed = 2f
    )

    val dynamicProperties = rememberLottieDynamicProperties(
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR, value = color,
            // Path matching everything with the name "Fill 1"
            keyPath = arrayOf("**", "Fill 1")
        )
    )
    LottieAnimation(
        modifier = Modifier.fillMaxWidth(0.5f),
        composition = composition,
        progress = { progress },
        dynamicProperties = dynamicProperties
    )
}