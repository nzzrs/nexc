/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
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
fun EmptyLottie() {
    val composition by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.empty_lottie))

    val progress by animateLottieCompositionAsState(composition)

    val flyColor = MaterialTheme.colorScheme.primary.toArgb()

    // The commented code below is kept because the colors appears visually appealing without any
    // of these adjustments. However, having the layer paths prepared may be useful in future.

    /*
    // Should be dark
    val insideBoxColor = Color.Black.toArgb()

    // Should be light
    val outerBoxColor = Color.LightGray.copy(alpha = 0.1f).toArgb()

    // Should be lighter than left side
    val rightSideColor = Color.LightGray.toArgb()

    // Should be darker than right side
    val leftSideColor = Color.Gray.toArgb()
    */

    val dynamicProperties = rememberLottieDynamicProperties(
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = flyColor,
            keyPath = arrayOf("ruoi", "ruoi", "Group 1", "Fill 1") // Body fly
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.STROKE_COLOR,
            value = flyColor,
            keyPath = arrayOf("ruoi", "ruoi", "Group 2", "Stroke 1") // Wing fly
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.STROKE_COLOR,
            value = flyColor,
            keyPath = arrayOf("ruoi", "ruoi", "Group 3", "Stroke 1") // Wing fly
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.STROKE_COLOR,
            value = flyColor,
            keyPath = arrayOf("Shape Layer 2", "Group 6", "Stroke 1")  // Path fly
        )
        /*
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = insideBoxColor,
            keyPath = arrayOf("im_emptyBox Outlines", "box", "Group 7", "Fill 1")  // Inside box
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = outerBoxColor,
            keyPath = arrayOf("im_emptyBox Outlines", "box", "Group 8", "Fill 1")  // Outer box
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = rightSideColor,
            keyPath = arrayOf("im_emptyBox Outlines", "box", "Group 9", "Fill 1")  // Right side box
        ),
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR,
            value = leftSideColor,
            keyPath = arrayOf("im_emptyBox Outlines", "box", "Group 10", "Fill 1")  // Left side box
        )
         */
    )


    LottieAnimation(
        modifier = Modifier.fillMaxWidth(0.7f),
        composition = composition,
        progress = { progress },
        dynamicProperties = dynamicProperties
    )
}