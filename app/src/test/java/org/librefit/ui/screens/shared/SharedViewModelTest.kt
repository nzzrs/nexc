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

package org.librefit.ui.screens.shared

import com.google.common.truth.Truth.assertThat
import org.junit.Before
import org.junit.Test
import org.librefit.data.ExerciseDC

class SharedViewModelTest {
    private lateinit var viewModel: SharedViewModel

    @Before
    fun setUp() {
        viewModel = SharedViewModel()
    }

    @Test
    fun `initial state is an empty list`() {
        // Act
        val result = viewModel.getSelectedExercisesList()

        // Assert
        assertThat(result).isEmpty()
    }

    @Test
    fun getSelectedExercisesList() {
        // Arrange
        val exercises = (0..4).map { ExerciseDC(id = "$it") }

        viewModel.setSelectedExercisesList(exercises)

        // Act (First call)
        val firstResult = viewModel.getSelectedExercisesList()

        // Assert (First call)
        assertThat(firstResult).isEqualTo(exercises)

        // Act (Second call)
        val secondResult = viewModel.getSelectedExercisesList()

        // Assert (Second call)
        assertThat(secondResult).isEmpty()
    }

}