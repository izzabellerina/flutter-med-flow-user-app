import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ══════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY
  // ══════════════════════════════════════════════════════════════════════════

  static TextStyle generalText(
    double fonSize, {
    Color color = const Color(0xFF25253A),
    FontWeight fonWeight = FontWeight.w400,
    TextDecorationStyle? decorationStyle,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.athiti(
      color: color,
      fontSize: fonSize,
      decorationStyle: decorationStyle,
      decoration: decoration,
      fontWeight: fonWeight,
      fontStyle: FontStyle.normal,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIMARY / BRAND COLORS
  // ══════════════════════════════════════════════════════════════════════════

  static Color get primaryThemeApp => Color(0xff0d9488);
  static Color get primary1 => Color(0xFF115e59);
  static Color get primary2 => Color(0xff14b8a6);
  static Color get blueLogo => Color(0xff2F4A85);

  // ══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ══════════════════════════════════════════════════════════════════════════

  static Color get primaryText => Color(0xFF1E293B);
  static Color get secondaryText62 => Color(0xff64748B);
  static Color get secondaryText9A => Color(0xff94A3B8);
  static Color get secondaryTextb2 => Color(0xffCBD5E1);
  static Color get thirdTextColor => Color(0xFF94A3B8);
  static Color get textBlack87 => Colors.black87;
  static Color get labelColor66 => Color(0xFF64748B);
  static Color get darkGrey33 => Color(0xFF334155);

  // ══════════════════════════════════════════════════════════════════════════
  // BASE COLORS (Black / White)
  // ══════════════════════════════════════════════════════════════════════════

  static Color get blackColor => Color(0xff000000);
  static Color get whiteColor => Color(0xffffffff);

  // ══════════════════════════════════════════════════════════════════════════
  // GREY SCALE
  // ══════════════════════════════════════════════════════════════════════════

  static Color get grey => Colors.grey;
  static Color get greyLv1 => Color(0xff515151);
  static Color get greyShade200 => Colors.grey.shade200;
  static Color get greyShade300 => Colors.grey.shade300;
  static Color get greyShade400 => Colors.grey.shade400;
  static Color get greyShade500 => Colors.grey.shade500;
  static Color get greyShade600 => Colors.grey.shade600;
  static Color get greyShade700 => Colors.grey.shade700;
  static Color get greyLv3 => Color(0xFFF5F5F5);

  // ══════════════════════════════════════════════════════════════════════════
  // BACKGROUND COLORS
  // ══════════════════════════════════════════════════════════════════════════

  static Color get bgColor => Color(0xfff8fafc);
  static Color get fadeBackground => const Color(0xffF3F3F3);
  static Color get cardInfoBg => Color(0xFFF8F9FF);
  static Color get tabBarColor => Color(0xfff9fbfe);
  static Color get searchBarBgColor => Color(0x19f9fbfe);

  // ══════════════════════════════════════════════════════════════════════════
  // LINE / BORDER COLORS
  // ══════════════════════════════════════════════════════════════════════════

  static Color get lineColorD9 => Color(0xffE2E8F0);
  static Color get lineColorE4 => Color(0xffE2E8F0);
  static Color get lineColorF8 => Color(0xffF8FAFC);
  static Color get lineFadeColor => const Color(0xFFF1F5F9);
  static Color get lineFadeColor2 => const Color(0xFFF1F5F9);
  static Color get edgeButtonColor => Color(0xFFE2E8F0);

  // ══════════════════════════════════════════════════════════════════════════
  // STATUS / FEEDBACK COLORS
  // ══════════════════════════════════════════════════════════════════════════

  static Color get successColor => Colors.green;
  static Color get errorColor => Colors.red;
  static Color get warningColor => Colors.orange;
  static Color get infoColor => Colors.blue;
  static Color get confirm => Color(0xFF00C537);
  static Color get deleteColor => Color(0xffe94444);
  static Color get redWarning => Color(0xFFF82518);
  static Color get statusGreen => Color(0xFF4CAF50);

  // ══════════════════════════════════════════════════════════════════════════
  // BADGE COLORS
  // ══════════════════════════════════════════════════════════════════════════

  static Color get hnBadgeBgColor => Color(0x32FDA215);
  static Color get hnBadgeBorderColor => Color(0xFCFF7A00);
  static Color get noHnBadgeBgColor => Color(0x329a9a9a);
  static Color get dateBadgeColor => Color(0x3a69b7a8);
  static Color get dateBadgeTextColor => Color(0xff69b7a8);
  static Color get timeBadgeColor => Color(0x3a4a98f7);
  static Color get timeBadgeTextColor => Color(0xff4a98f7);
  static Color get medicBadgeColor => Color(0x30fea613);

  // ══════════════════════════════════════════════════════════════════════════
  // GENDER COLORS
  // ══════════════════════════════════════════════════════════════════════════

  static Color get maleColor => Color(0xFF009688);
  static Color get femaleColor => Color(0xFFE91E63);

  // ══════════════════════════════════════════════════════════════════════════
  // HEALTH STATUS / VITAL SIGNS
  // ══════════════════════════════════════════════════════════════════════════

  static Color get greenPaleBg => Colors.green.shade50;
  static Color get greenShade200 => Colors.green.shade200;
  static Color get greenShade600 => Colors.green.shade600;
  static Color get greenShade700 => Colors.green.shade700;
  static Color get yellowWarning => Colors.yellow.shade700;
  static Color get orangeShade700 => Colors.orange.shade700;
  static Color get blueShade700 => Colors.blue.shade700;
  static Color get redShade600 => Colors.red.shade600;
  static Color get redShade700 => Colors.red.shade700;
  static Color get redCritical => Colors.red.shade900;
  static Color get purple => Colors.purple;

  // ══════════════════════════════════════════════════════════════════════════
  // SHADOW / OVERLAY
  // ══════════════════════════════════════════════════════════════════════════

  static Color get shadowColor => Color(0x19000000);
  static Color get boxShadow => Color(0x49000000);
  static Color get inputShadow => Colors.black.withValues(alpha: 0.05);
  static Color get overlayLight => Colors.black.withValues(alpha: 0.1);
  static Color get shadowMedium => Colors.black.withValues(alpha: 0.2);
  static Color get imageShadow => Color(0x16313131);

  // ══════════════════════════════════════════════════════════════════════════
  // UI COMPONENT COLORS
  // ══════════════════════════════════════════════════════════════════════════

  static Color get radioBoxColor => Color(0xff4a98f7);
  static Color get iconBlur => Color(0xFF475569);
  static Color get checkOutColorBlueLigther => Color(0xFF2E2E2E);
  static Color get checkOutColorBlueDarker => Color(0xFF202020);
  static Color get gradientStart => Color(0xFF667eea);
  static Color get gradientEnd => Color(0xFF764ba2);

  // ══════════════════════════════════════════════════════════════════════════
  // DAY OF WEEK
  // ══════════════════════════════════════════════════════════════════════════

  static Color dayOfWeekColor(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return Color(0xFFE1BC63);
      case 2:
        return Colors.pinkAccent;
      case 3:
        return Colors.green;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.blue;
      case 6:
        return Colors.purple;
      case 7:
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // THEME DATA
  // ══════════════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.athitiTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryThemeApp,
        primary: primaryThemeApp,
        onPrimary: Colors.white,
        surface: whiteColor,
        surfaceContainerHighest: bgColor,
      ),
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryThemeApp,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: whiteColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lineColorD9),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lineColorD9),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryThemeApp, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryThemeApp,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.athiti(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryThemeApp,
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(color: primaryThemeApp),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.athiti(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryThemeApp,
        unselectedItemColor: secondaryText62,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.athiti(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.athiti(fontSize: 12),
      ),
    );
  }
}
