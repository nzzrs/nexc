/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.ui.components.animations

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.unit.dp
import com.airbnb.lottie.LottieProperty
import com.airbnb.lottie.compose.LottieAnimation
import com.airbnb.lottie.compose.LottieCompositionSpec
import com.airbnb.lottie.compose.animateLottieCompositionAsState
import com.airbnb.lottie.compose.rememberLottieComposition
import com.airbnb.lottie.compose.rememberLottieDynamicProperties
import com.airbnb.lottie.compose.rememberLottieDynamicProperty
import org.librefit.R

@Composable
fun TrainingLottie() {
    val color = MaterialTheme.colorScheme.primary.toArgb()

    val composition by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.personal_training_lottie))

    val progress by animateLottieCompositionAsState(composition)

    val dynamicProperties = rememberLottieDynamicProperties(
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 2 Outlines", "Group 2", "Fill 1") // Path layer
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 2 Outlines", "Group 7", "Fill 1") // Path layer
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 6 Outlines", "Group 2", "Fill 1") // Path layer
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 6 Outlines", "Group 3", "Fill 1") // Path layer
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 6 Outlines", "Group 4", "Fill 1") // Path layer
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 5 Outlines", "Group 2", "Fill 1") // Path layer
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 5 Outlines", "Group 3", "Fill 1") // Path layer
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 5 Outlines", "Group 4", "Fill 1") // Path layer
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 4 Outlines", "Group 1", "Fill 1") // Path layer
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 7 Outlines", "Group 1", "Fill 1") // Path layer
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 7 Outlines", "Group 2", "Fill 1") // Path layer
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = color,
            keyPath = arrayOf("Layer 7 Outlines", "Group 3", "Fill 1") // Path layer
        )
    )
    LottieAnimation(
        modifier = Modifier
            .fillMaxWidth(0.9f)
            .padding(20.dp),
        composition = composition,
        progress = { progress },
        dynamicProperties = dynamicProperties
    )
}