import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/models/seccion.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/secciones_data.dart';
import 'package:aprender_a_controlar/widgets/shortcut_slot.dart';
import 'package:aprender_a_controlar/widgets/theme_toggle_switch.dart';
import 'package:aprender_a_controlar/widgets/max_width_container.dart';

class HeroBlock extends StatelessWidget {
  final bool modoEdicionHero;
  final SeccionApp? bannerSlot;
  final VoidCallback onBannerTap;
  final List<SeccionApp?> slots;
  final Function(int) onSlotTap;
  final Function(int) onSlotDelete;
  final VoidCallback onToggleEdicion;
  final VoidCallback onOpenMenu;
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;
  final Function(String) onNavigate;
  final String perfilActivo;
  final List<String> perfiles;
  final Function(String) onPerfilChanged;
  final Function(String) onPerfilDeleted;

  const HeroBlock({
    super.key,
    required this.modoEdicionHero,
    required this.bannerSlot,
    required this.onBannerTap,
    required this.slots,
    required this.onSlotTap,
    required this.onSlotDelete,
    required this.onToggleEdicion,
    required this.onOpenMenu,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
    required this.onNavigate,
    required this.perfilActivo,
    required this.perfiles,
    required this.onPerfilChanged,
    required this.onPerfilDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = colors.isDark;

    final colorInicioHero = isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF);
    final colorFinHero = isDark ? const Color(0xFF1E293B) : const Color(0xFFDBEAFE);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorInicioHero, colorFinHero],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: true,
        child: MaxWidthContainer(
          maxWidth: 560,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. FILA SUPERIOR: Menú, Perfil, Modo Oscuro, Ajustes e Info (SIN OVERFLOWS)
              Row(
                children: [
                  _buildChip(
                    context,
                    label: "☰ Secciones",
                    onTap: onOpenMenu,
                  ),
                  const SizedBox(width: 6),
                  Flexible(child: _buildPerfilChip(context)),
                  const Spacer(),
                  ThemeToggleSwitch(
                    modoOscuro: modoOscuro,
                    onTap: onToggleModoOscuro,
                  ),
                  const SizedBox(width: 4),
                  _buildChip(
                    context,
                    label: modoEdicionHero ? "💾 Guardar" : "⚙️",
                    backgroundColor: modoEdicionHero ? colors.verde.withValues(alpha: 0.3) : null,
                    onTap: onToggleEdicion,
                  ),
                  const SizedBox(width: 4),
                  _buildChip(
                    context,
                    label: "❓",
                    onTap: () => _mostrarInstructivo(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. SALUDO PERSONALIZADO Y BADGE FAENA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "¡Hola, $perfilActivo! 👋",
                          style: TextStyle(
                            color: isDark ? Colors.white : colors.azulOscuro,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Control de sondaje en terreno • Listo para Operar",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : colors.grisTexto,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.verde.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.verde.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.verde,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "En Faena",
                          style: TextStyle(
                            color: colors.verde,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. TARJETA DESTACADA MODIFICABLE (HERO BANNER SLOT ELEGANTE)
              InkWell(
                onTap: onBannerTap,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [Colors.white, const Color(0xFFF8FAFC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: modoEdicionHero ? colors.azul : colors.bordeSuave,
                      width: modoEdicionHero ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.azul.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.azul.withValues(alpha: 0.25)),
                        ),
                        child: Center(
                          child: Text(
                            bannerSlot?.emoji ?? "📋",
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.azul.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                modoEdicionHero ? "TOCA PARA CAMBIAR BANNER" : "MÓDULO DESTACADO",
                                style: TextStyle(
                                  color: colors.azul,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              bannerSlot?.titulo ?? "Paso a paso del turno",
                              style: TextStyle(
                                color: colors.azulOscuro,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              bannerSlot?.descripcion ?? "Toca para registrar tareas y verificar control diario",
                              style: TextStyle(
                                color: colors.grisTexto,
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: modoEdicionHero ? Colors.amber.withValues(alpha: 0.25) : colors.azul.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: modoEdicionHero ? Colors.amber : colors.azul.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          modoEdicionHero ? "Editar ✏️" : "Entrar ➔",
                          style: TextStyle(
                            color: modoEdicionHero ? Colors.amber.shade800 : colors.azul,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 4. TITULO ACCESOS RÁPIDOS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      modoEdicionHero ? "🛠️ Editando Accesos Directos" : "🚀 Accesos Rápidos",
                      style: TextStyle(
                        color: isDark ? Colors.white : colors.azulOscuro,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!modoEdicionHero)
                    Text(
                      "Usa '⚙️' para personalizar",
                      style: TextStyle(
                        color: isDark ? Colors.white38 : colors.grisSecundario,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // 5. GRID DE 4 SLOTS PERSONALIZABLES
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ShortcutSlot(
                              slotIndex: 0,
                              seccion: slots[0],
                              isEditable: modoEdicionHero,
                              onTap: () => onSlotTap(0),
                              onDelete: () => onSlotDelete(0),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ShortcutSlot(
                              slotIndex: 1,
                              seccion: slots[1],
                              isEditable: modoEdicionHero,
                              onTap: () => onSlotTap(1),
                              onDelete: () => onSlotDelete(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ShortcutSlot(
                              slotIndex: 2,
                              seccion: slots[2],
                              isEditable: modoEdicionHero,
                              onTap: () => onSlotTap(2),
                              onDelete: () => onSlotDelete(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ShortcutSlot(
                              slotIndex: 3,
                              seccion: slots[3],
                              isEditable: modoEdicionHero,
                              onTap: () => onSlotTap(3),
                              onDelete: () => onSlotDelete(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 6. BARRA DE NAVEGACIÓN POR CATEGORÍAS DE APOYO (CARRUSEL HORIZONTAL)
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pilaresApp.length,
                  itemBuilder: (context, i) {
                    final pilar = pilaresApp[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: onOpenMenu,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.bordeSuave.withValues(alpha: 0.6)),
                          ),
                          child: Text(
                            "${pilar.emoji} ${pilar.titulo}",
                            style: TextStyle(
                              color: colors.azulOscuro,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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

  Widget _buildChip(
    BuildContext context, {
    required String label,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? colors.superficie.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.bordeSuave),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: colors.azulOscuro,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPerfilChip(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: () => _mostrarMenuPerfiles(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: colors.azul.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.azul.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("👤", style: TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                perfilActivo,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: colors.azul,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMenuPerfiles(BuildContext context) {
    final colors = AppColors.of(context);
    final nuevoPerfilCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.superficie,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Gestión de Perfiles", style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 17)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              ...perfiles.map((p) {
                final esActivo = p == perfilActivo;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: esActivo ? colors.azul.withValues(alpha: 0.12) : colors.superficieSuave,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: esActivo ? colors.azul : colors.bordeSuave),
                  ),
                  child: ListTile(
                    title: Text(p, style: TextStyle(color: colors.azulOscuro, fontWeight: esActivo ? FontWeight.bold : FontWeight.normal)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (esActivo) const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        if (perfiles.length > 1 && !esActivo)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () {
                              onPerfilDeleted(p);
                              Navigator.pop(ctx);
                            },
                          ),
                      ],
                    ),
                    onTap: () {
                      if (!esActivo) {
                        onPerfilChanged(p);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),
              TextField(
                controller: nuevoPerfilCtrl,
                decoration: InputDecoration(
                  labelText: "Crear Nuevo Perfil de Usuario",
                  hintText: "Ej: Pedro Soto",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () {
                      if (nuevoPerfilCtrl.text.trim().isNotEmpty) {
                        onPerfilChanged(nuevoPerfilCtrl.text.trim());
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarInstructivo(BuildContext context) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.superficie,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(ctx).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: colors.grisSecundario.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.menu_book_rounded, color: colors.azul, size: 24),
                const SizedBox(width: 8),
                Text("Guía de Uso de la Aplicación", style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 4),
            Text("Manual Técnico para Controladores de Sondaje", style: TextStyle(color: colors.grisTexto, fontSize: 12)),
            const Divider(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(
                      context,
                      icon: "🚀",
                      titulo: "Propósito de la App",
                      contenido: "Esta aplicación fue diseñada para el entrenamiento, asistencia técnica y control operacional continuo en plataformas de perforación diamantina (DDH). Permite evitar errores de cálculo de contra, pérdida de testigo o mala rotulación de bandejas.",
                    ),
                    _buildInfoSection(
                      context,
                      icon: "🏛️",
                      titulo: "Estructura en 4 Pilares",
                      contenido: "1. 🛠️ Herramientas de Campo\n2. 📚 Manual y Protocolos\n3. 🎯 Entrenamiento y Evaluación\n4. 💡 Asistentes e Inteligencia",
                    ),
                    _buildInfoSection(
                      context,
                      icon: "👤",
                      titulo: "Perfiles Multiusuario Independientes",
                      contenido: "Puedes cambiar o crear perfiles (ej. Juan Pérez, Pedro Soto). Cada perfil mantiene sus propias alarmas, accesos directos configurados e historial sin interferir con otros usuarios.",
                    ),
                    _buildInfoSection(
                      context,
                      icon: "⏰",
                      titulo: "Recordatorios y Alarmas de Terreno",
                      contenido: "Crea avisos por hora fija (ej. 14:00 hrs) o minutos de cuenta regresiva para tareas críticas. Soporta repeticiones diarias automáticas.",
                    ),
                    _buildInfoSection(
                      context,
                      icon: "🔐",
                      titulo: "PIN y Accesos de Instructor",
                      contenido: "• PIN Instructor por defecto: 9900\n(Para permisos avanzados de supervisión, consulta con tu instructor responsable)."
                    ),
                    _buildInfoSection(
                      context,
                      icon: "👨‍💻",
                      titulo: "Creador del Proyecto",
                      contenido: "Desarrollado y creado por Claudio Muñoz Rubilar.",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: colors.azul, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Entendido y Cerrar"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, {required String icon, required String titulo, required String contenido}) {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.superficieSuave, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.bordeSuave)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(titulo, style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13.5)),
            ],
          ),
          const SizedBox(height: 6),
          Text(contenido, style: TextStyle(color: colors.grisTexto, fontSize: 12, height: 1.35)),
        ],
      ),
    );
  }
}
