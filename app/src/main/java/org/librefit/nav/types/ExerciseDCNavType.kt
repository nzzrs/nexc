/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.nav.types

import android.net.Uri
import android.os.Bundle
import androidx.navigation.NavType
import kotlinx.serialization.json.Json
import org.librefit.db.entity.ExerciseDC

class ExerciseDCNavType : NavType<ExerciseDC>(isNullableAllowed = false) {

    override fun get(bundle: Bundle, key: String): ExerciseDC? {
        val json = bundle.getString(key)
        return json?.let { Json.decodeFromString(it) }
    }

    override fun parseValue(value: String): ExerciseDC {
        val decoded = Uri.decode(value)
        return Json.Default.decodeFromString(decoded)
    }

    override fun put(bundle: Bundle, key: String, value: ExerciseDC) {
        val json = Json.Default.encodeToString(value)
        bundle.putString(key, json)
    }

    override fun serializeAsValue(value: ExerciseDC): String {
        val json = Json.Default.encodeToString(value)
        return Uri.encode(json)
    }
}