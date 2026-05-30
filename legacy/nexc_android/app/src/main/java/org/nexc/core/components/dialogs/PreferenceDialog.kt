/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.components.dialogs

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import org.nexc.R
import org.nexc.core.enums.userPreferences.DialogPreference
import org.nexc.core.enums.userPreferences.Language
import org.nexc.core.enums.userPreferences.OneRepMaxFormula
import org.nexc.core.enums.userPreferences.ThemeMode
import org.nexc.core.util.Formatter

@Composable
fun PreferenceDialog(
    currentPreference: DialogPreference?,
    preferences: List<DialogPreference>,
    updatePreference: (DialogPreference) -> Unit,
    onDismiss: () -> Unit,
) {
    require(preferences.isNotEmpty()) { "Preferences must be not empty" }

    AlertDialog(
        title = {
            Text(
                text = stringResource(
                    when (preferences.first()) {
                        is Language -> R.string.language
                        is ThemeMode -> R.string.theme
                        is OneRepMaxFormula -> R.string.one_rep_max_formula
                        is org.nexc.core.enums.userPreferences.IntensityScale -> R.string.intensity_scale
                    }
                )
            )
        },
        icon = {
            Icon(
                painter = painterResource(
                    when (preferences.first()) {
                        is Language -> R.drawable.ic_translate
                        is ThemeMode -> R.drawable.ic_dark_mode
                        is OneRepMaxFormula -> R.drawable.ic_info
                        is org.nexc.core.enums.userPreferences.IntensityScale -> R.drawable.ic_logo_minimal
                    }
                ),
                contentDescription = null
            )
        },
        onDismissRequest = onDismiss,
        confirmButton = { /*The user doesn't need to confirm*/ },
        text = {
            LazyColumn(Modifier.heightIn(max = 300.dp)) {
                items(preferences, key = { it }) { preference ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(MaterialTheme.shapes.large)
                            .padding(5.dp)
                            .clickable {
                                onDismiss()
                                updatePreference(preference)
                            },
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = preference == currentPreference,
                            onClick = {
                                onDismiss()
                                updatePreference(preference)
                            }
                        )
                        Spacer(Modifier.width(10.dp))
                        Text(stringResource(Formatter.preferenceToStringId(preference)))
                    }
                }
            }
        }
    )
}