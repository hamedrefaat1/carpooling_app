import 'package:flutter/material.dart';

class AppColors {
  // =========================================
  // 🎨 COLOR SCHEME 1: MODERN BLUE (المفضل)
  // =========================================
  
  // Primary Colors
  static const Color primary = Color(0xFF2E7CF6);        // أزرق عصري
  static const Color primaryLight = Color(0xFF5A96F7);   // أزرق فاتح
  static const Color primaryDark = Color(0xFF1A5AC8);    // أزرق غامق
  
  // Secondary Colors
  static const Color secondary = Color(0xFF00D4AA);      // أخضر نعناعي (للنجاح)
  static const Color secondaryLight = Color(0xFF33DDBB); 
  static const Color accent = Color(0xFFFF6B6B);         // أحمر خفيف (للتنبيهات)
  
  // Background Colors
  static const Color background = Color(0xFFF8FAFC);     // أبيض مزرق خفيف
  static const Color surface = Color(0xFFFFFFFF);        // أبيض نقي
  static const Color surfaceLight = Color(0xFFF1F5F9);   // رمادي فاتح جداً
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);    // أسود مزرق
  static const Color textSecondary = Color(0xFF64748B);  // رمادي متوسط
  static const Color textLight = Color(0xFF94A3B8);      // رمادي فاتح
  static const Color textHint = Color(0xFFCBD5E1);       // رمادي خفيف جداً
  
  // Status Colors
  static const Color success = Color(0xFF10B981);        // أخضر نجاح
  static const Color warning = Color(0xFFF59E0B);        // برتقالي تحذير
  static const Color error = Color(0xFFEF4444);          // أحمر خطأ
  static const Color info = Color(0xFF3B82F6);           // أزرق معلومات
  
  // Border & Divider Colors
  static const Color border = Color(0xFFE2E8F0);         // حدود فاتحة
  static const Color borderDark = Color(0xFFCBD5E1);     // حدود أغمق
  static const Color divider = Color(0xFFF1F5F9);        // خط فاصل
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);         // ظل خفيف
  static const Color shadowMedium = Color(0x33000000);   // ظل متوسط

  // =========================================
  // 🌟 COLOR SCHEME 2: VIBRANT ALTERNATIVE 
  // =========================================
  
  static const Color alternativePrimary = Color(0xFF6366F1);    // بنفسجي عصري
  static const Color alternativeSecondary = Color(0xFF06B6D4);  // سماوي
  static const Color alternativeAccent = Color(0xFFEC4899);     // وردي زاهي
  
  // =========================================
  // 🚗 TRANSPORTATION SPECIFIC COLORS
  // =========================================
  
  static const Color driverColor = Color(0xFF2563EB);     // أزرق للسائق
  static const Color passengerColor = Color(0xFF059669);  // أخضر للراكب
  static const Color routeColor = Color(0xFF7C3AED);      // بنفسجي للمسار
  static const Color locationPin = Color(0xFFDC2626);     // أحمر للموقع
  
  // =========================================
  // 🎯 GRADIENT COLORS
  // =========================================
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E7CF6),
      Color(0xFF1A5AC8),
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00D4AA),
      Color(0xFF00A388),
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8FAFC),
      Color(0xFFE2E8F0),
    ],
  );

  // =========================================
  // 📱 DARK MODE COLORS
  // =========================================
  
  static const Color darkBackground = Color(0xFF0F172A);     // أسود مزرق
  static const Color darkSurface = Color(0xFF1E293B);       // رمادي غامق
  static const Color darkTextPrimary = Color(0xFFF8FAFC);   // أبيض فاتح
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // رمادي فاتح
  static const Color darkBorder = Color(0xFF334155);        // حدود غامقة

  // =========================================
  // 🎨 UTILITY FUNCTIONS
  // =========================================
  
  // دالة للحصول على لون مع شفافية
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // دالة للحصول على لون أفتح
  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  // دالة للحصول على لون أغمق  
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

// =========================================
// 🎯 THEME DATA CONFIGURATION
// =========================================

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Primary Color Scheme
    primaryColor: AppColors.primary,
    primaryColorLight: AppColors.primaryLight,
    primaryColorDark: AppColors.primaryDark,
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: Colors.white,
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    
    // Card Theme
    cardTheme:  CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: AppColors.textLight,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
  );

  
  static ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  
  // Primary Color Scheme for Dark
  primaryColor: AppColors.primary,
  primaryColorLight: AppColors.primaryLight,
  primaryColorDark: AppColors.primaryDark,
  
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.darkSurface,
    background: AppColors.darkBackground,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.darkTextPrimary,
    onBackground: AppColors.darkTextPrimary,
    onError: Colors.white,
  ),
  
  // App Bar Theme for Dark
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.darkTextPrimary,
    elevation: 0,
    centerTitle: true,
  ),
  
  // Card Theme for Dark
  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 2,
    shadowColor: AppColors.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  
  // Elevated Button Theme for Dark
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  
  // Text Theme for Dark (نفس اللايت بس بألوان غامقة)
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      color: AppColors.darkTextPrimary,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: AppColors.darkTextPrimary,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: AppColors.darkTextPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: AppColors.darkTextPrimary,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      color: AppColors.darkTextSecondary,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      color: AppColors.darkTextSecondary, // بدل darkTextLight
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
  ),
);
}