import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';
import 'package:share_plus/share_plus.dart';

class ChecklistScreen extends StatefulWidget {
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;
  final Function(String) onNavigate;
  final String perfilActivo;

  const ChecklistScreen({
    super.key,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
    required this.onNavigate,
    required this.perfilActivo,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  late TabController _tabController;
  List<bool> _checklistValues = [];
  bool _loading = true;
  List<Map<String, dynamic>> _historialTurnos = [];
  DateTime? _inicioTurno;
  int? _expandedTaskId;

  final List<Map<String, dynamic>> _phases = [
    {"title": "Inicio de Turno", "icon": Icons.wb_sunny_outlined, "color": Colors.blue},
    {"title": "Control Operativo", "icon": Icons.build_outlined, "color": Colors.green},
    {"title": "Cierre de Turno", "icon": Icons.nightlight_round_outlined, "color": Colors.purple},
    {"title": "Protocolos Especiales", "icon": Icons.warning_amber_outlined, "color": Colors.orange},
  ];

  final List<Map<String, dynamic>> _checklistItems = [
    // Phase 0: Inicio
    {
      "id": 0,
      "phase": 0,
      "icon": Icons.handshake_outlined,
      "title": "Traspaso de Información de Turno",
      "desc": "Coordinar con el inspector saliente el metraje pendiente, anomalías geológicas detectadas y la profundidad actual del pozo.",
      "tip": "Anota el fondo en tu libreta antes de que el turno anterior abandone la plataforma.",
    },
    {
      "id": 1,
      "phase": 0,
      "icon": Icons.record_voice_over_outlined,
      "title": "Charla de 5 Minutos de Seguridad",
      "desc": "Realizar o participar en la charla de seguridad matutina con la cuadrilla del perforista.",
      "tip": "Verifica que todos firmen la toma de conocimiento de riesgos.",
    },
    {
      "id": 2,
      "phase": 0,
      "icon": Icons.shield_outlined,
      "title": "EPP Completo y en Buen Estado",
      "desc": "Inspeccionar casco con barbijo, lentes UV, guantes de nitrilo/impacto, calzado con puntera de acero y protector solar.",
      "tip": "El EPP dañado debe ser reemplazado de inmediato.",
    },
    {
      "id": 3,
      "phase": 0,
      "icon": Icons.block_outlined,
      "title": "Delimitación de Área (Segregación)",
      "desc": "Verificar la segregación con conos, cadenas y letreros de advertencia en la plataforma activa de perforación.",
      "tip": "Mantente siempre fuera del radio de movimiento de barras.",
    },
    {
      "id": 4,
      "phase": 0,
      "icon": Icons.cleaning_services_outlined,
      "title": "Limpieza y Orden de Plataforma",
      "desc": "Asegurar que la plataforma esté libre de derrames de aceites, lodos de perforación y obstáculos.",
      "tip": "Una plataforma limpia previene caídas al mismo nivel.",
    },

    // Phase 1: Operativo
    {
      "id": 5,
      "phase": 1,
      "icon": Icons.unarchive_outlined,
      "title": "Monitoreo de Extracción del Testigo",
      "desc": "Supervisar la salida del tubo muestreador para evitar que el testigo sea golpeado o fracturado de forma artificial.",
      "tip": "No permitas golpes mecánicos a la laina.",
    },
    {
      "id": 6,
      "phase": 1,
      "icon": Icons.straighten,
      "title": "Medición y Recuperación de Corrida",
      "desc": "Medir el testigo de forma física y calcular el porcentaje de recuperación operacional (%) comparado con la carrera.",
      "tip": "Usa cinta métrica sobre el eje longitudinal central.",
    },
    {
      "id": 7,
      "phase": 1,
      "icon": Icons.move_to_inbox_outlined,
      "title": "Traspaso de Muestra a Bandeja",
      "desc": "Con cuidado y apoyo de puruña se traspasa la muestra desde la laina hasta la bandeja respetando el avance (Desde->Hasta).",
      "tip": "Revisa el sentido de avance antes de posicionar la muestra.",
    },
    {
      "id": 8,
      "phase": 1,
      "icon": Icons.tag,
      "title": "Posicionamiento de Tacos de Bloqueo",
      "desc": "Instalar tacos plásticos rojos o de madera con la profundidad exacta rotulada con claridad al final de cada carrera.",
      "tip": "Rotula con marcador indeleble de alta densidad.",
    },
    {
      "id": 9,
      "phase": 1,
      "icon": Icons.edit_note_outlined,
      "title": "Efectuar Regularización Física",
      "desc": "Ubicación de tacos de regularización a múltiplos de metros exactos, marcando la laina de forma metódica.",
      "tip": "Ubica geográficamente la pérdida de testigo en las fallas.",
    },
    {
      "id": 10,
      "phase": 1,
      "icon": Icons.edit_calendar_outlined,
      "title": "Rotulación de Caja Porta Testigo",
      "desc": "Marcar con letra clara e indeleble en el cabezal de la caja: Pozo, N° de Caja, Desde, Hasta y Flecha de avance.",
      "tip": "Usa plumón resistente al agua y al sol.",
    },

    // Phase 2: Especiales
    {
      "id": 11,
      "phase": 3,
      "icon": Icons.water_drop_outlined,
      "title": "Control de Pérdida de Retorno de Agua",
      "desc": "Supervisar el volumen de retorno de fluido e informar de inmediato ante pérdidas de circulación en el pozo.",
      "tip": "Registra la profundidad exacta de la pérdida en tu libreta.",
    },
    {
      "id": 12,
      "phase": 3,
      "icon": Icons.compass_calibration_outlined,
      "title": "Medición de Orientación de Testigo",
      "desc": "Verificar la correcta colocación y lectura del instrumento de orientación de testigo (Reflex / Champ).",
      "tip": "Asegura el acople del tubo de extensión de 0.40m.",
    },
    {
      "id": 13,
      "phase": 3,
      "icon": Icons.report_problem_outlined,
      "title": "Notificación de Incidencias Operacionales",
      "desc": "Reportar anomalías como atascamientos de sarta, desgaste prematuro de coronas o fallas mecánicas.",
      "tip": "Informa de inmediato al supervisor de turno.",
    },

    // Phase 3: Cierre
    {
      "id": 14,
      "phase": 2,
      "icon": Icons.calculate_outlined,
      "title": "Conciliación de Fondo Final y Sarta",
      "desc": "Verificar el fondo acumulado con la fórmula: Herramientas - Contra - PM, asegurando coincidencia total.",
      "tip": "No te retires sin conciliar el fondo con el perforista.",
    },
    {
      "id": 15,
      "phase": 2,
      "icon": Icons.camera_alt_outlined,
      "title": "Registro Fotográfico de Cajas",
      "desc": "Capturar fotografías de alta resolución de todas las cajas del turno en ángulo perpendicular y sin sombras.",
      "tip": "Asegura que las etiquetas de profundidad sean legibles.",
    },
    {
      "id": 16,
      "phase": 2,
      "icon": Icons.assignment_turned_in_outlined,
      "title": "Cierre de Planilla Física de Terreno",
      "desc": "Consolidar metros perforados, porcentaje de recuperación promedio y firmar el reporte con el perforista.",
      "tip": "Revisa los decimales y totales antes de firmar.",
    },
    {
      "id": 17,
      "phase": 2,
      "icon": Icons.lock_outline,
      "title": "Entrega Final y Cierre de Turno",
      "desc": "Entregar copia de la planilla al supervisor, resguardar las muestras y cerrar el turno formalmente.",
      "tip": "Un cierre ordenado garantiza un inicio limpio mañana.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _phases.length, vsync: this);
    _checklistValues = List.filled(_checklistItems.length, false);
    _cargarEstado();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = "checklist_${widget.perfilActivo}_";

    final savedValues = prefs.getStringList("${prefix}values");
    if (savedValues != null && savedValues.length == _checklistItems.length) {
      _checklistValues = savedValues.map((v) => v == "true").toList();
    }

    final inicioMs = prefs.getInt("${prefix}inicio_turno");
    if (inicioMs != null) {
      _inicioTurno = DateTime.fromMillisecondsSinceEpoch(inicioMs);
    }

    final historialRaw = prefs.getStringList("${prefix}historial");
    if (historialRaw != null) {
      _historialTurnos = List<Map<String, dynamic>>.from(historialRaw.map((item) {
        final parts = item.split('|');
        return <String, dynamic>{
          "fecha": parts[0],
          "completado": parts.length > 1 ? parts[1] : "100%",
          "duracion": parts.length > 2 ? parts[2] : "Turno",
        };
      }));
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _guardarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = "checklist_${widget.perfilActivo}_";
    final valuesStr = _checklistValues.map((v) => v.toString()).toList();
    await prefs.setStringList("${prefix}values", valuesStr);

    if (_inicioTurno != null) {
      await prefs.setInt("${prefix}inicio_turno", _inicioTurno!.millisecondsSinceEpoch);
    } else {
      await prefs.remove("${prefix}inicio_turno");
    }
  }

  Future<void> _iniciarTurno() async {
    setState(() {
      _inicioTurno = DateTime.now();
    });
    await _guardarEstado();
  }

  Future<void> _finalizarTurno() async {
    final totalCount = _checklistItems.length;
    final completedCount = _checklistValues.where((v) => v).length;
    final missingCount = totalCount - completedCount;

    if (missingCount > 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final colors = AppColors.of(ctx);
          final missingItems = _checklistItems
              .asMap()
              .entries
              .where((e) => !_checklistValues[e.key])
              .map((e) => e.value)
              .toList();

          return AlertDialog(
            backgroundColor: colors.superficie,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Turno Incompleto ($completedCount/$totalCount)",
                    style: TextStyle(color: colors.azulOscuro, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "⚠️ ¡Atención! Aún tienes $missingCount tareas pendientes por realizar en este turno:",
                  style: TextStyle(color: colors.grisTexto, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: missingItems.take(5).map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Icon(Icons.radio_button_unchecked, size: 14, color: Colors.orange),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item['title'].toString(),
                                  style: TextStyle(color: colors.azulOscuro, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (missingItems.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "...y ${missingItems.length - 5} tareas más pendientes.",
                      style: TextStyle(color: colors.grisTexto, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Revisar Pendientes"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
                child: const Text("Finalizar Incompleto"),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;
    }

    await _ejecutarCierreTurno(completedCount, totalCount);
  }

  Future<void> _ejecutarCierreTurno(int completedCount, int totalCount) async {
    final pct = ((completedCount / totalCount) * 100).toStringAsFixed(0);

    final duracionStr = _inicioTurno != null
        ? "${DateTime.now().difference(_inicioTurno!).inHours}h ${DateTime.now().difference(_inicioTurno!).inMinutes.remainder(60)}m"
        : "N/A";

    final fechaStr = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    final nuevoRegistro = "$fechaStr|$pct% completado|$duracionStr";

    final prefs = await SharedPreferences.getInstance();
    final prefix = "checklist_${widget.perfilActivo}_";
    final historialRaw = prefs.getStringList("${prefix}historial") ?? [];
    historialRaw.insert(0, nuevoRegistro);
    await prefs.setStringList("${prefix}historial", historialRaw);

    // Reset checklist
    setState(() {
      _checklistValues = List.filled(_checklistItems.length, false);
      _inicioTurno = null;
      _historialTurnos.insert(0, <String, dynamic>{
        "fecha": fechaStr,
        "completado": "$pct% completado",
        "duracion": duracionStr,
      });
    });
    await _guardarEstado();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(completedCount == totalCount
              ? "🎉 ¡Turno 100% completado con éxito! Archivado en historial."
              : "Turno cerrado ($pct% completado, $totalCount-$completedCount faltantes). Archivo en historial."),
          backgroundColor: completedCount == totalCount ? Colors.green : Colors.orange.shade800,
        ),
      );
    }
  }

  void _compartirReporte() {
    final completedCount = _checklistValues.where((v) => v).length;
    final total = _checklistItems.length;
    final pct = ((completedCount / total) * 100).toStringAsFixed(0);
    final completedList = _checklistItems.asMap().entries.where((e) => _checklistValues[e.key]).map((e) => "✅ ${e.value['title']}").join("\n");
    
    final text = "📋 REPORTE PASO A PASO DEL TURNO\nOperador: ${widget.perfilActivo}\nProgreso: $pct% ($completedCount de $total tareas)\n\nTareas Completadas:\n$completedList";
        
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: colors.fondo,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalItems = _checklistItems.length;
    final completedItems = _checklistValues.where((v) => v).length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

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
          "Paso a paso del turno",
          style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            color: colors.azulOscuro,
            tooltip: "Reiniciar Tareas",
            onPressed: _reiniciarChecklist,
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            color: colors.azulOscuro,
            tooltip: "Ir al Inicio",
            onPressed: () => widget.onNavigate("home"),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            color: colors.azulOscuro,
            tooltip: "Compartir Reporte",
            onPressed: _compartirReporte,
          ),
          IconButton(
            icon: const Icon(Icons.history_outlined),
            color: colors.azulOscuro,
            tooltip: "Historial de Turnos",
            onPressed: () => _mostrarModalHistorial(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // DASHBOARD DE PROGRESO DE TURNO
          Container(
            color: colors.superficie,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.azul.withValues(alpha: 0.1), colors.azulClaro.withValues(alpha: 0.15)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.azul.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Anillo de progreso circular
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 5,
                              backgroundColor: colors.bordeSuave,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress == 1.0 ? Colors.green : colors.azul,
                              ),
                            ),
                          ),
                          Text(
                            "${(progress * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colors.azulOscuro,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Información del Turno
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Progreso del Turno",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colors.azulOscuro,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _inicioTurno != null ? Colors.green.withValues(alpha: 0.15) : colors.superficieSuave,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: _inicioTurno != null ? Colors.green : colors.bordeSuave),
                                  ),
                                  child: Text(
                                    _inicioTurno != null ? "TURNO EN VIVO 🟢" : "INACTIVO ⚪",
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: _inicioTurno != null ? Colors.green.shade800 : colors.grisTexto,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$completedItems de $totalItems tareas de control completadas",
                              style: TextStyle(fontSize: 12, color: colors.grisTexto),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Botones de acción del Turno
                  Row(
                    children: [
                      if (_inicioTurno == null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _iniciarTurno,
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: const Text("Iniciar Nuevo Turno"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.azul,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _finalizarTurno,
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text("Finalizar y Archivar Turno"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // TAB BAR CATEGORIZADO POR FASES DE TURNO
          Container(
            color: colors.superficie,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: colors.azul,
              labelColor: colors.azul,
              unselectedLabelColor: colors.grisTexto,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: List.generate(_phases.length, (phaseIdx) {
                final p = _phases[phaseIdx];
                final phaseItems = _checklistItems.where((it) => it['phase'] == phaseIdx).toList();
                final doneCount = phaseItems.where((it) => _checklistValues[it['id']]).length;
                final bool allDone = doneCount == phaseItems.length && phaseItems.isNotEmpty;

                return Tab(
                  child: Row(
                    children: [
                      Icon(p['icon'] as IconData, size: 16, color: allDone ? Colors.green : p['color'] as Color),
                      const SizedBox(width: 6),
                      Text(p['title'] as String),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: allDone ? Colors.green.withValues(alpha: 0.15) : (p['color'] as Color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$doneCount/${phaseItems.length}",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: allDone ? Colors.green : p['color'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // LISTA DE PASOS CON TARJETAS EXPANDIBLES
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_phases.length, (phaseIdx) {
                final items = _checklistItems.where((it) => it['phase'] == phaseIdx).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: items.length,
                  itemBuilder: (ctx, idx) {
                    final item = items[idx];
                    final itemId = item['id'] as int;
                    final isChecked = _checklistValues[itemId];
                    final isExpanded = _expandedTaskId == itemId;
                    final Color pColor = _phases[phaseIdx]['color'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isChecked ? Colors.green.withValues(alpha: 0.04) : colors.superficie,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isChecked ? Colors.green.withValues(alpha: 0.4) : colors.bordeSuave,
                          width: isChecked ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.01),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header del Item del Paso
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                _expandedTaskId = isExpanded ? null : itemId;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  // Checkbox interactivo
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _checklistValues[itemId] = !_checklistValues[itemId];
                                      });
                                      _guardarEstado();
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: isChecked ? Colors.green : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isChecked ? Colors.green : colors.grisSecundario,
                                          width: 2,
                                        ),
                                      ),
                                      child: isChecked
                                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Ícono del Paso
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: pColor.withValues(alpha: 0.12),
                                    child: Icon(item['icon'] as IconData, size: 16, color: pColor),
                                  ),
                                  const SizedBox(width: 10),

                                  // Título del Paso
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Paso ${idx + 1}: ${item['title']}",
                                          style: TextStyle(
                                            color: isChecked ? colors.azulOscuro : colors.azulOscuro,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                            decoration: isChecked ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: colors.grisSecundario,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Guía Expandida del Paso
                          if (isExpanded)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                              decoration: BoxDecoration(
                                color: colors.superficieSuave.withValues(alpha: 0.5),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 14),
                                  Text(
                                    item['desc'].toString(),
                                    style: TextStyle(color: colors.grisTexto, fontSize: 12.5, height: 1.4),
                                  ),
                                  const SizedBox(height: 10),

                                  // Consejo Crítico
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.amber.shade600.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("💡", style: TextStyle(fontSize: 14)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            item['tip'].toString(),
                                            style: TextStyle(color: colors.azulOscuro, fontSize: 11.5, height: 1.35),
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
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _borrarHistorialTurnos() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever_outlined, color: Colors.red),
            SizedBox(width: 8),
            Text("¿Borrar Historial?"),
          ],
        ),
        content: Text("Esta acción eliminará de forma permanente todo el historial de turnos archivados para '${widget.perfilActivo}'."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Borrar Definitivamente"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      final prefix = "checklist_${widget.perfilActivo}_";
      await prefs.remove("${prefix}historial");
      setState(() {
        _historialTurnos.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Historial de turnos eliminado con éxito.")),
        );
      }
    }
  }

  Future<void> _reiniciarChecklist() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.orange),
            SizedBox(width: 8),
            Text("Reiniciar Tareas"),
          ],
        ),
        content: const Text("¿Deseas desmarcar todas las tareas del paso a paso del turno actual para comenzar de nuevo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
            child: const Text("Reiniciar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _checklistValues = List.filled(_checklistItems.length, false);
        _inicioTurno = null;
      });
      await _guardarEstado();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🔄 Paso a paso del turno reiniciado.")),
        );
      }
    }
  }

  void _mostrarModalHistorial(BuildContext context) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.superficie,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: colors.azul),
                      const SizedBox(width: 8),
                      Text(
                        "Historial de Turnos Archivados",
                        style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  if (_historialTurnos.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _borrarHistorialTurnos();
                      },
                      icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: Colors.red),
                      label: const Text("Borrar Todo", style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_historialTurnos.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text("Aún no has archivado ningún turno en este perfil.", style: TextStyle(color: colors.grisTexto, fontSize: 13)),
                  ),
                )
              else
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    itemCount: _historialTurnos.length,
                    itemBuilder: (c, i) {
                      final h = _historialTurnos[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.superficieSuave,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.bordeSuave),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(h['fecha'].toString(), style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 12.5)),
                                Text("Duración: ${h['duracion']}", style: TextStyle(color: colors.grisTexto, fontSize: 11)),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                  child: Text(h['completado'].toString(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                  tooltip: "Borrar registro",
                                  onPressed: () async {
                                    setState(() {
                                      _historialTurnos.removeAt(i);
                                    });
                                    setModalState(() {});
                                    final prefs = await SharedPreferences.getInstance();
                                    final prefix = "checklist_${widget.perfilActivo}_";
                                    final raw = _historialTurnos.map((item) => "${item['fecha']}|${item['completado']}|${item['duracion']}").toList();
                                    await prefs.setStringList("${prefix}historial", raw);
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
