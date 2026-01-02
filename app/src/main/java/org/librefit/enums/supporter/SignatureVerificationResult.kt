/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The LibreFit Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.librefit.enums.supporter

import android.content.pm.Signature


sealed class SignatureVerificationResult {
    data class Success(val signatures: Set<Signature>) : SignatureVerificationResult()
    object NoSignatureFound : SignatureVerificationResult()
    object PackageNotFound : SignatureVerificationResult()
    object UnknownError : SignatureVerificationResult()
}