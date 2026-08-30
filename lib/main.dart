import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/app_routes.dart';
import 'package:aprender_a_controlar/screens/home_screen.dart';
import 'package:aprender_a_controlar/screens/aprender_screen.dart';
import 'package:aprender_a_controlar/screens/calculadoras_screen.dart';
import 'package:aprender_a_controlar/screens/quiz_screen.dart';
import 'package:aprender_a_controlar/screens/ejercicios_screen.dart';
import 'package:aprender_a_controlar/screens/camara_screen.dart';
import 'package:aprender_a_controlar/screens/checklist_screen.dart';
import 'package:aprender_a_controlar/screens/glosario_screen.dart';
import 'package:aprender_a_controlar/screens/detalles_screen.dart';
import 'package:aprender_a_controlar/screens/procedimientos_screen.dart';
import 'package:aprender_a_controlar/screens/documentos_obligatorios_screen.dart';
import 'package:aprender_a_controlar/screens/ejercicios_cuaderno_screen.dart';
import 'package:aprender_a_controlar/screens/stats_screen.dart';
import 'package:aprender_a_controlar/screens/onboarding_screen.dart';
import 'package:aprender_a_controlar/screens/tutorial_screen.dart';
import 'package:aprender_a_controlar/screens/instructor_panel_screen.dart';
import 'package:aprender_a_controlar/screens/formulario_screen.dart';
import 'package:aprender_a_controlar/screens/chatbot_screen.dart';
import 'package:aprender_a_controlar/screens/notas_screen.dart';
import 'package:aprender_a_controlar/screens/simulacro_screen.dart';
import 'package:aprender_a_controlar/screens/recordatorios_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final modoOscuroInicial = prefs.getBool('modo_oscuro') ?? false;
  
  bool accesoAutorizadoInicial = prefs.getBool('acceso_autorizado') ?? false;
  final appBloqueadaInicial = prefs.getBool('app_bloqueada') ?? false;
  final intentosIniciales = prefs.getInt('intentos_acceso') ?? 0;

  final perfilActivoInicial = prefs.getString('perfil_activo') ?? 'Usuario Principal';
  final perfilesIniciales = prefs.getStringList('perfiles_lista') ?? ['Usuario Principal'];

  // Lógica de caducidad mensual: si cambia el mes o el año, expira el acceso.
  if (accesoAutorizadoInicial) {
    final mesUltimaValidacion = prefs.getInt('mes_ultima_validacion');
    final anioUltimaValidacion = prefs.getInt('anio_ultima_validacion');
    final ahora = DateTime.now();
    
    if (mesUltimaValidacion == null || 
        anioUltimaValidacion == null || 
        ahora.month != mesUltimaValidacion || 
        ahora.year != anioUltimaValidacion) {
      accesoAutorizadoInicial = false;
      await prefs.setBool('acceso_autorizado', false);
    }
  }

  // Lógica de caducidad de 28 días:
  final last28DayUnlock = prefs.getInt('last_28day_unlock_time');
  final appBloqueada28Inicial = prefs.getBool('app_bloqueada_28') ?? false;
  final intentos28Iniciales = prefs.getInt('intentos_acceso_28') ?? 0;
  bool necesitaValidacion28Inicial = false;

  if (accesoAutorizadoInicial) {
    if (last28DayUnlock == null) {
      await prefs.setInt('last_28day_unlock_time', DateTime.now().millisecondsSinceEpoch);
    } else {
      final ahora = DateTime.now().millisecondsSinceEpoch;
      if (ahora - last28DayUnlock > 28 * 24 * 60 * 60 * 1000) {
        necesitaValidacion28Inicial = true;
      }
    }
  }

  runApp(
    AprenderAControlarApp(
      modoOscuroInicial: modoOscuroInicial,
      accesoAutorizadoInicial: accesoAutorizadoInicial,
      appBloqueadaInicial: appBloqueadaInicial,
      intentosIniciales: intentosIniciales,
      perfilActivoInicial: perfilActivoInicial,
      perfilesIniciales: perfilesIniciales,
      necesitaValidacion28Inicial: necesitaValidacion28Inicial,
      appBloqueada28Inicial: appBloqueada28Inicial,
      intentos28Iniciales: intentos28Iniciales,
    ),
  );
}

