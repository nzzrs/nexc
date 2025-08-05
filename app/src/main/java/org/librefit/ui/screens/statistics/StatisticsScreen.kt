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
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.rememberNavController
import org.librefit.R
import org.librefit.enums.chart.StatisticsChart
import org.librefit.ui.components.HeadlineText
import org.librefit.ui.components.LibreFitLazyColumn
import org.librefit.ui.components.LibreFitScaffold
import org.librefit.ui.components.charts.LibreFitCartesianChart
import org.librefit.ui.components.charts.Point
import org.librefit.ui.theme.LibreFitTheme
import java.text.DecimalFormat

@Composable
fun StatisticsScreen(
    navController: NavHostController
) {
    val viewModel: StatisticsScreenViewModel = hiltViewModel()

    val points by viewModel.points.collectAsState()

    val legend by viewModel.legendIds.collectAsState()

    val statisticsChart by viewModel.statisticsChart.collectAsState()

    StatisticsScreenContent(
        navController = navController,
        points = points,
        legend = legend,
        statisticsChart = statisticsChart,
        updateStatisticsChart = viewModel::updateStatisticsChart
    )
}

@Composable
private fun StatisticsScreenContent(
    navController: NavHostController,
    points: List<Point>,
    legend: List<Pair<Int, Long?>>,
    statisticsChart: StatisticsChart,
    updateStatisticsChart: (StatisticsChart) -> Unit
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
                    format = when (statisticsChart) {
                        StatisticsChart.LOAD -> DecimalFormat("#.## " + stringResource(R.string.kg))
                        StatisticsChart.REPS -> DecimalFormat()
                        StatisticsChart.VOLUME -> DecimalFormat("#.## " + stringResource(R.string.kg))
                        StatisticsChart.DURATION -> DecimalFormat("# " + stringResource(R.string.min))
                    },
                    points = points,
                    legendList = legend.map { pair ->
                        stringResource(pair.first) + if (pair.second != null) {
                            ": " + pair.second
                        } else ""
                    },
                    chartMode = statisticsChart,
                    useColumns = true,
                    updateChartMode = { updateStatisticsChart(it as StatisticsChart) }
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
            navController = rememberNavController(),
            statisticsChart = StatisticsChart.LOAD,
            points = emptyList(),
            legend = emptyList(),
            updateStatisticsChart = {},
        )
    }
}