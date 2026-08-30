import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';

class CuadernoBienvenida extends StatelessWidget {
  final AppColors colors;
  final bool esModoManual;
  final Function(bool) onModoManualChanged;
  final TextEditingController manualPozoIdController;
  final TextEditingController manualBarrasController;
  final TextEditingController manualPuntoMuertoController;
  final TextEditingController manualBarrilController;
  final String nivelDificultad;
  final Function(bool) onDificultadChanged;
  final int cantidadCorridas;
  final Function(int?) onCantidadCorridasChanged;
  final bool iniciarConBarras300;
  final Function(bool) onIniciarConBarras300Changed;
  final bool usarExtensionReflex;
  final Function(bool) onUsarExtensionReflexChanged;
  final bool permitirCambioBarril;
  final Function(bool) onPermitirCambioBarrilChanged;
  final String direccionCambioBarril;
  final Function(String?) onDireccionCambioBarrilChanged;
  final int manualFilaCambioBarril;
  final Function(int?) onManualFilaCambioBarrilChanged;
  final bool permitirCambioSarta;
  final Function(bool) onPermitirCambioSartaChanged;

  final String pozoId;
  final double fondoInicial;
  final double contraInicial;
  final int barrasIniciales;
  final double largoBarra;
  final double puntoMuerto;
  final double barrilMedida;
  final bool esOrientado;
  final double herramientaTotal;

  final VoidCallback onComenzar;

  const CuadernoBienvenida({
    super.key,
    required this.colors,
    required this.esModoManual,
    required this.onModoManualChanged,
    required this.manualPozoIdController,
    required this.manualBarrasController,
    required this.manualPuntoMuertoController,
    required this.manualBarrilController,
    required this.nivelDificultad,
    required this.onDificultadChanged,
    required this.cantidadCorridas,
    required this.onCantidadCorridasChanged,
    required this.iniciarConBarras300,
    required this.onIniciarConBarras300Changed,
    required this.usarExtensionReflex,
    required this.onUsarExtensionReflexChanged,
    required this.permitirCambioBarril,
    required this.onPermitirCambioBarrilChanged,
    required this.direccionCambioBarril,
    required this.onDireccionCambioBarrilChanged,
    required this.manualFilaCambioBarril,
    required this.onManualFilaCambioBarrilChanged,
    required this.permitirCambioSarta,
    required this.onPermitirCambioSartaChanged,
    required this.pozoId,
    required this.fondoInicial,
    required this.contraInicial,
    required this.barrasIniciales,
    required this.largoBarra,
    required this.puntoMuerto,
    required this.barrilMedida,
    required this.esOrientado,
    required this.herramientaTotal,
    required this.onComenzar,
  });

