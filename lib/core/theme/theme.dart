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
import 'shapes.dart';
import 'spacing.dart';
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
  surfaceContainerLowest: surfaceContainerLowestLight,
  surfaceContainerLow: surfaceContainerLowLight,
  surfaceContainer: surfaceContainerLight,
  surfaceContainerHigh: surfaceContainerHighLight,
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
  surfaceContainerLowest: surfaceContainerLowestDark,
  surfaceContainerLow: surfaceContainerLowDark,
  surfaceContainer: surfaceContainerDark,
  surfaceContainerHigh: surfaceContainerHighDark,
  surfaceContainerHighest: surfaceContainerHighestDark,
  outline: outlineDark,
  outlineVariant: outlineVariantDark,
  scrim: scrimDark,
  inverseSurface: inverseSurfaceDark,
  onInverseSurface: inverseOnSurfaceDark,
  inversePrimary: inversePrimaryDark,
);

ThemeData createNexcTheme(ColorScheme scheme) {
  final bool isLight = scheme.brightness == Brightness.light;
  final Color cardColor = isLight
      ? surfaceContainerLowLight
      : surfaceContainerLowDark;
  final Color groupColor = isLight
      ? surfaceContainerLight
      : surfaceContainerDark;
  final Color fieldColor = isLight
      ? surfaceContainerHighestLight
      : surfaceContainerHighestDark;
  final TextTheme text = nexcTextTheme;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: text,
    scaffoldBackgroundColor: scheme.surface,
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: scheme.onSurface),
      titleTextStyle: text.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.lgRadius),
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cardColor,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.xlRadius),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: NexcSpacing.xl,
        vertical: NexcSpacing.xl,
      ),
      titleTextStyle: text.headlineSmall?.copyWith(color: scheme.onSurface),
      contentTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: scheme.surfaceContainerLow,
      showDragHandle: true,
      dragHandleColor: scheme.outlineVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NexcShapes.xl),
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.smRadius),
      insetPadding: const EdgeInsets.all(NexcSpacing.lg),
      elevation: 3,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: groupColor,
      selectedColor: scheme.secondaryContainer,
      disabledColor: groupColor.withValues(alpha: 0.4),
      labelStyle: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
      secondaryLabelStyle: text.labelLarge?.copyWith(
        color: scheme.onSecondaryContainer,
      ),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(
        horizontal: NexcSpacing.md,
        vertical: NexcSpacing.sm,
      ),
      showCheckmark: false,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      titleTextStyle: text.titleMedium?.copyWith(color: scheme.onSurface),
      subtitleTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: NexcSpacing.lg,
        vertical: NexcSpacing.xs,
      ),
      minVerticalPadding: NexcSpacing.md,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.mdRadius),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        selectedBackgroundColor: scheme.secondaryContainer,
        selectedForegroundColor: scheme.onSecondaryContainer,
        foregroundColor: scheme.onSurfaceVariant,
        backgroundColor: groupColor,
        textStyle: text.labelLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: NexcSpacing.lg,
          vertical: NexcSpacing.md,
        ),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      labelStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      unselectedLabelStyle: text.titleSmall,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: scheme.primary, width: 3),
        borderRadius: NexcShapes.fullRadius,
      ),
      overlayColor: WidgetStatePropertyAll(
        scheme.primary.withValues(alpha: 0.06),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.onPrimary;
        }
        return scheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primary;
        }
        return scheme.surfaceContainerHighest;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      textColor: scheme.onSurface,
      collapsedTextColor: scheme.onSurface,
      iconColor: scheme.onSurfaceVariant,
      collapsedIconColor: scheme.onSurfaceVariant,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.mdRadius),
      collapsedShape: const RoundedRectangleBorder(
        borderRadius: NexcShapes.mdRadius,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(
        NexcSpacing.lg,
        0,
        NexcSpacing.lg,
        NexcSpacing.lg,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      circularTrackColor: Colors.transparent,
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(3),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: NexcShapes.mdRadius),
        ),
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.xlRadius),
      hourMinuteShape: const RoundedRectangleBorder(
        borderRadius: NexcShapes.mdRadius,
      ),
      dayPeriodShape: const RoundedRectangleBorder(
        borderRadius: NexcShapes.mdRadius,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: NexcShapes.xsRadius,
      ),
      textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
    ),
    // Material 3 Expressive: fully rounded actions.
    buttonTheme: const ButtonThemeData(alignedDropdown: true),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(0, NexcSpacing.touchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: NexcSpacing.xl,
          vertical: NexcSpacing.md,
        ),
        textStyle: text.labelLarge,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(0, NexcSpacing.touchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: NexcSpacing.xl,
          vertical: NexcSpacing.md,
        ),
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(0, NexcSpacing.touchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: NexcSpacing.xl,
          vertical: NexcSpacing.md,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(0, NexcSpacing.touchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: NexcSpacing.lg,
          vertical: NexcSpacing.md,
        ),
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(
          NexcSpacing.touchTarget,
          NexcSpacing.touchTarget,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: NexcShapes.fullRadius,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: const RoundedRectangleBorder(borderRadius: NexcShapes.lgRadius),
      elevation: 3,
      highlightElevation: 3,
      extendedTextStyle: text.labelLarge,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fieldColor,
      border: const OutlineInputBorder(
        borderRadius: NexcShapes.smRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: NexcShapes.smRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: NexcShapes.smRadius,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: NexcShapes.smRadius,
        borderSide: BorderSide(color: scheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: NexcShapes.smRadius,
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: NexcSpacing.lg,
        vertical: NexcSpacing.md,
      ),
      labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      hintStyle: text.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 72,
      indicatorShape: const StadiumBorder(),
      indicatorColor: scheme.secondaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return text.labelMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
          );
        }
        return text.labelMedium?.copyWith(color: scheme.onSurfaceVariant);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: scheme.onSecondaryContainer);
        }
        return IconThemeData(color: scheme.onSurfaceVariant);
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      indicatorShape: const StadiumBorder(),
      selectedIconTheme: IconThemeData(color: scheme.onSecondaryContainer),
      unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      selectedLabelTextStyle: text.labelMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: text.labelMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
  );
}

final nexcLightTheme = createNexcTheme(lightColorScheme);
final nexcDarkTheme = createNexcTheme(darkColorScheme);
