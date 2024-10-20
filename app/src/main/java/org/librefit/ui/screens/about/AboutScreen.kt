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

package org.librefit.ui.screens.about

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedCard
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavHostController
import androidx.navigation.compose.rememberNavController
import org.librefit.R
import org.librefit.nav.Destination
import org.librefit.ui.components.HeadlineText

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AboutScreen(navController : NavHostController) {

    val context = LocalContext.current

    Scaffold (
        topBar = {
            TopAppBar(
                title = {
                    Text(text = stringResource(id = R.string.label_about))
                },
                navigationIcon = {
                    IconButton(
                        onClick = { navController.popBackStack() }
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Default.ArrowBack,
                            contentDescription = stringResource(id = R.string.label_navigate_back)
                        )
                    }
                }
            )
        },
    ) { innerPadding ->

        Column (
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues = innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(start = 15.dp, end = 15.dp),
            verticalArrangement = Arrangement.spacedBy(15.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ){

            val logoSize = 170.dp
            Image(
                imageVector = ImageVector.vectorResource(id = R.drawable.ic_logo),
                contentDescription = null,
                modifier = Modifier
                    .size(logoSize)
                    .border(
                        BorderStroke(1.dp, MaterialTheme.colorScheme.surfaceContainer),
                        RoundedCornerShape(logoSize)
                    )
            )


            HeadlineText(text =  stringResource(R.string.label_support_project))

            AboutItem(
                Icons.Default.Favorite,
                text = stringResource(R.string.label_donate),
                onClick = {
//                    val intent = Intent(Intent.ACTION_VIEW).apply {
//                        data = Uri.parse(context.getString( ))
//                    }
//                    context.startActivity(intent)
                },
                enabled = false
            )

            AboutItem(
                ImageVector.vectorResource(R.drawable.ic_handshake),
                text = stringResource(R.string.label_contribute),
                onClick = {},
                false
            )

            AboutItem(
                ImageVector.vectorResource(R.drawable.ic_translate),
                stringResource(R.string.label_translate),
                onClick = {},
                false
            )


            HeadlineText(text = stringResource(R.string.label_info))

            AboutItem(
                ImageVector.vectorResource(R.drawable.ic_policy),
                stringResource(R.string.label_privacy_policy),
                onClick = {
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        data = Uri.parse(context.getString(R.string.url_privacy))
                    }
                    context.startActivity(intent)
                }

            )

            AboutItem(
                ImageVector.vectorResource(R.drawable.ic_globe),
                stringResource(R.string.label_website),
                onClick = {
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        data = Uri.parse(context.getString(R.string.url_website))
                    }
                    context.startActivity(intent)
                }
            )

            AboutItem(
                ImageVector.vectorResource(R.drawable.ic_source_code),
                stringResource(R.string.label_source_code),
                onClick = {
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        data = Uri.parse(context.getString(R.string.url_source_code))
                    }
                    context.startActivity(intent)
                }
            )


            AboutItem(
                ImageVector.vectorResource(R.drawable.ic_license),
                stringResource(R.string.label_license),
                onClick = {
                    navController.navigate(Destination.LicenseScreen)
                }
            )

            HeadlineText(stringResource(R.string.label_contributors))

            AboutItem(
                Icons.Default.Person,
                "IamDg",
                onClick = {
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        data = Uri.parse(context.getString(R.string.url_IamDg))
                    }
                    context.startActivity(intent)
                }
            )
        }
    }
}

@Composable
private fun AboutItem(
    imageVector: ImageVector,
    text: String,
    onClick : () -> Unit,
    enabled : Boolean = true
){

    OutlinedCard(
        enabled = enabled,
        onClick = onClick
    ) {
        Row (
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .height(50.dp)
        ){
            Spacer(modifier = Modifier.width(20.dp))
            Icon(
                imageVector = imageVector,
                contentDescription = "$text icon"
            )
            Spacer(modifier = Modifier.width(20.dp))
            Text(
                text = text,
                fontSize = 20.sp
            )
        }
    }
}



@Preview
@Composable
private fun AboutScreenPreview(){
    AboutScreen (rememberNavController())
}