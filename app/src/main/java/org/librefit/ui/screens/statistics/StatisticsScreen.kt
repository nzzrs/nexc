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

package org.librefit.ui.screens.statistics

import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.rememberNavController
import org.librefit.R
import org.librefit.ui.components.HeadlineText
import org.librefit.ui.components.LibreFitLazyColumn
import org.librefit.ui.components.LibreFitScaffold
import org.librefit.ui.components.charts.LibreFitCartesianChart
import org.librefit.ui.theme.LibreFitTheme

@Composable
fun StatisticsScreen(
    navController: NavHostController
) {
    val viewModel: StatisticsScreenViewModel = hiltViewModel()

    StatisticsScreenContent(
        navController = navController
    )
}

@Composable
private fun StatisticsScreenContent(
    navController: NavHostController
) {
    LibreFitScaffold(
        title = AnnotatedString(stringResource(R.string.statistics)),
        navigateBack = navController::popBackStack
    ) { innerPadding ->
        LibreFitLazyColumn(innerPadding = innerPadding) {
            item {
                HeadlineText(stringResource(R.string.overview))
            }
            item {
                LibreFitCartesianChart(
                    points = emptyList(),

                    )
            }
        }
    }
}

@Preview
@Composable
fun StatisticsScreenPreview() {
    LibreFitTheme(dynamicColor = false, darkTheme = true) {
        StatisticsScreenContent(
            navController = rememberNavController()
        )
    }
}