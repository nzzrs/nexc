/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';

/// Localized strings for the current [BuildContext].
///
/// Widget tests and previews sometimes pump a screen without the generated
/// localization delegates installed. In that case [AppLocalizations.of]
/// returns null, so the extension falls back to the generated English bundle
/// instead of throwing. This keeps the English UI byte-identical for callers
/// that never install the delegates.
extension L10nContext on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsEn();
}
