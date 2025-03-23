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

package org.librefit.ui.components.charts

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.patrykandpatrick.vico.compose.cartesian.CartesianChartHost
import com.patrykandpatrick.vico.compose.cartesian.axis.rememberBottom
import com.patrykandpatrick.vico.compose.cartesian.axis.rememberStart
import com.patrykandpatrick.vico.compose.cartesian.layer.rememberColumnCartesianLayer
import com.patrykandpatrick.vico.compose.cartesian.layer.rememberLine
import com.patrykandpatrick.vico.compose.cartesian.layer.rememberLineCartesianLayer
import com.patrykandpatrick.vico.compose.cartesian.rememberCartesianChart
import com.patrykandpatrick.vico.compose.cartesian.rememberVicoZoomState
import com.patrykandpatrick.vico.compose.common.ProvideVicoTheme
import com.patrykandpatrick.vico.compose.common.component.rememberLineComponent
import com.patrykandpatrick.vico.compose.common.fill
import com.patrykandpatrick.vico.compose.common.shader.verticalGradient
import com.patrykandpatrick.vico.compose.m3.common.rememberM3VicoTheme
import com.patrykandpatrick.vico.core.cartesian.Zoom
import com.patrykandpatrick.vico.core.cartesian.axis.HorizontalAxis
import com.patrykandpatrick.vico.core.cartesian.axis.VerticalAxis
import com.patrykandpatrick.vico.core.cartesian.data.CartesianChartModelProducer
import com.patrykandpatrick.vico.core.cartesian.data.CartesianValueFormatter
import com.patrykandpatrick.vico.core.cartesian.data.columnSeries
import com.patrykandpatrick.vico.core.cartesian.data.lineSeries
import com.patrykandpatrick.vico.core.cartesian.layer.ColumnCartesianLayer
import com.patrykandpatrick.vico.core.cartesian.layer.LineCartesianLayer
import com.patrykandpatrick.vico.core.cartesian.marker.DefaultCartesianMarker
import com.patrykandpatrick.vico.core.common.data.ExtraStore
import com.patrykandpatrick.vico.core.common.shader.ShaderProvider
import com.patrykandpatrick.vico.core.common.shape.CorneredShape
import org.librefit.data.ChartData
import org.librefit.ui.components.CustomScaffold
import java.text.DecimalFormat

/**
 * A custom [com.patrykandpatrick.vico.core.cartesian.CartesianChart]
 *
 * @param format It is used by [VerticalAxis] to display Y axis values following the provided format
 * @param listChartData A list of [org.librefit.data.ChartData] containing the actual values of the chart, it must be not empty.
 *
 * @param columns When `false`, the chart becomes a line chart.
 *
 * @throws IllegalArgumentException when [listChartData] is empty
 */
@Composable
fun CustomCartesianChart(
    format: DecimalFormat = DecimalFormat(),
    listChartData: List<ChartData>,
    columns: Boolean = false
) {
    require(listChartData.isNotEmpty()) {
        "Chart data must not be empty."
    }

    val yAxisData = listChartData.map { it.yValue }
    val xAxisLabels = listChartData.map { it.xValue }

    val labelListKey = ExtraStore.Key<List<String>>()
    val modelProducer = remember { CartesianChartModelProducer() }
    LaunchedEffect(yAxisData) {
        modelProducer.runTransaction {
            if (columns) {
                columnSeries { series(yAxisData) }
            } else {
                lineSeries { series(yAxisData) }
            }
            if (xAxisLabels.all { it.isNotBlank() }) {
                extras { it[labelListKey] = xAxisLabels }
            }
        }
    }

    val primaryColor = MaterialTheme.colorScheme.primary

    /**
     * Material design 3 chart
     */
    ProvideVicoTheme(rememberM3VicoTheme()) {
        CartesianChartHost(
            chart = rememberCartesianChart(
                if (columns) rememberColumnCartesianLayer(
                    columnProvider = ColumnCartesianLayer.ColumnProvider.series(
                        rememberLineComponent(
                            fill = fill(MaterialTheme.colorScheme.primary),
                            thickness = 32.dp,
                            shape = CorneredShape.rounded(32, 32)
                        )
                    ),
                    columnCollectionSpacing = 64.dp
                ) else rememberLineCartesianLayer(
                    lineProvider = LineCartesianLayer.LineProvider.series(
                        LineCartesianLayer.rememberLine(
                            fill = LineCartesianLayer.LineFill.single(fill(primaryColor)),
                            areaFill = LineCartesianLayer.AreaFill.single(
                                fill(
                                    ShaderProvider.verticalGradient(
                                        arrayOf(primaryColor.copy(alpha = 0.4f), Color.Transparent)
                                    )
                                )
                            ),
                            // Curved line
                            pointConnector = LineCartesianLayer.PointConnector.cubic()
                        )
                    ),
                    pointSpacing = 64.dp
                ),
                marker = rememberMarker(
                    valueFormatter = DefaultCartesianMarker.ValueFormatter.default(format)
                ),
                startAxis = VerticalAxis.rememberStart(
                    valueFormatter = remember(format) { CartesianValueFormatter.decimal(format) }
                ),
                bottomAxis = HorizontalAxis.rememberBottom(
                    valueFormatter = remember(yAxisData, xAxisLabels) {
                        if (xAxisLabels.all { it.isNotBlank() })
                            CartesianValueFormatter { context, x, _ ->
                                context.model.extraStore.getOrNull(labelListKey)?.get(x.toInt())
                                    ?: xAxisLabels.getOrNull(yAxisData.indexOf(x.toFloat()))
                                    ?: xAxisLabels.first()
                            }
                        else CartesianValueFormatter.decimal()
                    }
                ),
            ),
            zoomState = rememberVicoZoomState(
                zoomEnabled = false,
                minZoom = Zoom.fixed(),
                maxZoom = Zoom.fixed()
            ),
            modelProducer = modelProducer,
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        }

    }
}

@Preview
@Composable
private fun CustomCartesianChartPreview() {
    CustomScaffold {
        Column(Modifier.padding(it)) {
            CustomCartesianChart(
                listChartData = listOf(1f, 2f, -1f).map(::ChartData)
            )
        }
    }
}