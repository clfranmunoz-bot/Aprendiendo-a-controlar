import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/models/procedimiento.dart';
import 'package:aprender_a_controlar/utils/url_helper.dart';

class ProcedimientosScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProcedimientosScreen({super.key, this.onBack});

  @override
  State<ProcedimientosScreen> createState() => _ProcedimientosScreenState();
}

class _ProcedimientosScreenState extends State<ProcedimientosScreen> {
  String _searchQuery = "";
  String _selectedCategory = "Todos";

  final List<String> _categories = [
    "Todos",
    "Operaciones",
    "Seguridad y Vehículos",
    "Seguridad",
    "Emergencias y Riesgos"
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
      case "Operaciones":
        return colors.azul;
      case "Seguridad y Vehículos":
        return colors.naranjo;
      case "Seguridad":
        return colors.verde;
      case "Emergencias y Riesgos":
        return colors.rojo;
      default:
        return colors.grisTexto;
    }
  }

  Color _getBadgeBgColor(String categoria, AppColors colors) {
    switch (categoria) {
      case "Operaciones":
        return colors.azulClaro;
      case "Seguridad y Vehículos":
        return colors.naranjoClaro;
      case "Seguridad":
        return colors.verdeClaro;
      case "Emergencias y Riesgos":
        return colors.rojoClaro;
      default:
        return colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final width = MediaQuery.of(context).size.width;

    // Filter procedures
    final filtrados = listaProcedimientos.where((p) {
      final matchesSearch = p.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.codigo.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == "Todos" || p.categoria == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: colors.fondo,
      appBar: AppBar(
        title: const Text("Procedimientos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.superficie,
              border: Border(
                bottom: BorderSide(color: colors.bordeSuave, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: colors.grisTexto),
                    hintText: "Buscar por nombre, código o versión...",
                    hintStyle: TextStyle(color: colors.grisTexto.withOpacity(0.7)),
                    filled: true,
                    fillColor: colors.isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.bordeSuave, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.azul, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? (colors.isDark ? Colors.white : colors.azulOscuro)
                                  : colors.grisTexto,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                            }
                          },
                          backgroundColor: colors.isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          selectedColor: colors.azul.withOpacity(0.18),
                          side: BorderSide(
                            color: isSelected ? colors.azul.withOpacity(0.5) : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // List / Grid Body
          Expanded(
            child: filtrados.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: colors.grisSecundario.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Sin resultados",
                            style: TextStyle(
                              color: colors.azulOscuro,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No encontramos ningún procedimiento que coincida con tus criterios de búsqueda.",
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
                          mainAxisExtent: 220,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filtrados.length,
                        itemBuilder: (context, index) {
                          return _buildProcedimientoCard(context, filtrados[index], colors, isGrid: true);
                        },
                      )
                    // List Layout for Mobile
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtrados.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildProcedimientoCard(context, filtrados[index], colors),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcedimientoCard(BuildContext context, Procedimiento p, AppColors colors, {bool isGrid = false}) {
    final badgeColor = _getBadgeColor(p.categoria, colors);
    final badgeBg = _getBadgeBgColor(p.categoria, colors);

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
            // Top Row: Badge category and Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.azul.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    p.icono,
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
                    p.categoria,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  p.codigo,
                  style: TextStyle(
                    color: colors.grisTexto,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            isGrid
                ? Expanded(
                    child: Text(
                      p.titulo,
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
                      p.titulo,
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
                    onPressed: () => _abrirUrl(context, p.url),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text(
                      "Abrir en Drive",
                      style: TextStyle(fontSize: 12.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.azul,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _copiarEnlace(context, p.url),
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  tooltip: "Copiar Enlace",
                  color: colors.grisTexto,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: colors.bordeSuave, width: 1),
                    ),
                    padding: const EdgeInsets.all(10),
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
