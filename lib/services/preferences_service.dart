import 'package:shared_preferences/shared_preferences.dart';

/// Servicio centralizado para gestionar las preferencias y persistencia de la app.
class PreferencesService {
  static const String keyModoOscuro = 'modo_oscuro';
  static const String keyPerfilActivo = 'perfil_activo';
  static const String keyPerfilesLista = 'perfiles_lista';
  static const String keyOnboardingVisto = 'onboarding_visto';
  static const String keyTutorialCompletado = 'tutorial_completado';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // MODO OSCURO
  bool get modoOscuro => _prefs.getBool(keyModoOscuro) ?? false;
  Future<bool> setModoOscuro(bool value) => _prefs.setBool(keyModoOscuro, value);

  // PERFILES
  String get perfilActivo => _prefs.getString(keyPerfilActivo) ?? 'Usuario Principal';
  Future<bool> setPerfilActivo(String value) => _prefs.setString(keyPerfilActivo, value);

  List<String> get perfilesLista => _prefs.getStringList(keyPerfilesLista) ?? ['Usuario Principal'];
  Future<bool> setPerfilesLista(List<String> list) => _prefs.setStringList(keyPerfilesLista, list);

  // ONBOARDING & TUTORIAL
  bool get onboardingVisto => _prefs.getBool(keyOnboardingVisto) ?? false;
  Future<bool> setOnboardingVisto(bool value) => _prefs.setBool(keyOnboardingVisto, value);

  bool get tutorialCompletado => _prefs.getBool(keyTutorialCompletado) ?? false;
  Future<bool> setTutorialCompletado(bool value) => _prefs.setBool(keyTutorialCompletado, value);

  // GENÉRICO PARA OTROS MODULOS
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String val) => _prefs.setString(key, val);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool val) => _prefs.setBool(key, val);

  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int val) => _prefs.setInt(key, val);

  List<String>? getStringList(String key) => _prefs.getStringList(key);
  Future<bool> setStringList(String key, List<String> val) => _prefs.setStringList(key, val);

  Future<bool> remove(String key) => _prefs.remove(key);
}
