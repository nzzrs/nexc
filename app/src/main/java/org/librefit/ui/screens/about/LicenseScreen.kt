/*
 * Copyright (c) 2024-2025. LibreFit
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
 *
 * LibreFit is subject to additional terms covering author attribution and
 * trademark usage, as found in the accompanying ADDITIONAL_TERMS.md file.
 */

package org.librefit.ui.screens.about

import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalResources
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import org.librefit.R
import org.librefit.ui.components.LibreFitLazyColumn
import org.librefit.ui.components.LibreFitScaffold
import org.librefit.ui.components.MarkdownText
import org.librefit.ui.components.dialogs.UrlActionDialog
import org.librefit.ui.theme.LibreFitTheme

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun LicenseScreen(navigateBack: () -> Unit) {
    val noticeText = rememberSaveable { mutableStateOf("") }
    val licenseText = rememberSaveable { mutableStateOf("") }

    val resources = LocalResources.current

    LaunchedEffect(Unit) {
        licenseText.value = resources.openRawResource(R.raw.license)
            .bufferedReader()
            .use { it.readText() }

        noticeText.value = resources.openRawResource(R.raw.license_notice)
            .bufferedReader()
            .use { it.readText() }
    }


    val url = remember { mutableStateOf<String?>(null) }

    url.value?.let {
        UrlActionDialog(it) { url.value = null }
    }

    LibreFitScaffold(
        title = AnnotatedString(stringResource(id = R.string.license)),
        navigateBack = navigateBack,
    ) { innerPadding ->
        LibreFitLazyColumn(innerPadding) {

            item {
                MarkdownText(noticeText.value)
            }

            item {
                Spacer(Modifier.height(60.dp))
            }

            item {
                MarkdownText(licenseText.value)
            }
        }
    }
}

@Preview
@Composable
private fun LicenseScreenPreview() {
    LibreFitTheme(dynamicColor = false, darkTheme = true) {
        LicenseScreen { }
    }
}