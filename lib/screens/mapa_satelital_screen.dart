import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aprender_a_controlar/models/mapa_punto.dart';
import 'package:aprender_a_controlar/models/faena_mapa.dart';
import 'package:aprender_a_controlar/services/utm_converter.dart';
import 'package:aprender_a_controlar/services/mapa_service.dart';
import 'package:aprender_a_controlar/widgets/mapa/mapa_canvas_painter.dart';
import 'package:aprender_a_controlar/widgets/mapa/mapa_nuevo_punto_dialog.dart';
import 'package:aprender_a_controlar/widgets/mapa/mapa_punto_detalle_sheet.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/app_routes.dart';

class MapaSatelitalScreen extends StatefulWidget {
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;
  final Function(String)? onNavigate;

  const MapaSatelitalScreen({
    super.key,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
    this.onNavigate,
  });

  @override
  State<MapaSatelitalScreen> createState() => _MapaSatelitalScreenState();
}

class _MapaSatelitalScreenState extends State<MapaSatelitalScreen> with SingleTickerProviderStateMixin {
  late FaenaMapa _faenaActiva;
  List<MapaPunto> _puntos = [];
  MapaPunto? _puntoSeleccionado;
  LatLngPoint? _posicionUsuario;
  double? _precisionGpsMetros = 8.0;
  double? _rumboUsuario = 45.0; // Grados
  bool _cargandoImagen = true;
  ui.Image? _imagenSatelital;

  // Modos de visualización
  bool _mostrarGrillaUtm = true;
  bool _mostrarMarcadores = true;
  bool _modoSimulador = false;
  bool _gpsBuscando = false;

  final TransformationController _transformController = TransformationController();
  late AnimationController _pulseController;
  StreamSubscription? _posicionSubscription;

  // Tamaño virtual del lienzo para alta definición (HQ)
  final double _canvasWidth = 3072.0;
  final double _canvasHeight = 2560.0;

  @override
  void initState() {
    super.initState();
    _faenaActiva = MapaService.faenasCatalogo.first;

    // Posición inicial por defecto (Plataforma central de Los Pelambres)
    _posicionUsuario = LatLngPoint(
      latitude: _faenaActiva.centerLat,
      longitude: _faenaActiva.centerLng,
      altitude: 3240,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _cargarImagenSatelital();
    _cargarPuntos();
    _iniciarGps();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transformController.dispose();
    _posicionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _cargarImagenSatelital() async {
    try {
      final ByteData data = await rootBundle.load(_faenaActiva.imageAssetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _imagenSatelital = fi.image;
          _cargandoImagen = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _ajustarMapaCompleto();
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cargandoImagen = false);
      }
    }
  }

  Future<void> _cargarPuntos() async {
    final pts = await MapaService.obtenerPuntos(_faenaActiva.id);
    if (mounted) {
      setState(() => _puntos = pts);
    }
  }

  Future<void> _iniciarGps() async {
    setState(() => _gpsBuscando = true);
    final pos = await MapaService.obtenerPosicionGpsActual();
    if (pos != null && mounted) {
      setState(() {
        _posicionUsuario = LatLngPoint(
          latitude: pos.latitude,
          longitude: pos.longitude,
          altitude: pos.altitude,
        );
        _precisionGpsMetros = pos.accuracy;
        _rumboUsuario = pos.heading >= 0 ? pos.heading : _rumboUsuario;
        _gpsBuscando = false;
      });
      _centrarEnPosicion(_posicionUsuario!);
    } else {
      if (mounted) {
        setState(() => _gpsBuscando = false);
      }
    }
  }

  void _centrarEnPosicion(LatLngPoint latLng) {
    final norm = _faenaActiva.latLngToNormalized(latLng.latitude, latLng.longitude);
    final targetX = norm.dx * _canvasWidth;
    final targetY = norm.dy * _canvasHeight;

    final mediaQuery = MediaQuery.of(context).size;
    final screenW = mediaQuery.width;
    final screenH = mediaQuery.height - 180; // compensar barras

    const double zoom = 2.2;
    final double tx = -targetX * zoom + (screenW / 2);
    final double ty = -targetY * zoom + (screenH / 2);

    final matrix = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(zoom);

    _transformController.value = matrix;
  }

  void _ajustarMapaCompleto() {
    final mediaQuery = MediaQuery.of(context).size;
    final screenW = mediaQuery.width;
    final screenH = mediaQuery.height - 200;

    final scaleX = screenW / _canvasWidth;
    final scaleY = screenH / _canvasHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final tx = (screenW - (_canvasWidth * scale)) / 2;
    final ty = (screenH - (_canvasHeight * scale)) / 2;

    final matrix = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);

    _transformController.value = matrix;
  }

