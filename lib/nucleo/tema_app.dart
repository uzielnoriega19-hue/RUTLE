import 'package:flutter/material.dart';

// Paleta de colores de la marca RUTLE
// Azul limpio, profesional, confiable
class ColoresRutle {
  // Azul cielo — color primario del modo claro
  static const Color azulCielo = Color(0xFF0288D1);
  static const Color azulCieloContenedor = Color(0xFFBAE6FD);

  // Azul oscuro — conservado para el modo oscuro
  static const Color azulPrimario = Color(0xFF1565C0);
  static const Color azulOscuro = Color(0xFF0D47A1);

  // Cyan secundario
  static const Color cianSecundario = Color(0xFF00ACC1);
  static const Color cianContenedor = Color(0xFFB2EBF2);

  // Teal terciario (ecología, medio ambiente)
  static const Color tealTerciario = Color(0xFF00838F);
  static const Color tealContenedor = Color(0xFFB2EBF2);

  // Superficies - Modo claro
  static const Color fondoClaro = Color(0xFFF0F9FF);
  static const Color superficieClara = Color(0xFFFFFFFF);
  static const Color superficieVarianteClara = Color(0xFFE0F2FE);

  // Superficies - Modo oscuro (navy azul rico, no negro)
  static const Color fondoOscuro = Color(0xFF1A2840);
  static const Color superficieOscura = Color(0xFF1F3050);
  static const Color superficieVarianteOscura = Color(0xFF263A5C);
  static const Color tarjetaOscura = Color(0xFF1C2E4C);

  // Semánticos
  static const Color exito = Color(0xFF2E7D32);
  static const Color exitoAccent = Color(0xFF43A047);
  static const Color advertencia = Color(0xFFE65100);
  static const Color advertenciaAccent = Color(0xFFFB8C00);
  static const Color error = Color(0xFFBA1A1A);
}

