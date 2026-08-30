import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprender_a_controlar/models/nota_campo.dart';

class NotasService {
  static const String _keyPerfilActivo = 'perfil_activo';

  static Future<String> _getPerfilActivoKey(SharedPreferences prefs) async {
    final perfil = prefs.getString(_keyPerfilActivo) ?? 'Usuario Principal';
    return 'notas_campo_${perfil.trim()}';
  }

  static Future<List<NotaCampo>> obtenerNotas() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPerfilActivoKey(prefs);
    final jsonString = prefs.getString(key);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => NotaCampo.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> guardarNota(NotaCampo nota) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPerfilActivoKey(prefs);
    final notas = await obtenerNotas();

    final index = notas.indexWhere((n) => n.id == nota.id);
    if (index >= 0) {
      notas[index] = nota;
    } else {
      notas.insert(0, nota);
    }

    final encoded = jsonEncode(notas.map((n) => n.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  static Future<void> eliminarNota(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPerfilActivoKey(prefs);
    final notas = await obtenerNotas();
    notas.removeWhere((n) => n.id == id);

    final encoded = jsonEncode(notas.map((n) => n.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  static Future<void> cambiarEstadoRevision(String id, bool revisado) async {
    final notas = await obtenerNotas();
    final index = notas.indexWhere((n) => n.id == id);
    if (index >= 0) {
      final updated = notas[index].copyWith(revisadoConSupervisor: revisado);
      await guardarNota(updated);
    }
  }
}
