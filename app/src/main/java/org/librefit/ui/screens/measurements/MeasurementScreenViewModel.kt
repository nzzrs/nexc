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

package org.librefit.ui.screens.measurements

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import org.librefit.data.ChartData
import org.librefit.db.entity.Measurement
import org.librefit.db.repository.MeasurementRepository
import org.librefit.enums.MeasurementCardState
import org.librefit.enums.chart.MeasurementChart
import org.librefit.util.Formatter
import java.time.LocalDateTime
import javax.inject.Inject
import kotlin.random.Random

@HiltViewModel
class MeasurementScreenViewModel @Inject constructor(
    private val measurementRepository: MeasurementRepository
) : ViewModel() {
    private val _measurementChart = MutableStateFlow(MeasurementChart.BODY_WEIGHT)
    val measurementChart = _measurementChart.asStateFlow()

    fun updateMeasurementChart(newMeasurementChart: MeasurementChart) {
        _measurementChart.value = newMeasurementChart
    }


    val measurements: StateFlow<List<Measurement>> = measurementRepository.measurements
        .distinctUntilChanged()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )


    val listChartData: StateFlow<List<ChartData>> =
        combine(
            measurements,
            measurementChart
        ) { measurements, measurementChart ->
            measurements
                .filter {
                    when (measurementChart) {
                        MeasurementChart.BODY_WEIGHT -> it.bodyWeight != 0f
                        MeasurementChart.FAT_MASS -> it.bodyFatPercentage != 0f
                        MeasurementChart.LEAN_MASS -> it.muscleMassPercentage != 0f
                    }
                }
                .map {
                    ChartData(
                        yValue = when (measurementChart) {
                            MeasurementChart.BODY_WEIGHT -> it.bodyWeight
                            MeasurementChart.FAT_MASS -> it.bodyFatPercentage
                            MeasurementChart.LEAN_MASS -> it.muscleMassPercentage
                        },
                        xValue = Formatter.getShortDateFromLocalDate(it.date)
                    )
                }
        }
            .distinctUntilChanged()
            .flowOn(Dispatchers.Default)
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = emptyList()
            )


    private val _idMeasurement = MutableStateFlow(0L)
    val idMeasurement = _idMeasurement.asStateFlow()

    fun updateIdMeasurement(newValue: Long) {
        _idMeasurement.value = newValue
    }


    private val currentMeasurement: StateFlow<Measurement> = idMeasurement
        .map { id -> measurements.value.find { it.id == id } ?: Measurement() }
        .distinctUntilChanged()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = Measurement() // Start with null until the first ID is processed
        )


    private val _bodyweight = MutableStateFlow(0f)
    val bodyWeight: StateFlow<Float> =
        combine(_bodyweight, currentMeasurement) { b, m ->
            if (bodyWeight.value != b) b else m.bodyWeight
        }
            .distinctUntilChanged()
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = 0f
            )

    fun updateBodyweight(newValue: String) {
        _bodyweight.value = newValue.ifBlank { "0" }.toFloat()
    }


    private val _fatMass = MutableStateFlow(0f)
    val fatMass: StateFlow<Float> =
        combine(_fatMass, currentMeasurement) { f, m ->
            if (fatMass.value != f) f else m.bodyFatPercentage
        }
            .distinctUntilChanged()
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = 0f
            )

    fun updateFatMass(newValue: String) {
        _fatMass.value = newValue.ifBlank { "0" }.toFloat()
    }


    private val _leanMass = MutableStateFlow(0f)
    val leanMass: StateFlow<Float> =
        combine(_leanMass, currentMeasurement) { l, m ->
            if (leanMass.value != l) l else m.muscleMassPercentage
        }
            .distinctUntilChanged()
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = 0f
            )

    fun updateLeanMass(newValue: String) {
        _leanMass.value = newValue.ifBlank { "0" }.toFloat()
    }


    private val _notes = MutableStateFlow("")
    val notes: StateFlow<String> =
        combine(_notes, currentMeasurement) { n, m ->
            if (notes.value != n) n else m.notes
        }
            .distinctUntilChanged()
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = ""
            )

    fun updateNotes(newValue: String) {
        _notes.value = newValue
    }


    private val _date = MutableStateFlow(LocalDateTime.now())
    val date: StateFlow<LocalDateTime> =
        combine(_date, currentMeasurement) { d, m ->
            if (date.value != d) d else m.date
        }
            .distinctUntilChanged()
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = LocalDateTime.now()
            )

    fun updateDate(newValue: LocalDateTime) {
        _date.value = newValue
    }


    private val _measurementCardState = MutableStateFlow(MeasurementCardState.NEW)
    val measurementCardState = _measurementCardState.asStateFlow()

    fun updateMeasurementCardState(measurementCardState: MeasurementCardState) {
        _measurementCardState.value = measurementCardState
    }


    fun upsertMeasurementToDB() {
        viewModelScope.launch(Dispatchers.IO) {
            measurementRepository.upsertMeasurement(
                Measurement(
                    id = if (measurementCardState.value == MeasurementCardState.EDIT)
                        idMeasurement.value else 0L,
                    bodyWeight = bodyWeight.value,
                    notes = notes.value,
                    muscleMassPercentage = leanMass.value,
                    bodyFatPercentage = fatMass.value,
                    date = date.value
                )
            )
            _idMeasurement.value = Random.nextLong()

            _measurementCardState.value = MeasurementCardState.NEW
        }
    }

    fun deleteMeasurementById(id: Long) {
        viewModelScope.launch(Dispatchers.IO) {
            measurementRepository.deleteById(id)

            _idMeasurement.value = Random.nextLong()

            _measurementCardState.value = MeasurementCardState.NEW
        }
    }
}