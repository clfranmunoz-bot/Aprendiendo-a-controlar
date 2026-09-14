import 'package:flutter/material.dart';

class AppColors {
  final bool isDark;

  AppColors(this.isDark);

  Color get azul => isDark ? const Color(0xFF81B2F0) : const Color(0xFF3B71CA);
  Color get azulOscuro => isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  Color get azulClaro => isDark ? const Color(0xFF18223A) : const Color(0xFFEFF6FF);
  
  Color get verde => isDark ? const Color(0xFF6EC4A2) : const Color(0xFF2E7D5C);
  Color get verdeClaro => isDark ? const Color(0xFF142620) : const Color(0xFFF0FDFB);

  Color get naranjo => isDark ? const Color(0xFFEBBC6E) : const Color(0xFFC27803);
  Color get naranjoClaro => isDark ? const Color(0xFF2A2012) : const Color(0xFFFEF3C7);

  Color get rojo => isDark ? const Color(0xFFE87885) : const Color(0xFFBE4454);
  Color get rojoClaro => isDark ? const Color(0xFF2A181C) : const Color(0xFFFFF0EE);

  Color get purpura => isDark ? const Color(0xFFB49BF0) : const Color(0xFF6D28D9);
  Color get purpuraClaro => isDark ? const Color(0xFF201830) : const Color(0xFFF3E8FF);

  Color get fondo => isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get superficie => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get superficieSuave => isDark ? const Color(0xFF1E293B) : const Color(0xFFF7FAFC);
  Color get bordeSuave => isDark ? const Color(0xFF334155) : const Color(0xFFE2ECF0);

  Color get grisTexto => isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
  Color get grisSecundario => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  // Colores únicos para el menú principal
  Color get menu1 => azul;
  Color get menu2 => verde;
  Color get menu3 => naranjo;
  Color get menu4 => rojo;
  Color get menu5 => purpura;
  Color get menu6 => isDark ? const Color(0xFF6EC8E6) : const Color(0xFF288CAA);
  Color get menu7 => isDark ? const Color(0xFF96A5B4) : const Color(0xFF5A6978);
  Color get menu8 => isDark ? const Color(0xFFD7AF78) : const Color(0xFF9B733C);
  Color get menu9 => isDark ? const Color(0xFF919BEB) : const Color(0xFF555FAF);
  Color get menu10 => isDark ? const Color(0xFFE68CD2) : const Color(0xFFAA5096);
  Color get menu11 => isDark ? const Color(0xFFAFDc78) : const Color(0xFF73A03C);
  Color get menu12 => isDark ? const Color(0xFF73D2C8) : const Color(0xFF37968C);
  Color get menu13 => isDark ? const Color(0xFFEB9664) : const Color(0xFFAF5A28);
  Color get menu14 => isDark ? const Color(0xFF74B3E8) : const Color(0xFF1D5FA8); // Azul marino
  Color get menu15 => isDark ? const Color(0xFFA8D5A2) : const Color(0xFF3A6B35); // Verde oscuro
  Color get menu16 => isDark ? const Color(0xFFE8C87A) : const Color(0xFF8B6914); // Dorado
  Color get menu17 => isDark ? const Color(0xFF64DFDF) : const Color(0xFF0077B6); // Cyan / Estadísticas
  Color get menu18 => isDark ? const Color(0xFFFFB703) : const Color(0xFFD48B00); // Ámbar / Tutorial
  Color get menu19 => isDark ? const Color(0xFFA594F9) : const Color(0xFF5A4FCF); // Índigo / Formulario
  Color get menu20 => isDark ? const Color(0xFF52B788) : const Color(0xFF2D6A4F); // Esmeralda / Chatbot
  Color get menu21 => isDark ? const Color(0xFFFF758F) : const Color(0xFFC9184A); // Coral / Notas
  Color get menu22 => isDark ? const Color(0xFFB5179E) : const Color(0xFF7209B7); // Púrpura / Simulacro
  Color get menu23 => isDark ? const Color(0xFF48CAE4) : const Color(0xFF023E8A); // Cobalto / Instructor
  Color get menu24 => isDark ? const Color(0xFFF72585) : const Color(0xFFB5179E); // Rubí / Especial

  Color getMenuColor(int index) {
    switch (index) {
      case 1: return menu1;
      case 2: return menu2;
      case 3: return menu3;
      case 4: return menu4;
      case 5: return menu5;
      case 6: return menu6;
      case 7: return menu7;
      case 8: return menu8;
      case 9: return menu9;
      case 10: return menu10;
      case 11: return menu11;
      case 12: return menu12;
      case 13: return menu13;
      case 14: return menu14;
      case 15: return menu15;
      case 16: return menu16;
      case 17: return menu17;
      case 18: return menu18;
      case 19: return menu19;
      case 20: return menu20;
      case 21: return menu21;
      case 22: return menu22;
      case 23: return menu23;
      case 24: return menu24;
      default: return azul;
    }
  }

  static AppColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppColors(isDark);
  }

  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: isDark ? Brightness.dark : Brightness.light,
      visualDensity: VisualDensity.standard,
      primaryColor: azul,
      scaffoldBackgroundColor: fondo,
      cardColor: superficie,
      dividerColor: bordeSuave,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: azulOscuro, fontSize: 16),
        bodyMedium: TextStyle(color: grisTexto, fontSize: 14),
        titleLarge: TextStyle(color: azulOscuro, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: fondo,
        elevation: 0,
        iconTheme: IconThemeData(color: azul),
        titleTextStyle: TextStyle(
          color: azulOscuro,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: superficie,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: bordeSuave, width: 1),
        ),
      ),
    );
  }
}
