/*
 * Copyright (c) 2025. LibreFit
 *
 * This file is part of LibreFit
 *
 * LibreFit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * LibreFit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with LibreFit.  If not, see <https://www.gnu.org/licenses/>.
 */

package org.librefit.ui.screens.about

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ExitToApp
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import org.librefit.R
import org.librefit.ui.components.CustomButton
import org.librefit.ui.components.CustomScaffold
import org.librefit.ui.components.HeadlineText
import org.librefit.ui.components.MarkdownText
import org.librefit.ui.components.bottomMargin
import org.librefit.ui.components.dialogs.UrlActionDialog
import org.librefit.ui.theme.LibreFitTheme

@Composable
fun PrivacyScreen(
    navigateBack: (() -> Unit)? = null
) {

    var privacyPolicyText by rememberSaveable { mutableStateOf("") }

    val context = LocalContext.current

    LaunchedEffect(Unit) {
        privacyPolicyText = context.resources.openRawResource(R.raw.privacy_policy)
            .bufferedReader()
            .use { it.readText() }
    }


    val url = remember { mutableStateOf("") }

    UrlActionDialog(url)

    CustomScaffold(
        title = AnnotatedString(stringResource(id = R.string.privacy)),
        navigateBack = navigateBack,
    ) { innerPadding ->
        // This box is used to constrain width in landscape mode
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.TopCenter
        ) {
            LazyColumn(
                contentPadding = innerPadding,
                modifier = Modifier
                    .widthIn(max = 600.dp)
                    .padding(start = 10.dp, end = 10.dp),
                verticalArrangement = Arrangement.spacedBy(20.dp)
            ) {
                item { HeadlineText(stringResource(R.string.privacy_notice)) }

                item {
                    MarkdownText(
                        stringResource(R.string.privacy_notice_summary)
                                + "\n\n## " + stringResource(R.string.privacy_notice_optional_perm)
                                + "\n\n" + stringResource(R.string.privacy_notice_notification_perm)
                                + "\n\n" + stringResource(R.string.privacy_notice_battery_perm)
                                + "\n\n## " + stringResource(R.string.privacy_notice_default_perm)
                                + "\n\n" + stringResource(R.string.privacy_notice_foreground_perm)
                    )
                }

                item { HeadlineText(stringResource(R.string.privacy_policy)) }

                item {
                    CustomButton(
                        text = stringResource(R.string.view_online_version),
                        icon = Icons.AutoMirrored.Filled.ExitToApp,
                        onClick = {
                            url.value = context.getString(R.string.url_privacy)
                        }
                    )
                }

                item {
                    MarkdownText(privacyPolicyText)
                }

                bottomMargin()
            }
        }
    }

}

@Preview
@Composable
private fun PrivacyScreenPreview() {
    LibreFitTheme(false, true) {
        PrivacyScreen()
    }
}