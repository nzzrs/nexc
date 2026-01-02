/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import org.librefit.R
import org.librefit.enums.InfoMode
import org.librefit.enums.userPreferences.ThemeMode
import org.librefit.ui.components.modalBottomSheets.InfoModalBottomSheet
import org.librefit.ui.theme.LibreFitTheme

/**
 * Displays a headline text with an optional information button.
 *
 * @param text The headline text to display.
 * @param infoMode If non-null, the  information is used by the [IconButton] when clicked
 * to open [InfoModalBottomSheet]
 */
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun HeadlineText(
    text: String,
    infoMode: InfoMode? = null
) {
    var localInfoMode by remember { mutableStateOf(InfoMode.DISMISS) }

    InfoModalBottomSheet(localInfoMode) { localInfoMode = InfoMode.DISMISS }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 20.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center
    ) {
        Text(
            modifier = Modifier.weight(1f, false),
            text = text,
            style = MaterialTheme.typography.headlineSmallEmphasized,
            color = MaterialTheme.colorScheme.primary,
            textAlign = TextAlign.Center,
        )
        if (infoMode != null) {
            IconButton(
                onClick = { localInfoMode = infoMode }
            ) {
                Icon(
                    painter = painterResource(R.drawable.ic_info),
                    contentDescription = stringResource(R.string.info)
                )
            }
        }

    }
}

@Preview
@Composable
private fun HeadlineTextPreview() {
    LibreFitTheme(dynamicColor = false, themeMode = ThemeMode.DARK) {
        LibreFitScaffold(title = AnnotatedString("HeadlineText showcase")) { innerPadding ->
            LazyColumn(
                contentPadding = innerPadding,
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                item {
                    HeadlineText(
                        "Headline",
                        InfoMode.entries.filter { it != InfoMode.DISMISS }.randomOrNull()
                    )
                }

                item {
                    HeadlineText(
                        "Very long long log headline",
                        InfoMode.entries.filter { it != InfoMode.DISMISS }.randomOrNull()
                    )
                }

                items((1..10).map { "Item $it" }) {
                    Card(Modifier.fillMaxWidth()) {
                        Text(it, Modifier.padding(15.dp))
                    }
                }
            }
        }
    }
}