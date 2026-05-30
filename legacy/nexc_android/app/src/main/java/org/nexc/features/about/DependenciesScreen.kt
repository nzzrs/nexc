/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.features.about

import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.tooling.preview.Preview
import com.mikepenz.aboutlibraries.ui.compose.android.produceLibraries
import com.mikepenz.aboutlibraries.ui.compose.m3.LibrariesContainer
import org.nexc.R
import org.nexc.core.enums.userPreferences.ThemeMode
import org.nexc.core.components.NexcScaffold
import org.nexc.core.components.dialogs.UrlActionDialog
import org.nexc.core.theme.NexcTheme

@Composable
fun DependenciesScreen(navigateBack: () -> Unit) {
    val url = remember { mutableStateOf<String?>(null) }

    url.value?.let {
        UrlActionDialog(it) { url.value = null }
    }

    val libs = produceLibraries(R.raw.aboutlibraries)

    NexcScaffold(
        title = AnnotatedString(stringResource(R.string.dependencies)),
        navigateBack = navigateBack
    ) { innerPadding ->
        LibrariesContainer(
            contentPadding = innerPadding,
            libraries = libs.value,
            showDescription = true,
            onLibraryClick = {
                url.value = it.website ?: ""
            }
        )
    }
}

@Preview
@Composable
private fun LibrariesScreenPreview() {
    NexcTheme(dynamicColor = false, themeMode = ThemeMode.DARK) {
        DependenciesScreen { }
    }
}