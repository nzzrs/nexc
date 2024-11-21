package org.librefit.ui.screens.about

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ExitToApp
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import org.librefit.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LicenseScreen(navigateBack: () -> Unit) {
    val licenseText = rememberSaveable { mutableStateOf("") }

    val context = LocalContext.current

    LaunchedEffect(Unit) {
        licenseText.value = loadLicenseText(context)
    }


    val clipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

    var showDialog by remember { mutableStateOf(false) }

    var url = stringResource(R.string.url_gpl3)

    if (showDialog) {
        AlertDialog(
            onDismissRequest = { showDialog = false },
            confirmButton = {
                TextButton(
                    onClick = {
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            data = Uri.parse(url)
                        }
                        context.startActivity(intent)
                        showDialog = false
                    }
                ) {
                    Text(stringResource(R.string.label_open))
                }
            },
            dismissButton = {
                TextButton(
                    onClick = {
                        val clip = ClipData.newPlainText("Copied Url", url)
                        clipboardManager.setPrimaryClip(clip)
                        showDialog = false
                    }
                ) {
                    Text(stringResource(R.string.label_copy))
                }
            },
            text = { Text(text = url) }
        )
    }


    Scaffold(
        topBar = {
            TopAppBar(title = {
                Text(text = stringResource(id = R.string.label_license))
            }, navigationIcon = {
                IconButton(
                    onClick = navigateBack
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Default.ArrowBack,
                        contentDescription = stringResource(id = R.string.label_navigate_back)
                    )
                }
            })
        },
    ) { innerPadding ->
        Column(
            modifier = Modifier.padding(innerPadding),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Button(
                modifier = Modifier.fillMaxWidth(),
                onClick = {
                    showDialog = true
                }
            ) {
                Text(stringResource(R.string.label_view_gpl3_online))
                Icon(
                    imageVector = Icons.AutoMirrored.Default.ExitToApp,
                    contentDescription = null
                )
            }
            HorizontalDivider()
            Box(
                modifier = Modifier
                    .padding(start = 15.dp, end = 15.dp)
                    .verticalScroll(rememberScrollState())
                    .horizontalScroll(rememberScrollState())
                    .fillMaxSize()
                    .weight(1f),
            ) {
                Text(licenseText.value)
            }
        }
    }
}

private fun loadLicenseText(context: Context): String {
    val inputStream = context.resources.openRawResource(R.raw.license)
    return inputStream.bufferedReader().use { it.readText() }
}