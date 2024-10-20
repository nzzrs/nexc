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

package org.librefit.ui.screens


import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.navigation.NavHostController
import androidx.navigation.compose.rememberNavController
import org.librefit.R
import org.librefit.nav.Destination
import org.librefit.ui.screens.home.HomeScreen


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(navController: NavHostController) {



    var expended by remember { mutableStateOf(false) }

    var homeScreenSelected by remember { mutableStateOf(true) }

    val titleTopBar = buildAnnotatedString {
        withStyle(style = SpanStyle(color = MaterialTheme.colorScheme.primary)){
            append(stringResource(id = R.string.app_name).removeRange(5,8))
        }
        append(stringResource(id = R.string.app_name).removeRange(0,5))
    }


    Scaffold(
        modifier = Modifier.fillMaxSize(),
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Text(text = titleTopBar)
                },
                actions = {
                    IconButton(
                        onClick = { expended = true }
                    ) {
                        Icon(
                            imageVector = Icons.Default.MoreVert,
                            contentDescription = stringResource(id = R.string.label_more_options)
                        )
                    }
                    DropdownMenu(
                        expanded = expended,
                        onDismissRequest = { expended = false },
                    ) {
                        DropdownMenuItem(
                            leadingIcon = {
                                Icon(
                                    imageVector = Icons.Default.Settings,
                                    contentDescription = stringResource(id = R.string.label_settings)
                                )
                            },
                            text = { Text(text = stringResource(id = R.string.label_settings)) },
                            onClick = {
                                navController.navigate(Destination.SettingsScreen)
                                expended = false
                            }
                        )
                        DropdownMenuItem(
                            leadingIcon = {
                                Icon(
                                    imageVector = Icons.Default.Info,
                                    contentDescription = stringResource(id = R.string.label_about)
                                )
                            },
                            text = { Text(text = stringResource(id = R.string.label_about)) },
                            onClick = {
                                navController.navigate(Destination.AboutScreen)
                                expended = false
                            }
                        )
                    }
                }
            )
        },
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    selected = homeScreenSelected,
                    onClick = { homeScreenSelected = true },
                    icon = {
                        Icon(
                            imageVector = if(homeScreenSelected) Icons.Default.Home else Icons.Outlined.Home,
                            contentDescription = stringResource(R.string.label_home)
                        )
                    },
                    label = {
                        Text(
                            text = stringResource(R.string.label_home)
                        )
                    }
                )
                NavigationBarItem(
                    selected = !homeScreenSelected,
                    onClick = { homeScreenSelected = false },
                    icon = {
                        Icon(
                            imageVector = if(!homeScreenSelected) Icons.Default.Person else Icons.Outlined.Person,
                            contentDescription = stringResource(R.string.label_profile)
                        )
                    },
                    label = {
                        Text(
                            text = stringResource(R.string.label_profile)
                        )
                    }
                )
            }
        }
    ) { innerPadding ->
        if(homeScreenSelected) HomeScreen( innerPadding, navController) else ProfileScreen(
            innerPadding
        )
    }
}

@Preview
@Composable
fun MainScreenPreview()
{
    MainScreen(rememberNavController())
}

