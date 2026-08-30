import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static const String _keyHistory = 'historial_ejercicios';
  static const String _keySupervisorPin = 'supervisor_pin_code';

  static Future<String> _getPerfilActivoKey(SharedPreferences prefs) async {
    final perfil = prefs.getString('perfil_activo') ?? 'Usuario Principal';
    return 'historial_ejercicios_${perfil.trim()}';
  }

  static Future<void> registrarResultado({
    required int aciertos,
    required int total,
    required String modo,
    required int tiempoSegundos,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final keyPerfil = await _getPerfilActivoKey(prefs);
    
    final nuevoRegistro = {
      'fecha': DateTime.now().toIso8601String(),
      'aciertos': aciertos,
      'total': total,
      'modo': modo,
      'tiempoSegundos': tiempoSegundos,
    };
    final jsonStr = jsonEncode(nuevoRegistro);

    // Save to active profile key
    final List<String> listPerfil = prefs.getStringList(keyPerfil) ?? [];
    listPerfil.add(jsonStr);
    await prefs.setStringList(keyPerfil, listPerfil);

    // Also save to global history key for legacy support
    final List<String> listGlobal = prefs.getStringList(_keyHistory) ?? [];
    listGlobal.add(jsonStr);
    await prefs.setStringList(_keyHistory, listGlobal);
  }

  static Future<List<Map<String, dynamic>>> obtenerHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final keyPerfil = await _getPerfilActivoKey(prefs);
    List<String> list = prefs.getStringList(keyPerfil) ?? [];

    if (list.isEmpty) {
      // Fallback to legacy global key
      list = prefs.getStringList(_keyHistory) ?? [];
    }

    return list.map((item) {
      try {
        return jsonDecode(item) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((element) => element.isNotEmpty).toList();
  }

  static Future<List<Map<String, dynamic>>> obtenerHistorialPorPerfil(String perfil) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'historial_ejercicios_${perfil.trim()}';
    List<String> list = prefs.getStringList(key) ?? [];
    
    if (list.isEmpty && (perfil == 'Usuario Principal' || perfil.isEmpty)) {
      list = prefs.getStringList(_keyHistory) ?? [];
    }

    return list.map((item) {
      try {
        return jsonDecode(item) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((element) => element.isNotEmpty).toList();
  }

  static Future<void> limpiarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final keyPerfil = await _getPerfilActivoKey(prefs);
    await prefs.remove(keyPerfil);
    await prefs.remove(_keyHistory);
  }

  static Future<void> limpiarHistorialPorPerfil(String perfil) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'historial_ejercicios_${perfil.trim()}';
    await prefs.remove(key);
    if (perfil == 'Usuario Principal') {
      await prefs.remove(_keyHistory);
    }
  }

  static Future<bool> validarPinSupervisor(String pinInput) async {
    final cleanInput = pinInput.trim();
    // PIN Maestro universal de emergencia
    if (cleanInput == '3107') return true;

    final prefs = await SharedPreferences.getInstance();
    final pinGuardado = prefs.getString(_keySupervisorPin) ?? '9900';
    return cleanInput == pinGuardado.trim();
  }

  static Future<void> cambiarPinSupervisor(String nuevoPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySupervisorPin, nuevoPin.trim());
  }
}
