import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/services/stats_service.dart';

class InstructorPanelScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;

  const InstructorPanelScreen({
    super.key,
    required this.onNavigate,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
  });

  @override
  State<InstructorPanelScreen> createState() => _InstructorPanelScreenState();
}

class _OperadorStats {
  final String nombre;
  final int totalSesiones;
  final int aciertosTotales;
  final int preguntasTotales;
  final double precisionPromedio;
  final String estadoCuaderno;

  _OperadorStats({
    required this.nombre,
    required this.totalSesiones,
    required this.aciertosTotales,
    required this.preguntasTotales,
    required this.precisionPromedio,
    required this.estadoCuaderno,
  });
}

class _InstructorPanelScreenState extends State<InstructorPanelScreen> {
  bool _cargando = true;
  bool _autenticado = false;
  List<_OperadorStats> _ranking = [];
  double _precisionGrupo = 0;
  int _cuadernosCompletadosGrupo = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pedirPin();
    });
  }

  Future<void> _pedirPin() async {
    final controller = TextEditingController();
    bool pinCorrecto = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text("Acceso Instructor"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ingresa el PIN de supervisión para acceder al Panel de Instructor (PIN por defecto: 9900):",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "PIN (ej. 9900)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onNavigate('home');
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final esValido = await StatsService.validarPinSupervisor(controller.text);
              if (esValido) {
                pinCorrecto = true;
                if (ctx.mounted) Navigator.pop(ctx);
              } else {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text("❌ PIN incorrecto. Intenta nuevamente.")),
                  );
                }
              }
            },
            child: const Text("Ingresar"),
          ),
        ],
      ),
    );

    if (pinCorrecto) {
      setState(() {
        _autenticado = true;
      });
      _cargarDatosGrupales();
    }
  }

  Future<void> _cargarDatosGrupales() async {
    setState(() {
      _cargando = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final perfiles = prefs.getStringList('perfiles_lista') ?? ['Usuario Principal'];

    final List<_OperadorStats> listaStats = [];
    int sumaPreguntasGrupo = 0;
    int sumaAciertosGrupo = 0;
    int completadosCount = 0;

    for (final perfil in perfiles) {
      final historial = await StatsService.obtenerHistorialPorPerfil(perfil);
      
      int aciertos = 0;
      int preguntas = 0;
      for (final sesion in historial) {
        aciertos += (sesion['aciertos'] as int? ?? 0);
        preguntas += (sesion['total'] as int? ?? 0);
      }

      final double precision = preguntas > 0 ? (aciertos / preguntas) * 100 : 0.0;

      // Check notebook state for this profile
      final cuadernoState = prefs.getString('cuaderno_state_$perfil');
      String estadoCuaderno = "Sin iniciar";
      if (cuadernoState != null) {
        if (cuadernoState.contains('"pantalla":"resultado"') || cuadernoState.contains('"resultado"')) {
          estadoCuaderno = "Completado 🏆";
          completadosCount++;
        } else {
          estadoCuaderno = "En progreso ⏳";
        }
      }

      sumaPreguntasGrupo += preguntas;
      sumaAciertosGrupo += aciertos;

      listaStats.add(_OperadorStats(
        nombre: perfil,
        totalSesiones: historial.length,
        aciertosTotales: aciertos,
        preguntasTotales: preguntas,
        precisionPromedio: precision,
        estadoCuaderno: estadoCuaderno,
      ));
    }

    // Sort leaderboard by precision descending
    listaStats.sort((a, b) => b.precisionPromedio.compareTo(a.precisionPromedio));

    setState(() {
      _ranking = listaStats;
      _precisionGrupo = sumaPreguntasGrupo > 0 ? (sumaAciertosGrupo / sumaPreguntasGrupo) * 100 : 0.0;
      _cuadernosCompletadosGrupo = completadosCount;
      _cargando = false;
    });
  }

  Future<void> _eliminarHistorialOperador(String perfil) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("¿Reiniciar alumno $perfil?"),
        content: Text("Se eliminará permanentemente el historial de ejercicios registrados para el operador $perfil."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Sí, reiniciar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StatsService.limpiarHistorialPorPerfil(perfil);
      await _cargarDatosGrupales();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Historial de $perfil reiniciado correctamente.")),
        );
      }
    }
  }

  void _exportarReporteGrupal() {
    final buffer = StringBuffer();
    buffer.writeln("=== REPORTE CONSOLIDADO DE INSTRUCCIÓN DE SONDAJE ===");
    buffer.writeln("Fecha: ${DateTime.now().toString().substring(0, 10)}");
    buffer.writeln("Total Operadores: ${_ranking.length}");
    buffer.writeln("Precisión Grupal: ${_precisionGrupo.toStringAsFixed(1)}%");
    buffer.writeln("Cuadernos Completados: $_cuadernosCompletadosGrupo");
    buffer.writeln("----------------------------------------------------");
    buffer.writeln("Lugar\tOperador\tPrecisión\tSesiones\tEstado Cuaderno");

    for (int i = 0; i < _ranking.length; i++) {
      final op = _ranking[i];
      buffer.writeln("${i + 1}\t${op.nombre}\t${op.precisionPromedio.toStringAsFixed(1)}%\t${op.totalSesiones}\t${op.estadoCuaderno}");
    }
    buffer.writeln("----------------------------------------------------");
    buffer.writeln("Generado automáticamente por la App Aprender a Controlar.");

    Share.share(buffer.toString());
  }

  Future<void> _mostrarDialogoCambiarPin() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cambiar PIN de Supervisión"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: "Nuevo PIN simple (ej. 9900)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await StatsService.cambiarPinSupervisor(controller.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ PIN de supervisión actualizado exitosamente.")),
                  );
                }
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.fondo,
      appBar: AppBar(
        backgroundColor: colors.superficie,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.azulOscuro),
          onPressed: () => widget.onNavigate('home'),
        ),
        title: Text(
          "Panel del Instructor 👥",
          style: TextStyle(
            color: colors.azulOscuro,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: "Cambiar PIN",
            onPressed: _mostrarDialogoCambiarPin,
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: "Volver al Inicio",
            onPressed: () => widget.onNavigate('home'),
          ),
        ],
      ),
      body: !_autenticado
          ? const SizedBox()
          : _cargando
              ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          "Operadores",
                          "${_ranking.length}",
                          Icons.people_outline,
                          colors.azul,
                          colors,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildKpiCard(
                          "Promedio Grupo",
                          "${_precisionGrupo.toStringAsFixed(1)}%",
                          Icons.insights,
                          colors.verde,
                          colors,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildKpiCard(
                          "Cuadernos",
                          "$_cuadernosCompletadosGrupo",
                          Icons.menu_book,
                          colors.naranjo,
                          colors,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Leaderboard Title
                  Text(
                    "Tabla de Rendimiento del Equipo",
                    style: TextStyle(
                      color: colors.azulOscuro,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Leaderboard Cards List
                  ..._ranking.asMap().entries.map((entry) {
                    final index = entry.key;
                    final op = entry.value;

                    String medal = "#${index + 1}";
                    if (index == 0) medal = "🥇";
                    if (index == 1) medal = "🥈";
                    if (index == 2) medal = "🥉";

                    return Card(
                      color: colors.superficie,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colors.bordeSuave, width: 1.2),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.azulClaro,
                          child: Text(
                            medal,
                            style: TextStyle(
                              fontSize: index < 3 ? 18 : 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          op.nombre,
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          "Sesiones: ${op.totalSesiones}  •  Cuaderno: ${op.estadoCuaderno}",
                          style: TextStyle(color: colors.grisTexto, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${op.precisionPromedio.toStringAsFixed(0)}%",
                              style: TextStyle(
                                color: op.precisionPromedio >= 80
                                    ? colors.verde
                                    : op.precisionPromedio >= 50
                                        ? colors.naranjo
                                        : colors.rojo,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                              tooltip: "Reiniciar operador",
                              onPressed: () => _eliminarHistorialOperador(op.nombre),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _exportarReporteGrupal,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.azul, width: 1.5),
                        foregroundColor: colors.azul,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.copy_all),
                      label: const Text(
                        "Copiar Reporte Grupal (CSV/Texto)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colors.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.bordeSuave, width: 1.2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colors.azulOscuro,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: colors.grisTexto, fontSize: 10.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
