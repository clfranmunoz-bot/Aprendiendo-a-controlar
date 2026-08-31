import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/app_routes.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';

class TutorialScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;

  const TutorialScreen({
    super.key,
    required this.onNavigate,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  int _paginaActual = 0;
  int _faseActual = 0;
  int _modoVista = 0; // 0 = Guía Paso a Paso, 1 = Roadmap de Terreno Completo

  // Estados interactivos in-line
  double _inlinePm = 0.50;
  int _inlineBarras = 40;
  final double _inlineTestigoRec = 1.45;
  final double _inlinePerforado = 1.50;
  final Set<String> _eppChecked = {};
  final Set<String> _roadmapCompletados = {};

  static const List<Map<String, dynamic>> _fases = [
    {
      "titulo": "Antes de Perforar",
      "subtitulo": "Inicio de Turno",
      "color": Colors.blue,
      "emoji": "🟦",
      "pasos": [
        {
          "icono": "🤝",
          "titulo": "Traspaso de turno",
          "descripcion":
              "Recibe del controlador saliente el fondo actual, la sarta configurada, anomalías detectadas y cualquier observación pendiente. Este traspaso es obligatorio.",
          "tip": "Anota el fondo exacto en tu cuaderno antes de que el turno anterior se retire.",
        },
        {
          "icono": "📐",
          "titulo": "Verifica el Punto Muerto (PM)",
          "descripcion":
              "Mide la distancia fija entre el collar del pozo y la marca de referencia de la contra en el cabezal. El PM es constante en el turno (típicamente 0.40m - 1.20m).",
          "formula": r"PM = distancia fija desde el suelo hasta la marca del cabezal",
          "tip": "El PM es el mismo durante todo el turno. Mídelo al inicio y no lo olvides.",
          "interactiveType": "pm_slider",
        },
        {
          "icono": "🧮",
          "titulo": "Calcula las Herramientas Totales",
          "descripcion":
              "Con los datos del perforista (N° de barras, tipo de barril y extensión), calcula la longitud total de la sarta para verificar el fondo.",
          "formula": r"Herr = (N° Barras × Largo) + Barril + Extensión − PM",
          "tip": "Confirma con el perforista el número exacto de barras antes de calcular.",
          "interactiveType": "herr_calc",
        },
        {
          "icono": "📋",
          "titulo": "Checklist de Inicio y EPP Obligatorio",
          "descripcion":
              "Verifica EPP obligatorio, delimitación de área, limpieza de plataforma y realiza la charla de 5 minutos de seguridad con la cuadrilla.",
          "tip": "No comiences a registrar corridas sin haber completado el checklist de inicio.",
          "interactiveType": "epp_checker",
        },
        {
          "icono": "📓",
          "titulo": "Prepara tu cuaderno de terreno",
          "descripcion":
              "Abre una nueva hoja con los datos del pozo: nombre, fecha, turno, fondo inicial, perforista y PM. Deja columnas para: Desde, Hasta, Perforado, Testigo, %Rec y Contra.",
          "tip": "Un cuaderno ordenado es la firma de un controlador profesional.",
        },
      ],
    },
    {
      "titulo": "Durante la Perforación",
      "subtitulo": "Registro de Corridas",
      "color": Colors.green,
      "emoji": "🟩",
      "pasos": [
        {
          "icono": "📖",
          "titulo": "Lee la Contra antes de cada corrida",
          "descripcion":
              "Antes de que el perforista baje el barril, consulta y anota la contra (sobrante de sarta). Es el punto de partida de cada corrida.",
          "formula": r"Desde = Fondo anterior",
          "tip": "La contra siempre se lee con la sarta apoyada suavemente en el fondo, con mínima presión.",
        },
        {
          "icono": "⛏️",
          "titulo": "Supervisa la extracción del testigo",
          "descripcion":
              "Cuando el perforista sube el tubo interior, observa que la laina salga completa y no sea golpeada. Ayuda a posicionarla en la cuna de tendido con cuidado.",
          "tip": "Nunca dejes que el testigo caiga al suelo. La muestra rota no puede recuperarse.",
        },
        {
          "icono": "📏",
          "titulo": "Mide el testigo y calcula %Rec",
          "descripcion":
              "Extiende el testigo en la cuna y mídelo con cinta métrica. Anota los metros de testigo recuperado y calcula el porcentaje de recuperación.",
          "formula": r"%Rec = (Testigo recuperado / Metros perforados) × 100",
          "tip": "Si la recuperación es menor al 85%, anota la causa (roca molida, falla, soplado).",
          "interactiveType": "rec_calc",
        },
        {
          "icono": "🔢",
          "titulo": "Calcula la nueva Contra y Adiciones",
          "descripcion":
              "Después de registrar la corrida, calcula la nueva contra. Si se agregó barra, primero suma el largo de barra a la contra anterior.",
          "formula": "Contra nueva = Contra anterior - Perforado\nCon adición: Contra Ajustada = Contra anterior + Largo barra",
          "tip": "Compara tu contra calculada con la que reporta el perforista. Deben coincidir.",
        },
        {
          "icono": "🏷️",
          "titulo": "Coloca los tacos y regulariza",
          "descripcion":
              "Instala el taco de bloqueo rojo al final de cada corrida en la bandeja. Realiza la regularización colocando tacos en los múltiplos exactos de metro.",
          "tip": "La regularización permite al geólogo saber exactamente dónde se perdió testigo.",
        },
        {
          "icono": "🪣",
          "titulo": "Monitorea el agua de retorno",
          "descripcion":
              "Observa constantemente el retorno del fluido. Si disminuye o se pierde, informa de inmediato al perforista y al supervisor. Anota la profundidad donde ocurrió.",
          "tip": "La pérdida de retorno no es un problema menor. Puede comprometer el pozo entero.",
        },
        {
          "icono": "📸",
          "titulo": "Documenta en el cuaderno de terreno",
          "descripcion":
              "Anota cada corrida al instante: Desde, Hasta, Metros perforados, Testigo, %Rec, Contra y cualquier observación geológica relevante.",
          "tip": "Una corrida sin anotar es una corrida perdida. Registra todo en el momento.",
        },
      ],
    },
    {
      "titulo": "Cierre de Turno",
      "subtitulo": "Entrega y Documentación",
      "color": Colors.orange,
      "emoji": "🟧",
      "pasos": [
        {
          "icono": "✔️",
          "titulo": "Verifica el fondo final",
          "descripcion":
              "Confirma con el perforista el fondo final del pozo. Calcula una última vez: Herramientas − Contra − PM, y verifica que coincida con el fondo acumulado.",
          "formula": "Fondo = Herr - Contra - PM\n(debe coincidir con: Fondo anterior + Metros perforados totales)",
          "tip": "Si hay diferencia de más de 0.05 m entre ambos métodos, revisa tus cálculos.",
        },
        {
          "icono": "📦",
          "titulo": "Organiza y marca las cajas de testigo",
          "descripcion":
              "Verifica que todas las cajas del turno tengan su rotulación completa: Nombre del pozo, N° de caja, Desde/Hasta en metros y flecha de avance.",
          "tip": "Revisa dos veces el Desde/Hasta rotulado en la madera antes de cerrar la caja.",
        },
        {
          "icono": "📷",
          "titulo": "Toma las fotografías oficiales",
          "descripcion":
              "Fotografía cada caja de testigo del turno en posición vertical, centrada, con buena iluminación y con el taco de madera rotulado bien visible.",
          "tip": "Evita sombras y reflejos del sol en la muestra al fotografiar.",
        },
        {
          "icono": "📊",
          "titulo": "Consolida la planilla diaria",
          "descripcion":
              "Suma el total de metros perforados en el turno, calcula la recuperación promedio del día y verifica que no falten datos en ninguna fila.",
          "formula": r"%Rec Promedio = (Total testigo / Total perforado) × 100",
          "tip": "El %Rec promedio del turno es el dato principal que revisará el cliente.",
        },
        {
          "icono": "🤝",
          "titulo": "Realiza el traspaso al turno entrante",
          "descripcion":
              "Entrega el pozo al controlador del siguiente turno: fondo final, contra actual, sarta en pozo, cajas listas y cualquier observación pendiente.",
          "tip": "Un buen traspaso protege la continuidad de la operación y evita errores en el turno siguiente.",
        },
        {
          "icono": "🔒",
          "titulo": "Cierra tu turno y guarda tu libreta",
          "descripcion":
              "Firma la planilla física, guarda tu cuaderno en un lugar seguro y notifica al supervisor que el turno ha sido cerrado formalmente.",
          "tip": "Felicidades por completar un turno seguro y riguroso.",
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _pasosActuales =>
      List<Map<String, dynamic>>.from(_fases[_faseActual]['pasos']);

  int get _totalPasos => _pasosActuales.length;

  void _nextPage() {
    if (_paginaActual < _totalPasos - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else if (_faseActual < _fases.length - 1) {
      setState(() {
        _faseActual++;
        _paginaActual = 0;
      });
      _pageController.jumpToPage(0);
    }
  }

  void _prevPage() {
    if (_paginaActual > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else if (_faseActual > 0) {
      setState(() {
        _faseActual--;
        _paginaActual = _pasosActuales.length - 1;
      });
      _pageController.jumpToPage(_totalPasos - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fase = _fases[_faseActual];
    final Color faseColor = fase['color'] as Color;
    final pasos = _pasosActuales;
    final bool esUltimoPaso = _faseActual == _fases.length - 1 && _paginaActual == _totalPasos - 1;
    final bool esPrimerPaso = _faseActual == 0 && _paginaActual == 0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.fondo,
      drawer: DrawerMenu(
        onNavigate: widget.onNavigate,
        modoOscuro: widget.modoOscuro,
        onToggleModoOscuro: widget.onToggleModoOscuro,
      ),
      appBar: AppBar(
        backgroundColor: colors.superficie,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: colors.azulOscuro),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          "Flujo Completo de Turno",
          style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: colors.azulOscuro),
            onPressed: () => widget.onNavigate('home'),
          )
        ],
      ),
      body: Column(
        children: [
          // Selector de Modo de Vista (Paso a Paso vs Roadmap Completo)
          Container(
            color: colors.superficie,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: colors.superficieSuave,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.bordeSuave),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _modoVista = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _modoVista == 0 ? colors.azul : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app_outlined, size: 15, color: _modoVista == 0 ? Colors.white : colors.grisTexto),
                            const SizedBox(width: 6),
                            Text(
                              "Guía Interactiva",
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _modoVista == 0 ? Colors.white : colors.grisTexto,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _modoVista = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _modoVista == 1 ? colors.azul : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.alt_route_outlined, size: 15, color: _modoVista == 1 ? Colors.white : colors.grisTexto),
                            const SizedBox(width: 6),
                            Text(
                              "Roadmap Completo",
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _modoVista == 1 ? Colors.white : colors.grisTexto,
                              ),
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

          if (_modoVista == 0) ...[
            // MODO 0: GUÍA INTERACTIVA PASO A PASO
            Container(
              color: colors.superficie,
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: Row(
                children: List.generate(_fases.length, (i) {
                  final f = _fases[i];
                  final isActive = i == _faseActual;
                  final c = f['color'] as Color;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _faseActual = i;
                          _paginaActual = 0;
                        });
                        _pageController.jumpToPage(0);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: i < _fases.length - 1 ? 6 : 0),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? c.withValues(alpha: 0.15) : colors.superficieSuave,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive ? c : colors.bordeSuave,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(f['emoji'] as String, style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(
                              f['subtitulo'] as String,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive ? c : colors.grisTexto,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            LinearProgressIndicator(
              value: (_paginaActual + 1) / _totalPasos,
              backgroundColor: colors.bordeSuave,
              valueColor: AlwaysStoppedAnimation<Color>(faseColor),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _paginaActual = page),
                itemCount: pasos.length,
                itemBuilder: (ctx, i) {
                  final paso = pasos[i];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: faseColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: faseColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                "Paso ${i + 1} de $_totalPasos — ${fase['titulo']}",
                                style: TextStyle(
                                  color: faseColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Text(paso['icono'] as String, style: const TextStyle(fontSize: 34)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                paso['titulo'] as String,
                                style: TextStyle(
                                  color: colors.azulOscuro,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Text(
                          paso['descripcion'] as String,
                          style: TextStyle(color: colors.grisTexto, fontSize: 14.5, height: 1.5),
                        ),
                        const SizedBox(height: 14),

                        // Mini-Herramientas Interactivas in-line por tipo de paso
                        if (paso['interactiveType'] == 'pm_slider') _buildPmInteractive(colors, faseColor),
                        if (paso['interactiveType'] == 'herr_calc') _buildHerrCalcInteractive(colors, faseColor),
                        if (paso['interactiveType'] == 'epp_checker') _buildEppInteractive(colors, faseColor),
                        if (paso['interactiveType'] == 'rec_calc') _buildRecCalcInteractive(colors, faseColor),

                        // Fórmula (si aplica)
                        if (paso['formula'] != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: faseColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: faseColor.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.functions, color: faseColor, size: 16),
                                    const SizedBox(width: 6),
                                    Text("Fórmula clave:", style: TextStyle(color: faseColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  paso['formula'] as String,
                                  style: TextStyle(
                                    color: colors.azulOscuro,
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Pro Tip
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade600.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("💡", style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Consejo de Terreno:",
                                      style: TextStyle(
                                        color: Colors.amber.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      paso['tip'] as String,
                                      style: TextStyle(
                                        color: colors.azulOscuro,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Barra inferior de navegación
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.superficie,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, -2))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: esPrimerPaso ? null : _prevPage,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text("Anterior"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.superficieSuave,
                      foregroundColor: colors.azulOscuro,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      _totalPasos,
                      (idx) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: idx == _paginaActual ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: idx == _paginaActual ? faseColor : colors.bordeSuave,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: esUltimoPaso ? () => _mostrarModalCertificado(context) : _nextPage,
                    icon: Icon(esUltimoPaso ? Icons.emoji_events : Icons.arrow_forward, size: 16),
                    label: Text(esUltimoPaso ? "Finalizar" : "Siguiente"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: esUltimoPaso ? Colors.orange.shade700 : faseColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // MODO 1: ROADMAP COMPLETO DE TERRENO (VISTA INFOGRAFÍA / LÍNEA DE TIEMPO)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _fases.length,
                itemBuilder: (context, fIdx) {
                  final f = _fases[fIdx];
                  final Color fColor = f['color'] as Color;
                  final List<Map<String, dynamic>> fPasos = List<Map<String, dynamic>>.from(f['pasos']);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header de Fase
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        margin: const EdgeInsets.only(top: 8, bottom: 12),
                        decoration: BoxDecoration(
                          color: fColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: fColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Text(f['emoji'] as String, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Fase ${fIdx + 1}: ${f['titulo']}",
                                    style: TextStyle(color: fColor, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    "${fPasos.length} Pasos clave de control",
                                    style: TextStyle(color: colors.grisTexto, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Pasos en línea de tiempo vertical
                      ...List.generate(fPasos.length, (pIdx) {
                        final p = fPasos[pIdx];
                        final stepId = "${fIdx}_$pIdx";
                        final isChecked = _roadmapCompletados.contains(stepId);

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Columna de conector vertical
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isChecked) {
                                          _roadmapCompletados.remove(stepId);
                                        } else {
                                          _roadmapCompletados.add(stepId);
                                        }
                                      });
                                    },
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: isChecked ? Colors.green : fColor,
                                      child: isChecked
                                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                                          : Text("${pIdx + 1}", style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  if (pIdx < fPasos.length - 1)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: fColor.withValues(alpha: 0.3),
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),

                              // Tarjeta de paso
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isChecked ? Colors.green.withValues(alpha: 0.04) : colors.superficie,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isChecked ? Colors.green.withValues(alpha: 0.3) : colors.bordeSuave,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(p['icono'] as String, style: const TextStyle(fontSize: 20)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              p['titulo'] as String,
                                              style: TextStyle(
                                                color: colors.azulOscuro,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                                              color: isChecked ? Colors.green : colors.grisSecundario,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                if (isChecked) {
                                                  _roadmapCompletados.remove(stepId);
                                                } else {
                                                  _roadmapCompletados.add(stepId);
                                                }
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        p['descripcion'] as String,
                                        style: TextStyle(color: colors.grisTexto, fontSize: 12.5, height: 1.4),
                                      ),
                                      if (p['formula'] != null) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: fColor.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            p['formula'] as String,
                                            style: TextStyle(color: fColor, fontSize: 10.5, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // WIDGETS INTERACTIVOS IN-LINE PARA LOS PASOS

  Widget _buildPmInteractive(AppColors colors, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.superficieSuave,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Prueba el Punto Muerto (PM):", style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold)),
              Text("${_inlinePm.toStringAsFixed(2)} m", style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _inlinePm,
            min: 0.20,
            max: 1.50,
            divisions: 26,
            activeColor: accent,
            onChanged: (v) => setState(() => _inlinePm = v),
          ),
          Text(
            "El PM representa los ${_inlinePm.toStringAsFixed(2)} m entre el suelo y la lectura del cabezal.",
            style: TextStyle(color: colors.grisTexto, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildHerrCalcInteractive(AppColors colors, Color accent) {
    final herr = (_inlineBarras * 3.00) + 4.15 - _inlinePm;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.superficieSuave,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Simulador rápido de Sarta:", style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Barras (3m c/u): $_inlineBarras", style: TextStyle(color: colors.grisTexto, fontSize: 12)),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => setState(() => _inlineBarras = (_inlineBarras - 1).clamp(1, 100))),
                  Text("$_inlineBarras", style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => setState(() => _inlineBarras = (_inlineBarras + 1).clamp(1, 100))),
                ],
              )
            ],
          ),
          Text("Formula: ($_inlineBarras × 3.00) + 4.15m - ${_inlinePm.toStringAsFixed(2)}m", style: const TextStyle(fontSize: 11, fontFamily: "monospace")),
          const SizedBox(height: 4),
          Text("Herramientas Totales = ${herr.toStringAsFixed(2)} m", style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEppInteractive(AppColors colors, Color accent) {
    final eppList = ["Casco c/Barbijo", "Lentes UV", "Guantes Nitrilo", "Zapatos Acero", "Fonos Auditivos"];
    final done = _eppChecked.length == eppList.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: done ? Colors.green.withValues(alpha: 0.08) : colors.superficieSuave,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? Colors.green : accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("EPP de Seguridad Obligatorio:", style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold)),
              if (done)
                const Text("¡EPP APROBADO! ✅", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: eppList.map((item) {
              final isChecked = _eppChecked.contains(item);
              return ChoiceChip(
                label: Text(item, style: TextStyle(fontSize: 10, color: isChecked ? Colors.white : colors.azulOscuro)),
                selected: isChecked,
                selectedColor: Colors.green,
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      _eppChecked.add(item);
                    } else {
                      _eppChecked.remove(item);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecCalcInteractive(AppColors colors, Color accent) {
    final recPct = _inlinePerforado > 0 ? (_inlineTestigoRec / _inlinePerforado) * 100 : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.superficieSuave,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Calculador In-line de %Rec:", style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text("Testigo: ${_inlineTestigoRec.toStringAsFixed(2)} m", style: TextStyle(color: colors.grisTexto, fontSize: 11)),
              ),
              Expanded(
                child: Text("Perforado: ${_inlinePerforado.toStringAsFixed(2)} m", style: TextStyle(color: colors.grisTexto, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text("% Recuperación = ${recPct.toStringAsFixed(1)}%", style: TextStyle(color: recPct >= 85 ? Colors.green : Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _mostrarModalCertificado(BuildContext context) {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.superficie,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Text("🏆", style: TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text("¡Inducción Completada!", style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
          ],
        ),
        content: Text(
          "Has recorrido los 18 pasos del flujo operacional completo de un turno. ¡Ya estás preparado para realizar tu primer simulacro práctico!",
          style: TextStyle(color: colors.grisTexto, fontSize: 13.5, height: 1.45),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Repasar Guía"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onNavigate(AppRoutes.simulacro);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text("Ir al Simulacro"),
          ),
        ],
      ),
    );
  }
}
