import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/secciones_data.dart';
import 'package:aprender_a_controlar/models/seccion.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';
import 'package:aprender_a_controlar/widgets/latex_formula.dart';

class DetallesScreen extends StatefulWidget {
  final String seccionId;
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;
  final Function(String) onNavigate;

  const DetallesScreen({
    super.key,
    required this.seccionId,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
    required this.onNavigate,
  });

  @override
  State<DetallesScreen> createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final seccion = obtenerSeccionPorId(widget.seccionId);

    if (seccion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Sección no encontrada.")),
      );
    }

    final accentColor = colors.getMenuColor(seccion.colorIndex);

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerMenu(
        onNavigate: widget.onNavigate,
        modoOscuro: widget.modoOscuro,
        onToggleModoOscuro: widget.onToggleModoOscuro,
      ),
      appBar: AppBar(
        title: Text(seccion.titulo),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => widget.onNavigate("home"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                border: Border(
                  bottom: BorderSide(
                    color: accentColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: accentColor.withOpacity(0.2),
                    child: Text(
                      seccion.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seccion.titulo,
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          seccion.descripcion,
                          style: TextStyle(
                            color: colors.grisTexto,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Area by ID
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildContenidoSeccion(context, seccion),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenidoSeccion(BuildContext context, SeccionApp seccion) {
    switch (widget.seccionId) {
      case "criterios_medicion":
        return _buildCriteriosMedicion(context);
      case "seguridad_riesgos":
        return _buildSeguridadRiesgos(context);
      case "reportabilidad":
        return _buildReportabilidad(context);
      case "rotulacion_bandejas":
        return _buildRotulacionBandejas(context);
      case "tricono_diametro":
        return _buildTriconoDiametro(context);
      case "hacer_cuaderno":
        return _buildHacerCuaderno(context);
      case "mapas_conceptuales":
        return _buildMapasConceptuales(context);
      default:
        return Center(
          child: Text(
            "Contenido no disponible para ${seccion.titulo}",
            style: const TextStyle(fontSize: 15),
          ),
        );
    }
  }

  // Cards layout builders
  Widget _buildCriteriosMedicion(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        _buildInfoCard(
          context,
          icon: "❓",
          title: "¿Para qué sirve?",
          desc:
              "Ayuda a estimar la recuperación exacta según el estado físico en que se encuentra el testigo de perforación: entero, fracturado o molido.",
          themeColor: colors.azul,
        ),
        _buildInfoCard(
          context,
          icon: "✅",
          title: "A. Muestra entera",
          desc:
              "Cuando el testigo está completo y es continuo, se considera como 100% recuperado. Solo se eliminan o descartan los espacios reales entre fracturas naturales.",
          themeColor: colors.verde,
        ),
        _buildInfoCard(
          context,
          icon: "🟡",
          title: "B1. Fracturada casi completa",
          desc:
              "Si los fragmentos están prácticamente unidos y aún se reconoce la forma cilíndrica de la roca, se puede considerar un porcentaje del 90% al 95%.",
          themeColor: colors.naranjo,
        ),
        _buildInfoCard(
          context,
          icon: "🟠",
          title: "B2. Fracturada con muchos trozos",
          desc:
              "Si los fragmentos son independientes pero llenan gran parte de la canaleta porta testigo, se aplica un castigo mayor basado en el porcentaje real de ocupación.",
          themeColor: colors.purpura,
        ),
        _buildInfoCard(
          context,
          icon: "🔴",
          title: "B3. Baja ocupación",
          desc:
              "Si los trozos ocupan aproximadamente la mitad de la canaleta, se castiga el largo medido en torno al 50%. Debe documentarse con precisión para evitar inflar el metraje.",
          themeColor: colors.rojo,
        ),
        _buildInfoCard(
          context,
          icon: "⚫",
          title: "C. Muestra molida fina",
          desc:
              "Corresponde a roca molida, arcillosa, arenosa o disgregada. Se mide visualmente según cuánto llena el espacio cilíndrico de la canaleta en la laina.",
          themeColor: colors.azul,
        ),
        _buildInfoCard(
          context,
          icon: "💡",
          title: "Regla práctica de terreno",
          desc:
              "Mientras más conserva el testigo su forma cilíndrica original, menor castigo aplicaremos. Mientras más molido, suelto o incompleto, mayor será el castigo a la recuperación física.",
          themeColor: colors.verde,
        ),
      ],
    );
  }

  Widget _buildSeguridadRiesgos(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        _buildInfoCard(
          context,
          icon: "⚠️",
          title: "Principio general",
          desc:
              "El controlador de sondajes debe ejecutar su tarea sin exponerse a energías no controladas, manteniéndose siempre en la zona segregada designada y respetando los controles.",
          themeColor: colors.azul,
        ),
        _buildInfoCard(
          context,
          icon: "🦺",
          title: "EPP básico obligatorio",
          desc:
              "Casco de seguridad con barbiquejo, lentes protectores, guantes de nitrilo/cabritilla, calzado de seguridad de caña alta, protección auditiva (tapones/copas), respirador con filtros para polvo y chaleco reflectante.",
          themeColor: colors.verde,
        ),
        _buildInfoCard(
          context,
          icon: "🚧",
          title: "Segregación física",
          desc:
              "El área de trabajo del inspector debe estar delimitada mediante conos, cadenas o cintas de seguridad respecto al equipo de perforación. Nunca traspasar al área directa del perforista sin coordinación.",
          themeColor: colors.naranjo,
        ),
        _buildInfoCard(
          context,
          icon: "😷",
          title: "Prevención ante Sílice libre",
          desc:
              "En zonas con polvo en suspensión o manipulación de lodos secos, el uso de protección respiratoria tipo P100 es mandatorio. Realizar chequeos y limpiezas diarias.",
          themeColor: colors.purpura,
        ),
        _buildInfoCard(
          context,
          icon: "🔊",
          title: "Exposición a Ruido industrial",
          desc:
              "La plataforma cuenta con motores de alta potencia. El uso de protección auditiva es doble o simple según el área señalizada, y obligatorio en presencia de ruido.",
          themeColor: colors.rojo,
        ),
        _buildInfoCard(
          context,
          icon: "☀️",
          title: "Radiación UV y deshidratación",
          desc:
              "El trabajo en terreno expone a climas extremos. Es vital usar bloqueador solar factor 50+, gorro legionario acoplado al casco, mangas protectoras e hidratación constante.",
          themeColor: colors.azul,
        ),
        _buildInfoCard(
          context,
          icon: "🪨",
          title: "Riesgo de caída de rocas",
          desc:
              "Al inspeccionar taludes o acopiar testigos en laderas, mantener distancia prudente, respetar delimitaciones geológicas y reportar de inmediato grietas o condiciones subestándar.",
          themeColor: colors.verde,
        ),
        _buildInfoCard(
          context,
          icon: "📦",
          title: "Manipulación de bandejas de roca",
          desc:
              "Evitar sobreesfuerzos al levantar bandejas (peso máximo permitido). Usar técnicas de postura correctas (doblar rodillas, espalda recta) para prevenir lesiones lumbares.",
          themeColor: colors.naranjo,
        ),
      ],
    );
  }

  Widget _buildReportabilidad(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        _buildInfoCard(
          context,
          icon: "🎯",
          title: "Objetivo operacional",
          desc:
              "La reportabilidad deja un respaldo legal e institucional de la operación diaria del turno, controlando avances por máquina, rendimientos, desviaciones geotécnicas y consumos.",
          themeColor: colors.azul,
        ),
        _buildInfoCard(
          context,
          icon: "📝",
          title: "Datos de control (mínimos)",
          desc:
              "Fecha del reporte, turno (Día/Noche), nombre del controlador, código de la sonda, número e identificación del pozo, número correlativo de la bandeja, metrajes 'Desde' y 'Hasta', y observaciones geológicas.",
          themeColor: colors.verde,
        ),
        _buildInfoCard(
          context,
          icon: "⛏️",
          title: "Métricas de perforación",
          desc:
              "Registrar metraje inicial y final de corrida, metros perforados efectivos, metros recuperados físicos, porcentaje calculado de recuperación (%), diámetro del pozo y largo de las barras usadas.",
          themeColor: colors.naranjo,
        ),
        _buildInfoCard(
          context,
          icon: "🔩",
          title: "Herramientas de pozo",
          desc:
              "Detalle completo de coronas diamantadas (serie, tipo, desgaste), escareadores, zapatas, largo total de la herramienta de fondo, casing instalado y uso de aditivos químicos.",
          themeColor: colors.purpura,
        ),
        _buildInfoCard(
          context,
          icon: "🚨",
          title: "Situaciones y anomalías",
          desc:
              "Incidentes operacionales, tiempos perdidos, rotura de barras, atrapes de herramienta, pérdidas de circulación de agua, testigos molidos o colapsados de pozo que afecten la calidad geológica.",
          themeColor: colors.rojo,
        ),
        _buildInfoCard(
          context,
          icon: "🏁",
          title: "Cierre de Pozo (Término)",
          desc:
              "Documentar la finalización del sondaje, profundidad total alcanzada, encamisado final del pozo, retiro seguro de barras e instalación de tapón con coordenadas de GPS.",
          themeColor: colors.azul,
        ),
      ],
    );
  }

  Widget _buildRotulacionBandejas(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        _buildInfoCard(
          context,
          icon: "🎯",
          title: "Objetivo de trazabilidad",
          desc:
              "La rotulación definitiva asegura que el testigo conserve su origen e identidad geológica. Un error de rotulado invalida muestras que cuestan miles de dólares y confunde los modelos.",
          themeColor: colors.azul,
        ),
        _buildInfoCard(
          context,
          icon: "📌",
          title: "Datos principales en cabezal",
          desc:
              "El cabezal de cada bandeja porta testigo debe contener con letra gruesa e indeleble: Identificador del Pozo (ej. DDH-204A), metraje de inicio (DESDE), metraje de término (HASTA) y el Número correlativo de Bandeja.",
          themeColor: colors.verde,
        ),
        _buildInfoCard(
          context,
          icon: "🗺️",
          title: "Ubicación espacial de marcas",
          desc:
              "Tanto en el cabezal de madera o plástico como en los tacos divisores, la lectura se realiza de izquierda a derecha. Escribir los números en la dirección de avance de la perforación.",
          themeColor: colors.naranjo,
        ),
        _buildInfoCard(
          context,
          icon: "✍️",
          title: "Calidad y claridad de escritura",
          desc:
              "Evitar abreviaciones dudosas y usar números claros. Si ocurre una enmienda, tachar de forma simple y firmar al lado con la fecha, sin destruir la legibilidad del dato original.",
          themeColor: colors.purpura,
        ),
        _buildInfoCard(
          context,
          icon: "✅",
          title: "Chequeo de salida (Prevención)",
          desc:
              "Antes de tapar, asegurar y despachar la bandeja al taller de logueo, comparar las marcas de metraje contra el reporte firmado de la sonda para garantizar discrepancia cero.",
          themeColor: colors.rojo,
        ),
      ],
    );
  }

  Widget _buildTriconoDiametro(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        _buildInfoCard(
          context,
          icon: "⛏️",
          title: "Perforación con tricono",
          desc:
              "En horizontes de sobrecarga (suelos, rocas descompuestas o gravas), se perfora con tricono para ensanchar o avanzar sin obtener muestra física. Este tramo debe quedar claramente registrado.",
          themeColor: colors.azul,
        ),
        _buildInfoCard(
          context,
          icon: "📏",
          title: "Registro de tramo tricono",
          desc:
              "Señalizar el inicio y fin del tramo tricono. En la bandeja, en lugar de testigo de roca, se instala un taco largo de madera o plástico pintado de rojo indicando 'TRICONO' y el metraje del tramo.",
          themeColor: colors.verde,
        ),
        _buildInfoCard(
          context,
          icon: "🔄",
          title: "Reducción de diámetros",
          desc:
              "A medida que el pozo profundiza, la fricción obliga a reducir diámetros (ej. de PQ de 85mm a HQ de 63.5mm, o HQ a NQ de 47.6mm).",
          themeColor: colors.naranjo,
        ),
        _buildInfoCard(
          context,
          icon: "📍",
          title: "Instalación de taco divisor de cambio",
          desc:
              "En el punto exacto de la reducción de diámetro, colocar un taco especial marcado con la leyenda: 'REDUCCIÓN A [HQ/NQ]' indicando los metros para que el geólogo sepa el cambio de escala.",
          themeColor: colors.purpura,
        ),
        _buildInfoCard(
          context,
          icon: "🔗",
          title: "Trazabilidad continua del pozo",
          desc:
              "Mantener coherencia entre diámetros, tipo de barras informadas, corona en uso y bandejas despachadas. Cualquier alteración de continuidad genera errores en el cálculo final de regularización.",
          themeColor: colors.rojo,
        ),
      ],
    );
  }

  // Hacer Cuaderno view with gorgeous mockup table
  Widget _buildHacerCuaderno(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Introduction
        _buildInfoCard(
          context,
          icon: "📓",
          title: "Introducción al registro manuscrito",
          desc:
              "Aprende paso a paso cómo estructurar el formato oficial de control operacional de perforación diamantina en tu cuaderno de terreno de forma ordenada, profesional y sin errores.",
          themeColor: colors.azul,
        ),

        const SizedBox(height: 12),
        _buildSubtitulo("Paso 1: Preparación"),
        _buildParrafo(
          "Necesitarás un cuaderno cuadriculado o de líneas, un bolígrafo azul o negro, un lápiz de mina para marcas temporales y una regla técnica de 30 cm. Utiliza siempre una página nueva y limpia por cada pozo o jornada.",
        ),

        _buildSubtitulo("Paso 2: La Cabecera"),
        _buildParrafo(
          "En la primera línea superior escribe de forma horizontal los metadatos primarios de identificación:\n• Controlador: J. Pérez  • Fecha: 18/05/2026  • Turno: Día",
        ),

        _buildSubtitulo("Paso 3: Columnas de Especificaciones"),
        _buildParrafo(
          "Divide verticalmente la parte superior en dos columnas de texto alineadas para agrupar los parámetros operacionales y mecánicos del pozo de sondaje:",
        ),

        // Splitted parameters cards
        Row(
          children: [
            Expanded(
              child: Card(
                color: colors.superficie,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: colors.azul.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Columna Izquierda",
                        style: TextStyle(
                          color: colors.azul,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "• Sonda: DT-500\n• Pozo: DDH-204A\n• Azimuth: 180°\n• Inclinación: -60°\n• Barril: 4.15m\n• Punto muerto: 1.20m",
                        style: TextStyle(
                          color: colors.grisTexto,
                          fontSize: 11,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Card(
                color: colors.superficie,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: colors.verde.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Columna Derecha",
                        style: TextStyle(
                          color: colors.verde,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "• Corona: Diamantada N°9\n• Escariador: 6\" Standard\n• Zapata HWT: Reforzada\n• Casing HWT: 12.00m\n• Largo programado: 350m\n• Sector: Cordillera",
                        style: TextStyle(
                          color: colors.grisTexto,
                          fontSize: 11,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        _buildSubtitulo("Paso 4: Títulos y Enunciados de la Tabla"),
        _buildParrafo(
          "Debajo del bloque de parámetros, dibuja una tabla horizontal que contenga las 9 columnas mandatorias de terreno para llevar los cálculos operacionales de las corridas:",
        ),

        Card(
          color: colors.purpuraClaro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "1. Desde: Metraje inicial de la corrida.\n"
              "2. Hasta: Metraje final de la corrida.\n"
              "3. Perf: Largo total perforado (Hasta - Desde).\n"
              "4. Rec: Largo del testigo físico recuperado.\n"
              "5. % Rec: Eficiencia de recuperación calculated (%)\n"
              "6. Barras: Cantidad de barras bajadas al pozo.\n"
              "7. Herramientas: Total de la sumatoria de las barras en metros + el largo de barril.\n"
              "8. Contra: Barra sobrante informada por el perforista.\n"
              "9. Orient: ¿Testigo orientado por herramienta geotécnica? (Sí/No)",
              style: TextStyle(
                color: colors.purpura,
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        Card(
          color: colors.rojoClaro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colors.rojo, width: 1.5),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colors.rojo),
                    const SizedBox(width: 8),
                    Text(
                      "OBSERVACIÓN IMPORTANTE",
                      style: TextStyle(
                        color: colors.rojo,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Cuando hay un cambio de barril se debe saltar un reglón en el cuaderno y sumar la diferencia entre barriles (m) a la contra y al total de herramientas, en ese reglon vacío se debe escribir cambio de barril.",
                  style: TextStyle(
                    color: colors.azulOscuro,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "El barril corto mide 2.60 m y el largo 4.15 m, y en caso de que sea un sondaje orientado se suman 0.40 m de extensión para el reflex.",
                  style: TextStyle(
                    color: colors.grisTexto,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        _buildSubtitulo("Vista de Hoja de Cuaderno Simulada"),
        _buildParrafo(
          "A continuación se muestra un mockup digital fidedigno de cómo luce la planilla de terreno manuscrita en un cuaderno físico con papel crema, margen rojo y tinta azul clásica:",
        ),

        // Cream graph-paper card representation
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          constraints: const BoxConstraints(minHeight: 340),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF0), // Smooth Creamy Lined Paper
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC7A75C),
              width: 3,
            ), // Leather Cover Brown Border
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            painter: const _CuadernoGridPainter(),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Lined Margin Red Line
                  Container(
                    width: 2.5,
                    color: Colors.redAccent.withOpacity(0.85),
                    margin: const EdgeInsets.only(left: 14, right: 12),
                  ),

                  // Paper Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header ink blue
                          const Text(
                            "PLANILLA DE SONDAJE - TERRENO",
                            style: TextStyle(
                              color: Color(0xFF1F3A8A), // Classic Ink Blue
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              fontFamily: "Courier",
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Controlador: Juan Pérez  |  Sector: Cordillera  |  Fecha: 18/05/2026",
                            style: TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Courier",
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Sonda: DT-500\n"
                                  "Pozo: DDH-204A\n"
                                  "Azimuth: 180°\n"
                                  "Inclinación: -60°\n"
                                  "Barril: 4.15m\n"
                                  "Pto. Muerto: 1.20m",
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 8.5,
                                    height: 1.3,
                                    fontFamily: "Courier",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Corona: Diamantada N°9\n"
                                  "Escariador: 6\" Standard\n"
                                  "Zapata HWT: Reforzada\n"
                                  "Casing HWT: 12.00m\n"
                                  "L. Progr.: 350m\n"
                                  "Turno: Día",
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 8.5,
                                    height: 1.3,
                                    fontFamily: "Courier",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            color: Color(0xFF93C5FD),
                            thickness: 1.2,
                            height: 16,
                          ),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 525,
                              child: Table(
                                columnWidths: const {
                                  6: FixedColumnWidth(85), // Herramientas
                                },
                                defaultColumnWidth: const FixedColumnWidth(55),
                                border: TableBorder.all(
                                  color: const Color(0xFF60A5FA),
                                  width: 0.9,
                                ),
                                children: [
                                  _buildCuadernoTableHeader([
                                    "Desde",
                                    "Hasta",
                                    "Perf.",
                                    "Rec.",
                                    "% Rec",
                                    "Barras",
                                    "Herramientas",
                                    "Contra",
                                    "Orient",
                                  ]),
                                  _buildCuadernoTableRow([
                                    "120.50",
                                    "122.00",
                                    "1.50",
                                    "1.50",
                                    "100.0%",
                                    "40",
                                    "124.15",
                                    "0.95",
                                    "Sí",
                                  ]),
                                  _buildCuadernoTableRow([
                                    "122.00",
                                    "123.50",
                                    "1.50",
                                    "1.45",
                                    "96.7%",
                                    "40",
                                    "124.15",
                                    "0.45",
                                    "Sí",
                                  ]),
                                  _buildCuadernoTableRow([
                                    "123.50",
                                    "125.00",
                                    "1.50",
                                    "1.38",
                                    "92.0%",
                                    "41",
                                    "127.15",
                                    "0.95",
                                    "Sí",
                                  ]),
                                  _buildCuadernoTableRow([
                                    "125.00",
                                    "126.50",
                                    "1.50",
                                    "1.50",
                                    "100.0%",
                                    "41",
                                    "127.15",
                                    "0.45",
                                    "No",
                                  ]),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Obs: Se agrega barra N°41 a los 123.50m. Pérdida menor de testigo a los 124.50m por fractura natural geológica. Tacos instalados.",
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 9.5,
                              fontStyle: FontStyle.italic,
                              fontFamily: "Courier",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  TableRow _buildCuadernoTableHeader(List<String> cells) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFEFF6FF)),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Text(
            cell,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.bold,
              fontSize: 9,
              fontFamily: "Courier",
            ),
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildCuadernoTableRow(List<String> cells) {
    return TableRow(
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Text(
            cell,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
              fontFamily: "Courier",
            ),
          ),
        );
      }).toList(),
    );
  }

    // ─────────────────────────────────────────────────────────────────────────────
  // MAPAS CONCEPTUALES INTERACTIVOS (GRAFOS DE CONCEPTOS)
  // ─────────────────────────────────────────────────────────────────────────────
  int _mapSelectedTab = 0;
  final Map<int, int> _selectedNodePerMap = {0: 0, 1: 0, 2: 0, 3: 0};

  static final List<Map<String, dynamic>> _mapasDatos = [
    {
      "titulo": "Flujo de Control Operacional",
      "descripcion": "Grafo de relaciones del proceso estándar de control de sondaje en terreno.",
      "accent": Colors.blue,
      "nodes": [
        {
          "titulo": "Control",
          "subtitulo": "Rol del Controlador",
          "icono": Icons.engineering_outlined,
          "pos": Offset(178, 153),
          "detalle": "El Control de Sondaje es el proceso central de auditoría del pozo, donde se validan metrajes, calidad de roca y seguridad operacional en la plataforma.",
          "tip": "Tu presencia asegura que los datos geológicos reportados sean 100% reales."
        },
        {
          "titulo": "Seguridad",
          "subtitulo": "EPP y Segregación",
          "icono": Icons.shield,
          "pos": Offset(178, 30),
          "detalle": "La seguridad en la plataforma es la primera condición del control. Incluye el uso de EPP específico y el respeto estricto a las áreas delimitadas.",
          "tip": "Evita siempre la línea de fuego de las herramientas."
        },
        {
          "titulo": "Testigo",
          "subtitulo": "Muestra de Roca",
          "icono": Icons.terrain_outlined,
          "pos": Offset(20, 153),
          "detalle": "El testigo de roca diamantina es el producto físico recuperado del subsuelo. Representa la evidencia directa para la estimación mineral.",
          "tip": "Evita golpear o fracturar artificialmente la roca."
        },
        {
          "titulo": "Registros",
          "subtitulo": "Planilla y Reporte",
          "icono": Icons.assignment_outlined,
          "pos": Offset(336, 153),
          "detalle": "Los registros diarios consolidan el metraje perforado, recuperación de muestra y tiempos de operación para los reportes de supervisión.",
          "tip": "Escribe con números legibles y dos decimales."
        },
        {
          "titulo": "Regularizado",
          "subtitulo": "Ajuste de Metrajes",
          "icono": Icons.edit_note_outlined,
          "pos": Offset(178, 276),
          "detalle": "El regularizado es el proceso de ajustar las marcas del testigo a múltiplos exactos de un metro para referenciar pérdidas de muestra.",
          "tip": "Permite al geólogo saber dónde ocurrió la pérdida física."
        }
      ],
      "connections": [
        {"from": 0, "to": 1, "label": "exige"},
        {"from": 0, "to": 2, "label": "recupera"},
        {"from": 0, "to": 3, "label": "genera"},
        {"from": 0, "to": 4, "label": "aplica"}
      ]
    },
    {
      "titulo": "Procedimiento de Recuperación",
      "descripcion": "Conceptos clave involucrados en el cálculo del porcentaje de recuperación.",
      "accent": Colors.green,
      "nodes": [
        {
          "titulo": "Cálculo %",
          "subtitulo": "Ecuación de Calidad",
          "icono": Icons.calculate,
          "pos": Offset(178, 153),
          "detalle": "El Porcentaje de Recuperación indica qué proporción de la corrida teórica de roca fue efectivamente recuperada de forma física.",
          "tip": "La recuperación óptima es del 100%. Valores mayores indican anomalías."
        },
        {
          "titulo": "Perforado",
          "subtitulo": "Metraje de Corrida",
          "icono": Icons.compress_outlined,
          "pos": Offset(30, 40),
          "detalle": "Es la longitud teórica perforada en la corrida, determinada mediante la medición de la contra ajustada y la sarta de barras.",
          "tip": "Compara siempre con la sarta de herramientas totales."
        },
        {
          "titulo": "Recuperado",
          "subtitulo": "Longitud de Testigo",
          "icono": Icons.straighten,
          "pos": Offset(30, 260),
          "detalle": "Es la medición física real del testigo continuo alineado en la cuna metálica antes de ser traspasado a la bandeja.",
          "tip": "Mide a lo largo del eje central longitudinal."
        },
        {
          "titulo": "Fórmula",
          "subtitulo": "Relación Matemática",
          "icono": Icons.functions,
          "pos": Offset(336, 153),
          "detalle": "La fórmula matemática estándar compara el metraje recuperado contra el perforado y lo multiplica por 100 para obtener el porcentaje.",
          "tip": "Recuperación (%) = (Recuperado / Perforado) * 100."
        },
        {
          "titulo": "Castigos",
          "subtitulo": "Penalización de Roca",
          "icono": Icons.vertical_align_bottom,
          "pos": Offset(270, 260),
          "detalle": "Los castigos reducen la longitud recuperada considerada si el testigo está extremadamente molido o fragmentado por causas de operación.",
          "tip": "Asegura estimaciones honestas de la roca competente."
        }
      ],
      "connections": [
        {"from": 1, "to": 0, "label": "divide a"},
        {"from": 2, "to": 0, "label": "es dividido"},
        {"from": 0, "to": 3, "label": "aplica"},
        {"from": 0, "to": 4, "label": "se reduce por"}
      ]
    },
    {
      "titulo": "Metodología de Regularización",
      "descripcion": "Relación de conceptos para corregir metrajes tras pérdidas de muestra.",
      "accent": Colors.orange,
      "nodes": [
        {
          "titulo": "Regularizado",
          "subtitulo": "Ajuste de Testigos",
          "icono": Icons.push_pin_outlined,
          "pos": Offset(178, 153),
          "detalle": "El regularizado consiste en situar tacos en múltiplos exactos de un metro para ubicar geográficamente las pérdidas de roca.",
          "tip": "Previene el desfase acumulado en los metrajes del pozo."
        },
        {
          "titulo": "Tacos",
          "subtitulo": "Límites de Corrida",
          "icono": Icons.tag,
          "pos": Offset(30, 40),
          "detalle": "Los tacos plásticos colocados por el perforista marcan el Desde y Hasta oficial de cada corrida en la bandeja porta testigos.",
          "tip": "Lee con plumón permanente el metraje rotulado."
        },
        {
          "titulo": "Pérdida",
          "subtitulo": "Roca Faltante",
          "icono": Icons.terrain,
          "pos": Offset(30, 260),
          "detalle": "Diferencia física entre el metraje perforado y el testigo recuperado, comúnmente causada por fallas o zonas de cizalle blando.",
          "tip": "Ubicando la pérdida puedes marcar con exactitud el regularizado."
        },
        {
          "titulo": "Metraje",
          "subtitulo": "Metro Exacto",
          "icono": Icons.edit,
          "pos": Offset(336, 40),
          "detalle": "Punto múltiplo exacto de un metro donde se insertará el taco de regularización respectivo.",
          "tip": "Calcula y mide con huincha desde el taco inicial."
        },
        {
          "titulo": "Contra",
          "subtitulo": "Ajuste de Sarta",
          "icono": Icons.refresh,
          "pos": Offset(336, 260),
          "detalle": "La contra se ajusta en el cabezal de la máquina según las pérdidas regularizadas para mantener la coherencia del fondo.",
          "tip": "Corrige el metraje en el reporte de terreno."
        }
      ],
      "connections": [
        {"from": 1, "to": 0, "label": "delimita"},
        {"from": 2, "to": 0, "label": "determina"},
        {"from": 3, "to": 0, "label": "se marca a"},
        {"from": 0, "to": 4, "label": "corrige"}
      ]
    },
    {
      "titulo": "Protocolos Críticos de Seguridad",
      "descripcion": "Mapa relacional de los controles de seguridad en la plataforma de sondaje.",
      "accent": Colors.red,
      "nodes": [
        {
          "titulo": "Seguridad",
          "subtitulo": "Prevención Activa",
          "icono": Icons.shield, // will replace with Icons.shield below
          "pos": Offset(178, 153),
          "detalle": "El protocolo de seguridad busca garantizar el bienestar físico de la cuadrilla y del controlador de sondaje frente a energías móviles.",
          "tip": "Ninguna meta operacional justifica exponerse a un accidente."
        },
        {
          "titulo": "EPP",
          "subtitulo": "Protección Individual",
          "icono": Icons.engineering,
          "pos": Offset(178, 30),
          "detalle": "Uso de casco, lentes UV, zapatos de seguridad y protectores auditivos de forma obligatoria durante todo el turno.",
          "tip": "Mantén tus elementos limpios y en buen estado."
        },
        {
          "titulo": "Segregación",
          "subtitulo": "Área Delimitada",
          "icono": Icons.do_not_disturb_on_outlined,
          "pos": Offset(20, 153),
          "detalle": "Demarcación perimetral de la zona de trabajo con conos y cadenas para evitar ingresos involuntarios a radios de peligro.",
          "tip": "No cruces las cadenas mientras la sonda esté rotando."
        },
        {
          "titulo": "Coordinación",
          "subtitulo": "Señal de Ingreso",
          "icono": Icons.record_voice_over,
          "pos": Offset(336, 153),
          "detalle": "Contacto visual y autorización previa con el perforista antes de ingresar al área de movimiento de herramientas.",
          "tip": "Asegura que la máquina esté detenida al acercarte."
        },
        {
          "titulo": "Línea de Fuego",
          "subtitulo": "Radio de Peligro",
          "icono": Icons.dangerous,
          "pos": Offset(178, 276),
          "detalle": "Posicionamiento seguro fuera del radio de caída de herramientas, trayectoria del cable de wire line y partes giratorias.",
          "tip": "Identifica las vías de escape libres de obstáculos."
        }
      ],
      "connections": [
        {"from": 0, "to": 1, "label": "exige"},
        {"from": 0, "to": 2, "label": "mantiene"},
        {"from": 0, "to": 3, "label": "requiere"},
        {"from": 0, "to": 4, "label": "evita"}
      ]
    }
  ];

  Widget _buildMapasConceptuales(BuildContext context) {
    final colors = AppColors.of(context);
    final map = _mapasDatos[_mapSelectedTab];
    final String mapTitle = map['titulo'] as String;
    final String? mapDesc = map['descripcion'] as String?;
    final Color mapAccent = map['accent'] as Color? ?? colors.azul;
    final List<Map<String, dynamic>> nodes = List<Map<String, dynamic>>.from(map['nodes'] as List);
    final List<Map<String, dynamic>> connsRaw = List<Map<String, dynamic>>.from(map['connections'] as List);
    
    final int selectedNodeIdx = _selectedNodePerMap[_mapSelectedTab] ?? 0;
    final activeNode = nodes[selectedNodeIdx];

    // Build the connections list for CustomPainter
    final List<_MapConnection> connections = connsRaw.map((c) {
      return _MapConnection(
        c['from'] as int,
        c['to'] as int,
        c['label'] as String,
      );
    }).toList();

    // Node center offsets based on layout positions
    final List<Offset> nodeCenters = nodes.map((n) {
      final Offset pos = n['pos'] as Offset;
      // Add node radius (80x70 node has center offset by +40, +35)
      return Offset(pos.dx + 40, pos.dy + 35);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab selector con diseño Premium
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colors.superficie,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.bordeSuave),
            ),
            child: Row(
              children: List.generate(_mapasDatos.length, (index) {
                final m = _mapasDatos[index];
                final isSelected = _mapSelectedTab == index;
                final c = m['accent'] as Color;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _mapSelectedTab = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? c.withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        m['titulo'].toString().split(' ').last,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? c : colors.grisTexto,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Título y descripción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mapTitle,
                  style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (mapDesc != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      mapDesc,
                      style: TextStyle(color: colors.grisTexto, fontSize: 12, height: 1.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // LIENZO GRÁFICO DEL MAPA CONCEPTUAL (INTERACTIVO / DESPLAZABLE Y ZOOM)
          Center(
            child: Container(
              width: double.infinity,
              height: 340,
              decoration: BoxDecoration(
                color: colors.superficie,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.bordeSuave, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(80),
                      minScale: 0.65,
                      maxScale: 2.5,
                      constrained: false,
                      child: SizedBox(
                        width: 440,
                        height: 360,
                        child: Stack(
                          children: [
                            // Fondo de cuadrícula técnica sutil
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _GridPainter(colors.bordeSuave.withOpacity(0.4)),
                              ),
                            ),

                            // CustomPainter para dibujar las líneas de relación y etiquetas
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _MapConnectorPainter(
                                  connections: connections,
                                  nodeCenters: nodeCenters,
                                  accentColor: mapAccent,
                                  textColor: colors.azulOscuro,
                                  boxColor: colors.superficie,
                                ),
                              ),
                            ),

                            // Nodos interactivos colocados de forma absoluta
                            ...List.generate(nodes.length, (idx) {
                              final n = nodes[idx];
                              final pos = n["pos"] as Offset;
                              final isSelected = selectedNodeIdx == idx;

                              return Positioned(
                                left: pos.dx,
                                top: pos.dy,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedNodePerMap[_mapSelectedTab] = idx;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 80,
                                    height: 70,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? mapAccent : colors.superficieSuave,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected ? mapAccent : colors.bordeSuave,
                                        width: isSelected ? 2.5 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: mapAccent.withOpacity(0.35),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              )
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.02),
                                                blurRadius: 3,
                                                offset: const Offset(0, 2),
                                              )
                                            ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          idx == 0 && _mapSelectedTab == 3 ? Icons.shield : (n["icono"] as IconData),
                                          color: isSelected ? Colors.white : mapAccent,
                                          size: 20,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          n["titulo"].toString(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : colors.azulOscuro,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Badge flotante indicativo de gesto (Arrastra / Pinch Zoom)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.superficie.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.bordeSuave, width: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_outlined, size: 13, color: mapAccent),
                          const SizedBox(width: 4),
                          Text(
                            "Arrastra / Zoom",
                            style: TextStyle(fontSize: 10, color: colors.grisTexto, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // INSPECTOR DE CONCEPTO SELECCIONADO
          Card(
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: mapAccent.withOpacity(0.12),
                        child: Icon(
                          selectedNodeIdx == 0 && _mapSelectedTab == 3 ? Icons.shield : (activeNode['icono'] as IconData),
                          color: mapAccent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeNode['titulo'].toString(),
                              style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              activeNode['subtitulo'].toString(),
                              style: TextStyle(color: colors.grisTexto, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  
                  // Explicación conceptual
                  Text(
                    activeNode['detalle'].toString(),
                    style: TextStyle(color: colors.grisTexto, fontSize: 13, height: 1.45),
                  ),
                  const SizedBox(height: 14),

                  // Pro Tip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("💡", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activeNode['tip'].toString(),
                            style: TextStyle(color: colors.azulOscuro, fontSize: 11.5, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  // Base card styled wrapper
  Widget _buildInfoCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String desc,
    required Color themeColor,
  }) {
    final colors = AppColors.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.bordeSuave, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.azulOscuro,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: TextStyle(
                      color: colors.grisTexto,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lined helpers for notebook details layout
  Widget _buildSubtitulo(String text) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: colors.azulOscuro,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParrafo(String text) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(color: colors.grisTexto, fontSize: 13, height: 1.4),
      ),
    );
  }
}

class _CuadernoGridPainter extends CustomPainter {
  const _CuadernoGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final minorPaint = Paint()
      ..color = const Color(0xFFBFDBFE).withOpacity(0.55)
      ..strokeWidth = 0.6;
    final majorPaint = Paint()
      ..color = const Color(0xFF93C5FD).withOpacity(0.72)
      ..strokeWidth = 0.9;

    const step = 18.0;
    for (double x = 0; x <= size.width; x += step) {
      final paint = (x / step).round() % 5 == 0 ? majorPaint : minorPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      final paint = (y / step).round() % 5 == 0 ? majorPaint : minorPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CuadernoGridPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// CLASES AUXILIARES DE CONEXIONES Y DIBUJO DE GRAFOS
// ─────────────────────────────────────────────────────────────────────────────
class _MapConnection {
  final int from;
  final int to;
  final String label;

  const _MapConnection(this.from, this.to, this.label);
}

class _MapConnectorPainter extends CustomPainter {
  final List<_MapConnection> connections;
  final List<Offset> nodeCenters;
  final Color accentColor;
  final Color textColor;
  final Color boxColor;

  _MapConnectorPainter({
    required this.connections,
    required this.nodeCenters,
    required this.accentColor,
    required this.textColor,
    required this.boxColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = accentColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (final conn in connections) {
      if (conn.from >= nodeCenters.length || conn.to >= nodeCenters.length) continue;
      final start = nodeCenters[conn.from];
      final end = nodeCenters[conn.to];

      // Dibuja la línea de relación entre nodos
      canvas.drawLine(start, end, linePaint);

      // Dibuja punta de flecha apuntando al nodo destino
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final angle = atan2(dy, dx);
      
      final arrowLength = 9.0;
      final nodeRadius = 38.0; // Distancia desde el centro del nodo de 80x70
      final arrowTip = Offset(
        end.dx - nodeRadius * cos(angle),
        end.dy - nodeRadius * sin(angle),
      );

      final path = Path();
      path.moveTo(arrowTip.dx, arrowTip.dy);
      path.lineTo(
        arrowTip.dx - arrowLength * cos(angle - 0.35),
        arrowTip.dy - arrowLength * sin(angle - 0.35),
      );
      path.lineTo(
        arrowTip.dx - arrowLength * cos(angle + 0.35),
        arrowTip.dy - arrowLength * sin(angle + 0.35),
      );
      path.close();
      canvas.drawPath(path, arrowPaint);

      // Dibuja la etiqueta de relación en el punto medio de la línea
      final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      
      final textSpan = TextSpan(
        text: conn.label,
        style: TextStyle(
          color: accentColor,
          fontSize: 9.0,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // Dibuja fondo del texto de conexión para legibilidad
      final rectWidth = textPainter.width + 8;
      final rectHeight = textPainter.height + 4;
      final rectPaint = Paint()..color = boxColor;
      final borderPaint = Paint()
        ..color = accentColor.withOpacity(0.2)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: mid, width: rectWidth, height: rectHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rrect, rectPaint);
      canvas.drawRRect(rrect, borderPaint);

      // Pinta texto
      textPainter.paint(
        canvas,
        Offset(mid.dx - textPainter.width / 2, mid.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MapConnectorPainter oldDelegate) => true;
}

class _GridPainter extends CustomPainter {
  final Color gridColor;

  _GridPainter(this.gridColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
