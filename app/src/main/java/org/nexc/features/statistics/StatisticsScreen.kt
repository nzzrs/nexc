/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.features.statistics

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavHostController
import androidx.navigation.compose.rememberNavController
import org.nexc.R
import org.nexc.core.enums.InfoMode
import org.nexc.core.enums.chart.StatisticsChart
import org.nexc.core.enums.exercise.Muscle
import org.nexc.core.enums.userPreferences.ThemeMode
import org.nexc.core.components.HeadlineText
import org.nexc.core.components.NexcLazyColumn
import org.nexc.core.components.NexcScaffold
import org.nexc.core.components.charts.MuscleHeatmap
import org.nexc.core.components.charts.NexcCartesianChart
import org.nexc.core.components.charts.Point
import org.nexc.core.theme.NexcTheme
import org.nexc.core.util.Formatter
import kotlin.random.Random

@Composable
fun StatisticsScreen(
    navController: NavHostController
) {
    val viewModel: StatisticsScreenViewModel = hiltViewModel()

    val muscleDistributionPoints by viewModel.muscleDistributionPoints.collectAsStateWithLifecycle()

    val muscleDistributionLegendIds by viewModel.muscleDistributionLegendIds.collectAsStateWithLifecycle()

    val muscleDistributionStatisticsChart by viewModel.muscleDistributionStatisticsChart.collectAsStateWithLifecycle()

    val exercisesDistributionPoints by viewModel.exercisesDistributionPoints.collectAsStateWithLifecycle()

    val exercisesDistributionLegendIds by viewModel.exercisesDistributionLegendIds.collectAsStateWithLifecycle()

    val exercisesDistributionStatisticsChart by viewModel.exercisesDistributionStatisticsChart.collectAsStateWithLifecycle()

    val muscleHeatmapData by viewModel.muscleHeatmapData.collectAsStateWithLifecycle()

    StatisticsScreenContent(
        navController = navController,
        muscleDistributionPoints = muscleDistributionPoints,
        muscleDistributionLegendIds = muscleDistributionLegendIds,
        muscleDistributionStatisticsChart = muscleDistributionStatisticsChart,
        exercisesDistributionPoints = exercisesDistributionPoints,
        exercisesDistributionLegendIds = exercisesDistributionLegendIds,
        exercisesDistributionStatisticsChart = exercisesDistributionStatisticsChart,
        muscleHeatmapData = muscleHeatmapData,
        updateMuscleDistributionStatisticsChart = viewModel::updateMuscleDistributionStatisticsChart,
        updateExercisesDistributionStatisticsChart = viewModel::updateExercisesDistributionStatisticsChart,
    )
}

