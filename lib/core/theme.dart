import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AqiLevel {
  final String label;
  final Color color;
  final Color bgColor;
  final String advice;
  final String icon;

  const AqiLevel({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.advice,
    required this.icon,
  });
}

class AqiColors {
  AqiColors._();

  static const Color baik = Color(0xFF00E676);
  static const Color sedang = Color(0xFFFFD600);
  static const Color tidakSehatSensitif = Color(0xFFFF6D00);
  static const Color tidakSehat = Color(0xFFE53935);
  static const Color sangatTidakSehat = Color(0xFFAA00FF);
  static const Color berbahaya = Color(0xFF7B1FA2);

  static AqiLevel getLevelFromAqi(int aqi) {
    if (aqi <= AppConstants.aqiBaik) {
      return const AqiLevel(
        label: 'Baik',
        color: baik,
        bgColor: Color(0xFF0A2E1A),
        advice:
            'Kualitas udara sangat baik. Cocok untuk aktivitas luar ruangan.',
        icon: '😊',
      );
    } else if (aqi <= AppConstants.aqiSedang) {
      return const AqiLevel(
        label: 'Sedang',
        color: sedang,
        bgColor: Color(0xFF2D2600),
        advice:
            'Kualitas udara dapat diterima. Kelompok sensitif sebaiknya membatasi aktivitas luar.',
        icon: '😐',
      );
    } else if (aqi <= AppConstants.aqiTidakSehatSensitif) {
      return const AqiLevel(
        label: 'Tidak Sehat (Sensitif)',
        color: tidakSehatSensitif,
        bgColor: Color(0xFF2D1600),
        advice:
            'Kelompok sensitif (anak-anak, lansia, penderita penyakit jantung/paru) sebaiknya mengurangi aktivitas luar ruangan.',
        icon: '😷',
      );
    } else if (aqi <= AppConstants.aqiTidakSehat) {
      return const AqiLevel(
        label: 'Tidak Sehat',
        color: tidakSehat,
        bgColor: Color(0xFF2D0000),
        advice:
            'Semua orang mungkin mulai merasakan dampak kesehatan. Batasi aktivitas fisik di luar ruangan.',
        icon: '🤧',
      );
    } else if (aqi <= AppConstants.aqiSangatTidakSehat) {
      return const AqiLevel(
        label: 'Sangat Tidak Sehat',
        color: sangatTidakSehat,
        bgColor: Color(0xFF1A0030),
        advice:
            'Peringatan darurat kesehatan. Semua orang berisiko terkena dampak serius. Hindari aktivitas luar ruangan.',
        icon: '😨',
      );
    } else {
      return const AqiLevel(
        label: 'Berbahaya',
        color: berbahaya,
        bgColor: Color(0xFF1A0020),
        advice:
            'Darurat! Kondisi udara sangat berbahaya. Tetap di dalam ruangan, tutup semua jendela, gunakan pemurni udara.',
        icon: '☠️',
      );
    }
  }
}

class AppTheme {
  AppTheme._();

  static const Color black = Color(0xFF000000);
  static const Color surface = Color(0xFF0D0D0D);
  static const Color surfaceElevated = Color(0xFF1A1A1A);
  static const Color surfaceCard = Color(0xFF141414);
  static const Color border = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textTertiary = Color(0xFF666666);
  static const Color accent = Color(0xFF00E676);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: black,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: Color(0xFF00BFA5),
          surface: surface,
          onSurface: textPrimary,
          onPrimary: black,
        ),
        textTheme: GoogleFonts.soraTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
              fontSize: 57,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
            displayMedium: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
            headlineMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            headlineSmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textPrimary,
              letterSpacing: 0.1,
            ),
            titleSmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textPrimary,
              letterSpacing: 0.1,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textPrimary,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textSecondary,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textTertiary,
            ),
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
              letterSpacing: 0.1,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: black,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Sora',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: surfaceCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: border, width: 1),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: border,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          hintStyle: const TextStyle(
            fontFamily: 'Sora',
            color: textTertiary,
            fontSize: 14,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: accent,
          unselectedItemColor: textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: accent.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
              );
            }
            return const TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              color: textTertiary,
            );
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: surfaceElevated,
          contentTextStyle: const TextStyle(
            fontFamily: 'Sora',
            color: textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}

