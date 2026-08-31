import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';
import 'package:aprender_a_controlar/widgets/calculadora_bolsillo.dart';
import 'package:aprender_a_controlar/screens/ejercicios_cuaderno/cuaderno_bienvenida.dart';
import 'package:aprender_a_controlar/screens/ejercicios_cuaderno/cuaderno_resultados.dart';
import 'package:aprender_a_controlar/screens/ejercicios_cuaderno/teclado_cuaderno.dart';
import 'package:aprender_a_controlar/services/stats_service.dart';
import 'package:aprender_a_controlar/screens/ejercicios/ejercicios_helpers.dart';

class EjerciciosCuadernoScreen extends StatefulWidget {
  const EjerciciosCuadernoScreen({super.key});

  @override
  State<EjerciciosCuadernoScreen> createState() => _EjerciciosCuadernoScreenState();
}

class CorridaModel {
  final int index;
  double perforado;
  double recuperado;
  double pctRecuperacion;
  bool esCambioBarril;
  double nuevoBarrilMedida;
  bool esCambioBarras;
  double nuevoLargoBarra;
  int count300;
  int count290;

  // User responses
  double? userContra;
  double? userFondo;
  int? userBarras;
  double? userHerr;
  double? userDesde;

  // Correct calculations
  double correctContra;
  double correctFondo;
  int correctBarras;
  double correctHerramienta;

  // Verification states per cell
  bool? isContraCorrect;
  bool? isFondoCorrect;
  bool? isBarrasCorrect;
  bool? isHerrCorrect;
  bool? isDesdeCorrect;
  bool? isContraInicialCorrect;

  bool respondidoCorrectamente = false;
  bool primerIntentoCorrecto = false;

  CorridaModel({
    required this.index,
    required this.perforado,
    required this.recuperado,
    required this.pctRecuperacion,
    required this.esCambioBarril,
    required this.nuevoBarrilMedida,
    this.esCambioBarras = false,
    this.nuevoLargoBarra = 3.00,
    required this.count300,
    required this.count290,
    required this.correctContra,
    required this.correctFondo,
    required this.correctBarras,
    required this.correctHerramienta,
  });
}

