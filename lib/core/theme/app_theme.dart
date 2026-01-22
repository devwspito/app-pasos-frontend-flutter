import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Application theme configuration using Material Design 3.
///
/// Provides static theme data for light and dark modes with consistent
/// styling across all Material components.
abstract final class AppTheme {
  // ============================================================
  // Seed Color for Dynamic Color Schemes
  // ============================================================

  /// Primary seed color for generating color schemes
  static const Color seedColor = AppColors.primary;

  // ============================================================
  // Light Theme
  // ============================================================

  /// Light theme configuration
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.onInverseSurface,
      inversePrimary: AppColors.inversePrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.robotoTextTheme(AppTextStyles.lightTextTheme),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: _lightAppBarTheme(colorScheme),
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      filledButtonTheme: _filledButtonTheme(colorScheme),
      inputDecorationTheme: _lightInputDecorationTheme(colorScheme),
      floatingActionButtonTheme: _floatingActionButtonTheme(colorScheme),
      bottomNavigationBarTheme: _lightBottomNavigationBarTheme(colorScheme),
      navigationBarTheme: _lightNavigationBarTheme(colorScheme),
      chipTheme: _chipTheme(colorScheme),
      dialogTheme: _dialogTheme,
      snackBarTheme: _snackBarTheme(colorScheme),
      dividerTheme: _dividerTheme(colorScheme),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: AppSpacing.iconMd,
      ),
      listTileTheme: _listTileTheme(colorScheme),
      switchTheme: _switchTheme(colorScheme),
      checkboxTheme: _checkboxTheme(colorScheme),
      radioTheme: _radioTheme(colorScheme),
      progressIndicatorTheme: _progressIndicatorTheme(colorScheme),
      sliderTheme: _sliderTheme(colorScheme),
      tabBarTheme: _lightTabBarTheme(colorScheme),
      tooltipTheme: _tooltipTheme(colorScheme),
      bottomSheetTheme: _bottomSheetTheme,
      drawerTheme: _drawerTheme,
    );
  }

  // ============================================================
  // Dark Theme
  // ============================================================

  /// Dark theme configuration
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onSecondaryDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.onSecondaryContainerDark,
      tertiary: AppColors.tertiaryDark,
      onTertiary: AppColors.onTertiaryDark,
      tertiaryContainer: AppColors.tertiaryContainerDark,
      onTertiaryContainer: AppColors.onTertiaryContainerDark,
      error: AppColors.errorDark,
      onError: AppColors.onErrorDark,
      errorContainer: AppColors.errorContainerDark,
      onErrorContainer: AppColors.onErrorContainerDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      outline: AppColors.outlineDark,
      outlineVariant: AppColors.outlineVariantDark,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.inverseSurfaceDark,
      onInverseSurface: AppColors.onInverseSurfaceDark,
      inversePrimary: AppColors.inversePrimaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.robotoTextTheme(AppTextStyles.darkTextTheme),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: _darkAppBarTheme(colorScheme),
      cardTheme: _cardThemeDark,
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      filledButtonTheme: _filledButtonTheme(colorScheme),
      inputDecorationTheme: _darkInputDecorationTheme(colorScheme),
      floatingActionButtonTheme: _floatingActionButtonTheme(colorScheme),
      bottomNavigationBarTheme: _darkBottomNavigationBarTheme(colorScheme),
      navigationBarTheme: _darkNavigationBarTheme(colorScheme),
      chipTheme: _chipTheme(colorScheme),
      dialogTheme: _dialogThemeDark,
      snackBarTheme: _snackBarTheme(colorScheme),
      dividerTheme: _dividerTheme(colorScheme),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: AppSpacing.iconMd,
      ),
      listTileTheme: _listTileTheme(colorScheme),
      switchTheme: _switchTheme(colorScheme),
      checkboxTheme: _checkboxTheme(colorScheme),
      radioTheme: _radioTheme(colorScheme),
      progressIndicatorTheme: _progressIndicatorTheme(colorScheme),
      sliderTheme: _sliderTheme(colorScheme),
      tabBarTheme: _darkTabBarTheme(colorScheme),
      tooltipTheme: _tooltipTheme(colorScheme),
      bottomSheetTheme: _bottomSheetThemeDark,
      drawerTheme: _drawerThemeDark,
    );
  }

  // ============================================================
  // AppBar Themes
  // ============================================================

  static AppBarTheme _lightAppBarTheme(ColorScheme colorScheme) => AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: AppSpacing.iconMd,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: AppSpacing.iconMd,
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      );

  static AppBarTheme _darkAppBarTheme(ColorScheme colorScheme) => AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: AppSpacing.iconMd,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: AppSpacing.iconMd,
        ),
        titleTextStyle: AppTextStyles.titleLargeDark.copyWith(
          color: colorScheme.onSurface,
        ),
      );

  // ============================================================
  // Card Theme
  // ============================================================

  static const CardTheme _cardTheme = CardTheme(
    elevation: 1,
    margin: EdgeInsets.all(AppSpacing.sm),
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.borderRadiusMd,
    ),
    clipBehavior: Clip.antiAlias,
  );

  static const CardTheme _cardThemeDark = CardTheme(
    elevation: 1,
    margin: EdgeInsets.all(AppSpacing.sm),
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.borderRadiusMd,
    ),
    clipBehavior: Clip.antiAlias,
  );

  // ============================================================
  // Button Themes
  // ============================================================

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(64, AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme colorScheme) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(64, AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: AppTextStyles.labelLarge,
        ),
      );

  static TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(64, AppSpacing.buttonHeightSm),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      );

  static FilledButtonThemeData _filledButtonTheme(ColorScheme colorScheme) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(64, AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      );

  // ============================================================
  // Input Decoration Theme
  // ============================================================

  static InputDecorationTheme _lightInputDecorationTheme(
          ColorScheme colorScheme) =>
      InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: colorScheme.error),
        helperStyle: AppTextStyles.bodySmall
            .copyWith(color: colorScheme.onSurfaceVariant),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      );

  static InputDecorationTheme _darkInputDecorationTheme(
          ColorScheme colorScheme) =>
      InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        labelStyle: AppTextStyles.bodyMediumDark,
        hintStyle: AppTextStyles.bodyMediumDark
            .copyWith(color: colorScheme.onSurfaceVariant),
        errorStyle: AppTextStyles.bodySmallDark.copyWith(color: colorScheme.error),
        helperStyle: AppTextStyles.bodySmallDark
            .copyWith(color: colorScheme.onSurfaceVariant),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      );

  // ============================================================
  // FAB Theme
  // ============================================================

  static FloatingActionButtonThemeData _floatingActionButtonTheme(
          ColorScheme colorScheme) =>
      FloatingActionButtonThemeData(
        elevation: 3,
        focusElevation: 4,
        hoverElevation: 4,
        highlightElevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
      );

  // ============================================================
  // Bottom Navigation Bar Theme
  // ============================================================

  static BottomNavigationBarThemeData _lightBottomNavigationBarTheme(
          ColorScheme colorScheme) =>
      BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 2,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: AppTextStyles.labelMedium,
        unselectedLabelStyle: AppTextStyles.labelMedium,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      );

  static BottomNavigationBarThemeData _darkBottomNavigationBarTheme(
          ColorScheme colorScheme) =>
      BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 2,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: AppTextStyles.labelMediumDark,
        unselectedLabelStyle: AppTextStyles.labelMediumDark,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      );

  // ============================================================
  // Navigation Bar Theme (Material 3)
  // ============================================================

  static NavigationBarThemeData _lightNavigationBarTheme(
          ColorScheme colorScheme) =>
      NavigationBarThemeData(
        elevation: 2,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium.copyWith(color: colorScheme.primary);
          }
          return AppTextStyles.labelMedium
              .copyWith(color: colorScheme.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onSecondaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      );

  static NavigationBarThemeData _darkNavigationBarTheme(
          ColorScheme colorScheme) =>
      NavigationBarThemeData(
        elevation: 2,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMediumDark
                .copyWith(color: colorScheme.primary);
          }
          return AppTextStyles.labelMediumDark
              .copyWith(color: colorScheme.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onSecondaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      );

  // ============================================================
  // Chip Theme
  // ============================================================

  static ChipThemeData _chipTheme(ColorScheme colorScheme) => ChipThemeData(
        elevation: 0,
        pressElevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        labelStyle: AppTextStyles.labelMedium,
        secondaryLabelStyle: AppTextStyles.labelMedium,
        side: BorderSide(color: colorScheme.outline),
      );

  // ============================================================
  // Dialog Theme
  // ============================================================

  static const DialogTheme _dialogTheme = DialogTheme(
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.borderRadiusXl,
    ),
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
  );

  static const DialogTheme _dialogThemeDark = DialogTheme(
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.borderRadiusXl,
    ),
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
  );

  // ============================================================
  // SnackBar Theme
  // ============================================================

  static SnackBarThemeData _snackBarTheme(ColorScheme colorScheme) =>
      SnackBarThemeData(
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
      );

  // ============================================================
  // Divider Theme
  // ============================================================

  static DividerThemeData _dividerTheme(ColorScheme colorScheme) =>
      DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: AppSpacing.md,
      );

  // ============================================================
  // ListTile Theme
  // ============================================================

  static ListTileThemeData _listTileTheme(ColorScheme colorScheme) =>
      ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        iconColor: colorScheme.onSurfaceVariant,
      );

  // ============================================================
  // Switch Theme
  // ============================================================

  static SwitchThemeData _switchTheme(ColorScheme colorScheme) =>
      SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return colorScheme.outline;
        }),
      );

  // ============================================================
  // Checkbox Theme
  // ============================================================

  static CheckboxThemeData _checkboxTheme(ColorScheme colorScheme) =>
      CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outline, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      );

  // ============================================================
  // Radio Theme
  // ============================================================

  static RadioThemeData _radioTheme(ColorScheme colorScheme) => RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
      );

  // ============================================================
  // Progress Indicator Theme
  // ============================================================

  static ProgressIndicatorThemeData _progressIndicatorTheme(
          ColorScheme colorScheme) =>
      ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      );

  // ============================================================
  // Slider Theme
  // ============================================================

  static SliderThemeData _sliderTheme(ColorScheme colorScheme) =>
      SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.12),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: AppTextStyles.labelMedium.copyWith(
          color: colorScheme.onPrimary,
        ),
      );

  // ============================================================
  // TabBar Theme
  // ============================================================

  static TabBarTheme _lightTabBarTheme(ColorScheme colorScheme) => TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: AppTextStyles.titleSmall,
        unselectedLabelStyle: AppTextStyles.titleSmall,
        indicatorColor: colorScheme.primary,
        dividerColor: colorScheme.outlineVariant,
        indicatorSize: TabBarIndicatorSize.tab,
      );

  static TabBarTheme _darkTabBarTheme(ColorScheme colorScheme) => TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: AppTextStyles.titleSmallDark,
        unselectedLabelStyle: AppTextStyles.titleSmallDark,
        indicatorColor: colorScheme.primary,
        dividerColor: colorScheme.outlineVariant,
        indicatorSize: TabBarIndicatorSize.tab,
      );

  // ============================================================
  // Tooltip Theme
  // ============================================================

  static TooltipThemeData _tooltipTheme(ColorScheme colorScheme) =>
      TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      );

  // ============================================================
  // Bottom Sheet Theme
  // ============================================================

  static const BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSpacing.radiusXl),
        topRight: Radius.circular(AppSpacing.radiusXl),
      ),
    ),
    showDragHandle: true,
  );

  static const BottomSheetThemeData _bottomSheetThemeDark =
      BottomSheetThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSpacing.radiusXl),
        topRight: Radius.circular(AppSpacing.radiusXl),
      ),
    ),
    showDragHandle: true,
  );

  // ============================================================
  // Drawer Theme
  // ============================================================

  static const DrawerThemeData _drawerTheme = DrawerThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(AppSpacing.radiusLg),
        bottomRight: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
  );

  static const DrawerThemeData _drawerThemeDark = DrawerThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(AppSpacing.radiusLg),
        bottomRight: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
  );
}
