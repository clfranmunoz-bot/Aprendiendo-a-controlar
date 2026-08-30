import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:camera/camera.dart';
import 'package:aprender_a_controlar/models/nota_campo.dart';
import 'package:aprender_a_controlar/services/notas_service.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';

class NotasScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;

  const NotasScreen({
    super.key,
    required this.onNavigate,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
  });

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<NotaCampo> _notas = [];
  bool _cargando = true;
  String _filtroCategoria = "Todas";
  String _searchQuery = "";

  final List<String> _categorias = [
    "Todas",
    "Operaciones",
    "Medición",
    "Muestra",
    "Maquinaria",
    "Seguridad",
  ];

  @override
  void initState() {
    super.initState();
    _cargarNotas();
  }

  Future<void> _cargarNotas() async {
    setState(() => _cargando = true);
    final cargadas = await NotasService.obtenerNotas();
    if (mounted) {
      setState(() {
        _notas = cargadas;
        _cargando = false;
      });
    }
  }

  Future<void> _toggleRevision(NotaCampo nota) async {
    final nuevoEstado = !nota.revisadoConSupervisor;
    await NotasService.cambiarEstadoRevision(nota.id, nuevoEstado);
    await _cargarNotas();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nuevoEstado
              ? "🟢 Marcado como REVISADO con Supervisor"
              : "🟡 Marcado como PENDIENTE de revisión"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _eliminarNota(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Nota"),
        content: const Text("¿Estás seguro de que deseas eliminar esta nota de campo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await NotasService.eliminarNota(id);
      await _cargarNotas();
    }
  }

  void _compartirNota(NotaCampo nota) {
    final texto = "📝 *NOTA DE CAMPO — CONTROL DE SONDAJE*\n"
        "----------------------------------------\n"
        "• *Título:* ${nota.titulo}\n"
        "• *Categoría:* ${nota.categoria}\n"
        "• *Estado:* ${nota.revisadoConSupervisor ? '🟢 REVISADO' : '🟡 PENDIENTE DE REVISIÓN'}\n"
        "• *Fecha:* ${nota.fecha.day}/${nota.fecha.month}/${nota.fecha.year} ${nota.fecha.hour.toString().padLeft(2, '0')}:${nota.fecha.minute.toString().padLeft(2, '0')}\n\n"
        "📌 *Detalle:* \n${nota.contenido}\n";

    if (nota.pathFoto != null && nota.pathFoto!.isNotEmpty && File(nota.pathFoto!).existsSync()) {
      Share.shareXFiles([XFile(nota.pathFoto!)], text: texto);
    } else {
      Share.share(texto);
    }
  }

  void _abrirModalCrearEditar([NotaCampo? notaExistente]) {
    final tituloCtrl = TextEditingController(text: notaExistente?.titulo ?? "");
    final contenidoCtrl = TextEditingController(text: notaExistente?.contenido ?? "");
    String catSel = notaExistente?.categoria ?? "Operaciones";
    String? pathFotoSel = notaExistente?.pathFoto;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final colors = AppColors.of(context);
            final bottomSpace = MediaQuery.of(modalCtx).viewInsets.bottom;

            return Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomSpace + 16),
              decoration: BoxDecoration(
                color: colors.superficie,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notaExistente == null ? "Nueva Nota de Campo 📝" : "Editar Nota ✍️",
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Título
                    TextField(
                      controller: tituloCtrl,
                      decoration: const InputDecoration(
                        labelText: "Título / Asunto de la duda",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Categoría
                    DropdownButtonFormField<String>(
                      value: catSel,
                      dropdownColor: colors.superficie,
                      borderRadius: BorderRadius.circular(16),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
                      elevation: 8,
                      style: TextStyle(color: colors.azulOscuro, fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: "Categoría",
                        filled: true,
                        fillColor: colors.superficieSuave,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.bordeSuave)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.bordeSuave)),
                      ),
                      items: ["Operaciones", "Medición", "Muestra", "Maquinaria", "Seguridad"]
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => catSel = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Contenido
                    TextField(
                      controller: contenidoCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Descripción / Detalle de la observación",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.blue),
                          tooltip: "Dictado por Voz",
                          onPressed: () {
                            _mostrarDialogoDictadoVoz(modalCtx, (textoDictado) {
                              setModalState(() {
                                if (contenidoCtrl.text.isEmpty) {
                                  contenidoCtrl.text = textoDictado;
                                } else {
                                  contenidoCtrl.text += " $textoDictado";
                                }
                              });
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Adjuntar Foto Preview/Button
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final fotoPath = await _capturarOTomarFoto(modalCtx);
                            if (fotoPath != null) {
                              setModalState(() => pathFotoSel = fotoPath);
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: Text(pathFotoSel == null ? "Tomar Foto 📷" : "Cambiar Foto 📷"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.azulClaro,
                            foregroundColor: colors.azul,
                          ),
                        ),
                        if (pathFotoSel != null) ...[
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setModalState(() => pathFotoSel = null);
                            },
                          ),
                        ],
                      ],
                    ),
                    if (pathFotoSel != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.bordeSuave),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: File(pathFotoSel!).existsSync()
                              ? Image.file(File(pathFotoSel!), fit: BoxFit.cover)
                              : Container(
                                  color: Colors.grey.shade300,
                                  alignment: Alignment.center,
                                  child: const Text("📷 Imagen Capturada (Referencia)"),
                                ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Guardar Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.azul,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          if (tituloCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(modalCtx).showSnackBar(
                              const SnackBar(content: Text("Ingresa un título para la nota")),
                            );
                            return;
                          }

                          final nueva = NotaCampo(
                            id: notaExistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            titulo: tituloCtrl.text.trim(),
                            contenido: contenidoCtrl.text.trim(),
                            categoria: catSel,
                            fecha: DateTime.now(),
                            revisadoConSupervisor: notaExistente?.revisadoConSupervisor ?? false,
                            pathFoto: pathFotoSel,
                          );

                          await NotasService.guardarNota(nueva);
                          if (modalCtx.mounted) Navigator.pop(modalCtx);
                          await _cargarNotas();
                        },
                        child: Text(
                          notaExistente == null ? "Guardar Nota" : "Actualizar Nota",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoDictadoVoz(BuildContext context, Function(String) onTextoDictado) {
    final tempCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.mic, color: Colors.redAccent),
            SizedBox(width: 8),
            Text("Dictado por Voz 🎙️"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Puedes hablar mediante el micrófono de tu teclado o ingresar el texto dictado:",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tempCtrl,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Ejemplo: Duda con la medida de contra en la corrida 4 a los 45m...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    label: const Text("Duda en contra"),
                    onPressed: () => tempCtrl.text = "Duda en la lectura de contra sobrante.",
                  ),
                  const SizedBox(width: 6),
                  ActionChip(
                    label: const Text("Pérdida de testigo"),
                    onPressed: () => tempCtrl.text = "Roca molida con pérdida de testigo.",
                  ),
                  const SizedBox(width: 6),
                  ActionChip(
                    label: const Text("Falla de agua"),
                    onPressed: () => tempCtrl.text = "Caída de presión en la bomba de agua.",
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (tempCtrl.text.trim().isNotEmpty) {
                onTextoDictado(tempCtrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text("Insertar"),
          ),
        ],
      ),
    );
  }

  Future<String?> _capturarOTomarFoto(BuildContext context) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final camera = cameras.first;
        final controller = CameraController(camera, ResolutionPreset.medium);
        await controller.initialize();
        final xfile = await controller.takePicture();
        await controller.dispose();
        return xfile.path;
      }
    } catch (_) {}

    // Fallback simulation for devices/simulators without active camera
    final directory = Directory.systemTemp.path;
    final simulatedPath = '$directory/foto_nota_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(simulatedPath);
    await file.writeAsString('Simulated image data');
    return simulatedPath;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final filtradas = _notas.where((n) {
      final matchesCat = _filtroCategoria == "Todas" || n.categoria == _filtroCategoria;
      final matchesSearch = _searchQuery.isEmpty ||
          n.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.contenido.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    final pendientesCount = _notas.where((n) => !n.revisadoConSupervisor).length;
    final revisadasCount = _notas.where((n) => n.revisadoConSupervisor).length;

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
          "Notas de Campo 📝",
          style: TextStyle(
            color: colors.azulOscuro,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      drawer: DrawerMenu(
        onNavigate: widget.onNavigate,
        modoOscuro: widget.modoOscuro,
        onToggleModoOscuro: widget.onToggleModoOscuro,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModalCrearEditar(),
        backgroundColor: colors.azul,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment),
        label: const Text("Nueva Nota", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // KPI Header
                Container(
                  color: colors.superficie,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.withOpacity(0.4)),
                          ),
                          child: Column(
                            children: [
                              Text("$pendientesCount",
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                              const SizedBox(height: 2),
                              const Text("Pendientes 🟡",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.withOpacity(0.4)),
                          ),
                          child: Column(
                            children: [
                              Text("$revisadasCount",
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                              const SizedBox(height: 2),
                              const Text("Revisadas 🟢",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Search Bar & Filter Chips
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: "Buscar en mis notas...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: colors.superficie,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.bordeSuave),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.bordeSuave),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categorias.map((cat) {
                            final isSel = _filtroCategoria == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSel,
                                selectedColor: colors.azul,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : colors.azulOscuro,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                onSelected: (_) {
                                  setState(() => _filtroCategoria = cat);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // List of Notes
                Expanded(
                  child: filtradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("📝", style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 10),
                              Text(
                                "No tienes notas en esta categoría",
                                style: TextStyle(color: colors.grisTexto, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          itemCount: filtradas.length,
                          itemBuilder: (context, idx) {
                            final nota = filtradas[idx];
                            return _buildNotaCard(nota, colors);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildNotaCard(NotaCampo nota, AppColors colors) {
    final esRevisado = nota.revisadoConSupervisor;

    return Card(
      color: colors.superficie,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: esRevisado ? Colors.green.withOpacity(0.5) : Colors.amber.withOpacity(0.5),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.azulClaro,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    nota.categoria,
                    style: TextStyle(color: colors.azul, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleRevision(nota),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: esRevisado ? Colors.green.shade100 : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      esRevisado ? "🟢 Revisado" : "🟡 Pendiente",
                      style: TextStyle(
                        color: esRevisado ? Colors.green.shade900 : Colors.amber.shade900,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              nota.titulo,
              style: TextStyle(
                color: colors.azulOscuro,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              nota.contenido,
              style: TextStyle(color: colors.grisTexto, fontSize: 13, height: 1.3),
            ),

            if (nota.pathFoto != null) ...[
              const SizedBox(height: 10),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.bordeSuave),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: File(nota.pathFoto!).existsSync()
                      ? Image.file(File(nota.pathFoto!), fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Text("📷 Imagen Adjunta (Referencia de Terreno)"),
                        ),
                ),
              ),
            ],
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${nota.fecha.day}/${nota.fecha.month}/${nota.fecha.year} ${nota.fecha.hour.toString().padLeft(2, '0')}:${nota.fecha.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(color: colors.grisTexto, fontSize: 11),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, size: 18),
                      onPressed: () => _compartirNota(nota),
                      tooltip: "Compartir",
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => _abrirModalCrearEditar(nota),
                      tooltip: "Editar",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      onPressed: () => _eliminarNota(nota.id),
                      tooltip: "Eliminar",
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