@Composable
private fun StatisticsScreenContent(
    navController: NavHostController,
    muscleDistributionPoints: List<Point>,
    muscleDistributionLegendIds: List<Pair<Int, Long?>>,
    muscleDistributionStatisticsChart: StatisticsChart,
    exercisesDistributionPoints: List<Point>,
    exercisesDistributionLegendIds: List<Pair<Int, Long?>>,
    exercisesDistributionStatisticsChart: StatisticsChart,
    muscleHeatmapData: Map<Muscle, Double>,
    updateMuscleDistributionStatisticsChart: (StatisticsChart) -> Unit,
    updateExercisesDistributionStatisticsChart: (StatisticsChart) -> Unit
) {
    NexcScaffold(
        title = AnnotatedString(stringResource(R.string.statistics)),
        navigateBack = navController::navigateUp
    ) { innerPadding ->
        NexcLazyColumn(innerPadding = innerPadding) {
            item {
                HeadlineText(
                    stringResource(R.string.muscles_distribution),
                    InfoMode.MUSCLE_DISTRIBUTION
                )
            }
            item {
                NexcCartesianChart(
                    decimalCount = when (exercisesDistributionStatisticsChart) {
                        StatisticsChart.DURATION -> 0
                        else -> 2
                    },
                    suffix = when (exercisesDistributionStatisticsChart) {
                        StatisticsChart.LOAD -> stringResource(R.string.kg)
                        StatisticsChart.REPS -> null
                        StatisticsChart.VOLUME -> stringResource(R.string.kg)
                        StatisticsChart.DURATION -> stringResource(R.string.min)
                    },
                    points = muscleDistributionPoints,
                    legendList = muscleDistributionLegendIds.map { pair ->
                        stringResource(pair.first) + if (pair.second != null) {
                            ": " + pair.second
                        } else ""
                    },
                    chartModes = StatisticsChart.entries,
                    chartMode = muscleDistributionStatisticsChart,
                    useColumns = true,
                    updateChartMode = updateMuscleDistributionStatisticsChart
                )
            }

            item {
                HeadlineText(
                    stringResource(R.string.muscle_heatmap),
                    InfoMode.MUSCLE_DISTRIBUTION
                )
            }

            item {
                MuscleHeatmap(muscleVolumeMap = muscleHeatmapData)
            }

            item {
                HeadlineText(
                    stringResource(R.string.exercises_distribution),
                    InfoMode.EXERCISES_DISTRIBUTION
                )
            }
            item {
                NexcCartesianChart(
                    decimalCount = when (exercisesDistributionStatisticsChart) {
                        StatisticsChart.DURATION -> 0
                        else -> 2
                    },
                    suffix = when (exercisesDistributionStatisticsChart) {
                        StatisticsChart.LOAD -> stringResource(R.string.kg)
                        StatisticsChart.REPS -> null
                        StatisticsChart.VOLUME -> stringResource(R.string.kg)
                        StatisticsChart.DURATION -> stringResource(R.string.min)
                    },
                    points = exercisesDistributionPoints,
                    legendList = exercisesDistributionLegendIds.map { pair ->
                        stringResource(pair.first) + if (pair.second != null) {
                            ": " + pair.second
                        } else ""
                    },
                    chartModes = StatisticsChart.entries,
                    chartMode = exercisesDistributionStatisticsChart,
                    useColumns = true,
                    updateChartMode = { updateExercisesDistributionStatisticsChart(it) }
                )
            }
        }
    }
}

@Preview
@Composable
fun StatisticsScreenPreview() {
    var muscleDistributionStatisticsChart by remember { mutableStateOf(StatisticsChart.entries.random()) }
    var exerciseDistributionStatisticsChart by remember { mutableStateOf(StatisticsChart.entries.random()) }

    val musclesNames = listOf(
        stringResource(Formatter.exerciseEnumToStringId(Muscle.BICEPS)),
        stringResource(Formatter.exerciseEnumToStringId(Muscle.TRICEPS))
    )

    val cutoffsIds: List<Pair<Int, Long?>> = listOf(
        R.string.past_week to null, R.string.past_month to null, R.string.history to null
    )

    key(muscleDistributionStatisticsChart) {
        val muscleDistributionPoints = listOf(
            Point(
                yValues = (0..2).map { Random.nextDouble() },
                xValue = musclesNames.first()
            ),
            Point(
                yValues = (0..2).map { Random.nextDouble() },
                xValue = musclesNames[1]
            )
        )

        val exerciseDistributionPoints = listOf(
            Point(
                yValues = (0..2).map { Random.nextDouble() },
                xValue = musclesNames.first()
            ),
            Point(
                yValues = (0..2).map { Random.nextDouble() },
                xValue = musclesNames[1]
            )
        )

        NexcTheme(dynamicColor = false, themeMode = ThemeMode.DARK) {
            StatisticsScreenContent(
                navController = rememberNavController(),
                muscleDistributionPoints = muscleDistributionPoints,
                muscleDistributionLegendIds = cutoffsIds,
                muscleDistributionStatisticsChart = muscleDistributionStatisticsChart,
                updateMuscleDistributionStatisticsChart = {
                    muscleDistributionStatisticsChart = it
                },
                exercisesDistributionPoints = exerciseDistributionPoints,
                exercisesDistributionLegendIds = emptyList(),
                exercisesDistributionStatisticsChart = exerciseDistributionStatisticsChart,
                muscleHeatmapData = emptyMap(),
                updateExercisesDistributionStatisticsChart = {
                    exerciseDistributionStatisticsChart = it
                }
            )
        }
    }
}