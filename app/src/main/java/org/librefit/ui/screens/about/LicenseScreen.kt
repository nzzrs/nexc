package org.librefit.ui.screens.about

import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch
import org.librefit.MainActivity
import org.librefit.R
import java.io.BufferedReader
import java.io.InputStreamReader

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LicenseScreen(navigateBack : () -> Unit) {
    val licenseText = rememberSaveable { mutableStateOf("") }

    val coroutineScope = rememberCoroutineScope()
    LaunchedEffect(Unit) {
        coroutineScope.launch {
            val text = loadLicenseText()
            licenseText.value = text
        }
    }

    Scaffold (
        topBar = {
            TopAppBar(
                title = {
                    Text(text = stringResource(id = R.string.label_license))
                },
                navigationIcon = {
                    IconButton(
                        onClick = navigateBack
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
        Box(modifier = Modifier
            .padding(innerPadding)
            .padding(start = 15.dp, end = 15.dp)
            .verticalScroll(rememberScrollState())
            .horizontalScroll(rememberScrollState())
            .fillMaxSize())
        { Text(licenseText.value) }
    }
}

private fun loadLicenseText(): String {
    val inputStream = MainActivity::class.java.getResourceAsStream("/res/raw/license")
        ?: throw IllegalArgumentException("File not found")
    val reader = BufferedReader(InputStreamReader(inputStream))
    return reader.use { it.readText() }
}