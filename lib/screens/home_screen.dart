import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprender_a_controlar/models/seccion.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/secciones_data.dart';
import 'package:aprender_a_controlar/utils/app_routes.dart';
import 'package:aprender_a_controlar/widgets/hero_block.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';

class HomeScreen extends StatefulWidget {
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;
  final Function(String, {int? initialTab}) onNavigate;
  final String perfilActivo;
  final List<String> perfiles;
  final Function(String) onPerfilChanged;
  final Function(String) onPerfilDeleted;

  const HomeScreen({
    super.key,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
    required this.onNavigate,
    required this.perfilActivo,
    required this.perfiles,
    required this.onPerfilChanged,
    required this.onPerfilDeleted,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool _modoEdicionHero = false;
  SeccionApp? _bannerSlot;
  final List<SeccionApp?> _slots = List.filled(4, null);

  @override
  void initState() {
    super.initState();
    _cargarSlots();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perfilActivo != widget.perfilActivo) {
      _cargarSlots();
    }
  }

  Future<void> _cargarSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final p = widget.perfilActivo;
    
    final idBanner = prefs.getString("${p}_banner_slot") ?? "checklist_turno";
    final id0 = prefs.getString("${p}_slot_0") ?? "aprender_procedimiento";
    final id1 = prefs.getString("${p}_slot_1") ?? "calculadoras";
    final id2 = prefs.getString("${p}_slot_2") ?? "ejercicios_practicos";
    final id3 = prefs.getString("${p}_slot_3") ?? "quiz_puntaje";

    setState(() {
      _bannerSlot = idBanner == "empty" ? null : obtenerSeccionPorId(idBanner);
      _slots[0] = id0 == "empty" ? null : obtenerSeccionPorId(id0);
      _slots[1] = id1 == "empty" ? null : obtenerSeccionPorId(id1);
      _slots[2] = id2 == "empty" ? null : obtenerSeccionPorId(id2);
      _slots[3] = id3 == "empty" ? null : obtenerSeccionPorId(id3);
    });
  }

  Future<void> _guardarSlot(int index, String seccionId) async {
    final prefs = await SharedPreferences.getInstance();
    if (index == -1) {
      await prefs.setString("${widget.perfilActivo}_banner_slot", seccionId);
    } else {
      await prefs.setString("${widget.perfilActivo}_slot_$index", seccionId);
    }
    _cargarSlots();
  }

  void _onBannerTap() {
    if (_modoEdicionHero) {
      _mostrarSelectorSecciones(-1);
    } else {
      final seccion = _bannerSlot;
      if (seccion != null) {
        if (seccion.id == "calculadoras") {
          widget.onNavigate("calculadoras", initialTab: 0);
        } else {
          widget.onNavigate(seccion.id);
        }
      } else {
        _mostrarSelectorSecciones(-1);
      }
    }
  }

  Future<void> _eliminarSlot(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("${widget.perfilActivo}_slot_$index", "empty");
    _cargarSlots();
  }

  void _onSlotTap(int index) {
    if (_modoEdicionHero) {
      _mostrarSelectorSecciones(index);
    } else {
      final seccion = _slots[index];
      if (seccion != null) {
        if (seccion.id == "calculadoras") {
          widget.onNavigate("calculadoras", initialTab: 0);
        } else {
          widget.onNavigate(seccion.id);
        }
      } else {
        _mostrarSelectorSecciones(index);
      }
    }
  }

  void _mostrarSelectorSecciones(int slotIndex) {
    final colors = AppColors.of(context);
    final searchCtrl = TextEditingController();
    String pilarFiltro = "todos";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.fondo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final filtradas = catalogoSecciones.where((s) {
              final coincidePilar = pilarFiltro == "todos" || s.pilar == pilarFiltro;
              final coincideTexto = query.isEmpty ||
                  s.titulo.toLowerCase().contains(query) ||
                  s.descripcion.toLowerCase().contains(query);
              return coincidePilar && coincideTexto;
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.grisSecundario.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Asignar Acceso Directo (Slot ${slotIndex + 1})",
                      style: TextStyle(
                        color: colors.azulOscuro,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // CAMPO DE BÚSQUEDA
                    TextField(
                      controller: searchCtrl,
                      style: TextStyle(color: colors.azulOscuro, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Buscar módulo para Slot ${slotIndex + 1}...",
                        prefixIcon: Icon(Icons.search, size: 18, color: colors.azul),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  searchCtrl.clear();
                                  setModalState(() {});
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
                      onChanged: (val) => setModalState(() {}),
                    ),
                    const SizedBox(height: 8),

                    // CHIPS DE PILARES
                    SizedBox(
                      height: 34,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pilaresApp.length,
                        itemBuilder: (ctx, i) {
                          final p = pilaresApp[i];
                          final sel = pilarFiltro == p.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text("${p.emoji} ${p.titulo}"),
                              selected: sel,
                              selectedColor: colors.azul,
                              backgroundColor: colors.superficieSuave,
                              labelStyle: TextStyle(
                                color: sel ? Colors.white : colors.azulOscuro,
                                fontSize: 11,
                                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onSelected: (s) {
                                setModalState(() {
                                  pilarFiltro = p.id;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // LISTADO RESULTANTE
                    Expanded(
                      child: filtradas.isEmpty
                          ? Center(
                              child: Text(
                                "No hay secciones con ese criterio.",
                                style: TextStyle(color: colors.grisTexto, fontSize: 12),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtradas.length,
                              itemBuilder: (context, idx) {
                                final seccion = filtradas[idx];
                                final colorTheme = colors.getMenuColor(seccion.colorIndex);

                                return Card(
                                  color: colors.superficieSuave,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: colors.bordeSuave.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                  elevation: 0,
                                  child: ListTile(
                                    tileColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: colorTheme.withValues(alpha: 0.15),
                                      child: Text(
                                        seccion.emoji,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    title: Text(
                                      seccion.titulo,
                                      style: TextStyle(
                                        color: colors.azulOscuro,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    subtitle: Text(
                                      seccion.descripcion,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.grisTexto,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                    onTap: () {
                                      _guardarSlot(slotIndex, seccion.id);
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerMenu(
        onNavigate: (route) {
          if (route == "home") {
            // Permanecer en home
          } else {
            widget.onNavigate(route);
          }
        },
        modoOscuro: widget.modoOscuro,
        onToggleModoOscuro: widget.onToggleModoOscuro,
      ),
      body: HeroBlock(
        modoEdicionHero: _modoEdicionHero,
        bannerSlot: _bannerSlot,
        onBannerTap: _onBannerTap,
        slots: _slots,
        onSlotTap: _onSlotTap,
        onSlotDelete: _eliminarSlot,
        onToggleEdicion: () {
          setState(() => _modoEdicionHero = !_modoEdicionHero);
        },
        onOpenMenu: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        modoOscuro: widget.modoOscuro,
        onToggleModoOscuro: widget.onToggleModoOscuro,
        onNavigate: widget.onNavigate,
        perfilActivo: widget.perfilActivo,
        perfiles: widget.perfiles,
        onPerfilChanged: widget.onPerfilChanged,
        onPerfilDeleted: widget.onPerfilDeleted,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => widget.onNavigate(AppRoutes.chatbot),
        backgroundColor: colors.azul,
        foregroundColor: Colors.white,
        icon: const Text("🤖", style: TextStyle(fontSize: 20)),
        label: const Text(
          "DrillBot",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
