/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 */

package org.nexc.features.home

import android.Manifest
import android.os.Build
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.AnimatedVisibilityScope
import androidx.compose.animation.ExperimentalSharedTransitionApi
import androidx.compose.animation.SharedTransitionLayout
import androidx.compose.animation.SharedTransitionScope
import androidx.compose.animation.animateColor
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithCache
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawOutline
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavHostController
import androidx.navigation.compose.rememberNavController
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.isGranted
import com.google.accompanist.permissions.rememberPermissionState
import org.nexc.R
import org.nexc.core.enums.pages.MainScreenPages
import org.nexc.core.enums.userPreferences.ThemeMode
import org.nexc.core.nav.Route
import org.nexc.core.components.GetAppNameInAnnotatedBuilder
import org.nexc.core.components.HeadlineText
import org.nexc.core.components.NexcButton
import org.nexc.core.components.NexcLazyColumn
import org.nexc.core.components.NexcScaffold
import org.nexc.core.components.dialogs.ConfirmDialog
import org.nexc.core.models.UiWorkout
import org.nexc.core.theme.NexcTheme
import org.nexc.core.util.Formatter
import kotlin.random.Random

@OptIn(ExperimentalPermissionsApi::class, ExperimentalSharedTransitionApi::class)
@Composable
fun SharedTransitionScope.HomeScreen(
    navController: NavHostController,
    animatedVisibilityScope: AnimatedVisibilityScope
) {
    val viewModel: HomeScreenViewModel = hiltViewModel()

    val requestPermissionNextTime by viewModel.requestPermissionNextTime.collectAsStateWithLifecycle()

    val notificationPermissionState = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        rememberPermissionState(
            Manifest.permission.POST_NOTIFICATIONS
        )
    } else {
        null
    }

    val routines by viewModel.routines.collectAsStateWithLifecycle()
    val runningWorkout by viewModel.runningWorkout.collectAsStateWithLifecycle()

    HomeScreenContent(
        navController = navController,
        runningWorkout = runningWorkout,
        routines = routines,
        animatedVisibilityScope = animatedVisibilityScope,
        deleteRunningWorkout = viewModel::deleteRunningWorkout,
        navigateToRoutine = { workoutId ->
            val hasNotificationPermission = notificationPermissionState?.status?.isGranted != false
            val requestPermission = !hasNotificationPermission && requestPermissionNextTime

            if (requestPermission) {
                navController.navigate(Route.RequestPermissionScreen(workoutId = workoutId)) {
                    launchSingleTop = true
                }
            } else {
                navController.navigate(Route.WorkoutScreen(workoutId = workoutId)) {
                    launchSingleTop = true
                    popUpTo(Route.RequestPermissionScreen(workoutId = workoutId)) {
                        inclusive = true
                    }
                }
            }
        }
    )
}

