import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/secciones_data.dart';
import 'package:aprender_a_controlar/models/seccion.dart';
import 'package:aprender_a_controlar/widgets/theme_toggle_switch.dart';
import 'package:aprender_a_controlar/widgets/max_width_container.dart';

class DrawerMenu extends StatefulWidget {
  final Function(String) onNavigate;
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;

  const DrawerMenu({
    super.key,
    required this.onNavigate,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
  });

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _pilarFiltro = "todos"; // "todos", "campo", "manual", "entrenamiento", "asistentes"
  
  final Map<String, bool> _seccionAbierta = {
    "campo": false,
    "manual": false,
    "entrenamiento": false,
    "asistentes": false,
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SeccionApp> _obtenerSeccionesFiltradas() {
    final query = _searchCtrl.text.trim().toLowerCase();
    return catalogoSecciones.where((s) {
      final coincidePilar = _pilarFiltro == "todos" || s.pilar == _pilarFiltro;
      final coincideTexto = query.isEmpty ||
          s.titulo.toLowerCase().contains(query) ||
          s.descripcion.toLowerCase().contains(query);
      return coincidePilar && coincideTexto;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final filtradas = _obtenerSeccionesFiltradas();
    final bool buscando = _searchCtrl.text.trim().isNotEmpty;

    return Drawer(
      backgroundColor: colors.fondo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: MaxWidthContainer(
          maxWidth: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CON TÍTULO Y BUSCADOR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Explorar Secciones",
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: colors.azulOscuro),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // CAMPO DE BÚSQUEDA INSTANTÁNEO
                    TextField(
                      controller: _searchCtrl,
                      style: TextStyle(color: colors.azulOscuro, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Buscar módulo, calculadora o tema...",
                        hintStyle: TextStyle(color: colors.grisTexto, fontSize: 12.5),
                        prefixIcon: Icon(Icons.search, size: 18, color: colors.azul),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: colors.superficieSuave,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.bordeSuave),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.bordeSuave),
                        ),
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                    const SizedBox(height: 10),

                    // BARRA DE FILTROS POR PILARES (CHIPS)
                    SizedBox(
                      height: 34,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pilaresApp.length,
                        itemBuilder: (ctx, i) {
                          final p = pilaresApp[i];
                          final sel = _pilarFiltro == p.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text("${p.emoji} ${p.titulo}"),
                              selected: sel,
                              selectedColor: colors.azul,
                              backgroundColor: colors.superficieSuave,
                              labelStyle: TextStyle(
                                color: sel ? Colors.white : colors.azulOscuro,
                                fontSize: 11.5,
                                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onSelected: (s) {
                                setState(() {
                                  _pilarFiltro = p.id;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 14, thickness: 1),

              // BOTÓN INICIO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildMenuItem(
                  context,
                  title: "🏠 Ir al Inicio (Portada)",
                  subtitle: "Regresar al panel principal",
                  color: colors.superficieSuave,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onNavigate("home");
                  },
                ),
              ),
              const SizedBox(height: 10),

              // LISTA DE SECCIONES ORGANIZADAS POR PILARES
              Expanded(
                child: filtradas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 40, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text("No se encontraron módulos", style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold)),
                            Text("Intenta buscar con otra palabra clave.", style: TextStyle(color: colors.grisTexto, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          if (buscando || _pilarFiltro != "todos") ...[
                            // LISTADO FILTRADO DIRECTO
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                "Resultados (${filtradas.length}):",
                                style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            ...filtradas.map((seccion) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: _buildSubMenuItem(context, seccion),
                                )),
                          ] else ...[
                            // ESTRUCTURA COMPLETA ORGANIZADA EN 4 PILARES
                            ...pilaresApp.where((p) => p.id != "todos").map((pilarInfo) {
                              final seccionesDelPilar = catalogoSecciones.where((s) => s.pilar == pilarInfo.id).toList();
                              final bool estaAbierto = _seccionAbierta[pilarInfo.id] ?? true;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCollapsibleHeader(
                                    title: "${pilarInfo.emoji} ${pilarInfo.titulo} (${seccionesDelPilar.length})",
                                    isOpen: estaAbierto,
                                    activeColor: colors.azul,
                                    backgroundColor: colors.superficieSuave,
                                    onTap: () {
                                      setState(() {
                                        _seccionAbierta[pilarInfo.id] = !estaAbierto;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 6),

                                  if (estaAbierto) ...[
                                    ...seccionesDelPilar.map((seccion) => Padding(
                                          padding: const EdgeInsets.only(left: 8, bottom: 6),
                                          child: _buildSubMenuItem(context, seccion),
                                        )),
                                    const SizedBox(height: 10),
                                  ],
                                ],
                              );
                            }),
                          ],
                        ],
                      ),
              ),

              // FOOTER CON INTERRUPTOR DE MODO OSCURO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.superficie,
                  border: Border(top: BorderSide(color: colors.bordeSuave)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(widget.modoOscuro ? Icons.dark_mode : Icons.light_mode, color: colors.azul),
                        const SizedBox(width: 8),
                        Text(
                          widget.modoOscuro ? "Modo Oscuro" : "Modo Claro",
                          style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    ThemeToggleSwitch(
                      modoOscuro: widget.modoOscuro,
                      onTap: widget.onToggleModoOscuro,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);
    return Card(
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.bordeSuave),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: colors.grisTexto, fontSize: 11.5)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: colors.azul),
      ),
    );
  }

  Widget _buildCollapsibleHeader({
    required String title,
    required bool isOpen,
    required Color activeColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.bordeSuave),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13.5)),
            Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: activeColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(BuildContext context, SeccionApp seccion) {
    final colors = AppColors.of(context);
    final colorTheme = colors.getMenuColor(seccion.colorIndex);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        widget.onNavigate(seccion.id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.superficie,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.bordeSuave.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorTheme.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(seccion.emoji, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(seccion.titulo, style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(seccion.descripcion, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.grisTexto, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: colors.grisSecundario),
          ],
        ),
      ),
    );
  }
}
