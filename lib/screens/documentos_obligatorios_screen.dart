import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/models/documento_obligatorio.dart';
import 'package:aprender_a_controlar/utils/url_helper.dart';

class DocumentosObligatoriosScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const DocumentosObligatoriosScreen({super.key, this.onBack});

  @override
  State<DocumentosObligatoriosScreen> createState() => _DocumentosObligatoriosScreenState();
}

class _DocumentosObligatoriosScreenState extends State<DocumentosObligatoriosScreen> {
  String _searchQuery = "";
  String _selectedCategory = "Todos";

  final List<String> _categories = [
    "Todos",
    "Permisos",
    "Checklists",
    "Controles",
  ];

  void _abrirUrl(BuildContext context, String urlString) {
    try {
      launchBrowserUrl(urlString);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al intentar abrir el enlace: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copiarEnlace(BuildContext context, String urlString) {
    Clipboard.setData(ClipboardData(text: urlString)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text("Enlace copiado al portapapeles con éxito."),
              ],
            ),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Color _getBadgeColor(String categoria, AppColors colors) {
    switch (categoria) {
      case "Permisos":
        return Colors.indigo.shade700;
      case "Checklists":
        return Colors.amber.shade900;
      case "Controles":
        return Colors.green.shade800;
      default:
        return colors.azul;
    }
  }

  Color _getBadgeBgColor(String categoria, AppColors colors) {
    switch (categoria) {
      case "Permisos":
        return Colors.indigo.shade50;
      case "Checklists":
        return Colors.amber.shade50;
      case "Controles":
        return Colors.green.shade50;
      default:
        return colors.azul.withOpacity(0.08);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final width = MediaQuery.of(context).size.width;

    // Filter documents
    final filtrados = listaDocumentosObligatorios.where((doc) {
      final matchesSearch = doc.titulo.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == "Todos" || doc.categoria == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: colors.fondo,
      appBar: AppBar(
        backgroundColor: colors.superficie,
        elevation: 0,
        title: Text(
          "Documentos obligatorios",
          style: TextStyle(
            color: colors.azulOscuro,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.azulOscuro),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: colors.bordeSuave,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter and Search Header
          Container(
            color: colors.superficie,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Buscar por nombre de documento...",
                    hintStyle: TextStyle(color: colors.grisTexto.withOpacity(0.6), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: colors.grisTexto, size: 20),
                    fillColor: colors.fondo,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.bordeSuave),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.bordeSuave),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.azul, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Categories row
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? colors.azul : colors.grisTexto,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                          selectedColor: colors.azul.withOpacity(0.12),
                          backgroundColor: colors.fondo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? colors.azul : colors.bordeSuave,
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.bordeSuave),

          // Main list or grid
          Expanded(
            child: filtrados.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_off_outlined,
                            size: 64,
                            color: colors.grisSecundario.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Sin resultados",
                            style: TextStyle(
                              color: colors.azulOscuro,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "No se encontraron documentos obligatorios que coincidan con los filtros seleccionados.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.grisTexto,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : width > 900
                    // Grid Layout for Tablet / Desktop
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisExtent: 200,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filtrados.length,
                        itemBuilder: (context, index) {
                          return _buildDocumentoCard(context, filtrados[index], colors, isGrid: true);
                        },
                      )
                    // List Layout for Mobile
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtrados.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildDocumentoCard(context, filtrados[index], colors),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentoCard(BuildContext context, DocumentoObligatorio doc, AppColors colors, {bool isGrid = false}) {
    final badgeColor = _getBadgeColor(doc.categoria, colors);
    final badgeBg = _getBadgeBgColor(doc.categoria, colors);

    return Card(
      color: colors.superficie,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.bordeSuave, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Badge and Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.azul.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    doc.icono,
                    color: colors.azul,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    doc.categoria,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            isGrid
                ? Expanded(
                    child: Text(
                      doc.titulo,
                      style: TextStyle(
                        color: colors.azulOscuro,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      doc.titulo,
                      style: TextStyle(
                        color: colors.azulOscuro,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
            const SizedBox(height: 12),
            // Bottom Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _abrirUrl(context, doc.url),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text(
                      "Abrir en Drive",
                      style: TextStyle(fontSize: 12.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: colors.azul,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _copiarEnlace(context, doc.url),
                  icon: Icon(Icons.copy, color: colors.grisTexto, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.fondo,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: colors.bordeSuave),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