class AprenderAControlarApp extends StatefulWidget {
  // Hashes SHA-256 de las contraseñas de acceso mensual (rotación cíclica de 5 meses).
  // El mapeo de contraseña → hash se gestiona fuera del código fuente.
  static const List<String> hashesContrasenas = [
    'c4969cd7f36d8f896b24f8213550aa48d8585a320b41af1cdcec62dfaa91cd1d',
    '61c582449dc8ad83c2857d628b74baf1a02efe5ed77a500f1b1b19149b87f9e6',
    '262115f6c982412cd508b53c39f823453134d8b4d75e405364ef17cbb7ea50c2',
    '642648e8c062d1657bc83fa3e9b378df8cec85963ea5551aa8f82340f7e478f4',
    '878aa3bef08d426d68d1571e6cdd5e26f6896db47c411ad92c5823094bbcf0dd',
  ];

  // Hash SHA-256 de la contraseña del sistema de renovación de 28 días.
  // La contraseña en texto claro se gestiona fuera del código fuente.
  static const String hashContrasena28 =
      'c4969cd7f36d8f896b24f8213550aa48d8585a320b41af1cdcec62dfaa91cd1d';

  final bool modoOscuroInicial;
  final bool accesoAutorizadoInicial;
  final bool appBloqueadaInicial;
  final int intentosIniciales;
  final String perfilActivoInicial;
  final List<String> perfilesIniciales;
  final bool necesitaValidacion28Inicial;
  final bool appBloqueada28Inicial;
  final int intentos28Iniciales;

  const AprenderAControlarApp({
    super.key,
    required this.modoOscuroInicial,
    required this.accesoAutorizadoInicial,
    required this.appBloqueadaInicial,
    required this.intentosIniciales,
    required this.perfilActivoInicial,
    required this.perfilesIniciales,
    required this.necesitaValidacion28Inicial,
    required this.appBloqueada28Inicial,
    required this.intentos28Iniciales,
  });

  @override
  State<AprenderAControlarApp> createState() => _AprenderAControlarAppState();
}

class _AprenderAControlarAppState extends State<AprenderAControlarApp> {
  late bool _modoOscuro;
  late bool _accesoAutorizado;
  late bool _appBloqueada;
  late int _intentosAcceso;

  late bool _necesitaValidacion28;
  late bool _appBloqueada28;
  late int _intentosAcceso28;

  @override
  void initState() {
    super.initState();
    _modoOscuro = widget.modoOscuroInicial;
    _accesoAutorizado = widget.accesoAutorizadoInicial;
    _appBloqueada = widget.appBloqueadaInicial;
    _intentosAcceso = widget.intentosIniciales.clamp(0, 3);
    
    _necesitaValidacion28 = widget.necesitaValidacion28Inicial;
    _appBloqueada28 = widget.appBloqueada28Inicial;
    _intentosAcceso28 = widget.intentos28Iniciales.clamp(0, 3);
  }

