import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';

class AppTheme {
  // الثيم الفاتح
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConfig.primaryColor,
      brightness: Brightness.light,
      primary: AppConfig.primaryColor,
      secondary: AppConfig.secondaryColor,
      tertiary: AppConfig.secondaryColor,
      error: AppConfig.errorColor,
      surface: AppConfig.backgroundColor,
    ),
    useMaterial3: true,
    fontFamily: AppConfig.primaryFont,

    // تخصيص AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppConfig.primaryColor,
      foregroundColor: Colors.white,
      elevation: AppConfig.cardElevation,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: AppConfig.fontSizeXXLarge,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      shadowColor: AppConfig.primaryColor.withValues(alpha: 0.3),
    ),

    // تخصيص الأزرار
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: AppConfig.buttonElevation,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConfig.spacingLG,
          vertical: AppConfig.spacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: AppConfig.fontSizeLarge,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // تخصيص حقول النص
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppConfig.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: AppConfig.borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: AppConfig.borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: AppConfig.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: AppConfig.errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConfig.spacingLG,
        vertical: AppConfig.spacingLG,
      ),
      labelStyle: GoogleFonts.cairo(
        color: AppConfig.textSecondaryColor,
        fontSize: AppConfig.fontSizeLarge,
      ),
      hintStyle: GoogleFonts.cairo(
        color: AppConfig.textLightColor,
        fontSize: AppConfig.fontSizeMedium,
      ),
    ),

    // تخصيص البطاقات
    cardTheme: CardThemeData(
      elevation: AppConfig.cardElevation,
      shadowColor: AppConfig.primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      margin: const EdgeInsets.all(AppConfig.spacingSM),
      color: AppConfig.cardColor,
    ),

    // تخصيص قوائم البيانات
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateColor.resolveWith(
        (states) => AppConfig.primaryColor.withValues(alpha: 0.1),
      ),
      headingTextStyle: GoogleFonts.cairo(
        fontWeight: FontWeight.bold,
        color: AppConfig.primaryColor,
        fontSize: AppConfig.fontSizeMedium,
      ),
      dataTextStyle: GoogleFonts.cairo(
        color: AppConfig.textPrimaryColor,
        fontSize: AppConfig.fontSizeMedium,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppConfig.borderColor),
        borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
      ),
    ),

    // تخصيص شريط التنقل السفلي
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppConfig.surfaceColor,
      selectedItemColor: AppConfig.primaryColor,
      unselectedItemColor: AppConfig.textSecondaryColor,
      elevation: AppConfig.cardElevation,
      type: BottomNavigationBarType.fixed,
    ),

    // تخصيص شريط التنقل العلوي
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppConfig.surfaceColor,
      indicatorColor: AppConfig.primaryColor.withValues(alpha: 0.1),
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.cairo(
          fontSize: AppConfig.fontSizeSmall,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // تخصيص شريط التقدم
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppConfig.primaryColor,
      linearTrackColor: AppConfig.borderColor,
    ),

    // تخصيص النوافذ المنبثقة
    dialogTheme: DialogThemeData(
      backgroundColor: AppConfig.surfaceColor,
      elevation: AppConfig.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
    ),

    // تخصيص الشرائح
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppConfig.primaryColor;
        }
        return AppConfig.borderColor;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppConfig.primaryColor.withValues(alpha: 0.3);
        }
        return AppConfig.borderColor.withValues(alpha: 0.3);
      }),
    ),

    // تخصيص مربعات الاختيار
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppConfig.primaryColor;
        }
        return AppConfig.borderColor;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
    ),

    // تخصيص أزرار الراديو
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppConfig.primaryColor;
        }
        return AppConfig.borderColor;
      }),
    ),

    // تخصيص الشرائح
    sliderTheme: SliderThemeData(
      activeTrackColor: AppConfig.primaryColor,
      inactiveTrackColor: AppConfig.borderColor,
      thumbColor: AppConfig.primaryColor,
      overlayColor: AppConfig.primaryColor.withValues(alpha: 0.2),
    ),
  );

  // الثيم الداكن
  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConfig.primaryColor,
      brightness: Brightness.dark,
      primary: AppConfig.primaryColor,
      secondary: AppConfig.secondaryColor,
      tertiary: AppConfig.secondaryColor,
      error: AppConfig.errorColor,
      surface: AppConfig.darkBackgroundColor,
    ),
    useMaterial3: true,
    fontFamily: AppConfig.primaryFont,

    // تخصيص AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppConfig.darkBackgroundColor,
      foregroundColor: Colors.white,
      elevation: AppConfig.cardElevation,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: AppConfig.fontSizeXXLarge,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      shadowColor: AppConfig.darkBackgroundColor.withValues(alpha: 0.3),
    ),

    // تخصيص الأزرار
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: AppConfig.buttonElevation,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConfig.spacingLG,
          vertical: AppConfig.spacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: AppConfig.fontSizeLarge,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // تخصيص حقول النص
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppConfig.darkSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: AppConfig.borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: AppConfig.borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: AppConfig.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: AppConfig.errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConfig.spacingLG,
        vertical: AppConfig.spacingLG,
      ),
      labelStyle: GoogleFonts.cairo(
        color: AppConfig.textLightColor,
        fontSize: AppConfig.fontSizeLarge,
      ),
      hintStyle: GoogleFonts.cairo(
        color: AppConfig.textLightColor.withValues(alpha: 0.7),
        fontSize: AppConfig.fontSizeMedium,
      ),
    ),

    // تخصيص البطاقات
    cardTheme: CardThemeData(
      elevation: AppConfig.cardElevation,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      margin: const EdgeInsets.all(AppConfig.spacingSM),
      color: AppConfig.darkCardColor,
    ),

    // تخصيص قوائم البيانات
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateColor.resolveWith(
        (states) => AppConfig.primaryColor.withValues(alpha: 0.2),
      ),
      headingTextStyle: GoogleFonts.cairo(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: AppConfig.fontSizeMedium,
      ),
      dataTextStyle: GoogleFonts.cairo(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: AppConfig.fontSizeMedium,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppConfig.borderColor),
        borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
      ),
    ),

    // تخصيص شريط التنقل السفلي
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppConfig.darkSurfaceColor,
      selectedItemColor: AppConfig.primaryColor,
      unselectedItemColor: AppConfig.textLightColor,
      elevation: AppConfig.cardElevation,
      type: BottomNavigationBarType.fixed,
    ),

    // تخصيص شريط التنقل العلوي
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppConfig.darkSurfaceColor,
      indicatorColor: AppConfig.primaryColor.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.cairo(
          fontSize: AppConfig.fontSizeSmall,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    ),

    // تخصيص شريط التقدم
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppConfig.primaryColor,
      linearTrackColor: AppConfig.borderColor,
    ),

    // تخصيص النوافذ المنبثقة
    dialogTheme: DialogThemeData(
      backgroundColor: AppConfig.darkSurfaceColor,
      elevation: AppConfig.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
    ),

    // تخصيص الشرائح
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppConfig.primaryColor;
        }
        return AppConfig.borderColor;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppConfig.primaryColor.withValues(alpha: 0.3);
        }
        return AppConfig.borderColor.withValues(alpha: 0.3);
      }),
    ),

    // تخصيص مربعات الاختيار
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppConfig.primaryColor;
        }
        return AppConfig.borderColor;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
    ),

    // تخصيص أزرار الراديو
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppConfig.primaryColor;
        }
        return AppConfig.borderColor;
      }),
    ),

    // تخصيص الشرائح
    sliderTheme: SliderThemeData(
      activeTrackColor: AppConfig.primaryColor,
      inactiveTrackColor: AppConfig.borderColor,
      thumbColor: AppConfig.primaryColor,
      overlayColor: AppConfig.primaryColor.withValues(alpha: 0.2),
    ),
  );
}
