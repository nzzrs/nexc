package org.nexc.features.editWorkout

import androidx.lifecycle.SavedStateHandle
import androidx.navigation.toRoute
import app.cash.turbine.test
import com.google.common.truth.Truth.assertThat
import io.mockk.coEvery
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkStatic
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.nexc.MainDispatcherRule
import org.nexc.core.models.UiWorkoutWithExercisesAndSets
import org.nexc.core.models.UiExerciseDC
import org.nexc.core.models.UiExercise
import org.nexc.core.models.UiExerciseWithSets
import org.nexc.core.models.UiWorkout
import org.nexc.core.nav.Route
import org.nexc.domain.usecase.workout.AddExerciseToWorkoutUseCase
import org.nexc.domain.usecase.workout.ManageSetUseCase
import org.nexc.domain.usecase.workout.ProcessSupersetUseCase
import org.nexc.domain.usecase.workout.SaveWorkoutUseCase
import kotlinx.collections.immutable.toImmutableList

import org.nexc.core.db.repository.WorkoutRepository
import org.nexc.core.db.repository.UserPreferencesRepository

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
        UiExerciseWithSets(exercise = UiExercise(id = 1), exerciseDC = UiExerciseDC(name = "Exercise 1")),
        UiExerciseWithSets(exercise = UiExercise(id = 2), exerciseDC = UiExerciseDC(name = "Exercise 2")),
        UiExerciseWithSets(exercise = UiExercise(id = 3), exerciseDC = UiExerciseDC(name = "Exercise 3"))
    )

    private lateinit var viewModel: EditWorkoutScreenViewModel

    @Before
    fun setUp() {
        mockkStatic("androidx.navigation.SavedStateHandleKt")
        workoutRepository = mockk()
        userPreferences = mockk(relaxed = true)
        addExerciseToWorkoutUseCase = mockk()
        manageSetUseCase = mockk()
        processSupersetUseCase = mockk()
        saveWorkoutUseCase = mockk()
        
        // Mock SavedStateHandle for the route
        savedStateHandle = SavedStateHandle(mapOf("workoutId" to 1L))

        every {
            any<SavedStateHandle>().toRoute<Route.EditWorkoutScreen>(any(), any())
        } returns Route.EditWorkoutScreen(1L)

        coEvery { workoutRepository.getWorkoutWithExercisesAndSets(1L) } returns UiWorkoutWithExercisesAndSets(
            workout = UiWorkout(id = 1L),
            exercisesWithSets = testExercises.map { it.copy() }.toImmutableList()
        )
        coEvery { workoutRepository.getRoutineFromRoutineID(any()) } returns org.nexc.core.db.entity.Workout()
        
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
