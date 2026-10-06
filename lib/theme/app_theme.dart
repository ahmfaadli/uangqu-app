import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  // ============================================================
  // CONSTANT
  // ============================================================

  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color darkPurple = Color(0xFF8B5CF6);

  static const String _themeKey = 'uangqu_theme_mode';

  // ============================================================
  // THEME MODE
  // ============================================================

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  // ============================================================
  // LOAD THEME
  // ============================================================

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final String? savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }

  // ============================================================
  // CHANGE THEME
  // ============================================================

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _themeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // ----------------------------------------------------------
    // BACKGROUND
    // ----------------------------------------------------------

    scaffoldBackgroundColor: const Color(0xFFF8F7FC),

    // ----------------------------------------------------------
    // COLOR SCHEME
    // ----------------------------------------------------------

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPurple,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryPurple,
      secondary: primaryPurple,
      surface: Colors.white,
      onSurface: const Color(0xFF18181B),
    ),

    // ----------------------------------------------------------
    // APP BAR
    // ----------------------------------------------------------

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF18181B),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),

    // ----------------------------------------------------------
    // TEXT
    // ----------------------------------------------------------

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Color(0xFF18181B),
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF18181B),
      ),
      bodySmall: TextStyle(
        color: Color(0xFF667085),
      ),
      titleLarge: TextStyle(
        color: Color(0xFF18181B),
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: Color(0xFF18181B),
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: Color(0xFF18181B),
        fontWeight: FontWeight.w600,
      ),
    ),

    // ----------------------------------------------------------
    // INPUT
    // ----------------------------------------------------------

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryPurple,
          width: 1.5,
        ),
      ),

      hintStyle: const TextStyle(
        color: Color(0xFF98A2B3),
      ),

      labelStyle: const TextStyle(
        color: Color(0xFF667085),
      ),
    ),

    // ----------------------------------------------------------
    // CARD
    // ----------------------------------------------------------

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    // ----------------------------------------------------------
    // DIVIDER
    // ----------------------------------------------------------

    dividerTheme: const DividerThemeData(
      color: Color(0xFFF0EEF5),
      thickness: 1,
    ),

    // ----------------------------------------------------------
    // DIALOG
    // ----------------------------------------------------------

    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // ----------------------------------------------------------
    // SNACKBAR
    // ----------------------------------------------------------

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF18181B),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // ----------------------------------------------------------
    // BOTTOM SHEET
    // ----------------------------------------------------------

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
  );

  // ============================================================
  // DARK THEME
  // ============================================================

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ----------------------------------------------------------
    // BACKGROUND
    // ----------------------------------------------------------

    scaffoldBackgroundColor: const Color(0xFF111114),

    // ----------------------------------------------------------
    // COLOR SCHEME
    // ----------------------------------------------------------

    colorScheme: ColorScheme.fromSeed(
      seedColor: darkPurple,
      brightness: Brightness.dark,
    ).copyWith(
      primary: darkPurple,
      secondary: darkPurple,

      // Background utama
      surface: const Color(0xFF1C1C21),

      // Text di atas surface
      onSurface: Colors.white,

      // Background aplikasi
      surfaceContainerLowest: const Color(0xFF111114),
      surfaceContainerLow: const Color(0xFF16161A),
      surfaceContainer: const Color(0xFF1C1C21),
      surfaceContainerHigh: const Color(0xFF222229),
      surfaceContainerHighest: const Color(0xFF2A2A31),
    ),

    // ----------------------------------------------------------
    // APP BAR
    // ----------------------------------------------------------

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),

    // ----------------------------------------------------------
    // TEXT
    // ----------------------------------------------------------

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        color: Color(0xFFA1A1AA),
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),

    // ----------------------------------------------------------
    // INPUT
    // ----------------------------------------------------------

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C1C21),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: darkPurple,
          width: 1.5,
        ),
      ),

      hintStyle: const TextStyle(
        color: Color(0xFF8A8A94),
      ),

      labelStyle: const TextStyle(
        color: Color(0xFFA1A1AA),
      ),
    ),

    // ----------------------------------------------------------
    // CARD
    // ----------------------------------------------------------

    cardTheme: CardThemeData(
      color: const Color(0xFF1C1C21),
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    // ----------------------------------------------------------
    // DIVIDER
    // ----------------------------------------------------------

    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A31),
      thickness: 1,
    ),

    // ----------------------------------------------------------
    // DIALOG
    // ----------------------------------------------------------

    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1C1C21),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        color: Color(0xFFA1A1AA),
        fontSize: 14,
        height: 1.5,
      ),
    ),

    // ----------------------------------------------------------
    // SNACKBAR
    // ----------------------------------------------------------

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2A2A31),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // ----------------------------------------------------------
    // BOTTOM SHEET
    // ----------------------------------------------------------

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1C1C21),
      surfaceTintColor: Colors.transparent,
    ),
  );
}