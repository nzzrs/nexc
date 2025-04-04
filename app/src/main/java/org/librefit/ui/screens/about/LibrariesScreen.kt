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

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.tooling.preview.Preview
import com.mikepenz.aboutlibraries.ui.compose.m3.LibrariesContainer
import org.librefit.R
import org.librefit.ui.components.CustomScaffold
import org.librefit.ui.theme.LibreFitTheme

@Composable
fun LibrariesScreen(navigateBack: () -> Unit) {
    CustomScaffold(
        title = AnnotatedString(stringResource(R.string.libraries)),
        navigateBack = navigateBack
    ) {
        LibrariesContainer(
            contentPadding = it,
            showDescription = true,
            modifier = Modifier.fillMaxSize()
        )
    }
}

@Preview
@Composable
private fun LibrariesScreenPreview() {
    LibreFitTheme(false, true) {
        LibrariesScreen { }
    }
}