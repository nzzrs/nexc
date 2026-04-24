/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.components

import android.graphics.BitmapFactory
import androidx.annotation.DrawableRes
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalResources

/**
 * A Composable function that reads a drawable's dimensions and returns its aspect ratio without loading the full bitmap into memory.
 * This project uses it to ensure correct sizes of async images in lazy columns in order to correctly set visible items on first composition.
 *
 * @param id The resource ID of the drawable.
 * @return The aspect ratio (width / height) of the drawable.
 */
@Composable
fun rememberDrawableAspectRatio(@DrawableRes id: Int): Float {
    val resources = LocalResources.current

    return remember(id) {
        // Create options and set inJustDecodeBounds to true which prevents memory allocation for the pixels.
        val options = BitmapFactory.Options().apply {
            inJustDecodeBounds = true
        }

        // It will not return a bitmap, but it will populate the outWidth and outHeight properties in 'options'.
        BitmapFactory.decodeResource(resources, id, options)

        val width = options.outWidth
        val height = options.outHeight

        // Calculate and return the aspect ratio. Add a check to prevent division by zero.
        if (height > 0) {
            width.toFloat() / height.toFloat()
        } else {
            1f // Default to a square aspect ratio as a fallback
        }
    }
}

/**
 * A Composable function that reads a asset's dimensions and returns its aspect ratio without loading the full bitmap into memory.
 * This project uses it to ensure correct sizes of async images in lazy columns in order to correctly set visible items on first composition.
 *
 * @param assetPath The path of the asset.
 * @param defaultRatio The ratio returned if something goes wrong
 * @return The aspect ratio (width / height) of the asset.
 */
@Composable
fun rememberAssetAspectRatio(assetPath: String?, defaultRatio: Float): Float {
    val context = LocalContext.current

    if (assetPath == null) return defaultRatio

    return remember(assetPath) {
        runCatching {
            // 'use' to auto-close the InputStream explicitly
            context.assets.open(assetPath).use { stream ->
                val options = BitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }

                // Decode header only
                BitmapFactory.decodeStream(stream, null, options)

                val width = options.outWidth
                val height = options.outHeight

                if (height > 0) {
                    width.toFloat() / height.toFloat()
                } else {
                    1f
                }
            }
        }.getOrDefault(defaultRatio)
    }
}