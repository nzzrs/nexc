/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.util

import android.content.Context
import android.net.Uri
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString
import org.nexc.core.db.AppDatabase
import org.nexc.core.db.repository.WorkoutRepository
import org.nexc.core.models.dto.WorkoutExportDTO
import org.nexc.core.models.dto.toExportDTO
import org.nexc.core.models.mappers.*
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.io.FileOutputStream
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.flow.first
import org.nexc.core.db.repository.DatasetRepository
import org.nexc.core.db.entity.Product
import org.nexc.core.db.entity.Recipe
import org.nexc.core.db.entity.RecipeIngredient
import org.nexc.core.db.entity.MealPlan
import org.nexc.core.db.entity.Meal
import org.nexc.core.db.entity.MealItem
import org.nexc.core.enums.MealPlanState
import org.nexc.core.enums.MealItemType
import org.nexc.core.db.relations.MealPlanWithMealsAndItems
import org.nexc.core.db.relations.MealWithItems
import org.nexc.core.db.relations.MealItemWithDetails
import org.nexc.core.db.relations.RecipeWithIngredients
import org.nexc.core.db.relations.RecipeIngredientWithProduct
import org.nexc.core.db.repository.MealRepository
import org.nexc.core.models.dto.MealPlanExportDTO
import org.nexc.core.models.dto.toExportDTO

