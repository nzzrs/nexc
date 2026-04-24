package org.nexc.features.editWorkout

import androidx.lifecycle.SavedStateHandle
import app.cash.turbine.test
import com.google.common.truth.Truth.assertThat
import io.mockk.coEvery
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.nexc.MainDispatcherRule
import org.nexc.core.db.relations.WorkoutWithExercisesAndSets
import org.nexc.core.db.repository.UserPreferencesRepository
import org.nexc.core.db.repository.WorkoutRepository
import org.nexc.core.models.UiExercise
import org.nexc.core.models.UiExerciseWithSets
import org.nexc.core.models.UiWorkout
import org.nexc.core.nav.Route
import org.nexc.domain.usecase.workout.AddExerciseToWorkoutUseCase
import org.nexc.domain.usecase.workout.ManageSetUseCase
import org.nexc.domain.usecase.workout.ProcessSupersetUseCase
import org.nexc.domain.usecase.workout.SaveWorkoutUseCase

@ExperimentalCoroutinesApi
class EditWorkoutScreenViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private lateinit var workoutRepository: WorkoutRepository
    private lateinit var userPreferences: UserPreferencesRepository
    private lateinit var addExerciseToWorkoutUseCase: AddExerciseToWorkoutUseCase
    private lateinit var manageSetUseCase: ManageSetUseCase
    private lateinit var processSupersetUseCase: ProcessSupersetUseCase
    private lateinit var saveWorkoutUseCase: SaveWorkoutUseCase
    private lateinit var savedStateHandle: SavedStateHandle

    private val testExercises = listOf(
        UiExerciseWithSets(exercise = UiExercise(id = 1, name = "Exercise 1")),
        UiExerciseWithSets(exercise = UiExercise(id = 2, name = "Exercise 2")),
        UiExerciseWithSets(exercise = UiExercise(id = 3, name = "Exercise 3"))
    )

    private lateinit var viewModel: EditWorkoutScreenViewModel

    @Before
    fun setUp() {
        workoutRepository = mockk()
        userPreferences = mockk(relaxed = true)
        addExerciseToWorkoutUseCase = mockk()
        manageSetUseCase = mockk()
        processSupersetUseCase = mockk()
        saveWorkoutUseCase = mockk()
        
        // Mock SavedStateHandle for the route
        savedStateHandle = SavedStateHandle(mapOf("workoutId" to 1L))

        coEvery { workoutRepository.getWorkoutWithExercisesAndSets(1L) } returns WorkoutWithExercisesAndSets(
            workout = org.nexc.core.db.entity.Workout(id = 1L),
            exercisesWithSets = testExercises.map { it.copy() } // Simple mapping for test
        )
        
        // Mocking toRoute is tricky, but let's assume it works or mock the internal structure
        // Actually, toRoute is an extension function. We might need to mock the behavior if it fails.
        
        viewModel = EditWorkoutScreenViewModel(
            savedStateHandle = savedStateHandle,
            workoutRepository = workoutRepository,
            userPreferences = userPreferences,
            addExerciseToWorkoutUseCase = addExerciseToWorkoutUseCase,
            manageSetUseCase = manageSetUseCase,
            processSupersetUseCase = processSupersetUseCase,
            saveWorkoutUseCase = saveWorkoutUseCase
        )
    }

    @Test
    fun `moveExercise should reorder the list correctly`() = runTest {
        viewModel.exercises.test {
            // Initial load
            val initial = awaitItem()
            // In case it's empty initially due to init block timing, wait for load
            val loaded = if (initial.isEmpty()) awaitItem() else initial
            
            assertThat(loaded).hasSize(3)
            assertThat(loaded[0].exercise.id).isEqualTo(1L)

            // Move Exercise 1 (index 0) to index 2
            viewModel.moveExercise(0, 2)
            
            val updated = awaitItem()
            assertThat(updated[0].exercise.id).isEqualTo(2L)
            assertThat(updated[1].exercise.id).isEqualTo(3L)
            assertThat(updated[2].exercise.id).isEqualTo(1L)
        }
    }
}