  Future<void> _toggleModoOscuro() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _modoOscuro = !_modoOscuro;
    });
    await prefs.setBool('modo_oscuro', _modoOscuro);
  }

  Future<bool> _validarAcceso(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = password.trim();

    // Hashing la clave ingresada
    final bytes = utf8.encode(normalized);
    final hashInput = sha256.convert(bytes).toString();

    // Obtener la clave correspondiente al mes del calendario actual
    final ahora = DateTime.now();
    final indexContrasenaActual = (ahora.month - 1) % 5;
    final hashCorrecto = AprenderAControlarApp.hashesContrasenas[indexContrasenaActual];

    if (hashInput == hashCorrecto) {
      await prefs.setBool('acceso_autorizado', true);
      await prefs.setInt('intentos_acceso', 0);
      await prefs.setInt('mes_ultima_validacion', ahora.month);
      await prefs.setInt('anio_ultima_validacion', ahora.year);
      setState(() {
        _accesoAutorizado = true;
        _intentosAcceso = 0;
      });
      return true;
    }

    final nuevosIntentos = (_intentosAcceso + 1).clamp(0, 3);
    final debeBloquear = nuevosIntentos >= 3;
    await prefs.setInt('intentos_acceso', nuevosIntentos);
    if (debeBloquear) {
      await prefs.setBool('app_bloqueada', true);
    }
    setState(() {
      _intentosAcceso = nuevosIntentos;
      _appBloqueada = debeBloquear;
    });
    return false;
  }

  Future<bool> _validarAcceso28(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = password.trim();

    // Hashear la clave ingresada con SHA-256 (mismo mecanismo que el acceso mensual)
    final bytes = utf8.encode(normalized);
    final hashInput = sha256.convert(bytes).toString();

    if (hashInput == AprenderAControlarApp.hashContrasena28) {
      await prefs.setInt('intentos_acceso_28', 0);
      await prefs.setInt('last_28day_unlock_time', DateTime.now().millisecondsSinceEpoch);
      setState(() {
        _necesitaValidacion28 = false;
        _intentosAcceso28 = 0;
      });
      return true;
    }

    final nuevosIntentos = (_intentosAcceso28 + 1).clamp(0, 3);
    final debeBloquear = nuevosIntentos >= 3;
    await prefs.setInt('intentos_acceso_28', nuevosIntentos);
    if (debeBloquear) {
      await prefs.setBool('app_bloqueada_28', true);
    }
    setState(() {
      _intentosAcceso28 = nuevosIntentos;
      _appBloqueada28 = debeBloquear;
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aprendiendo a Controlar',
      debugShowCheckedModeBanner: false,
      theme: AppColors(false).themeData,
      darkTheme: AppColors(true).themeData,
      themeMode: _modoOscuro ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _appBloqueada28
          ? _AccessGate28(
              appBloqueada: true,
              intentosUsados: 3,
              onValidarAcceso: _validarAcceso28,
            )
          : (_accesoAutorizado
              ? (_necesitaValidacion28
                  ? _AccessGate28(
                      appBloqueada: false,
                      intentosUsados: _intentosAcceso28,
                      onValidarAcceso: _validarAcceso28,
                    )
                  : _RootNavigator(
                      modoOscuro: _modoOscuro,
                      onToggleModoOscuro: _toggleModoOscuro,
                      perfilActivoInicial: widget.perfilActivoInicial,
                      perfilesIniciales: widget.perfilesIniciales,
                    ))
              : _AccessGate(
                  appBloqueada: _appBloqueada,
                  intentosUsados: _intentosAcceso,
                  onValidarAcceso: _validarAcceso,
                )),
    );
  }
}

class _AccessGate extends StatefulWidget {
  final bool appBloqueada;
  final int intentosUsados;
  final Future<bool> Function(String password) onValidarAcceso;

  const _AccessGate({
    required this.appBloqueada,
    required this.intentosUsados,
    required this.onValidarAcceso,
  });

  @override
  State<_AccessGate> createState() => _AccessGateState();
}

class _AccessGateState extends State<_AccessGate> {
  final TextEditingController _passwordController = TextEditingController();
  bool _ocultarPassword = true;
  bool _validando = false;
  String? _mensajeError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  int get _intentosRestantes => (3 - widget.intentosUsados).clamp(0, 3);

