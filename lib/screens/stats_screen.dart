import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/services/stats_service.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;

  const StatsScreen({
    super.key,
    required this.onNavigate,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _historial = [];
  List<Map<String, dynamic>> _historialTurnos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _isLoading = true;
    });
    final data = await StatsService.obtenerHistorial();
    
    final prefs = await SharedPreferences.getInstance();
    final perfil = prefs.getString('perfil_activo') ?? 'Usuario Principal';
    final List<Map<String, dynamic>> histTurnos = [];

    // 1. Cargar desde checklist_${perfil}_historial (formato primario de checklist_screen)
    final checklistRaw = prefs.getStringList('checklist_${perfil}_historial');
    if (checklistRaw != null && checklistRaw.isNotEmpty) {
      for (final item in checklistRaw) {
        final parts = item.split('|');
        if (parts.isNotEmpty) {
          final fecha = parts[0];
          final compStr = parts.length > 1 ? parts[1] : "100%";
          final duracion = parts.length > 2 ? parts[2] : "Turno";
          final numMatch = RegExp(r'(\d+(\.\d+)?)').firstMatch(compStr);
          final pct = numMatch != null ? (double.tryParse(numMatch.group(1)!) ?? 100.0) : 100.0;
          histTurnos.add({
            'inicio': "Duración: $duracion",
            'cierre': fecha,
            'porcentaje': pct,
          });
        }
      }
    } else {
      // 2. Fallback: formato legacy '${perfil}_historial_turnos'
      final histJson = prefs.getString('${perfil}_historial_turnos');
      if (histJson != null) {
        try {
          final decoded = (histJson.split('||')).where((s) => s.isNotEmpty);
          for (final entry in decoded) {
            final parts = entry.split('|');
            if (parts.length >= 3) {
              histTurnos.add({
                'inicio': parts[0],
                'cierre': parts[1],
                'porcentaje': double.tryParse(parts[2]) ?? 0.0,
              });
            }
          }
        } catch (_) {}
      }
    }

    if (!mounted) return;
    setState(() {
      _historial = data;
      _historialTurnos = histTurnos;
      _isLoading = false;
    });
  }

  Future<void> _confirmarLimpiar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Limpiar Historial?"),
        content: const Text("Esta acción borrará permanentemente todo tu historial de entrenamiento diamantino."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Borrar Todo"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StatsService.limpiarHistorial();
      final prefs = await SharedPreferences.getInstance();
      final perfil = prefs.getString('perfil_activo') ?? 'Usuario Principal';
      await prefs.remove('${perfil}_historial_turnos');
      await prefs.remove('checklist_${perfil}_historial');
      await _cargarHistorial();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Historial de estadísticas borrado")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // Calculate metrics
    final totalSesiones = _historial.length;
    double promedioAciertos = 0;
    int totalAciertos = 0;
    int totalPreguntas = 0;

    for (var item in _historial) {
      final aciertos = item['aciertos'] as int? ?? 0;
      final total = item['total'] as int? ?? 0;
      totalAciertos += aciertos;
      totalPreguntas += total;
    }

    if (totalPreguntas > 0) {
      promedioAciertos = (totalAciertos / totalPreguntas) * 100;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.fondo,
      appBar: AppBar(
        backgroundColor: colors.superficie,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: colors.azulOscuro),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          "Rendimiento Operacional",
          style: TextStyle(
            color: colors.azulOscuro,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_historial.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              tooltip: "Borrar estadísticas",
              onPressed: _confirmarLimpiar,
            ),
          IconButton(
            icon: Icon(Icons.home_outlined, color: colors.azulOscuro),
            tooltip: "Volver al Inicio",
            onPressed: () => widget.onNavigate('home'),
          ),
        ],
      ),
      drawer: DrawerMenu(
        onNavigate: widget.onNavigate,
        modoOscuro: widget.modoOscuro,
        onToggleModoOscuro: widget.onToggleModoOscuro,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_historial.isEmpty && _historialTurnos.isEmpty)
              ? _buildEmptyState(colors)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPI Summary row
                      Row(
                        children: [
                          Expanded(
                            child: _buildKPICard(
                              title: "Sesiones",
                              value: "$totalSesiones",
                              icon: Icons.assignment_outlined,
                              colors: colors,
                              colorText: colors.azul,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildKPICard(
                              title: "Acierto Prom.",
                              value: "${promedioAciertos.toStringAsFixed(1)}%",
                              icon: Icons.analytics_outlined,
                              colors: colors,
                              colorText: promedioAciertos >= 80
                                  ? colors.verde
                                  : promedioAciertos >= 60
                                      ? colors.naranjo
                                      : colors.rojo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildKPICard(
                              title: "Turnos Registrados",
                              value: "${_historialTurnos.length}",
                              icon: Icons.history_toggle_off,
                              colors: colors,
                              colorText: colors.azul,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildKPICard(
                              title: "Turnos Completos",
                              value: "${_historialTurnos.where((t) => (t['porcentaje'] as double? ?? 0.0) >= 100).length}",
                              icon: Icons.check_circle_outline,
                              colors: colors,
                              colorText: colors.verde,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Chart Card
                      if (_historial.isNotEmpty) ...[
                        Card(
                          color: colors.superficie,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: colors.bordeSuave, width: 1.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Curva de Aprendizaje (Últimas sesiones)",
                                  style: TextStyle(
                                    color: colors.azulOscuro,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 160,
                                  width: double.infinity,
                                  child: CustomPaint(
                                    painter: _LearningCurvePainter(
                                      colors: colors,
                                      data: _historial.map((e) {
                                        final a = e['aciertos'] as int? ?? 0;
                                        final t = e['total'] as int? ?? 1;
                                        return (a / t) * 100;
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Historial de Actividades",
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _historial.length,
                          itemBuilder: (context, index) {
                            final item = _historial[_historial.length - 1 - index];
                            final fecha = DateTime.tryParse(item['fecha'] ?? '') ?? DateTime.now();
                            final aciertos = item['aciertos'] as int? ?? 0;
                            final total = item['total'] as int? ?? 0;
                            final modo = item['modo'] as String? ?? 'Ejercicio';
                            final pct = total > 0 ? (aciertos / total) * 100 : 0.0;
                            final tiempoSegs = item['tiempoSegundos'] as int? ?? 0;
                            final min = tiempoSegs ~/ 60;
                            final segs = tiempoSegs % 60;

                            return Card(
                              color: colors.superficie,
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: colors.bordeSuave, width: 1),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: pct >= 80
                                      ? colors.verde.withValues(alpha: 0.1)
                                      : pct >= 60
                                          ? colors.naranjo.withValues(alpha: 0.1)
                                          : colors.rojo.withValues(alpha: 0.1),
                                  child: Icon(
                                    pct >= 80 ? Icons.check_circle_outline : Icons.error_outline,
                                    color: pct >= 80
                                        ? colors.verde
                                        : pct >= 60
                                            ? colors.naranjo
                                            : colors.rojo,
                                  ),
                                ),
                                title: Text(
                                  modo,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colors.azulOscuro,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  "${fecha.day}/${fecha.month}/${fecha.year} • Duración: ${min}m ${segs}s",
                                  style: TextStyle(color: colors.grisTexto, fontSize: 12),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "$aciertos/$total",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colors.azulOscuro,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "${pct.toStringAsFixed(0)}%",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: pct >= 80
                                            ? colors.verde
                                            : pct >= 60
                                                ? colors.naranjo
                                                : colors.rojo,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      if (_historialTurnos.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          "Historial de Turnos de Control (Checklist)",
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _historialTurnos.length,
                          itemBuilder: (context, index) {
                            final item = _historialTurnos[index];
                            final double pct = item['porcentaje'] as double? ?? 0.0;
                            final isComplete = pct >= 100;
                            return Card(
                              color: colors.superficie,
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: colors.bordeSuave, width: 1),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isComplete
                                      ? colors.verde.withValues(alpha: 0.1)
                                      : colors.naranjo.withValues(alpha: 0.1),
                                  child: Icon(
                                    isComplete ? Icons.check_circle : Icons.warning_amber_rounded,
                                    color: isComplete ? colors.verde : colors.naranjo,
                                  ),
                                ),
                                title: Text(
                                  "Turno #${_historialTurnos.length - index}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colors.azulOscuro,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text("Inicio: ${item['inicio']}", style: TextStyle(color: colors.grisTexto, fontSize: 11)),
                                    Text("Cierre: ${item['cierre']}", style: TextStyle(color: colors.grisTexto, fontSize: 11)),
                                  ],
                                ),
                                trailing: Text(
                                  "${pct.toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isComplete ? colors.verde : colors.naranjo,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required AppColors colors,
    required Color colorText,
  }) {
    return Card(
      color: colors.superficie,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.bordeSuave, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: colors.azul, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: colors.grisTexto, fontSize: 12), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.query_stats_outlined, size: 80, color: colors.grisTexto.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              "Sin Historial Aún",
              style: TextStyle(color: colors.azulOscuro, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Completa rondas de ejercicios diamantinos o llena el cuaderno de terreno para ver tus estadísticas y curvas de aprendizaje.",
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.grisTexto, fontSize: 13.5, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningCurvePainter extends CustomPainter {
  final AppColors colors;
  final List<double> data;

  _LearningCurvePainter({required this.colors, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Use at most the last 10 sessions to keep graph clean
    final graphData = data.length > 10 ? data.sublist(data.length - 10) : data;

    final linePaint = Paint()
      ..color = colors.azul
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = colors.azulOscuro
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = colors.bordeSuave.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = size.height * (1 - i / gridLines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      
      // Draw labels (100%, 75%, etc.)
      final textSpan = TextSpan(
        text: "${(i * 100 ~/ gridLines)}%",
        style: TextStyle(color: colors.grisTexto.withValues(alpha: 0.8), fontSize: 8),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      final labelY = (y - 10).clamp(0.0, size.height - 12.0);
      textPainter.paint(canvas, Offset(4, labelY));
    }

    final int pointsCount = graphData.length;
    if (pointsCount == 1) {
      // Single point
      final double y = size.height * (1 - graphData[0] / 100);
      canvas.drawCircle(Offset(size.width / 2, y), 5, pointPaint);
      return;
    }

    final double stepX = size.width / (pointsCount - 1);
    final List<Offset> points = [];

    for (int i = 0; i < pointsCount; i++) {
      final double x = i * stepX;
      final double y = size.height * (1 - graphData[i] / 100);
      points.add(Offset(x, y));
    }

    // Draw path line
    final Path path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < pointsCount; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw point circles
    for (var pt in points) {
      canvas.drawCircle(pt, 4.5, pointPaint);
      // Outer border circle for high visibility
      canvas.drawCircle(
        pt,
        6,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LearningCurvePainter oldDelegate) {
    if (data.length != oldDelegate.data.length || colors.isDark != oldDelegate.colors.isDark) {
      return true;
    }
    for (int i = 0; i < data.length; i++) {
      if (data[i] != oldDelegate.data[i]) return true;
    }
    return false;
  }
}