@Singleton
class BackupManager @Inject constructor(
    @ApplicationContext private val context: Context,
    private val workoutRepository: WorkoutRepository,
    private val datasetRepository: DatasetRepository,
    private val mealRepository: MealRepository
) {
    private val databaseName = AppDatabase.NAME

    suspend fun exportDatabase(uri: Uri) = withContext(Dispatchers.IO) {
        val dbFile = context.getDatabasePath(databaseName)
        context.contentResolver.openOutputStream(uri)?.use { output ->
            dbFile.inputStream().use { input ->
                input.copyTo(output)
            }
        }
    }

    suspend fun importDatabase(uri: Uri) = withContext(Dispatchers.IO) {
        val dbFile = context.getDatabasePath(databaseName)
        val shmFile = File(dbFile.path + "-shm")
        val walFile = File(dbFile.path + "-wal")

        // In a real app, we should probably close the DB connection first
        // But for a simple implementation, we might need a restart
        context.contentResolver.openInputStream(uri)?.use { input ->
            FileOutputStream(dbFile).use { output ->
                input.copyTo(output)
            }
        }
        // Clean up journal files to ensure consistency
        if (shmFile.exists()) shmFile.delete()
        if (walFile.exists()) walFile.delete()
    }

    suspend fun exportPlans(uri: Uri) = withContext(Dispatchers.IO) {
        val routines = workoutRepository.routines.first()
        val routinesWithExercises = routines.map { 
            workoutRepository.getWorkoutWithExercisesAndSets(it.id)
        }
        
        val dtos = routinesWithExercises.map { routine ->
            routine.workout.toExportDTO(routine.exercisesWithSets)
        }
        val json = Json.encodeToString(dtos)
        
        context.contentResolver.openOutputStream(uri)?.use<java.io.OutputStream, Unit> { output ->
            output.write(json.toByteArray())
        }
    }

    suspend fun importPlans(uri: Uri): Boolean = withContext(Dispatchers.IO) {
        try {
            context.contentResolver.openInputStream(uri)?.use { input ->
                val json = input.bufferedReader().readText()
                val dtos = Json.decodeFromString<List<WorkoutExportDTO>>(json)

                dtos.forEach { dto ->
                    val supersetMapping = mutableMapOf<String, Long>()

                    val workout = org.nexc.core.db.entity.Workout(
                        notes = dto.notes,
                        title = dto.title,
                        state = org.nexc.core.enums.WorkoutState.valueOf(dto.state),
                        timeElapsed = dto.timeElapsed,
                        created = dto.created,
                        completed = dto.completed ?: java.time.LocalDateTime.now()
                    )

                    val exercisesWithSets = dto.exercises.map { exerciseDto ->
                        val uiExerciseDc = datasetRepository.getExerciseFromId(exerciseDto.exerciseId)
                            ?: org.nexc.core.db.entity.ExerciseDC(id = exerciseDto.exerciseId, name = exerciseDto.name).toUi()
                        
                        val supersetId = exerciseDto.supersetGroupId?.let { groupId ->
                            supersetMapping.getOrPut(groupId) { java.util.UUID.randomUUID().mostSignificantBits }
                        }
                        
                        org.nexc.core.db.relations.ExerciseWithSets(
                            exercise = org.nexc.core.db.entity.Exercise(
                                notes = exerciseDto.notes,
                                setMode = org.nexc.core.enums.SetMode.valueOf(exerciseDto.setMode),
                                restTime = exerciseDto.restTime,
                                supersetId = supersetId,
                                idExerciseDC = uiExerciseDc.id
                            ),
                            sets = exerciseDto.sets.map { setDto ->
                                org.nexc.core.db.entity.Set(
                                    load = setDto.load,
                                    reps = setDto.reps,
                                    elapsedTime = setDto.elapsedTime,
                                    rpe = setDto.rpe.toDoubleOrNull(),
                                    intensityScale = setDto.intensityScale,
                                    completed = setDto.completed
                                )
                            },
                            exerciseDC = uiExerciseDc.toEntity()
                        )
                    }

                    workoutRepository.addWorkoutWithExercisesAndSets(
                        org.nexc.core.db.relations.WorkoutWithExercisesAndSets(
                            workout = workout,
                            exercisesWithSets = exercisesWithSets
                        )
                    )
                }
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    suspend fun exportExercises(uri: Uri) = withContext(Dispatchers.IO) {
        val customExercises = datasetRepository.customExercises.first()
        val json = Json.encodeToString(customExercises)
        context.contentResolver.openOutputStream(uri)?.use { output ->
            output.write(json.toByteArray())
        }
    }

    suspend fun importExercises(uri: Uri): Boolean = withContext(Dispatchers.IO) {
        try {
            context.contentResolver.openInputStream(uri)?.use { input ->
                val json = input.bufferedReader().readText()
                val exercises = Json.decodeFromString<List<org.nexc.core.db.entity.ExerciseDC>>(json)
                exercises.forEach {
                    datasetRepository.upsertExercise(it.copy(isCustomExercise = true))
                }
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    suspend fun exportMealPlans(uri: Uri) = withContext(Dispatchers.IO) {
        val templates = mealRepository.getMealPlansWithMealsAndItemsByState(MealPlanState.TEMPLATE).first()
        val dtos = templates.map { it.toExportDTO() }
        val json = Json.encodeToString(dtos)
        context.contentResolver.openOutputStream(uri)?.use { output ->
            output.write(json.toByteArray())
        }
    }

    suspend fun importMealPlans(uri: Uri): Boolean = withContext(Dispatchers.IO) {
        try {
            context.contentResolver.openInputStream(uri)?.use { input ->
                val json = input.bufferedReader().readText()
                val dtos = Json.decodeFromString<List<MealPlanExportDTO>>(json)

                val productCache = mealRepository.getAllProducts().first().toMutableList()
                val recipeCache = mealRepository.getAllRecipes().first().toMutableList()

                dtos.forEach { dto ->
                    val mealPlan = MealPlan(
                        title = dto.title,
                        notes = dto.notes,
                        state = MealPlanState.valueOf(dto.state),
                        created = dto.created,
                        completed = dto.completed
                    )

                    val mealsWithItems = dto.meals.map { mealDto ->
                        val meal = Meal(
                            name = mealDto.name,
                            time = mealDto.time,
                            notes = mealDto.notes,
                            position = mealDto.position
                        )

                        val items = mealDto.items.map { itemDto ->
                            val itemType = MealItemType.valueOf(itemDto.type)
                            var targetId = 0L

                            if (itemType == MealItemType.PRODUCT && itemDto.product != null) {
                                val pDto = itemDto.product
                                var matchedProduct = productCache.find { it.name.equals(pDto.name, ignoreCase = true) }
                                if (matchedProduct == null) {
                                    val newProduct = Product(
                                        name = pDto.name,
                                        weight = pDto.weight,
                                        cost = pDto.cost,
                                        quantity = pDto.quantity,
                                        units = pDto.units,
                                        ediblePercent = pDto.ediblePercent,
                                        edibleQtyPerUnit = pDto.edibleQtyPerUnit,
                                        proteins = pDto.proteins,
                                        carbs = pDto.carbs,
                                        fats = pDto.fats,
                                        isSupplement = pDto.isSupplement,
                                        isPortable = pDto.isPortable
                                    )
                                    val insertedId = mealRepository.saveProduct(newProduct)
                                    val productWithId = newProduct.copy(id = insertedId)
                                    productCache.add(productWithId)
                                    matchedProduct = productWithId
                                }
                                targetId = matchedProduct.id
                            } else if (itemType == MealItemType.RECIPE && itemDto.recipe != null) {
                                val rDto = itemDto.recipe
                                var matchedRecipe = recipeCache.find { it.recipe.name.equals(rDto.name, ignoreCase = true) }
                                if (matchedRecipe == null) {
                                    val ingredientRelations = rDto.ingredients.map { ingDto ->
                                        var ingProduct = productCache.find { it.name.equals(ingDto.product.name, ignoreCase = true) }
                                        if (ingProduct == null) {
                                            val newProduct = Product(
                                                name = ingDto.product.name,
                                                weight = ingDto.product.weight,
                                                cost = ingDto.product.cost,
                                                quantity = ingDto.product.quantity,
                                                units = ingDto.product.units,
                                                ediblePercent = ingDto.product.ediblePercent,
                                                edibleQtyPerUnit = ingDto.product.edibleQtyPerUnit,
                                                proteins = ingDto.product.proteins,
                                                carbs = ingDto.product.carbs,
                                                fats = ingDto.product.fats,
                                                isSupplement = ingDto.product.isSupplement,
                                                isPortable = ingDto.product.isPortable
                                             )
                                            val insertedId = mealRepository.saveProduct(newProduct)
                                            val productWithId = newProduct.copy(id = insertedId)
                                            productCache.add(productWithId)
                                            ingProduct = productWithId
                                        }
                                        RecipeIngredientWithProduct(
                                            ingredient = RecipeIngredient(
                                                productId = ingProduct.id,
                                                amount = ingDto.amount
                                            ),
                                            product = ingProduct
                                        )
                                    }

                                    val newRecipe = Recipe(
                                        name = rDto.name,
                                        instructions = rDto.instructions,
                                        isPortable = rDto.isPortable
                                    )

                                    val recipeWithIngs = RecipeWithIngredients(
                                        recipe = newRecipe,
                                        ingredients = ingredientRelations
                                    )

                                    val insertedId = mealRepository.saveRecipe(recipeWithIngs)
                                    val recipeWithId = recipeWithIngs.copy(recipe = newRecipe.copy(id = insertedId))
                                    recipeCache.add(recipeWithId)
                                    matchedRecipe = recipeWithId
                                }
                                targetId = matchedRecipe.recipe.id
                            }

                            val mealItem = MealItem(
                                type = itemType,
                                targetId = targetId,
                                amount = itemDto.amount,
                                consumed = itemDto.consumed,
                                position = itemDto.position
                            )

                            val itemProduct = productCache.find { it.id == targetId && itemType == MealItemType.PRODUCT }
                            val itemRecipe = recipeCache.find { it.recipe.id == targetId && itemType == MealItemType.RECIPE }

                            MealItemWithDetails(
                                mealItem = mealItem,
                                product = itemProduct,
                                recipe = itemRecipe
                            )
                        }

                        MealWithItems(
                            meal = meal,
                            items = items
                        )
                    }

                    val mealPlanWithMeals = MealPlanWithMealsAndItems(
                        mealPlan = mealPlan,
                        meals = mealsWithItems
                    )

                    mealRepository.saveMealPlan(mealPlanWithMeals)
                }
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
