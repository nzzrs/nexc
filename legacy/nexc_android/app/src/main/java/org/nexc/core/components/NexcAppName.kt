/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 */

package org.nexc.core.components

import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.withStyle
import org.nexc.R

/**
 * It returns the app name with material theme style colored with the primary color.
 */
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun AnnotatedString.Builder.GetAppNameInAnnotatedBuilder(style: TextStyle = MaterialTheme.typography.displaySmallEmphasized) {
    val appName = stringResource(id = R.string.app_name)
    
    withStyle(
        style = style.copy(
            color = MaterialTheme.colorScheme.primary
        ).toSpanStyle()
    ) {
        append(appName)
    }
}

/**
 * It returns the app name as [Text] colored with the primary color and with the [style] provided
 */
@Composable
fun AppNameText(style: TextStyle = LocalTextStyle.current) {
    Text(
        text = buildAnnotatedString {
            GetAppNameInAnnotatedBuilder(style)
        },
        style = style
    )
}