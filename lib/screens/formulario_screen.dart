import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';
import 'package:aprender_a_controlar/screens/ejercicios/ejercicios_helpers.dart';

class FormularioScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;

  const FormularioScreen({
    super.key,
    required this.onNavigate,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
  });

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioItem {
  final String titulo;
  final String categoria;
  final String descripcion;
  final String formulaLatex;
  final List<String> variables;
  final String ejemploTitulo;
  final String ejemploProcedimiento;

  _FormularioItem({
    required this.titulo,
    required this.categoria,
    required this.descripcion,
    required this.formulaLatex,
    required this.variables,
    required this.ejemploTitulo,
    required this.ejemploProcedimiento,
  });
}

class _FormularioScreenState extends State<FormularioScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = "";

  final List<_FormularioItem> _formulas = [
    _FormularioItem(
      titulo: "Porcentaje de Recuperación Diamantina",
      categoria: "Recuperación",
      descripcion: "Calcula la proporción de testigo de roca recuperado en la bandeja respecto al intervalo perforado en la maniobra.",
      formulaLatex: r"\% \text{Rec} = \frac{\text{Testigo Recuperado}}{\text{Perforado}} \times 100",
      variables: [
        "Testigo Recuperado: Metros de roca física obtenidos en la bandeja.",
        "Perforado: Avance efectivo de la maniobra de perforación.",
      ],
      ejemploTitulo: "Ejemplo: Corrida de 3.00 m con 2.85 m en bandeja",
      ejemploProcedimiento: r"1. Dividendos: $2.85 / 3.00 = 0.95$" "\n" r"2. Multiplicar por 100: $0.95 \times 100 = 95.0\%$ " "\n" r"3. Resultado: $95.0\%$ de recuperación aceptable.",
    ),
    _FormularioItem(
      titulo: "Contra Ajustada (Adición de Barra)",
      categoria: "Contras",
      descripcion: "Determina la contra de referencia a registrar cuando la contra anterior es menor al avance perforado y se acopla una nueva barra a la sarta.",
      formulaLatex: r"\text{Contra Ajustada} = \text{Contra Anterior} + \text{Largo de Barra}",
      variables: [
        "Contra Anterior: Sobrante medido en la corrida previa.",
        "Largo de Barra: Longitud de la nueva barra acoplada (2.90 m o 3.00 m).",
      ],
      ejemploTitulo: "Ejemplo: Contra anterior 0.50 m, avance 1.80 m, barra de 2.90 m",
      ejemploProcedimiento: r"1. Condición: $0.50\text{ m} < 1.80\text{ m}$ (Se adiciona barra)." "\n" r"2. Suma: $0.50 + 2.90 = 3.40\text{ m}$" "\n" r"3. Resultado: Contra Ajustada = $3.40\text{ m}$.",
    ),
    _FormularioItem(
      titulo: "Nueva Contra (al finalizar corrida)",
      categoria: "Contras",
      descripcion: "Sabrante de barra que queda sobre el cabezal del rotador al terminar la maniobra de perforación.",
      formulaLatex: r"\text{Contra} = \text{Contra Ajustada} - \text{Perforado}",
      variables: [
        "Contra Ajustada: Contra inicial o ajustada por adición de barra.",
        "Perforado: Metros avanzados en la corrida.",
      ],
      ejemploTitulo: "Ejemplo: Contra Ajustada 3.40 m y perforado de 1.80 m",
      ejemploProcedimiento: r"1. Resta directa: $3.40 - 1.80 = 1.60\text{ m}$" "\n" r"2. Resultado: Nueva Contra a registrar = $1.60\text{ m}$.",
    ),
    _FormularioItem(
      titulo: "Herramientas Totales (Sarta de Perforación)",
      categoria: "Herramientas",
      descripcion: "Sumatoria del metraje de todas las barras, barril tomamuestras y accesorios en el pozo, descontando la altura del punto muerto.",
      formulaLatex: r"\text{Herr} = (\text{Barras} \times \text{Largo}) + \text{Barril} + \text{Extensión} - \text{PM}",
      variables: [
        "Barras x Largo: Total metros de tubos acoplados.",
        "Barril: Medida estandarizada (2.60 m o 4.15 m).",
        "Extensión Reflex: 0.40 m adicionales si se usa herramienta orientada.",
        "PM (Punto Muerto): Distancia del suelo a la marca de lectura del cabezal.",
      ],
      ejemploTitulo: "Ejemplo: 10 barras x 3.00 m, barril 2.60 m, Reflex 0.40 m, PM 0.50 m",
      ejemploProcedimiento: r"1. Barras: $10 \times 3.00 = 30.00\text{ m}$" "\n" r"2. Suma componentes: $30.00 + 2.60 + 0.40 - 0.50 = 32.50\text{ m}$" "\n" r"3. Resultado: Herramientas = $32.50\text{ m}$.",
    ),
    _FormularioItem(
      titulo: "Profundidad del Pozo (Fondo)",
      categoria: "Fondos",
      descripcion: "Fórmula de comprobación geométrica universal que relaciona la sarta de herramientas con el sobrante de contra.",
      formulaLatex: r"\text{Fondo} = \text{Herr} - \text{Contra}",
      variables: [
        "Herr: Herramientas totales dentro del pozo.",
        "Contra: Sobrante de barra medido en el cabezal.",
      ],
      ejemploTitulo: "Ejemplo: Herramientas de 32.50 m y contra de 1.60 m",
      ejemploProcedimiento: r"1. Resta: $32.50 - 1.60 = 30.90\text{ m}$" "\n" r"2. Resultado: Fondo actual del pozo = $30.90\text{ m}$.",
    ),
    _FormularioItem(
      titulo: "Avance Perforado por Fondos",
      categoria: "Fondos",
      descripcion: "Calcula los metros perforados mediante la diferencia entre la cota de fondo actual y la cota de fondo previa.",
      formulaLatex: r"\text{Perforado} = \text{Fondo Nuevo} - \text{Fondo Anterior}",
      variables: [
        "Fondo Nuevo: Cota de fondo al finalizar la maniobra.",
        "Fondo Anterior: Cota de fondo al iniciar la maniobra.",
      ],
      ejemploTitulo: "Ejemplo: Fondo anterior 29.10 m y fondo nuevo 30.90 m",
      ejemploProcedimiento: r"1. Resta: $30.90 - 29.10 = 1.80\text{ m}$" "\n" r"2. Resultado: Avance de la corrida = $1.80\text{ m}$.",
    ),
    _FormularioItem(
      titulo: "Tacos de Regularización (Pérdida de Testigo)",
      categoria: "Regularización",
      descripcion: "Determina la medida del taco de madera a instalar en las cajas portatestigos cuando la roca recuperada es menor al intervalo perforado.",
      formulaLatex: r"\text{Largo Taco} = \text{Intervalo Teórico} - \text{Testigo Recuperado}",
      variables: [
        "Intervalo Teórico: Avance perforado en ese tramo de caja.",
        "Testigo Recuperado: Roca física recuperada en ese tramo.",
      ],
      ejemploTitulo: "Ejemplo: Tramo de 1.50 m con 1.10 m recuperado",
      ejemploProcedimiento: r"1. Resta: $1.50 - 1.10 = 0.40\text{ m}$" "\n" r'2. Resultado: Fabricar e instalar taco de madera de $0.40\text{ m}$ rotulado "PÉRDIDA".',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final filtered = _formulas.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.titulo.toLowerCase().contains(query) ||
          item.categoria.toLowerCase().contains(query) ||
          item.descripcion.toLowerCase().contains(query);
    }).toList();

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
          "Formulario Matemático 📐",
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
      drawer: DrawerMenu(
        onNavigate: widget.onNavigate,
        modoOscuro: widget.modoOscuro,
        onToggleModoOscuro: widget.onToggleModoOscuro,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Buscar fórmula o concepto...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colors.superficie,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
          ),

          // List of Formulas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final item = filtered[idx];
                return Card(
                  color: colors.superficie,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: colors.bordeSuave, width: 1.2),
                  ),
                  child: ExpansionTile(
                    key: ValueKey(item.titulo),
                    title: Text(
                      item.titulo,
                      style: TextStyle(
                        color: colors.azulOscuro,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.azulClaro,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.categoria,
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 16),
                            Text(
                              item.descripcion,
                              style: TextStyle(color: colors.grisTexto, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 12),

                            // LaTeX Formula Box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: colors.bordeSuave),
                              ),
                              alignment: Alignment.center,
                              child: textWithLatex(
                                colors,
                                "\$\$${item.formulaLatex}\$\$",
                                style: TextStyle(
                                  color: colors.azul,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Variables breakdown
                            Text(
                              "Desglose de Variables:",
                              style: TextStyle(
                                color: colors.azulOscuro,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...item.variables.map(
                              (v) => Padding(
                                padding: const EdgeInsets.only(bottom: 3.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("• ", style: TextStyle(color: colors.azul, fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(
                                        v,
                                        style: TextStyle(color: colors.grisTexto, fontSize: 12.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Practical Example Box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.verdeClaro.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: colors.verde.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "💡 ${item.ejemploTitulo}",
                                    style: TextStyle(
                                      color: colors.verde,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  textWithLatex(
                                    colors,
                                    item.ejemploProcedimiento,
                                    style: TextStyle(
                                      color: colors.azulOscuro,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
