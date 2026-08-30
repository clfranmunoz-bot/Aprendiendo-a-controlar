import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/glosario_data.dart';
import 'package:aprender_a_controlar/models/glosario.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';

class GlosarioScreen extends StatefulWidget {
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;
  final Function(String) onNavigate;

  const GlosarioScreen({
    super.key,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
    required this.onNavigate,
  });

  @override
  State<GlosarioScreen> createState() => _GlosarioScreenState();
}

class _GlosarioScreenState extends State<GlosarioScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  List<TerminoGlosario> _filteredTerms = [];
  String _searchQuery = "";
  String _selectedCategoria = "Todas";

  @override
  void initState() {
    super.initState();
    _filteredTerms = _applyFilters(bancoGlosario);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<TerminoGlosario> _applyFilters(Iterable<TerminoGlosario> source) {
    var list = source.toList();
    if (_selectedCategoria != "Todas") {
      list = list.where((t) => t.categoria == _selectedCategoria).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((t) {
        return t.termino.toLowerCase().contains(_searchQuery) ||
            t.definicion.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    list.sort((a, b) => a.termino.toLowerCase().compareTo(b.termino.toLowerCase()));
    return list;
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
      _filteredTerms = _applyFilters(bancoGlosario);
    });
  }

  void _setCategoria(String cat) {
    setState(() {
      _selectedCategoria = cat;
      _filteredTerms = _applyFilters(bancoGlosario);
    });
  }

  Color _getCatColor(String cat) {
    switch (cat) {
      case '🔧 Equipos y Herramientas': return Colors.blue.shade700;
      case '📐 Medición y Cálculo': return Colors.green.shade700;
      case '🪨 Geología del Terreno': return Colors.brown.shade600;
      case '📄 Documentación y Seguridad': return Colors.red.shade700;
      case '💧 Fluidos y Lodos': return Colors.cyan.shade700;
      default: return Colors.grey.shade600;
    }
  }

  Color _getCatBgColor(String cat) {
    switch (cat) {
      case '🔧 Equipos y Herramientas': return Colors.blue.shade50;
      case '📐 Medición y Cálculo': return Colors.green.shade50;
      case '🪨 Geología del Terreno': return Colors.brown.shade50;
      case '📄 Documentación y Seguridad': return Colors.red.shade50;
      case '💧 Fluidos y Lodos': return Colors.cyan.shade50;
      default: return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

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
          "Glosario de Sondaje",
          style: TextStyle(
            color: colors.azulOscuro,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: colors.azulOscuro),
            tooltip: "Volver al Inicio",
            onPressed: () => widget.onNavigate('home'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner descriptivo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: colors.purpuraClaro,
            child: Row(
              children: [
                Icon(Icons.menu_book, color: colors.purpura, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${bancoGlosario.length} términos técnicos de control de perforación diamantina.",
                    style: TextStyle(color: colors.purpura, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: colors.azulOscuro),
              decoration: InputDecoration(
                hintText: "Buscar término o palabra clave...",
                hintStyle: TextStyle(color: colors.grisSecundario),
                prefixIcon: Icon(Icons.search, color: colors.azul),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: colors.superficie,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.bordeSuave),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.bordeSuave),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.azul, width: 2),
                ),
              ),
            ),
          ),

          // Filtros por categoría (chips)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: categoriasGlosario.map((cat) {
                final isSelected = _selectedCategoria == cat;
                final catColor = cat == "Todas" ? colors.azul : _getCatColor(cat);
                final catBg = cat == "Todas" ? colors.azulClaro : _getCatBgColor(cat);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      cat == "Todas" ? "Todas" : cat.substring(cat.indexOf(' ') + 1),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : catColor,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: catColor,
                    backgroundColor: catBg,
                    onSelected: (_) => _setCategoria(cat),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }).toList(),
            ),
          ),

          // Contador de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _searchQuery.isEmpty && _selectedCategoria == "Todas"
                    ? "${bancoGlosario.length} términos disponibles"
                    : "${_filteredTerms.length} resultado${_filteredTerms.length != 1 ? 's' : ''}",
                style: TextStyle(color: colors.grisSecundario, fontSize: 12),
              ),
            ),
          ),

          // Lista de términos
          Expanded(
            child: _filteredTerms.isEmpty
                ? _buildEmptyState(context, colors)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    itemCount: _filteredTerms.length,
                    itemBuilder: (context, index) {
                      return _buildGlossaryCard(context, _filteredTerms[index], colors);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: colors.purpura),
          const SizedBox(height: 12),
          Text("No se encontraron resultados",
              style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text("Intenta cambiar el filtro o la búsqueda.",
              style: TextStyle(color: colors.grisTexto, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              _setCategoria("Todas");
            },
            child: const Text("Limpiar Filtros"),
          ),
        ],
      ),
    );
  }

  Widget _buildGlossaryCard(BuildContext context, TerminoGlosario item, AppColors colors) {
    final catColor = _getCatColor(item.categoria);
    final catBg = _getCatBgColor(item.categoria);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.bordeSuave, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          item.termino,
          style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 14.5),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: catBg, borderRadius: BorderRadius.circular(6)),
            child: Text(
              item.categoria.replaceFirst(RegExp(r'^. '), ''),
              style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: colors.purpuraClaro,
          child: Text(
            item.termino[0].toUpperCase(),
            style: TextStyle(color: colors.purpura, fontWeight: FontWeight.bold),
          ),
        ),
        iconColor: colors.purpura,
        collapsedIconColor: colors.grisSecundario,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 10, thickness: 0.8),
          const SizedBox(height: 6),
          Text(
            item.definicion,
            style: TextStyle(color: colors.grisTexto, fontSize: 13.5, height: 1.5),
          ),
        ],
      ),
    );
  }
}