class _EjerciciosCuadernoScreenState extends State<EjerciciosCuadernoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // State variables
  String _pantalla = "bienvenida"; // bienvenida, corrida, resultado
  bool _showCalculator = false;

  // Difficulty & Length configuration (Básico and Intermedio)
  String _nivelDificultad = "Básico"; // Básico, Intermedio
  int _cantidadCorridas = 10; // 5, 10, 15, 20
  double _escalaFuente = 1.0;
  bool _permitirCambioSarta = false; // Toggle switch for sarta/bars change event
  bool _permitirCambioBarril = false; // Toggle switch for barrel change event
  bool _iniciarConBarras300 = true; // Toggle switch for initial bar size: true = 3.00m, false = 2.90m
  bool _esModoManual = false; // Toggle for manual entry mode
  bool _usarExtensionReflex = false; // Toggle for reflex extension (oriented hole) in both auto and manual modes
  int _manualFilaCambioBarril = 5; // Default index (run number) for barrel change in manual mode
  TextEditingController? _activeKeyboardController; // Keeps track of active in-app keyboard controller

  bool _loading = true; // true mientras _loadStateAndInit() no ha terminado

  String _pozoId = '';
  int _barrasIniciales = 0;
  double _largoBarra = 3.0;
  double _puntoMuerto = 0.5;
  double _barrilMedida = 2.6;
  bool _esOrientado = false;
  double _herramientaTotal = 1.5;
  double _contraInicial = 0.0;
  double _fondoInicial = 0.0;

  final List<CorridaModel> _corridas = [];
  int _selectedCorridaIndex = 0; // The active row selected for explanation/reference

  // Dynamic Lists of Controllers for each run
  List<TextEditingController> _contraControllers = [];
  List<TextEditingController> _fondoControllers = [];
  List<TextEditingController> _barrasControllers = [];
  List<TextEditingController> _herrControllers = [];
  List<TextEditingController> _desdeControllers = [];

  // Controllers for Manual Mode (Perforado & Recuperado)
  List<TextEditingController> _perfControllers = [];
  List<TextEditingController> _recControllers = [];

  // Welcome page controllers for Manual Mode parameters setup
  final TextEditingController _manualPozoIdController = TextEditingController(text: "DDH-MANUAL");
  final TextEditingController _manualBarrasController = TextEditingController(text: "0");
  final TextEditingController _manualPuntoMuertoController = TextEditingController(text: "0.5");
  final TextEditingController _manualBarrilController = TextEditingController(text: "2.60");
  final TextEditingController _manualContraController = TextEditingController(text: "2.10");

  // Verification stats
  int _totalVerificaciones = 0;
  String? _feedbackExplicativo;
  bool _explicacionVisible = false;
  bool _descVisible = false;
  String _direccionCambioBarril = "Corto a Largo"; // "Corto a Largo" or "Largo a Corto"
  Offset _calcPosition = const Offset(100, 100);

  @override
  void initState() {
    super.initState();
    _loadStateAndInit();
  }

  @override
  void dispose() {
    _disposeControllers();
    _manualPozoIdController.dispose();
    _manualBarrasController.dispose();
    _manualPuntoMuertoController.dispose();
    _manualBarrilController.dispose();
    _manualContraController.dispose();
    super.dispose();
  }

  void _disposeControllers() {
    _activeKeyboardController = null;
    for (var c in _contraControllers) c.dispose();
    for (var c in _fondoControllers) c.dispose();
    for (var c in _barrasControllers) c.dispose();
    for (var c in _herrControllers) c.dispose();
    for (var c in _perfControllers) c.dispose();
    for (var c in _recControllers) c.dispose();
    for (var c in _desdeControllers) c.dispose();
    _contraControllers.clear();
    _fondoControllers.clear();
    _barrasControllers.clear();
    _herrControllers.clear();
    _perfControllers.clear();
    _recControllers.clear();
    _desdeControllers.clear();
  }

  // Helper method for the custom bar-addition rule:
  // "si la contra es menor a lo perforado se agrega barra... si es mayor no se agrega"
  bool _evaluarCondicionAdicion(double contra, double perforado) {
    return contra < perforado;
  }

  Future<void> _loadStateAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    final perfilActivo = prefs.getString('perfil_activo') ?? 'Usuario Principal';
    if (prefs.containsKey('cuaderno_state_$perfilActivo')) {
      await _loadExerciseState();
    } else {
      _generarNuevoPozo();
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveExerciseState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final perfilActivo = prefs.getString('perfil_activo') ?? 'Usuario Principal';

      final state = {
        'pantalla': _pantalla,
        'pozoId': _pozoId,
        'barrasIniciales': _barrasIniciales,
        'largoBarra': _largoBarra,
        'puntoMuerto': _puntoMuerto,
        'barrilMedida': _barrilMedida,
        'esOrientado': _esOrientado,
        'herramientaTotal': _herramientaTotal,
        'contraInicial': _contraInicial,
        'fondoInicial': _fondoInicial,
        'nivelDificultad': _nivelDificultad,
        'cantidadCorridas': _cantidadCorridas,
        'permitirCambioSarta': _permitirCambioSarta,
        'permitirCambioBarril': _permitirCambioBarril,
        'direccionCambioBarril': _direccionCambioBarril,
        'calcX': _calcPosition.dx,
        'calcY': _calcPosition.dy,
        'iniciarConBarras300': _iniciarConBarras300,
        'esModoManual': _esModoManual,
        'usarExtensionReflex': _usarExtensionReflex,
        'manualFilaCambioBarril': _manualFilaCambioBarril,
        'totalVerificaciones': _totalVerificaciones,
        'selectedCorridaIndex': _selectedCorridaIndex,
        'explicacionVisible': _explicacionVisible,
        'corridas': _corridas.map((c) => {
          'index': c.index,
          'perforado': c.perforado,
          'recuperado': c.recuperado,
          'pctRecuperacion': c.pctRecuperacion,
          'esCambioBarril': c.esCambioBarril,
          'nuevoBarrilMedida': c.nuevoBarrilMedida,
          'esCambioBarras': c.esCambioBarras,
          'nuevoLargoBarra': c.nuevoLargoBarra,
          'count300': c.count300,
          'count290': c.count290,
          'correctContra': c.correctContra,
          'correctFondo': c.correctFondo,
          'correctBarras': c.correctBarras,
          'correctHerramienta': c.correctHerramienta,
          'userContra': c.userContra,
          'userFondo': c.userFondo,
          'userBarras': c.userBarras,
          'userHerr': c.userHerr,
          'userDesde': c.userDesde,
          'isContraCorrect': c.isContraCorrect,
          'isFondoCorrect': c.isFondoCorrect,
          'isBarrasCorrect': c.isBarrasCorrect,
          'isHerrCorrect': c.isHerrCorrect,
          'isDesdeCorrect': c.isDesdeCorrect,
          'respondidoCorrectamente': c.respondidoCorrectamente,
          'primerIntentoCorrecto': c.primerIntentoCorrecto,
        }).toList(),
        'userFondoTexts': _fondoControllers.map((c) => c.text).toList(),
        'userBarrasTexts': _barrasControllers.map((c) => c.text).toList(),
        'userHerrTexts': _herrControllers.map((c) => c.text).toList(),
        'userContraTexts': _contraControllers.map((c) => c.text).toList(),
        'userPerfTexts': _perfControllers.map((c) => c.text).toList(),
        'userRecTexts': _recControllers.map((c) => c.text).toList(),
        'userDesdeTexts': _desdeControllers.map((c) => c.text).toList(),
      };

      await prefs.setString('cuaderno_state_$perfilActivo', jsonEncode(state));
    } catch (e) {
      debugPrint("Error saving cuaderno state: $e");
    }
  }

  Future<void> _loadExerciseState() async {
    final prefs = await SharedPreferences.getInstance();
    final perfilActivo = prefs.getString('perfil_activo') ?? 'Usuario Principal';
    final raw = prefs.getString('cuaderno_state_$perfilActivo');
    if (raw == null) return;

    try {
      final state = jsonDecode(raw);
      setState(() {
        _pantalla = state['pantalla'] ?? 'bienvenida';
        _pozoId = state['pozoId'];
        _barrasIniciales = state['barrasIniciales'];
        _largoBarra = state['largoBarra'];
        _puntoMuerto = state['puntoMuerto'];
        _barrilMedida = state['barrilMedida'];
        _esOrientado = state['esOrientado'];
        _herramientaTotal = state['herramientaTotal'];
        _contraInicial = state['contraInicial'];
        _fondoInicial = state['fondoInicial'];
        _nivelDificultad = state['nivelDificultad'] ?? 'Básico';
        _cantidadCorridas = state['cantidadCorridas'] ?? 10;
        _permitirCambioSarta = state['permitirCambioSarta'] ?? false;
        _permitirCambioBarril = state['permitirCambioBarril'] ?? false;
        _direccionCambioBarril = state['direccionCambioBarril'] ?? 'Corto a Largo';
        final double cx = state['calcX']?.toDouble() ?? 100.0;
        final double cy = state['calcY']?.toDouble() ?? 100.0;
        _calcPosition = Offset(cx, cy);
        _iniciarConBarras300 = state['iniciarConBarras300'] ?? true;
        _esModoManual = state['esModoManual'] ?? false;
        _usarExtensionReflex = state['usarExtensionReflex'] ?? false;
        _manualFilaCambioBarril = state['manualFilaCambioBarril'] ?? 5;
        _totalVerificaciones = state['totalVerificaciones'] ?? 0;
        _selectedCorridaIndex = state['selectedCorridaIndex'] ?? 0;
        _explicacionVisible = state['explicacionVisible'] ?? false;

        _corridas.clear();
        _disposeControllers();

        _contraControllers = List.generate(_cantidadCorridas + 1, (_) => TextEditingController());
        _fondoControllers = List.generate(_cantidadCorridas, (_) => TextEditingController());
        _barrasControllers = List.generate(_cantidadCorridas, (_) => TextEditingController());
        _herrControllers = List.generate(_cantidadCorridas, (_) => TextEditingController());
        _perfControllers = List.generate(_cantidadCorridas, (_) => TextEditingController());
        _recControllers = List.generate(_cantidadCorridas, (_) => TextEditingController());
        _desdeControllers = List.generate(_cantidadCorridas - 1, (_) => TextEditingController());

        final list = state['corridas'] as List;
        for (var map in list) {
          final c = CorridaModel(
            index: map['index'],
            perforado: map['perforado'],
            recuperado: map['recuperado'],
            pctRecuperacion: map['pctRecuperacion'],
            esCambioBarril: map['esCambioBarril'],
            nuevoBarrilMedida: map['nuevoBarrilMedida'],
            esCambioBarras: map['esCambioBarras'] ?? false,
            nuevoLargoBarra: map['nuevoLargoBarra'] ?? 3.00,
            count300: map['count300'] ?? 0,
            count290: map['count290'] ?? 0,
            correctContra: map['correctContra'],
            correctFondo: map['correctFondo'],
            correctBarras: map['correctBarras'],
            correctHerramienta: map['correctHerramienta'],
          );
          c.userContra = map['userContra'];
          c.userFondo = map['userFondo'];
          c.userBarras = map['userBarras'];
          c.userHerr = map['userHerr'];
          c.userDesde = map['userDesde'];
          c.isContraCorrect = map['isContraCorrect'];
          c.isFondoCorrect = map['isFondoCorrect'];
          c.isBarrasCorrect = map['isBarrasCorrect'];
          c.isHerrCorrect = map['isHerrCorrect'];
          c.isDesdeCorrect = map['isDesdeCorrect'];
          c.respondidoCorrectamente = map['respondidoCorrectamente'] ?? false;
          c.primerIntentoCorrecto = map['primerIntentoCorrecto'] ?? false;
          _corridas.add(c);
        }

        final fondoTexts = state['userFondoTexts'] as List;
        final barrasTexts = state['userBarrasTexts'] as List;
        final herrTexts = state['userHerrTexts'] as List;
        final contraTexts = state['userContraTexts'] as List;
        final perfTexts = state['userPerfTexts'] as List?;
        final recTexts = state['userRecTexts'] as List?;
        final desdeTexts = state['userDesdeTexts'] as List?;

        for (int i = 0; i < _cantidadCorridas; i++) {
          _fondoControllers[i].text = fondoTexts[i];
          _barrasControllers[i].text = barrasTexts[i];
          _herrControllers[i].text = herrTexts[i];
          _contraControllers[i].text = contraTexts[i];
          if (i > 0 && desdeTexts != null && (i - 1) < desdeTexts.length) {
            _desdeControllers[i - 1].text = desdeTexts[i - 1];
          }
          if (perfTexts != null && i < perfTexts.length) {
            _perfControllers[i].text = perfTexts[i];
          }
          if (recTexts != null && i < recTexts.length) {
            _recControllers[i].text = recTexts[i];
          }
        }

        _setupRealTimeValidation();

        if (_explicacionVisible && _selectedCorridaIndex < _cantidadCorridas) {
          _generarFeedbackExplicativo(_selectedCorridaIndex);
        }
      });
    } catch (e) {
      debugPrint("Error loading cuaderno state: $e");
    }
  }

  void _mostrarConfirmacionFinalizar() {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.fondo,
          title: Text(
            "Finalizar Ejercicio",
            style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            "¿Estás seguro de finalizar el ejercicio?",
            style: TextStyle(color: colors.grisTexto, fontSize: 14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("No", style: TextStyle(color: colors.grisTexto)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _finalizarEjercicio();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.naranjo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Sí, finalizar"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarConfirmacionLimpiar() {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.fondo,
          title: Text(
            "Limpiar Cuaderno",
            style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            "¿Estás seguro de limpiar el cuaderno? Se borrarán todas las respuestas ingresadas.",
            style: TextStyle(color: colors.grisTexto, fontSize: 14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("No", style: TextStyle(color: colors.grisTexto)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _limpiarCuaderno();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.rojo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Sí, limpiar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _finalizarEjercicio() async {
    final prefs = await SharedPreferences.getInstance();
    final perfilActivo = prefs.getString('perfil_activo') ?? 'Usuario Principal';
    await prefs.remove('cuaderno_state_$perfilActivo');
    
    final aciertos = _calcularPuntajeFinal();
    StatsService.registrarResultado(
      aciertos: aciertos,
      total: _cantidadCorridas,
      modo: "Cuaderno Pozo $_pozoId",
      tiempoSegundos: 0,
    );

    setState(() {
      _pantalla = "resultado";
      _activeKeyboardController = null; // Clear keyboard state
    });
  }

  void _generarNuevoPozo() {
    final random = Random();
    
    if (_esModoManual) {
      // Manual Mode setup
      _pozoId = _manualPozoIdController.text.trim();
      _barrasIniciales = int.tryParse(_manualBarrasController.text.trim()) ?? 0;
      _largoBarra = _iniciarConBarras300 ? 3.00 : 2.90;
      _puntoMuerto = double.tryParse(_manualPuntoMuertoController.text.trim().replaceAll(',', '.')) ?? 0.5;
      if (_permitirCambioBarril) {
        _barrilMedida = (_direccionCambioBarril == "Corto a Largo") ? 2.60 : 4.15;
        _manualBarrilController.text = _barrilMedida.toStringAsFixed(2);
      } else {
        _barrilMedida = double.tryParse(_manualBarrilController.text.trim().replaceAll(',', '.')) ?? 2.60;
      }
      _esOrientado = _usarExtensionReflex; // Reflex extension switch
      
      _herramientaTotal = (_barrasIniciales * _largoBarra) + _barrilMedida + (_esOrientado ? 0.40 : 0.0) - _puntoMuerto;
      // Condition: tool initial must always be equal to contra in the first row
      _contraInicial = _herramientaTotal;
      _contraInicial = double.parse(_contraInicial.toStringAsFixed(2));
      _fondoInicial = 0.00;
    } else {
      // Automatic Mode setup
      _pozoId = "DDH-4${100 + random.nextInt(900)}";
      _largoBarra = _iniciarConBarras300 ? 3.00 : 2.90;
      final pmOpciones = [0.5, 1.0, 1.5, 2.0];
      _puntoMuerto = pmOpciones[random.nextInt(pmOpciones.length)];
      _esOrientado = _usarExtensionReflex; // Reflex extension switch
      if (_permitirCambioBarril) {
        _barrilMedida = (_direccionCambioBarril == "Corto a Largo") ? 2.60 : 4.15;
      } else {
        _barrilMedida = (random.nextInt(100) < 95) ? 2.60 : 4.15;
      }

      if (_nivelDificultad == "Básico") {
        _fondoInicial = 0.00;
        _barrasIniciales = 0;
        _herramientaTotal = _barrilMedida + (_esOrientado ? 0.40 : 0.0) - _puntoMuerto;
        _contraInicial = _herramientaTotal;
        _contraInicial = double.parse(_contraInicial.toStringAsFixed(2));
      } else {
        _barrasIniciales = 30 + random.nextInt(31);
        _contraInicial = (2 + random.nextInt(4)) * 0.5;
        _herramientaTotal = (_barrasIniciales * _largoBarra) + _barrilMedida + (_esOrientado ? 0.40 : 0.0) - _puntoMuerto;
        _fondoInicial = _herramientaTotal - _contraInicial;
        _fondoInicial = double.parse(_fondoInicial.toStringAsFixed(2));
      }
    }

    _corridas.clear();
    _disposeControllers();

    _contraControllers = List.generate(_cantidadCorridas + 1, (_) => TextEditingController());
    _fondoControllers = List.generate(_cantidadCorridas, (_) => TextEditingController());
    _barrasControllers = List.generate(_cantidadCorridas, (_) => TextEditingController());
    _herrControllers = List.generate(_cantidadCorridas, (_) => TextEditingController());
    _perfControllers = List.generate(_cantidadCorridas, (_) => TextEditingController(text: "0.0"));
    _recControllers = List.generate(_cantidadCorridas, (_) => TextEditingController(text: "0.0"));
    _desdeControllers = List.generate(_cantidadCorridas - 1, (_) => TextEditingController());

    double currentContra = _contraInicial;
    double currentFondo = _fondoInicial;
    double currentBarrilMedida = _barrilMedida;

    int bars300 = (_largoBarra == 3.00) ? _barrasIniciales : 0;
    int bars290 = (_largoBarra == 2.90) ? _barrasIniciales : 0;
    double currentLargoBarra = _largoBarra;

    final Set<int> cambioBarrilIndices = {};
    final Set<int> cambioBarrasIndices = {};

    if (_permitirCambioBarril) {
      if (_esModoManual) {
        cambioBarrilIndices.add(_manualFilaCambioBarril.clamp(1, _cantidadCorridas));
      } else {
        cambioBarrilIndices.add(_cantidadCorridas ~/ 2);
      }
    }

    if (_permitirCambioSarta) {
      int idxBarras = _cantidadCorridas ~/ 4;
      if (_permitirCambioBarril && cambioBarrilIndices.contains(idxBarras)) {
        idxBarras = (cambioBarrilIndices.first - 2).clamp(1, _cantidadCorridas);
      }
      cambioBarrasIndices.add(idxBarras);
    }

    for (int i = 1; i <= _cantidadCorridas; i++) {
      if (cambioBarrilIndices.contains(i)) {
        final nuevoMedida = (currentBarrilMedida == 2.60) ? 4.15 : 2.60;
        final diff = nuevoMedida - currentBarrilMedida;
        final currentHerramienta = (bars300 * 3.00) + (bars290 * 2.90) + nuevoMedida + (_esOrientado ? 0.40 : 0.0) - _puntoMuerto;
        currentContra = currentContra + diff;
        currentBarrilMedida = nuevoMedida;

        _corridas.add(CorridaModel(
          index: i,
          perforado: 0.0,
          recuperado: 0.0,
          pctRecuperacion: 0.0,
          esCambioBarril: true,
          nuevoBarrilMedida: nuevoMedida,
          esCambioBarras: false,
          nuevoLargoBarra: currentLargoBarra,
          count300: bars300,
          count290: bars290,
          correctContra: double.parse(currentContra.toStringAsFixed(2)),
          correctFondo: double.parse(currentFondo.toStringAsFixed(2)),
          correctBarras: bars300 + bars290,
          correctHerramienta: double.parse(currentHerramienta.toStringAsFixed(2)),
        ));
      } else if (cambioBarrasIndices.contains(i)) {
        final nuevoLargo = (currentLargoBarra == 3.00) ? 2.90 : 3.00;
        currentLargoBarra = nuevoLargo;
        final currentHerramienta = (bars300 * 3.00) + (bars290 * 2.90) + currentBarrilMedida + (_esOrientado ? 0.40 : 0.0) - _puntoMuerto;

        _corridas.add(CorridaModel(
          index: i,
          perforado: 0.0,
          recuperado: 0.0,
          pctRecuperacion: 0.0,
          esCambioBarril: false,
          nuevoBarrilMedida: currentBarrilMedida,
          esCambioBarras: true,
          nuevoLargoBarra: nuevoLargo,
          count300: bars300,
          count290: bars290,
          correctContra: double.parse(currentContra.toStringAsFixed(2)),
          correctFondo: double.parse(currentFondo.toStringAsFixed(2)),
          correctBarras: bars300 + bars290,
          correctHerramienta: double.parse(currentHerramienta.toStringAsFixed(2)),
        ));
      } else {
        // Normal runs in auto mode are generated, in manual mode they start at 0.0
        double perforado = 0.0;
        double recuperado = 0.0;
        double pctRec = 0.0;

        if (!_esModoManual) {
          perforado = (2 + random.nextInt(4)) * 0.5;
          recuperado = perforado * (85 + random.nextInt(16)) / 100.0;
          recuperado = double.parse(recuperado.toStringAsFixed(2));
          if (recuperado > perforado) {
            recuperado = perforado;
          }
          pctRec = double.parse(((recuperado / perforado) * 100).toStringAsFixed(1));
        }

        // Apply new sarta addition rule: contra < perforado
        bool seAgregaBarra = _evaluarCondicionAdicion(currentContra, perforado);

        if (seAgregaBarra) {
          if (currentLargoBarra == 3.00) {
            bars300++;
          } else {
            bars290++;
          }
          currentContra = currentContra + currentLargoBarra;
        }
        currentContra = currentContra - perforado;
        currentFondo = currentFondo + perforado;
        final currentHerramienta = (bars300 * 3.00) + (bars290 * 2.90) + currentBarrilMedida + (_esOrientado ? 0.40 : 0.0) - _puntoMuerto;

        _corridas.add(CorridaModel(
          index: i,
          perforado: perforado,
          recuperado: recuperado,
          pctRecuperacion: pctRec,
          esCambioBarril: false,
          nuevoBarrilMedida: currentBarrilMedida,
          esCambioBarras: false,
          nuevoLargoBarra: currentLargoBarra,
          count300: bars300,
          count290: bars290,
          correctContra: double.parse(currentContra.toStringAsFixed(2)),
          correctFondo: double.parse(currentFondo.toStringAsFixed(2)),
          correctBarras: bars300 + bars290,
          correctHerramienta: double.parse(currentHerramienta.toStringAsFixed(2)),
        ));

        if (_esModoManual) {
          _perfControllers[i - 1].text = "0.0";
          _recControllers[i - 1].text = "0.0";
        }
      }
    }

    _selectedCorridaIndex = 0;
    _totalVerificaciones = 0;
    _explicacionVisible = false;
    _feedbackExplicativo = null;

    _setupRealTimeValidation();
    _saveExerciseState();
  }

  void _recalcularValoresCorrectos() {
    double currentContra = _contraInicial;
    double currentFondo = _fondoInicial;
    double currentBarrilMedida = _barrilMedida;

    int bars300 = (_largoBarra == 3.00) ? _barrasIniciales : 0;
    int bars290 = (_largoBarra == 2.90) ? _barrasIniciales : 0;
    double currentLargoBarra = _largoBarra;

    final Set<int> cambioBarrilIndices = {};
    final Set<int> cambioBarrasIndices = {};

    if (_permitirCambioBarril) {
      if (_esModoManual) {
        cambioBarrilIndices.add(_manualFilaCambioBarril.clamp(1, _cantidadCorridas));
      } else {
        cambioBarrilIndices.add(_cantidadCorridas ~/ 2);
      }
    }

    if (_permitirCambioSarta) {
      int idxBarras = _cantidadCorridas ~/ 4;
      if (_permitirCambioBarril && cambioBarrilIndices.contains(idxBarras)) {
        idxBarras = (cambioBarrilIndices.first - 2).clamp(1, _cantidadCorridas);
      }
      cambioBarrasIndices.add(idxBarras);
    }

    for (int i = 0; i < _cantidadCorridas; i++) {
      final item = _corridas[i];
      final runNum = i + 1;

      if (cambioBarrilIndices.contains(runNum)) {
        final nuevoMedida = (currentBarrilMedida == 2.60) ? 4.15 : 2.60;
        final diff = nuevoMedida - currentBarrilMedida;
        final currentHerramienta = (bars300 * 3.00) + (bars290 * 2.90) + nuevoMedida + (_esOrientado ? 0.40 : 0.0) - _puntoMuerto;
        currentContra = currentContra + diff;
        currentBarrilMedida = nuevoMedida;

        item.esCambioBarril = true;
        item.nuevoBarrilMedida = nuevoMedida;
        item.esCambioBarras = false;
        item.count300 = bars300;
        item.count290 = bars290;
        item.correctContra = double.parse(currentContra.toStringAsFixed(2));
        item.correctFondo = double.parse(currentFondo.toStringAsFixed(2));
        item.correctBarras = bars300 + bars290;
        item.correctHerramienta = double.parse(currentHerramienta.toStringAsFixed(2));
      } else if (cambioBarrasIndices.contains(runNum)) {
        final nuevoLargo = (currentLargoBarra == 3.00) ? 2.90 : 3.00;
        currentLargoBarra = nuevoLargo;
        final currentHerramienta = (bars300 * 3.00) + (bars290 * 2.90) + currentBarrilMedida + (_esOrientado ? 0.40 : 0.0) - _puntoMuerto;

        item.esCambioBarril = false;
        item.esCambioBarras = true;
        item.nuevoLargoBarra = nuevoLargo;
        item.count300 = bars300;
        item.count290 = bars290;
        item.correctContra = double.parse(currentContra.toStringAsFixed(2));
        item.correctFondo = double.parse(currentFondo.toStringAsFixed(2));
        item.correctBarras = bars300 + bars290;
        item.correctHerramienta = double.parse(currentHerramienta.toStringAsFixed(2));
      } else {
        final perfVal = item.perforado;

        // Apply rule: contra < perforado
        bool seAgregaBarra = _evaluarCondicionAdicion(currentContra, perfVal);

        if (seAgregaBarra) {
          if (currentLargoBarra == 3.00) {
            bars300++;
          } else {
            bars290++;
          }
          currentContra = currentContra + currentLargoBarra;
        }
        currentContra = currentContra - perfVal;
        currentFondo = currentFondo + perfVal;
        final currentHerramienta = (bars300 * 3.00) + (bars290 * 2.90) + currentBarrilMedida + (_esOrientado ? 0.40 : 0.0) - _puntoMuerto;

        item.esCambioBarril = false;
        item.esCambioBarras = false;
        item.count300 = bars300;
        item.count290 = bars290;
        item.correctContra = double.parse(currentContra.toStringAsFixed(2));
        item.correctFondo = double.parse(currentFondo.toStringAsFixed(2));
        item.correctBarras = bars300 + bars290;
        item.correctHerramienta = double.parse(currentHerramienta.toStringAsFixed(2));
      }
    }
  }

  void _onPerfOrRecChanged(int i) {
    final item = _corridas[i];
    final perfText = _perfControllers[i].text.trim().replaceAll(',', '.');
    final recText = _recControllers[i].text.trim().replaceAll(',', '.');

    final newPerf = double.tryParse(perfText) ?? 0.0;
    final newRec = double.tryParse(recText) ?? 0.0;

    setState(() {
      item.perforado = newPerf;
      item.recuperado = newRec;
      item.pctRecuperacion = (newPerf > 0)
          ? double.parse(((newRec / newPerf) * 100).toStringAsFixed(1))
          : 0.0;

      // Dynamic chain recalculation of correct answers
      _recalcularValoresCorrectos();

      // Trigger validation for all rows immediately
      for (int idx = 0; idx < _cantidadCorridas; idx++) {
        _validarFilaRealTime(idx);
      }
    });

    _saveExerciseState();
  }

  void _mostrarDatosPozoPopup(BuildContext context) {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: colors.fondo,
          title: Text(
            "Datos Iniciales del Pozo ℹ️",
            style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPopupDataRow("Identificador del Pozo:", _pozoId, colors),
                _buildPopupDataRow("Fondo Inicial:", "${_fondoInicial.toStringAsFixed(2)} m", colors),
                _buildPopupDataRow("Contra Inicial:", "${_contraInicial.toStringAsFixed(2)} m", colors),
                _buildPopupDataRow("Barras Iniciales en Sarta:", "$_barrasIniciales", colors),
                _buildPopupDataRow("Largo de Barra de Partida:", "${_largoBarra.toStringAsFixed(2)} m", colors),
                _buildPopupDataRow("Punto Muerto:", "${_puntoMuerto.toStringAsFixed(2)} m", colors),
                _buildPopupDataRow("Barril Inicial:", "${_barrilMedida.toStringAsFixed(2)} m (${_barrilMedida == 2.60 ? 'Corto' : 'Largo'})", colors),
                _buildPopupDataRow("Sondaje Orientado (Reflex):", _esOrientado ? "Sí (+0.40m)" : "No", colors),
                _buildPopupDataRow("Herr Inicial (Total herramientas):", "${_herramientaTotal.toStringAsFixed(2)} m", colors),
                const Divider(height: 24, thickness: 1, color: Color(0xFF93C5FD)),
                const Text(
                  "Nota: Cuando hay cambio de barril de 2.60 m al de 4.15 m se debe sumar 1.55 m (la diferencia) a la Herr y a la contra, en caso de que se pase de barril largo al corto, se deben restar los 1.55 a la Herr y a la Contra (si al hacer la resta a la contra, esta da negativa, se debe agregar una barra). Esto es independiente si se cuenta con la extensión del reflex.",
                  style: TextStyle(
                    color: Color(0xFFE11D48),
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cerrar", style: TextStyle(color: colors.azul, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPopupDataRow(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.grisTexto, fontSize: 13)),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13.5)),
        ],
      ),
    );
  }

  void _setupRealTimeValidation() {
    for (int i = 0; i < _cantidadCorridas; i++) {
      _fondoControllers[i].addListener(() => _validarFilaRealTime(i));
      _barrasControllers[i].addListener(() => _validarFilaRealTime(i));
      _herrControllers[i].addListener(() => _validarFilaRealTime(i));
      if (i > 0) {
        _desdeControllers[i - 1].addListener(() => _validarFilaRealTime(i));
      }
      if (_esModoManual) {
        _perfControllers[i].addListener(() => _onPerfOrRecChanged(i));
        _recControllers[i].addListener(() => _onPerfOrRecChanged(i));
      }
    }
    
    // Contra controllers triggers validation
    _contraControllers[0].addListener(() => _validarFilaRealTime(0));
    for (int i = 1; i <= _cantidadCorridas; i++) {
      _contraControllers[i].addListener(() => _validarFilaRealTime(i - 1));
    }
  }

  void _validarFilaRealTime(int i) {
    final item = _corridas[i];
    final isCambio = item.esCambioBarril || item.esCambioBarras;

    final fondoText = _fondoControllers[i].text.trim().replaceAll(',', '.');
    final barrasText = _barrasControllers[i].text.trim();
    final herrText = _herrControllers[i].text.trim().replaceAll(',', '.');
    final contraText = _contraControllers[i + 1].text.trim().replaceAll(',', '.');

    String desdeText = "";
    if (i > 0) {
      desdeText = _desdeControllers[i - 1].text.trim().replaceAll(',', '.');
    }

    final bool needsContraInicial = (i == 0 && _corridas[0].perforado > _contraInicial);
    final String contraInicialText = needsContraInicial ? _contraControllers[0].text.trim().replaceAll(',', '.') : "";

    final hasRequiredInputs = isCambio
        ? (barrasText.isNotEmpty && herrText.isNotEmpty && contraText.isNotEmpty)
        : (fondoText.isNotEmpty && barrasText.isNotEmpty && herrText.isNotEmpty && contraText.isNotEmpty && (i == 0 || desdeText.isNotEmpty) && (!needsContraInicial || contraInicialText.isNotEmpty));

    if (!hasRequiredInputs) {
      setState(() {
        item.isFondoCorrect = null;
        item.isBarrasCorrect = null;
        item.isHerrCorrect = null;
        item.isContraCorrect = null;
        if (i == 0) item.isContraInicialCorrect = null;
        if (i > 0) item.isDesdeCorrect = null;
        item.respondidoCorrectamente = false;
      });
      return;
    }

    final userFondo = isCambio ? item.correctFondo : double.tryParse(fondoText);
    final userBarras = int.tryParse(barrasText);
    final userHerr = double.tryParse(herrText);
    final userContra = double.tryParse(contraText);
    final userDesde = (i > 0 && !isCambio) ? double.tryParse(desdeText) : (i > 0 ? _corridas[i - 1].correctFondo : null);
    final userContraInicial = needsContraInicial ? double.tryParse(contraInicialText) : null;

    final fondoOk = isCambio ? true : (userFondo != null && (userFondo - item.correctFondo).abs() <= 0.01);
    final barrasOk = (userBarras != null && userBarras == item.correctBarras);
    final herrOk = (userHerr != null && (userHerr - item.correctHerramienta).abs() <= 0.01);

    final correctContraVal = (i < _cantidadCorridas - 1)
        ? _corridas[i + 1].correctContra + _corridas[i + 1].perforado
        : _corridas.last.correctContra;
    final contraOk = (userContra != null && (userContra - correctContraVal).abs() <= 0.01);

    bool desdeOk = true;
    if (i > 0 && !isCambio) {
      final correctDesdeVal = _corridas[i - 1].correctFondo;
      desdeOk = (userDesde != null && (userDesde - correctDesdeVal).abs() <= 0.01);
    }

    bool contraInicialOk = true;
    if (needsContraInicial) {
      final expectedContraInicial = _contraInicial + item.nuevoLargoBarra;
      contraInicialOk = (userContraInicial != null && (userContraInicial - expectedContraInicial).abs() <= 0.01);
    }

    setState(() {
      item.userFondo = userFondo;
      item.userBarras = userBarras;
      item.userHerr = userHerr;
      item.userContra = userContra;
      if (i > 0) {
        item.userDesde = userDesde;
        if (!isCambio) {
          item.isDesdeCorrect = desdeOk;
        } else {
          item.isDesdeCorrect = null;
        }
      }
      if (needsContraInicial) {
        item.isContraInicialCorrect = contraInicialOk;
      } else {
        item.isContraInicialCorrect = null;
      }

      if (!isCambio) {
        item.isFondoCorrect = fondoOk;
      } else {
        item.isFondoCorrect = null;
      }
      item.isBarrasCorrect = barrasOk;
      item.isHerrCorrect = herrOk;
      item.isContraCorrect = contraOk;

      item.respondidoCorrectamente = (fondoOk && barrasOk && herrOk && contraOk && desdeOk && contraInicialOk);

      if (_totalVerificaciones == 0 && item.respondidoCorrectamente) {
        item.primerIntentoCorrecto = true;
      }

      // Auto-advance logic:
      if (item.respondidoCorrectamente && i == _selectedCorridaIndex) {
        if (_selectedCorridaIndex < _cantidadCorridas) {
          final nextIndex = _selectedCorridaIndex + 1;
          _selectedCorridaIndex = nextIndex;
          _activeKeyboardController = null;
          _feedbackExplicativo = null;
          _descVisible = false; // Collapse the description block for the next run
          if (nextIndex < _cantidadCorridas) {
            _generarFeedbackExplicativo(nextIndex);
          }
        }
      }
    });
  }

  void _iniciarEjercicio() {
    setState(() {
      _pantalla = "corrida";
    });
    _saveExerciseState();
  }

  void _limpiarCuaderno() {
    setState(() {
      _feedbackExplicativo = null;
      for (int i = 0; i < _cantidadCorridas; i++) {
        final item = _corridas[i];
        item.userContra = null;
        item.userFondo = null;
        item.userBarras = null;
        item.userHerr = null;
        item.userDesde = null;
        item.isContraCorrect = null;
        item.isFondoCorrect = null;
        item.isBarrasCorrect = null;
        item.isHerrCorrect = null;
        item.isDesdeCorrect = null;
        item.isContraInicialCorrect = null;
        item.respondidoCorrectamente = false;

        _contraControllers[i].clear();
        _fondoControllers[i].clear();
        _barrasControllers[i].clear();
        _herrControllers[i].clear();
        if (i > 0) {
          _desdeControllers[i - 1].clear();
        }
        if (_esModoManual) {
          item.perforado = 0.0;
          item.recuperado = 0.0;
          item.pctRecuperacion = 0.0;
          _perfControllers[i].clear();
          _recControllers[i].clear();
        }
      }
      _contraControllers[_cantidadCorridas].clear();
      if (_esModoManual) {
        _recalcularValoresCorrectos();
      }
    });
    _saveExerciseState();
  }

  void _generarFeedbackExplicativo(int index) {
    final current = _corridas[index];
    final sb = StringBuffer();
    sb.writeln("💡 Explicación de la Corrida ${index + 1}:");

    if (current.esCambioBarril) {
      final prevBarril = (index == 0) ? _barrilMedida : _corridas[index - 1].nuevoBarrilMedida;
      final diff = current.nuevoBarrilMedida - prevBarril;
      final sign = diff >= 0 ? "+" : "";

      sb.writeln("• Evento Especial: Cambio de Barril.");
      sb.writeln("• Medida anterior: ${prevBarril.toStringAsFixed(2)} m.");
      sb.writeln("• Nueva medida: ${current.nuevoBarrilMedida.toStringAsFixed(2)} m.");
      sb.writeln("• Diferencia entre barriles: $sign${diff.toStringAsFixed(2)} m.");
      sb.writeln("• Reglas de Cálculo en Terreno:");
      sb.writeln("  1. El Fondo del Pozo NO cambia y se mantiene en ${current.correctFondo.toStringAsFixed(2)} m.");
      sb.writeln("  2. Barras en Sarta se mantienen en ${current.correctBarras} barras.");
      sb.writeln("  3. El Total de Herramientas (Herr.) aumenta en la diferencia: Herr anterior ($sign${diff.toStringAsFixed(2)}m) = ${current.correctHerramienta.toStringAsFixed(2)} m.");
      sb.writeln("  4. La Contra aumenta en la diferencia: Contra anterior ($sign${diff.toStringAsFixed(2)}m) = ${current.correctContra.toStringAsFixed(2)} m.");
    } else if (current.esCambioBarras) {
      final prevLargo = (index == 0) ? _largoBarra : _corridas[index - 1].nuevoLargoBarra;

      sb.writeln("• Evento Especial: Cambio de Barras en sarta.");
      sb.writeln("• Largo de barra anterior: ${prevLargo.toStringAsFixed(2)} m.");
      sb.writeln("• Nuevo largo de barra de adición: ${current.nuevoLargoBarra.toStringAsFixed(2)} m.");
      sb.writeln("• Reglas de Cálculo en Terreno:");
      sb.writeln("  1. El Fondo del Pozo NO cambia y se mantiene en ${current.correctFondo.toStringAsFixed(2)} m.");
      sb.writeln("  2. Barras en Sarta y Contra se mantienen iguales (${current.correctBarras} barras, ${current.correctContra.toStringAsFixed(2)} m).");
      sb.writeln("  3. El Total de Herramientas (Herr.) se mantiene en ${current.correctHerramienta.toStringAsFixed(2)} m (las barras en pozo no han cambiado aún).");
      sb.writeln("  4. A partir de la siguiente corrida, cualquier barra adicional que se agregue medirá ${current.nuevoLargoBarra.toStringAsFixed(2)} m.");
    } else {
      final prevContra = (index == 0) ? _contraInicial : _corridas[index - 1].correctContra;
      final prevFondo = (index == 0) ? _fondoInicial : _corridas[index - 1].correctFondo;
      final prevBarras = (index == 0) ? _barrasIniciales : _corridas[index - 1].correctBarras;
      final currentLargo = current.nuevoLargoBarra;

      sb.writeln("• Avance de Corrida: Perforado = ${current.perforado.toStringAsFixed(1)} m.");
      
      if (prevContra < current.perforado) {
        sb.writeln("• Adición de Barra: Como la contra anterior (${prevContra.toStringAsFixed(2)} m) es menor al perforado (${current.perforado.toStringAsFixed(1)} m), se adiciona una barra de ${currentLargo.toStringAsFixed(2)} m.");
        sb.writeln("• Barras en sarta: $prevBarras + 1 = ${current.correctBarras} barras.");
        sb.writeln("• Contra Ajustada (a escribir en el cuaderno): ${(prevContra + currentLargo).toStringAsFixed(2)} m.");
        sb.writeln("• Nueva Contra: Contra Ajustada - Perforado = ${(prevContra + currentLargo).toStringAsFixed(2)} - ${current.perforado.toStringAsFixed(1)} = ${current.correctContra.toStringAsFixed(2)} m.");
      } else {
        sb.writeln("• Sin Adición de Barra: La contra anterior (${prevContra.toStringAsFixed(2)} m) es mayor o igual al perforado (${current.perforado.toStringAsFixed(1)} m). No se agrega barra.");
        sb.writeln("• Barras en sarta: Se mantienen en $prevBarras barras.");
        sb.writeln("• Contra Ajustada (Contra Anterior - a escribir en el cuaderno): ${prevContra.toStringAsFixed(2)} m.");
        sb.writeln("• Nueva Contra: Contra Ajustada - Perforado = ${prevContra.toStringAsFixed(2)} - ${current.perforado.toStringAsFixed(1)} = ${current.correctContra.toStringAsFixed(2)} m.");
      }

      sb.writeln("• Nuevo Fondo: Fondo Anterior + Perforado = ${prevFondo.toStringAsFixed(2)} + ${current.perforado.toStringAsFixed(1)} = ${current.correctFondo.toStringAsFixed(2)} m.");
      sb.writeln("• Herramientas (Herr.): \$\$\\text{Herr} = (\\text{Barras} \\times \\text{Largo}) + \\text{Barril} + \\text{Extensión} - \\text{PM}\$\$");
      if (current.count300 > 0 && current.count290 > 0) {
        sb.writeln("  \$\$(${current.count300} \\times 3.00) + (${current.count290} \\times 2.90) + ${current.nuevoBarrilMedida.toStringAsFixed(2)} + ${_esOrientado ? '0.40' : '0.00'} - ${_puntoMuerto.toStringAsFixed(2)} = ${current.correctHerramienta.toStringAsFixed(2)}\\text{ m}\$\$");
      } else if (current.count300 > 0) {
        sb.writeln("  \$\$(${current.count300} \\times 3.00) + ${current.nuevoBarrilMedida.toStringAsFixed(2)} + ${_esOrientado ? '0.40' : '0.00'} - ${_puntoMuerto.toStringAsFixed(2)} = ${current.correctHerramienta.toStringAsFixed(2)}\\text{ m}\$\$");
      } else {
        sb.writeln("  \$\$(${current.count290} \\times 2.90) + ${current.nuevoBarrilMedida.toStringAsFixed(2)} + ${_esOrientado ? '0.40' : '0.00'} - ${_puntoMuerto.toStringAsFixed(2)} = ${current.correctHerramienta.toStringAsFixed(2)}\\text{ m}\$\$");
      }
      sb.writeln("• Verificación por Fórmula:");
      sb.writeln("  \$\$\\text{Fondo} = \\text{Herr} - \\text{Contra}\$\$");
      sb.writeln("  \$\$${current.correctHerramienta.toStringAsFixed(2)} - ${current.correctContra.toStringAsFixed(2)} = ${current.correctFondo.toStringAsFixed(2)}\\text{ m}\$\$");
    }

    _feedbackExplicativo = sb.toString();
  }

  int _calcularPuntajeFinal() {
    int correctasAlPrimerIntento = 0;
    for (var corrida in _corridas) {
      if (corrida.primerIntentoCorrecto) {
        correctasAlPrimerIntento++;
      }
    }
    return correctasAlPrimerIntento;
  }

  String _obtenerRango(int aciertos) {
    final pct = (aciertos / _cantidadCorridas) * 100;
    if (pct == 100) return "Experto en Control de Calidad (Precisión 100%)";
    if (pct >= 80) return "Controlador Operacional Senior";
    if (pct >= 60) return "Controlador de Terreno";
    return "Aprendiz de Sondajes";
  }

  Widget _buildCompactBadge(String label, String val, AppColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.grisTexto,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          val,
          style: TextStyle(
            color: colors.azulOscuro,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedExplanationCard(CorridaModel selected, AppColors colors) {
    final bool isJustificacionLocked = _selectedCorridaIndex > _unlockedIndex;

    if (isJustificacionLocked) {
      return Card(
        color: colors.superficie,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.bordeSuave, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.lock_outline, color: colors.grisTexto, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🔒 Justificación Bloqueada",
                      style: TextStyle(color: colors.rojo, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Completa y corrige las corridas anteriores primero para desbloquear las referencias y los datos del perforista de esta corrida.",
                      style: TextStyle(color: colors.azulOscuro, fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedCorridaIndex == _cantidadCorridas) {
      return Card(
        color: colors.superficie,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.bordeSuave, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cierre de Turno de Sondaje",
                style: TextStyle(color: colors.rojo, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                "Ingresa la contra final calculada en la última corrida (${_corridas.last.correctContra.toStringAsFixed(2)} m) en la celda de abajo para cerrar tu planilla.",
                style: TextStyle(color: colors.azulOscuro, fontSize: 12.5, height: 1.3),
              ),
            ],
          ),
        ),
      );
    }

    final prevContra = (_selectedCorridaIndex == 0)
        ? _contraInicial
        : _corridas[_selectedCorridaIndex - 1].correctContra;
    final prevFondo = (_selectedCorridaIndex == 0)
        ? _fondoInicial
        : _corridas[_selectedCorridaIndex - 1].correctFondo;

    final double contraAjustadaVal = _evaluarCondicionAdicion(prevContra, selected.perforado)
        ? (prevContra + selected.nuevoLargoBarra)
        : prevContra;

    return Card(
      color: colors.superficie,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.bordeSuave, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selected.esCambioBarril) ...[
              Text(
                "¡Alerta: Cambio de Barril!",
                style: TextStyle(color: colors.rojo, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                "El perforista informa cambio de barril. El nuevo mide ${selected.nuevoBarrilMedida.toStringAsFixed(2)} m. (Anterior: ${((_selectedCorridaIndex == 0) ? _barrilMedida : _corridas[_selectedCorridaIndex - 1].nuevoBarrilMedida).toStringAsFixed(2)} m).",
                style: TextStyle(color: colors.azulOscuro, fontSize: 12.5, height: 1.3),
              ),
            ] else if (selected.esCambioBarras) ...[
              Text(
                "¡Alerta: Cambio de Barras!",
                style: TextStyle(color: colors.rojo, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                "El perforista informa un cambio en el tipo de barras de la sarta. A partir de ahora las nuevas barras medirán ${selected.nuevoLargoBarra.toStringAsFixed(2)} m. (Anterior: ${((_selectedCorridaIndex == 0) ? _largoBarra : _corridas[_selectedCorridaIndex - 1].nuevoLargoBarra).toStringAsFixed(2)} m).",
                style: TextStyle(color: colors.azulOscuro, fontSize: 12.5, height: 1.3),
              ),
            ] else ...[
              InkWell(
                onTap: () {
                  setState(() {
                    _descVisible = !_descVisible;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Corrida Normal (Muestra disponible)",
                      style: TextStyle(color: colors.verde, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Row(
                      children: [
                        Text(
                          _descVisible ? "Ocultar datos" : "Ver datos del perforista",
                          style: TextStyle(color: colors.azul, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Icon(
                          _descVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: colors.azul,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_descVisible) ...[
                const SizedBox(height: 6),
                Text(
                  "Perforado: ${selected.perforado.toStringAsFixed(1)} m  |  Recuperado: ${selected.recuperado.toStringAsFixed(2)} m (${selected.pctRecuperacion.toStringAsFixed(1)}% Rec)",
                  style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  "Referencias (Fila anterior): Contra = ${prevContra.toStringAsFixed(2)} m  |  Fondo = ${prevFondo.toStringAsFixed(2)} m",
                  style: TextStyle(color: colors.grisTexto, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  "Contra Ajustada (a escribir en esta fila): ${contraAjustadaVal.toStringAsFixed(2)} m",
                  style: TextStyle(color: const Color(0xFFE11D48), fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
              ],
            ],
            const Divider(height: 10, thickness: 1),

            // Toggle help button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selected.respondidoCorrectamente ? "✓ Fila correcta" : "Cálculos pendientes o erróneos",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: selected.respondidoCorrectamente ? colors.verde : colors.grisTexto,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _explicacionVisible = !_explicacionVisible;
                      if (_explicacionVisible) {
                        _generarFeedbackExplicativo(_selectedCorridaIndex);
                      }
                    });
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                  icon: Icon(
                    _explicacionVisible ? Icons.help : Icons.help_outline,
                    size: 14,
                    color: colors.azul,
                  ),
                  label: Text(
                    _explicacionVisible ? "Ocultar explicación" : "Ver explicación",
                    style: TextStyle(color: colors.azul, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            if (_explicacionVisible && _feedbackExplicativo != null) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected.respondidoCorrectamente ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: selected.respondidoCorrectamente ? colors.verde : colors.bordeSuave),
                ),
                child: textWithLatex(
                  colors,
                  _feedbackExplicativo!,
                  style: TextStyle(
                    color: selected.respondidoCorrectamente ? const Color(0xFF065F46) : const Color(0xFF1E3A8A),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int get _unlockedIndex {
    for (int i = 0; i < _cantidadCorridas; i++) {
      if (!_corridas[i].respondidoCorrectamente) {
        return i;
      }
    }
    return _cantidadCorridas;
  }

  void _selectRow(int index) {
    setState(() {
      _selectedCorridaIndex = index;
      _activeKeyboardController = null;
      if (index < _cantidadCorridas) {
        _generarFeedbackExplicativo(index);
      }
    });
  }

  Widget _buildTableCellTextField({
    required TextEditingController controller,
    required TextInputType keyboardType,
    required bool? isCorrect,
    required AppColors colors,
    required int rowIndex,
  }) {
    Color cellColor = Colors.transparent;
    if (isCorrect == true) {
      cellColor = const Color(0xFFD1FAE5); // Light pastel green
    } else if (isCorrect == false) {
      cellColor = const Color(0xFFFEE2E2); // Light pastel red
    } else {
      cellColor = Colors.yellow.withValues(alpha: 0.12); // Yellow highlight for editing
    }

    return Container(
      height: 34 * _escalaFuente,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: TextField(
        controller: controller,
        readOnly: true,
        showCursor: true,
        textAlign: TextAlign.center,
        onTap: () {
          setState(() {
            _selectedCorridaIndex = rowIndex;
            _activeKeyboardController = controller;
            if (rowIndex < _cantidadCorridas) {
              _generarFeedbackExplicativo(rowIndex);
            }
          });
        },
        style: TextStyle(
          color: const Color(0xFF1F3A8A), // Always dark blue for paper look
          fontSize: 13 * _escalaFuente,
          fontWeight: FontWeight.bold,
          fontFamily: "Courier",
        ),
        decoration: InputDecoration(
          hintText: "?",
          hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6), fontSize: 13 * _escalaFuente),
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: cellColor,
          border: InputBorder.none,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: isCorrect != null
                  ? (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                  : Colors.black12,
              width: 1,
            ),
          ),
        ),
        onChanged: (_) {
          _saveExerciseState();
        },
      ),
    );
  }

  void _onKeyboardKeyPressed(String value) {
    if (_activeKeyboardController == null) return;
    final controller = _activeKeyboardController!;
    final text = controller.text;
    final selection = controller.selection;

    final start = selection.start;
    final end = selection.end;

    if (start >= 0 && end >= start) {
      final newText = text.replaceRange(start, end, value);
      controller.text = newText;
      controller.selection = TextSelection.collapsed(offset: start + value.length);
    } else {
      controller.text = text + value;
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }
    _saveExerciseState();
  }

  void _onKeyboardBackspace() {
    if (_activeKeyboardController == null) return;
    final controller = _activeKeyboardController!;
    final text = controller.text;
    final selection = controller.selection;

    final start = selection.start;
    final end = selection.end;

    if (start > 0 || end > start) {
      if (end > start) {
        final newText = text.replaceRange(start, end, "");
        controller.text = newText;
        controller.selection = TextSelection.collapsed(offset: start);
      } else {
        final newText = text.replaceRange(start - 1, start, "");
        controller.text = newText;
        controller.selection = TextSelection.collapsed(offset: start - 1);
      }
    }
    _saveExerciseState();
  }

  void _onKeyboardDone() {
    FocusScope.of(context).unfocus();
    setState(() {
      _activeKeyboardController = null;
    });
  }

  Widget _buildCustomNumericKeyboard(AppColors colors) {
    return TecladoCuaderno(
      colors: colors,
      onKeyPressed: _onKeyboardKeyPressed,
      onBackspacePressed: _onKeyboardBackspace,
      onDonePressed: _onKeyboardDone,
    );
  }

  Widget _buildSheetRow({
    required List<Widget> cells,
    required List<double> widths,
    Color? backgroundColor,
    bool isLastRow = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        border: Border(
          bottom: isLastRow
              ? BorderSide.none
              : const BorderSide(color: Color(0xFF60A5FA), width: 0.8),
        ),
      ),
      child: Row(
        children: List.generate(cells.length, (index) {
          final isLastCell = (index == cells.length - 1);
          return Container(
            width: widths[index],
            decoration: BoxDecoration(
              border: Border(
                right: isLastCell
                    ? BorderSide.none
                    : const BorderSide(color: Color(0xFF60A5FA), width: 0.8),
              ),
            ),
            child: cells[index],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // Mostrar spinner mientras se carga el estado desde SharedPreferences
    if (_loading) {
      return Scaffold(
        backgroundColor: colors.fondo,
        body: Center(
          child: CircularProgressIndicator(color: colors.azul),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerMenu(
        onNavigate: (route) {
          if (route != "ejercicios_cuaderno") {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, route);
          }
        },
        modoOscuro: colors.isDark,
        onToggleModoOscuro: () {},
      ),
      appBar: AppBar(
        title: const Text("Ejercicios del cuaderno"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          if (_pantalla == "corrida")
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: "Datos del Pozo",
              onPressed: () => _mostrarDatosPozoPopup(context),
            ),
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            tooltip: "Calculadora de Bolsillo",
            onPressed: () {
              setState(() {
                _showCalculator = !_showCalculator;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: "Volver al Panel",
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: _buildContenidoPantalla(colors),
            ),
          ),
          if (_showCalculator)
            Positioned(
              left: _calcPosition.dx,
              top: _calcPosition.dy,
              width: 250,
              child: CalculadoraBolsillo(
                onDrag: (delta) {
                  setState(() {
                    _calcPosition += delta;
                  });
                },
                onClose: () {
                  setState(() {
                    _showCalculator = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContenidoPantalla(AppColors colors) {
    if (_pantalla == "bienvenida") {
      return _buildPantallaBienvenida(colors);
    } else if (_pantalla == "corrida") {
      return _buildPantallaCorrida(colors);
    } else {
      return _buildPantallaResultado(colors);
    }
  }

  Widget _buildPantallaBienvenida(AppColors colors) {
    return CuadernoBienvenida(
      colors: colors,
      esModoManual: _esModoManual,
      onModoManualChanged: (val) {
        setState(() {
          _esModoManual = val;
          _generarNuevoPozo();
        });
      },
      manualPozoIdController: _manualPozoIdController,
      manualBarrasController: _manualBarrasController,
      manualPuntoMuertoController: _manualPuntoMuertoController,
      manualBarrilController: _manualBarrilController,
      nivelDificultad: _nivelDificultad,
      onDificultadChanged: (val) {
        setState(() {
          _nivelDificultad = val ? "Intermedio" : "Básico";
          _generarNuevoPozo();
        });
      },
      cantidadCorridas: _cantidadCorridas,
      onCantidadCorridasChanged: (val) {
        if (val != null) {
          setState(() {
            _cantidadCorridas = val;
            _generarNuevoPozo();
          });
        }
      },
      iniciarConBarras300: _iniciarConBarras300,
      onIniciarConBarras300Changed: (val) {
        setState(() {
          _iniciarConBarras300 = val;
          _generarNuevoPozo();
        });
      },
      usarExtensionReflex: _usarExtensionReflex,
      onUsarExtensionReflexChanged: (val) {
        setState(() {
          _usarExtensionReflex = val;
          _generarNuevoPozo();
        });
      },
      permitirCambioBarril: _permitirCambioBarril,
      onPermitirCambioBarrilChanged: (val) {
        setState(() {
          _permitirCambioBarril = val;
          _generarNuevoPozo();
        });
      },
      direccionCambioBarril: _direccionCambioBarril,
      onDireccionCambioBarrilChanged: (val) {
        if (val != null) {
          setState(() {
            _direccionCambioBarril = val;
            _generarNuevoPozo();
          });
        }
      },
      manualFilaCambioBarril: _manualFilaCambioBarril,
      onManualFilaCambioBarrilChanged: (val) {
        if (val != null) {
          setState(() {
            _manualFilaCambioBarril = val;
            _generarNuevoPozo();
          });
        }
      },
      permitirCambioSarta: _permitirCambioSarta,
      onPermitirCambioSartaChanged: (val) {
        setState(() {
          _permitirCambioSarta = val;
          _generarNuevoPozo();
        });
      },
      pozoId: _pozoId,
      fondoInicial: _fondoInicial,
      contraInicial: _contraInicial,
      barrasIniciales: _barrasIniciales,
      largoBarra: _largoBarra,
      puntoMuerto: _puntoMuerto,
      barrilMedida: _barrilMedida,
      esOrientado: _esOrientado,
      herramientaTotal: _herramientaTotal,
      onComenzar: _iniciarEjercicio,
    );
  }

  Widget _buildPantallaCorrida(AppColors colors) {
    final selected = _selectedCorridaIndex == _cantidadCorridas ? _corridas.last : _corridas[_selectedCorridaIndex];

    return Column(
      children: [
        // Top info ribbon
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colors.superficie,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.bordeSuave),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              _buildCompactBadge("Pozo:", _pozoId, colors),
              _buildCompactBadge("F. Ini:", "${_fondoInicial.toStringAsFixed(2)}m", colors),
              _buildCompactBadge("C. Ini:", "${_contraInicial.toStringAsFixed(2)}m", colors),
              _buildCompactBadge("Cant de barras:", "$_barrasIniciales", colors),
              _buildCompactBadge("PM:", "${_puntoMuerto.toStringAsFixed(2)}m", colors),
              _buildCompactBadge("Barril:", "${_barrilMedida.toStringAsFixed(2)}m (${_barrilMedida == 2.60 ? 'Corto' : 'Largo'})", colors),
              _buildCompactBadge("Orient:", _esOrientado ? "Sí (+0.40m)" : "No", colors),
            ],
          ),
        ),

        // Quick status card (Current selected row for help/reference)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: colors.azul.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.azul.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fila seleccionada: ${_selectedCorridaIndex == _cantidadCorridas ? 'Cierre de Turno' : 'Corrida ${selected.index}'}",
                style: TextStyle(fontWeight: FontWeight.bold, color: colors.azul, fontSize: 13),
              ),
              Text(
                _selectedCorridaIndex == _cantidadCorridas 
                    ? "CIERRE" 
                    : (selected.esCambioBarril 
                        ? "CAMBIO DE BARRIL" 
                        : (selected.esCambioBarras ? "CAMBIO DE BARRAS" : "Corrida Normal")),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: (_selectedCorridaIndex == _cantidadCorridas || selected.esCambioBarril || selected.esCambioBarras) ? colors.rojo : colors.verde,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Active Card Description with Dynamic Explanation Option
        _buildSelectedExplanationCard(selected, colors),
        const SizedBox(height: 8),

        // Lined Notebook Table wrapped in InteractiveViewer
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Planilla de Terreno (Toca una fila para seleccionarla):",
                    style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    "Puntaje obtenido: ${_calcularPuntajeFinal()} / $_cantidadCorridas",
                    style: TextStyle(color: colors.grisTexto, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildNotebookSection(colors),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        if (_activeKeyboardController != null) ...[
          _buildCustomNumericKeyboard(colors),
          const SizedBox(height: 10),
        ],

        // Bottom Action buttons
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: _mostrarConfirmacionFinalizar,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.naranjo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text("Finalizar Ejercicio 🏆", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: _mostrarConfirmacionLimpiar,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.bordeSuave, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Limpiar cuaderno",
                    style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotebookSection(AppColors colors) {
    final double colWidth = 72 * _escalaFuente;
    final double tableWidth = 9 * colWidth;

    return Stack(
      children: [
        Container(
          width: tableWidth + 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF0), // Always classic cream paper background
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFC7A75C), width: 2), // Golden leather edge
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            painter: const _CuadernoGridPainter(),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Lined paper margin line
                  Container(
                    width: 2,
                    color: Colors.redAccent.withValues(alpha: 0.7),
                    margin: const EdgeInsets.only(left: 12, right: 8),
                  ),

                  // Notebook Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "REGISTRO OPERACIONAL - POZO: $_pozoId",
                            style: TextStyle(
                              color: const Color(0xFF1F3A8A), // Always dark blue
                              fontWeight: FontWeight.bold,
                              fontSize: 14 * _escalaFuente,
                              fontFamily: "Courier",
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Iniciales: PM: ${_puntoMuerto.toStringAsFixed(2)}m | Contra: ${_contraInicial.toStringAsFixed(2)}m | Fondo: ${_fondoInicial.toStringAsFixed(2)}m",
                            style: TextStyle(
                              color: const Color(0xFF2563EB), // Always electric blue
                              fontSize: 12 * _escalaFuente,
                              fontFamily: "Courier",
                            ),
                          ),
                          const Divider(color: Color(0xFF93C5FD), thickness: 1, height: 12),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: tableWidth,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF60A5FA), width: 0.8),
                                ),
                                child: Column(
                                  children: [
                                    // 1. Table Header
                                    _buildSheetRow(
                                      backgroundColor: const Color(0xFFEFF6FF),
                                      widths: List.generate(9, (_) => colWidth),
                                      cells: ["Desde", "Hasta", "Perf.", "Rec.", "% Rec", "Barras", "Herr.", "Contra", "Orient"]
                                          .map((header) => Padding(
                                                padding: const EdgeInsets.all(3.0),
                                                child: Text(
                                                  header,
                                                  style: TextStyle(
                                                      color: const Color(0xFF1E3A8A),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11 * _escalaFuente,
                                                      fontFamily: "Courier"),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ))
                                          .toList(),
                                    ),

                                    // 2. Setup Initial Row (Row -1)
                                    _buildSheetRow(
                                      backgroundColor: _selectedCorridaIndex == -1 ? const Color(0xFFEFF6FF) : Colors.transparent,
                                      widths: List.generate(9, (_) => colWidth),
                                      cells: [
                                        "-",
                                        _fondoInicial.toStringAsFixed(2),
                                        "0.0",
                                        "0.0",
                                        "0.0%",
                                        "$_barrasIniciales",
                                        _herramientaTotal.toStringAsFixed(2),
                                        _contraInicial.toStringAsFixed(2),
                                        _esOrientado ? "Sí" : "No"
                                      ]
                                          .map((cell) => InkWell(
                                                onTap: () => _selectRow(-1),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                                  child: Text(
                                                    cell,
                                                    style: TextStyle(
                                                        color: const Color(0xFF1E3A8A),
                                                        fontSize: 11.5 * _escalaFuente,
                                                        fontFamily: "Courier"),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),

                                    // 3. Normal Run Rows (Rows 1 to N)
                                    ...List.generate(_cantidadCorridas, (idx) {
                                      final item = _corridas[idx];
                                      final isCambio = item.esCambioBarril || item.esCambioBarras;
                                      final prevFondoStr = idx == 0
                                          ? _fondoInicial.toStringAsFixed(2)
                                          : _corridas[idx - 1].correctFondo.toStringAsFixed(2);

                                      final isSelectedRow = (_selectedCorridaIndex == idx);

                                      final Widget contraCell = (idx == 0)
                                          ? (_corridas[0].perforado > _contraInicial
                                              ? _buildTableCellTextField(
                                                  controller: _contraControllers[0],
                                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                  isCorrect: _corridas[0].isContraInicialCorrect,
                                                  colors: colors,
                                                  rowIndex: 0,
                                                )
                                              : InkWell(
                                                  onTap: () => _selectRow(0),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                    child: Text(
                                                      _contraInicial.toStringAsFixed(2),
                                                      style: TextStyle(
                                                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.8),
                                                          fontSize: 11.5 * _escalaFuente,
                                                          fontFamily: "Courier"),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ))
                                          : _buildTableCellTextField(
                                              controller: _contraControllers[idx],
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              isCorrect: _corridas[idx].isContraCorrect,
                                              colors: colors,
                                              rowIndex: idx,
                                            );

                                      if (isCambio) {
                                        // Merged layout for first 5 columns: Desde, Hasta, Perf., Rec., % Rec
                                        return _buildSheetRow(
                                          backgroundColor: isSelectedRow
                                              ? const Color(0xFFEFF6FF).withValues(alpha: 0.6)
                                              : Colors.transparent,
                                          widths: [colWidth * 5, colWidth, colWidth, colWidth, colWidth],
                                          cells: [
                                            // Merged cell spanning 5 columns
                                            InkWell(
                                              onTap: () => _selectRow(idx),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  item.esCambioBarril ? "CAMBIO DE BARRIL" : "CAMBIO DE BARRAS",
                                                  style: TextStyle(
                                                    color: const Color(0xFFE11D48),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11 * _escalaFuente,
                                                    fontFamily: "Courier",
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Barras (Column 6)
                                            _buildTableCellTextField(
                                              controller: _barrasControllers[idx],
                                              keyboardType: TextInputType.number,
                                              isCorrect: item.isBarrasCorrect,
                                              colors: colors,
                                              rowIndex: idx,
                                            ),
                                            // Herr. (Column 7)
                                            _buildTableCellTextField(
                                              controller: _herrControllers[idx],
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              isCorrect: item.isHerrCorrect,
                                              colors: colors,
                                              rowIndex: idx,
                                            ),
                                            // Contra (Column 8)
                                            contraCell,
                                            // Orient (Column 9) - Show "-" as requested
                                            InkWell(
                                              onTap: () => _selectRow(idx),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                child: Text(
                                                  "-",
                                                  style: TextStyle(
                                                      color: const Color(0xFF1E3A8A),
                                                      fontSize: 11.5 * _escalaFuente,
                                                      fontFamily: "Courier"),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        // Normal Row Layout
                                        final Widget perfCell = _esModoManual
                                            ? _buildTableCellTextField(
                                                controller: _perfControllers[idx],
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                isCorrect: null,
                                                colors: colors,
                                                rowIndex: idx,
                                              )
                                            : InkWell(
                                                onTap: () => _selectRow(idx),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                  child: Text(
                                                    item.perforado.toStringAsFixed(1),
                                                    style: TextStyle(
                                                        color: const Color(0xFF1E3A8A),
                                                        fontSize: 11.5 * _escalaFuente,
                                                        fontFamily: "Courier"),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              );

                                        final Widget recCell = _esModoManual
                                            ? _buildTableCellTextField(
                                                controller: _recControllers[idx],
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                isCorrect: null,
                                                colors: colors,
                                                rowIndex: idx,
                                              )
                                            : InkWell(
                                                onTap: () => _selectRow(idx),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                  child: Text(
                                                    item.recuperado.toStringAsFixed(2),
                                                    style: TextStyle(
                                                        color: const Color(0xFF1E3A8A),
                                                        fontSize: 11.5 * _escalaFuente,
                                                        fontFamily: "Courier"),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              );

                                        return _buildSheetRow(
                                          backgroundColor: isSelectedRow
                                              ? const Color(0xFFEFF6FF).withValues(alpha: 0.6)
                                              : Colors.transparent,
                                          widths: List.generate(9, (_) => colWidth),
                                          cells: [
                                            // Desde
                                            (idx == 0)
                                                ? InkWell(
                                                    onTap: () => _selectRow(0),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                                      child: Text(
                                                        prevFondoStr,
                                                        style: TextStyle(
                                                            color: const Color(0xFF1E3A8A),
                                                            fontSize: 11.5 * _escalaFuente,
                                                            fontFamily: "Courier"),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  )
                                                : _buildTableCellTextField(
                                                    controller: _desdeControllers[idx - 1],
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    isCorrect: item.isDesdeCorrect,
                                                    colors: colors,
                                                    rowIndex: idx,
                                                  ),
                                            // Hasta
                                            _buildTableCellTextField(
                                              controller: _fondoControllers[idx],
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              isCorrect: item.isFondoCorrect,
                                              colors: colors,
                                              rowIndex: idx,
                                            ),
                                            // Perf
                                            perfCell,
                                            // Rec
                                            recCell,
                                            // % Rec
                                            InkWell(
                                              onTap: () => _selectRow(idx),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                child: Text(
                                                  "${item.pctRecuperacion.toStringAsFixed(1)}%",
                                                  style: TextStyle(
                                                      color: const Color(0xFF1E3A8A),
                                                      fontSize: 11.5 * _escalaFuente,
                                                      fontFamily: "Courier"),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            // Barras
                                            _buildTableCellTextField(
                                              controller: _barrasControllers[idx],
                                              keyboardType: TextInputType.number,
                                              isCorrect: item.isBarrasCorrect,
                                              colors: colors,
                                              rowIndex: idx,
                                            ),
                                            // Herr.
                                            _buildTableCellTextField(
                                              controller: _herrControllers[idx],
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              isCorrect: item.isHerrCorrect,
                                              colors: colors,
                                              rowIndex: idx,
                                            ),
                                            // Contra
                                            contraCell,
                                            // Orient
                                            InkWell(
                                              onTap: () => _selectRow(idx),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                child: Text(
                                                  _esOrientado ? "Sí" : "No",
                                                  style: TextStyle(
                                                      color: const Color(0xFF1E3A8A),
                                                      fontSize: 11.5 * _escalaFuente,
                                                      fontFamily: "Courier"),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    }),

                                    // 4. Final Closing Row (Row N + 1)
                                    _buildSheetRow(
                                      isLastRow: true,
                                      backgroundColor: (_selectedCorridaIndex == _cantidadCorridas)
                                          ? const Color(0xFFEFF6FF).withValues(alpha: 0.6)
                                          : Colors.transparent,
                                      widths: List.generate(9, (_) => colWidth),
                                      cells: [
                                        // Desde
                                        InkWell(
                                          onTap: () => _selectRow(_cantidadCorridas),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Text(
                                              _corridas.last.correctFondo.toStringAsFixed(2),
                                              style: TextStyle(
                                                  color: const Color(0xFF1E3A8A),
                                                  fontSize: 11.5 * _escalaFuente,
                                                  fontFamily: "Courier"),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // Hasta
                                        InkWell(
                                          onTap: () => _selectRow(_cantidadCorridas),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Text(
                                              _corridas.last.correctFondo.toStringAsFixed(2),
                                              style: TextStyle(
                                                  color: const Color(0xFF1E3A8A),
                                                  fontSize: 11.5 * _escalaFuente,
                                                  fontFamily: "Courier"),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // Perf
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          child: Text("-", style: TextStyle(color: Color(0xFF1E3A8A), fontFamily: "Courier"), textAlign: TextAlign.center),
                                        ),
                                        // Rec
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          child: Text("-", style: TextStyle(color: Color(0xFF1E3A8A), fontFamily: "Courier"), textAlign: TextAlign.center),
                                        ),
                                        // % Rec
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          child: Text("-", style: TextStyle(color: Color(0xFF1E3A8A), fontFamily: "Courier"), textAlign: TextAlign.center),
                                        ),
                                        // Barras
                                        InkWell(
                                          onTap: () => _selectRow(_cantidadCorridas),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Text(
                                              _corridas.last.correctBarras.toString(),
                                              style: TextStyle(
                                                  color: const Color(0xFF1E3A8A),
                                                  fontSize: 11.5 * _escalaFuente,
                                                  fontFamily: "Courier"),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // Herr
                                        InkWell(
                                          onTap: () => _selectRow(_cantidadCorridas),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Text(
                                              _corridas.last.correctHerramienta.toStringAsFixed(2),
                                              style: TextStyle(
                                                  color: const Color(0xFF1E3A8A),
                                                  fontSize: 11.5 * _escalaFuente,
                                                  fontFamily: "Courier"),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // Contra
                                        _buildTableCellTextField(
                                          controller: _contraControllers[_cantidadCorridas],
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          isCorrect: _corridas.last.isContraCorrect,
                                          colors: colors,
                                          rowIndex: _cantidadCorridas,
                                        ),
                                        // Orient (Static)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          child: Text(
                                            "FINAL",
                                            style: TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                                fontFamily: "Courier"),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Floating Scale Control Buttons (+ / -)
        Positioned(
          right: 12,
          top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: _escalaFuente <= 0.8
                        ? null
                        : () {
                            setState(() {
                              _escalaFuente = double.parse((_escalaFuente - 0.1).toStringAsFixed(1));
                            });
                          },
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.remove,
                        size: 14,
                        color: _escalaFuente <= 0.8 ? Colors.grey.shade400 : const Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    "${(_escalaFuente * 100).round()}%",
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: _escalaFuente >= 1.6
                        ? null
                        : () {
                            setState(() {
                              _escalaFuente = double.parse((_escalaFuente + 0.1).toStringAsFixed(1));
                            });
                          },
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add,
                        size: 14,
                        color: _escalaFuente >= 1.6 ? Colors.grey.shade400 : const Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _generarReporteTexto() {
    final buffer = StringBuffer();
    buffer.writeln("=== REPORTABILIDAD DE TURNO (PLANILLA SIMULADA) ===");
    buffer.writeln("Identificador del Pozo: $_pozoId");
    buffer.writeln("Fondo Inicial: ${_fondoInicial.toStringAsFixed(2)} m");
    buffer.writeln("Contra Inicial: ${_contraInicial.toStringAsFixed(2)} m");
    buffer.writeln("Total Herramientas Inicial: ${_herramientaTotal.toStringAsFixed(2)} m");
    buffer.writeln("--------------------------------------------------");
    buffer.writeln("Corrida\tDesde\tHasta\tPerf.\tRec.\t% Rec\tBarras\tHerr.\tContra");
    for (int i = 0; i < _corridas.length; i++) {
      final item = _corridas[i];
      final prevFondo = i == 0 ? _fondoInicial : _corridas[i - 1].correctFondo;
      buffer.writeln(
        "${i + 1}\t"
        "${prevFondo.toStringAsFixed(2)}\t"
        "${item.correctFondo.toStringAsFixed(2)}\t"
        "${item.perforado.toStringAsFixed(1)}\t"
        "${item.recuperado.toStringAsFixed(2)}\t"
        "${item.pctRecuperacion.toStringAsFixed(1)}%\t"
        "${item.correctBarras}\t"
        "${item.correctHerramienta.toStringAsFixed(2)}\t"
        "${item.correctContra.toStringAsFixed(2)}"
      );
    }
    buffer.writeln("--------------------------------------------------");
    buffer.writeln("Rango del operador: ${_obtenerRango(_calcularPuntajeFinal())}");
    buffer.writeln("Generado automáticamente por Aprender a Controlar.");
    return buffer.toString();
  }

  Widget _buildPantallaResultado(AppColors colors) {
    final aciertos = _calcularPuntajeFinal();
    final rango = _obtenerRango(aciertos);
    final report = _generarReporteTexto();
    return CuadernoResultados(
      colors: colors,
      aciertos: aciertos,
      cantidadCorridas: _cantidadCorridas,
      totalVerificaciones: _totalVerificaciones,
      rango: rango,
      reportText: report,
      onRetry: () {
        setState(() {
          _generarNuevoPozo();
          _pantalla = "corrida";
        });
      },
    );
  }
}

class _CuadernoGridPainter extends CustomPainter {
  const _CuadernoGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final minorPaint = Paint()
      ..color = const Color(0xFFBFDBFE).withValues(alpha: 0.4)
      ..strokeWidth = 0.5;
    final majorPaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.55)
      ..strokeWidth = 0.8;

    const step = 16.0;
    for (double x = 0; x <= size.width; x += step) {
      final paint = (x / step).round() % 5 == 0 ? majorPaint : minorPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      final paint = (y / step).round() % 5 == 0 ? majorPaint : minorPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CuadernoGridPainter oldDelegate) => false;
}
