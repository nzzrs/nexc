/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.components.animations

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import com.airbnb.lottie.compose.LottieAnimation
import com.airbnb.lottie.compose.LottieCompositionSpec
import com.airbnb.lottie.compose.animateLottieCompositionAsState
import com.airbnb.lottie.compose.rememberLottieComposition
import org.nexc.R

@Composable
fun CongratsLottie() {
    val composition by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.congratulations))

    val progress by animateLottieCompositionAsState(
        composition = composition,
        speed = 0.4f
    )

    LottieAnimation(
        modifier = Modifier.fillMaxWidth(),
        composition = composition,
        progress = { progress }
    )
}