/*
 * Copyright (c) 2024 LibreFit
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

package org.librefit.data

import androidx.compose.runtime.mutableStateListOf
import androidx.lifecycle.ViewModel

class SharedViewModel : ViewModel() {
    /**
     * A list used by CreateRoutineScreen and AddExerciseScreen
     */

    private val selectedExercisesList = mutableStateListOf<ExerciseDC>()

    fun getSelectedExercisesList() : List<ExerciseDC> {
        return selectedExercisesList.toList()
    }

    fun addSelectedExerciseToList (exerciseList: List<ExerciseDC>){
        resetSelectedExercisesList()
        selectedExercisesList += exerciseList
    }

    fun removeExerciseFromList (exercise: ExerciseDC ){
        selectedExercisesList.remove(exercise)
    }

    fun resetSelectedExercisesList () {
        selectedExercisesList.clear()
    }


    /**
     * A list used only by AddExerciseScreen based on FiltersCard
     */

    private var filtersList = mutableStateListOf<Enum<*>>()

    init {
        initializeFilterList()
    }

    private fun initializeFilterList(){
        Level.entries.forEach { filtersList.add(it) }
        Force.entries.forEach { filtersList.add(it) }
        Level.entries.forEach { filtersList.add(it) }
        Mechanic.entries.forEach { filtersList.add(it) }
        Equipment.entries.forEach { filtersList.add(it) }
        Muscle.entries.forEach { filtersList.add(it) }
        Category.entries.forEach { filtersList.add(it) }
    }

    fun addEnum( enum : Enum<*> ){
        filtersList.add(enum)
    }

    fun removeEnum( enum : Enum<*> ){
        filtersList.remove(enum)
    }

    fun isEnumInList ( enum : Enum<*> ) : Boolean{
        return filtersList.contains(enum)
    }

    fun resetFilterList(){
        filtersList.clear()
        initializeFilterList()
    }
}