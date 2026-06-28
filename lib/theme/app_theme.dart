import 'package:flutter/material.dart';

class AppColors {
  static const Color brand = Color(0xFF0E7C66); // ana teal
  static const Color brandSoft = Color(0xFF4FB89E); // açık teal (gradient)
  static const Color accent = Color(0xFFFF7A59); // sıcak vurgu
  static const Color bg = Color(0xFFF4F7F6); // ferah arka plan
  static const Color card = Colors.white;
  static const Color textMuted = Color(0xFF6B7280);
  static const Color track = Color(0xFFE6ECEA); // halka/progress zemini
}

class AppRadius {
  static const double card = 24;
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x14000000), // ~%8 siyah
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
    ).copyWith(primary: AppColors.brand);

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        height: 64,
        indicatorColor: AppColors.brand.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