@OptIn(ExperimentalSharedTransitionApi::class, ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun SharedTransitionScope.HomeScreenContent(
    navController: NavHostController,
    routines: List<UiWorkout>,
    runningWorkout: UiWorkout?,
    animatedVisibilityScope: AnimatedVisibilityScope,
    deleteRunningWorkout: () -> Unit,
    navigateToRoutine: (Long) -> Unit
) {
    val showConfirmDeleteRunningWorkoutDialog = rememberSaveable { mutableStateOf(false) }

    if (showConfirmDeleteRunningWorkoutDialog.value) {
        ConfirmDialog(
            title = stringResource(R.string.discard_running_workout_question),
            text = stringResource(R.string.delete_running_workout_text),
            confirmText = stringResource(R.string.discard_dialog),
            onConfirm = {
                deleteRunningWorkout()
                showConfirmDeleteRunningWorkoutDialog.value = false
            },
            onDismiss = {
                showConfirmDeleteRunningWorkoutDialog.value = false
            }
        )
    }

    // It is triggered when there's an unsaved, running workout but user taps a routine
    val routineIdToStart = remember { mutableStateOf<Long?>(null) }

    routineIdToStart.value?.let {
        ConfirmDialog(
            title = stringResource(R.string.discard_running_workout_question),
            text = stringResource(R.string.discard_running_workout_and_select_routine_text),
            confirmText = stringResource(R.string.discard_dialog),
            onConfirm = {
                deleteRunningWorkout()
                navigateToRoutine(it)
                routineIdToStart.value = null
            },
            onDismiss = {
                routineIdToStart.value = null
            }
        )
    }

    NexcLazyColumn {
        item {
            val infiniteTransition = rememberInfiniteTransition()
            val animatedColor by infiniteTransition.animateColor(
                initialValue = Color.Transparent,
                targetValue = MaterialTheme.colorScheme.secondary.copy(alpha = 0.8f),
                animationSpec = infiniteRepeatable(
                    animation = tween(1000),
                    repeatMode = RepeatMode.Reverse
                ),
            )
            val shape = MaterialTheme.shapes.extraLarge
            ElevatedCard(
                shape = shape,
                modifier = Modifier.drawWithCache {
                    onDrawWithContent {
                        drawContent()

                        if (runningWorkout != null) {
                            drawOutline(
                                outline = shape.createOutline(size, layoutDirection, this),
                                color = animatedColor,
                                style = Stroke(width = 5f)
                            )
                        }
                    }
                }
            ) {
                NexcButton(
                    text = stringResource(if (runningWorkout != null) R.string.resume_workout else R.string.start_empty_workout),
                    icon = painterResource(R.drawable.ic_play_arrow),
                    onClick = {
                        navigateToRoutine(runningWorkout?.id ?: 0)
                    },
                )
                AnimatedVisibility(runningWorkout != null) {
                    Column(
                        modifier = Modifier
                            .padding(15.dp)
                            .fillMaxWidth(),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                stringResource(R.string.elapsed_time) + ": " + Formatter.formatTime(
                                    runningWorkout?.timeElapsed ?: 0
                                )
                            )

                            IconButton(
                                enabled = runningWorkout != null,
                                onClick = {
                                    showConfirmDeleteRunningWorkoutDialog.value = true
                                }
                            ) {
                                Icon(
                                    painter = painterResource(R.drawable.ic_delete),
                                    contentDescription = stringResource(R.string.delete)
                                )
                            }
                        }
                    }
                }
            }
        }


        item {
            HeadlineText(stringResource(id = R.string.your_routines))
        }

        if (routines.isEmpty()) {
            item {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(150.dp),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = stringResource(R.string.start_creating_routine),
                        textAlign = TextAlign.Center
                    )
                    IconButton(
                        onClick = {
                            navController.navigate(Route.TutorialScreen()) {
                                launchSingleTop = true
                            }
                        }
                    ) {
                        Icon(
                            painter = painterResource(R.drawable.ic_help),
                            contentDescription = stringResource(R.string.help)
                        )
                    }
                }
            }
        }

        items(routines, key = { it.id }) { routine ->
            ElevatedCard(
                onClick = {
                    navController.navigate(Route.InfoWorkoutScreen(workoutId = routine.id)) {
                        launchSingleTop = true
                    }
                },
                shape = MaterialTheme.shapes.extraLarge,
                modifier = Modifier
                    .sharedBounds(
                        sharedContentState = rememberSharedContentState(routine.id),
                        animatedVisibilityScope = animatedVisibilityScope
                    )
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(15.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = routine.title,
                            style = MaterialTheme.typography.headlineMedium,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            fontWeight = FontWeight.SemiBold,
                            modifier = Modifier.sharedElement(
                                sharedContentState = rememberSharedContentState(
                                    routine.id.toString() + routine.title
                                ),
                                animatedVisibilityScope = animatedVisibilityScope
                            )
                        )
                        IconButton(
                            onClick = {
                                navController.navigate(Route.InfoWorkoutScreen(workoutId = routine.id)) {
                                    launchSingleTop = true
                                }
                            }
                        ) {
                            Icon(
                                painter = painterResource(R.drawable.ic_info),
                                contentDescription = stringResource(R.string.info)
                            )
                        }
                    }
                    NexcButton(
                        text = stringResource(R.string.start_routine),
                        icon = painterResource(R.drawable.ic_play_arrow),
                        elevated = false
                    ) {
                        if (runningWorkout != null) {
                            routineIdToStart.value = routine.id
                        } else {
                            navigateToRoutine(routine.id)
                        }
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalSharedTransitionApi::class, ExperimentalMaterial3ExpressiveApi::class)
@Preview(device = "id:medium_phone", locale = "en")
@Composable
fun HomeScreenPreview() {
    val pagerState = rememberPagerState(
        initialPage = MainScreenPages.HOME.ordinal,
        pageCount = { MainScreenPages.entries.size }
    )

    val runningWorkout = remember { mutableStateOf<UiWorkout?>(UiWorkout(timeElapsed = 1000)) }

    org.nexc.core.theme.NexcTheme(dynamicColor = false, themeMode = ThemeMode.DARK) {

        NexcScaffold(
            title = buildAnnotatedString {
                GetAppNameInAnnotatedBuilder(MaterialTheme.typography.titleLargeEmphasized)
            },
            actions = listOf({ }, { }),
            actionsIcons = listOf(
                painterResource(R.drawable.ic_info),
                painterResource(R.drawable.ic_settings)
            ),
            actionsElevated = listOf(false, false),
            fabAction = {},
            fabIcon = painterResource(R.drawable.ic_add),
            fabText = stringResource(R.string.create_routine),
            bottomBar = {
                NavigationBar {
                    MainScreenPages.entries.forEach { page ->
                        NavigationBarItem(
                            selected = pagerState.currentPage == page.ordinal,
                            onClick = { },
                            icon = {
                                Icon(
                                    painter = painterResource(
                                        id = when (page) {
                                            MainScreenPages.HOME -> R.drawable.ic_home
                                            MainScreenPages.PROFILE -> R.drawable.ic_person
                                        }
                                    ),
                                    contentDescription = stringResource(
                                        id = when (page) {
                                            MainScreenPages.HOME -> R.string.home
                                            MainScreenPages.PROFILE -> R.string.profile
                                        }
                                    )
                                )
                            },
                            label = {
                                Text(
                                    text = stringResource(
                                        id = when (page) {
                                            MainScreenPages.HOME -> R.string.home
                                            MainScreenPages.PROFILE -> R.string.profile
                                        }
                                    )
                                )
                            }
                        )
                    }
                }
            }
        ) { innerPadding ->
            HorizontalPager(
                state = rememberPagerState { 0 },
                contentPadding = innerPadding
            ) {
                SharedTransitionLayout {
                    AnimatedVisibility(visible = true) {
                        HomeScreenContent(
                            navController = rememberNavController(),
                            runningWorkout = runningWorkout.value,
                            routines = listOf(
                                UiWorkout(
                                    id = Random.nextLong(),
                                    title = "\uD83C\uDFCB Upper body"
                                ),
                                UiWorkout(
                                    id = Random.nextLong(),
                                    title = "\uD83D\uDD31 Lower body"
                                ),
                                UiWorkout(
                                    id = Random.nextLong(),
                                    title = "\uD83C\uDFC3 Tempo run"
                                )
                            ),
                            navigateToRoutine = {},
                            deleteRunningWorkout = { runningWorkout.value = null },
                            animatedVisibilityScope = this
                        )
                    }
                }
            }
        }
    }
}