  Future<void> _submit() async {
    if (widget.appBloqueada || _validando) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _validando = true;
      _mensajeError = null;
    });

    final correcto = await widget.onValidarAcceso(_passwordController.text);
    if (!mounted || correcto) return;

    _passwordController.clear();
    setState(() {
      _validando = false;
      _mensajeError = _intentosRestantes <= 0
          ? 'Aplicación bloqueada permanentemente.'
          : 'Contraseña incorrecta. Te quedan $_intentosRestantes intento(s).';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isBlocked = widget.appBloqueada;
    final codigoRotacion = (DateTime.now().month - 1) % 5 + 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await SystemNavigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.superficie,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.bordeSuave),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: isBlocked
                              ? colors.rojoClaro
                              : colors.azulClaro,
                          child: Icon(
                            isBlocked
                                ? Icons.lock_outline
                                : Icons.verified_user_outlined,
                            color: isBlocked ? colors.rojo : colors.azul,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          isBlocked ? 'Acceso bloqueado' : 'Acceso inicial',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isBlocked
                              ? 'Se superaron los 3 intentos permitidos. Esta instalación ya no puede abrir la aplicación.'
                              : 'Ingresa la contraseña de activación para usar la app en este dispositivo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.grisTexto,
                            height: 1.35,
                          ),
                        ),
                        if (!isBlocked) ...[
                          const SizedBox(height: 22),
                          TextField(
                            controller: _passwordController,
                            obscureText: _ocultarPassword,
                            enabled: !_validando,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              helperText:
                                  'Intentos restantes: $_intentosRestantes  •  Cód. Rotación: $codigoRotacion',
                              errorText: _mensajeError,
                              prefixIcon: const Icon(Icons.key_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _ocultarPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _ocultarPassword = !_ocultarPassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: colors.superficieSuave,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: colors.bordeSuave,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: colors.bordeSuave,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _validando ? null : _submit,
                            icon: _validando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(_validando ? 'Validando...' : 'Entrar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.azul,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 22),
                          OutlinedButton.icon(
                            onPressed: SystemNavigator.pop,
                            icon: const Icon(Icons.close),
                            label: const Text('Cerrar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessGate28 extends StatefulWidget {
  final bool appBloqueada;
  final int intentosUsados;
  final Future<bool> Function(String password) onValidarAcceso;

  const _AccessGate28({
    required this.appBloqueada,
    required this.intentosUsados,
    required this.onValidarAcceso,
  });

  @override
  State<_AccessGate28> createState() => _AccessGate28State();
}

class _AccessGate28State extends State<_AccessGate28> {
  final TextEditingController _passwordController = TextEditingController();
  bool _ocultarPassword = true;
  bool _validando = false;
  String? _mensajeError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  int get _intentosRestantes => (3 - widget.intentosUsados).clamp(0, 3);

  Future<void> _submit() async {
    if (widget.appBloqueada || _validando) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _validando = true;
      _mensajeError = null;
    });

    final correcto = await widget.onValidarAcceso(_passwordController.text);
    if (!mounted || correcto) return;

    _passwordController.clear();
    setState(() {
      _validando = false;
      _mensajeError = _intentosRestantes <= 0
          ? 'Aplicación bloqueada permanentemente por seguridad.'
          : 'Contraseña incorrecta. Te quedan $_intentosRestantes intento(s).';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isBlocked = widget.appBloqueada;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await SystemNavigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.superficie,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.bordeSuave),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: isBlocked
                              ? colors.rojoClaro
                              : colors.naranjoClaro,
                          child: Icon(
                            isBlocked
                                ? Icons.lock_outline
                                : Icons.security_outlined,
                            color: isBlocked ? colors.rojo : colors.naranjo,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          isBlocked ? 'Aplicación Bloqueada' : 'Control de Seguridad',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isBlocked
                              ? 'La aplicación ha sido bloqueada permanentemente debido a múltiples intentos fallidos de contraseña. Por favor, contacte al administrador de sistemas.'
                              : 'Por razones de seguridad, es necesario verificar tu contraseña de acceso para renovar el uso de la aplicación por 28 días.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.grisTexto,
                            height: 1.35,
                            fontSize: 13,
                          ),
                        ),
                        if (!isBlocked) ...[
                          const SizedBox(height: 22),
                          TextField(
                            controller: _passwordController,
                            obscureText: _ocultarPassword,
                            enabled: !_validando,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Contraseña de Seguridad',
                              helperText: 'Intentos restantes: $_intentosRestantes',
                              errorText: _mensajeError,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _ocultarPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _ocultarPassword = !_ocultarPassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: colors.superficieSuave,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: colors.bordeSuave,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: colors.bordeSuave,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _validando ? null : _submit,
                            icon: _validando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.security_update_good_outlined),
                            label: Text(_validando ? 'Verificando...' : 'Verificar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.naranjo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 22),
                          OutlinedButton.icon(
                            onPressed: SystemNavigator.pop,
                            icon: const Icon(Icons.close),
                            label: const Text('Cerrar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Root Navigator: gestiona la pila de pantallas con Navigator push/pop.
// Mantiene el modo oscuro y lo propaga a todas las pantallas.
// ─────────────────────────────────────────────────────────────────────────────
class _RootNavigator extends StatefulWidget {
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;
  final String perfilActivoInicial;
  final List<String> perfilesIniciales;

  const _RootNavigator({
    required this.modoOscuro,
    required this.onToggleModoOscuro,
    required this.perfilActivoInicial,
    required this.perfilesIniciales,
  });

  @override
  State<_RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<_RootNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late String _perfilActivo;
  late List<String> _perfiles;
  bool _onboardingSeen = true;

  @override
  void initState() {
    super.initState();
    _perfilActivo = widget.perfilActivoInicial;
    _perfiles = List.from(widget.perfilesIniciales);
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (!seen) {
      setState(() {
        _onboardingSeen = false;
      });
    }
  }

  Future<void> _changePerfil(String nuevoPerfil) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = nuevoPerfil.trim();
    if (normalized.isEmpty) return;

    await prefs.setString('perfil_activo', normalized);
    if (!_perfiles.contains(normalized)) {
      setState(() {
        _perfiles.add(normalized);
      });
      await prefs.setStringList('perfiles_lista', _perfiles);
    }
    setState(() {
      _perfilActivo = normalized;
    });
  }

  Future<void> _deletePerfil(String perfilToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _perfiles.remove(perfilToDelete);
    });
    await prefs.setStringList('perfiles_lista', _perfiles);

    // Limpiar preferencias asociadas al perfil eliminado
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith("${perfilToDelete}_")) {
        await prefs.remove(key);
      }
    }

    if (_perfilActivo == perfilToDelete) {
      final nextPerfil = _perfiles.isNotEmpty ? _perfiles.first : 'Usuario Principal';
      if (!_perfiles.contains(nextPerfil)) {
        setState(() {
          _perfiles.add(nextPerfil);
        });
        await prefs.setStringList('perfiles_lista', _perfiles);
      }
      setState(() {
        _perfilActivo = nextPerfil;
      });
      await prefs.setString('perfil_activo', nextPerfil);
    }
  }

  void _navigate(String route, {int? initialTab}) {
    final nav = _navigatorKey.currentState;
    if (nav == null) return;

    // Si la ruta destino es "home", limpiamos toda la pila
    if (route == 'home') {
      nav.popUntil((r) => r.isFirst);
      return;
    }

    nav.push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) =>
            _buildScreen(context, route, initialTab: initialTab),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, String route, {int? initialTab}) {
    final modoOscuro = widget.modoOscuro;
    final onToggle = widget.onToggleModoOscuro;

    switch (route) {
      case AppRoutes.aprenderProcedimiento:
        return AprenderScreen(onBack: () => _navigatorKey.currentState?.pop());

      case AppRoutes.calculadoras:
        return CalculadorasScreen(
          initialTab: initialTab ?? 0,
          onNavigate: _navigate,
        );

      case AppRoutes.regularizacion:
        return CalculadorasScreen(
          initialTab: 3,
          onNavigate: _navigate,
        );

      case AppRoutes.quizPuntaje:
        return QuizScreen(onNavigate: _navigate);

      case AppRoutes.ejerciciosPracticos:
        return EjerciciosScreen(onNavigate: _navigate);

      case AppRoutes.ejerciciosCuaderno:
        return const EjerciciosCuadernoScreen();

      case AppRoutes.stats:
        return StatsScreen(
          onNavigate: _navigate,
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
        );

      case AppRoutes.onboarding:
        return OnboardingScreen(
          onNavigate: (route) {
            setState(() {
              _onboardingSeen = true;
            });
            _navigatorKey.currentState?.popUntil((r) => r.isFirst);
          },
        );

      case AppRoutes.tutorial:
        return TutorialScreen(
          onNavigate: _navigate,
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
        );

      case AppRoutes.instructorPanel:
        return InstructorPanelScreen(
          onNavigate: _navigate,
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
        );

      case AppRoutes.formulario:
        return FormularioScreen(
          onNavigate: _navigate,
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
        );

      case AppRoutes.chatbot:
        return ChatbotScreen(
          onNavigate: _navigate,
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
        );

      case AppRoutes.notas:
        return NotasScreen(
          onNavigate: _navigate,
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
        );

      case AppRoutes.simulacro:
        return SimulacroScreen(
          onNavigate: _navigate,
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
          perfilActivo: _perfilActivo,
        );

      case AppRoutes.camaraFotos:
        return CamaraScreen(
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
          onNavigate: _navigate,
        );

      case AppRoutes.checklistTurno:
        return ChecklistScreen(
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
          onNavigate: _navigate,
          perfilActivo: _perfilActivo,
        );

      case AppRoutes.glosario:
        return GlosarioScreen(
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
          onNavigate: _navigate,
        );

      case AppRoutes.recordatorios:
        return RecordatoriosScreen(
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
          onNavigate: _navigate,
          perfilActivo: _perfilActivo,
        );

      case AppRoutes.procedimientosTeoricos:
        return ProcedimientosScreen(onBack: () => _navigatorKey.currentState?.pop());

      case AppRoutes.documentosObligatorios:
        return DocumentosObligatoriosScreen(onBack: () => _navigatorKey.currentState?.pop());

      // Todas las pantallas informativas pasan por DetallesScreen
      case AppRoutes.criteriosMedicion:
      case AppRoutes.seguridadRiesgos:
      case AppRoutes.reportabilidad:
      case AppRoutes.rotulacionBandejas:
      case AppRoutes.triconoDiametro:
      case AppRoutes.hacerCuaderno:
      case AppRoutes.mapasConceptuales:
        return DetallesScreen(
          seccionId: route,
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
          onNavigate: _navigate,
        );

      default:
        // Fallback al home
        return HomeScreen(
          modoOscuro: modoOscuro,
          onToggleModoOscuro: onToggle,
          onNavigate: _navigate,
          perfilActivo: _perfilActivo,
          perfiles: _perfiles,
          onPerfilChanged: _changePerfil,
          onPerfilDeleted: _deletePerfil,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final nav = _navigatorKey.currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        } else {
          await SystemNavigator.pop();
        }
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => !_onboardingSeen
              ? OnboardingScreen(
                  onNavigate: (route) {
                    setState(() {
                      _onboardingSeen = true;
                    });
                    _navigate(route);
                  },
                )
              : HomeScreen(
                  modoOscuro: widget.modoOscuro,
                  onToggleModoOscuro: widget.onToggleModoOscuro,
                  onNavigate: _navigate,
                  perfilActivo: _perfilActivo,
                  perfiles: _perfiles,
                  onPerfilChanged: _changePerfil,
                  onPerfilDeleted: _deletePerfil,
                ),
        ),
      ),
    );
  }
}
