import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';

class RecordatoriosScreen extends StatefulWidget {
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;
  final Function(String) onNavigate;
  final String perfilActivo;

  const RecordatoriosScreen({
    super.key,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
    required this.onNavigate,
    required this.perfilActivo,
  });

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;
  Timer? _countdownTimer;

  List<Map<String, dynamic>> _recordatorios = [];
  List<Map<String, dynamic>> _presets = [];
  bool _loading = true;

  // Plantillas por defecto si el perfil es nuevo
  final List<Map<String, dynamic>> _defaultPresets = [
    {
      "id": "p1",
      "titulo": "Enviar reporte de las 14:00",
      "categoria": "Reportes",
      "minutos": 60,
      "prioridad": "Alta",
    },
    {
      "id": "p2",
      "titulo": "Contar bandejas con muestra en plataforma",
      "categoria": "Muestras",
      "minutos": 30,
      "prioridad": "Alta",
    },
    {
      "id": "p3",
      "titulo": "Verificar retorno de agua de perforación",
      "categoria": "Fluidos",
      "minutos": 15,
      "prioridad": "Media",
    },
    {
      "id": "p4",
      "titulo": "Fotografiar cajas porta-testigos",
      "categoria": "Muestras",
      "minutos": 45,
      "prioridad": "Media",
    },
    {
      "id": "p5",
      "titulo": "Charla de 5 min de seguridad",
      "categoria": "Seguridad",
      "minutos": 120,
      "prioridad": "Alta",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatosPerfil();
    _iniciarReloj();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _iniciarReloj() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final ahora = DateTime.now();
      bool hayAlarmasSonando = false;

      setState(() {
        for (var r in _recordatorios) {
          if (r['completado'] == false && r['disparado'] == false) {
            final targetMs = r['targetTime'] as int;
            final diff = targetMs - ahora.millisecondsSinceEpoch;
            if (diff <= 0) {
              r['disparado'] = true;
              hayAlarmasSonando = true;
            }
          }
        }
      });

      if (hayAlarmasSonando) {
        _comprobarAlarmasSonando();
        _guardarDatosPerfil();
      }
    });
  }

  void _comprobarAlarmasSonando() {
    final sonando = _recordatorios.where((r) => r['disparado'] == true && r['completado'] == false).toList();
    if (sonando.isNotEmpty) {
      _mostrarModalAlarmaActiva(sonando.first);
    }
  }

  Future<void> _cargarDatosPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = "recordatorios_${widget.perfilActivo}_";

    // Cargar alarmas
    final rawList = prefs.getString("${prefix}lista");
    if (rawList != null) {
      final List<dynamic> decoded = jsonDecode(rawList);
      _recordatorios = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else {
      _recordatorios = [];
    }

    // Cargar plantillas
    final rawPresets = prefs.getString("${prefix}presets");
    if (rawPresets != null) {
      final List<dynamic> decodedP = jsonDecode(rawPresets);
      _presets = decodedP.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else {
      _presets = List.from(_defaultPresets);
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _guardarDatosPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = "recordatorios_${widget.perfilActivo}_";
    
    await prefs.setString("${prefix}lista", jsonEncode(_recordatorios));
    await prefs.setString("${prefix}presets", jsonEncode(_presets));
  }

  void _crearPresetDesdePlantilla(Map<String, dynamic> preset) {
    final target = DateTime.now().add(Duration(minutes: preset['minutos'] as int));
    final nuevo = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "titulo": preset['titulo'],
      "categoria": preset['categoria'],
      "prioridad": preset['prioridad'],
      "targetTime": target.millisecondsSinceEpoch,
      "modoProg": "minutos",
      "minutosProgramados": preset['minutos'],
      "horaExactaStr": _formatHora(target),
      "repeticion": "none", // Una sola vez
      "completado": false,
      "disparado": false,
      "notas": "Alarma activada desde la plantilla de ${widget.perfilActivo}.",
    };

    setState(() {
      _recordatorios.insert(0, nuevo);
    });
    _guardarDatosPerfil();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("⏰ Alarma creada: '${preset['titulo']}' para las ${_formatHora(target)}"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _dialogoCrearOEditarPreset({Map<String, dynamic>? presetExistente, int? index}) {
    final tituloCtrl = TextEditingController(text: presetExistente?['titulo'] ?? "");
    String categoria = presetExistente?['categoria'] ?? "Reportes";
    String prioridad = presetExistente?['prioridad'] ?? "Alta";
    int minutos = presetExistente?['minutos'] ?? 30;
    final customMinCtrl = TextEditingController();
    bool esMinutoPersonalizado = ![5, 10, 15, 30, 45, 60, 120].contains(minutos);
    if (esMinutoPersonalizado) customMinCtrl.text = minutos.toString();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final colors = AppColors.of(context);
          return AlertDialog(
            backgroundColor: colors.superficie,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                Icon(presetExistente == null ? Icons.playlist_add : Icons.edit, color: colors.azul),
                const SizedBox(width: 8),
                Text(
                  presetExistente == null ? "Nueva Plantilla Rápida" : "Editar Plantilla Rápida",
                  style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: tituloCtrl,
                    decoration: InputDecoration(
                      labelText: "Nombre de la Plantilla",
                      hintText: "Ej: Enviar reporte de 14:00, Medir agua...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: categoria,
                          dropdownColor: colors.superficie,
                          borderRadius: BorderRadius.circular(16),
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
                          elevation: 8,
                          style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(labelText: "Categoría", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          items: ["Reportes", "Muestras", "Fluidos", "Seguridad", "General"]
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setModalState(() => categoria = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: prioridad,
                          dropdownColor: colors.superficie,
                          borderRadius: BorderRadius.circular(16),
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
                          elevation: 8,
                          style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(labelText: "Prioridad", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          items: ["Alta", "Media", "Normal"]
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (v) => setModalState(() => prioridad = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text("Minutos predeterminados:", style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ...[5, 10, 15, 30, 45, 60, 120].map((m) {
                        final sel = !esMinutoPersonalizado && minutos == m;
                        return ChoiceChip(
                          label: Text("$m m"),
                          selected: sel,
                          selectedColor: colors.azul,
                          labelStyle: TextStyle(color: sel ? Colors.white : colors.azulOscuro, fontSize: 11),
                          onSelected: (s) => setModalState(() {
                            minutos = m;
                            esMinutoPersonalizado = false;
                          }),
                        );
                      }),
                      ChoiceChip(
                        label: Text(esMinutoPersonalizado ? "✏️ $minutos m" : "➕ Personalizado"),
                        selected: esMinutoPersonalizado,
                        selectedColor: colors.azul,
                        labelStyle: TextStyle(color: esMinutoPersonalizado ? Colors.white : colors.azulOscuro, fontSize: 11),
                        onSelected: (s) => setModalState(() => esMinutoPersonalizado = true),
                      ),
                    ],
                  ),
                  if (esMinutoPersonalizado) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: customMinCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Ingresa minutos exactos",
                        hintText: "Ej: 27, 90, 180...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null && parsed > 0) {
                          setModalState(() => minutos = parsed);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (presetExistente != null && index != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _presets.removeAt(index);
                    });
                    _guardarDatosPerfil();
                    Navigator.pop(ctx);
                  },
                  child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (tituloCtrl.text.trim().isEmpty) return;
                  if (esMinutoPersonalizado) {
                    final parsed = int.tryParse(customMinCtrl.text.trim());
                    if (parsed != null && parsed > 0) minutos = parsed;
                  }

                  final itemData = {
                    "id": presetExistente?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    "titulo": tituloCtrl.text.trim(),
                    "categoria": categoria,
                    "prioridad": prioridad,
                    "minutos": minutos,
                  };

                  setState(() {
                    if (presetExistente != null && index != null) {
                      _presets[index] = itemData;
                    } else {
                      _presets.add(itemData);
                    }
                  });
                  _guardarDatosPerfil();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: colors.azul, foregroundColor: Colors.white),
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _crearPersonalizado() {
    final tituloCtrl = TextEditingController();
    final notasCtrl = TextEditingController();
    final customMinCtrl = TextEditingController();
    
    String categoria = "Reportes";
    String prioridad = "Alta";
    
    // Modo de programación: 0 = Minutos, 1 = Hora Fija
    int modoProgramacion = 0; 
    int minutos = 15;
    bool esMinutoPersonalizado = false;

    // Hora fija seleccionada (por defecto la hora actual + 1 hora)
    TimeOfDay horaFija = TimeOfDay(hour: (DateTime.now().hour + 1) % 24, minute: 0);

    // Repetición: "none" (una vez), "daily" (diario), "weekdays" (Lun-Vie)
    String repeticion = "none";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).superficie,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final colors = AppColors.of(context);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_alarm, color: colors.azul),
                      const SizedBox(width: 8),
                      Text("Nueva Alarma (${widget.perfilActivo})", style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: tituloCtrl,
                    decoration: InputDecoration(
                      labelText: "Asunto / Tarea de Terreno",
                      hintText: "Ej: Enviar reporte de 14:00, Contar bandejas...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: categoria,
                          dropdownColor: colors.superficie,
                          borderRadius: BorderRadius.circular(16),
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
                          elevation: 8,
                          style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(labelText: "Categoría", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          items: ["Reportes", "Muestras", "Fluidos", "Seguridad", "General"]
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setModalState(() => categoria = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: prioridad,
                          dropdownColor: colors.superficie,
                          borderRadius: BorderRadius.circular(16),
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
                          elevation: 8,
                          style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(labelText: "Prioridad", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          items: ["Alta", "Media", "Normal"]
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (v) => setModalState(() => prioridad = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // SELECTOR DE MODO DE PROGRAMACIÓN (MINUTOS VS HORA FIJA)
                  Text("Modo de Programación:", style: TextStyle(color: colors.azulOscuro, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    height: 38,
                    decoration: BoxDecoration(color: colors.superficieSuave, borderRadius: BorderRadius.circular(10), border: Border.all(color: colors.bordeSuave)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => modoProgramacion = 0),
                            child: Container(
                              decoration: BoxDecoration(color: modoProgramacion == 0 ? colors.azul : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                              alignment: Alignment.center,
                              child: Text("⏱️ Por Minutos", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: modoProgramacion == 0 ? Colors.white : colors.grisTexto)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => modoProgramacion = 1),
                            child: Container(
                              decoration: BoxDecoration(color: modoProgramacion == 1 ? colors.azul : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                              alignment: Alignment.center,
                              child: Text("🕒 Por Hora Fija (14:00)", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: modoProgramacion == 1 ? Colors.white : colors.grisTexto)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (modoProgramacion == 0) ...[
                    // PROGRAMAR POR MINUTOS
                    Text("Programar dentro de:", style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ...[5, 10, 15, 30, 45, 60, 120].map((m) {
                          final sel = !esMinutoPersonalizado && minutos == m;
                          return ChoiceChip(
                            label: Text("$m min"),
                            selected: sel,
                            selectedColor: colors.azul,
                            labelStyle: TextStyle(color: sel ? Colors.white : colors.azulOscuro, fontSize: 11),
                            onSelected: (s) => setModalState(() {
                              minutos = m;
                              esMinutoPersonalizado = false;
                            }),
                          );
                        }),
                        ChoiceChip(
                          label: Text(esMinutoPersonalizado ? "✏️ $minutos m" : "➕ Personalizado"),
                          selected: esMinutoPersonalizado,
                          selectedColor: colors.azul,
                          labelStyle: TextStyle(color: esMinutoPersonalizado ? Colors.white : colors.azulOscuro, fontSize: 11),
                          onSelected: (s) => setModalState(() => esMinutoPersonalizado = true),
                        ),
                      ],
                    ),
                    if (esMinutoPersonalizado) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: customMinCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Ingresa minutos exactos (ej: 27, 90...)",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed != null && parsed > 0) {
                            setModalState(() => minutos = parsed);
                          }
                        },
                      ),
                    ],
                  ] else ...[
                    // PROGRAMAR POR HORA FIJA EXACTA (ej: 14:00)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: colors.superficieSuave, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.bordeSuave)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Hora exacta de alarma:", style: TextStyle(color: colors.grisTexto, fontSize: 11)),
                              Text(
                                "${horaFija.hour.toString().padLeft(2, '0')}:${horaFija.minute.toString().padLeft(2, '0')} hrs",
                                style: TextStyle(color: colors.azul, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(context: context, initialTime: horaFija);
                              if (picked != null) {
                                setModalState(() => horaFija = picked);
                              }
                            },
                            icon: const Icon(Icons.access_time, size: 16),
                            label: const Text("Cambiar Hora"),
                            style: ElevatedButton.styleFrom(backgroundColor: colors.azul, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // REPETICIÓN RECURRENTE (REPLICAR VARIOS DÍAS)
                  Text("Repetir Alarma (Replicar días):", style: TextStyle(color: colors.azulOscuro, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: repeticion,
                    dropdownColor: colors.superficie,
                    borderRadius: BorderRadius.circular(16),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
                    elevation: 8,
                    style: TextStyle(color: colors.azulOscuro, fontSize: 12.5, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colors.superficieSuave,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.bordeSuave)),
                    ),
                    items: const [
                      DropdownMenuItem(value: "none", child: Text("Una sola vez (Solo hoy)")),
                      DropdownMenuItem(value: "daily", child: Text("🔄 Todos los días (Diario)")),
                      DropdownMenuItem(value: "weekdays", child: Text("📅 Días hábiles (Lunes a Viernes)")),
                    ],
                    onChanged: (v) => setModalState(() => repeticion = v!),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: notasCtrl,
                    decoration: InputDecoration(
                      labelText: "Notas / Observaciones adicionales (Opcional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (tituloCtrl.text.trim().isEmpty) return;
                        
                        DateTime target;
                        if (modoProgramacion == 0) {
                          if (esMinutoPersonalizado) {
                            final parsed = int.tryParse(customMinCtrl.text.trim());
                            if (parsed != null && parsed > 0) minutos = parsed;
                          }
                          target = DateTime.now().add(Duration(minutes: minutos));
                        } else {
                          final ahora = DateTime.now();
                          target = DateTime(ahora.year, ahora.month, ahora.day, horaFija.hour, horaFija.minute);
                          if (target.isBefore(ahora)) {
                            target = target.add(const Duration(days: 1)); // Si la hora ya pasó hoy, se programa para mañana
                          }
                        }

                        final nuevo = {
                          "id": DateTime.now().millisecondsSinceEpoch.toString(),
                          "titulo": tituloCtrl.text.trim(),
                          "categoria": categoria,
                          "prioridad": prioridad,
                          "targetTime": target.millisecondsSinceEpoch,
                          "modoProg": modoProgramacion == 0 ? "minutos" : "hora",
                          "minutosProgramados": minutos,
                          "horaExactaStr": "${horaFija.hour.toString().padLeft(2, '0')}:${horaFija.minute.toString().padLeft(2, '0')}",
                          "repeticion": repeticion,
                          "completado": false,
                          "disparado": false,
                          "notas": notasCtrl.text.trim(),
                        };

                        setState(() {
                          _recordatorios.insert(0, nuevo);
                        });
                        _guardarDatosPerfil();
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.alarm_add),
                      label: const Text("Activar Alarma"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.azul,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _postergarAlarma(Map<String, dynamic> item, int minutos) {
    setState(() {
      item['targetTime'] = DateTime.now().add(Duration(minutes: minutos)).millisecondsSinceEpoch;
      item['disparado'] = false;
    });
    _guardarDatosPerfil();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("⏰ Alarma postergada $minutos minutos.")),
    );
  }

  void _marcarCompletado(Map<String, dynamic> item) {
    final rep = item['repeticion'] as String? ?? "none";
    
    if (rep != "none") {
      // Si la alarma es recurrente, se recalcula la siguiente aparición sin eliminarla
      DateTime siguiente;
      final ahora = DateTime.now();

      if (rep == "daily") {
        siguiente = ahora.add(const Duration(days: 1));
      } else if (rep == "weekdays") {
        siguiente = ahora.add(const Duration(days: 1));
        while (siguiente.weekday == DateTime.saturday || siguiente.weekday == DateTime.sunday) {
          siguiente = siguiente.add(const Duration(days: 1));
        }
      } else {
        siguiente = ahora.add(const Duration(days: 1));
      }

      // Si fue programada por hora fija, mantener la hora exacta
      if (item['modoProg'] == 'hora' && item['horaExactaStr'] != null) {
        final parts = (item['horaExactaStr'] as String).split(':');
        if (parts.length == 2) {
          final h = int.tryParse(parts[0]) ?? 14;
          final m = int.tryParse(parts[1]) ?? 0;
          siguiente = DateTime(siguiente.year, siguiente.month, siguiente.day, h, m);
        }
      }

      setState(() {
        item['targetTime'] = siguiente.millisecondsSinceEpoch;
        item['disparado'] = false;
        item['completado'] = false;
      });
      _guardarDatosPerfil();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🔄 Alarma programada para la siguiente fecha: ${_formatHora(siguiente)} (${_formatFecha(siguiente)})")),
      );
    } else {
      setState(() {
        item['completado'] = true;
        item['disparado'] = false;
      });
      _guardarDatosPerfil();
    }
  }

  void _eliminarRecordatorio(Map<String, dynamic> item) {
    setState(() {
      _recordatorios.removeWhere((r) => r['id'] == item['id']);
    });
    _guardarDatosPerfil();
  }

  void _mostrarModalAlarmaActiva(Map<String, dynamic> item) {
    final colors = AppColors.of(context);
    final repStr = _getRepeticionLabel(item['repeticion'] as String?);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.superficie,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.notifications_active, color: Colors.red, size: 40),
            ),
            const SizedBox(height: 12),
            Text("⏰ ¡ALARMA DE TERRENO!", style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item['titulo'].toString(),
              style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (item['notas'] != null && item['notas'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item['notas'].toString(),
                style: TextStyle(color: colors.grisTexto, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(
                "Perfil: ${widget.perfilActivo} | Cat: ${item['categoria']} | $repStr",
                style: TextStyle(color: Colors.orange.shade900, fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _postergarAlarma(item, 10);
            },
            child: const Text("😴 Postergar 10 min"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _marcarCompletado(item);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("✅ Marcar Realizado"),
          ),
        ],
      ),
    );
  }

  String _formatHora(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  String _formatFecha(DateTime dt) {
    return "${dt.day}/${dt.month}";
  }

  String _formatCountDown(int targetTimeMs) {
    final diffSeconds = ((targetTimeMs - DateTime.now().millisecondsSinceEpoch) / 1000).round();
    if (diffSeconds <= 0) return "¡ALERTA AHORA!";
    final m = (diffSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (diffSeconds % 60).toString().padLeft(2, '0');
    return "Faltan $m m $s s";
  }

  String _getRepeticionLabel(String? rep) {
    switch (rep) {
      case "daily": return "🔄 Repite: Todos los días";
      case "weekdays": return "📅 Repite: Lun-Vie";
      default: return "📌 Una sola vez";
    }
  }

  IconData _getIconForCategory(String cat) {
    switch (cat) {
      case "Reportes": return Icons.send_time_extension_outlined;
      case "Muestras": return Icons.inventory_2_outlined;
      case "Fluidos": return Icons.water_drop_outlined;
      case "Seguridad": return Icons.shield_outlined;
      default: return Icons.alarm_outlined;
    }
  }

  Color _getColorForCategory(String cat) {
    switch (cat) {
      case "Reportes": return Colors.blue;
      case "Muestras": return Colors.green;
      case "Fluidos": return Colors.cyan;
      case "Seguridad": return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final activas = _recordatorios.where((r) => r['completado'] == false).toList();
    final completadas = _recordatorios.where((r) => r['completado'] == true).toList();

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recordatorios y Alarmas",
              style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "👤 Perfil: ${widget.perfilActivo}",
              style: TextStyle(color: colors.azul, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: colors.azulOscuro),
            onPressed: () => widget.onNavigate('home'),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.azul,
          labelColor: colors.azul,
          unselectedLabelColor: colors.grisTexto,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: "⏰ Alarmas Activas (${activas.length})"),
            Tab(text: "✅ Histórico (${completadas.length})"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearPersonalizado,
        icon: const Icon(Icons.add_alarm),
        label: const Text("Nueva Alarma"),
        backgroundColor: colors.azul,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: ALARMAS ACTIVAS & PRESETS
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PLANTILLAS RÁPIDAS MODIFICABLES (FIX OVERFLOW)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Plantillas Rápidas (1-Tap):",
                              style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _dialogoCrearOEditarPreset(),
                            icon: const Icon(Icons.add, size: 15),
                            label: const Text("+ Plantilla", style: TextStyle(fontSize: 11.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      SizedBox(
                        height: 95,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _presets.length,
                          itemBuilder: (ctx, i) {
                            final p = _presets[i];
                            final Color pColor = _getColorForCategory(p['categoria'].toString());
                            final IconData pIcon = _getIconForCategory(p['categoria'].toString());

                            return Container(
                              width: 175,
                              margin: const EdgeInsets.only(right: 10),
                              child: Stack(
                                children: [
                                  InkWell(
                                    onTap: () => _crearPresetDesdePlantilla(p),
                                    onLongPress: () => _dialogoCrearOEditarPreset(presetExistente: p, index: i),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: pColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: pColor.withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Icon(pIcon, size: 18, color: pColor),
                                              Text("${p['minutos']} min", style: TextStyle(fontSize: 10, color: pColor, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          Text(
                                            p['titulo'].toString(),
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.azulOscuro),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, size: 14, color: Colors.grey),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _dialogoCrearOEditarPreset(presetExistente: p, index: i),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),

                      // LISTA DE ALARMAS ACTIVAS DEL PERFIL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Alarmas Activas de ${widget.perfilActivo}:",
                              style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text("${activas.length} pendientes", style: TextStyle(color: colors.grisTexto, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (activas.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(color: colors.superficie, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.bordeSuave)),
                          child: Column(
                            children: [
                              const Icon(Icons.alarm_off, size: 36, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text("No tienes alarmas activas", style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Usa una plantilla rápida arriba o crea una nueva alarma por hora o minutos.", style: TextStyle(color: colors.grisTexto, fontSize: 12), textAlign: TextAlign.center),
                            ],
                          ),
                        )
                      else
                        ...activas.map((item) {
                          final targetMs = item['targetTime'] as int;
                          final targetDt = DateTime.fromMillisecondsSinceEpoch(targetMs);
                          final countStr = _formatCountDown(targetMs);
                          final isSonando = item['disparado'] == true;
                          final repLabel = _getRepeticionLabel(item['repeticion'] as String?);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSonando ? Colors.red.withOpacity(0.08) : colors.superficie,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSonando ? Colors.red : colors.bordeSuave, width: isSonando ? 2 : 1),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: item['prioridad'] == 'Alta' ? Colors.red.withOpacity(0.12) : colors.azul.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "${item['categoria']} • ${item['prioridad']}",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: item['prioridad'] == 'Alta' ? Colors.red.shade700 : colors.azul,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.access_time, size: 14, color: isSonando ? Colors.red : colors.grisTexto),
                                    const SizedBox(width: 4),
                                    Text(
                                      countStr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSonando ? Colors.red : colors.azulOscuro,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  item['titulo'].toString(),
                                  style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 14.5),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text("Programada: ${_formatHora(targetDt)}", style: TextStyle(color: colors.grisTexto, fontSize: 11)),
                                    const SizedBox(width: 10),
                                    Text(repLabel, style: TextStyle(color: colors.azul, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                if (item['notas'] != null && item['notas'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(item['notas'].toString(), style: TextStyle(color: colors.grisTexto, fontSize: 12)),
                                ],
                                const SizedBox(height: 8),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => _postergarAlarma(item, 10),
                                      child: const Text("+10 min", style: TextStyle(fontSize: 11)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 22),
                                      onPressed: () => _marcarCompletado(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () => _eliminarRecordatorio(item),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                // TAB 2: HISTÓRICO DE COMPLETADAS DE ESTE PERFIL
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: completadas.length,
                  itemBuilder: (ctx, i) {
                    final item = completadas[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.superficie,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.bordeSuave),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['titulo'].toString(), style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.lineThrough)),
                                Text("Perfil: ${widget.perfilActivo} | Categoría: ${item['categoria']}", style: TextStyle(color: colors.grisTexto, fontSize: 11)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                            onPressed: () => _eliminarRecordatorio(item),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