  Widget _buildConfigTable(List<TableRow> rows) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(),
        1: FixedColumnWidth(95),
        2: FixedColumnWidth(55),
        3: FixedColumnWidth(95),
      },
      children: rows,
    );
  }

  Widget _buildDataRow(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.grisTexto, fontSize: 12.5)),
          Text(value, style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "📓",
            style: TextStyle(fontSize: 54),
          ),
          const SizedBox(height: 8),
          Text(
            "Ejercicios del Cuaderno",
            style: TextStyle(
              color: colors.azulOscuro,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "Simulación de registro operacional en terreno. Completa todas las celdas en blanco en tu planilla del cuaderno de terreno y verifica cuando desees.",
            style: TextStyle(
              color: colors.grisTexto,
              fontSize: 13.5,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Card(
            color: colors.superficie,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colors.bordeSuave, width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "CONFIGURACIÓN DE LA PRÁCTICA",
                      style: TextStyle(
                        color: colors.azul,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const Divider(height: 16, thickness: 1.2),

                  _buildConfigTable([
                    TableRow(
                      children: [
                        const TableCell(
                          child: Text(
                            "¿Activar Modo Manual (Casos de Colegas)?",
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const TableCell(child: SizedBox.shrink()),
                        TableCell(
                          child: Switch(
                            value: esModoManual,
                            onChanged: onModoManualChanged,
                            activeColor: colors.azul,
                          ),
                        ),
                        const TableCell(child: SizedBox.shrink()),
                      ],
                    ),
                  ]),
                  const Divider(height: 16),

                  if (esModoManual) ...[
                    Center(
                      child: Text(
                        "DATOS INICIALES MANUALES",
                        style: TextStyle(color: colors.azul, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: manualPozoIdController,
                      decoration: const InputDecoration(labelText: "Identificador del Pozo", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: manualBarrasController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Barras Iniciales en Sarta", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: manualPuntoMuertoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Punto Muerto (m)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: manualBarrilController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Barril Inicial (m)", border: OutlineInputBorder()),
                    ),
                  ] else ...[
                    _buildConfigTable([
                      TableRow(
                        children: [
                          const TableCell(
                            child: Text(
                              "Dificultad (Metraje Inicial):",
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                "Metro 0",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: nivelDificultad == "Básico" ? FontWeight.bold : FontWeight.normal,
                                  color: nivelDificultad == "Básico" ? colors.azul : colors.grisTexto,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Switch(
                              value: nivelDificultad == "Intermedio",
                              onChanged: onDificultadChanged,
                              activeColor: colors.azul,
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                "Metro al azar",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: nivelDificultad == "Intermedio" ? FontWeight.bold : FontWeight.normal,
                                  color: nivelDificultad == "Intermedio" ? colors.azul : colors.grisTexto,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 12),
                  ],

                  const Text("Cantidad de Perforaciones (Corridas)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: cantidadCorridas,
                    dropdownColor: colors.superficie,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 8,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
                    style: TextStyle(color: colors.azulOscuro, fontSize: 13.5),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text("5 Corridas")),
                      DropdownMenuItem(value: 10, child: Text("10 Corridas")),
                      DropdownMenuItem(value: 15, child: Text("15 Corridas")),
                      DropdownMenuItem(value: 20, child: Text("20 Corridas")),
                    ],
                    onChanged: onCantidadCorridasChanged,
                  ),
                  const SizedBox(height: 12),

                  _buildConfigTable([
                    TableRow(
                      children: [
                        const TableCell(
                          child: Text(
                            "Largo de Barra Inicial:",
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              "2.90 m",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: !iniciarConBarras300 ? FontWeight.bold : FontWeight.normal,
                                color: !iniciarConBarras300 ? colors.azul : colors.grisTexto,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Switch(
                            value: iniciarConBarras300,
                            onChanged: onIniciarConBarras300Changed,
                            activeColor: colors.azul,
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              "3.00 m",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: iniciarConBarras300 ? FontWeight.bold : FontWeight.normal,
                                color: iniciarConBarras300 ? colors.azul : colors.grisTexto,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const TableCell(
                          child: Text(
                            "Extensión del Reflex (Orientación):",
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              "Sin extensión",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: !usarExtensionReflex ? FontWeight.bold : FontWeight.normal,
                                  color: !usarExtensionReflex ? colors.azul : colors.grisTexto),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Switch(
                            value: usarExtensionReflex,
                            onChanged: onUsarExtensionReflexChanged,
                            activeColor: colors.azul,
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              "Con extensión",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: usarExtensionReflex ? FontWeight.bold : FontWeight.normal,
                                  color: usarExtensionReflex ? colors.azul : colors.grisTexto),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const TableCell(
                          child: Text(
                            "¿Incluir Cambio de Barril?",
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const TableCell(child: SizedBox.shrink()),
                        TableCell(
                          child: Switch(
                            value: permitirCambioBarril,
                            onChanged: onPermitirCambioBarrilChanged,
                            activeColor: colors.azul,
                          ),
                        ),
                        const TableCell(child: SizedBox.shrink()),
                      ],
                    ),
                  ]),

                  if (permitirCambioBarril) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Dirección Cambio Barril:",
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: direccionCambioBarril,
                            dropdownColor: colors.superficie,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 8,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
                            style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "Corto a Largo",
                                child: Text("2.60m → 4.15m"),
                              ),
                              DropdownMenuItem(
                                value: "Largo a Corto",
                                child: Text("4.15m → 2.60m"),
                              ),
                            ],
                            onChanged: onDireccionCambioBarrilChanged,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (esModoManual && permitirCambioBarril) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Corrida para cambio de barril:",
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: manualFilaCambioBarril.clamp(1, cantidadCorridas),
                            dropdownColor: colors.superficie,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 8,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
                            style: TextStyle(color: colors.azulOscuro, fontSize: 13.5, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: List.generate(cantidadCorridas, (idx) {
                              final runNum = idx + 1;
                              return DropdownMenuItem<int>(
                                value: runNum,
                                child: Text("Corrida $runNum"),
                              );
                            }),
                            onChanged: onManualFilaCambioBarrilChanged,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),
                  _buildConfigTable([
                    TableRow(
                      children: [
                        const TableCell(
                          child: Text(
                            "¿Incluir Cambio de Sarta (Barras)?",
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const TableCell(child: SizedBox.shrink()),
                        TableCell(
                          child: Switch(
                            value: permitirCambioSarta,
                            onChanged: onPermitirCambioSartaChanged,
                            activeColor: colors.azul,
                          ),
                        ),
                        const TableCell(child: SizedBox.shrink()),
                      ],
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            color: colors.superficie,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colors.bordeSuave, width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "DATOS INICIALES GENERADOS",
                      style: TextStyle(
                        color: colors.azul,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Divider(height: 16, thickness: 1.2),
                  _buildDataRow("Identificador del Pozo:", pozoId, colors),
                  _buildDataRow("Fondo Inicial:", "${fondoInicial.toStringAsFixed(2)} m", colors),
                  _buildDataRow("Contra Inicial:", "${contraInicial.toStringAsFixed(2)} m", colors),
                  _buildDataRow("Cantidad de Barras en Sarta:", "$barrasIniciales", colors),
                  _buildDataRow("Largo Inicial de Barra:", "${largoBarra.toStringAsFixed(2)} m", colors),
                  _buildDataRow("Punto Muerto:", "${puntoMuerto.toStringAsFixed(2)} m", colors),
                  _buildDataRow("Barril Inicial:", "${barrilMedida.toStringAsFixed(2)} m (${barrilMedida == 2.60 ? 'Corto' : 'Largo'})", colors),
                  _buildDataRow("Sondaje Orientado (Reflex):", esOrientado ? "Sí (+0.40m)" : "No", colors),
                  _buildDataRow("Herr Inicial (Total herramientas):", "${herramientaTotal.toStringAsFixed(2)} m", colors),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onComenzar,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.azul,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Comenzar Ejercicio",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
