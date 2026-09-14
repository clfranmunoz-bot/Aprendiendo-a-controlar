import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';

class CamaraScreen extends StatefulWidget {
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;
  final Function(String) onNavigate;

  const CamaraScreen({
    super.key,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
    required this.onNavigate,
  });

  @override
  State<CamaraScreen> createState() => _CamaraScreenState();
}

class _CamaraScreenState extends State<CamaraScreen> {
  static const _galleryChannel = MethodChannel('aprender_a_controlar/gallery');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isSimulated = false;
  bool _tomandoFoto = false;
  XFile? _fotoCapturada;

  // Checklist items
  bool _nombrePozo = false;
  bool _inicioFinMetraje = false;
  bool _tacosBloqueo = false;
  bool _tacosRegularizado = false;
  bool _numBandeja = false;

  // Simulated tray variables (for custom interactive web/macOS mockup)
  String _simPozo = "DDH-204A";
  int _simBandeja = 42;
  double _simDesde = 122.00;
  double _simHasta = 125.40;

  bool get _todoListo =>
      _nombrePozo &&
      _inicioFinMetraje &&
      _tacosBloqueo &&
      _tacosRegularizado &&
      _numBandeja;

  @override
  void initState() {
    super.initState();
    _inicializarCamara();
  }

  Future<void> _inicializarCamara() async {
    // If not mobile, force simulation
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      if (!mounted) return;
      setState(() {
        _isSimulated = true;
        _isInitialized = true;
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isSimulated = true;
          _isInitialized = true;
        });
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isSimulated = false;
        });
      }
    } catch (e) {
      debugPrint("Error al inicializar cámara real: $e");
      if (mounted) {
        setState(() {
          _isSimulated = true;
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturarFoto() async {
    if (!_todoListo || _tomandoFoto) return;

    setState(() {
      _tomandoFoto = true;
    });

    // Simulated camera flash effect
    await Future.delayed(const Duration(milliseconds: 300));

    if (_isSimulated) {
      // Create a fake captured file representation (just dummy success)
      setState(() {
        _tomandoFoto = false;
        // In simulation, we just assign a fake XFile
        _fotoCapturada = XFile(""); 
      });
    } else {
      try {
        final image = await _controller!.takePicture();
        setState(() {
          _tomandoFoto = false;
          _fotoCapturada = image;
        });
      } catch (e) {
        debugPrint("Error capturando foto real: $e");
        setState(() {
          _tomandoFoto = false;
          // Fallback to fake photo preview
          _fotoCapturada = XFile("");
        });
      }
    }
  }

  void _reiniciarCamara() {
    setState(() {
      _fotoCapturada = null;
      _nombrePozo = false;
      _inicioFinMetraje = false;
      _tacosBloqueo = false;
      _tacosRegularizado = false;
      _numBandeja = false;
    });
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              color == Colors.red 
                  ? Icons.error_outline 
                  : color == Colors.blue 
                      ? Icons.hourglass_empty
                      : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarFotoEnGaleria() async {
    if (_fotoCapturada == null || _fotoCapturada!.path.isEmpty) return;

    if (_isSimulated) {
      _mostrarSnackBar("Simulación: Foto archivada en historial.", Colors.green);
      _reiniciarCamara();
      return;
    }

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        _mostrarSnackBar("Guardando foto en galería...", Colors.blue);
        final bool? result = await _galleryChannel.invokeMethod<bool>(
          'saveImage',
          {'path': _fotoCapturada!.path},
        );
        if (result == true) {
          _mostrarSnackBar("Foto guardada en galería exitosamente.", Colors.green);
        } else {
          _mostrarSnackBar("Error al guardar la foto en la galería.", Colors.red);
        }
      } else {
        _mostrarSnackBar("Foto archivada exitosamente.", Colors.green);
      }
    } catch (e) {
      debugPrint("Error guardando foto en galería: $e");
      _mostrarSnackBar("Error: No se pudo guardar en la galería.", Colors.red);
    }
    _reiniciarCamara();
  }

  void _randomizarSimulacion() {
    setState(() {
      final pozos = ["DDH-102", "DDH-204A", "DDH-89B", "RC-450", "DDH-300"];
      _simPozo = (pozos..shuffle()).first;
      _simBandeja = (20 + (80 * (DateTime.now().millisecond / 1000))).toInt();
      _simDesde = double.parse((100.0 + _simBandeja * 3.0).toStringAsFixed(2));
      _simHasta = double.parse((_simDesde + 3.0 + (DateTime.now().microsecond % 10) / 10).toStringAsFixed(2));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerMenu(
        onNavigate: widget.onNavigate,
        modoOscuro: widget.modoOscuro,
        onToggleModoOscuro: widget.onToggleModoOscuro,
      ),
      appBar: AppBar(
        title: const Text("Cámara de Inspección"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: "Volver al Inicio",
            onPressed: () => widget.onNavigate('home'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _mostrarAyudaCamara(context),
          )
        ],
      ),
      body: Column(
        children: [
          // Banner descriptivo superior
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: colors.azulClaro,
            child: Row(
              children: [
                Icon(Icons.camera_alt, color: colors.azul, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Inspecciona la bandeja de sondajes y verifica el estándar antes de archivar la foto de terreno.",
                    style: TextStyle(
                      color: colors.azul,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Área del Viewfinder / Previsualización
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.bordeSuave, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_fotoCapturada != null)
                    _buildPreviewFoto(context)
                  else if (!_isInitialized)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else if (_isSimulated)
                    _buildSimulatedViewfinder(context)
                  else
                    _buildNativeViewfinder(context),

                  // Flash Screen Overlay
                  if (_tomandoFoto)
                    AnimatedOpacity(
                      opacity: _tomandoFoto ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(color: Colors.white),
                    ),

                  // Floating Checklist Panel (Only if not showing captured preview)
                  if (_fotoCapturada == null)
                    Positioned(
                      left: 12,
                      top: 12,
                      right: 12,
                      child: _buildFloatingChecklist(context),
                    ),
                ],
              ),
            ),
          ),

          // Barra inferior de controles
          if (_fotoCapturada == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Row(
                children: [
                  if (_isSimulated)
                    IconButton(
                      icon: Icon(Icons.cached_rounded, color: colors.azul, size: 28),
                      tooltip: "Simular otra bandeja",
                      onPressed: _randomizarSimulacion,
                    )
                  else
                    const SizedBox(width: 48),
                  
                  const Spacer(),
                  
                  // Capture Button
                  GestureDetector(
                    onTap: _todoListo ? _capturarFoto : null,
                    child: Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _todoListo ? colors.rojo : colors.grisSecundario.withValues(alpha: 0.3),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: _todoListo ? [
                          BoxShadow(
                            color: colors.rojo.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ] : [],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.camera,
                          color: _todoListo ? Colors.white : Colors.white60,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Indicators status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _todoListo ? colors.verdeClaro : colors.naranjoClaro,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _todoListo ? "Listo" : "Bloqueado",
                      style: TextStyle(
                        color: _todoListo ? colors.verde : colors.naranjo,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: colors.azul),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Tomar otra"),
                      onPressed: _reiniciarCamara,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.verde,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.save_alt),
                      label: const Text("Archivar foto"),
                      onPressed: _guardarFotoEnGaleria,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Floating translucent glass card for requirements checklist
  Widget _buildFloatingChecklist(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.superficie.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.bordeSuave.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          "Requisitos de Rotulación (${[_nombrePozo, _inicioFinMetraje, _tacosBloqueo, _tacosRegularizado, _numBandeja].where((e) => e).length}/5)",
          style: TextStyle(
            color: colors.azulOscuro,
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _todoListo ? "¡Todo verificado! Shutter desbloqueado." : "Verifica y marca todos los puntos para fotografiar.",
          style: TextStyle(
            color: _todoListo ? colors.verde : colors.grisTexto,
            fontSize: 11,
          ),
        ),
        leading: Icon(
          _todoListo ? Icons.check_circle : Icons.warning_amber_rounded,
          color: _todoListo ? colors.verde : colors.naranjo,
          size: 20,
        ),
        initiallyExpanded: true,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        children: [
          _buildCheckItem(
            "Nombre del Pozo visible y correcto",
            _nombrePozo,
            (val) => setState(() => _nombrePozo = val ?? false),
          ),
          _buildCheckItem(
            "Inicio y Fin del Metraje rotulado",
            _inicioFinMetraje,
            (val) => setState(() => _inicioFinMetraje = val ?? false),
          ),
          _buildCheckItem(
            "Tacos de Bloqueo posicionados físicamente",
            _tacosBloqueo,
            (val) => setState(() => _tacosBloqueo = val ?? false),
          ),
          _buildCheckItem(
            "Tacos de Regularizado instalados",
            _tacosRegularizado,
            (val) => setState(() => _tacosRegularizado = val ?? false),
          ),
          _buildCheckItem(
            "Número de Bandeja visible (ej. N° 42)",
            _numBandeja,
            (val) => setState(() => _numBandeja = val ?? false),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text, bool value, ValueChanged<bool?> onChanged) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              activeColor: colors.verde,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.azulOscuro,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Real native camera viewfinder widget
  Widget _buildNativeViewfinder(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: Text("Error al iniciar cámara"));
    }

    return CameraPreview(_controller!);
  }

  // High-fidelity interactive simulated mockup of a core tray
  Widget _buildSimulatedViewfinder(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E2C),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Wood texture background/frame for core tray
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723), // Wood brown
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2D1510), width: 6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              ),
            ),
          ),

          // 2. Tray inner slots with rock cores
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(26.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Head board label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "POZO: $_simPozo",
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Courier",
                          ),
                        ),
                        Text(
                          "BANDEJA: $_simBandeja",
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Courier",
                          ),
                        ),
                        Text(
                          "${_simDesde.toStringAsFixed(2)}m - ${_simHasta.toStringAsFixed(2)}m",
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Courier",
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Slot 1 (Core Tube 1)
                  _buildSimulatedSlot(
                    metroIni: _simDesde,
                    metroFin: _simDesde + 1.20,
                    tacos: ["TACO BLOQUEO\n${_simDesde + 0.80}m"],
                    colorRoca: const Color(0xFF78909C), // Slate grey
                  ),

                  // Slot 2 (Core Tube 2)
                  _buildSimulatedSlot(
                    metroIni: _simDesde + 1.20,
                    metroFin: _simDesde + 2.30,
                    tacos: ["REGULARIZADO\n${_simDesde + 2.00}m"],
                    colorRoca: const Color(0xFF90A4AE),
                  ),

                  // Slot 3 (Core Tube 3)
                  _buildSimulatedSlot(
                    metroIni: _simDesde + 2.30,
                    metroFin: _simHasta,
                    tacos: [],
                    colorRoca: const Color(0xFF607D8B),
                  ),
                ],
              ),
            ),
          ),

          // Watermarks/guides for scanning
          Positioned(
            left: 30,
            top: 100,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.cyan, width: 3),
                  top: BorderSide(color: Colors.cyan, width: 3),
                ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 100,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.cyan, width: 3),
                  top: BorderSide(color: Colors.cyan, width: 3),
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 40,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.cyan, width: 3),
                  bottom: BorderSide(color: Colors.cyan, width: 3),
                ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: 40,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.cyan, width: 3),
                  bottom: BorderSide(color: Colors.cyan, width: 3),
                ),
              ),
            ),
          ),

          // Central alignment line
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.cyan.withValues(alpha: 0.3),
          ),

          // Overlay simulating a reflection/hologram
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.white.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Simulated camera badge
          Positioned(
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.cyan.withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.computer, color: Colors.cyan, size: 14),
                  SizedBox(width: 6),
                  Text(
                    "SIMULADOR MAC/WEB V1.0",
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a wooden row with a stone core drill
  Widget _buildSimulatedSlot({
    required double metroIni,
    required double metroFin,
    required List<String> tacos,
    required Color colorRoca,
  }) {
    return Container(
      height: 64,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B0E0B), // Black slot space
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF351B15), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Rock Core cylinders
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorRoca,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        gradient: LinearGradient(
                          colors: [
                            colorRoca.withValues(alpha: 0.8),
                            colorRoca,
                            colorRoca.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorRoca,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                        gradient: LinearGradient(
                          colors: [
                            colorRoca.withValues(alpha: 0.8),
                            colorRoca,
                            colorRoca.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Splitting run blocks / Tacos
          if (tacos.isNotEmpty)
            Positioned(
              left: 100,
              top: 2,
              bottom: 2,
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  border: Border.all(color: Colors.white54, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ]
                ),
                child: Center(
                  child: Text(
                    tacos.first,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7.5,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),

          // 3. Grid markings (Run lengths)
          Positioned(
            left: 8,
            child: Text(
              "${metroIni.toStringAsFixed(2)}m",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: "Courier",
              ),
            ),
          ),
          Positioned(
            right: 8,
            child: Text(
              "${metroFin.toStringAsFixed(2)}m",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: "Courier",
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Previsualización de la foto capturada en un cuadro premium
  Widget _buildPreviewFoto(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      color: colors.superficie,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simulated flash screen result or camera actual preview
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isSimulated)
                  // Render the tray as frozen picture
                  _buildSimulatedViewfinder(context)
                else if (kIsWeb)
                  const Center(child: Icon(Icons.photo, size: 80, color: Colors.cyan))
                else
                  Image.file(
                    File(_fotoCapturada!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                
                // Holographic scanned overlay on top of result
                Positioned(
                  left: 20,
                  right: 20,
                  top: 80,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.verde.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8),
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "INSPECCIÓN APROBADA",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "• Pozo: ${_isSimulated ? _simPozo : "DDH-CONFIRMADO"}\n"
                          "• Metraje: ${_isSimulated ? "${_simDesde.toStringAsFixed(2)}m - ${_simHasta.toStringAsFixed(2)}m" : "Tramo validado"}\n"
                          "• Elementos físicos: 100% legibles y ordenados\n"
                          "• Bandeja N°: ${_isSimulated ? _simBandeja : "Ok"}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarAyudaCamara(BuildContext context) {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.superficie,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.photo_library, color: colors.azul),
              const SizedBox(width: 10),
              Text(
                "Estándar Geológico",
                style: TextStyle(color: colors.azulOscuro),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAyudaParrafo(
                  "1. Legibilidad de Letra:",
                  "El nombre del pozo y los metros deben estar escritos con marcador indeleble negro de trazo grueso.",
                ),
                _buildAyudaParrafo(
                  "2. Orientación:",
                  "Fotografía siempre con orientación horizontal. Asegúrate de encuadrar de forma recta la bandeja, evitando sombras directas.",
                ),
                _buildAyudaParrafo(
                  "3. Bloques de testigo:",
                  "Los bloques de fin de corrida o tacos de bloqueo deben mostrar los metros legibles mirando hacia el inicio (izq.).",
                ),
                _buildAyudaParrafo(
                  "4. Tacos de Regularizado:",
                  "Todo tramo regularizado debe contar con su correspondiente taco identificador, en la posición exacta del corte.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Entendido",
                style: TextStyle(color: colors.azul, fontWeight: FontWeight.bold),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildAyudaParrafo(String title, String desc) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.azulOscuro,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            desc,
            style: TextStyle(
              color: colors.grisTexto,
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