  void _zoomIn() {
    final matrix = _transformController.value.clone();
    final currentScale = matrix.getMaxScaleOnAxis();
    if (currentScale < 12.0) {
      final mediaQuery = MediaQuery.of(context).size;
      final cx = mediaQuery.width / 2;
      final cy = (mediaQuery.height - 180) / 2;
      const factor = 1.4;

      final newMatrix = Matrix4.identity()
        ..translate(cx, cy)
        ..scale(factor)
        ..translate(-cx, -cy)
        ..multiply(matrix);
      _transformController.value = newMatrix;
    }
  }

  void _zoomOut() {
    final matrix = _transformController.value.clone();
    final currentScale = matrix.getMaxScaleOnAxis();
    if (currentScale > 0.2) {
      final mediaQuery = MediaQuery.of(context).size;
      final cx = mediaQuery.width / 2;
      final cy = (mediaQuery.height - 180) / 2;
      const factor = 1.0 / 1.4;

      final newMatrix = Matrix4.identity()
        ..translate(cx, cy)
        ..scale(factor)
        ..translate(-cx, -cy)
        ..multiply(matrix);
      _transformController.value = newMatrix;
    }
  }

  void _abrirDetallePunto(MapaPunto punto) {
    setState(() => _puntoSeleccionado = punto);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => MapaPuntoDetalleSheet(
        punto: punto,
        posicionUsuario: _posicionUsuario,
        onNavegarHacia: () {
          setState(() => _puntoSeleccionado = punto);
        },
        onEliminar: punto.esPersonalizado
            ? () async {
                await MapaService.eliminarPuntoPersonalizado(_faenaActiva.id, punto.id);
                _cargarPuntos();
                setState(() {
                  if (_puntoSeleccionado?.id == punto.id) _puntoSeleccionado = null;
                });
              }
            : null,
      ),
    );
  }

  void _abrirCrearPunto({LatLngPoint? coordenadaInicial}) async {
    final nuevoPunto = await showDialog<MapaPunto>(
      context: context,
      builder: (ctx) => MapaNuevoPuntoDialog(
        faena: _faenaActiva,
        coordenadaInicial: coordenadaInicial ?? _posicionUsuario,
      ),
    );

    if (nuevoPunto != null) {
      await MapaService.guardarPuntoPersonalizado(_faenaActiva.id, nuevoPunto);
      await _cargarPuntos();
      _centrarEnPosicion(LatLngPoint(latitude: nuevoPunto.latitud, longitude: nuevoPunto.longitud));
      _abrirDetallePunto(nuevoPunto);
    }
  }

  void _exportarPuntos() async {
    final csv = await MapaService.exportarPuntosCsv(_faenaActiva.id);
    await Share.share(
      csv,
      subject: 'Puntos_Sondajes_${_faenaActiva.id}_${DateTime.now().toIso8601String().split('T').first}.csv',
    );
  }

  void _mostrarListaPuntos() {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.superficie,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pozos y Puntos (${_puntos.length})',
                        style: TextStyle(color: colors.azulOscuro, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _puntos.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_off_outlined, size: 48, color: colors.grisSecundario),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No hay pozos ni puntos guardados',
                                    style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Presiona el botón para registrar tu primer pozo, plataforma o refugio.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: colors.grisSecundario, fontSize: 12),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colors.naranjo,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.add_location_alt, size: 18),
                                    label: const Text('Registrar Primer Pozo'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _abrirCrearPunto();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _puntos.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final p = _puntos[index];
                              return ListTile(
                                leading: Text(p.categoria.emoji, style: const TextStyle(fontSize: 22)),
                                title: Text(
                                  p.nombre,
                                  style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'UTM ${p.husoUtm}${p.hemisferio} E: ${p.esteUtm.toStringAsFixed(0)} N: ${p.norteUtm.toStringAsFixed(0)}',
                                  style: TextStyle(color: colors.grisSecundario, fontSize: 12),
                                ),
                                trailing: Icon(Icons.chevron_right, color: colors.grisSecundario),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _centrarEnPosicion(LatLngPoint(latitude: p.latitud, longitude: p.longitud));
                                  _abrirDetallePunto(p);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onTapCanvas(TapUpDetails details) {
    // Buscar si tocó cerca de un marcador
    final localPos = details.localPosition;
    const double touchRadius = 30.0;

    for (final p in _puntos) {
      final norm = _faenaActiva.latLngToNormalized(p.latitud, p.longitud);
      final pPos = Offset(norm.dx * _canvasWidth, norm.dy * _canvasHeight);
      if ((pPos - localPos).distance <= touchRadius) {
        _abrirDetallePunto(p);
        return;
      }
    }

    // Si está en modo simulador, mover la posición del usuario aquí
    if (_modoSimulador) {
      final norm = Offset(localPos.dx / _canvasWidth, localPos.dy / _canvasHeight);
      final newLatLng = _faenaActiva.normalizedToLatLng(norm);
      setState(() {
        _posicionUsuario = LatLngPoint(
          latitude: newLatLng.latitude,
          longitude: newLatLng.longitude,
          altitude: 3200,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UtmCoordinate? utmUsuario;
    if (_posicionUsuario != null) {
      utmUsuario = UtmConverter.latLonToUtm(
        _posicionUsuario!.latitude,
        _posicionUsuario!.longitude,
        altitude: _posicionUsuario!.altitude,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1722),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.satellite_alt, color: Color(0xFF00E5FF), size: 18),
                const SizedBox(width: 6),
                Text(
                  _faenaActiva.nombre,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              '100% Offline • WGS84 & UTM 19S',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
          ],
        ),
        actions: [
          // Botón Lista de Pozos
          IconButton(
            icon: const Icon(Icons.format_list_bulleted, color: Colors.white),
            tooltip: 'Lista de Pozos y Puntos',
            onPressed: _mostrarListaPuntos,
          ),
          // Botón Selector de Capas
          PopupMenuButton<String>(
            icon: const Icon(Icons.layers_outlined, color: Colors.white),
            tooltip: 'Capas y Opciones',
            color: const Color(0xFF1E293B),
            onSelected: (val) {
              if (val == 'grilla') setState(() => _mostrarGrillaUtm = !_mostrarGrillaUtm);
              if (val == 'marcadores') setState(() => _mostrarMarcadores = !_mostrarMarcadores);
              if (val == 'simulador') {
                setState(() => _modoSimulador = !_modoSimulador);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_modoSimulador ? 'Modo Simulador activado: Toca en el mapa para moverte' : 'Modo GPS real activado'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              if (val == 'exportar') _exportarPuntos();
            },
            itemBuilder: (ctx) => [
              CheckedPopupMenuItem(
                value: 'grilla',
                checked: _mostrarGrillaUtm,
                child: const Text('Cuadrícula Métrica UTM', style: TextStyle(color: Colors.white)),
              ),
              CheckedPopupMenuItem(
                value: 'marcadores',
                checked: _mostrarMarcadores,
                child: const Text('Marcadores de Pozos', style: TextStyle(color: Colors.white)),
              ),
              CheckedPopupMenuItem(
                value: 'simulador',
                checked: _modoSimulador,
                child: const Text('Modo Simulador / Pruebas', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'exportar',
                child: Row(
                  children: [
                    Icon(Icons.file_download_outlined, color: Colors.amberAccent, size: 20),
                    SizedBox(width: 8),
                    Text('Exportar Planilla CSV', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          // Botón Volver al Inicio (Home)
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            tooltip: 'Volver al Inicio',
            onPressed: () {
              if (widget.onNavigate != null) {
                widget.onNavigate!(AppRoutes.home);
              } else {
                Navigator.popUntil(context, (r) => r.isFirst);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. LIENZO INTERACTIVO DEL MAPA SATELITAL
          Positioned.fill(
            child: _cargandoImagen
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
                : InteractiveViewer(
                    transformationController: _transformController,
                    minScale: 0.2,
                    maxScale: 10.0,
                    boundaryMargin: const EdgeInsets.all(1000),
                    child: SizedBox(
                      width: _canvasWidth,
                      height: _canvasHeight,
                      child: GestureDetector(
                        onTapUp: _onTapCanvas,
                        onLongPressStart: (details) {
                          final norm = Offset(details.localPosition.dx / _canvasWidth, details.localPosition.dy / _canvasHeight);
                          final latLng = _faenaActiva.normalizedToLatLng(norm);
                          _abrirCrearPunto(coordenadaInicial: latLng);
                        },
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) {
                            return CustomPaint(
                              size: Size(_canvasWidth, _canvasHeight),
                              painter: MapaCanvasPainter(
                                imagenSatelital: _imagenSatelital,
                                faena: _faenaActiva,
                                puntos: _puntos,
                                puntoSeleccionado: _puntoSeleccionado,
                                posicionUsuario: _posicionUsuario,
                                precisionMetros: _precisionGpsMetros,
                                rumboUsuario: _rumboUsuario,
                                mostrarGrillaUtm: _mostrarGrillaUtm,
                                mostrarMarcadores: _mostrarMarcadores,
                                escalaZoom: _transformController.value.getMaxScaleOnAxis(),
                                pulsoAnimacion: _pulseController.value,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          ),

          // 2. BOTONES FLOTANTES DE ACCIÓN RÁPIDA (DERECHA)
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                // Centrar en ubicación actual
                _buildMapFloatingBtn(
                  icon: _gpsBuscando ? Icons.gps_not_fixed : Icons.my_location,
                  tooltip: 'Centrar en mi ubicación',
                  color: const Color(0xFF00E5FF),
                  onPressed: () {
                    if (_posicionUsuario != null) {
                      _centrarEnPosicion(_posicionUsuario!);
                    } else {
                      _iniciarGps();
                    }
                  },
                ),
                const SizedBox(height: 10),
                // Ajustar al mapa completo
                _buildMapFloatingBtn(
                  icon: Icons.zoom_out_map,
                  tooltip: 'Ajustar mapa completo',
                  onPressed: _ajustarMapaCompleto,
                ),
                const SizedBox(height: 10),
                // Botón Zoom +
                _buildMapFloatingBtn(
                  icon: Icons.add,
                  tooltip: 'Acercar zoom (+)',
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 10),
                // Botón Zoom -
                _buildMapFloatingBtn(
                  icon: Icons.remove,
                  tooltip: 'Alejar zoom (-)',
                  onPressed: _zoomOut,
                ),
                const SizedBox(height: 10),
                // Agregar nuevo pozo / waypoint
                _buildMapFloatingBtn(
                  icon: Icons.add_location_alt,
                  tooltip: 'Registrar nuevo pozo en terreno',
                  color: Colors.amberAccent,
                  onPressed: () => _abrirCrearPunto(),
                ),
                const SizedBox(height: 10),
                // Indicador Modo Simulador
                if (_modoSimulador)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🎮 MODO SIMULADOR',
                      style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),

          // 3. BARRA INFERIOR DE TELEMETRÍA Y COORDENADAS MINERAS
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, -3)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Coordenadas en tiempo real
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.gps_fixed, color: Color(0xFF00E5FF), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                utmUsuario != null ? utmUsuario.formatted : 'Buscando satélites...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _posicionUsuario != null
                                    ? 'WGS84: ${_posicionUsuario!.formatted} • Precisión ±${_precisionGpsMetros?.toStringAsFixed(0)}m'
                                    : 'Sin señal GNSS',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        if (_puntoSeleccionado != null)
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.amberAccent,
                              backgroundColor: Colors.amberAccent.withOpacity(0.15),
                            ),
                            icon: const Icon(Icons.info_outline, size: 16),
                            label: Text(_puntoSeleccionado!.nombre),
                            onPressed: () => _abrirDetallePunto(_puntoSeleccionado!),
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
    );
  }

  Widget _buildMapFloatingBtn({
    required IconData icon,
    required String tooltip,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.white, size: 22),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
