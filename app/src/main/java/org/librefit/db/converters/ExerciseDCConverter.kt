/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.db.converters

import androidx.room.TypeConverter
import com.squareup.moshi.Moshi
import com.squareup.moshi.Types
import org.librefit.enums.exercise.Category
import org.librefit.enums.exercise.Equipment
import org.librefit.enums.exercise.Force
import org.librefit.enums.exercise.Level
import org.librefit.enums.exercise.Mechanic
import org.librefit.enums.exercise.Muscle

class ExerciseDCConverter {
    private val moshi = Moshi.Builder().build()

    // Converter for List<String> (for instructions and images)
    private val stringListType = Types.newParameterizedType(List::class.java, String::class.java)
    private val stringListAdapter = moshi.adapter<List<String>>(stringListType)

    @TypeConverter
    fun fromStringList(value: String?): List<String>? {
        return value?.let { stringListAdapter.fromJson(it) } ?: emptyList()
    }

    @TypeConverter
    fun toStringList(list: List<String>?): String? {
        return stringListAdapter.toJson(list)
    }

    // Converter for List<Muscle>
    private val muscleListType = Types.newParameterizedType(List::class.java, Muscle::class.java)
    private val muscleListAdapter = moshi.adapter<List<Muscle>>(muscleListType)

    @TypeConverter
    fun fromMuscleList(value: String?): List<Muscle>? {
        return value?.let { muscleListAdapter.fromJson(it) } ?: emptyList()
    }

    @TypeConverter
    fun toMuscleList(list: List<Muscle>?): String? {
        return muscleListAdapter.toJson(list)
    }

    // Converters for Enums
    @TypeConverter
    fun fromForce(value: String?): Force? = value?.let { Force.valueOf(it) }

    @TypeConverter
    fun toForce(force: Force?): String? = force?.name

    @TypeConverter
    fun fromLevel(value: String): Level = Level.valueOf(value)

    @TypeConverter
    fun toLevel(level: Level): String = level.name

    @TypeConverter
    fun fromMechanic(value: String?): Mechanic? = value?.let { Mechanic.valueOf(it) }

    @TypeConverter
    fun toMechanic(mechanic: Mechanic?): String? = mechanic?.name

    @TypeConverter
    fun fromEquipment(value: String?): Equipment? = value?.let { Equipment.valueOf(it) }

    @TypeConverter
    fun toEquipment(equipment: Equipment?): String? = equipment?.name

    @TypeConverter
    fun fromCategory(value: String): Category = Category.valueOf(value)

    @TypeConverter
    fun toCategory(category: Category): String = category.name
}