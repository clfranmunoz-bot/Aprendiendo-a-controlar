import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio centralizado de autenticación, hashing y seguridad de acceso
/// para renovaciones mensuales y ciclos de 28 días.
class AuthService {
  // Hashes SHA-256 de las contraseñas de acceso mensual (rotación cíclica de 5 meses).
  static const List<String> hashesContrasenas = [
    'c4969cd7f36d8f896b24f8213550aa48d8585a320b41af1cdcec62dfaa91cd1d',
    '61c582449dc8ad83c2857d628b74baf1a02efe5ed77a500f1b1b19149b87f9e6',
    '262115f6c982412cd508b53c39f823453134d8b4d75e405364ef17cbb7ea50c2',
    '642648e8c062d1657bc83fa3e9b378df8cec85963ea5551aa8f82340f7e478f4',
    '878aa3bef08d426d68d1571e6cdd5e26f6896db47c411ad92c5823094bbcf0dd',
  ];

  // Hash SHA-256 de la contraseña del sistema de renovación de 28 días.
  static const String hashContrasena28 =
      'c4969cd7f36d8f896b24f8213550aa48d8585a320b41af1cdcec62dfaa91cd1d';

  /// Hashea un string en texto plano con SHA-256.
  static String hashSha256(String input) {
    final bytes = utf8.encode(input.trim());
    return sha256.convert(bytes).toString();
  }

  /// Valida la contraseña mensual según el mes del calendario actual.
  static bool verificarContrasenaMensual(String inputPassword, [DateTime? fecha]) {
    final ahora = fecha ?? DateTime.now();
    final indexContrasena = (ahora.month - 1) % 5;
    final hashCorrecto = hashesContrasenas[indexContrasena];
    return hashSha256(inputPassword) == hashCorrecto;
  }

  /// Valida la contraseña de ciclo de 28 días.
  static bool verificarContrasena28Dias(String inputPassword) {
    return hashSha256(inputPassword) == hashContrasena28;
  }

  /// Verifica si el acceso mensual ha caducado por cambio de mes/año.
  static bool haCaducadoAccesoMensual({
    required int? mesUltimaValidacion,
    required int? anioUltimaValidacion,
    DateTime? fechaActual,
  }) {
    if (mesUltimaValidacion == null || anioUltimaValidacion == null) return true;
    final ahora = fechaActual ?? DateTime.now();
    return ahora.month != mesUltimaValidacion || ahora.year != anioUltimaValidacion;
  }

  /// Verifica si el ciclo de 28 días requiere renovación.
  static bool necesitaRenovacion28Dias({
    required int? last28DayUnlockTimestamp,
    int? timestampActual,
  }) {
    if (last28DayUnlockTimestamp == null) return false;
    final ahora = timestampActual ?? DateTime.now().millisecondsSinceEpoch;
    return (ahora - last28DayUnlockTimestamp) > (28 * 24 * 60 * 60 * 1000);
  }

  /// Procesa un intento de login mensual persistiendo los datos en SharedPreferences.
  static Future<AuthValidationResult> procesarLoginMensual({
    required String password,
    required int intentosActuales,
    required SharedPreferences prefs,
  }) async {
    final ahora = DateTime.now();
    final esCorrecta = verificarContrasenaMensual(password, ahora);

    if (esCorrecta) {
      await prefs.setBool('acceso_autorizado', true);
      await prefs.setInt('intentos_acceso', 0);
      await prefs.setInt('mes_ultima_validacion', ahora.month);
      await prefs.setInt('anio_ultima_validacion', ahora.year);
      return const AuthValidationResult(
        autorizado: true,
        bloqueado: false,
        intentosUsados: 0,
      );
    }

    final nuevosIntentos = (intentosActuales + 1).clamp(0, 3);
    final debeBloquear = nuevosIntentos >= 3;
    await prefs.setInt('intentos_acceso', nuevosIntentos);
    if (debeBloquear) {
      await prefs.setBool('app_bloqueada', true);
    }
    return AuthValidationResult(
      autorizado: false,
      bloqueado: debeBloquear,
      intentosUsados: nuevosIntentos,
    );
  }

  /// Procesa un intento de login de 28 días persistiendo los datos en SharedPreferences.
  static Future<AuthValidationResult> procesarLogin28Dias({
    required String password,
    required int intentosActuales,
    required SharedPreferences prefs,
  }) async {
    final esCorrecta = verificarContrasena28Dias(password);

    if (esCorrecta) {
      await prefs.setInt('intentos_acceso_28', 0);
      await prefs.setInt('last_28day_unlock_time', DateTime.now().millisecondsSinceEpoch);
      return const AuthValidationResult(
        autorizado: true,
        bloqueado: false,
        intentosUsados: 0,
      );
    }

    final nuevosIntentos = (intentosActuales + 1).clamp(0, 3);
    final debeBloquear = nuevosIntentos >= 3;
    await prefs.setInt('intentos_acceso_28', nuevosIntentos);
    if (debeBloquear) {
      await prefs.setBool('app_bloqueada_28', true);
    }
    return AuthValidationResult(
      autorizado: false,
      bloqueado: debeBloquear,
      intentosUsados: nuevosIntentos,
    );
  }
}

class AuthValidationResult {
  final bool autorizado;
  final bool bloqueado;
  final int intentosUsados;

  const AuthValidationResult({
    required this.autorizado,
    required this.bloqueado,
    required this.intentosUsados,
  });
}
