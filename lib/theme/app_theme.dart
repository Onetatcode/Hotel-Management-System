import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  // Radii
  static const double radiusIcon = 14;
  static const double radiusInput = 16;
  static const double radiusCard = 20;
  static const double radiusDialog = 24;
  static const double radiusPill = 999;
}

class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.lime,
      onPrimary: AppColors.background,
      primaryContainer: Color(0xFF2A3319),
      onPrimaryContainer: AppColors.lime,
      secondary: AppColors.lime,
      onSecondary: AppColors.background,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.elevated,
      onSurfaceVariant: AppColors.textMuted,
      outline: AppColors.highlight,
      error: AppColors.softRed,
      onError: AppColors.background,
    );

    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme.copyWith(
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        titleSmall: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.elevated,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusCard)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.elevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusDialog),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontFamily: 'Manrope',
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontFamily: 'Manrope',
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.elevated,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: AppColors.textMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusDialog),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.elevated,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        floatingLabelStyle: const TextStyle(
          color: AppColors.lime,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: BorderSide(
            color: AppColors.highlight.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: BorderSide(
            color: AppColors.lime.withValues(alpha: 0.7),
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: BorderSide(
            color: AppColors.softRed.withValues(alpha: 0.6),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: BorderSide(
            color: AppColors.softRed.withValues(alpha: 0.9),
            width: 1.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.highlight,
          disabledForegroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(fontFamily: 'Manrope'),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textMuted,
          side: BorderSide(color: AppColors.highlight.withValues(alpha: 0.8)),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(fontFamily: 'Manrope'),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lime,
          textStyle: textTheme.labelLarge?.copyWith(fontFamily: 'Manrope'),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusIcon),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lime,
        foregroundColor: AppColors.background,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.lime,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.background
                : AppColors.textMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            fontWeight:
                states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.textPrimary
                : AppColors.textMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.lime,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusIcon),
        ),
        selectedIconTheme: const IconThemeData(color: AppColors.background),
        unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          fontFamily: 'Manrope',
          color: AppColors.textMuted,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.lime,
        labelStyle: const TextStyle(
          fontFamily: 'Manrope',
          color: AppColors.textMuted,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Manrope',
          color: AppColors.background,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: AppColors.highlight.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.elevated,
        contentTextStyle: const TextStyle(
          fontFamily: 'Manrope',
          color: AppColors.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        ),
        insetPadding: const EdgeInsets.all(16),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.highlight.withValues(alpha: 0.6),
        thickness: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.lime,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.lime,
        selectionColor: Color(0x55B6FF3C),
        selectionHandleColor: AppColors.lime,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(AppColors.elevated),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
            ),
          ),
        ),
      ),
    );
  }
}
