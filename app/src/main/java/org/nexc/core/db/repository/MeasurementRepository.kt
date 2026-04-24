/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.db.repository

import org.nexc.core.db.dao.MeasurementDao
import org.nexc.core.db.entity.Measurement
import java.time.LocalDateTime
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Repository class for managing measurements data.
 *
 * This class serves as a mediator between [MeasurementDao] and the
 * application, providing a clean API for data access.
 *
 *
 * @param measurementDao The [MeasurementDao] instance used to access measurements data from the database.
 *
 */
@Singleton
class MeasurementRepository @Inject constructor(
    private val measurementDao: MeasurementDao
) {
    val measurements = measurementDao.getAllMeasurements()

    suspend fun upsertMeasurement(measurement: Measurement) {
        measurementDao.upsertMeasurement(measurement)
    }

    suspend fun deleteMeasurement(measurement: Measurement) {
        measurementDao.deleteMeasurement(measurement)
    }

    suspend fun deleteById(id: Long) {
        measurementDao.deleteById(id)
    }

    suspend fun getLastMeasurementByCutoff(cutoff: LocalDateTime): Measurement? {
        return measurementDao.getLastMeasurementByCutoff(cutoff)
    }
}