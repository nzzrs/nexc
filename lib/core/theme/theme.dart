/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

final lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: primaryLight,
  onPrimary: onPrimaryLight,
  primaryContainer: primaryContainerLight,
  onPrimaryContainer: onPrimaryContainerLight,
  secondary: secondaryLight,
  onSecondary: onSecondaryLight,
  secondaryContainer: secondaryContainerLight,
  onSecondaryContainer: onSecondaryContainerLight,
  tertiary: tertiaryLight,
  onTertiary: onTertiaryLight,
  tertiaryContainer: tertiaryContainerLight,
  onTertiaryContainer: onTertiaryContainerLight,
  error: errorLight,
  onError: onErrorLight,
  errorContainer: errorContainerLight,
  onErrorContainer: onErrorContainerLight,
  surface: surfaceLight,
  onSurface: onSurfaceLight,
  surfaceContainerHighest: surfaceContainerHighestLight,
  outline: outlineLight,
  outlineVariant: outlineVariantLight,
  scrim: scrimLight,
  inverseSurface: inverseSurfaceLight,
  onInverseSurface: inverseOnSurfaceLight,
  inversePrimary: inversePrimaryLight,
);

final darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: primaryDark,
  onPrimary: onPrimaryDark,
  primaryContainer: primaryContainerDark,
  onPrimaryContainer: onPrimaryContainerDark,
  secondary: secondaryDark,
  onSecondary: onSecondaryDark,
  secondaryContainer: secondaryContainerDark,
  onSecondaryContainer: onSecondaryContainerDark,
  tertiary: tertiaryDark,
  onTertiary: onTertiaryDark,
  tertiaryContainer: tertiaryContainerDark,
  onTertiaryContainer: onTertiaryContainerDark,
  error: errorDark,
  onError: onErrorDark,
  errorContainer: errorContainerDark,
  onErrorContainer: onErrorContainerDark,
  surface: surfaceDark,
  onSurface: onSurfaceDark,
  surfaceContainerHighest: surfaceContainerHighestDark,
  outline: outlineDark,
  outlineVariant: outlineVariantDark,
  scrim: scrimDark,
  inverseSurface: inverseSurfaceDark,
  onInverseSurface: inverseOnSurfaceDark,
  inversePrimary: inversePrimaryDark,
);

ThemeData createNexcTheme(ColorScheme scheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: nexcTextTheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: scheme.onSurface),
      titleTextStyle: nexcTextTheme.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    ),
    // Material 3 Expressive uses extra-rounded components (28dp corners)
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      color: scheme.brightness == Brightness.light
          ? surfaceContainerLight
          : surfaceContainerDark,
    ),
    buttonTheme: const ButtonThemeData(
      alignedDropdown: true,
    ),
    // M3 Expressive buttons are fully rounded (StadiumBorder)
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 3,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.brightness == Brightness.light
          ? surfaceContainerLight
          : surfaceContainerDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: scheme.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return nexcTextTheme.labelMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
          );
        }
        return nexcTextTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: scheme.onSecondaryContainer);
        }
        return IconThemeData(color: scheme.onSurfaceVariant);
      }),
    ),
  );
}

final nexcLightTheme = createNexcTheme(lightColorScheme);
final nexcDarkTheme = createNexcTheme(darkColorScheme);
