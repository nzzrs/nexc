/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.components

import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import org.nexc.R
import org.nexc.core.enums.userPreferences.ThemeMode
import org.nexc.core.theme.NexcTheme
import kotlin.random.Random

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun NexcButton(
    modifier: Modifier = Modifier,
    text: String,
    icon: Painter? = null,
    iconDescription: String? = null,
    elevated: Boolean = true,
    enabled: Boolean = true,
    interactionSource: MutableInteractionSource? = null,
    onClick: () -> Unit
) {
    val haptic = LocalHapticFeedback.current

    Button(
        modifier = modifier,
        onClick = {
            haptic.performHapticFeedback(HapticFeedbackType.ContextClick)
            onClick()
        },
        colors = if (elevated) ButtonDefaults.buttonColors() else ButtonDefaults.filledTonalButtonColors(),
        enabled = enabled,
        shapes = ButtonDefaults.shapes(),
        interactionSource = interactionSource
    ) {
        Row(
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .padding(5.dp)
        ) {
            if (icon != null) {
                Icon(
                    painter = icon,
                    contentDescription = iconDescription
                )
                Spacer(Modifier.width(ButtonDefaults.IconSpacing))
            }
            Text(
                text = text,
                style = MaterialTheme.typography.labelLargeEmphasized,
                overflow = TextOverflow.Ellipsis,
                maxLines = 1,
            )
        }
    }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Preview
@Composable
private fun NexcButtonPreview() {
    NexcTheme(dynamicColor = false, themeMode = ThemeMode.DARK) {
        NexcButton(
            text = stringResource(R.string.start_routine),
            icon = painterResource(R.drawable.ic_play_arrow),
            elevated = Random.nextBoolean(),
            onClick = {}
        )
    }
}