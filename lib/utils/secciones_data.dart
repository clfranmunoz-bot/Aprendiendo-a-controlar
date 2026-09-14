import 'package:aprender_a_controlar/models/seccion.dart';

class PilarInfo {
  final String id;
  final String titulo;
  final String emoji;

  const PilarInfo({required this.id, required this.titulo, required this.emoji});
}

const List<PilarInfo> pilaresApp = [
  PilarInfo(id: "todos", titulo: "Todos", emoji: "⚡"),
  PilarInfo(id: "campo", titulo: "Herramientas de Campo", emoji: "🛠️"),
  PilarInfo(id: "manual", titulo: "Manual y Protocolos", emoji: "📚"),
  PilarInfo(id: "entrenamiento", titulo: "Entrenamiento", emoji: "🎯"),
  PilarInfo(id: "asistentes", titulo: "Asistentes y Apoyo", emoji: "💡"),
];

final List<SeccionApp> catalogoSecciones = [
  // 🛠️ PILAR 1: HERRAMIENTAS DE CAMPO (DÍA A DÍA)
  const SeccionApp(
    id: "checklist_turno",
    titulo: "Paso a paso del turno",
    descripcion: "Control diario, tareas críticas y de supervisión",
    emoji: "📋",
    colorIndex: 10,
    pilar: "campo",
  ),
  const SeccionApp(
    id: "calculadoras",
    titulo: "Calculadoras operacionales",
    descripcion: "Recuperación, contra, fondo y regularización",
    emoji: "🧮",
    colorIndex: 2,
    pilar: "campo",
  ),
  const SeccionApp(
    id: "recordatorios",
    titulo: "Recordatorios y Alarmas",
    descripcion: "Alarmas y avisos de tareas críticas en terreno",
    emoji: "⏰",
    colorIndex: 3,
    pilar: "campo",
  ),
  const SeccionApp(
    id: "notas",
    titulo: "Notas de Campo",
    descripcion: "Bitácora de observaciones, dudas, dictado por voz y fotos",
    emoji: "📝",
    colorIndex: 21,
    pilar: "campo",
  ),
  const SeccionApp(
    id: "camara_fotos",
    titulo: "Fotografiar bandejas",
    descripcion: "Cámara de inspección con ayuda memoria visual",
    emoji: "📷",
    colorIndex: 1,
    pilar: "campo",
  ),
  const SeccionApp(
    id: "mapa_satelital",
    titulo: "Mapa Satelital & GPS",
    descripcion: "Ubicación offline en faena, pozos, distancias y UTM",
    emoji: "🛰️",
    colorIndex: 6,
    pilar: "campo",
  ),

  // 📚 PILAR 2: MANUAL Y PROTOCOLOS DE SONDAJE
  const SeccionApp(
    id: "aprender_procedimiento",
    titulo: "Pasos fundamentales simplificados",
    descripcion: "Flujo completo de control paso a paso en terreno",
    emoji: "📚",
    colorIndex: 1,
    pilar: "manual",
  ),
  const SeccionApp(
    id: "tutorial",
    titulo: "Guía de Inicio Rápido",
    descripcion: "Conceptos, glosario y tutorial operacional",
    emoji: "📖",
    colorIndex: 18,
    pilar: "manual",
  ),
  const SeccionApp(
    id: "glosario",
    titulo: "Glosario Técnico",
    descripcion: "Términos y conceptos técnicos de sondaje",
    emoji: "📖",
    colorIndex: 4,
    pilar: "manual",
  ),
  const SeccionApp(
    id: "criterios_medicion",
    titulo: "Criterios de medición",
    descripcion: "Pérdida de testigo y criterios de castigo",
    emoji: "📐",
    colorIndex: 5,
    pilar: "manual",
  ),
  const SeccionApp(
    id: "rotulacion_bandejas",
    titulo: "Rotulación de bandejas",
    descripcion: "Trazabilidad de bandejas y rotulado correcto",
    emoji: "🏷️",
    colorIndex: 11,
    pilar: "manual",
  ),
  const SeccionApp(
    id: "seguridad_riesgos",
    titulo: "Seguridad y riesgos",
    descripcion: "EPP y riesgos críticos en perforación",
    emoji: "🛡️",
    colorIndex: 8,
    pilar: "manual",
  ),
  const SeccionApp(
    id: "reportabilidad",
    titulo: "Reportabilidad",
    descripcion: "Datos mínimos de turno y entrega de reportes",
    emoji: "📊",
    colorIndex: 9,
    pilar: "manual",
  ),
  const SeccionApp(
    id: "mapas_conceptuales",
    titulo: "Mapas conceptuales",
    descripcion: "Esquemas y resúmenes visuales de apoyo",
    emoji: "🗺️",
    colorIndex: 6,
    pilar: "manual",
  ),
  const SeccionApp(
    id: "hacer_cuaderno",
    titulo: "Hacer cuaderno",
    descripcion: "Guía paso a paso para rehacer plantilla de terreno",
    emoji: "📓",
    colorIndex: 7,
    pilar: "manual",
  ),
  const SeccionApp(
    id: "tricono_diametro",
    titulo: "Diámetro y otros",
    descripcion: "Cambios de diámetro y tramos de perforación",
    emoji: "⚙️",
    colorIndex: 12,
    pilar: "manual",
  ),
  const SeccionApp(
    id: "procedimientos_teoricos",
    titulo: "Procedimientos",
    descripcion: "Descripción y protocolos operacionales estándar (Próximamente)",
    emoji: "📑",
    colorIndex: 14,
    pilar: "manual",
  ),
  const SeccionApp(
    id: "documentos_obligatorios",
    titulo: "Documentos obligatorios",
    descripcion: "Documentación y registros técnicos obligatorios (Próximamente)",
    emoji: "📄",
    colorIndex: 15,
    pilar: "manual",
  ),

  // 🎯 PILAR 3: ENTRENAMIENTO Y EVALUACIÓN
  const SeccionApp(
    id: "simulacro",
    titulo: "Simulacro de Turno",
    descripcion: "Practica el flujo completo de un turno: corridas, cálculos, cierre y evaluación",
    emoji: "🎯",
    colorIndex: 22,
    pilar: "entrenamiento",
  ),
  const SeccionApp(
    id: "ejercicios_cuaderno",
    titulo: "Ejercicios del cuaderno",
    descripcion: "Práctica de registro y cálculo secuencial de corridas",
    emoji: "✍️",
    colorIndex: 16,
    pilar: "entrenamiento",
  ),
  const SeccionApp(
    id: "ejercicios_practicos",
    titulo: "Ejercicios prácticos",
    descripcion: "Casos prácticos de cálculo en terreno",
    emoji: "🏋️",
    colorIndex: 13,
    pilar: "entrenamiento",
  ),
  const SeccionApp(
    id: "quiz_puntaje",
    titulo: "Quiz con puntaje",
    descripcion: "Evaluación y puntaje de conocimientos teóricos",
    emoji: "📝",
    colorIndex: 3,
    pilar: "entrenamiento",
  ),
  const SeccionApp(
    id: "stats",
    titulo: "Mis Estadísticas",
    descripcion: "Estadísticas, evolución y gráficos de rendimiento",
    emoji: "📊",
    colorIndex: 17,
    pilar: "entrenamiento",
  ),

  // 💡 PILAR 4: ASISTENTES E INTELIGENCIA DE APOYO
  const SeccionApp(
    id: "chatbot",
    titulo: "DrillBot Asistente",
    descripcion: "Chatbot inteligente de respuestas inmediatas offline",
    emoji: "🤖",
    colorIndex: 20,
    pilar: "asistentes",
  ),
  const SeccionApp(
    id: "formulario",
    titulo: "Formulario Matemático",
    descripcion: "Ecuaciones con LaTeX, desglose y ejemplos resueltos",
    emoji: "📐",
    colorIndex: 19,
    pilar: "asistentes",
  ),
  const SeccionApp(
    id: "instructor_panel",
    titulo: "Panel del Instructor",
    descripcion: "Supervisión, ranking de rendimiento y reportes grupales",
    emoji: "👥",
    colorIndex: 23,
    pilar: "asistentes",
  ),
];

SeccionApp? obtenerSeccionPorId(String id) {
  if (id == "calculadora_recuperacion" || id == "calculadora_contra" || id == "simulador_regularizacion") {
    return catalogoSecciones.firstWhere((s) => s.id == "calculadoras");
  }
  for (var seccion in catalogoSecciones) {
    if (seccion.id == id) {
      return seccion;
    }
  }
  return null;
}