class TemaApp {
  static ThemeData get temaClaro => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          // Azul cielo como color primario del modo claro
          primary: Color(0xFF0288D1),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFBAE6FD),
          onPrimaryContainer: Color(0xFF014F6D),
          secondary: Color(0xFF00ACC1),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFB2EBF2),
          onSecondaryContainer: Color(0xFF004D5B),
          tertiary: Color(0xFF00838F),
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFB2EBF2),
          onTertiaryContainer: Color(0xFF004D5B),
          error: Color(0xFFE53935),
          onError: Colors.white,
          errorContainer: Color(0xFFFFCDD2),
          onErrorContainer: Color(0xFF7F0000),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF1A1C1E),
          surfaceContainerHighest: Color(0xFFE0F2FE),
          onSurfaceVariant: Color(0xFF44474F),
          outline: Color(0xFF74777F),
          outlineVariant: Color(0xFFB0D4E8),
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: Color(0xFF1A2C38),
          onInverseSurface: Color(0xFFE9F5FB),
          inversePrimary: Color(0xFF7FCDEA),
          surfaceTint: Color(0xFF0288D1),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F9FF),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0288D1),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF29B6F6),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0x4029B6F6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0288D1),
            side: const BorderSide(color: Color(0xFF0288D1), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0288D1),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Color(0xFF44474F)),
          floatingLabelStyle: const TextStyle(color: Color(0xFF0288D1)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB0D4E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB0D4E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0288D1), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: const Color(0x141565C0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF0288D1),
        ),

        dividerTheme: const DividerThemeData(
          color: Color(0xFFEEF4FF),
          thickness: 1,
        ),

        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFBAE6FD),
          labelStyle: const TextStyle(color: Color(0xFF014F6D)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: const TextStyle(
            color: Color(0xFF1A1C1E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          contentTextStyle: const TextStyle(
            color: Color(0xFF44474F),
            fontSize: 14,
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF1A1C1E),
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? const Color(0xFF0288D1)
                : Colors.white,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? const Color(0xFF7FCDEA)
                : const Color(0xFFB0D4E8),
          ),
        ),

        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold),
          displayMedium:
              TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold),
          displaySmall:
              TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold),
          headlineLarge:
              TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.w700),
          headlineMedium:
              TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.w600),
          headlineSmall:
              TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.w600),
          titleLarge:
              TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.w600),
          titleMedium:
              TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.w500),
          titleSmall:
              TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: Color(0xFF1A1C1E)),
          bodyMedium: TextStyle(color: Color(0xFF44474F)),
          bodySmall: TextStyle(color: Color(0xFF44474F)),
          labelLarge:
              TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.w500),
          labelMedium: TextStyle(color: Color(0xFF44474F)),
          labelSmall: TextStyle(color: Color(0xFF74777F)),
        ),
      );

  static ThemeData get temaOscuro => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF90B8F9),
          onPrimary: Color(0xFF00315E),
          primaryContainer: Color(0xFF1A4080),
          onPrimaryContainer: Color(0xFFD6E3FF),
          secondary: Color(0xFF7FCDEA),
          onSecondary: Color(0xFF003547),
          secondaryContainer: Color(0xFF0D4060),
          onSecondaryContainer: Color(0xFFB3E5FC),
          tertiary: Color(0xFF4DD0E1),
          onTertiary: Color(0xFF003640),
          tertiaryContainer: Color(0xFF0A4855),
          onTertiaryContainer: Color(0xFFA0EEFF),
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          errorContainer: Color(0xFF93000A),
          onErrorContainer: Color(0xFFFFDAD6),
          // Superficies: navy azul visible, no negro
          surface: Color(0xFF1F3050),
          onSurface: Color(0xFFDDE5F4),
          surfaceContainerHighest: Color(0xFF263A5C),
          onSurfaceVariant: Color(0xFFBCC8DF),
          outline: Color(0xFF7A8FA8),
          outlineVariant: Color(0xFF3A4E68),
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: Color(0xFFDDE5F4),
          onInverseSurface: Color(0xFF1F3050),
          inversePrimary: Color(0xFF1565C0),
          surfaceTint: Color(0xFF90B8F9),
        ),
        // Fondo general: navy rico, claramente azul oscuro
        scaffoldBackgroundColor: const Color(0xFF1A2840),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF162236),
          foregroundColor: Color(0xFF90B8F9),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFE2E2E9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFF90B8F9)),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E4D8C),
            foregroundColor: const Color(0xFFD6E3FF),
            elevation: 2,
            shadowColor: Colors.black45,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF90B8F9),
            side: const BorderSide(color: Color(0xFF90B8F9), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF90B8F9),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF243654),
          labelStyle: const TextStyle(color: Color(0xFFBCC8DF)),
          floatingLabelStyle: const TextStyle(color: Color(0xFF90B8F9)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A4E68)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A4E68)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF90B8F9), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFF1C2E4C),
          elevation: 4,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF90B8F9),
        ),

        dividerTheme: const DividerThemeData(
          color: Color(0xFF263A5C),
          thickness: 1,
        ),

        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF1A4080),
          labelStyle: const TextStyle(color: Color(0xFFD6E3FF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF1C2E4C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: const TextStyle(
            color: Color(0xFFE2E2E9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          contentTextStyle: const TextStyle(
            color: Color(0xFFC4C7CF),
            fontSize: 14,
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF263A5C),
          contentTextStyle: const TextStyle(color: Color(0xFFDDE5F4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? const Color(0xFF90B8F9)
                : const Color(0xFF8E9099),
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? const Color(0xFF004885)
                : const Color(0xFF44474F),
          ),
        ),

        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: Color(0xFFE2E2E9), fontWeight: FontWeight.bold),
          displayMedium:
              TextStyle(color: Color(0xFFE2E2E9), fontWeight: FontWeight.bold),
          displaySmall:
              TextStyle(color: Color(0xFFE2E2E9), fontWeight: FontWeight.bold),
          headlineLarge:
              TextStyle(color: Color(0xFFE2E2E9), fontWeight: FontWeight.w700),
          headlineMedium:
              TextStyle(color: Color(0xFFE2E2E9), fontWeight: FontWeight.w600),
          headlineSmall:
              TextStyle(color: Color(0xFFE2E2E9), fontWeight: FontWeight.w600),
          titleLarge:
              TextStyle(color: Color(0xFFE2E2E9), fontWeight: FontWeight.w600),
          titleMedium:
              TextStyle(color: Color(0xFFE2E2E9), fontWeight: FontWeight.w500),
          titleSmall:
              TextStyle(color: Color(0xFFE2E2E9), fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: Color(0xFFE2E2E9)),
          bodyMedium: TextStyle(color: Color(0xFFC4C7CF)),
          bodySmall: TextStyle(color: Color(0xFFC4C7CF)),
          labelLarge:
              TextStyle(color: Color(0xFFE2E2E9), fontWeight: FontWeight.w500),
          labelMedium: TextStyle(color: Color(0xFFC4C7CF)),
          labelSmall: TextStyle(color: Color(0xFF8E9099)),
        ),
      );
}
