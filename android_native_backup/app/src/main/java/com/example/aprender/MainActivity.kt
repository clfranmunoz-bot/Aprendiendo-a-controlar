package com.example.aprender

import android.app.Activity
import android.app.AlertDialog
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.text.InputType
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.Space
import android.widget.TextView
import android.widget.Toast
import android.widget.TableLayout
import android.widget.TableRow
import android.widget.HorizontalScrollView
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import java.text.Normalizer
import java.util.Locale
import kotlin.math.round

class MainActivity : androidx.activity.ComponentActivity() {

    private var modoOscuro = false

    private val azul get() = if (modoOscuro) Color.rgb(129, 178, 240) else Color.rgb(59, 113, 202)
    private val azulOscuro get() = if (modoOscuro) Color.rgb(241, 245, 249) else Color.rgb(15, 23, 42)
    private val azulClaro get() = if (modoOscuro) Color.rgb(24, 34, 58) else Color.rgb(239, 246, 255)
    private val verde get() = if (modoOscuro) Color.rgb(110, 196, 162) else Color.rgb(46, 125, 96)
    private val verdeClaro get() = if (modoOscuro) Color.rgb(20, 38, 32) else Color.rgb(240, 253, 250)
    private val naranjo get() = if (modoOscuro) Color.rgb(235, 188, 110) else Color.rgb(194, 120, 3)
    private val naranjoClaro get() = if (modoOscuro) Color.rgb(42, 32, 18) else Color.rgb(254, 243, 199)
    private val rojo get() = if (modoOscuro) Color.rgb(232, 120, 133) else Color.rgb(190, 68, 84)
    private val rojoClaro get() = if (modoOscuro) Color.rgb(42, 24, 28) else Color.rgb(255, 240, 238)
    private val purpura get() = if (modoOscuro) Color.rgb(180, 155, 240) else Color.rgb(109, 40, 217)
    private val purpuraClaro get() = if (modoOscuro) Color.rgb(32, 24, 48) else Color.rgb(243, 232, 255)
    private val fondo get() = if (modoOscuro) Color.rgb(15, 23, 42) else Color.rgb(248, 250, 252)
    private val superficie get() = if (modoOscuro) Color.rgb(30, 41, 59) else Color.WHITE
    private val superficieSuave get() = if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(247, 250, 252)
    private val bordeSuave get() = if (modoOscuro) Color.rgb(51, 65, 85) else Color.rgb(226, 232, 240)
    private val grisTexto get() = if (modoOscuro) Color.rgb(203, 213, 225) else Color.rgb(71, 85, 105)
    private val grisSecundario get() = if (modoOscuro) Color.rgb(148, 163, 184) else Color.rgb(100, 116, 139)

    // Colores únicos para el menú principal (desaturados y balanceados)
    private val menu1 get() = if (modoOscuro) Color.rgb(129, 178, 240) else Color.rgb(59, 113, 202)
    private val menu2 get() = if (modoOscuro) Color.rgb(110, 196, 162) else Color.rgb(46, 125, 96)
    private val menu3 get() = if (modoOscuro) Color.rgb(235, 188, 110) else Color.rgb(194, 120, 3)
    private val menu4 get() = if (modoOscuro) Color.rgb(232, 120, 133) else Color.rgb(190, 68, 84)
    private val menu5 get() = if (modoOscuro) Color.rgb(180, 155, 240) else Color.rgb(112, 80, 180)
    private val menu6 get() = if (modoOscuro) Color.rgb(110, 200, 230) else Color.rgb(40, 140, 170)
    private val menu7 get() = if (modoOscuro) Color.rgb(150, 165, 180) else Color.rgb(90, 105, 120)
    private val menu8 get() = if (modoOscuro) Color.rgb(215, 175, 120) else Color.rgb(155, 115, 60)
    private val menu9 get() = if (modoOscuro) Color.rgb(145, 155, 235) else Color.rgb(85, 95, 175)
    private val menu10 get() = if (modoOscuro) Color.rgb(230, 140, 210) else Color.rgb(170, 80, 150)
    private val menu11 get() = if (modoOscuro) Color.rgb(175, 220, 120) else Color.rgb(115, 160, 60)
    private val menu12 get() = if (modoOscuro) Color.rgb(115, 210, 200) else Color.rgb(55, 150, 140)
    private val menu13 get() = if (modoOscuro) Color.rgb(235, 150, 100) else Color.rgb(175, 90, 40)

    // =========================================================================
    // CONFIGURACIÓN EDITABLE DEL BLOQUE SUPERIOR AZUL (HERO) Y WIDGETS INTERACTIVOS
    // =========================================================================
    data class HeroBlockConfig(
        val etiqueta: String,
        val titulo: String,
        val descripcion: String
    )

    data class HeroMetricaConfig(
        val valor: String,
        val etiqueta: String
    )

    data class SeccionApp(
        val id: String,
        val titulo: String,
        val descripcion: String,
        val esFuerte: Boolean,
        val accion: () -> Unit
    )

    private var modoEdicionHero = false
    private var enPortada = true
    private var teoricosAbierto = false
    private var practicosAbierto = false

    // 1. Textos principales del bloque azul
    private val heroBlockConfig = HeroBlockConfig(
        etiqueta = "Entrenamiento operacional",
        titulo = "Aprender a controlar sondajes",
        descripcion = "Practica recuperación, regularización, bandejas, seguridad y reportabilidad con una ruta de estudio mucho más clara."
    )

    // 2. Módulos y métricas rápidas mostradas en el bloque azul
    private val heroMetricasConfig = listOf(
        HeroMetricaConfig(valor = "9", etiqueta = "módulos teóricos"),
        HeroMetricaConfig(valor = "5", etiqueta = "herramientas prácticas")
    )

    // 3. Catálogo de todas las secciones disponibles en la app para asignar
    private fun obtenerCatalogoSecciones(): List<SeccionApp> = listOf(
        SeccionApp("aprender_procedimiento", "Aprender procedimiento", "Flujo completo de control", true) { mostrarAprender() },
        SeccionApp("calculadoras", "Calculadoras operacionales", "Recuperación, contra, fondo y regularización", false) { mostrarCalculadoras() },
        SeccionApp("quiz_puntaje", "Quiz con puntaje", "Evaluación y puntaje", false) { iniciarQuiz() },
        SeccionApp("criterios_medicion", "Criterios de medición", "Castigos del testigo", false) { mostrarCriteriosMedicion() },
        SeccionApp("seguridad_riesgos", "Seguridad y riesgos", "EPP y riesgos críticos", false) { mostrarSeguridadRiesgos() },
        SeccionApp("reportabilidad", "Reportabilidad", "Datos mínimos de turno", false) { mostrarReportabilidad() },
        SeccionApp("checklist_turno", "Paso a paso del turno", "Control diario y tareas", false) { mostrarChecklistTurno() },
        SeccionApp("rotulacion_bandejas", "Rotulación de bandejas", "Trazabilidad de bandejas", false) { mostrarRotulacionBandejas() },
        SeccionApp("tricono_diametro", "Tricono y diámetro", "Cambios y tramos", false) { mostrarTriconoDiametro() },
        SeccionApp("ejercicios_practicos", "Ejercicios prácticos", "Practica lo aprendido", false) { mostrarEjercicios() },
        SeccionApp("glosario", "Glosario", "Conceptos técnicos", false) { mostrarGlosario() },
        SeccionApp("mapas_conceptuales", "Mapas conceptuales", "Resumen visual de apoyo", false) { mostrarMapas() },
        SeccionApp("hacer_cuaderno", "Hacer cuaderno", "Guía para recrear plantilla", false) { mostrarHacerCuaderno() },
        SeccionApp("camara_fotos", "Fotografíar bandejas", "Revisión con ayuda memoria", false) { mostrarCamaraInspeccion() }
    )

    private fun obtenerSeccionPorId(id: String): SeccionApp? {
        val catalogo = obtenerCatalogoSecciones()
        if (id == "calculadora_recuperacion") {
            return SeccionApp("calculadoras", "Calculadoras operacionales", "Recuperación, contra, fondo y regularización", false) { mostrarCalculadoras(0) }
        }
        if (id == "calculadora_contra") {
            return SeccionApp("calculadoras", "Calculadoras operacionales", "Recuperación, contra, fondo y regularización", false) { mostrarCalculadoras(1) }
        }
        if (id == "simulador_regularizacion") {
            return SeccionApp("calculadoras", "Calculadoras operacionales", "Recuperación, contra, fondo y regularización", false) { mostrarCalculadoras(3) }
        }
        if (id == "calculadoras") {
            return catalogo.find { it.id == "calculadoras" }
        }
        return catalogo.find { it.id == id }
    }

    private fun eliminarSlot(slotIndex: Int) {
        val prefs = getSharedPreferences("hero_shortcuts_prefs", MODE_PRIVATE)
        prefs.edit().putString("slot_$slotIndex", "empty").apply()
        mostrarPortada()
    }

    private fun mostrarSelectorSecciones(slotIndex: Int) {
        val dialog = android.app.Dialog(this).apply {
            requestWindowFeature(android.view.Window.FEATURE_NO_TITLE)
            window?.setBackgroundDrawable(android.graphics.drawable.ColorDrawable(Color.TRANSPARENT))
        }

        val dialogView = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(20), dp(20), dp(20))
            background = fondoRedondeado(superficie, radio = 24)
        }

        val tvTitulo = TextView(this).apply {
            text = "Asignar acceso directo"
            textSize = 20f
            setTextColor(azulOscuro)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setPadding(0, 0, 0, dp(16))
            gravity = Gravity.CENTER_HORIZONTAL
        }
        dialogView.addView(tvTitulo)

        val scroll = ScrollView(this).apply {
            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(320)
            )
            layoutParams = params
        }

        val listaOpciones = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
        }

        val catalogo = obtenerCatalogoSecciones()
        catalogo.forEach { seccion ->
            val btnOpcion = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(dp(16), dp(12), dp(16), dp(12))
                gravity = Gravity.CENTER_VERTICAL
                background = fondoRedondeado(superficieSuave, radio = 14)
                
                val params = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, dp(8))
                layoutParams = params
            }

            val circulo = View(this).apply {
                background = fondoRedondeado(azul, radio = 6)
                val params = LinearLayout.LayoutParams(dp(8), dp(8))
                params.setMargins(0, 0, dp(12), 0)
                layoutParams = params
            }
            btnOpcion.addView(circulo)

            val tvTexto = TextView(this).apply {
                text = seccion.titulo
                textSize = 15f
                setTextColor(azulOscuro)
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            }
            btnOpcion.addView(tvTexto)

            aplicarInteraccion(btnOpcion) {
                val prefs = getSharedPreferences("hero_shortcuts_prefs", MODE_PRIVATE)
                prefs.edit().putString("slot_$slotIndex", seccion.id).apply()
                modoEdicionHero = false
                dialog.dismiss()
                mostrarPortada()
            }

            listaOpciones.addView(btnOpcion)
        }

        scroll.addView(listaOpciones)
        dialogView.addView(scroll)

        val btnCancelar = Button(this).apply {
            text = "Cancelar"
            textSize = 14f
            setTextColor(Color.WHITE)
            setAllCaps(false)
            background = fondoRedondeado(rojo, radio = 14)
            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, dp(16), 0, 0)
            layoutParams = params
            
            setOnClickListener {
                dialog.dismiss()
            }
        }
        dialogView.addView(btnCancelar)

        dialog.setContentView(dialogView)
        
        dialog.window?.let { w ->
            val displayMetrics = resources.displayMetrics
            val width = (displayMetrics.widthPixels * 0.88).toInt()
            w.setLayout(width, ViewGroup.LayoutParams.WRAP_CONTENT)
        }
        
        dialog.show()
    }
    // =========================================================================

    private var quizIndex = 0
    private var quizScore = 0
    private var preguntasQuizActuales: List<Pregunta> = emptyList()
    private var ejercicioIndex = 0
    private var ejerciciosActuales: List<EjercicioPractico> = emptyList()

    data class Pregunta(
        val enunciado: String,
        val opciones: List<String>,
        val correcta: Int,
        val retroalimentacion: String
    )

    data class EjercicioPractico(
        val titulo: String,
        val enunciado: String,
        val opciones: List<String>,
        val correcta: Int,
        val retroalimentacion: String
    )

    private val bancoPreguntasQuiz = listOf(
        Pregunta(
            enunciado = "La recuperación se calcula dividiendo muestra recuperada por muestra perforada y multiplicando por 100.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Esa es la fórmula base de recuperación."
        ),
        Pregunta(
            enunciado = "El taco de bloqueo y el taco de regularizado cumplen exactamente la misma función.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 1,
            retroalimentacion = "Falso. El taco de bloqueo separa corridas o tramos perforados. El taco de regularizado marca soportes de distancia."
        ),
        Pregunta(
            enunciado = "Si se recupera más de 100%, se debe revisar si hay muestra recuperada de una corrida anterior.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. La recuperación sobre 100% puede indicar muestra arrastrada o recuperada desde una corrida anterior."
        ),
        Pregunta(
            enunciado = "La muestra se debe traspasar a bandeja manteniendo el orden del testigo.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Mantener el orden del testigo es clave para que la información geológica sea confiable."
        ),
        Pregunta(
            enunciado = "La reportabilidad solo debe incluir el porcentaje de recuperación.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 1,
            retroalimentacion = "Falso. También se registran metrajes, diámetros, herramientas, observaciones, situaciones operacionales y datos de turno."
        ),
        Pregunta(
            enunciado = "El controlador debe mantenerse en zona segregada y no ingresar al área de perforación sin autorización.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. La segregación es un control crítico para evitar exposición a energías del equipo de perforación."
        ),
        Pregunta(
            enunciado = "El taco de regularizado debe representar lo más fielmente posible el metraje real del testigo.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Por eso se aplica criterio geológico y compensación cuando existe pérdida o mala recuperación."
        ),
        Pregunta(
            enunciado = "La muestra molida fina siempre se considera como 100% recuperada.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 1,
            retroalimentacion = "Falso. La muestra molida se mide según cuánto llena la canaleta y puede requerir castigo."
        ),
        Pregunta(
            enunciado = "La información de la bandeja debe escribirse con letra legible.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. La trazabilidad del testigo depende de registros claros y legibles."
        ),
        Pregunta(
            enunciado = "La baja recuperación debe informarse y registrarse cuando afecta la calidad de la muestra.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Toda condición que afecte la muestra debe quedar respaldada en reporte."
        ),
        Pregunta(
            enunciado = "El flexómetro es una herramienta útil para medir la longitud del testigo recuperado.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. El flexómetro permite medir los tramos recuperados."
        ),
        Pregunta(
            enunciado = "Si el testigo está compacto, se mide de manera continua.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. La muestra compacta permite una medición continua, descontando espacios reales cuando corresponda."
        ),
        Pregunta(
            enunciado = "Si el testigo está fracturado y conserva casi la forma cilíndrica, se puede considerar aproximadamente 90% a 95%.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Ese criterio se usa cuando los fragmentos casi conforman el volumen del testigo."
        ),
        Pregunta(
            enunciado = "Una muestra molida que ocupa cerca de la mitad de la canaleta se debe considerar siempre 100%.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 1,
            retroalimentacion = "Falso. Si ocupa cerca del 50%, se debe aplicar castigo importante."
        ),
        Pregunta(
            enunciado = "El cambio de diámetro debe quedar registrado.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Todo cambio de diámetro debe quedar registrado para mantener trazabilidad."
        ),
        Pregunta(
            enunciado = "La perforación con tricono, cuando no recupera muestra, no necesita registrarse.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 1,
            retroalimentacion = "Falso. El tramo perforado con tricono debe quedar registrado."
        ),
        Pregunta(
            enunciado = "La fractura inducida debe diferenciarse de una fractura natural.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Debe marcarse para no confundirla con una condición natural del testigo."
        ),
        Pregunta(
            enunciado = "El área de trabajo del controlador debe estar segregada respecto del equipo de perforación.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. La segregación ayuda a controlar la exposición a energías peligrosas."
        ),
        Pregunta(
            enunciado = "El controlador puede ingresar libremente al área del perforista si necesita mirar la muestra.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 1,
            retroalimentacion = "Falso. Debe solicitar autorización y cumplir controles de ingreso."
        ),
        Pregunta(
            enunciado = "El uso de protección respiratoria puede ser necesario en zonas con exposición a polvo con sílice.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. En zonas de riesgo se debe usar protección respiratoria adecuada."
        ),
        Pregunta(
            enunciado = "El uso de protección auditiva es parte de los controles frente a exposición a ruido.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. La protección auditiva es un control importante frente al ruido."
        ),
        Pregunta(
            enunciado = "La radiación UV se controla con bloqueador solar, hidratación y protección adecuada.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Son medidas básicas para controlar exposición UV."
        ),
        Pregunta(
            enunciado = "La caída de rocas debe reportarse y controlarse con medidas geotécnicas y distancia de seguridad.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Es un riesgo crítico que debe gestionarse."
        ),
        Pregunta(
            enunciado = "La bandeja debe registrar número de pozo, desde, hasta y número de bandeja.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Estos datos permiten mantener la trazabilidad."
        ),
        Pregunta(
            enunciado = "Antes de cerrar una bandeja completa, se deben chequear los datos registrados.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Se debe revisar la información antes de tapar y apilar."
        ),
        Pregunta(
            enunciado = "Una condición subestándar debe informarse al supervisor directo.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Las condiciones subestándares deben comunicarse oportunamente."
        ),
        Pregunta(
            enunciado = "La cantidad de barras utilizadas debe ser coherente con el fondo o profundidad del pozo.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Debe existir coherencia entre barras y profundidad alcanzada."
        ),
        Pregunta(
            enunciado = "El reporte puede entregarse con letra poco clara si el controlador lo explicó verbalmente.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 1,
            retroalimentacion = "Falso. El reporte debe ser limpio, claro y legible."
        ),
        Pregunta(
            enunciado = "El taco de bloqueo separa cada corrida o tramo perforado.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Sirve para identificar y separar tramos de perforación."
        ),
        Pregunta(
            enunciado = "El taco de regularizado se usa para marcar soportes de distancia definidos por el proyecto.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Se utiliza para marcar metrajes de referencia."
        ),
        Pregunta(
            enunciado = "Si se detecta exceso de agua, mala recuperación o problemas de operación, se debe registrar como situación operacional.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Toda situación que afecte la operación o la calidad de muestra debe quedar registrada."
        ),
        Pregunta(
            enunciado = "La muestra se puede mezclar entre bandejas si pertenece al mismo pozo.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 1,
            retroalimentacion = "Falso. El orden y continuidad del testigo deben mantenerse."
        ),
        Pregunta(
            enunciado = "El número de bandeja debe avanzar en orden con el avance del pozo.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Esto permite mantener continuidad y trazabilidad."
        ),
        Pregunta(
            enunciado = "El controlador debe registrar observaciones cuando existan cambios de taco o ajustes por recuperación mayor al 100%.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Estos ajustes deben quedar respaldados."
        ),
        Pregunta(
            enunciado = "El checklist de turno ayuda a reforzar controles antes, durante y después de la operación.",
            opciones = listOf("Verdadero", "Falso"),
            correcta = 0,
            retroalimentacion = "Correcto. Es una herramienta de apoyo para no omitir controles relevantes."
        )
    )

    private val ejercicios = listOf(
        EjercicioPractico(
            "Banco 01",
            "¿Cuál es el objetivo principal del procedimiento de control operacional de sondaje diamantino?",
            listOf(
                "Describir la metodología del servicio e identificar y controlar riesgos operacionales",
                "Definir únicamente la mantención de equipos de perforación",
                "Regular solo el ingreso de vehículos a la plataforma"
            ),
            0,
            "El procedimiento busca describir cómo se ejecuta el servicio y controlar riesgos que afecten seguridad, salud, medio ambiente y calidad."
        ),
        EjercicioPractico(
            "Banco 02",
            "¿A quién aplica el procedimiento de control operacional de sondajes diamantino?",
            listOf(
                "Solo a los supervisores de turno",
                "A todo el personal y actividades relacionadas con el servicio de control de sondajes MLP",
                "Solo al perforista y al geólogo"
            ),
            1,
            "El alcance indicado en el procedimiento abarca a todo el personal y a todas las actividades ligadas al servicio."
        ),
        EjercicioPractico(
            "Banco 03",
            "En zonas de riesgo por sílice, ¿qué protección respiratoria se exige en el procedimiento?",
            listOf(
                "Mascarilla de tela reutilizable",
                "Protector respiratorio de medio rostro con filtros P100",
                "Solo protector auditivo"
            ),
            1,
            "El EPP listado en el procedimiento exige protector respiratorio de medio rostro con filtros P100 para este riesgo."
        ),
        EjercicioPractico(
            "Banco 04",
            "¿Cuál es la función del wire line en la perforación diamantina?",
            listOf(
                "Extraer el tubo interior desde dentro de la columna de barras",
                "Cortar el testigo cuando no cabe en la bandeja",
                "Marcar el metraje de regularización"
            ),
            0,
            "El wire line es el cable acerado que sostiene al pescante y permite extraer el tubo interior."
        ),
        EjercicioPractico(
            "Banco 05",
            "¿Para qué sirve el pescante según el procedimiento?",
            listOf(
                "Para estabilizar la plataforma en terreno blando",
                "Para sacar el tubo interior porta testigo sin retirar barras",
                "Para medir el punto muerto del equipo"
            ),
            1,
            "El pescante está diseñado para extraer el tubo interior porta testigo a través del interior de las barras."
        ),
        EjercicioPractico(
            "Banco 06",
            "¿Qué describe mejor al tricono dentro del procedimiento?",
            listOf(
                "Una herramienta de perforación usada para rotación y empuje en el terreno",
                "Una pieza de rotulación de bandejas",
                "Un aditivo de perforación"
            ),
            0,
            "El procedimiento define el tricono como herramienta de perforación para rotación y empuje."
        ),
        EjercicioPractico(
            "Banco 07",
            "Si antes de iniciar la tarea se detecta una desviación y el ARTP no contempla un control específico, ¿qué corresponde hacer?",
            listOf(
                "Continuar el trabajo y registrar la desviación al final",
                "Detener el trabajo y buscar la mejora o control correspondiente",
                "Esperar a que llegue el siguiente turno"
            ),
            1,
            "El procedimiento indica detener el trabajo cuando no exista un control especificado y buscar la mejora antes de continuar."
        ),
        EjercicioPractico(
            "Banco 08",
            "Antes de comenzar la operación, el controlador o supervisor debe consultar características del pozo como:",
            listOf(
                "Cota, azimut, inclinación y profundidad",
                "Solo color de roca y clima",
                "Solo número de trabajadores y turno"
            ),
            0,
            "El procedimiento exige revisar cota, azimut, inclinación, profundidad y otros datos entregados por el mandante."
        ),
        EjercicioPractico(
            "Banco 09",
            "¿Dónde debe ubicarse normalmente el lugar de trabajo del controlador?",
            listOf(
                "Dentro del área de perforación, junto al piano",
                "En una zona segregada dentro de la plataforma y fuera del área de perforación",
                "Sobre la máquina sondeadora"
            ),
            1,
            "El lugar de trabajo debe estar segregado y fuera del área de perforación para evitar exposición a riesgos."
        ),
        EjercicioPractico(
            "Banco 10",
            "Si el controlador necesita ingresar al área de perforación para revisar la muestra, ¿qué debe ocurrir obligatoriamente?",
            listOf(
                "Debe solicitar autorización y recibir charla de ingreso a la zona segregada",
                "Puede ingresar si usa guantes y lentes",
                "Solo debe informar al geólogo al terminar"
            ),
            0,
            "El ingreso requiere autorización del perforista y charla de ingreso a la zona segregada."
        ),
        EjercicioPractico(
            "Banco 11",
            "¿Qué debe chequear el controlador respecto del barril y el punto muerto al iniciar la perforación?",
            listOf(
                "La medida del barril y del punto muerto, registrando la información en el reporte",
                "Solo el color del barril",
                "Solo la velocidad del huinche"
            ),
            0,
            "El procedimiento señala medir barril y punto muerto y registrar esos datos en el reporte de control."
        ),
        EjercicioPractico(
            "Banco 12",
            "Mientras el perforista extrae y posiciona el tubo interior en el mesón saca testigos, el controlador debe:",
            listOf(
                "Permanecer fuera del área segregada y fuera de la línea de fuego hasta ser autorizado",
                "Acercarse para ordenar la muestra inmediatamente",
                "Tomar fotografías desde el área del perforista"
            ),
            0,
            "El controlador no debe exponerse a la línea de fuego y debe esperar la autorización de ingreso."
        ),
        EjercicioPractico(
            "Banco 13",
            "Cuando se trabaja con una corona de diámetro HQ3, ¿qué indica la nota del procedimiento?",
            listOf(
                "Usar dos lainas en el tubo interior durante la perforación",
                "Eliminar el uso de tacos de bloqueo",
                "Duplicar el largo de las barras"
            ),
            0,
            "El procedimiento especifica el uso de dos lainas en el tubo interior al trabajar con HQ3."
        ),
        EjercicioPractico(
            "Banco 14",
            "¿Cuál es la forma ideal de medir recuperación y regularizado una vez recibida la muestra?",
            listOf(
                "Con la muestra aún en la laina y lo menos alterada posible",
                "Después de mezclar los trozos en la bandeja",
                "Solo una vez cerrada la bandeja"
            ),
            0,
            "La medición ideal se hace con la muestra en la laina, antes del traspaso, para no alterar el testigo."
        ),
        EjercicioPractico(
            "Banco 15",
            "¿Cómo debe realizarse siempre el traspaso del testigo a la bandeja?",
            listOf(
                "Desde abajo hacia arriba y de derecha a izquierda",
                "Desde arriba hacia abajo y de izquierda a derecha",
                "En el orden que deje más espacio libre"
            ),
            1,
            "El procedimiento fija ese orden para mantener continuidad y trazabilidad del testigo."
        ),
        EjercicioPractico(
            "Banco 16",
            "Durante el traspaso a bandeja, ¿qué espacio debe dejarse a cada lado de la bandeja?",
            listOf(
                "5 cm",
                "10 cm",
                "20 cm"
            ),
            1,
            "Se deben dejar 10 cm a cada lado y espacio suficiente para la ubicación de tacos."
        ),
        EjercicioPractico(
            "Banco 17",
            "Si queda roca molida en la zapata o porta resorte de la barra, el controlador debe:",
            listOf(
                "Desecharla para no contaminar la bandeja",
                "Sacarla totalmente y ubicarla en el lugar de la bandeja que corresponda",
                "Dejarla dentro de la barra y seguir perforando"
            ),
            1,
            "La roca molida debe retirarse y ubicarse en la posición correcta para no perder información del tramo."
        ),
        EjercicioPractico(
            "Banco 18",
            "Si el testigo no cabe en una canoa de la bandeja y se genera una fractura inducida, ¿cómo debe marcarse?",
            listOf(
                "Con dos // en plumón azul",
                "Con una X roja en la bandeja",
                "No se marca si quedó dentro de la misma bandeja"
            ),
            0,
            "La fractura inducida debe diferenciarse de una natural y el estándar señalado usa dos // en azul."
        ),
        EjercicioPractico(
            "Banco 19",
            "¿Dónde debe registrar manualmente el controlador la información de la operación?",
            listOf(
                "Solo en la memoria del equipo",
                "En el reporte diario y en el cuaderno de registro de cada sonda",
                "Únicamente en la bandeja porta testigo"
            ),
            1,
            "El procedimiento pide llevar ambos registros: reporte diario y cuaderno."
        ),
        EjercicioPractico(
            "Banco 20",
            "¿Qué información debe consultar al perforista respecto de las barras?",
            listOf(
                "El resto de barra o barra sobrante (contra) y registrarlo",
                "Solo el color de la barra usada",
                "La marca comercial del proveedor"
            ),
            0,
            "El controlador debe consultar la contra y registrarla como parte del control operacional."
        ),
        EjercicioPractico(
            "Banco 21",
            "¿Cómo debe entregarse al supervisor de turno la información de la perforación?",
            listOf(
                "Solo verbalmente al cambiar de turno",
                "En forma verbal y escrita, con hoja limpia y letra legible",
                "Solo mediante una fotografía de la bandeja"
            ),
            1,
            "El procedimiento exige respaldo verbal y escrito, con reporte claro y completo."
        ),
        EjercicioPractico(
            "Banco 22",
            "Cuando hay reducción de diámetro, ¿qué acción es correcta?",
            listOf(
                "Registrarla en la bandeja, indicar el inicio del cambio y ubicar un taco en la nueva bandeja",
                "Mantener la misma bandeja sin registrar nada",
                "Cambiar solamente el número de pozo"
            ),
            0,
            "Toda reducción de diámetro debe quedar claramente trazada en bandeja y con taco de cambio."
        ),
        EjercicioPractico(
            "Banco 23",
            "¿Cómo deben separarse entre sí las corridas o sacadas de barra para medir recuperación?",
            listOf(
                "Con un taco de bloqueo",
                "Con una línea azul en la bandeja",
                "Con una esponja en cada extremo"
            ),
            0,
            "Cada tramo perforado o corrida debe separarse mediante taco de bloqueo."
        ),
        EjercicioPractico(
            "Banco 24",
            "Si en la segunda corrida se recupera más de lo perforado, ¿cuál es la interpretación correcta?",
            listOf(
                "No se debe hacer ningún ajuste porque el dato está bien",
                "Probablemente se recuperó muestra perdida del tramo anterior y se debe ajustar la medición",
                "Siempre significa que el perforista cambió de diámetro"
            ),
            1,
            "La recuperación superior al 100% suele deberse a muestra del tramo anterior recuperada en la siguiente carrera."
        ),
        EjercicioPractico(
            "Banco 25",
            "¿Dónde deben registrarse los cambios de taco de bloqueo?",
            listOf(
                "En el reporte diario y en el cuaderno",
                "Solo en la bandeja",
                "Solo en el libro de asistencia"
            ),
            0,
            "El procedimiento pide dejar trazabilidad de los cambios de taco tanto en reporte como en cuaderno."
        ),
        EjercicioPractico(
            "Banco 26",
            "¿Cada cuánto avance debe agregarse un taco de regularizado, salvo que el proyecto defina otro soporte?",
            listOf(
                "Cada 0,5 m",
                "Cada 2 m",
                "Cada 5 m"
            ),
            1,
            "El estándar general indicado es marcar el avance cada 2 metros."
        ),
        EjercicioPractico(
            "Banco 27",
            "Respecto del taco y la línea de regularizado, ¿qué afirmación es correcta?",
            listOf(
                "El taco debe ponerse siempre; la línea con plumón solo cuando el testigo es compacto",
                "La línea siempre reemplaza al taco",
                "Ninguno se usa cuando la roca está disgregada"
            ),
            0,
            "El taco de regularizado siempre debe ir en la bandeja; la línea en el testigo solo si la roca está compacta."
        ),
        EjercicioPractico(
            "Banco 28",
            "¿Qué expresión representa correctamente la recuperación porcentual?",
            listOf(
                "Muestra recuperada / muestra perforada × 100",
                "Muestra perforada / muestra recuperada × 100",
                "Muestra recuperada + muestra perforada × 100"
            ),
            0,
            "La fórmula base del procedimiento divide lo recuperado por lo perforado y multiplica por 100."
        ),
        EjercicioPractico(
            "Banco 29",
            "El promedio ponderado de recuperaciones se calcula por cada:",
            listOf(
                "Tramo de regularizado",
                "Tramo de bloqueo",
                "Cambio de turno"
            ),
            1,
            "El procedimiento indica que el promedio ponderado se calcula por cada tramo de bloqueo."
        ),
        EjercicioPractico(
            "Banco 30",
            "Si el testigo está entero y compacto, la medición de recuperación debe ser:",
            listOf(
                "Continua, eliminando solo espacios reales entre fracturas",
                "Castigada automáticamente en 25%",
                "Estimativa según el color de la roca"
            ),
            0,
            "La muestra entera se considera 100% recuperada, descontando solo vacíos reales."
        ),
        EjercicioPractico(
            "Banco 31",
            "En criterio B1, cuando los trozos casi conforman el cilindro del testigo, ¿qué recuperación aproximada se considera?",
            listOf(
                "95%",
                "75%",
                "50%"
            ),
            0,
            "En B1 se considera una recuperación cercana al 95% del largo medido."
        ),
        EjercicioPractico(
            "Banco 32",
            "En criterio B2, si los trozos ocupan cerca del 80% del volumen del testigo, ¿qué castigo corresponde aplicar al largo medido?",
            listOf(
                "10%",
                "25%",
                "50%"
            ),
            1,
            "Para B2 se castiga el tramo en un 25% para calcular la recuperación."
        ),
        EjercicioPractico(
            "Banco 33",
            "En criterio B3, si los trozos ocupan solo la mitad de la canaleta, ¿qué castigo corresponde?",
            listOf(
                "25%",
                "50%",
                "75%"
            ),
            1,
            "Cuando la ocupación es cercana al 50% del volumen del testigo, el castigo es del 50%."
        ),
        EjercicioPractico(
            "Banco 34",
            "Si la muestra molida llena aproximadamente el 100% de la canaleta, ¿qué castigo se aplica al largo medido?",
            listOf(
                "10%",
                "25%",
                "50%"
            ),
            0,
            "Para molido que ocupa el equivalente al 100% del volumen del testigo, el castigo indicado es de 10%."
        ),
        EjercicioPractico(
            "Banco 35",
            "Si la muestra molida llena aproximadamente el 80% de la canaleta, ¿qué castigo se aplica al largo medido?",
            listOf(
                "10%",
                "25%",
                "50%"
            ),
            1,
            "Cuando el molido ocupa cerca del 80% del volumen, el castigo indicado es del 25%."
        ),
        EjercicioPractico(
            "Banco 36",
            "¿Cuál es el propósito principal de la regularización del testigo recuperado?",
            listOf(
                "Dividir el sondaje en soportes de distancia definidos por el proyecto",
                "Medir únicamente el peso de las bandejas",
                "Registrar la asistencia del turno"
            ),
            0,
            "La regularización se usa para materializar soportes de distancia útiles para el logeo y medición geológica."
        ),
        EjercicioPractico(
            "Banco 37",
            "¿Cuándo se utiliza la compensación de muestra o fórmula de regularización?",
            listOf(
                "Solo cuando la roca está completamente intacta",
                "Cuando el testigo está molido o fracturado y no se distingue claramente la zona de pérdida",
                "Solo en perforación con tricono"
            ),
            1,
            "La fórmula compensatoria se usa cuando no es posible identificar con claridad dónde se perdió muestra."
        ),
        EjercicioPractico(
            "Banco 38",
            "Al marcar el metraje en el testigo con línea perpendicular, ¿hacia qué lado de la línea debe quedar escrito el valor?",
            listOf(
                "Hacia la izquierda de la línea",
                "Hacia la derecha de la línea",
                "En el centro de la línea"
            ),
            0,
            "El procedimiento indica que el metraje escrito en el testigo debe quedar hacia la izquierda de la línea."
        ),
        EjercicioPractico(
            "Banco 39",
            "En la pestaña inferior de la bandeja, ¿qué secuencia de datos debe registrarse?",
            listOf(
                "Número de pozo, desde, hasta y número de bandeja",
                "Solo fecha, turno y nombre del controlador",
                "Número de serie del barril, corona y escareador"
            ),
            0,
            "La rotulación inferior de la bandeja debe mantener esa secuencia para asegurar trazabilidad."
        ),
        EjercicioPractico(
            "Banco 40",
            "Si un tramo se perfora con tricono y no hay muestra recuperada, ¿qué debe hacerse?",
            listOf(
                "Registrar metraje inicial y final del tramo y dejar taco indicando la operación",
                "Asignar 100% de recuperación para cerrar el tramo",
                "Esperar el siguiente turno para registrar"
            ),
            0,
            "El tramo perforado con tricono debe quedar explícitamente registrado aunque no haya muestra."
        ),
        EjercicioPractico(
            "Banco 41",
            "Antes de tapar y apilar una bandeja completa, ¿qué verificación exige el procedimiento?",
            listOf(
                "Revisar por última vez los datos de la bandeja y dejar registro",
                "Quitar todos los tacos para ahorrar espacio",
                "Trasladarla de inmediato sin revisión"
            ),
            0,
            "Antes del cierre final se debe volver a revisar la información de la bandeja."
        ),
        EjercicioPractico(
            "Banco 42",
            "¿Cuál es la altura máxima permitida al apilar bandejas completas?",
            listOf(
                "6 pisos, equivalente a 24 bandejas",
                "10 pisos, equivalente a 40 bandejas",
                "12 pisos, equivalente a 48 bandejas"
            ),
            1,
            "El procedimiento fija una altura máxima de 10 pisos, equivalente a 40 bandejas."
        ),
        EjercicioPractico(
            "Banco 43",
            "Se perforan 1,50 m y se recuperan 1,20 m. ¿Cuál es la recuperación aproximada?",
            listOf("70%", "80%", "90%"),
            1,
            "1,20 / 1,50 × 100 = 80%."
        ),
        EjercicioPractico(
            "Banco 44",
            "Se perforan 2,40 m y se recuperan 1,80 m. ¿Cuál es la recuperación?",
            listOf("65%", "70%", "75%"),
            2,
            "1,80 / 2,40 × 100 = 75%."
        ),
        EjercicioPractico(
            "Banco 45",
            "Se perforan 0,60 m y se recuperan 0,40 m. ¿Cuál es la recuperación aproximada?",
            listOf("66,7%", "75,0%", "83,3%"),
            0,
            "0,40 / 0,60 × 100 = 66,7% aproximadamente."
        ),
        EjercicioPractico(
            "Banco 46",
            "Se perforan 0,90 m y se recuperan 1,10 m. ¿Qué recuperación aproximada se obtiene?",
            listOf("98,0%", "122,2%", "150,0%"),
            1,
            "1,10 / 0,90 × 100 = 122,2% aproximadamente, lo que obliga a revisar muestra arrastrada."
        ),
        EjercicioPractico(
            "Banco 47",
            "En un tramo de 2,30 m perforados se recuperan 1,70 m. ¿Cuál es la recuperación aproximada?",
            listOf("63,9%", "73,9%", "83,9%"),
            1,
            "1,70 / 2,30 × 100 = 73,9% aproximadamente."
        ),
        EjercicioPractico(
            "Banco 48",
            "Si se perforan 2,20 m y se recuperan 1,20 m, ¿cuál es la recuperación aproximada?",
            listOf("44,5%", "54,5%", "64,5%"),
            1,
            "1,20 / 2,20 × 100 = 54,5% aproximadamente."
        ),
        EjercicioPractico(
            "Banco 49",
            "Si se perforan 1,50 m y se recuperan 1,50 m, ¿cuál es la recuperación?",
            listOf("95%", "100%", "105%"),
            1,
            "Cuando lo recuperado y lo perforado son iguales, la recuperación es 100%."
        ),
        EjercicioPractico(
            "Banco 50",
            "Desde taco 236,3 m a 239,2 m se perforan 2,90 m y se recuperan 2,10 m. ¿Cuál es la recuperación aproximada?",
            listOf("62,4%", "72,4%", "82,4%"),
            1,
            "2,10 / 2,90 × 100 = 72,4% aproximadamente."
        ),
        EjercicioPractico(
            "Banco 51",
            "Se perforan 3,00 m y se recuperan 2,25 m. ¿Cuál es la recuperación?",
            listOf("65%", "70%", "75%"),
            2,
            "2,25 / 3,00 × 100 = 75%."
        ),
        EjercicioPractico(
            "Banco 52",
            "Si se perforan 1,80 m y se recuperan 0,90 m, ¿qué recuperación se obtiene?",
            listOf("40%", "50%", "60%"),
            1,
            "0,90 / 1,80 × 100 = 50%."
        ),
        EjercicioPractico(
            "Banco 53",
            "En un tramo de 2,70 m perforados se recuperan 2,43 m. ¿Cuál es la recuperación aproximada?",
            listOf("80%", "85%", "90%"),
            2,
            "2,43 / 2,70 × 100 = 90%."
        ),
        EjercicioPractico(
            "Banco 54",
            "Para un tramo entre 121,0 m y 123,3 m con 1,70 m recuperados y 2,30 m perforados, ¿a qué distancia desde el taco inicial queda el regularizado 121,5 m usando fórmula compensatoria?",
            listOf("0,37 m", "0,50 m", "0,73 m"),
            0,
            "(121,50 - 121,00) × 1,70 / 2,30 = 0,37 m aproximadamente."
        ),
        EjercicioPractico(
            "Banco 55",
            "En el mismo tramo 121,0 m a 123,3 m con 1,70 m recuperados, ¿a qué distancia desde el taco inicial queda el regularizado 123,0 m?",
            listOf("1,11 m", "1,47 m", "1,90 m"),
            1,
            "(123,0 - 121,0) × 1,70 / 2,30 = 1,47 m aproximadamente desde el taco inicial."
        ),
        EjercicioPractico(
            "Banco 56",
            "Si un taco falso queda en 236,7 m y el tramo hasta 239,2 m tiene 2,50 m perforados y 1,70 m recuperados, ¿a qué distancia desde el taco falso queda el regularizado 238,0 m?",
            listOf("0,52 m", "0,88 m", "1,30 m"),
            1,
            "(238,0 - 236,7) × 1,70 / 2,50 = 0,88 m aproximadamente."
        ),
        EjercicioPractico(
            "Banco 57",
            "Si desde el regularizado 123,0 m al término de bandeja hay 0,12 m medidos, con 2,30 m perforados y 1,70 m recuperados, ¿qué metraje final de bandeja resulta?",
            listOf("123,12 m", "123,16 m", "123,23 m"),
            1,
            "0,12 × 2,30 / 1,70 = 0,16 m; al sumarlo a 123,0 m resulta 123,16 m."
        ),
        EjercicioPractico(
            "Banco 58",
            "Se perforan 2,00 m y se recupera 1,00 m. Si un soporte teórico está a 0,50 m desde el taco inicial, ¿a qué distancia física aproximada queda usando compensación?",
            listOf("0,25 m", "0,50 m", "0,75 m"),
            0,
            "0,50 × 1,00 / 2,00 = 0,25 m."
        ),
        EjercicioPractico(
            "Banco 59",
            "Se perforan 1,50 m y se recuperan 1,20 m. Si el regularizado teórico está a 1,00 m desde el taco inicial, ¿a qué distancia física aproximada debe ubicarse?",
            listOf("0,67 m", "0,80 m", "1,20 m"),
            1,
            "1,00 × 1,20 / 1,50 = 0,80 m."
        ),
        EjercicioPractico(
            "Banco 60",
            "Se perforan 2,40 m y se recuperan 1,80 m. Si el soporte teórico está a 1,20 m desde el taco inicial, ¿qué distancia física aproximada corresponde?",
            listOf("0,90 m", "1,20 m", "1,60 m"),
            0,
            "1,20 × 1,80 / 2,40 = 0,90 m."
        )
    )

    private var tabActualPortada = 0 // 0 = Teórico, 1 = Práctico

    private var backCallback: android.window.OnBackInvokedCallback? = null
    private var backAction: (() -> Unit)? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val prefs = getSharedPreferences("hero_shortcuts_prefs", MODE_PRIVATE)
        modoOscuro = prefs.getBoolean("modo_oscuro", false)
        
        val desbloqueada = prefs.getBoolean("app_desbloqueada", false)
        if (desbloqueada) {
            mostrarPortada()
        } else {
            mostrarPantallaBloqueo()
        }
    }

    private fun mostrarPantallaBloqueo() {
        enPortada = true
        actualizarCallbackBack()
        
        val scroll = ScrollView(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            isFillViewport = true
            setBackgroundColor(fondo)
        }
        
        val base = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(24), dp(48), dp(24), dp(24))
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }
        
        // Logo / Lock Icon
        val tvIcono = TextView(this).apply {
            text = "🔒"
            textSize = 64f
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(16))
        }
        base.addView(tvIcono)
        
        // Title
        val tvTitulo = TextView(this).apply {
            text = "Acceso Protegido"
            textSize = 28f
            setTextColor(azulOscuro)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(8))
        }
        base.addView(tvTitulo)
        
        // Subtitle
        val tvSubtitulo = TextView(this).apply {
            text = "Ingresa la clave de activación para habilitar la aplicación en tu dispositivo."
            textSize = 15f
            setTextColor(grisTexto)
            gravity = Gravity.CENTER
            setLineSpacing(dp(4).toFloat(), 1.0f)
            setPadding(0, 0, 0, dp(24))
        }
        base.addView(tvSubtitulo)
        
        // Password Field
        val passInput = EditText(this).apply {
            hint = "Clave de activación"
            textSize = 16f
            setTextColor(azulOscuro)
            setHintTextColor(grisSecundario)
            inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD
            gravity = Gravity.CENTER_HORIZONTAL
            minHeight = dp(54)
            setPadding(dp(16), dp(14), dp(16), dp(14))
            background = fondoRedondeado(superficie, bordeSuave, 20)
            
            // Focus borders
            setOnFocusChangeListener { _, hasFocus ->
                background = if (hasFocus) {
                    fondoRedondeado(superficie, azul, 20)
                } else {
                    fondoRedondeado(superficie, bordeSuave, 20)
                }
            }
            
            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, dp(6), 0, dp(16))
            layoutParams = params
        }
        base.addView(passInput)
        
        // Validation Button
        val btnValidar = boton("Validar y Activar", azul) {
            val input = passInput.text.toString().trim()
            val correctPasswords = setOf("control2026", "sondaje2026", "aprender2026")
            
            if (correctPasswords.contains(input.lowercase())) {
                val prefs = getSharedPreferences("hero_shortcuts_prefs", MODE_PRIVATE)
                prefs.edit().putBoolean("app_desbloqueada", true).apply()
                Toast.makeText(this, "¡Acceso concedido! Bienvenido.", Toast.LENGTH_LONG).show()
                mostrarPortada()
            } else {
                Toast.makeText(this, "Clave incorrecta. La aplicación se cerrará.", Toast.LENGTH_LONG).show()
                passInput.postDelayed({
                    finishAffinity()
                }, 1200)
            }
        }
        base.addView(btnValidar)
        
        scroll.addView(base)
        setContentView(scroll)
    }

    /**
     * Registra o desregistra el callback de retroceso moderno (API 33+).
     * Cuando estamos en una sección interna, interceptamos el gesto
     * para volver a la portada en vez de cerrar la app.
     * Cuando estamos en la portada, dejamos que el sistema cierre la app normalmente.
     */
    private fun actualizarCallbackBack() {
        // Desregistrar callback anterior si existe
        if (backCallback != null) {
            onBackInvokedDispatcher.unregisterOnBackInvokedCallback(backCallback!!)
            backCallback = null
        }

        // Solo registrar si NO estamos en la portada
        if (!enPortada) {
            backCallback = android.window.OnBackInvokedCallback {
                val action = backAction
                if (action != null) {
                    action.invoke()
                } else {
                    mostrarPortada()
                }
            }
            onBackInvokedDispatcher.registerOnBackInvokedCallback(
                android.window.OnBackInvokedDispatcher.PRIORITY_DEFAULT,
                backCallback!!
            )
        }
    }

    private fun dp(valor: Int): Int {
        return (valor * resources.displayMetrics.density).toInt()
    }

    private fun fondoRedondeado(
        color: Int,
        borde: Int = Color.TRANSPARENT,
        radio: Int = 18
    ): GradientDrawable {
        return GradientDrawable().apply {
            setColor(color)
            cornerRadius = dp(radio).toFloat()
            if (borde != Color.TRANSPARENT) {
                setStroke(dp(1), borde)
            }
        }
    }

    private fun fondoGradiente(
        inicio: Int,
        fin: Int,
        radio: Int = 24,
        borde: Int = Color.TRANSPARENT,
        orientacion: GradientDrawable.Orientation = GradientDrawable.Orientation.TL_BR
    ): GradientDrawable {
        return GradientDrawable(orientacion, intArrayOf(inicio, fin)).apply {
            cornerRadius = dp(radio).toFloat()
            if (borde != Color.TRANSPARENT) {
                setStroke(dp(1), borde)
            }
        }
    }

    private fun crearBase(mostrarBotonMenu: Boolean = true): LinearLayout {
        enPortada = false
        backAction = null
        actualizarCallbackBack()
        
        // Configurar barras de estado y de navegación dinámicas
        window.statusBarColor = fondo
        window.navigationBarColor = fondo
        window.setBackgroundDrawable(android.graphics.drawable.ColorDrawable(fondo))
        val flags = if (modoOscuro) 0 else (View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR or View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR)
        window.decorView.systemUiVisibility = flags
        
        val contenedor = LinearLayout(this)
        contenedor.orientation = LinearLayout.VERTICAL
        contenedor.setPadding(dp(18), dp(18), dp(18), dp(28))
        contenedor.setBackgroundColor(fondo)

        if (mostrarBotonMenu) {
            val headerBar = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(0, 0, 0, dp(12))
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
            }

            val btnMenuDesplegado = TextView(this).apply {
                text = "☰"
                textSize = 20f
                setTextColor(azul)
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(dp(14), dp(8), dp(14), dp(8))
                background = fondoRedondeado(
                    if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(239, 246, 255),
                    if (modoOscuro) Color.rgb(51, 65, 85) else Color.rgb(191, 219, 254),
                    radio = 12
                )
                gravity = Gravity.CENTER
            }

            aplicarInteraccion(btnMenuDesplegado) {
                abrirMenuLateral(desplegado = true)
            }

            headerBar.addView(btnMenuDesplegado)
            contenedor.addView(headerBar)
        }

        val scroll = ScrollView(this)
        scroll.isFillViewport = true
        scroll.isVerticalScrollBarEnabled = false
        scroll.addView(contenedor)

        setContentView(scroll)

        // Animar entrada escalonada de todos los hijos del contenedor
        contenedor.post {
            animarEntradaEscalonada(contenedor)
        }

        return contenedor
    }

    private fun animarEntradaEscalonada(layout: LinearLayout, delayBase: Long = 40L) {
        for (i in 0 until layout.childCount) {
            val child = layout.getChildAt(i)
            child.alpha = 0f
            child.translationY = dp(18).toFloat()
            child.animate()
                .alpha(1f)
                .translationY(0f)
                .setDuration(320)
                .setStartDelay(i * delayBase)
                .setInterpolator(android.view.animation.DecelerateInterpolator(1.8f))
                .start()
        }
    }

    private fun titulo(texto: String, seccion: String = ""): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(0, 0, 0, dp(10))

            // Breadcrumb chip (si hay sección definida)
            if (seccion.isNotEmpty()) {
                addView(
                    TextView(this@MainActivity).apply {
                        this.text = "🏠 Inicio  ›  $seccion"
                        textSize = 12f
                        setTextColor(grisSecundario)
                        setPadding(0, 0, 0, dp(8))
                    }
                )
            }

            addView(
                TextView(this@MainActivity).apply {
                    this.text = texto
                    textSize = 28f
                    setTextColor(azulOscuro)
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                }
            )
        }
    }

    private fun bajada(texto: String): TextView {
        return TextView(this).apply {
            this.text = texto
            textSize = 16f
            setTextColor(grisTexto)
            setPadding(0, 0, 0, dp(18))
            setLineSpacing(dp(4).toFloat(), 1.0f)
        }
    }

    private fun subtitulo(texto: String, color: Int = azul): TextView {
        return TextView(this).apply {
            this.text = texto
            textSize = 19f
            setTextColor(color)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setPadding(0, dp(10), 0, dp(6))
        }
    }

    private fun parrafo(texto: String): TextView {
        return TextView(this).apply {
            this.text = texto
            textSize = 15f
            setTextColor(grisTexto)
            setPadding(0, 0, 0, dp(12))
            setLineSpacing(dp(4).toFloat(), 1.0f)
        }
    }

    private fun espacio(alto: Int = 10): Space {
        return Space(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(alto)
            )
        }
    }

    private fun boton(
        texto: String,
        color: Int = azul,
        accion: () -> Unit
    ): Button {
        return Button(this).apply {
            this.text = texto
            textSize = 15f
            this.contentDescription = texto
            
            // Si el color de fondo es muy claro, usamos un color oscuro para legibilidad
            val red = Color.red(color)
            val green = Color.green(color)
            val blue = Color.blue(color)
            val luminancia = 0.299 * red + 0.587 * green + 0.114 * blue
            if (luminancia > 180.0) {
                setTextColor(Color.rgb(15, 23, 42))
            } else {
                setTextColor(Color.WHITE)
            }
            
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setAllCaps(false)
            minHeight = dp(54)
            setPadding(dp(18), dp(12), dp(18), dp(12))

            // Premium subtle vertical/diagonal gradient
            val colorFin = when (color) {
                azul -> if (modoOscuro) Color.rgb(96, 145, 210) else Color.rgb(37, 85, 170)
                verde -> if (modoOscuro) Color.rgb(80, 166, 132) else Color.rgb(30, 95, 70)
                naranjo -> if (modoOscuro) Color.rgb(205, 158, 80) else Color.rgb(154, 90, 0)
                purpura -> if (modoOscuro) Color.rgb(150, 125, 210) else Color.rgb(89, 20, 187)
                rojo -> if (modoOscuro) Color.rgb(202, 90, 103) else Color.rgb(150, 38, 54)
                else -> color
            }
            background = if (colorFin != color) {
                fondoGradiente(color, colorFin, radio = 20)
            } else {
                fondoRedondeado(color, radio = 20)
            }

            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, dp(6), 0, dp(8))
            layoutParams = params

            aplicarInteraccion(this, accion)
        }
    }

    private fun botonSecundario(
        texto: String,
        accion: () -> Unit
    ): Button {
        return Button(this).apply {
            this.text = texto
            textSize = 14f
            this.contentDescription = texto
            setTextColor(azul)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setAllCaps(false)
            minHeight = dp(52)
            setPadding(dp(18), dp(10), dp(18), dp(10))
            background = fondoRedondeado(superficie, bordeSuave, 20)

            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, dp(8), 0, dp(14))
            layoutParams = params

            aplicarInteraccion(this, accion)
        }
    }

    private fun tarjeta(
        titulo: String,
        texto: String,
        colorTitulo: Int = azul,
        colorFondo: Int = superficie
    ): LinearLayout {
        val card = LinearLayout(this)
        card.orientation = LinearLayout.HORIZONTAL
        card.setPadding(dp(16), dp(18), dp(20), dp(18))
        card.background = fondoRedondeado(colorFondo, bordeSuave, 24)
        card.elevation = dp(3).toFloat()
        card.contentDescription = "$titulo: $texto"

        val params = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
        params.setMargins(0, dp(6), 0, dp(12))
        card.layoutParams = params

        // Left accent vertical bar (Premium UX)
        val acento = View(this).apply {
            val lp = LinearLayout.LayoutParams(dp(4), ViewGroup.LayoutParams.MATCH_PARENT)
            lp.setMargins(0, 0, dp(16), 0)
            layoutParams = lp
            background = fondoRedondeado(colorTitulo, radio = 2)
        }
        card.addView(acento)

        val contenido = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        }

        val tvTitulo = TextView(this).apply {
            this.text = titulo
            textSize = 18.5f
            setTextColor(colorTitulo)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setPadding(0, 0, 0, dp(8))
        }

        val tvTexto = TextView(this).apply {
            this.text = texto
            textSize = 15f
            setTextColor(grisTexto)
            setLineSpacing(dp(4).toFloat(), 1.0f)
        }

        contenido.addView(tvTitulo)
        contenido.addView(tvTexto)
        card.addView(contenido)
        return card
    }

    private fun campoNumero(hint: String): EditText {
        return EditText(this).apply {
            this.hint = hint
            this.contentDescription = hint
            textSize = 16f
            setTextColor(azulOscuro)
            setHintTextColor(grisSecundario)
            inputType = InputType.TYPE_CLASS_NUMBER or
                    InputType.TYPE_NUMBER_FLAG_DECIMAL or
                    InputType.TYPE_NUMBER_FLAG_SIGNED
            minHeight = dp(54)
            setPadding(dp(16), dp(14), dp(16), dp(14))
            background = fondoRedondeado(superficie, bordeSuave, 20)

            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, dp(6), 0, dp(10))
            layoutParams = params

            setOnFocusChangeListener { _, hasFocus ->
                background = if (hasFocus) {
                    GradientDrawable().apply {
                        setColor(superficie)
                        cornerRadius = dp(20).toFloat()
                        setStroke(dp(2), azul)
                    }
                } else {
                    fondoRedondeado(superficie, bordeSuave, 20)
                }
            }
        }
    }

    private fun resaltarCampoError(campo: EditText, tieneError: Boolean) {
        campo.background = if (tieneError) {
            GradientDrawable().apply {
                setColor(superficie)
                cornerRadius = dp(20).toFloat()
                setStroke(dp(2), rojo) // Red border for error
            }
        } else {
            fondoRedondeado(superficie, bordeSuave, 20)
        }
    }

    /** Agrega una etiqueta flotante antes de un campo de entrada */
    private fun etiquetaCampo(texto: String): TextView {
        return TextView(this).apply {
            this.text = texto
            textSize = 12.5f
            setTextColor(azul)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setPadding(dp(4), dp(8), 0, dp(2))
        }
    }

    private fun aplicarInteraccion(view: View, accion: () -> Unit) {
        view.isClickable = true
        view.isFocusable = true
        view.setOnTouchListener { _, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    view.animate()
                        .scaleX(0.95f)
                        .scaleY(0.95f)
                        .alpha(0.88f)
                        .setDuration(70)
                        .start()
                }

                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    view.animate()
                        .scaleX(1.0f)
                        .scaleY(1.0f)
                        .alpha(1.0f)
                        .setDuration(120)
                        .start()
                }
            }
            false
        }
        view.setOnClickListener { accion() }
    }

    private fun chip(texto: String, fondoChip: Int, colorTexto: Int): TextView {
        return TextView(this).apply {
            this.text = texto
            textSize = 12f
            setTextColor(colorTexto)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setPadding(dp(10), dp(6), dp(10), dp(6))
            background = fondoRedondeado(fondoChip, radio = 14)
            
            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            layoutParams = params
        }
    }

    private fun chipAccion(
        texto: String,
        fondoChip: Int,
        colorTexto: Int,
        accion: () -> Unit
    ): TextView {
        return chip(texto, fondoChip, colorTexto).apply {
            contentDescription = texto
            aplicarInteraccion(this, accion)
        }
    }

    private fun encabezadoSeccion(etiqueta: String, titulo: String, detalle: String): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(0, dp(10), 0, dp(4))
            addView(chip(etiqueta, azulClaro, azul))
            addView(
                TextView(this@MainActivity).apply {
                    text = titulo
                    textSize = 22f
                    setTextColor(azulOscuro)
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                    setPadding(0, dp(10), 0, dp(4))
                }
            )
            addView(
                TextView(this@MainActivity).apply {
                    text = detalle
                    textSize = 14.5f
                    setTextColor(grisSecundario)
                    setLineSpacing(dp(3).toFloat(), 1.0f)
                    setPadding(0, 0, 0, dp(4))
                }
            )
        }
    }

    private fun miniDato(valor: String, etiqueta: String): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(12), dp(12), dp(12), dp(12))
            background = fondoRedondeado(Color.argb(28, 255, 255, 255), radio = 18)

            val params = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            params.setMargins(0, 0, dp(8), 0)
            layoutParams = params

            addView(
                TextView(this@MainActivity).apply {
                    text = valor
                    textSize = 18f
                    setTextColor(Color.WHITE)
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                }
            )

            addView(
                TextView(this@MainActivity).apply {
                    text = etiqueta
                    textSize = 12f
                    setTextColor(Color.argb(220, 255, 255, 255))
                    setLineSpacing(dp(2).toFloat(), 1.0f)
                }
            )
        }
    }

    private fun accionHero(
        titulo: String,
        detalle: String,
        fondoAccion: Int,
        colorTexto: Int,
        accion: () -> Unit
    ): LinearLayout {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(14), dp(14), dp(14), dp(14))
            background = fondoRedondeado(fondoAccion, radio = 20)
            contentDescription = "$titulo. $detalle"
        }

        val params = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        params.setMargins(0, 0, dp(10), 0)
        card.layoutParams = params

        card.addView(
            TextView(this).apply {
                text = titulo
                textSize = 14.5f
                setTextColor(colorTexto)
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(0, 0, 0, dp(4))
            }
        )

        card.addView(
            TextView(this).apply {
                text = detalle
                textSize = 12.5f
                setTextColor(if (colorTexto == Color.WHITE) Color.argb(220, 255, 255, 255) else grisTexto)
                setLineSpacing(dp(2).toFloat(), 1.0f)
            }
        )

        aplicarInteraccion(card, accion)
        return card
    }

    private fun tarjetaModuloInicio(
        numero: String,
        categoria: String,
        titulo: String,
        detalle: String,
        colorAcento: Int,
        accion: () -> Unit
    ): LinearLayout {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(18), dp(16), dp(18), dp(16))
            background = fondoRedondeado(superficie, bordeSuave, 24)
            elevation = dp(2).toFloat()
            contentDescription = "$titulo. $detalle"
        }

        val params = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
        params.setMargins(0, dp(6), 0, dp(10))
        card.layoutParams = params

        val cabecera = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        cabecera.addView(
            TextView(this).apply {
                text = numero
                minWidth = dp(38)
                gravity = Gravity.CENTER
                textSize = 12f
                setTextColor(Color.WHITE)
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(0, dp(9), 0, dp(9))
                background = fondoRedondeado(colorAcento, radio = 19)
            }
        )

        cabecera.addView(
            TextView(this).apply {
                text = categoria
                textSize = 12.5f
                setTextColor(colorAcento)
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(dp(10), 0, 0, 0)
            }
        )

        card.addView(cabecera)

        card.addView(
            TextView(this).apply {
                text = titulo
                textSize = 19f
                setTextColor(azulOscuro)
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(0, dp(14), 0, dp(6))
            }
        )

        card.addView(
            TextView(this).apply {
                text = detalle
                textSize = 14.5f
                setTextColor(grisTexto)
                setLineSpacing(dp(3).toFloat(), 1.0f)
                setPadding(0, 0, 0, dp(10))
            }
        )

        card.addView(
            TextView(this).apply {
                text = "Abrir modulo"
                textSize = 13f
                setTextColor(colorAcento)
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                background = fondoRedondeado(
                    Color.argb(26, Color.red(colorAcento), Color.green(colorAcento), Color.blue(colorAcento)),
                    radio = 14
                )
                setPadding(dp(10), dp(6), dp(10), dp(6))
            }
        )

        aplicarInteraccion(card, accion)
        return card
    }

    private fun crearSwitchModoOscuro(): LinearLayout {
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            background = fondoRedondeado(Color.argb(36, 255, 255, 255), radio = 18)
            setPadding(dp(4), dp(4), dp(4), dp(4))
        }

        val solView = TextView(this).apply {
            text = "☀️ Claro"
            textSize = 12f
            setTextColor(Color.WHITE)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            gravity = Gravity.CENTER
            setPadding(dp(10), dp(4), dp(10), dp(4))
            if (!modoOscuro) {
                background = fondoRedondeado(Color.WHITE, radio = 14)
                setTextColor(azulOscuro)
            } else {
                background = null
            }
        }

        val lunaView = TextView(this).apply {
            text = "🌙 Oscuro"
            textSize = 12f
            setTextColor(Color.argb(180, 255, 255, 255))
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            gravity = Gravity.CENTER
            setPadding(dp(10), dp(4), dp(10), dp(4))
            if (modoOscuro) {
                background = fondoRedondeado(Color.WHITE, radio = 14)
                setTextColor(Color.rgb(15, 23, 42))
            } else {
                background = null
            }
        }

        container.addView(solView)
        container.addView(lunaView)

        aplicarInteraccion(container) {
            modoOscuro = !modoOscuro
            getSharedPreferences("hero_shortcuts_prefs", MODE_PRIVATE)
                .edit().putBoolean("modo_oscuro", modoOscuro).apply()
            mostrarPortada()
        }

        return container
    }

    private fun heroInicio(): LinearLayout {
        val hero = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(20), dp(20), dp(20))
            
            val colorInicioHero = if (modoOscuro) Color.rgb(15, 23, 42) else azulOscuro
            val colorFinHero = if (modoOscuro) Color.rgb(30, 41, 59) else azul
            
            background = fondoGradiente(colorInicioHero, colorFinHero, 0, Color.argb(28, 255, 255, 255))
            elevation = dp(4).toFloat()
        }

        val params = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            0,
            1f
        )
        params.setMargins(0, 0, 0, 0)
        hero.layoutParams = params

        val filaSuperior = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        filaSuperior.addView(
            chipAccion("☰ Menú", Color.argb(42, 255, 255, 255), Color.WHITE) {
                mostrarMenuLateral()
            }
        )

        filaSuperior.addView(
            Space(this).apply {
                layoutParams = LinearLayout.LayoutParams(dp(8), 1)
            }
        )

        filaSuperior.addView(crearSwitchModoOscuro())

        filaSuperior.addView(
            Space(this).apply {
                layoutParams = LinearLayout.LayoutParams(0, 1, 1f)
            }
        )

        filaSuperior.addView(
            chip(heroBlockConfig.etiqueta, Color.argb(36, 255, 255, 255), Color.WHITE)
        )
        hero.addView(filaSuperior)

        // 2. Título principal
        hero.addView(
            TextView(this).apply {
                text = heroBlockConfig.titulo
                textSize = 31f
                setTextColor(Color.WHITE)
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(0, dp(14), 0, dp(8))
            }
        )

        // 3. Descripción / Resumen
        hero.addView(
            TextView(this).apply {
                text = heroBlockConfig.descripcion
                textSize = 15.5f
                setTextColor(Color.argb(228, 255, 255, 255))
                setLineSpacing(dp(4).toFloat(), 1.0f)
                setPadding(0, 0, 0, dp(18))
            }
        )

        // 4. Métricas / Datos resumidos dinámicos
        val filaDatos = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
        }
        val metricas = heroMetricasConfig
        metricas.forEachIndexed { index, metrica ->
            val esUltimo = index == metricas.size - 1
            filaDatos.addView(
                miniDato(metrica.valor, metrica.etiqueta).apply {
                    if (esUltimo) {
                        (layoutParams as LinearLayout.LayoutParams).setMargins(0, 0, 0, 0)
                    }
                }
            )
        }
        hero.addView(filaDatos)

        // 5. Cargar estados de los 4 slots desde SharedPreferences
        val prefs = getSharedPreferences("hero_shortcuts_prefs", MODE_PRIVATE)
        val idSlot0 = prefs.getString("slot_0", "aprender_procedimiento") ?: "aprender_procedimiento"
        val idSlot1 = prefs.getString("slot_1", "calculadora_recuperacion") ?: "calculadora_recuperacion"
        val idSlot2 = prefs.getString("slot_2", "simulador_regularizacion") ?: "simulador_regularizacion"
        val idSlot3 = prefs.getString("slot_3", "quiz_puntaje") ?: "quiz_puntaje"

        val seccion0 = if (idSlot0 == "empty") null else obtenerSeccionPorId(idSlot0)
        val seccion1 = if (idSlot1 == "empty") null else obtenerSeccionPorId(idSlot1)
        val seccion2 = if (idSlot2 == "empty") null else obtenerSeccionPorId(idSlot2)
        val seccion3 = if (idSlot3 == "empty") null else obtenerSeccionPorId(idSlot3)

        // 6. Fila Acciones 1 (Slots 0 y 1)
        val filaAcciones1 = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, dp(14), 0, 0)
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                0,
                1f
            )
        }
        
        val view0 = crearSlotWidget(0, seccion0, esEstiloFuerte = true)
        val view1 = crearSlotWidget(1, seccion1, esEstiloFuerte = false)
        
        filaAcciones1.addView(view0)
        filaAcciones1.addView(view1)
        
        // Configurar márgenes para 50%/50% y separación en medio
        (view0.layoutParams as LinearLayout.LayoutParams).apply {
            setMargins(0, 0, dp(10), 0)
        }
        (view1.layoutParams as LinearLayout.LayoutParams).apply {
            setMargins(0, 0, 0, 0)
        }
        
        hero.addView(filaAcciones1)

        // 7. Fila Acciones 2 (Slots 2 y 3)
        val filaAcciones2 = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, dp(10), 0, 0)
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                0,
                1f
            )
        }
        
        val view2 = crearSlotWidget(2, seccion2, esEstiloFuerte = false)
        val view3 = crearSlotWidget(3, seccion3, esEstiloFuerte = false)
        
        filaAcciones2.addView(view2)
        filaAcciones2.addView(view3)
        
        // Configurar márgenes para 50%/50% y separación en medio
        (view2.layoutParams as LinearLayout.LayoutParams).apply {
            setMargins(0, 0, dp(10), 0)
        }
        (view3.layoutParams as LinearLayout.LayoutParams).apply {
            setMargins(0, 0, 0, 0)
        }
        
        hero.addView(filaAcciones2)

        return hero
    }

    private fun abrirMenuLateral(desplegado: Boolean = false) {
        if (desplegado) {
            teoricosAbierto = true
            practicosAbierto = true
        }
        mostrarMenuLateral()
    }

    private fun mostrarMenuLateral() {
        val dialog = android.app.Dialog(this).apply {
            requestWindowFeature(android.view.Window.FEATURE_NO_TITLE)
            window?.setBackgroundDrawable(android.graphics.drawable.ColorDrawable(Color.TRANSPARENT))
            setCancelable(true)
        }

        val overlay = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setBackgroundColor(Color.argb(92, 8, 22, 45))
        }

        val panel = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(18), dp(22), dp(18), dp(18))
            background = fondoRedondeado(superficie, bordeSuave, radio = 0)
            layoutParams = LinearLayout.LayoutParams(dp(310), ViewGroup.LayoutParams.MATCH_PARENT)
        }

        fun construirMenu() {
            panel.removeAllViews()

            // 1. Cabecera del Menú
            panel.addView(
                TextView(this).apply {
                    text = "Secciones"
                    textSize = 25f
                    setTextColor(azulOscuro)
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                }
            )

            panel.addView(
                TextView(this).apply {
                    text = "Abre cualquier módulo desde los submenús o vuelve a la portada de widgets."
                    textSize = 14f
                    setTextColor(grisSecundario)
                    setLineSpacing(dp(2).toFloat(), 1.0f)
                    setPadding(0, dp(4), 0, dp(16))
                }
            )

            // 2. Scroll de las opciones
            val scroll = ScrollView(this).apply {
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    0,
                    1f
                )
            }

            val lista = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
            }

            // Opción 1: Volver a Portada
            val itemInicio = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(16), dp(12), dp(16), dp(12))
                background = fondoRedondeado(superficieSuave, radio = 14)
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 0, 0, dp(10))
                }
            }
            itemInicio.addView(
                TextView(this).apply {
                    text = "🏠 Ir al Inicio (Portada)"
                    textSize = 15.5f
                    setTextColor(azulOscuro)
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                }
            )
            aplicarInteraccion(itemInicio) {
                dialog.dismiss()
                mostrarPortada()
            }
            lista.addView(itemInicio)

            // Opción 2: Submenú Módulos Teóricos
            val itemTeoricosHeader = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(16), dp(14), dp(16), dp(14))
                background = fondoRedondeado(if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(238, 242, 255), radio = 14)
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 0, 0, dp(8))
                }
            }
            itemTeoricosHeader.addView(
                TextView(this).apply {
                    text = "📚 Módulos Teóricos"
                    textSize = 15.5f
                    setTextColor(azul)
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                }
            )
            itemTeoricosHeader.addView(
                TextView(this).apply {
                    text = if (teoricosAbierto) "▲" else "▼"
                    textSize = 12f
                    setTextColor(azul)
                }
            )
            aplicarInteraccion(itemTeoricosHeader) {
                teoricosAbierto = !teoricosAbierto
                construirMenu()
            }
            lista.addView(itemTeoricosHeader)

            if (teoricosAbierto) {
                val teoricos = listOf(
                    Pair("1. Aprender procedimiento", "aprender_procedimiento"),
                    Pair("2. Seguridad y riesgos", "seguridad_riesgos"),
                    Pair("3. Reportabilidad", "reportabilidad"),
                    Pair("4. Hacer cuaderno", "hacer_cuaderno"),
                    Pair("5. Tricono y cambio de diámetro", "tricono_diametro"),
                    Pair("6. Criterios de medición", "criterios_medicion"),
                    Pair("7. Rotulación de bandejas", "rotulacion_bandejas"),
                    Pair("8. Glosario", "glosario"),
                    Pair("9. Mapas conceptuales", "mapas_conceptuales")
                )

                teoricos.forEach { (tituloLabel, id) ->
                    val seccion = obtenerSeccionPorId(id) ?: return@forEach

                    val itemSub = LinearLayout(this).apply {
                        orientation = LinearLayout.VERTICAL
                        setPadding(dp(14), dp(10), dp(14), dp(10))
                        background = fondoRedondeado(superficieSuave, bordeSuave, 12)
                        layoutParams = LinearLayout.LayoutParams(
                            ViewGroup.LayoutParams.MATCH_PARENT,
                            ViewGroup.LayoutParams.WRAP_CONTENT
                        ).apply {
                            setMargins(dp(16), 0, 0, dp(6))
                        }
                    }

                    itemSub.addView(
                        TextView(this).apply {
                            text = tituloLabel
                            textSize = 14.5f
                            setTextColor(azulOscuro)
                            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                        }
                    )

                    itemSub.addView(
                        TextView(this).apply {
                            text = seccion.descripcion
                            textSize = 12.5f
                            setTextColor(grisTexto)
                            setPadding(0, dp(4), 0, 0)
                        }
                    )

                    aplicarInteraccion(itemSub) {
                        dialog.dismiss()
                        seccion.accion()
                    }
                    lista.addView(itemSub)
                }
                lista.addView(Space(this).apply { layoutParams = LinearLayout.LayoutParams(1, dp(8)) })
            }

            // Opción 3: Submenú Herramientas Prácticas
            val itemPracticosHeader = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(16), dp(14), dp(16), dp(14))
                background = fondoRedondeado(if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(240, 253, 244), radio = 14)
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 0, 0, dp(8))
                }
            }
            itemPracticosHeader.addView(
                TextView(this).apply {
                    text = "🛠️ Herramientas Prácticas"
                    textSize = 15.5f
                    setTextColor(verde)
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                }
            )
            itemPracticosHeader.addView(
                TextView(this).apply {
                    text = if (practicosAbierto) "▲" else "▼"
                    textSize = 12f
                    setTextColor(verde)
                }
            )
            aplicarInteraccion(itemPracticosHeader) {
                practicosAbierto = !practicosAbierto
                construirMenu()
            }
            lista.addView(itemPracticosHeader)

            if (practicosAbierto) {
                val practicos = listOf(
                    Pair("1. Paso a paso del turno", "checklist_turno"),
                    Pair("2. Calculadoras operacionales", "calculadoras"),
                    Pair("3. Ejercicios prácticos", "ejercicios_practicos"),
                    Pair("4. Quiz con puntaje", "quiz_puntaje"),
                    Pair("5. Fotografíar bandejas", "camara_fotos")
                )

                practicos.forEach { (tituloLabel, id) ->
                    val seccion = obtenerSeccionPorId(id) ?: return@forEach
                    val itemSub = LinearLayout(this).apply {
                        orientation = LinearLayout.VERTICAL
                        setPadding(dp(14), dp(10), dp(14), dp(10))
                        background = fondoRedondeado(superficieSuave, bordeSuave, 12)
                        layoutParams = LinearLayout.LayoutParams(
                            ViewGroup.LayoutParams.MATCH_PARENT,
                            ViewGroup.LayoutParams.WRAP_CONTENT
                        ).apply {
                            setMargins(dp(16), 0, 0, dp(6))
                        }
                    }

                    itemSub.addView(
                        TextView(this).apply {
                            text = tituloLabel
                            textSize = 14.5f
                            setTextColor(azulOscuro)
                            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                        }
                    )

                    itemSub.addView(
                        TextView(this).apply {
                            text = seccion.descripcion
                            textSize = 12.5f
                            setTextColor(grisTexto)
                            setPadding(0, dp(4), 0, 0)
                        }
                    )

                    aplicarInteraccion(itemSub) {
                        dialog.dismiss()
                        seccion.accion()
                    }
                    lista.addView(itemSub)
                }
            }

            scroll.addView(lista)
            panel.addView(scroll)

            val filaBotonesMenu = LinearLayout(this@MainActivity).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                
                val params = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, dp(12), 0, 0)
                layoutParams = params
            }

            val btnModo = chipAccion(if (modoOscuro) "☀️ Claro" else "🌙 Oscuro", azulClaro, azul) {
                modoOscuro = !modoOscuro
                getSharedPreferences("hero_shortcuts_prefs", MODE_PRIVATE)
                    .edit().putBoolean("modo_oscuro", modoOscuro).apply()
                dialog.dismiss()
                mostrarPortada()
            }
            
            val btnCerrar = chipAccion("Cerrar", azulClaro, azul) {
                dialog.dismiss()
            }

            filaBotonesMenu.addView(btnModo)
            filaBotonesMenu.addView(Space(this@MainActivity).apply { layoutParams = LinearLayout.LayoutParams(0, 1, 1f) })
            filaBotonesMenu.addView(btnCerrar)
            panel.addView(filaBotonesMenu)
        }

        construirMenu()

        overlay.addView(panel)
        overlay.addView(
            View(this).apply {
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f)
                setOnClickListener { dialog.dismiss() }
            }
        )

        dialog.setContentView(overlay)
        dialog.window?.let { w ->
            w.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
            w.setGravity(Gravity.START)
        }
        dialog.show()
    }

    private fun crearSlotWidget(
        slotIndex: Int,
        seccion: SeccionApp?,
        esEstiloFuerte: Boolean
    ): View {
        val contenedor = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(14), dp(14), dp(14), dp(14))
            val params = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f)
            layoutParams = params
        }

        if (seccion == null) {
            // ESTADO: VACÍO (Placeholder con botón +)
            contenedor.gravity = Gravity.CENTER
            contenedor.background = fondoRedondeado(Color.argb(20, 255, 255, 255), Color.argb(45, 255, 255, 255), radio = 20)
            
            // Botón "+" en el centro
            val tvPlus = TextView(this).apply {
                text = "+"
                textSize = 28f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(0, 0, 0, 0)
            }
            contenedor.addView(tvPlus)
            
            aplicarInteraccion(contenedor) {
                mostrarSelectorSecciones(slotIndex)
            }
        } else {
            // ESTADO: OCUPADO
            val fondoColor = if (esEstiloFuerte) {
                if (modoOscuro) superficie else Color.rgb(239, 246, 255)
            } else {
                Color.argb(34, 255, 255, 255)
            }
            val colorTexto = if (esEstiloFuerte) azulOscuro else Color.WHITE
            val bordeColor = if (esEstiloFuerte) {
                if (modoOscuro) Color.rgb(51, 65, 85) else Color.rgb(226, 232, 240)
            } else {
                Color.argb(45, 255, 255, 255)
            }
            
            contenedor.background = fondoRedondeado(fondoColor, bordeColor, radio = 20)
            
            // Si está en modo edición, añadimos la fila de cabecera con el botón "X"
            if (modoEdicionHero) {
                val filaCabecera = LinearLayout(this).apply {
                    orientation = LinearLayout.HORIZONTAL
                    gravity = Gravity.CENTER_VERTICAL
                    setPadding(0, 0, 0, dp(4))
                }
                
                val tvTitulo = TextView(this).apply {
                    text = seccion.titulo
                    textSize = 14.5f
                    setTextColor(colorTexto)
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                }
                
                val tvCerrar = TextView(this).apply {
                    text = "✕"
                    textSize = 16f
                    setTextColor(if (esEstiloFuerte) rojo else Color.WHITE)
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                    setPadding(dp(6), dp(2), dp(6), dp(2))
                    background = fondoRedondeado(if (esEstiloFuerte) Color.rgb(255, 235, 235) else Color.argb(40, 255, 255, 255), radio = 10)
                    
                    setOnClickListener {
                        eliminarSlot(slotIndex)
                    }
                }
                
                filaCabecera.addView(tvTitulo)
                filaCabecera.addView(tvCerrar)
                contenedor.addView(filaCabecera)
            } else {
                // Título estándar
                contenedor.addView(
                    TextView(this).apply {
                        text = seccion.titulo
                        textSize = 14.5f
                        setTextColor(colorTexto)
                        setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                        setPadding(0, 0, 0, dp(4))
                    }
                )
            }
            
            // Descripción detallada
            contenedor.addView(
                TextView(this).apply {
                    text = seccion.descripcion
                    textSize = 12.5f
                    setTextColor(if (colorTexto == Color.WHITE) Color.argb(220, 255, 255, 255) else grisTexto)
                    setLineSpacing(dp(2).toFloat(), 1.0f)
                }
            )
            
            if (!modoEdicionHero) {
                // Clic estándar para navegar
                aplicarInteraccion(contenedor) {
                    seccion.accion()
                }
                // Long press para entrar en modo edición
                contenedor.setOnLongClickListener {
                    modoEdicionHero = true
                    mostrarPortada()
                    true
                }
            } else {
                // En modo edición, presionar en cualquier parte del widget fuera del botón X desactiva modo edición
                aplicarInteraccion(contenedor) {
                    modoEdicionHero = false
                    mostrarPortada()
                }
            }
        }
        
        return contenedor
    }

    private fun leerDouble(campo: EditText): Double? {
        return campo.text.toString()
            .trim()
            .replace(",", ".")
            .toDoubleOrNull()
    }

    private fun mostrarDialogo(
        titulo: String,
        mensaje: String,
        alCerrar: (() -> Unit)? = null
    ) {
        val dialog = android.app.Dialog(this).apply {
            requestWindowFeature(android.view.Window.FEATURE_NO_TITLE)
            window?.setBackgroundDrawable(android.graphics.drawable.ColorDrawable(Color.TRANSPARENT))
        }

        val dialogView = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(22), dp(22), dp(22), dp(22))
            background = fondoRedondeado(if (modoOscuro) Color.rgb(30, 41, 59) else Color.WHITE, radio = 24)
        }

        val tvTitulo = TextView(this).apply {
            text = titulo
            textSize = 20f
            setTextColor(if (modoOscuro) Color.WHITE else azulOscuro)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setPadding(0, 0, 0, dp(10))
            gravity = Gravity.CENTER_HORIZONTAL
        }
        dialogView.addView(tvTitulo)

        val tvMensaje = TextView(this).apply {
            text = mensaje
            textSize = 15f
            setTextColor(if (modoOscuro) Color.rgb(226, 232, 240) else grisTexto)
            setLineSpacing(dp(3).toFloat(), 1.0f)
            setPadding(0, 0, 0, dp(20))
            gravity = Gravity.CENTER_HORIZONTAL
        }
        dialogView.addView(tvMensaje)

        val btnAceptar = Button(this).apply {
            text = "Aceptar"
            textSize = 14f
            setTextColor(Color.WHITE)
            setAllCaps(false)
            background = fondoRedondeado(azul, radio = 14)
            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            layoutParams = params
            
            aplicarInteraccion(this) {
                dialog.dismiss()
                alCerrar?.invoke()
            }
        }
        dialogView.addView(btnAceptar)

        dialog.setContentView(dialogView)
        
        dialog.window?.let { w ->
            val displayMetrics = resources.displayMetrics
            val width = (displayMetrics.widthPixels * 0.85).toInt()
            w.setLayout(width, ViewGroup.LayoutParams.WRAP_CONTENT)
        }
        
        dialog.show()
    }

    private fun mostrarPortada() {
        val layout = crearBase(mostrarBotonMenu = false)
        enPortada = true
        actualizarCallbackBack()

        // Eliminar los paddings de la portada para que sea full-bleed (pantalla completa)
        layout.setPadding(0, 0, 0, 0)

        // Cambiar el fondo del contenedor y ScrollView para eliminar el borde blanco por completo
        layout.setBackgroundColor(azulOscuro)
        (layout.parent as? ScrollView)?.setBackgroundColor(azulOscuro)

        // Cambiar también el color de las barras del sistema para un look full-bleed
        window.statusBarColor = azulOscuro
        window.navigationBarColor = azulOscuro
        window.setBackgroundDrawable(android.graphics.drawable.ColorDrawable(azulOscuro))
        window.decorView.systemUiVisibility = 0

        // 1. Agregar el Bloque Hero Superior (Widgets)
        layout.addView(heroInicio())
    }

    private fun mostrarInicio() {
        mostrarPortada()
        /*
        if (false) {
            val layout = crearBase()

        layout.addView(heroInicio())
        layout.addView(
            encabezadoSeccion(
                "Ruta sugerida",
                "Comienza por lo esencial",
                "La portada ahora prioriza la secuencia natural de aprendizaje para que no te enfrentes a trece botones iguales de una sola vez."
            )
        )
        layout.addView(
            tarjetaModuloInicio(
                "01",
                "Base operacional",
                "Aprender procedimiento",
                "Recorre el flujo completo del control de sondaje, desde la preparacion hasta el cierre del reporte.",
                menu1
            ) { mostrarAprender() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "02",
                "Calculo guiado",
                "Calculadora de recuperacion",
                "Practica el calculo de metros recuperados y refuerza el criterio antes de pasar a simulaciones.",
                menu2
            ) { mostrarCalculadora() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "03",
                "Aplicacion",
                "Simulador de regularizacion",
                "Ubica tacos y soportes de distancia con una practica mas cercana al trabajo real.",
                menu3
            ) { mostrarRegularizacion() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "04",
                "Evaluacion",
                "Quiz con puntaje",
                "Mide tu avance con preguntas aleatorias y retroalimentacion inmediata.",
                menu5
            ) { iniciarQuiz() }
        )

        layout.addView(
            encabezadoSeccion(
                "Operacion en terreno",
                "Consulta rapida para el turno",
                "Estas pantallas quedan agrupadas como material de apoyo para decisiones, control operacional y trazabilidad."
            )
        )
        layout.addView(
            tarjetaModuloInicio(
                "05",
                "Criterio tecnico",
                "Criterios de medicion del testigo",
                "Revisa cuando castigar la recuperacion y como interpretar testigo entero, fracturado o molido.",
                menu8
            ) { mostrarCriteriosMedicion() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "06",
                "Seguridad",
                "Seguridad y riesgos",
                "Refuerza segregacion, EPP, silice, ruido, UV y caida de rocas.",
                menu9
            ) { mostrarSeguridadRiesgos() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "07",
                "Registro",
                "Reportabilidad",
                "Ordena los datos que deben quedar respaldados en cada turno y por cada pozo.",
                menu10
            ) { mostrarReportabilidad() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "08",
                "Control diario",
                "Paso a paso del turno",
                "Usa una guia rapida para preparar, ejecutar y cerrar la actividad sin omisiones.",
                menu11
            ) { mostrarChecklistTurno() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "09",
                "Trazabilidad",
                "Rotulacion de bandejas",
                "Mantiene la identificacion del testigo clara, legible y coherente con el reporte.",
                menu12
            ) { mostrarRotulacionBandejas() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "10",
                "Cambios operacionales",
                "Tricono y cambio de diametro",
                "Documenta tramos sin muestra y cambios de diametro sin perder continuidad.",
                menu13
            ) { mostrarTriconoDiametro() }
        )

        layout.addView(
            encabezadoSeccion(
                "Practica y apoyo visual",
                "Refuerza y repasa",
                "Aqui quedan los modulos mas ligeros para practicar escenarios, fijar conceptos y consultar material de apoyo."
            )
        )
        layout.addView(
            tarjetaModuloInicio(
                "11",
                "Practica activa",
                "Ejercicios practicos",
                "Resuelve situaciones concretas de recuperacion, seguridad, rotulacion y control operacional.",
                menu4
            ) { mostrarEjercicios() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "12",
                "Referencia",
                "Glosario",
                "Consulta definiciones clave de perforacion, herramientas, bandejas y componentes del proceso.",
                menu6
            ) { mostrarGlosario() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "13",
                "Vision general",
                "Mapas conceptuales",
                "Repasa el proceso con una estructura visual de control operacional, recuperacion y seguridad.",
                menu7
            ) { mostrarMapas() }
        )
    }


                ejercicio.enunciado,
                azul,
                azulClaro
            )
        )

        layout.addView(
            tarjeta(
                ejercicio.titulo,
                "Resuelve el caso y revisa la justificación debajo. Cada vez que entras a este apartado, el orden cambia.",
                azul,
                superficie
            )
        )

        val retroCard = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(18), dp(16), dp(18), dp(16))
            background = fondoRedondeado(superficieSuave, bordeSuave, 22)
            visibility = View.GONE

            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, dp(10), 0, dp(12))
            }
        }

        val retroTitulo = TextView(this).apply {
            textSize = 18f
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setTextColor(azulOscuro)
            setPadding(0, 0, 0, dp(8))
        }

        val retroTexto = TextView(this).apply {
            textSize = 15f
            setTextColor(grisTexto)
            setLineSpacing(dp(4).toFloat(), 1.0f)
        }

        retroCard.addView(retroTitulo)
        retroCard.addView(retroTexto)

        val botonSiguiente = boton("Siguiente ejercicio", azul) {
            if (ejercicioIndex < ejerciciosActuales.lastIndex) {
                ejercicioIndex++
                mostrarEjercicioActual()
            } else {
                mostrarResultadoEjercicios()
            }
        }.apply {
            visibility = View.GONE
        }

        ejercicio.opciones.forEachIndexed { index, opcion ->
            val botonOpcion = boton(opcion, azul) {
                val correcto = index == ejercicio.correcta

                botonesOpciones.forEachIndexed { indiceBoton, boton ->
                    boton.isEnabled = false
                    boton.alpha = if (indiceBoton == index) 1f else 0.66f
                }

                retroTitulo.text = if (correcto) "Respuesta correcta" else "Revisar respuesta"
                retroTitulo.setTextColor(if (correcto) verde else rojo)
                retroTexto.text = if (correcto) {
                    ejercicio.retroalimentacion
                } else {
                    "Respuesta correcta: ${ejercicio.opciones[ejercicio.correcta]}\n\n${ejercicio.retroalimentacion}"
                }
                retroCard.background = fondoRedondeado(
                    if (correcto) verdeClaro else naranjoClaro,
                    bordeSuave,
                    22
                )
                retroCard.visibility = View.VISIBLE
                botonSiguiente.text = if (ejercicioIndex < ejerciciosActuales.lastIndex) {
                    "Siguiente ejercicio"
                } else {
                    "Finalizar práctica"
                }
                botonSiguiente.visibility = View.VISIBLE
            }

            botonesOpciones += botonOpcion
            layout.addView(botonOpcion)
        }

        layout.addView(retroCard)
        layout.addView(botonSiguiente)
        }

        layout.addView(heroInicio())
        layout.addView(
            encabezadoSeccion(
                "Ruta sugerida",
                "Comienza por lo esencial",
                "La portada ahora prioriza la secuencia natural de aprendizaje para que no te enfrentes a trece botones iguales de una sola vez."
            )
        )
        layout.addView(
            tarjetaModuloInicio(
                "01",
                "Base operacional",
                "Aprender procedimiento",
                "Recorre el flujo completo del control de sondaje, desde la preparacion hasta el cierre del reporte.",
                menu1
            ) { mostrarAprender() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "02",
                "Calculo guiado",
                "Calculadora de recuperacion",
                "Practica el calculo de metros recuperados y refuerza el criterio antes de pasar a simulaciones.",
                menu2
            ) { mostrarCalculadora() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "03",
                "Aplicacion",
                "Simulador de regularizacion",
                "Ubica tacos y soportes de distancia con una practica mas cercana al trabajo real.",
                menu3
            ) { mostrarRegularizacion() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "04",
                "Evaluacion",
                "Quiz con puntaje",
                "Mide tu avance con preguntas aleatorias y retroalimentacion inmediata.",
                menu5
            ) { iniciarQuiz() }
        )

        layout.addView(
            encabezadoSeccion(
                "Operacion en terreno",
                "Consulta rapida para el turno",
                "Estas pantallas quedan agrupadas como material de apoyo para decisiones, control operacional y trazabilidad."
            )
        )
        layout.addView(
            tarjetaModuloInicio(
                "05",
                "Criterio tecnico",
                "Criterios de medicion del testigo",
                "Revisa cuando castigar la recuperacion y como interpretar testigo entero, fracturado o molido.",
                menu8
            ) { mostrarCriteriosMedicion() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "06",
                "Seguridad",
                "Seguridad y riesgos",
                "Refuerza segregacion, EPP, silice, ruido, UV y caida de rocas.",
                menu9
            ) { mostrarSeguridadRiesgos() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "07",
                "Registro",
                "Reportabilidad",
                "Ordena los datos que deben quedar respaldados en cada turno y por cada pozo.",
                menu10
            ) { mostrarReportabilidad() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "08",
                "Control diario",
                "Paso a paso del turno",
                "Usa una guia rapida para preparar, ejecutar y cerrar la actividad sin omisiones.",
                menu11
            ) { mostrarChecklistTurno() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "09",
                "Trazabilidad",
                "Rotulacion de bandejas",
                "Mantiene la identificacion del testigo clara, legible y coherente con el reporte.",
                menu12
            ) { mostrarRotulacionBandejas() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "10",
                "Cambios operacionales",
                "Tricono y cambio de diametro",
                "Documenta tramos sin muestra y cambios de diametro sin perder continuidad.",
                menu13
            ) { mostrarTriconoDiametro() }
        )

        layout.addView(
            encabezadoSeccion(
                "Practica y apoyo visual",
                "Refuerza y repasa",
                "Aqui quedan los modulos mas ligeros para practicar escenarios, fijar conceptos y consultar material de apoyo."
            )
        )
        layout.addView(
            tarjetaModuloInicio(
                "11",
                "Practica activa",
                "Ejercicios practicos",
                "Resuelve situaciones concretas de recuperacion, seguridad, rotulacion y control operacional.",
                menu4
            ) { mostrarEjercicios() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "12",
                "Referencia",
                "Glosario",
                "Consulta definiciones clave de perforacion, herramientas, bandejas y componentes del proceso.",
                menu6
            ) { mostrarGlosario() }
        )
        layout.addView(
            tarjetaModuloInicio(
                "13",
                "Vision general",
                "Mapas conceptuales",
                "Repasa el proceso con una estructura visual de control operacional, recuperacion y seguridad.",
                menu7
            ) { mostrarMapas() }
        )

        if (false) {
        layout.addView(
            bajada(
                "App de entrenamiento para practicar control operacional de sondaje diamantino: recuperación, regularización, tacos, bandejas, seguridad y reportabilidad."
            )
        )

        layout.addView(
            tarjeta(
                "Versión de aprendizaje",
                "Esta app permite estudiar el procedimiento, practicar cálculos, resolver ejercicios, revisar criterios de medición y reforzar seguridad operacional.",
                azul,
                azulClaro
            )
        )

        layout.addView(boton("1. Aprender procedimiento", menu1) { mostrarAprender() })
        layout.addView(boton("2. Calculadora de recuperación", menu2) { mostrarCalculadora() })
        layout.addView(boton("3. Criterios de medición del testigo", menu8) { mostrarCriteriosMedicion() })
        layout.addView(boton("4. Seguridad y riesgos", menu9) { mostrarSeguridadRiesgos() })
        layout.addView(boton("5. Reportabilidad", menu10) { mostrarReportabilidad() })
        layout.addView(boton("6. Paso a paso del turno", menu11) { mostrarChecklistTurno() })
        layout.addView(boton("7. Rotulación de bandejas", menu12) { mostrarRotulacionBandejas() })
        layout.addView(boton("8. Tricono y cambio de diámetro", menu13) { mostrarTriconoDiametro() })
        layout.addView(boton("9. Simulador de regularización", menu3) { mostrarRegularizacion() })
        layout.addView(boton("10. Ejercicios prácticos", menu4) { mostrarEjercicios() })
        layout.addView(boton("11. Quiz con puntaje", menu5) { iniciarQuiz() })
        layout.addView(boton("12. Glosario", menu6) { mostrarGlosario() })
        layout.addView(boton("13. Mapas conceptuales", menu7) { mostrarMapas() })
        }
    }

        */
    }

    private fun mostrarAprender() {
        val layout = crearBase()

        layout.addView(titulo("Aprender procedimiento", "Teóricos"))

        layout.addView(tarjeta("🔧 1. Preparación del trabajo", "Antes de iniciar el control, el controlador debe revisar el entorno, EPP, herramientas, materiales, equipos de apoyo y condiciones de seguridad. También debe conocer la información del pozo: cota, azimut, inclinación y profundidad.", azul, azulClaro))
        layout.addView(tarjeta("🛡️ 2. Segregación y seguridad", "El controlador debe mantenerse fuera del área de perforación y trabajar desde una zona segregada. Si necesita ingresar al área de la perforista, debe contar con autorización y charla de ingreso.", verde, verdeClaro))
        layout.addView(tarjeta("📦 3. Recepción del testigo", "Una vez extraído el tubo interior, la muestra debe revisarse y traspasarse a la bandeja procurando alterar lo menos posible el orden original del testigo.", naranjo, naranjoClaro))
        layout.addView(tarjeta("📐 4. Traspaso a bandeja", "El testigo se ordena desde arriba hacia abajo y de izquierda a derecha. Debe mantenerse el orden, dejar espacio para tacos y registrar cualquier situación especial, como fractura inducida o muestra molida.", purpura, purpuraClaro))
        layout.addView(tarjeta("📏 5. Medición de recuperación", "El controlador mide la muestra recuperada y calcula el porcentaje de recuperación respecto al tramo perforado. Cada corrida debe separarse mediante taco de bloqueo.", rojo, rojoClaro))
        layout.addView(tarjeta("📍 6. Regularización", "La regularización marca soportes de distancia definidos por el proyecto, por ejemplo cada 2 metros. El taco de regularizado debe representar lo más fielmente posible el metraje real del testigo.", azul, azulClaro))
        layout.addView(tarjeta("📋 7. Reportabilidad", "Al finalizar el turno, se registran metrajes, recuperación, diámetro, barras, herramientas, casing, aditivos, observaciones, mediciones y cualquier situación que afecte la calidad de la muestra.", verde, verdeClaro))
    }

    private fun mostrarCalculadoras(tabInicial: Int = -1) {
        val layout = crearBase()

        if (tabInicial != -1) {
            backAction = { mostrarCalculadoras(-1) }
            actualizarCallbackBack()
        }

        if (tabInicial == -1) {
            // ==========================================
            // MODO MENÚ / DASHBOARD (Vista por defecto)
            // ==========================================
            layout.addView(chip("Calculadoras", azulClaro, azul))
            layout.addView(titulo("Calculadoras operacionales", "Prácticos"))
            layout.addView(bajada("Selecciona una de las 5 herramientas de cálculo técnico para iniciar la operación en terreno."))

            // Contenedor principal del grid (ocupa el resto de la pantalla)
            val gridContainer = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    0,
                    1f
                )
            }

            fun crearDashboardWidget(
                tituloWidget: String,
                detalleWidget: String,
                colorAcento: Int,
                accion: () -> Unit
            ): LinearLayout {
                val card = LinearLayout(this).apply {
                    orientation = LinearLayout.VERTICAL
                    gravity = Gravity.CENTER_VERTICAL
                    setPadding(dp(16), dp(16), dp(16), dp(16))
                    background = fondoRedondeado(superficie, bordeSuave, radio = 22)
                    elevation = dp(3).toFloat()
                    
                    layoutParams = LinearLayout.LayoutParams(
                        0,
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        1f
                    )
                }

                // Círculo de color
                val circulo = View(this).apply {
                    background = fondoRedondeado(colorAcento, radio = 10)
                    val params = LinearLayout.LayoutParams(dp(16), dp(16))
                    params.setMargins(0, 0, 0, dp(10))
                    layoutParams = params
                }
                card.addView(circulo)

                card.addView(
                    TextView(this).apply {
                        text = tituloWidget
                        textSize = 17.5f
                        setTextColor(azulOscuro)
                        setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                        setPadding(0, 0, 0, dp(4))
                    }
                )

                card.addView(
                    TextView(this).apply {
                        text = detalleWidget
                        textSize = 13f
                        setTextColor(grisTexto)
                        setLineSpacing(dp(2).toFloat(), 1.0f)
                    }
                )

                aplicarInteraccion(card, accion)
                return card
            }

            val fila1 = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    0,
                    1f
                ).apply {
                    setMargins(0, 0, 0, dp(12))
                }
            }

            val fila2 = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    0,
                    1f
                ).apply {
                    setMargins(0, 0, 0, dp(12))
                }
            }

            val fila3 = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    0,
                    1f
                )
            }

            val widgetRec = crearDashboardWidget(
                "Recuperación",
                "Porcentaje de corrida perforado/recuperado",
                verde
            ) { mostrarCalculadoras(0) }

            val widgetContra = crearDashboardWidget(
                "Contra",
                "Estimación de contra con barras y fondo",
                purpura
            ) { mostrarCalculadoras(1) }

            fila1.addView(widgetRec)
            fila1.addView(widgetContra)
            (widgetRec.layoutParams as LinearLayout.LayoutParams).setMargins(0, 0, dp(12), 0)

            val widgetFondo = crearDashboardWidget(
                "Fondo Pozo",
                "Cálculo del fondo estimado del pozo",
                azul
            ) { mostrarCalculadoras(2) }

            val widgetReg = crearDashboardWidget(
                "Regularizar",
                "Simulación de ubicación física de tacos",
                naranjo
            ) { mostrarCalculadoras(3) }

            fila2.addView(widgetFondo)
            fila2.addView(widgetReg)
            (widgetFondo.layoutParams as LinearLayout.LayoutParams).setMargins(0, 0, dp(12), 0)

            val widgetPerf = crearDashboardWidget(
                "Perforado",
                "Cálculo de metros perforados por contras o fondo",
                azulClaro
            ) { mostrarCalculadoras(4) }

            fila3.addView(widgetPerf)

            gridContainer.addView(fila1)
            gridContainer.addView(fila2)
            gridContainer.addView(fila3)
            layout.addView(gridContainer)

            layout.addView(espacio(16))
    
        } else {
            // ==========================================
            // MODO CALCULADORA INDIVIDUAL (Con pestañas)
            // ==========================================
            
            // Botón de cabecera para regresar al menú de calculadoras
            layout.addView(
                botonSecundario("← Volver al menú de calculadoras") {
                    mostrarCalculadoras(-1)
                }
            )

            // Contenedor de pestañas segmentadas de 4 vías
            val tabsLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(dp(4), dp(4), dp(4), dp(4))
                background = fondoRedondeado(
                    if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(235, 242, 250),
                    if (modoOscuro) Color.rgb(51, 65, 85) else Color.TRANSPARENT,
                    radio = 16
                )
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 0, 0, dp(16))
                }
            }

            val tabRec = TextView(this).apply {
                text = "Recuperación"
                textSize = 12.5f
                gravity = Gravity.CENTER
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(0, dp(10), 0, dp(10))
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            }

            val tabContra = TextView(this).apply {
                text = "Contra"
                textSize = 12.5f
                gravity = Gravity.CENTER
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(0, dp(10), 0, dp(10))
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            }

            val tabFondo = TextView(this).apply {
                text = "Fondo Pozo"
                textSize = 12.5f
                gravity = Gravity.CENTER
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(0, dp(10), 0, dp(10))
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            }

            val tabReg = TextView(this).apply {
                text = "Regularizar"
                textSize = 12.5f
                gravity = Gravity.CENTER
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(0, dp(10), 0, dp(10))
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            }

            val tabPerf = TextView(this).apply {
                text = "Perforado"
                textSize = 12.5f
                gravity = Gravity.CENTER
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(0, dp(10), 0, dp(10))
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            }

            tabsLayout.addView(tabRec)
            tabsLayout.addView(tabContra)
            tabsLayout.addView(tabFondo)
            tabsLayout.addView(tabReg)
            tabsLayout.addView(tabPerf)
            layout.addView(tabsLayout)

            // --- Tarjetas y Fórmulas ---
            // 1. Recuperación
            val formulaRec = tarjeta(
                "Fórmula",
                "Recuperación (%) = (Muestra recuperada / Muestra perforada) × 100",
                azul,
                azulClaro
            )
            val ejemploRec = tarjeta(
                "Ejemplo rápido",
                "Si se perforan 1,50 m y se recuperan 1,20 m:\n\n1,20 / 1,50 × 100 = 80%",
                azul,
                azulClaro
            )

            // 2. Contra
            val formulaContra = tarjeta(
                "Fórmula usada",
                "Método 1 (Físico - Barras y Fondo):\nContra = (Cantidad de barras × Largo de barra) + Largo herramienta - Punto muerto - Fondo del pozo\n\nMétodo 2 (Operacional - Con Contra anterior):\nContra Actual = Contra Anterior - Perforado\n⚠️ Nota de Terreno: Si la Contra Anterior es menor al metraje Perforado, se le debe sumar el largo de una barra (3.0 o 2.9 m) a la contra anterior antes de la resta.",
                azul,
                azulClaro
            )

            // 3. Fondo
            val formulaFondo = tarjeta(
                "Fórmula usada",
                "Fondo del pozo = (Cantidad de barras × Largo de barra) + Largo herramienta - Punto muerto - Contra",
                azul,
                azulClaro
            )

            // 4. Regularización
            val formulaReg = tarjeta(
                "Fórmula de Regularizado",
                "Ubicación Física = Distancia Teórica × (Recuperado / Perforado)\n\n• Distancia Teórica = Metraje a Regularizar - Taco Inicial\n• Metraje Perforado = Taco Final - Taco Inicial",
                naranjo,
                naranjoClaro
            )

            // 5. Perforado
            val formulaPerf = tarjeta(
                "Fórmulas de Perforado",
                "Puedes calcular los metros perforados de dos maneras según tus datos:\n\n" +
                "• Método 1 (Por contras):\n  Perforado = Contra Anterior - Contra Actual\n" +
                "  (Se usa si el largo de la sarta no cambió)\n\n" +
                "• Método 2 (Por fondo de pozo):\n  Perforado = Fondo Actual - Fondo Anterior",
                verde,
                verdeClaro
            )

            layout.addView(formulaRec)
            layout.addView(ejemploRec)
            layout.addView(formulaContra)
            layout.addView(formulaFondo)
            layout.addView(formulaReg)
            layout.addView(formulaPerf)


            // --- Inputs ---
            // Recuperación
            val perforadoInput = campoNumero("Muestra perforada en metros. Ej: 1.50")
            val recuperadoInput = campoNumero("Muestra recuperada en metros. Ej: 1.20")
            
            // Contra & Fondo
            val cantidadBarrasInput = campoNumero("Cantidad de barras. Ej: 80")
            val largoBarraInput = campoNumero("Largo de barra en metros. Ej: 3.00")
            val largoHerramientaInput = campoNumero("Largo herramienta en metros. Ej: 1.50")
            val puntoMuertoInput = campoNumero("Punto muerto en metros. Ej: 0.80")
            val fondoPozoInput = campoNumero("Fondo del pozo en metros. Ej: 239.20")
            val contraInput = campoNumero("Contra en metros. Ej: 0.50")

            // Perforado
            val contraAnteriorInput = campoNumero("Contra anterior en metros. Ej: 0.80")
            val contraActualInput = campoNumero("Contra actual en metros. Ej: 0.20")
            val fondoAnteriorInput = campoNumero("Fondo anterior en metros. Ej: 240.00")
            val fondoActualInput = campoNumero("Fondo actual en metros. Ej: 241.50")

            // Regularización
            val tacoInicialInput = campoNumero("Taco inicial. Ej: 236.30")
            val tacoFinalInput = campoNumero("Taco final. Ej: 239.20")
            val recuperadoRegInput = campoNumero("Metros recuperados. Ej: 2.10")
            val regularizarInput = EditText(this).apply {
                hint = "Metrajes a regularizar (separados por comas). Ej: 238, 239"
                textSize = 16f
                setTextColor(azulOscuro)
                setHintTextColor(grisSecundario)
                inputType = InputType.TYPE_CLASS_TEXT
                minHeight = dp(54)
                setPadding(dp(16), dp(14), dp(16), dp(14))
                background = fondoRedondeado(superficie, bordeSuave, 20)

                val params = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, dp(6), 0, dp(10))
                layoutParams = params

                setOnFocusChangeListener { _, hasFocus ->
                    background = if (hasFocus) {
                        fondoRedondeado(superficie, azul, 20)
                    } else {
                        fondoRedondeado(superficie, bordeSuave, 20)
                    }
                }
            }

            layout.addView(perforadoInput)
            layout.addView(recuperadoInput)
            layout.addView(cantidadBarrasInput)
            layout.addView(largoBarraInput)
            layout.addView(largoHerramientaInput)
            layout.addView(puntoMuertoInput)
            layout.addView(fondoPozoInput)
            layout.addView(contraInput)
            layout.addView(contraAnteriorInput)
            layout.addView(contraActualInput)
            layout.addView(fondoAnteriorInput)
            layout.addView(fondoActualInput)
            layout.addView(tacoInicialInput)
            layout.addView(tacoFinalInput)
            layout.addView(recuperadoRegInput)
            layout.addView(regularizarInput)

            // --- Resultado ---
            val resultado = TextView(this).apply {
                text = "Resultado pendiente"
                textSize = 24f
                setTextColor(azulOscuro)
                gravity = Gravity.CENTER
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                setPadding(0, dp(18), 0, dp(6))
            }

            val justificacion = TextView(this).apply {
                text = ""
                textSize = 14.5f
                setTextColor(if (modoOscuro) Color.rgb(203, 213, 225) else Color.rgb(71, 85, 105))
                gravity = Gravity.START
                setLineSpacing(dp(4).toFloat(), 1.0f)
                setPadding(dp(16), dp(16), dp(16), dp(16))
                background = fondoRedondeado(
                    if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(241, 245, 249),
                    if (modoOscuro) Color.rgb(51, 65, 85) else Color.rgb(226, 232, 240),
                    radio = 16
                )
                
                val params = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, dp(6), 0, dp(18))
                layoutParams = params
                
                visibility = View.GONE
            }
            layout.addView(resultado)
            layout.addView(justificacion)

            // --- Botones ---
            // 1. Calcular Recuperación
            val btnCalcularRec = boton("Calcular recuperación", verde) {
                resaltarCampoError(perforadoInput, false)
                resaltarCampoError(recuperadoInput, false)

                val perforado = leerDouble(perforadoInput)
                val recuperado = leerDouble(recuperadoInput)

                var hasError = false
                if (perforado == null || perforado <= 0.0) {
                    resaltarCampoError(perforadoInput, true)
                    hasError = true
                }
                if (recuperado == null || recuperado < 0.0) {
                    resaltarCampoError(recuperadoInput, true)
                    hasError = true
                }

                if (hasError) {
                    Toast.makeText(this, "Ingresa valores válidos en los campos destacados", Toast.LENGTH_SHORT).show()
                    return@boton
                }

                val perforadoVal = perforado!!
                val recuperadoVal = recuperado!!

                val porcentaje = (recuperadoVal / perforadoVal) * 100
                val redondeado = round(porcentaje * 10) / 10

                val comentario = when {
                    porcentaje > 100 -> "Recuperación mayor al 100%. Revisar si existe muestra recuperada de una corrida anterior."
                    porcentaje >= 90 -> "Muy buena recuperación. Mantener registro claro del tramo."
                    porcentaje >= 70 -> "Recuperación aceptable. Revisar estado del testigo y compactación."
                    porcentaje >= 50 -> "Recuperación baja. Registrar observación y condición de muestra."
                    else -> "Recuperación crítica. Comunicar al supervisor y dejar registro."
                }

                resultado.gravity = Gravity.CENTER
                resultado.textSize = 32f
                resultado.text = "📊 $redondeado %"

                justificacion.visibility = View.VISIBLE
                justificacion.text =
                    "📊 Porcentaje de Recuperación: $redondeado %\n\n" +
                    "📖 Razonamiento paso a paso:\n" +
                    "1. Identificar datos:\n" +
                    "   • Muestra perforada: ${formato(perforadoVal)} m\n" +
                    "   • Muestra recuperada: ${formato(recuperadoVal)} m\n" +
                    "2. Aplicar fórmula:\n" +
                    "   • % Recuperación = (Recuperado / Perforado) × 100\n" +
                    "3. Desarrollar cálculo:\n" +
                    "   • (${formato(recuperadoVal)} / ${formato(perforadoVal)}) × 100 = $redondeado %\n\n" +
                    "💡 Conclusión: $comentario"
            }

            // 2. Calcular Contra
            val btnCalcularContra = boton("Calcular contra", purpura) {
                resaltarCampoError(cantidadBarrasInput, false)
                resaltarCampoError(largoBarraInput, false)
                resaltarCampoError(largoHerramientaInput, false)
                resaltarCampoError(puntoMuertoInput, false)
                resaltarCampoError(fondoPozoInput, false)
                resaltarCampoError(contraAnteriorInput, false)
                resaltarCampoError(perforadoInput, false)

                val cantidadBarras = leerDouble(cantidadBarrasInput)
                val largoBarra = leerDouble(largoBarraInput)
                val largoHerramienta = leerDouble(largoHerramientaInput)
                val puntoMuerto = leerDouble(puntoMuertoInput)
                val fondoPozo = leerDouble(fondoPozoInput)

                val contraAnterior = leerDouble(contraAnteriorInput)
                val perforado = leerDouble(perforadoInput)

                val tieneMetodo2 = contraAnteriorInput.visibility == View.VISIBLE

                if (tieneMetodo2) {
                    var hasError = false
                    if (contraAnterior == null || contraAnterior < 0.0) {
                        resaltarCampoError(contraAnteriorInput, true)
                        hasError = true
                    }
                    if (perforado == null || perforado <= 0.0) {
                        resaltarCampoError(perforadoInput, true)
                        hasError = true
                    }
                    if (largoBarra != null && largoBarra <= 0.0) {
                        resaltarCampoError(largoBarraInput, true)
                        hasError = true
                    }
                    if (hasError) {
                        Toast.makeText(this, "Ingresa valores válidos en los campos destacados", Toast.LENGTH_SHORT).show()
                        return@boton
                    }
                } else {
                    var hasError = false
                    if (cantidadBarras == null || cantidadBarras < 0) {
                        resaltarCampoError(cantidadBarrasInput, true)
                        hasError = true
                    }
                    if (largoBarra == null || largoBarra <= 0) {
                        resaltarCampoError(largoBarraInput, true)
                        hasError = true
                    }
                    if (largoHerramienta == null || largoHerramienta < 0) {
                        resaltarCampoError(largoHerramientaInput, true)
                        hasError = true
                    }
                    if (puntoMuerto == null || puntoMuerto < 0) {
                        resaltarCampoError(puntoMuertoInput, true)
                        hasError = true
                    }
                    if (fondoPozo == null || fondoPozo <= 0) {
                        resaltarCampoError(fondoPozoInput, true)
                        hasError = true
                    }
                    if (hasError) {
                        Toast.makeText(this, "Ingresa valores válidos en los campos destacados", Toast.LENGTH_SHORT).show()
                        return@boton
                    }
                }

                if (tieneMetodo2) {
                    val largoBarraEfectivo = largoBarra ?: 3.0
                    var contraAnteriorAjustada = contraAnterior!!
                    val seAgregoBarra = contraAnteriorAjustada < perforado!!
                    if (seAgregoBarra) {
                        contraAnteriorAjustada += largoBarraEfectivo
                    }
                    val contra = contraAnteriorAjustada - perforado!!
                    val contraRed = round(contra * 100) / 100

                    resultado.gravity = Gravity.CENTER
                    resultado.textSize = 32f
                    resultado.text = "📐 ${formato(contraRed)} m"

                    justificacion.visibility = View.VISIBLE
                    
                    val pasoAjuste = if (seAgregoBarra) {
                        "⚠️ La Contra Anterior (${formato(contraAnterior)} m) es menor al metraje perforado (${formato(perforado)} m), lo que indica operacionalmente que se agregó una nueva barra de perforación de ${formato(largoBarraEfectivo)} m a la sarta.\n" +
                        "   • Contra Anterior Ajustada = ${formato(contraAnterior)} m + ${formato(largoBarraEfectivo)} m = ${formato(contraAnteriorAjustada)} m\n\n"
                    } else {
                        ""
                    }
                    
                    val formulaUsada = if (seAgregoBarra) {
                        "Contra Actual = (Contra Anterior + Largo Barra) - Perforado"
                    } else {
                        "Contra Actual = Contra Anterior - Perforado"
                    }
                    
                    val calculoDesarrollado = if (seAgregoBarra) {
                        "Contra Anterior Ajustada (${formato(contraAnteriorAjustada)} m) - Perforado (${formato(perforado)} m) = ${formato(contraRed)} m"
                    } else {
                        "Contra Anterior (${formato(contraAnterior)} m) - Perforado (${formato(perforado)} m) = ${formato(contraRed)} m"
                    }

                    justificacion.text =
                        "📐 Contra Actual: ${formato(contraRed)} m\n\n" +
                        "📖 Razonamiento paso a paso (Método Contras/Perforación):\n" +
                        pasoAjuste +
                        "1. Aplicar fórmula:\n" +
                        "   • $formulaUsada\n" +
                        "2. Desarrollar cálculo:\n" +
                        "   • $calculoDesarrollado\n\n" +
                        "💡 Tip de Terreno: Esta forma de cálculo es ideal si se conoce con exactitud el metraje avanzado en la corrida y la contra anterior."
                    return@boton
                }

                // Método 1 (Sarta de barras y fondo) o Ambos
                val largoTotalBarras = cantidadBarras!! * largoBarra!!
                val profundidadCalculada = largoTotalBarras + largoHerramienta!! - puntoMuerto!!
                val contra = profundidadCalculada - fondoPozo!!
                val contraRedondeada = round(contra * 100) / 100
                val profundidadRedondeada = round(profundidadCalculada * 100) / 100
                val herramientaRedondeada = round(largoHerramienta * 100) / 100

                val comentario = when {
                    contra < 0 -> "Resultado negativo. Revisa los datos ingresados o la convención usada para punto muerto/largo herramienta."
                    contra == 0.0 -> "No se obtiene contra estimada. Verifica con perforista si corresponde."
                    contra > largoBarra -> "La contra supera el largo de una barra. Revisa cantidad de barras, fondo del pozo o datos de herramienta."
                    else -> "Contra dentro de rango esperable. Verificar con perforista antes de registrar."
                }

                resultado.gravity = Gravity.CENTER
                resultado.textSize = 32f
                resultado.text = "📐 ${formato(contraRedondeada)} m"

                val sb = StringBuilder()
                sb.append("📐 Contra Estimada: ${formato(contraRedondeada)} m\n")
                sb.append("📏 Profundidad Física Calculada: ${formato(profundidadRedondeada)} m\n\n")
                sb.append("📖 Razonamiento paso a paso:\n")
                sb.append("1. Calcular largo total de barras:\n")
                sb.append("   • Barras (${formato(cantidadBarras)}) × Largo barra (${formato(largoBarra)} m) = ${formato(largoTotalBarras)} m\n")
                sb.append("2. Obtener largo de herramienta:\n")
                sb.append("   • Herramienta = ${formato(herramientaRedondeada)} m\n")
                sb.append("3. Calcular profundidad física (extremo de la herramienta):\n")
                sb.append("   • Largo barras (${formato(largoTotalBarras)} m) + Herramienta (${formato(herramientaRedondeada)} m) - Punto muerto (${formato(puntoMuerto)} m) = ${formato(profundidadRedondeada)} m\n")
                sb.append("4. Calcular Contra:\n")
                sb.append("   • Profundidad (${formato(profundidadRedondeada)} m) - Fondo del pozo (${formato(fondoPozo)} m) = ${formato(contraRedondeada)} m\n\n")

                if (tieneMetodo2) {
                    val largoBarraEfectivo = largoBarra ?: 3.0
                    var contraAnteriorAjustada = contraAnterior!!
                    val seAgregoBarra = contraAnteriorAjustada < perforado!!
                    if (seAgregoBarra) {
                        contraAnteriorAjustada += largoBarraEfectivo
                    }
                    val contraM2 = contraAnteriorAjustada - perforado!!
                    val contraM2Red = round(contraM2 * 100) / 100
                    sb.append("🔍 Comparación con Método Alternativo (Contra Anterior - Perforado):\n")
                    if (seAgregoBarra) {
                        sb.append("   • Se detectó adición de barra: (${formato(contraAnterior)} m + ${formato(largoBarraEfectivo)} m) - ${formato(perforado)} m = ${formato(contraM2Red)} m\n")
                    } else {
                        sb.append("   • Cálculo: ${formato(contraAnterior)} m - ${formato(perforado)} m = ${formato(contraM2Red)} m\n")
                    }
                    val diff = kotlin.math.abs(contraRedondeada - contraM2Red)
                    if (diff < 0.01) {
                        sb.append("   • ✅ ¡Ambos métodos coinciden perfectamente!\n\n")
                    } else {
                        sb.append("   • ⚠️ Diferencia de ${formato(diff)} m detectada. Revisa los datos de sarta o el metraje perforado.\n\n")
                    }
                }

                sb.append("💡 Conclusión: $comentario")
                justificacion.visibility = View.VISIBLE
                justificacion.text = sb.toString().trim()
            }

            // 3. Calcular Fondo
            val btnCalcularFondo = boton("Calcular fondo del pozo", purpura) {
                resaltarCampoError(cantidadBarrasInput, false)
                resaltarCampoError(largoBarraInput, false)
                resaltarCampoError(largoHerramientaInput, false)
                resaltarCampoError(puntoMuertoInput, false)
                resaltarCampoError(contraInput, false)

                val cantidadBarras = leerDouble(cantidadBarrasInput)
                val largoBarra = leerDouble(largoBarraInput)
                val largoHerramienta = leerDouble(largoHerramientaInput)
                val puntoMuerto = leerDouble(puntoMuertoInput)
                val contra = leerDouble(contraInput)

                var hasError = false
                if (cantidadBarras == null || cantidadBarras < 0) {
                    resaltarCampoError(cantidadBarrasInput, true)
                    hasError = true
                }
                if (largoBarra == null || largoBarra <= 0) {
                    resaltarCampoError(largoBarraInput, true)
                    hasError = true
                }
                if (largoHerramienta == null || largoHerramienta < 0) {
                    resaltarCampoError(largoHerramientaInput, true)
                    hasError = true
                }
                if (puntoMuerto == null || puntoMuerto < 0) {
                    resaltarCampoError(puntoMuertoInput, true)
                    hasError = true
                }
                if (contra == null || contra < 0) {
                    resaltarCampoError(contraInput, true)
                    hasError = true
                }

                if (hasError) {
                    Toast.makeText(this, "Ingresa valores válidos en los campos destacados", Toast.LENGTH_SHORT).show()
                    return@boton
                }

                val cantidadBarrasVal = cantidadBarras!!
                val largoBarraVal = largoBarra!!
                val largoHerramientaVal = largoHerramienta!!
                val puntoMuertoVal = puntoMuerto!!
                val contraVal = contra!!

                val largoTotalBarras = cantidadBarrasVal * largoBarraVal
                val fondoPozo = largoTotalBarras + largoHerramientaVal - puntoMuertoVal - contraVal

                val largoTotalRedondeado = round(largoTotalBarras * 100) / 100
                val fondoRedondeado = round(fondoPozo * 100) / 100

                val comentario = when {
                    fondoPozo < 0 -> {
                        "Resultado no válido. Revisa cantidad de barras, largo de barra, largo herramienta, punto muerto o contra."
                    }
                    contraVal > largoBarraVal -> {
                        "La contra ingresada supera el largo de una barra. Verifica el dato con el perforista."
                    }
                    else -> {
                        "Fondo estimado calculado. Confirmar con los datos operacionales antes de registrar."
                    }
                }

                resultado.gravity = Gravity.CENTER
                resultado.textSize = 32f
                resultado.text = "🕳️ ${formato(fondoRedondeado)} m"

                justificacion.visibility = View.VISIBLE
                justificacion.text =
                    "🕳️ Fondo del Pozo Estimado: ${formato(fondoRedondeado)} m\n" +
                    "📏 Largo Total de Barras: ${formato(largoTotalRedondeado)} m\n\n" +
                    "📖 Razonamiento paso a paso:\n" +
                    "1. Calcular largo total de barras:\n" +
                    "   • Barras (${formato(cantidadBarrasVal)}) × Largo barra (${formato(largoBarraVal)} m) = ${formato(largoTotalBarras)} m\n" +
                    "2. Aplicar fórmula:\n" +
                    "   • Fondo = Largo barras + Largo herramienta - Punto muerto - Contra\n" +
                    "3. Desarrollar cálculo:\n" +
                    "   • ${formato(largoTotalBarras)} m + ${formato(largoHerramientaVal)} m - ${formato(puntoMuertoVal)} m - ${formato(contraVal)} m = ${formato(fondoRedondeado)} m\n\n" +
                    "💡 Conclusión: $comentario"
            }

            // 4. Calcular Regularización
            val btnCalcularReg = boton("Calcular ubicación del regularizado", naranjo) {
                resaltarCampoError(tacoInicialInput, false)
                resaltarCampoError(tacoFinalInput, false)
                resaltarCampoError(recuperadoRegInput, false)
                resaltarCampoError(regularizarInput, false)

                val inicio = leerDouble(tacoInicialInput)
                val fin = leerDouble(tacoFinalInput)
                val recuperado = leerDouble(recuperadoRegInput)
                val regularizarRaw = regularizarInput.text.toString().trim()

                var hasError = false
                if (inicio == null || inicio < 0.0) {
                    resaltarCampoError(tacoInicialInput, true)
                    hasError = true
                }
                if (fin == null || fin <= (inicio ?: 0.0)) {
                    resaltarCampoError(tacoFinalInput, true)
                    hasError = true
                }
                if (recuperado == null || recuperado <= 0.0) {
                    resaltarCampoError(recuperadoRegInput, true)
                    hasError = true
                }
                if (regularizarRaw.isEmpty()) {
                    resaltarCampoError(regularizarInput, true)
                    hasError = true
                }

                if (hasError) {
                    Toast.makeText(this, "Ingresa valores válidos en los campos destacados", Toast.LENGTH_SHORT).show()
                    return@boton
                }

                val regularizarList = regularizarRaw.split(",")
                    .mapNotNull { it.trim().toDoubleOrNull() }

                if (regularizarList.isEmpty()) {
                    resaltarCampoError(regularizarInput, true)
                    Toast.makeText(this, "Ingresa metrajes válidos separados por comas", Toast.LENGTH_SHORT).show()
                    return@boton
                }

                val metrajesInvalidos = regularizarList.filter { it < (inicio ?: 0.0) || it > (fin ?: 0.0) }
                if (metrajesInvalidos.isNotEmpty()) {
                    resaltarCampoError(regularizarInput, true)
                    Toast.makeText(this, "Todos los metrajes deben estar dentro del tramo [${formato(inicio ?: 0.0)} - ${formato(fin ?: 0.0)}]", Toast.LENGTH_LONG).show()
                    return@boton
                }

                val inicioVal = inicio!!
                val finVal = fin!!
                val recuperadoVal = recuperado!!

                val perforado = finVal - inicioVal
                val recPorcentaje = recuperadoVal / perforado * 100
                val recuperacionRedondeada = round(recPorcentaje * 10) / 10

                val metrajesOrdenados = regularizarList.sorted()
                val resultadosFisicos = metrajesOrdenados.map { metraje ->
                    val distTeorica = metraje - inicioVal
                    val distFisica = distTeorica * recuperadoVal / perforado
                    val distRedondeada = round(distFisica * 100) / 100
                    metraje to distRedondeada
                }

                resultado.gravity = Gravity.CENTER
                resultado.textSize = 26f
                resultado.text = "📍 Ubicaciones Calculadas"

                val sb = StringBuilder()
                sb.append("📍 Ubicaciones Físicas Calculadas:\n\n")
                sb.append("📖 Razonamiento paso a paso:\n")
                sb.append("1. Calcular metros perforados reales del tramo:\n")
                sb.append("   • Taco final (${formato(finVal)} m) - Taco inicial (${formato(inicioVal)} m) = ${formato(perforado)} m\n")
                sb.append("2. Obtener porcentaje de recuperación de muestra:\n")
                sb.append("   • (Recuperado (${formato(recuperadoVal)} m) / Perforado (${formato(perforado)} m)) × 100 = $recuperacionRedondeada %\n")
                sb.append("3. Escalar cada metraje según pérdida:\n")
                sb.append("   • Fórmula: Distancia física = Distancia teórica × (Recuperado / Perforado)\n")
                sb.append("   • Donde: Distancia teórica = Metraje regularizado - Taco inicial\n\n")
                sb.append("Resultados:\n")

                resultadosFisicos.forEachIndexed { index, (metraje, distFisica) ->
                    val distTeorica = metraje - inicioVal
                    sb.append("• Para taco a ${formato(metraje)} m:\n")
                    sb.append("   - Distancia teórica: ${formato(distTeorica)} m\n")
                    sb.append("   - Ubicación física: ${formato(distTeorica)} m × (${formato(recuperadoVal)} / ${formato(perforado)}) = ${formato(distFisica)} m desde taco inicial\n")
                    if (index > 0) {
                        val distPrev = resultadosFisicos[index - 1].second
                        val diff = distFisica - distPrev
                        val diffRedondeada = round(diff * 100) / 100
                        val metrajePrev = resultadosFisicos[index - 1].first
                        sb.append("   - Instrucción: Medir ${formato(diffRedondeada)} m físicos a partir del taco a ${formato(metrajePrev)} m\n")
                    }
                    sb.append("\n")
                }

                justificacion.visibility = View.VISIBLE
                justificacion.text = sb.toString().trim()
            }

            val btnLimpiar = botonSecundario("Limpiar todos los campos") {
                perforadoInput.text.clear()
                recuperadoInput.text.clear()
                cantidadBarrasInput.text.clear()
                largoBarraInput.text.clear()
                largoHerramientaInput.text.clear()
                puntoMuertoInput.text.clear()
                fondoPozoInput.text.clear()
                contraInput.text.clear()
                tacoInicialInput.text.clear()
                tacoFinalInput.text.clear()
                recuperadoRegInput.text.clear()
                regularizarInput.text.clear()
                contraAnteriorInput.text.clear()
                contraActualInput.text.clear()
                fondoAnteriorInput.text.clear()
                fondoActualInput.text.clear()
                resultado.gravity = Gravity.CENTER
                resultado.textSize = 24f
                resultado.text = "Resultado pendiente"
                justificacion.text = ""
                justificacion.visibility = View.GONE
            }

            val btnCalcularPerf = boton("Calcular perforado", verde) {
                resaltarCampoError(contraAnteriorInput, false)
                resaltarCampoError(contraActualInput, false)
                resaltarCampoError(fondoAnteriorInput, false)
                resaltarCampoError(fondoActualInput, false)

                val contraAnterior = leerDouble(contraAnteriorInput)
                val contraActual = leerDouble(contraActualInput)
                val fondoAnterior = leerDouble(fondoAnteriorInput)
                val fondoActual = leerDouble(fondoActualInput)

                val tieneContrasInput = contraAnteriorInput.text.isNotEmpty() || contraActualInput.text.isNotEmpty()
                val tieneFondosInput = fondoAnteriorInput.text.isNotEmpty() || fondoActualInput.text.isNotEmpty()

                if (!tieneContrasInput && !tieneFondosInput) {
                    resaltarCampoError(contraAnteriorInput, true)
                    resaltarCampoError(contraActualInput, true)
                    resaltarCampoError(fondoAnteriorInput, true)
                    resaltarCampoError(fondoActualInput, true)
                    Toast.makeText(this, "Por favor ingresa Contra Anterior y Actual, o Fondo Anterior y Actual", Toast.LENGTH_SHORT).show()
                    return@boton
                }

                var hasError = false
                if (tieneContrasInput) {
                    if (contraAnterior == null || contraAnterior < 0) {
                        resaltarCampoError(contraAnteriorInput, true)
                        hasError = true
                    }
                    if (contraActual == null || contraActual < 0) {
                        resaltarCampoError(contraActualInput, true)
                        hasError = true
                    }
                }
                if (tieneFondosInput) {
                    if (fondoAnterior == null || fondoAnterior < 0) {
                        resaltarCampoError(fondoAnteriorInput, true)
                        hasError = true
                    }
                    if (fondoActual == null || fondoActual < 0) {
                        resaltarCampoError(fondoActualInput, true)
                        hasError = true
                    }
                }

                if (hasError) {
                    Toast.makeText(this, "Ingresa valores válidos en los campos destacados", Toast.LENGTH_SHORT).show()
                    return@boton
                }

                val tieneContras = contraAnterior != null && contraActual != null
                val tieneFondos = fondoAnterior != null && fondoActual != null

                val mainResultText = when {
                    tieneContras -> {
                        val perfContra = contraAnterior!! - contraActual!!
                        val perfContraRed = round(perfContra * 100) / 100
                        "⛏️ ${formato(perfContraRed)} m"
                    }
                    else -> {
                        val perfFondo = fondoActual!! - fondoAnterior!!
                        val perfFondoRed = round(perfFondo * 100) / 100
                        "⛏️ ${formato(perfFondoRed)} m"
                    }
                }

                resultado.gravity = Gravity.CENTER
                resultado.textSize = 32f
                resultado.text = mainResultText

                val sb = java.lang.StringBuilder()
                sb.append("⛏️ Metraje Perforado Estimado:\n\n")

                if (tieneContras) {
                    val perfContra = contraAnterior!! - contraActual!!
                    val perfContraRed = round(perfContra * 100) / 100
                    
                    sb.append("🔹 Método 1 (Por contras):\n")
                    sb.append("   • Fórmula: Perforado = Contra Anterior - Contra Actual\n")
                    sb.append("   • Cálculo: ${formato(contraAnterior)} m - ${formato(contraActual)} m\n")
                    sb.append("   • Resultado: ${formato(perfContraRed)} m\n\n")
                }

                if (tieneFondos) {
                    val perfFondo = fondoActual!! - fondoAnterior!!
                    val perfFondoRed = round(perfFondo * 100) / 100
                    
                    sb.append("🔹 Método 2 (Por fondo de pozo):\n")
                    sb.append("   • Fórmula: Perforado = Fondo Actual - Fondo Anterior\n")
                    sb.append("   • Cálculo: ${formato(fondoActual)} m - ${formato(fondoAnterior)} m\n")
                    sb.append("   • Resultado: ${formato(perfFondoRed)} m\n\n")
                }

                if (tieneContras && tieneFondos) {
                    val perfContra = contraAnterior!! - contraActual!!
                    val perfFondo = fondoActual!! - fondoAnterior!!
                    val diff = kotlin.math.abs(perfContra - perfFondo)
                    if (diff < 0.01) {
                        sb.append("✅ ¡Excelente! Ambos métodos coinciden perfectamente.")
                    } else {
                        sb.append("⚠️ Advertencia: Los métodos difieren por ${formato(diff)} m. Revisa si hubo cambio en el largo de la sarta o en las barras.")
                    }
                } else {
                    sb.append("💡 Tip de Terreno: Si cuentas con ambos tipos de datos, puedes ingresarlos todos para verificar la consistencia del control.")
                }

                justificacion.visibility = View.VISIBLE
                justificacion.text = sb.toString().trim()
            }

            layout.addView(btnCalcularRec)
            layout.addView(btnCalcularContra)
            layout.addView(btnCalcularFondo)
            layout.addView(btnCalcularReg)
            layout.addView(btnCalcularPerf)
            layout.addView(btnLimpiar)

            // --- Lógica de pestañas ---
            fun actualizarTabs(tabIndex: Int) {
                val colorVerdeActivo = verde
                val colorPurpuraActivo = purpura
                val colorNaranjoActivo = naranjo

                val textoActivo = Color.WHITE
                val textoVerdeInactivo = verde
                val textoPurpuraInactivo = purpura
                val textoNaranjoInactivo = naranjo

                // Colores dinámicos de pestañas
                val colorInactivo = if (modoOscuro) Color.rgb(148, 163, 184) else Color.rgb(100, 116, 139)

                tabRec.background = if (tabIndex == 0) fondoRedondeado(colorVerdeActivo, radio = 14) else null
                tabRec.setTextColor(if (tabIndex == 0) textoActivo else colorInactivo)

                tabContra.background = if (tabIndex == 1) fondoRedondeado(colorPurpuraActivo, radio = 14) else null
                tabContra.setTextColor(if (tabIndex == 1) textoActivo else colorInactivo)

                tabFondo.background = if (tabIndex == 2) fondoRedondeado(colorPurpuraActivo, radio = 14) else null
                tabFondo.setTextColor(if (tabIndex == 2) textoActivo else colorInactivo)

                tabReg.background = if (tabIndex == 3) fondoRedondeado(colorNaranjoActivo, radio = 14) else null
                tabReg.setTextColor(if (tabIndex == 3) textoActivo else colorInactivo)

                tabPerf.background = if (tabIndex == 4) fondoRedondeado(colorVerdeActivo, radio = 14) else null
                tabPerf.setTextColor(if (tabIndex == 4) textoActivo else colorInactivo)

                // Visibilities
                // 1. Recuperación
                formulaRec.visibility = if (tabIndex == 0) View.VISIBLE else View.GONE
                ejemploRec.visibility = if (tabIndex == 0) View.VISIBLE else View.GONE
                perforadoInput.visibility = if (tabIndex == 0 || tabIndex == 1) View.VISIBLE else View.GONE
                recuperadoInput.visibility = if (tabIndex == 0) View.VISIBLE else View.GONE
                btnCalcularRec.visibility = if (tabIndex == 0) View.VISIBLE else View.GONE

                // 2. Contra
                formulaContra.visibility = if (tabIndex == 1) View.VISIBLE else View.GONE
                fondoPozoInput.visibility = if (tabIndex == 1) View.VISIBLE else View.GONE
                contraAnteriorInput.visibility = if (tabIndex == 1 || tabIndex == 4) View.VISIBLE else View.GONE
                btnCalcularContra.visibility = if (tabIndex == 1) View.VISIBLE else View.GONE

                // 3. Fondo
                formulaFondo.visibility = if (tabIndex == 2) View.VISIBLE else View.GONE
                contraInput.visibility = if (tabIndex == 2) View.VISIBLE else View.GONE
                btnCalcularFondo.visibility = if (tabIndex == 2) View.VISIBLE else View.GONE

                // 4. Regularización
                formulaReg.visibility = if (tabIndex == 3) View.VISIBLE else View.GONE
                tacoInicialInput.visibility = if (tabIndex == 3) View.VISIBLE else View.GONE
                tacoFinalInput.visibility = if (tabIndex == 3) View.VISIBLE else View.GONE
                recuperadoRegInput.visibility = if (tabIndex == 3) View.VISIBLE else View.GONE
                regularizarInput.visibility = if (tabIndex == 3) View.VISIBLE else View.GONE
                btnCalcularReg.visibility = if (tabIndex == 3) View.VISIBLE else View.GONE

                // 5. Perforado
                formulaPerf.visibility = if (tabIndex == 4) View.VISIBLE else View.GONE
                contraActualInput.visibility = if (tabIndex == 4) View.VISIBLE else View.GONE
                fondoAnteriorInput.visibility = if (tabIndex == 4) View.VISIBLE else View.GONE
                fondoActualInput.visibility = if (tabIndex == 4) View.VISIBLE else View.GONE
                btnCalcularPerf.visibility = if (tabIndex == 4) View.VISIBLE else View.GONE

                // El botón limpiar siempre está visible para todas las calculadoras
                btnLimpiar.visibility = View.VISIBLE

                // Campos compartidos de barras (Contra y Fondo)
                val esContraOFondo = tabIndex == 1 || tabIndex == 2
                cantidadBarrasInput.visibility = if (esContraOFondo) View.VISIBLE else View.GONE
                largoBarraInput.visibility = if (esContraOFondo) View.VISIBLE else View.GONE
                largoHerramientaInput.visibility = if (esContraOFondo) View.VISIBLE else View.GONE
                puntoMuertoInput.visibility = if (esContraOFondo) View.VISIBLE else View.GONE

                // Colores del texto del resultado
                resultado.setTextColor(
                    when (tabIndex) {
                        0 -> verde
                        1, 2 -> purpura
                        4 -> verde
                        else -> naranjo
                    }
                )
                resultado.gravity = Gravity.CENTER
                resultado.textSize = 24f
                resultado.text = "Resultado pendiente"
                justificacion.text = ""
                justificacion.visibility = View.GONE
            }

            tabRec.setOnClickListener { actualizarTabs(0) }
            tabContra.setOnClickListener { actualizarTabs(1) }
            tabFondo.setOnClickListener { actualizarTabs(2) }
            tabReg.setOnClickListener { actualizarTabs(3) }
            tabPerf.setOnClickListener { actualizarTabs(4) }

            actualizarTabs(tabInicial)
        }
    }



    private fun mostrarRegularizacion() {
        val layout = crearBase()

        layout.addView(titulo("Simulador de regularización", "Prácticos"))

        layout.addView(
            tarjeta(
                "Objetivo",
                "Este simulador calcula la distancia física aproximada donde debería ubicarse un taco de regularizado dentro de un tramo con pérdida de muestra.",
                naranjo,
                naranjoClaro
            )
        )

        val tacoInicialInput = campoNumero("Taco inicial. Ej: 236.30")
        val tacoFinalInput = campoNumero("Taco final. Ej: 239.20")
        val recuperadoInput = campoNumero("Metros recuperados. Ej: 2.10")
        val regularizarInput = EditText(this).apply {
            hint = "Metrajes a regularizar (separados por comas). Ej: 238, 239"
            textSize = 16f
            setTextColor(azulOscuro)
            setHintTextColor(grisSecundario)
            inputType = InputType.TYPE_CLASS_TEXT
            minHeight = dp(54)
            setPadding(dp(16), dp(14), dp(16), dp(14))
            background = fondoRedondeado(superficie, bordeSuave, 20)

            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, dp(6), 0, dp(10))
            layoutParams = params

            setOnFocusChangeListener { _, hasFocus ->
                background = if (hasFocus) {
                    fondoRedondeado(superficie, azul, 20)
                } else {
                    fondoRedondeado(superficie, bordeSuave, 20)
                }
            }
        }

        layout.addView(tacoInicialInput)
        layout.addView(tacoFinalInput)
        layout.addView(recuperadoInput)
        layout.addView(regularizarInput)

        val resultado = TextView(this).apply {
            text = "Resultado pendiente"
            textSize = 21f
            setTextColor(naranjo)
            gravity = Gravity.CENTER
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setPadding(0, dp(18), 0, dp(18))
        }

        layout.addView(resultado)

        val btnCalcular = boton("Calcular ubicación del regularizado", naranjo) {
            val inicio = leerDouble(tacoInicialInput)
            val fin = leerDouble(tacoFinalInput)
            val recuperado = leerDouble(recuperadoInput)
            val regularizarRaw = regularizarInput.text.toString().trim()

            if (inicio == null || fin == null || recuperado == null || regularizarRaw.isEmpty() || fin <= inicio || recuperado <= 0.0) {
                Toast.makeText(this, "Ingresa valores válidos", Toast.LENGTH_SHORT).show()
                return@boton
            }

            val regularizarList = regularizarRaw.split(",")
                .mapNotNull { it.trim().toDoubleOrNull() }

            if (regularizarList.isEmpty()) {
                Toast.makeText(this, "Ingresa metrajes válidos separados por comas", Toast.LENGTH_SHORT).show()
                return@boton
            }

            val metrajesInvalidos = regularizarList.filter { it < inicio || it > fin }
            if (metrajesInvalidos.isNotEmpty()) {
                Toast.makeText(this, "Todos los metrajes deben estar dentro del tramo [${formato(inicio)} - ${formato(fin)}]", Toast.LENGTH_LONG).show()
                return@boton
            }

            val perforado = fin - inicio
            val recPorcentaje = recuperado / perforado * 100
            val recuperacionRedondeada = round(recPorcentaje * 10) / 10

            val metrajesOrdenados = regularizarList.sorted()
            val resultadosFisicos = metrajesOrdenados.map { metraje ->
                val distTeorica = metraje - inicio
                val distFisica = distTeorica * recuperado / perforado
                val distRedondeada = round(distFisica * 100) / 100
                metraje to distRedondeada
            }

            val sb = StringBuilder()
            sb.append("Perforado: ${formato(perforado)} m\n")
            sb.append("Recuperación: $recuperacionRedondeada %\n\n")

            resultadosFisicos.forEachIndexed { index, (metraje, distFisica) ->
                sb.append("📍 Taco ${formato(metraje)} m:\n")
                sb.append("   • Desde inicio: ${formato(distFisica)} m\n")
                if (index > 0) {
                    val distPrev = resultadosFisicos[index - 1].second
                    val diff = distFisica - distPrev
                    val diffRedondeada = round(diff * 100) / 100
                    val metrajePrev = resultadosFisicos[index - 1].first
                    sb.append("   • Medir ${formato(diffRedondeada)} m desde taco ${formato(metrajePrev)} m\n")
                }
                sb.append("\n")
            }

            resultado.text = sb.toString().trim()
        }

        val btnLimpiar = botonSecundario("Limpiar todos los campos") {
            tacoInicialInput.text.clear()
            tacoFinalInput.text.clear()
            recuperadoInput.text.clear()
            regularizarInput.text.clear()
            resultado.text = "Resultado pendiente"
        }

        layout.addView(btnCalcular)
        layout.addView(btnLimpiar)

        layout.addView(
            tarjeta(
                "Importante",
                "Este cálculo es una ayuda práctica. En terreno se debe aplicar criterio geológico, revisar condición del testigo y registrar cualquier ajuste de taco.",
                rojo,
                naranjoClaro
            )
        )
    }

    private fun mostrarEjercicios() {
        val layout = crearBase()

        layout.addView(chip("Entrenamiento", purpuraClaro, purpura))
        layout.addView(titulo("Ejercicios prácticos"))
        layout.addView(bajada("Elige una de las 6 modalidades de entrenamiento interactivo para perfeccionar tus habilidades operativas de control de sondaje."))

        val gridContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        fun crearDashboardWidget(
            tituloWidget: String,
            detalleWidget: String,
            colorAcento: Int,
            esAnchoCompleto: Boolean = false,
            accion: () -> Unit
        ): LinearLayout {
            val card = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(16), dp(16), dp(16), dp(16))
                background = fondoRedondeado(superficie, radio = 22)
                elevation = dp(3).toFloat()
                
                layoutParams = if (esAnchoCompleto) {
                    LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT
                    ).apply {
                        setMargins(0, 0, 0, dp(12))
                    }
                } else {
                    LinearLayout.LayoutParams(
                        0,
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        1f
                    )
                }
            }

            // Círculo de color
            val circulo = View(this).apply {
                background = fondoRedondeado(colorAcento, radio = 10)
                val params = LinearLayout.LayoutParams(dp(16), dp(16))
                params.setMargins(0, 0, 0, dp(10))
                layoutParams = params
            }
            card.addView(circulo)

            card.addView(
                TextView(this).apply {
                    text = tituloWidget
                    textSize = 17.5f
                    setTextColor(azulOscuro)
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                    setPadding(0, 0, 0, dp(4))
                }
            )

            card.addView(
                TextView(this).apply {
                    text = detalleWidget
                    textSize = 13f
                    setTextColor(grisTexto)
                    setLineSpacing(dp(2).toFloat(), 1.0f)
                }
            )

            aplicarInteraccion(card, accion)
            return card
        }

        // Fila 1: Ronda de 15 Ejercicios de Sondaje (Ancho completo)
        val widgetRonda = crearDashboardWidget(
            "1. Ronda de 15 Ejercicios",
            "Pon a prueba tus conocimientos con una ronda de 15 ejercicios interactivos al azar (contra, fondo, recuperación, regularización y perforado) con dificultad elegible.",
            azul,
            esAnchoCompleto = true
        ) {
            mostrarDificultadRonda15()
        }
        gridContainer.addView(widgetRonda)

        // Fila 2: Contra + Fondo (Grid 2 columnas)
        val fila2 = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(140)
            ).apply {
                setMargins(0, 0, 0, dp(12))
            }
        }

        val widgetContra = crearDashboardWidget(
            "2. Ejercicios Contra",
            "Cálculo de contra estimada con barras y fondo",
            purpura
        ) { mostrarEjerciciosContraAleatorios() }

        val widgetFondo = crearDashboardWidget(
            "3. Ejercicios Fondo",
            "Cálculo de fondo de pozo con problemas al azar",
            Color.rgb(0, 96, 100)
        ) { mostrarEjerciciosFondoAleatorios() }

        fila2.addView(widgetContra)
        fila2.addView(widgetFondo)
        (widgetContra.layoutParams as LinearLayout.LayoutParams).setMargins(0, 0, dp(12), 0)
        gridContainer.addView(fila2)

        // Fila 3: Recuperación + Regularización (Grid 2 columnas)
        val fila3 = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(140)
            ).apply {
                setMargins(0, 0, 0, dp(12))
            }
        }

        val widgetRec = crearDashboardWidget(
            "4. Ejercicios Recup.",
            "Cálculo de recuperación con decimales y casos reales",
            Color.rgb(124, 77, 255)
        ) { mostrarEjerciciosRecuperacionAleatorios() }

        val widgetReg = crearDashboardWidget(
            "5. Ejercicios Regulariz.",
            "Simulación de ubicación física de regularización",
            Color.rgb(216, 67, 21)
        ) { mostrarEjerciciosRegularizacionAleatorios() }

        fila3.addView(widgetRec)
        fila3.addView(widgetReg)
        (widgetRec.layoutParams as LinearLayout.LayoutParams).setMargins(0, 0, dp(12), 0)
        gridContainer.addView(fila3)

        // Fila 4: Perforado (Ancho completo para destacar la novedad)
        val fila4 = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(140)
            )
        }

        val widgetPerf = crearDashboardWidget(
            "6. Ejercicios Perforado",
            "Cálculo de metraje perforado a partir de contras o fondos de pozo al azar",
            verde
        ) { mostrarEjerciciosPerforadoAleatorios() }

        fila4.addView(widgetPerf)
        gridContainer.addView(fila4)

        layout.addView(gridContainer)
        layout.addView(espacio(16))
    }

    private fun mostrarEjercicioSecuencial() {
        if (ejerciciosActuales.isEmpty()) {
            ejerciciosActuales = ejercicios.shuffled().take(10)
        }

        val layout = crearBase()
        val ejercicio = ejerciciosActuales[ejercicioIndex]
        val botonesOpciones = mutableListOf<Button>()

        layout.addView(titulo("Ejercicios prácticos"))

        val progreso = TextView(this).apply {
            text = "Pregunta ${ejercicioIndex + 1} de ${ejerciciosActuales.size}"
            textSize = 14f
            setTextColor(grisSecundario)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setPadding(dp(4), dp(2), dp(4), dp(6))

            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, dp(2), 0, dp(4))
            }
        }

        val tarjetaPregunta = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(18), dp(18), dp(18), dp(18))
            background = fondoRedondeado(azulClaro, bordeSuave, 22)
            elevation = dp(2).toFloat()

            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, dp(4), 0, dp(12))
            }
        }

        val textoPregunta = TextView(this).apply {
            text = ejercicio.enunciado
            textSize = 18f
            setTextColor(azulOscuro)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setLineSpacing(dp(4).toFloat(), 1.0f)
        }

        tarjetaPregunta.addView(textoPregunta)
        layout.addView(progreso)
        layout.addView(tarjetaPregunta)

        val calcInline = crearCalculadoraBolsilloInline()
        lateinit var btnCalc: Button
        btnCalc = botonSecundario("🧮 Abrir Calculadora") {
            if (calcInline.visibility == View.VISIBLE) {
                calcInline.visibility = View.GONE
                btnCalc.text = "🧮 Abrir Calculadora"
            } else {
                calcInline.visibility = View.VISIBLE
                btnCalc.text = "🧮 Cerrar Calculadora"
            }
        }
        layout.addView(btnCalc)
        layout.addView(calcInline)

        val opcionesMezcladas = ejercicio.opciones.mapIndexed { indiceOriginal, texto ->
            indiceOriginal to texto
        }.shuffled()

        val retroCard = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(18), dp(16), dp(18), dp(16))
            background = fondoRedondeado(superficieSuave, bordeSuave, 22)
            visibility = View.GONE

            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, dp(10), 0, dp(12))
            }
        }

        val retroTitulo = TextView(this).apply {
            textSize = 18f
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setTextColor(azulOscuro)
            setPadding(0, 0, 0, dp(8))
        }

        val retroTexto = TextView(this).apply {
            textSize = 15f
            setTextColor(grisTexto)
            setLineSpacing(dp(4).toFloat(), 1.0f)
        }

        retroCard.addView(retroTitulo)
        retroCard.addView(retroTexto)

        val botonSiguiente = boton("Siguiente pregunta", azul) {
            if (ejercicioIndex < ejerciciosActuales.lastIndex) {
                ejercicioIndex++
                mostrarEjercicioSecuencial()
            } else {
                mostrarResultadoEjercicios()
            }
        }.apply {
            visibility = View.GONE
        }

        opcionesMezcladas.forEachIndexed { index, opcionMezclada ->
            val letra = ('a'.code + index).toChar()
            val botonOpcion = boton("$letra. ${opcionMezclada.second}", azul) {
                val correcto = opcionMezclada.first == ejercicio.correcta

                botonesOpciones.forEachIndexed { indiceBoton, boton ->
                    boton.isEnabled = false
                    val esCorrectoBoton = opcionesMezcladas[indiceBoton].first == ejercicio.correcta
                    val colorBoton = if (indiceBoton == index) {
                        if (correcto) verde else rojo
                    } else if (esCorrectoBoton) {
                        verde
                    } else {
                        azul
                    }
                    boton.background = fondoRedondeado(colorBoton, radio = 20)
                    boton.alpha = if (indiceBoton == index || esCorrectoBoton) 1f else 0.5f

                    // Ajustar color del texto de acuerdo a la luminancia
                    val red = Color.red(colorBoton)
                    val green = Color.green(colorBoton)
                    val blue = Color.blue(colorBoton)
                    val luminancia = 0.299 * red + 0.587 * green + 0.114 * blue
                    if (luminancia > 180.0) {
                        boton.setTextColor(Color.rgb(15, 23, 42))
                    } else {
                        boton.setTextColor(Color.WHITE)
                    }
                }

                retroTitulo.text = if (correcto) "Respuesta correcta" else "Revisar respuesta"
                retroTitulo.setTextColor(if (correcto) verde else rojo)
                retroTexto.text = if (correcto) {
                    "¡Excelente! Tu respuesta es correcta.\n\nJustificación: ${ejercicio.retroalimentacion}"
                } else {
                    "Tu respuesta seleccionada fue: ${opcionMezclada.second}\n\nRespuesta correcta: ${ejercicio.opciones[ejercicio.correcta]}\n\nJustificación: ${ejercicio.retroalimentacion}"
                }
                retroCard.background = fondoRedondeado(
                    if (correcto) verdeClaro else naranjoClaro,
                    bordeSuave,
                    22
                )
                retroCard.visibility = View.VISIBLE
                botonSiguiente.text = if (ejercicioIndex < ejerciciosActuales.lastIndex) {
                    "Siguiente pregunta"
                } else {
                    "Finalizar práctica"
                }
                botonSiguiente.visibility = View.VISIBLE
            }

            botonesOpciones += botonOpcion
            layout.addView(botonOpcion)
        }

        layout.addView(retroCard)
        layout.addView(botonSiguiente)
    }

    private fun mostrarResultadoEjercicios() {
        val layout = crearBase()

        layout.addView(titulo("Práctica completada"))
        layout.addView(
            tarjeta(
                "¡Buen trabajo!",
                "Terminaste exitosamente la ronda de 15 ejercicios dinámicos de sondaje diamantino.\n\n" +
                        "Si vuelves a jugar, la app volverá a generar problemas completamente nuevos con datos reales de terreno.",
                verde,
                if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(232, 245, 233)
            )
        )

        layout.addView(boton("Volver a Ejercicios", verde) { mostrarEjercicios() })
    }

    private fun mostrarEjercicioActual() {
        val layout = crearBase()

        layout.addView(titulo("Ejercicios prácticos"))

        layout.addView(
            tarjeta(
                "Banco de ejercicios",
                "Resuelve situaciones de recuperación, regularización, seguridad, reportabilidad, bandejas y control operacional. Total: ${ejercicios.size} ejercicios.",
                azul,
                azulClaro
            )
        )

        ejercicios.forEach { ejercicio ->
            agregarEjercicio(layout, ejercicio)
        }
    }

    private fun agregarEjercicio(layout: LinearLayout, ejercicio: EjercicioPractico) {
        val card = LinearLayout(this)
        card.orientation = LinearLayout.VERTICAL
        card.setPadding(dp(16), dp(14), dp(16), dp(14))
        card.background = fondoRedondeado(Color.WHITE, Color.rgb(220, 226, 235))

        val params = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
        params.setMargins(0, dp(8), 0, dp(12))
        card.layoutParams = params

        card.addView(subtitulo(ejercicio.titulo, azul))
        card.addView(parrafo(ejercicio.enunciado))

        ejercicio.opciones.forEachIndexed { index, opcion ->
            val botonOpcion = boton(opcion, azul) {
                val correcto = index == ejercicio.correcta
                val tituloDialogo = if (correcto) "Correcto" else "Revisar"
                val mensaje = if (correcto) {
                    ejercicio.retroalimentacion
                } else {
                    "La respuesta correcta era: ${ejercicio.opciones[ejercicio.correcta]}\n\n${ejercicio.retroalimentacion}"
                }
                mostrarDialogo(tituloDialogo, mensaje)
            }
            card.addView(
                botonOpcion
            )
        }

        layout.addView(card)
    }

    private fun iniciarQuiz() {
        quizIndex = 0
        quizScore = 0
        preguntasQuizActuales = bancoPreguntasQuiz.shuffled().take(15)
        mostrarPreguntaQuiz()
    }

    private fun mostrarPreguntaQuiz() {
        if (preguntasQuizActuales.isEmpty()) {
            preguntasQuizActuales = bancoPreguntasQuiz.shuffled().take(15)
        }

        val layout = crearBase()
        val pregunta = preguntasQuizActuales[quizIndex]
        val botonesOpciones = mutableListOf<Button>()

        layout.addView(titulo("Quiz con puntaje"))

        layout.addView(
            tarjeta(
                "Pregunta ${quizIndex + 1} de ${preguntasQuizActuales.size}",
                pregunta.enunciado,
                azul,
                azulClaro
            )
        )

        val retroCard = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(18), dp(16), dp(18), dp(16))
            background = fondoRedondeado(superficieSuave, bordeSuave, 22)
            visibility = View.GONE

            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, dp(10), 0, dp(12))
            }
        }

        val retroTitulo = TextView(this).apply {
            textSize = 18f
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setTextColor(azulOscuro)
            setPadding(0, 0, 0, dp(8))
        }

        val retroTexto = TextView(this).apply {
            textSize = 15f
            setTextColor(grisTexto)
            setLineSpacing(dp(4).toFloat(), 1.0f)
        }

        retroCard.addView(retroTitulo)
        retroCard.addView(retroTexto)

        val botonSiguiente = boton("Siguiente pregunta", azul) {
            if (quizIndex < preguntasQuizActuales.lastIndex) {
                quizIndex++
                mostrarPreguntaQuiz()
            } else {
                mostrarResultadoQuiz()
            }
        }.apply {
            visibility = View.GONE
        }

        pregunta.opciones.forEachIndexed { index, opcion ->
            val botonOpcion = boton(opcion, azul) {
                val correcto = index == pregunta.correcta
                if (correcto) {
                    quizScore++
                }

                botonesOpciones.forEachIndexed { indiceBoton, boton ->
                    boton.isEnabled = false
                    val esCorrectoBoton = indiceBoton == pregunta.correcta
                    val colorBoton = if (indiceBoton == index) {
                        if (correcto) verde else rojo
                    } else if (esCorrectoBoton) {
                        verde
                    } else {
                        azul
                    }
                    boton.background = fondoRedondeado(colorBoton, radio = 20)
                    boton.alpha = if (indiceBoton == index || esCorrectoBoton) 1f else 0.5f

                    // Ajustar color del texto de acuerdo a la luminancia
                    val red = Color.red(colorBoton)
                    val green = Color.green(colorBoton)
                    val blue = Color.blue(colorBoton)
                    val luminancia = 0.299 * red + 0.587 * green + 0.114 * blue
                    if (luminancia > 180.0) {
                        boton.setTextColor(Color.rgb(15, 23, 42))
                    } else {
                        boton.setTextColor(Color.WHITE)
                    }
                }

                retroTitulo.text = if (correcto) "Respuesta correcta" else "Revisar respuesta"
                retroTitulo.setTextColor(if (correcto) verde else rojo)
                retroTexto.text = if (correcto) {
                    "¡Excelente! Tu respuesta es correcta.\n\nJustificación: ${pregunta.retroalimentacion}"
                } else {
                    "Tu respuesta seleccionada fue: ${opcion}\n\nRespuesta correcta: ${pregunta.opciones[pregunta.correcta]}\n\nJustificación: ${pregunta.retroalimentacion}"
                }
                retroCard.background = fondoRedondeado(
                    if (correcto) verdeClaro else naranjoClaro,
                    bordeSuave,
                    22
                )
                retroCard.visibility = View.VISIBLE
                botonSiguiente.text = if (quizIndex < preguntasQuizActuales.lastIndex) {
                    "Siguiente pregunta"
                } else {
                    "Ver resultado"
                }
                botonSiguiente.visibility = View.VISIBLE
            }
            botonesOpciones += botonOpcion
            layout.addView(botonOpcion)
        }

        layout.addView(retroCard)
        layout.addView(botonSiguiente)
    }

    private fun mostrarResultadoQuiz() {
        val layout = crearBase()
        val total = preguntasQuizActuales.size
        val porcentaje = if (total > 0) (quizScore * 100 / total) else 0

        layout.addView(titulo("Resultado del quiz", "Prácticos"))

        val comentario = when {
            quizScore == total -> "Excelente. Dominas la base del control de sondaje."
            quizScore >= 12 -> "Muy buen avance. Puedes reforzar algunos detalles específicos."
            quizScore >= 9 -> "Buen avance. Conviene reforzar recuperación, regularización y reportabilidad."
            quizScore >= 6 -> "Vas avanzando, pero es recomendable repasar criterios de medición y seguridad."
            else -> "Conviene repasar el procedimiento antes de avanzar al simulador."
        }

        // Emoji y colores según rendimiento
        val emoji = when {
            quizScore == total -> "🏆"
            porcentaje >= 80 -> "⭐"
            porcentaje >= 60 -> "👍"
            porcentaje >= 40 -> "📖"
            else -> "💪"
        }
        val colorPuntaje = when {
            porcentaje >= 80 -> verde
            porcentaje >= 60 -> naranjo
            else -> rojo
        }

        // Tarjeta de puntaje grande con emoji
        val puntajeCard = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(24), dp(28), dp(24), dp(28))
            background = fondoGradiente(
                if (quizScore == total) Color.rgb(20, 83, 45) else superficie,
                if (quizScore == total) Color.rgb(46, 125, 96) else superficie,
                radio = 28
            )
            elevation = dp(4).toFloat()
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply { setMargins(0, dp(8), 0, dp(16)) }
        }

        puntajeCard.addView(
            TextView(this).apply {
                text = emoji
                textSize = 52f
                gravity = Gravity.CENTER
                setPadding(0, 0, 0, dp(8))
            }
        )

        puntajeCard.addView(
            TextView(this).apply {
                text = "$quizScore / $total"
                textSize = 38f
                setTextColor(if (quizScore == total) Color.WHITE else colorPuntaje)
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                gravity = Gravity.CENTER
            }
        )

        puntajeCard.addView(
            TextView(this).apply {
                text = "$porcentaje% de aciertos"
                textSize = 16f
                setTextColor(if (quizScore == total) Color.argb(220, 255, 255, 255) else grisSecundario)
                gravity = Gravity.CENTER
                setPadding(0, dp(4), 0, dp(8))
            }
        )

        puntajeCard.addView(
            TextView(this).apply {
                text = comentario
                textSize = 15f
                setTextColor(if (quizScore == total) Color.argb(240, 255, 255, 255) else grisTexto)
                gravity = Gravity.CENTER
                setLineSpacing(dp(3).toFloat(), 1.0f)
            }
        )

        layout.addView(puntajeCard)

        layout.addView(boton("Reintentar quiz", verde) { iniciarQuiz() })
    }

    private fun mostrarGlosario() {
        val layout = crearBase()

        layout.addView(titulo("Glosario básico", "Teóricos"))

        val conceptos = listOf(
            "Sondaje diamantino DDH" to "Perforación que permite obtener una muestra cilíndrica de roca o grava llamada testigo.",
            "Testigo" to "Muestra cilíndrica de material rocoso usada para obtener información geológica, geotécnica o geometalúrgica.",
            "Eje del testigo" to "Línea imaginaria correspondiente al eje central longitudinal de la muestra cilíndrica.",
            "Bandeja porta testigo" to "Bandeja donde se ordenan y almacenan las muestras recuperadas durante la perforación.",
            "Taco de bloqueo" to "Separador que identifica una corrida o tramo perforado.",
            "Taco de regularizado" to "Marca física usada para dividir el sondaje en soportes de distancia definidos.",
            "Recuperación" to "Porcentaje entre muestra recuperada y muestra perforada.",
            "Regularización" to "Proceso de marcar metrajes de referencia en el testigo.",
            "Tricono" to "Herramienta de perforación usada para rotación y empuje en terreno.",
            "Corona" to "Herramienta de perforación con insertos diamantados o de carburo, usada según dureza de roca y objetivo.",
            "Wire line" to "Cable acerado que permite extraer el tubo interior desde la columna de barras.",
            "Pescante" to "Herramienta que permite enganchar y extraer el tubo interior porta testigo.",
            "Casing" to "Tubería utilizada para estabilizar o proteger el pozo durante la perforación.",
            "Laina" to "Pieza utilizada en el tubo interior durante la extracción de muestra.",
            "Plataforma de trabajo" to "Lugar físico donde se posiciona la máquina sondeadora para realizar la perforación.",
            "Empate" to "Operación de inicio de la perforación del sondaje en el punto especificado.",
            "Contra" to "Resto de barra o barra sobrante informado por el perforista. Permite verificar la coherencia entre la cantidad de barras utilizadas, el largo de barra, el largo de herramienta, el punto muerto y el fondo del pozo. Debe ser consultada al perforista y registrada por el controlador en el reporte o cuaderno de la sonda, de todos modos puede ser calculada para corroborar."
        )

        conceptos.sortedBy { normalizarTexto(it.first) }.forEach { concepto ->
            layout.addView(tarjeta(concepto.first, concepto.second, azul, superficie))
        }
    }

    // ── Helpers para mapas conceptuales con nodos visuales ──

    /**
     * Crea un nodo visual (caja redondeada) para un mapa conceptual.
     */
    private fun nodoMapa(texto: String, colorAccento: Int, colorFondo: Int): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(14), dp(12), dp(14), dp(12))
            background = fondoRedondeado(colorFondo, colorAccento, 14)
            elevation = dp(1).toFloat()

            val indicador = View(this@MainActivity).apply {
                background = fondoRedondeado(colorAccento, radio = 5)
                val p = LinearLayout.LayoutParams(dp(6), dp(6))
                p.setMargins(0, 0, dp(12), 0)
                layoutParams = p
            }
            addView(indicador)

            val tv = TextView(this@MainActivity).apply {
                this.text = texto
                textSize = 14.5f
                setTextColor(azulOscuro)
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            }
            addView(tv)

            val lp = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            layoutParams = lp
        }
    }

    /**
     * Crea un conector visual (flecha ↓ o símbolo +) entre nodos.
     * tipo: "flecha" para secuencial (↓), "suma" para aditivo (+)
     */
    private fun conectorFlecha(colorLinea: Int, tipo: String = "flecha"): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(0, dp(2), 0, dp(2))

            val lp = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            layoutParams = lp

            // Línea vertical superior
            val lineaArriba = View(this@MainActivity).apply {
                background = fondoRedondeado(colorLinea, radio = 2)
                val p = LinearLayout.LayoutParams(dp(2), dp(10))
                p.gravity = Gravity.CENTER_HORIZONTAL
                layoutParams = p
            }
            addView(lineaArriba)

            // Símbolo central
            val simbolo = TextView(this@MainActivity).apply {
                text = if (tipo == "suma") "＋" else "▼"
                textSize = if (tipo == "suma") 13f else 10f
                setTextColor(colorLinea)
                gravity = Gravity.CENTER
                setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            }
            addView(simbolo)

            // Línea vertical inferior
            val lineaAbajo = View(this@MainActivity).apply {
                background = fondoRedondeado(colorLinea, radio = 2)
                val p = LinearLayout.LayoutParams(dp(2), dp(10))
                p.gravity = Gravity.CENTER_HORIZONTAL
                layoutParams = p
            }
            addView(lineaAbajo)
        }
    }

    /**
     * Crea un mapa conceptual completo: tarjeta contenedora con título,
     * seguida de nodos y conectores intercalados.
     * pasos = lista de pares: ("texto del nodo", "flecha" | "suma")
     * El segundo valor indica el tipo de conector ANTES de ese nodo.
     * El primer nodo no tiene conector previo, así que su tipo se ignora.
     */
    private fun mapaConceptual(
        tituloMapa: String,
        pasos: List<Pair<String, String>>,
        colorAccento: Int,
        colorFondoNodo: Int,
        colorFondoCard: Int
    ): LinearLayout {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(18), dp(16), dp(18), dp(18))
            background = fondoRedondeado(colorFondoCard, bordeSuave, 22)
            elevation = dp(2).toFloat()

            val lp = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            lp.setMargins(0, dp(6), 0, dp(14))
            layoutParams = lp
        }

        // Título del mapa
        val tvTitulo = TextView(this).apply {
            text = tituloMapa
            textSize = 18.5f
            setTextColor(colorAccento)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setPadding(0, 0, 0, dp(14))
        }
        card.addView(tvTitulo)

        // Nodos y conectores
        pasos.forEachIndexed { index, (texto, tipo) ->
            if (index > 0) {
                card.addView(conectorFlecha(colorAccento, tipo))
            }
            card.addView(nodoMapa(texto, colorAccento, colorFondoNodo))
        }

        return card
    }

    private fun mostrarMapas() {
        val layout = crearBase()

        layout.addView(titulo("Mapas conceptuales", "Teóricos"))

        // Mapa 1: Control operacional
        layout.addView(
            mapaConceptual(
                "Mapa 1: Control operacional",
                listOf(
                    "Preparación del trabajo" to "flecha",
                    "Segregación y seguridad" to "flecha",
                    "Recepción del testigo" to "flecha",
                    "Traspaso a bandeja" to "flecha",
                    "Medición de recuperación" to "flecha",
                    "Regularización" to "flecha",
                    "Rotulación" to "flecha",
                    "Reportabilidad" to "flecha"
                ),
                azul, azulClaro, superficie
            )
        )

        // Mapa 2: Recuperación
        layout.addView(
            mapaConceptual(
                "Mapa 2: Recuperación",
                listOf(
                    "Muestra perforada" to "suma",
                    "Muestra recuperada" to "suma",
                    "Cálculo de recuperación (%)" to "flecha",
                    "Interpretación" to "flecha",
                    "Registro en reporte" to "flecha"
                ),
                verde, verdeClaro, superficie
            )
        )

        // Mapa 3: Regularización
        layout.addView(
            mapaConceptual(
                "Mapa 3: Regularización",
                listOf(
                    "Taco inicial" to "suma",
                    "Taco final" to "suma",
                    "Recuperación del tramo" to "suma",
                    "Cálculo o criterio geológico" to "flecha",
                    "Ubicación del taco de regularizado" to "flecha",
                    "Registro del ajuste" to "flecha"
                ),
                naranjo, naranjoClaro, superficie
            )
        )

        // Mapa 4: Seguridad
        layout.addView(
            mapaConceptual(
                "Mapa 4: Seguridad",
                listOf(
                    "EPP" to "suma",
                    "Segregación" to "suma",
                    "Control de acceso" to "suma",
                    "Comunicación" to "suma",
                    "Trabajo seguro en plataforma" to "flecha"
                ),
                rojo, rojoClaro, superficie
            )
        )
    }

    private fun mostrarHacerCuaderno() {
        val layout = crearBase()

        layout.addView(chip("Guía técnica", azulClaro, azul))
        layout.addView(titulo("Hacer cuaderno"))
        layout.addView(bajada("Guía paso a paso para recrear un formulario de control de perforación en un cuaderno de papel normal de forma profesional."))

        layout.addView(tarjeta(
            "Introducción",
            "¡Hola! En esta guía aprenderás paso a paso cómo pasar el formato técnico de control de perforación a tu cuaderno de papel para poder registrar todos los datos a mano de forma limpia, ordenada y sumamente clara en terreno. ¡Comencemos!",
            azul, azulClaro
        ))

        layout.addView(subtitulo("Paso 1: Preparación"))
        layout.addView(parrafo("Para comenzar, necesitarás tener a mano:\n• Tu cuaderno de notas (es ideal que sea de cuadrícula o líneas para facilitar el trazo).\n• Un lápiz de mina o bolígrafo (pasta).\n• Una regla.\n\nTe sugerimos usar una página completamente limpia y nueva para que tengas suficiente espacio de trabajo."))

        layout.addView(subtitulo("Paso 2: La Cabecera"))
        layout.addView(parrafo("En la primera o dos primeras líneas superiores de la página, escribe los campos básicos de identificación de forma horizontal:\n\nNombre controlador: __________________\nFecha: __________   Turno: __________\n\nDeja un espacio prudente después de cada etiqueta para poder escribir la información de turno con holgura."))

        layout.addView(subtitulo("Paso 3: Las Columnas de Especificaciones"))
        layout.addView(parrafo("Debajo de la cabecera, deja un pequeño espacio vertical para separar el contenido y divide visualmente la página en dos columnas de texto alineadas. Esto te permitirá agrupar las especificaciones técnicas ordenadamente:"))

        val filaColumnas = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        val colIzq = tarjeta(
            "Columna Izquierda",
            "• Sonda:\n• Pozo:\n• Recomendación:\n• Azimuth:\n• Inclinación:\n• L. Herramienta:\n• Punto muerto:",
            azul, superficie
        ).apply {
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                setMargins(0, 0, dp(10), 0)
            }
        }

        val colDer = tarjeta(
            "Columna Derecha",
            "• Corona:\n• Escariador:\n• Corona zapata HWT:\n• Casing HWT:\n• Largo programado:\n• Sector:",
            verde, superficie
        ).apply {
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        }

        filaColumnas.addView(colIzq)
        filaColumnas.addView(colDer)
        layout.addView(filaColumnas)

        layout.addView(subtitulo("Paso 4: Títulos y Enunciados de la Tabla"))
        layout.addView(parrafo("Esta es la sección crucial de tu cuaderno, donde se asentará toda la información dura del turno. Enfócate en colocar únicamente estos 9 enunciados en la fila de títulos de la tabla:"))

        layout.addView(tarjeta(
            "Enunciados Oficiales de la Tabla",
            "1. Desde: Metraje inicial de la corrida.\n" +
            "2. Hasta: Metraje final de la corrida.\n" +
            "3. Perforado (Perf.): Largo total perforado (Hasta - Desde).\n" +
            "4. Recuperado (Rec.): Largo del testigo físico recuperado.\n" +
            "5. % Recuperación (% Rec.): Eficiencia de recuperación del testigo.\n" +
            "6. Número de barras (Barras): Cantidad de barras bajadas al pozo.\n" +
            "7. Herramienta (Herr.): Largo físico de la herramienta de perforación.\n" +
            "8. Contra: Barra sobrante informada por el perforista.\n" +
            "9. Orientado (Orient.): Indicación de si el testigo fue orientado (Sí/No).",
            purpura, superficie
        ))

        layout.addView(subtitulo("Vista de Hoja de Cuaderno Simulada"))
        layout.addView(parrafo("Desliza horizontalmente la tabla para ver el ejemplo completo de cómo lucirá tu hoja de cuaderno real con los datos del pozo y las corridas anotadas:"))

        // ====================================================================
        // MOCKUP REALISTA DE LA HOJA DE CUADERNO (CREAMY LINED PAPER STYLE)
        // ====================================================================
        val cuadernoMock = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(dp(14), dp(16), dp(14), dp(16))
            background = fondoRedondeado(
                Color.rgb(255, 255, 248), // Papel crema suave y premium
                Color.rgb(212, 163, 89),  // Borde color marrón/cuero del cuaderno
                radio = 16
            )
            elevation = dp(4).toFloat()
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, dp(8), 0, dp(16))
            }
        }

        // Línea roja vertical del margen izquierdo del cuaderno
        val lineaRojaMargen = View(this).apply {
            background = fondoRedondeado(Color.rgb(239, 68, 68), radio = 0) // Rojo vivo de margen
            layoutParams = LinearLayout.LayoutParams(dp(2), ViewGroup.LayoutParams.MATCH_PARENT).apply {
                setMargins(0, 0, dp(12), 0)
            }
        }
        cuadernoMock.addView(lineaRojaMargen)

        val contenidoCuaderno = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        }

        // Título imitación manuscrito en tinta azul
        contenidoCuaderno.addView(TextView(this).apply {
            text = "📖 CONTROL DE PERFORACIÓN"
            textSize = 14.5f
            setTextColor(Color.rgb(28, 49, 116)) // Azul tinta clásica
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setPadding(0, 0, 0, dp(6))
        })

        // Fila de cabecera en tinta azul
        contenidoCuaderno.addView(TextView(this).apply {
            text = "Controlador: J. Pérez    Fecha: 18/05/2026    Turno: Día"
            textSize = 11.5f
            setTextColor(Color.rgb(40, 70, 140))
            setTypeface(Typeface.DEFAULT, Typeface.ITALIC)
            setPadding(0, 0, 0, dp(10))
        })

        // Especificaciones del Pozo del cuaderno en tinta azul/gris
        val specsLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, dp(12))
            }
        }

        val colIzqMock = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        }
        colIzqMock.addView(TextView(this).apply {
            text = "• Sonda: LX-14\n• Pozo: DDH-240\n• Recom: Perforar suave\n• Azimuth: 180°\n• Inclinación: -60°\n• L. Herramienta: 1.50 m\n• Punto muerto: 0.80 m"
            textSize = 10.5f
            setTextColor(Color.rgb(30, 41, 59))
            setLineSpacing(dp(2).toFloat(), 1.0f)
        })

        val colDerMock = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        }
        colDerMock.addView(TextView(this).apply {
            text = "• Corona: Diamantada #9\n• Escariador: Standard\n• Corona zapata: HWT\n• Casing: HWT 12 m\n• Largo prog: 350 m\n• Sector: Norte"
            textSize = 10.5f
            setTextColor(Color.rgb(30, 41, 59))
            setLineSpacing(dp(2).toFloat(), 1.0f)
        })

        specsLayout.addView(colIzqMock)
        specsLayout.addView(colDerMock)
        contenidoCuaderno.addView(specsLayout)

        // Separador horizontal manuscrito
        contenidoCuaderno.addView(View(this).apply {
            background = fondoRedondeado(Color.rgb(148, 163, 184), radio = 0)
            layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(1)).apply {
                setMargins(0, 0, 0, dp(10))
            }
        })

        // Tabla horizontalmente scrollable
        val tablaHorizontalScroll = HorizontalScrollView(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            isHorizontalScrollBarEnabled = true
        }

        val tablaLayout = TableLayout(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        // Helper para las celdas del mockup del cuaderno
        fun crearCeldaMock(texto: String, esEncabezado: Boolean = false, anchoDp: Int = 70): TextView {
            return TextView(this).apply {
                text = texto
                textSize = if (esEncabezado) 11f else 10.5f
                setTextColor(if (esEncabezado) Color.rgb(28, 49, 116) else Color.rgb(15, 23, 42))
                setTypeface(Typeface.DEFAULT, if (esEncabezado) Typeface.BOLD else Typeface.NORMAL)
                gravity = Gravity.CENTER
                setPadding(dp(6), dp(6), dp(6), dp(6))
                width = dp(anchoDp)
                background = GradientDrawable().apply {
                    setColor(if (esEncabezado) Color.rgb(240, 244, 252) else Color.TRANSPARENT)
                    setStroke(dp(1), Color.rgb(180, 190, 205)) // Líneas de cuadrícula azulinas claras
                }
            }
        }

        // Títulos de la tabla
        val cabeceraFila = TableRow(this).apply {
            addView(crearCeldaMock("Desde", true, 55))
            addView(crearCeldaMock("Hasta", true, 55))
            addView(crearCeldaMock("Perf.", true, 55))
            addView(crearCeldaMock("Rec.", true, 55))
            addView(crearCeldaMock("% Rec.", true, 60))
            addView(crearCeldaMock("Barras", true, 60))
            addView(crearCeldaMock("Herr.", true, 55))
            addView(crearCeldaMock("Contra", true, 55))
            addView(crearCeldaMock("Orient.", true, 60))
        }
        tablaLayout.addView(cabeceraFila)

        // Fila de corrida 1
        val filaDatos1 = TableRow(this).apply {
            addView(crearCeldaMock("236.30", false, 55))
            addView(crearCeldaMock("237.80", false, 55))
            addView(crearCeldaMock("1.50", false, 55))
            addView(crearCeldaMock("1.30", false, 55))
            addView(crearCeldaMock("86.7%", false, 60))
            addView(crearCeldaMock("79", false, 60))
            addView(crearCeldaMock("1.50", false, 55))
            addView(crearCeldaMock("0.50", false, 55))
            addView(crearCeldaMock("Sí (✓)", false, 60))
        }
        tablaLayout.addView(filaDatos1)

        // Fila de corrida 2
        val filaDatos2 = TableRow(this).apply {
            addView(crearCeldaMock("237.80", false, 55))
            addView(crearCeldaMock("239.30", false, 55))
            addView(crearCeldaMock("1.50", false, 55))
            addView(crearCeldaMock("1.50", false, 55))
            addView(crearCeldaMock("100%", false, 60))
            addView(crearCeldaMock("80", false, 60))
            addView(crearCeldaMock("1.50", false, 55))
            addView(crearCeldaMock("0.50", false, 55))
            addView(crearCeldaMock("Sí (✓)", false, 60))
        }
        tablaLayout.addView(filaDatos2)

        // Fila vacía para simular el resto de la hoja
        val filaVacia = TableRow(this).apply {
            addView(crearCeldaMock("", false, 55))
            addView(crearCeldaMock("", false, 55))
            addView(crearCeldaMock("", false, 55))
            addView(crearCeldaMock("", false, 55))
            addView(crearCeldaMock("", false, 60))
            addView(crearCeldaMock("", false, 60))
            addView(crearCeldaMock("", false, 55))
            addView(crearCeldaMock("", false, 55))
            addView(crearCeldaMock("", false, 60))
        }
        tablaLayout.addView(filaVacia)

        tablaHorizontalScroll.addView(tablaLayout)
        contenidoCuaderno.addView(tablaHorizontalScroll)
        cuadernoMock.addView(contenidoCuaderno)

        layout.addView(cuadernoMock)


    }

    // =========================================================================
    // MODULO CAMARA DE FOTOS CON AYUDA MEMORIA (CAMERA INSPECCION)
    // =========================================================================
    
    // Lista ayuda memoria editable en el código
    private val listaAyudaMemoria = listOf(
        "Nombre del pozo",
        "Inicio y fin del metraje en la bandeja",
        "Tacos de bloqueo",
        "Tacos de regularizado",
        "Número de bandeja"
    )

    // Estado local de ítems chequeados
    private val checklistEstados = mutableMapOf<String, Boolean>()
    
    private var imageCapture: ImageCapture? = null

    private fun tienePermisoCamara(): Boolean {
        return checkSelfPermission(android.Manifest.permission.CAMERA) == android.content.pm.PackageManager.PERMISSION_GRANTED
    }

    private fun solicitarPermisoCamara() {
        requestPermissions(arrayOf(android.Manifest.permission.CAMERA), 1001)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1001) {
            if (grantResults.isNotEmpty() && grantResults[0] == android.content.pm.PackageManager.PERMISSION_GRANTED) {
                mostrarCamaraInspeccion()
            } else {
                Toast.makeText(this, "Permiso de cámara denegado. Se requiere para tomar fotos.", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun mostrarCamaraInspeccion() {
        // Restablecer el estado cada vez que se ingresa/sale de la sección de fotografía
        checklistEstados.clear()

        val layout = crearBase()

        // Listas para sincronizar e interactuar directamente en el overlay
        val textViewsCondiciones = ArrayList<TextView>()
        var actualizarBotonState: () -> Unit = {}

        val chipView = chip("Herramienta de Campo", azulClaro, azul)
        layout.addView(chipView)
        val tituloView = titulo("Fotografíar bandejas", "Prácticos")
        layout.addView(tituloView)
        val bajadaView = bajada("Toma fotografías de tus bandejas de testigos asegurándote de revisar cada punto clave de control en terreno.")
        layout.addView(bajadaView)

        if (!tienePermisoCamara()) {
            layout.addView(tarjeta(
                "Permiso Requerido",
                "Para poder utilizar la cámara de fotos integrada y visualizar la vista previa de inspección, se necesita que otorgues permiso de cámara a la aplicación.",
                rojo,
                rojoClaro
            ))
            layout.addView(boton("Otorgar permiso de cámara", rojo) {
                solicitarPermisoCamara()
            })
            return
        }

        // Vista previa de cámara (Viewfinder) de mayor tamaño con overlay translúcido del 50%
        val cardCamara = android.widget.FrameLayout(this).apply {
            background = fondoRedondeado(Color.BLACK, Color.rgb(212, 163, 89), radio = 16)
            setPadding(dp(4), dp(4), dp(4), dp(4))
            elevation = dp(6).toFloat()
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(550) // ¡Tamaño súper ampliado de 450dp a 550dp!
            ).apply {
                setMargins(0, dp(12), 0, dp(12))
            }
        }

        // Botón flotante para expandir a pantalla completa en la esquina inferior derecha
        val btnFullscreen = TextView(this).apply {
            text = "⛶"
            textSize = 20f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(dp(12), dp(12), dp(12), dp(12))
            // Fondo translúcido oscuro con borde sutil
            background = fondoRedondeado(Color.argb(165, 15, 23, 42), Color.argb(90, 255, 255, 255), radio = 50)
            elevation = dp(8).toFloat()
            
            layoutParams = android.widget.FrameLayout.LayoutParams(
                dp(48),
                dp(48)
            ).apply {
                gravity = Gravity.BOTTOM or Gravity.END
                setMargins(0, 0, dp(16), dp(16)) // Ubicación en la esquina inferior derecha
            }
        }

        var esPantallaCompleta = false
        aplicarInteraccion(btnFullscreen) {
            esPantallaCompleta = !esPantallaCompleta
            if (esPantallaCompleta) {
                // 1. Ocular los headers
                chipView.visibility = View.GONE
                tituloView.visibility = View.GONE
                bajadaView.visibility = View.GONE
                
                // Ocultar cabecera ☰ de crearBase si existe
                if (layout.childCount > 0) {
                    val primerHijo = layout.getChildAt(0)
                    if (primerHijo is LinearLayout) {
                        primerHijo.visibility = View.GONE
                    }
                }
                
                // 2. Quitar padding y márgenes de cardCamara
                layout.setPadding(0, 0, 0, 0)
                
                val paramsCard = cardCamara.layoutParams as LinearLayout.LayoutParams
                paramsCard.height = ViewGroup.LayoutParams.MATCH_PARENT
                paramsCard.setMargins(0, 0, 0, 0)
                cardCamara.layoutParams = paramsCard
                
                cardCamara.background = fondoRedondeado(Color.BLACK, Color.TRANSPARENT, radio = 0)
                
                btnFullscreen.text = "🗗"
                btnFullscreen.background = fondoRedondeado(Color.argb(210, 239, 68, 68), Color.TRANSPARENT, radio = 50)
            } else {
                // 1. Mostrar headers
                chipView.visibility = View.VISIBLE
                tituloView.visibility = View.VISIBLE
                bajadaView.visibility = View.VISIBLE
                
                if (layout.childCount > 0) {
                    val primerHijo = layout.getChildAt(0)
                    if (primerHijo is LinearLayout) {
                        primerHijo.visibility = View.VISIBLE
                    }
                }
                
                // 2. Restaurar padding y márgenes
                layout.setPadding(dp(18), dp(18), dp(18), dp(28))
                
                val paramsCard = cardCamara.layoutParams as LinearLayout.LayoutParams
                paramsCard.height = dp(550)
                paramsCard.setMargins(0, dp(12), 0, dp(12))
                cardCamara.layoutParams = paramsCard
                
                cardCamara.background = fondoRedondeado(Color.BLACK, Color.rgb(212, 163, 89), radio = 16)
                
                btnFullscreen.text = "⛶"
                btnFullscreen.background = fondoRedondeado(Color.argb(165, 15, 23, 42), Color.argb(90, 255, 255, 255), radio = 50)
            }
        }

        val previewView = PreviewView(this).apply {
            layoutParams = android.widget.FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }
        cardCamara.addView(previewView)

        // Overlay translúcido al 50% de opacidad que muestra las condiciones de desbloqueo
        val overlayCondiciones = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            // Color oscuro translúcido (~53% de opacidad)
            background = fondoRedondeado(Color.argb(135, 15, 23, 42), radio = 12)
            setPadding(dp(24), dp(24), dp(24), dp(24))
            layoutParams = android.widget.FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        val tvTituloOverlay = TextView(this).apply {
            text = "🔒 Requisitos de Captura"
            textSize = 17f
            setTextColor(Color.WHITE)
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(14))
        }
        overlayCondiciones.addView(tvTituloOverlay)

        val tvSubtituloOverlay = TextView(this).apply {
            text = "Marca los 5 puntos de la ayuda memoria para liberar el obturador:"
            textSize = 12.5f
            setTextColor(Color.argb(200, 241, 245, 249))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(16))
        }
        overlayCondiciones.addView(tvSubtituloOverlay)

        // Lista de textviews para actualizar dinámicamente las condiciones en el overlay
        listaAyudaMemoria.forEach { item ->
            val tv = TextView(this).apply {
                textSize = 14.5f
                setPadding(dp(16), dp(8), dp(16), dp(8))
                gravity = Gravity.CENTER
                setTextColor(Color.argb(180, 255, 255, 255))
                
                // Permitir presionar directamente sobre la cámara para validar los requisitos
                aplicarInteraccion(this) {
                    val nuevoEstado = !(checklistEstados[item] ?: false)
                    checklistEstados[item] = nuevoEstado
                    actualizarBotonState()
                }
            }
            textViewsCondiciones.add(tv)
        }
        textViewsCondiciones.forEach { overlayCondiciones.addView(it) }
        cardCamara.addView(overlayCondiciones)
        cardCamara.addView(btnFullscreen)

        // Botón Shutter / Obturador de captura de fotos flotante sobre el visor de la cámara
        val botonCapturar = TextView(this).apply {
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            gravity = Gravity.CENTER
            setPadding(dp(22), dp(12), dp(22), dp(12))
            
            layoutParams = android.widget.FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
                setMargins(0, 0, 0, dp(16)) // Flotando a 16dp de la parte inferior
            }
        }
        cardCamara.addView(botonCapturar)

        layout.addView(cardCamara)

        // Función lambda local para actualizar el estado del botón y del overlay sin recargar la pantalla
        actualizarBotonState = {
            val todosChequeados = listaAyudaMemoria.all { checklistEstados[it] == true }
            
            // Actualizar la lista en el overlay
            listaAyudaMemoria.forEachIndexed { index, item ->
                val completado = checklistEstados[item] == true
                val tv = textViewsCondiciones[index]
                if (completado) {
                    tv.text = "✓ $item"
                    tv.setTextColor(Color.rgb(110, 196, 162)) // Hermoso verde pastel
                    tv.setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                } else {
                    tv.text = "○ $item"
                    tv.setTextColor(Color.argb(180, 255, 255, 255)) // Translúcido
                    tv.setTypeface(Typeface.DEFAULT, Typeface.NORMAL)
                }
            }

            if (todosChequeados) {
                overlayCondiciones.animate()
                    .alpha(0f)
                    .setDuration(500)
                    .setInterpolator(android.view.animation.DecelerateInterpolator())
                    .withEndAction { overlayCondiciones.visibility = View.GONE }
                    .start()
                
                botonCapturar.text = "📷 CAPTURAR FOTO"
                botonCapturar.textSize = 14f
                botonCapturar.setTextColor(Color.WHITE)
                // Rojo vibrante premium con sombra elevada flotando sobre el visor de la cámara
                botonCapturar.background = fondoRedondeado(Color.rgb(239, 68, 68), Color.rgb(185, 28, 28), radio = 30)
                botonCapturar.elevation = dp(6).toFloat()
            } else {
                overlayCondiciones.visibility = View.VISIBLE
                overlayCondiciones.alpha = 1f // Reactivar la visibilidad si se desmarca alguna
                
                botonCapturar.text = "🔒 REQUISITOS PENDIENTES"
                botonCapturar.textSize = 12f
                botonCapturar.setTextColor(Color.argb(220, 241, 245, 249))
                // Efecto cristalino/glassmorphic oscuro para el estado bloqueado sobre la cámara
                botonCapturar.background = fondoRedondeado(Color.argb(165, 15, 23, 42), Color.argb(80, 255, 255, 255), radio = 30)
                botonCapturar.elevation = dp(2).toFloat()
            }
        }

        // Establecer el estado visual inicial
        actualizarBotonState()
        
        aplicarInteraccion(botonCapturar) {
            val todosChequeados = listaAyudaMemoria.all { checklistEstados[it] == true }
            if (todosChequeados) {
                capturarFotografia()
            } else {
                Toast.makeText(this@MainActivity, "Por favor verifica los 5 puntos de la ayuda memoria para habilitar la cámara.", Toast.LENGTH_SHORT).show()
            }
        }

        // Iniciar la cámara en segundo plano
        iniciarCamaraX(previewView)
    }

    private fun iniciarCamaraX(previewView: PreviewView) {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
        cameraProviderFuture.addListener({
            try {
                val cameraProvider = cameraProviderFuture.get()
                
                val preview = Preview.Builder().build().also {
                    it.setSurfaceProvider(previewView.surfaceProvider)
                }
                
                imageCapture = ImageCapture.Builder()
                    .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
                    .build()
                
                val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
                
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    this as LifecycleOwner,
                    cameraSelector,
                    preview,
                    imageCapture
                )
            } catch (exc: Exception) {
                Toast.makeText(this, "Error al abrir cámara: ${exc.message}", Toast.LENGTH_SHORT).show()
            }
        }, ContextCompat.getMainExecutor(this))
    }

    private fun capturarFotografia() {
        val imageCapture = imageCapture ?: return
        
        val nombreArchivo = "inspeccion_${System.currentTimeMillis()}.jpg"
        
        // Configurar valores para registrar la foto en la galería pública del sistema
        val contentValues = android.content.ContentValues().apply {
            put(android.provider.MediaStore.MediaColumns.DISPLAY_NAME, nombreArchivo)
            put(android.provider.MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                put(android.provider.MediaStore.MediaColumns.RELATIVE_PATH, android.os.Environment.DIRECTORY_PICTURES + "/AprenderInspecciones")
            }
        }
        
        val outputOptions = ImageCapture.OutputFileOptions.Builder(
            contentResolver,
            android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            contentValues
        ).build()
        
        // Efecto visual flash de pantalla simple al capturar
        val overlayFlash = View(this).apply {
            setBackgroundColor(Color.WHITE)
            alpha = 0.8f
        }
        val decorView = window.decorView as ViewGroup
        decorView.addView(overlayFlash, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        overlayFlash.animate().alpha(0f).setDuration(300).withEndAction {
            decorView.removeView(overlayFlash)
        }.start()

        imageCapture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(outputFileResults: ImageCapture.OutputFileResults) {
                    val savedUri = outputFileResults.savedUri
                    val msg = "¡Foto guardada con éxito en tu galería pública!\n\nPuedes encontrarla en tu Galería o Google Fotos bajo la carpeta:\n'Pictures/AprenderInspecciones'\n\nURI: ${savedUri}"
                    AlertDialog.Builder(this@MainActivity)
                        .setTitle("📸 Guardado en Galería")
                        .setMessage(msg)
                        .setPositiveButton("Excelente") { dialog, _ -> dialog.dismiss() }
                        .show()
                }

                override fun onError(exception: ImageCaptureException) {
                    Toast.makeText(this@MainActivity, "Error al guardar foto: ${exception.message}", Toast.LENGTH_SHORT).show()
                }
            }
        )
    }

    private fun mostrarCriteriosMedicion() {
        val layout = crearBase()

        layout.addView(titulo("Criterios de medición del testigo", "Teóricos"))

        layout.addView(tarjeta("❓ ¿Para qué sirve?", "Ayuda a estimar la recuperación según el estado físico del testigo: entero, fracturado o molido.", azul, azulClaro))
        layout.addView(tarjeta("✅ A. Muestra entera", "Cuando el testigo está completo y continuo, se considera como 100% recuperado. Solo se eliminan espacios reales entre fracturas.", verde, verdeClaro))
        layout.addView(tarjeta("🟡 B1. Fracturada casi completa", "Si los fragmentos están prácticamente unidos y aún se reconoce el cilindro, se puede considerar aproximadamente 90% a 95%.", naranjo, naranjoClaro))
        layout.addView(tarjeta("🟠 B2. Fracturada con muchos trozos", "Si los fragmentos son independientes, pero llenan gran parte de la canaleta, se aplica castigo mayor según ocupación.", purpura, purpuraClaro))
        layout.addView(tarjeta("🔴 B3. Baja ocupación", "Si los trozos ocupan aproximadamente la mitad de la canaleta, se castiga el largo medido en torno al 50%.", rojo, rojoClaro))
        layout.addView(tarjeta("⚫ C. Muestra molida fina", "Corresponde a roca molida, argilizada, arenosa o disgregada. Se mide según cuánto llena la canaleta.", azul, azulClaro))
        layout.addView(tarjeta("💡 Regla práctica", "Mientras más conserva el testigo su forma cilíndrica original, menor castigo. Mientras más molido, suelto o incompleto, mayor castigo.", verde, verdeClaro))
    }

    private fun mostrarSeguridadRiesgos() {
        val layout = crearBase()

        layout.addView(titulo("Seguridad y riesgos", "Teóricos"))

        layout.addView(tarjeta("⚠️ Principio general", "El controlador debe ejecutar la tarea sin exponerse a energías no controladas, manteniéndose en zona segregada y respetando controles definidos.", azul, azulClaro))
        layout.addView(tarjeta("🦺 EPP básico", "Casco con barbiquejo, lentes, guantes, zapatos de seguridad, protección auditiva, respiratoria, chaleco reflectante, bloqueador solar y ropa adecuada.", verde, verdeClaro))
        layout.addView(tarjeta("🚧 Segregación", "El área del controlador debe estar segregada respecto al equipo de perforación. No debe quedar acceso libre hacia el área del perforista.", naranjo, naranjoClaro))
        layout.addView(tarjeta("😷 Sílice", "En zonas de riesgo se debe utilizar protección respiratoria con filtros adecuados y realizar chequeo diario del equipo.", purpura, purpuraClaro))
        layout.addView(tarjeta("🔊 Ruido", "El uso de protección auditiva es obligatorio cuando exista exposición a ruido.", rojo, rojoClaro))
        layout.addView(tarjeta("☀️ Radiación UV", "Usar bloqueador solar, gorro legionario, hidratación y considerar el índice UV.", azul, azulClaro))
        layout.addView(tarjeta("🪨 Caída de rocas", "Mantener distancia de zonas de caída, respetar controles geotécnicos y reportar condiciones inseguras.", verde, verdeClaro))
        layout.addView(tarjeta("📦 Manipulación de bandejas", "Controlar sobreesfuerzos, cortes, golpes y trastornos musculoesqueléticos al mover o cerrar bandejas.", naranjo, naranjoClaro))
    }

    private fun mostrarReportabilidad() {
        val layout = crearBase()

        layout.addView(titulo("Reportabilidad", "Teóricos"))

        layout.addView(tarjeta("🎯 Objetivo", "La reportabilidad deja respaldo de la operación por turno, avances por máquina, mediciones y situaciones relevantes.", azul, azulClaro))
        layout.addView(tarjeta("📝 Datos mínimos", "Fecha, turno, controlador, sonda, pozo, número de bandeja, desde, hasta y observaciones generales.", verde, verdeClaro))
        layout.addView(tarjeta("⛏️ Datos de perforación", "Metraje inicial, metraje final, metros perforados, metros recuperados, porcentaje de recuperación, diámetro y largo de barras.", naranjo, naranjoClaro))
        layout.addView(tarjeta("🔩 Herramientas", "Registrar corona, escareador, zapata, largo de herramienta, casing instalado, aditivos y mediciones realizadas.", purpura, purpuraClaro))
        layout.addView(tarjeta("🚨 Situaciones operacionales", "Registrar incidentes, cambios de metodología, pérdida de herramientas, mala recuperación, exceso de agua o condiciones que afecten la calidad.", rojo, rojoClaro))
        layout.addView(tarjeta("🏁 Cierre de pozo", "Registrar cumplimiento de objetivos, profundidad alcanzada y cantidad de barras utilizadas.", azul, azulClaro))
    }

    private fun mostrarChecklistTurno() {
        val layout = crearBase()

        layout.addView(titulo("Paso a paso del turno", "Prácticos"))

        layout.addView(tarjeta("Uso de la guía", "Marca cada punto antes, durante y al finalizar el turno. Esta versión es de práctica; luego puede guardar avance.", azul, azulClaro))

        layout.addView(subtitulo("1. Antes de iniciar"))
        layout.addView(itemChecklist("1.1 Participé en charla de seguridad."))
        layout.addView(itemChecklist("1.2 Revisé EPP: casco, lentes, guantes, zapatos, auditivo y respirador si corresponde."))
        layout.addView(itemChecklist("1.3 Revisé herramientas: flexómetro, plumones, cuaderno, lápiz y materiales."))
        layout.addView(itemChecklist("1.4 Conozco datos del pozo: cota, azimut, inclinación y profundidad."))
        layout.addView(itemChecklist("1.5 Verifiqué segregación del área de trabajo."))

        layout.addView(subtitulo("2. Durante la operación"))
        layout.addView(itemChecklist("2.1 Me mantengo fuera del área de perforación."))
        layout.addView(itemChecklist("2.2 Hice el cuaderno, registrando diametro, herramienta, punto muerto, azimuth, inclinación, turno, fecha, etc."))
        layout.addView(itemChecklist("2.3 Mido muestra recuperada por tramo."))
        layout.addView(itemChecklist("2.4 Calculo recuperación correctamente."))
        layout.addView(itemChecklist("2.5 Registré metraje inicial y final."))
        layout.addView(itemChecklist("2.6 Reviso orden del testigo antes del traspaso a bandeja."))
        layout.addView(itemChecklist("2.7 Instalo tacos de bloqueo según corrida o tramo."))
        layout.addView(itemChecklist("2.8 Realizo regularizado cuando corresponde."))
        layout.addView(itemChecklist("2.9 Registro recuperación mayor o menor a 100%."))
        layout.addView(itemChecklist("2.10 Rotulé bandejas con datos legibles."))

        layout.addView(subtitulo("3. En caso de ser necesario"))
        layout.addView(itemChecklist("3.1 Informé condiciones subestándares al supervisor."))
        layout.addView(itemChecklist("3.2 Registro cambio de diámetro de las barras."))

        layout.addView(subtitulo("4. Al finalizar"))
        layout.addView(itemChecklist("4.1 Realicé el report físico."))
        layout.addView(itemChecklist("4.2 Realicé el report digital."))
        layout.addView(itemChecklist("4.3 Envié las fotos del Report a Base de Datos."))
        layout.addView(itemChecklist("4.4 Envié las fotos de las bandejas."))
        layout.addView(itemChecklist("4.5 Dejé el área limpia y ordenada."))

        layout.addView(espacio(16))
        layout.addView(boton("Turno Finalizado", verde) {
            val prefs = getSharedPreferences("checklist_prefs", MODE_PRIVATE)
            prefs.edit().clear().apply()
            mostrarChecklistTurno()
            Toast.makeText(this, "Turno finalizado. Paso a paso restablecido.", Toast.LENGTH_SHORT).show()
        })
    }

    private fun itemChecklist(texto: String): Button {
        val prefs = getSharedPreferences("checklist_prefs", MODE_PRIVATE)
        var marcado = prefs.getBoolean(texto, false)

        return Button(this).apply {
            this.text = if (marcado) "☑ $texto" else "☐ $texto"
            textSize = 14f
            setTextColor(if (marcado) verde else azul)
            setAllCaps(false)
            gravity = Gravity.START or Gravity.CENTER_VERTICAL
            background = fondoRedondeado(superficie, bordeSuave)
            setPadding(dp(14), dp(10), dp(14), dp(10))

            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, dp(4), 0, dp(4))
            layoutParams = params

            setOnClickListener {
                marcado = !marcado
                prefs.edit().putBoolean(texto, marcado).apply()
                this.text = if (marcado) "☑ $texto" else "☐ $texto"
                setTextColor(if (marcado) verde else azul)
            }
        }
    }

    private fun mostrarRotulacionBandejas() {
        val layout = crearBase()

        layout.addView(titulo("Rotulación de bandejas", "Teóricos"))

        layout.addView(tarjeta("🎯 Objetivo", "La rotulación asegura trazabilidad del testigo y evita confusiones entre pozos, bandejas y tramos.", azul, azulClaro))
        layout.addView(tarjeta("📌 Datos principales", "La bandeja debe registrar número de pozo, desde, hasta y número de bandeja.", verde, verdeClaro))
        layout.addView(tarjeta("🗺️ Ubicación de datos", "La información debe ubicarse de forma ordenada y legible, respetando el sentido de avance del testigo.", naranjo, naranjoClaro))
        layout.addView(tarjeta("✍️ Letra legible", "Todo registro debe ser claro, limpio y entendible para el supervisor, geólogo o persona que revise posteriormente.", purpura, purpuraClaro))
        layout.addView(tarjeta("✅ Antes de cerrar", "Antes de tapar y apilar la bandeja, se debe chequear nuevamente que los datos coincidan con el reporte.", rojo, rojoClaro))
    }

    private fun mostrarTriconoDiametro() {
        val layout = crearBase()

        layout.addView(titulo("Tricono y cambio de diámetro", "Teóricos"))

        layout.addView(tarjeta("⛏️ Perforación con tricono", "En algunos casos el pozo inicia con tricono y no existe recuperación de muestra. Este tramo debe quedar registrado.", azul, azulClaro))
        layout.addView(tarjeta("📏 Registro del tramo", "Se debe indicar metraje inicial y final del tramo perforado con tricono y dejar taco o registro correspondiente.", verde, verdeClaro))
        layout.addView(tarjeta("🔄 Reducción de diámetro", "Cuando se cambia el diámetro, el controlador debe registrarlo y cambiar el tipo de bandeja si corresponde.", naranjo, naranjoClaro))
        layout.addView(tarjeta("📍 Taco de cambio", "Debe ubicarse un taco que indique el cambio de diámetro en la nueva bandeja.", purpura, purpuraClaro))
        layout.addView(tarjeta("🔗 Trazabilidad", "Todo cambio operacional debe quedar claro para que la información del sondaje sea coherente y verificable.", rojo, rojoClaro))
    }

    private fun normalizarTexto(texto: String): String {
        return Normalizer.normalize(texto.lowercase(Locale.getDefault()), Normalizer.Form.NFD)
            .replace("\\p{Mn}+".toRegex(), "")
    }

    private fun formato(valor: Double): String {
        return String.format(Locale.US, "%.2f", valor)
    }

    private fun mostrarEjerciciosContraAleatorios() {
        val layout = crearBase()

        layout.addView(titulo("Ejercicios aleatorios de contra"))

        layout.addView(
            tarjeta(
                "¿Cómo funciona?",
                "La app genera problemas aleatorios operacionales para determinar la contra en terreno usando dos métodos:\n\n" +
                        "1. Método Físico:\n" +
                        "   Contra = (Cantidad de barras × Largo de barra) + Largo herramienta - Punto muerto - Fondo del pozo\n\n" +
                        "2. Método Operacional:\n" +
                        "   Contra Actual = Contra Anterior - Perforado",
                purpura,
                purpuraClaro
            )
        )

        layout.addView(boton("Nivel básico", verde) {
            mostrarProblemaContra(NivelContra.BASICO)
        })

        layout.addView(boton("Nivel medio", naranjo) {
            mostrarProblemaContra(NivelContra.MEDIO)
        })

        layout.addView(boton("Nivel avanzado", rojo) {
            mostrarProblemaContra(NivelContra.AVANZADO)
        })
    }

    private fun mostrarProblemaContra(nivel: NivelContra) {
        val problema = generarProblemaContra(nivel)
        val layout = crearBase()

        layout.addView(titulo("Problema de contra"))
        layout.addView(botonSecundario("Volver a niveles") { mostrarEjerciciosContraAleatorios() })

        val nombreNivel = when (nivel) {
            NivelContra.BASICO -> "Básico"
            NivelContra.MEDIO -> "Medio"
            NivelContra.AVANZADO -> "Avanzado"
        }

        val esMetodoNuevo = problema.metodoUsado == "anterior_perforado"

        val tarjetaCuerpo = if (esMetodoNuevo) {
            "Calcula la contra actual con los siguientes datos operacionales:\n\n" +
                    "• Contra anterior: ${formato(problema.contraAnterior!!)} m\n" +
                    "• Metraje perforado: ${formato(problema.perforado!!)} m\n" +
                    "• Largo de barra del pozo: ${formato(problema.largoBarra!!)} m\n\n" +
                    "Fórmula básica:\n" +
                    "Contra actual = Contra anterior - Perforado\n" +
                    "⚠️ Regla de Terreno: Recuerda aplicar el ajuste de adición de barra si corresponde."
        } else {
            val profundidadCalculada =
                (problema.cantidadBarras!! * problema.largoBarra!!) +
                        problema.largoHerramienta!! -
                        problema.puntoMuerto!!
            "Calcula la contra estimada con los siguientes datos:\n\n" +
                    "Cantidad de barras: ${formato(problema.cantidadBarras!!)}\n" +
                    "Largo de barra: ${formato(problema.largoBarra!!)} m\n" +
                    "Largo herramienta: ${formato(problema.largoHerramienta!!)} m\n" +
                    "Punto muerto: ${formato(problema.puntoMuerto!!)} m\n" +
                    "Fondo del pozo: ${formato(problema.fondoPozo!!)} m\n\n" +
                    "Profundidad calculada:\n" +
                    "(${formato(problema.cantidadBarras!!)} × ${formato(problema.largoBarra!!)}) + ${formato(problema.largoHerramienta!!)} - ${formato(problema.puntoMuerto!!)} = ${formato(profundidadCalculada)} m"
        }

        layout.addView(
            tarjeta(
                "Nivel $nombreNivel",
                tarjetaCuerpo,
                purpura,
                purpuraClaro
            )
        )

        val calcInline = crearCalculadoraBolsilloInline()
        lateinit var btnCalc: Button
        btnCalc = botonSecundario("🧮 Abrir Calculadora") {
            if (calcInline.visibility == View.VISIBLE) {
                calcInline.visibility = View.GONE
                btnCalc.text = "🧮 Abrir Calculadora"
            } else {
                calcInline.visibility = View.VISIBLE
                btnCalc.text = "🧮 Cerrar Calculadora"
            }
        }
        layout.addView(btnCalc)
        layout.addView(calcInline)
        layout.addView(subtitulo("¿Cuál es la contra estimada?"))

        problema.opciones.forEachIndexed { index, opcion ->
            layout.addView(
                boton("${formato(opcion)} m", azul) {
                    val correcto = index == problema.respuestaCorrecta

                    val mensaje = if (esMetodoNuevo) {
                        val seAgregoBarra = problema.contraAnterior!! < problema.perforado!!
                        val contraAnteriorAjustada = if (seAgregoBarra) problema.contraAnterior!! + problema.largoBarra!! else problema.contraAnterior!!
                        val pasoAjuste = if (seAgregoBarra) {
                            "Como la contra anterior (${formato(problema.contraAnterior!!)} m) es menor al metraje perforado (${formato(problema.perforado!!)} m), significa operacionalmente que se agregó una barra nueva de ${formato(problema.largoBarra!!)} m.\n" +
                            "   • Contra Anterior Ajustada = ${formato(problema.contraAnterior!!)} m + ${formato(problema.largoBarra!!)} m = ${formato(contraAnteriorAjustada)} m\n\n"
                        } else {
                            ""
                        }
                        val formulaUsada = if (seAgregoBarra) {
                            "Contra actual = (Contra anterior + Largo barra) - Perforado"
                        } else {
                            "Contra actual = Contra anterior - Perforado"
                        }
                        val calculoDesarrollado = if (seAgregoBarra) {
                            "Contra actual = (${formato(problema.contraAnterior!!)} m + ${formato(problema.largoBarra!!)} m) - ${formato(problema.perforado!!)} m\n" +
                            "Contra actual = ${formato(contraAnteriorAjustada)} m - ${formato(problema.perforado!!)} m = ${formato(problema.contraCorrecta)} m"
                        } else {
                            "Contra actual = ${formato(problema.contraAnterior!!)} m - ${formato(problema.perforado!!)} m = ${formato(problema.contraCorrecta)} m"
                        }

                        if (correcto) {
                            "Correcto.\n\n" +
                                    pasoAjuste +
                                    "Fórmula:\n" +
                                    "   • $formulaUsada\n\n" +
                                    "Desarrollo:\n" +
                                    "   • $calculoDesarrollado\n\n" +
                                    problema.interpretacion
                        } else {
                            "Revisar.\n\n" +
                                    "La respuesta correcta era: ${formato(problema.contraCorrecta)} m\n\n" +
                                    pasoAjuste +
                                    "Fórmula:\n" +
                                    "   • $formulaUsada\n\n" +
                                    "Desarrollo:\n" +
                                    "   • $calculoDesarrollado\n\n" +
                                    problema.interpretacion
                        }
                    } else {
                        val profundidadCalculada =
                            (problema.cantidadBarras!! * problema.largoBarra!!) +
                                    problema.largoHerramienta!! -
                                    problema.puntoMuerto!!
                        if (correcto) {
                            "Correcto.\n\n" +
                                    "Contra = profundidad calculada - fondo del pozo\n" +
                                    "Contra = ${formato(profundidadCalculada)} - ${formato(problema.fondoPozo!!)}\n" +
                                    "Contra = ${formato(problema.contraCorrecta)} m\n\n" +
                                    problema.interpretacion
                        } else {
                            "Revisar.\n\n" +
                                    "La respuesta correcta era: ${formato(problema.contraCorrecta)} m\n\n" +
                                    "Contra = ${formato(profundidadCalculada)} - ${formato(problema.fondoPozo!!)}\n" +
                                    "Contra = ${formato(problema.contraCorrecta)} m\n\n" +
                                    problema.interpretacion
                        }
                    }

                    mostrarDialogo(
                        if (correcto) "Correcto" else "Respuesta incorrecta",
                        mensaje
                    )
                }
            )
        }

        layout.addView(
            boton("Generar otro problema del mismo nivel", naranjo) {
                mostrarProblemaContra(nivel)
            }
        )

        layout.addView(
            boton("Cambiar nivel", purpura) {
                mostrarEjerciciosContraAleatorios()
            }
        )
    }

    private fun generarProblemaContra(nivel: NivelContra): ProblemaContra {
        val usarMetodoNuevo = (1..2).random() == 1
        if (usarMetodoNuevo) {
            return generarProblemaContraNuevoMetodo(nivel)
        }
        return when (nivel) {
            NivelContra.BASICO -> generarProblemaContraBasico()
            NivelContra.MEDIO -> generarProblemaContraMedio()
            NivelContra.AVANZADO -> generarProblemaContraAvanzado()
        }
    }

    private fun generarProblemaContraNuevoMetodo(nivel: NivelContra): ProblemaContra {
        val largoBarra = listOf(2.90, 3.00).random()
        val requiereBarraAdicional = (1..2).random() == 1 // 50% probabilidad
        
        var contraAnterior = 0.0
        var perforado = 0.0
        
        if (requiereBarraAdicional) {
            // contraAnterior < perforado
            contraAnterior = when (nivel) {
                NivelContra.BASICO -> listOf(0.50, 0.80, 1.00, 1.20).random()
                NivelContra.MEDIO -> redondear2((50..150).random() / 100.0)
                NivelContra.AVANZADO -> redondear2((40..140).random() / 100.0)
            }
            perforado = when (nivel) {
                NivelContra.BASICO -> listOf(1.50, 1.80, 2.00).random()
                NivelContra.MEDIO -> redondear2((160..250).random() / 100.0)
                NivelContra.AVANZADO -> redondear2((150..280).random() / 100.0)
            }
        } else {
            // contraAnterior >= perforado
            contraAnterior = when (nivel) {
                NivelContra.BASICO -> listOf(1.80, 2.00, 2.50).random()
                NivelContra.MEDIO -> redondear2((200..450).random() / 100.0)
                NivelContra.AVANZADO -> redondear2((250..550).random() / 100.0)
            }
            perforado = when (nivel) {
                NivelContra.BASICO -> listOf(0.50, 0.80, 1.00, 1.20).random()
                NivelContra.MEDIO -> redondear2((50..180).random() / 100.0)
                NivelContra.AVANZADO -> redondear2((80..240).random() / 100.0)
            }
            // Asegurar que contraAnterior >= perforado
            if (contraAnterior < perforado) {
                val temp = contraAnterior
                contraAnterior = perforado
                perforado = temp
            }
        }

        val contraAnteriorAjustada = if (contraAnterior < perforado) contraAnterior + largoBarra else contraAnterior
        val contraCorrecta = redondear2(contraAnteriorAjustada - perforado)

        val distractores = mutableSetOf<Double>()
        while (distractores.size < 2) {
            val diferencia = when (nivel) {
                NivelContra.BASICO -> listOf(-0.50, -0.30, 0.30, 0.50).random()
                NivelContra.MEDIO -> listOf(-0.25, -0.15, 0.15, 0.25).random()
                NivelContra.AVANZADO -> listOf(-0.35, -0.08, 0.08, 0.35).random()
            }
            val posible = redondear2(contraCorrecta + diferencia)
            if (posible != contraCorrecta && posible > 0) {
                distractores.add(posible)
            }
        }
        val opciones = (distractores + contraCorrecta).shuffled()
        val respuestaCorrecta = opciones.indexOf(contraCorrecta)

        val interpretacion = if (contraAnterior < perforado) {
            "Interpretación: Como la contra anterior (${formato(contraAnterior)} m) es menor al metraje perforado (${formato(perforado)} m), significa operacionalmente que se agregó una nueva barra de ${formato(largoBarra)} m. Por lo tanto, se ajusta la contra anterior: ${formato(contraAnterior)} m + ${formato(largoBarra)} m = ${formato(contraAnteriorAjustada)} m, y luego se resta el perforado: ${formato(contraAnteriorAjustada)} m - ${formato(perforado)} m = ${formato(contraCorrecta)} m."
        } else {
            "Interpretación: Como la contra anterior (${formato(contraAnterior)} m) es mayor o igual al metraje perforado (${formato(perforado)} m), se resta directamente: ${formato(contraAnterior)} m - ${formato(perforado)} m = ${formato(contraCorrecta)} m."
        }

        return ProblemaContra(
            nivel = nivel,
            cantidadBarras = null,
            largoBarra = largoBarra,
            largoHerramienta = null,
            puntoMuerto = null,
            fondoPozo = null,
            contraCorrecta = contraCorrecta,
            opciones = opciones,
            respuestaCorrecta = respuestaCorrecta,
            interpretacion = interpretacion,
            contraAnterior = contraAnterior,
            perforado = perforado,
            metodoUsado = "anterior_perforado"
        )
    }

    private fun generarProblemaContraBasico(): ProblemaContra {
        val cantidadBarras = (40..100).random().toDouble()
        val largoBarra = 3.00
        val largoHerramienta = listOf(1.20, 1.30, 1.40, 1.50, 1.60).random()
        val puntoMuerto = listOf(0.50, 0.60, 0.70, 0.80, 0.90).random()

        val contraCorrecta = listOf(0.30, 0.50, 0.60, 0.70, 1.00, 1.20, 1.50).random()

        val profundidadCalculada = cantidadBarras * largoBarra + largoHerramienta - puntoMuerto
        val fondoPozo = redondear2(profundidadCalculada - contraCorrecta)

        return crearProblemaConOpciones(
            nivel = NivelContra.BASICO,
            cantidadBarras = cantidadBarras,
            largoBarra = largoBarra,
            largoHerramienta = largoHerramienta,
            puntoMuerto = puntoMuerto,
            fondoPozo = fondoPozo,
            contraCorrecta = contraCorrecta
        )
    }

    private fun generarProblemaContraMedio(): ProblemaContra {
        val cantidadBarras = (35..120).random().toDouble()
        val largoBarra = listOf(1.50, 3.00, 3.05).random()
        val largoHerramienta = redondear2((110..190).random() / 100.0)
        val puntoMuerto = redondear2((40..110).random() / 100.0)

        val maxCentimos = ((largoBarra - 0.05) * 100).toInt()
        val randomCentimos = (10..maxCentimos).random()
        val contraCorrecta = redondear2(randomCentimos / 100.0)

        val profundidadCalculada = cantidadBarras * largoBarra + largoHerramienta - puntoMuerto
        val fondoPozo = redondear2(profundidadCalculada - contraCorrecta)

        return crearProblemaConOpciones(
            nivel = NivelContra.MEDIO,
            cantidadBarras = cantidadBarras,
            largoBarra = largoBarra,
            largoHerramienta = largoHerramienta,
            puntoMuerto = puntoMuerto,
            fondoPozo = fondoPozo,
            contraCorrecta = contraCorrecta
        )
    }

    private fun generarProblemaContraAvanzado(): ProblemaContra {
        val cantidadBarras = (30..130).random().toDouble()
        val largoBarra = listOf(1.50, 3.00, 3.05).random()
        val largoHerramienta = redondear2((110..200).random() / 100.0)
        val puntoMuerto = redondear2((40..120).random() / 100.0)

        val tipoCaso = (1..3).random()

        val contraCorrecta = when (tipoCaso) {
            1 -> {
                val maxCentimos = ((largoBarra - 0.05) * 100).toInt()
                val randomCentimos = (10..maxCentimos).random()
                redondear2(randomCentimos / 100.0)
            }
            2 -> redondear2(((-80)..(-5)).random() / 100.0)
            else -> {
                val minCentimos = ((largoBarra + 0.10) * 100).toInt()
                val maxCentimos = ((largoBarra + 1.50) * 100).toInt()
                redondear2((minCentimos..maxCentimos).random() / 100.0)
            }
        }

        val profundidadCalculada = cantidadBarras * largoBarra + largoHerramienta - puntoMuerto
        val fondoPozo = redondear2(profundidadCalculada - contraCorrecta)

        return crearProblemaConOpciones(
            nivel = NivelContra.AVANZADO,
            cantidadBarras = cantidadBarras,
            largoBarra = largoBarra,
            largoHerramienta = largoHerramienta,
            puntoMuerto = puntoMuerto,
            fondoPozo = fondoPozo,
            contraCorrecta = contraCorrecta
        )
    }

    private fun crearProblemaConOpciones(
        nivel: NivelContra,
        cantidadBarras: Double,
        largoBarra: Double,
        largoHerramienta: Double,
        puntoMuerto: Double,
        fondoPozo: Double,
        contraCorrecta: Double
    ): ProblemaContra {
        val opciones = generarOpcionesContra(contraCorrecta, largoBarra, nivel)
        val respuestaCorrecta = opciones.indexOf(contraCorrecta)

        val interpretacion = interpretarContra(contraCorrecta, largoBarra)

        return ProblemaContra(
            nivel = nivel,
            cantidadBarras = cantidadBarras,
            largoBarra = largoBarra,
            largoHerramienta = largoHerramienta,
            puntoMuerto = puntoMuerto,
            fondoPozo = fondoPozo,
            contraCorrecta = contraCorrecta,
            opciones = opciones,
            respuestaCorrecta = respuestaCorrecta,
            interpretacion = interpretacion
        )
    }

    private fun generarOpcionesContra(
        correcta: Double,
        largoBarra: Double,
        nivel: NivelContra
    ): List<Double> {
        val distractores = mutableSetOf<Double>()

        while (distractores.size < 2) {
            val diferencia = when (nivel) {
                NivelContra.BASICO -> listOf(-1.00, -0.50, 0.50, 1.00).random()
                NivelContra.MEDIO -> listOf(-0.40, -0.30, -0.20, 0.20, 0.30, 0.40).random()
                NivelContra.AVANZADO -> listOf(-1.20, -0.75, -0.35, 0.35, 0.75, 1.20).random()
            }

            val posible = redondear2(correcta + diferencia)

            if (posible != correcta) {
                distractores.add(posible)
            }
        }

        return (distractores + correcta).shuffled()
    }

    private fun interpretarContra(contra: Double, largoBarra: Double): String {
        return when {
            contra < 0 -> {
                "Interpretación: la contra es negativa. Se deben revisar cantidad de barras, largo de barra, largo herramienta, punto muerto o fondo del pozo."
            }

            contra == 0.0 -> {
                "Interpretación: no se obtiene contra estimada. Verificar con el perforista si corresponde registrar contra cero."
            }

            contra > largoBarra -> {
                "Interpretación: la contra supera el largo de una barra. Se deben revisar los datos ingresados."
            }

            else -> {
                "Interpretación: contra dentro de rango esperable. Confirmar con el perforista antes de registrar."
            }
        }
    }

    private fun redondear2(valor: Double): Double {
        return round(valor * 100) / 100
    }

    private fun mostrarEjerciciosFondoAleatorios() {
        val layout = crearBase()
        val teal = Color.rgb(0, 96, 100)
        val tealClaro = if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(224, 247, 250)

        layout.addView(titulo("Ejercicios aleatorios de fondo"))

        layout.addView(
            tarjeta(
                "¿Qué practicarás?",
                "La app generará problemas nuevos para estimar el fondo del pozo usando barras, largo de barra, largo de herramienta, punto muerto y contra.\n\nFondo del pozo = (Cantidad de barras × Largo de barra) + Largo herramienta - Punto muerto - Contra",
                teal,
                tealClaro
            )
        )

        layout.addView(boton("Nivel básico", verde) {
            mostrarProblemaFondo(NivelCalculo.BASICO)
        })

        layout.addView(boton("Nivel medio", naranjo) {
            mostrarProblemaFondo(NivelCalculo.MEDIO)
        })

        layout.addView(boton("Nivel avanzado", rojo) {
            mostrarProblemaFondo(NivelCalculo.AVANZADO)
        })
    }

    private fun mostrarProblemaFondo(nivel: NivelCalculo) {
        val problema = generarProblemaFondo(nivel)
        val layout = crearBase()
        val teal = Color.rgb(0, 96, 100)
        val tealClaro = if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(224, 247, 250)

        layout.addView(titulo("Problema de fondo del pozo"))
        layout.addView(botonSecundario("Volver a niveles") { mostrarEjerciciosFondoAleatorios() })

        val nombreNivel = nombreNivel(nivel)
        val largoTotalBarras = problema.cantidadBarras * problema.largoBarra

        layout.addView(
            tarjeta(
                "Nivel $nombreNivel",
                "Calcula el fondo del pozo con los siguientes datos:\n\n" +
                        "Cantidad de barras: ${formato(problema.cantidadBarras)}\n" +
                        "Largo de barra: ${formato(problema.largoBarra)} m\n" +
                        "Largo de herramienta: ${formato(problema.largoHerramienta)} m\n" +
                        "Punto muerto: ${formato(problema.puntoMuerto)} m\n" +
                        "Contra: ${formato(problema.contra)} m\n\n" +
                        "Largo total de barras:\n" +
                        "${formato(problema.cantidadBarras)} × ${formato(problema.largoBarra)} = ${formato(largoTotalBarras)} m",
                teal,
                tealClaro
            )
        )

        val calcInline = crearCalculadoraBolsilloInline()
        lateinit var btnCalc: Button
        btnCalc = botonSecundario("🧮 Abrir Calculadora") {
            if (calcInline.visibility == View.VISIBLE) {
                calcInline.visibility = View.GONE
                btnCalc.text = "🧮 Abrir Calculadora"
            } else {
                calcInline.visibility = View.VISIBLE
                btnCalc.text = "🧮 Cerrar Calculadora"
            }
        }
        layout.addView(btnCalc)
        layout.addView(calcInline)
        layout.addView(subtitulo("¿Cuál es el fondo estimado del pozo?"))

        problema.opciones.forEachIndexed { index, opcion ->
            layout.addView(
                boton("${formato(opcion)} m", azul) {
                    val correcto = index == problema.respuestaCorrecta

                    val mensaje = if (correcto) {
                        "Correcto.\n\n" +
                                "Fondo = (${formato(problema.cantidadBarras)} × ${formato(problema.largoBarra)}) + ${formato(problema.largoHerramienta)} - ${formato(problema.puntoMuerto)} - ${formato(problema.contra)}\n\n" +
                                "Fondo = ${formato(problema.fondoCorrecto)} m\n\n" +
                                problema.interpretacion
                    } else {
                        "Revisar.\n\n" +
                                "La respuesta correcta era: ${formato(problema.fondoCorrecto)} m\n\n" +
                                "Fórmula:\n" +
                                "Fondo = (Barras × Largo barra) + Largo herramienta - Punto muerto - Contra\n\n" +
                                "Fondo = (${formato(problema.cantidadBarras)} × ${formato(problema.largoBarra)}) + ${formato(problema.largoHerramienta)} - ${formato(problema.puntoMuerto)} - ${formato(problema.contra)} = ${formato(problema.fondoCorrecto)} m\n\n" +
                                problema.interpretacion
                    }

                    mostrarDialogo(
                        if (correcto) "Correcto" else "Respuesta incorrecta",
                        mensaje
                    )
                }
            )
        }

        layout.addView(
            boton("Generar otro problema del mismo nivel", naranjo) {
                mostrarProblemaFondo(nivel)
            }
        )

        layout.addView(
            boton("Cambiar nivel", teal) {
                mostrarEjerciciosFondoAleatorios()
            }
        )
    }

    private fun generarProblemaFondo(nivel: NivelCalculo): ProblemaFondo {
        val cantidadBarras = when (nivel) {
            NivelCalculo.BASICO -> (40..100).random().toDouble()
            NivelCalculo.MEDIO -> (35..120).random().toDouble()
            NivelCalculo.AVANZADO -> (30..130).random().toDouble()
        }

        val largoBarra = when (nivel) {
            NivelCalculo.BASICO -> 3.00
            NivelCalculo.MEDIO -> listOf(1.50, 3.00, 3.05).random()
            NivelCalculo.AVANZADO -> listOf(1.50, 3.00, 3.05).random()
        }

        val largoHerramienta = when (nivel) {
            NivelCalculo.BASICO -> listOf(1.20, 1.30, 1.40, 1.50, 1.60).random()
            NivelCalculo.MEDIO -> redondear2((110..190).random() / 100.0)
            NivelCalculo.AVANZADO -> redondear2((110..200).random() / 100.0)
        }

        val puntoMuerto = when (nivel) {
            NivelCalculo.BASICO -> listOf(0.50, 0.60, 0.70, 0.80, 0.90).random()
            NivelCalculo.MEDIO -> redondear2((40..110).random() / 100.0)
            NivelCalculo.AVANZADO -> redondear2((40..120).random() / 100.0)
        }

        val contra = when (nivel) {
            NivelCalculo.BASICO -> listOf(0.30, 0.50, 0.60, 0.70, 1.00, 1.20).random()
            NivelCalculo.MEDIO -> {
                val maxCentimos = ((largoBarra - 0.05) * 100).toInt()
                val randomCentimos = (10..maxCentimos).random()
                redondear2(randomCentimos / 100.0)
            }
            NivelCalculo.AVANZADO -> {
                val tipoCaso = (1..3).random()
                when (tipoCaso) {
                    1 -> {
                        val maxCentimos = ((largoBarra - 0.05) * 100).toInt()
                        val randomCentimos = (10..maxCentimos).random()
                        redondear2(randomCentimos / 100.0)
                    }
                    2 -> {
                        val minCentimos = ((largoBarra + 0.10) * 100).toInt()
                        val maxCentimos = ((largoBarra + 1.50) * 100).toInt()
                        redondear2((minCentimos..maxCentimos).random() / 100.0)
                    }
                    else -> redondear2((0..(largoBarra * 100).toInt()).random() / 100.0)
                }
            }
        }

        val fondoCorrecto = redondear2(
            (cantidadBarras * largoBarra) + largoHerramienta - puntoMuerto - contra
        )

        val opciones = generarOpcionesNumericas(fondoCorrecto, nivel, permitirNegativos = false)
        val respuestaCorrecta = opciones.indexOf(fondoCorrecto)

        return ProblemaFondo(
            nivel = nivel,
            cantidadBarras = cantidadBarras,
            largoBarra = largoBarra,
            largoHerramienta = largoHerramienta,
            puntoMuerto = puntoMuerto,
            contra = contra,
            fondoCorrecto = fondoCorrecto,
            opciones = opciones,
            respuestaCorrecta = respuestaCorrecta,
            interpretacion = interpretarFondo(fondoCorrecto, contra, largoBarra)
        )
    }

    private fun interpretarFondo(fondo: Double, contra: Double, largoBarra: Double): String {
        return when {
            fondo < 0 -> "Interpretación: resultado no válido. Revisa cantidad de barras, largo de barra, largo herramienta, punto muerto o contra."
            contra > largoBarra -> "Interpretación: la contra ingresada supera el largo de una barra. Verifica el dato con el perforista."
            else -> "Interpretación: fondo estimado calculado. Confirmar con los datos operacionales antes de registrar."
        }
    }

    private fun generarOpcionesNumericas(
        correcta: Double,
        nivel: NivelCalculo,
        permitirNegativos: Boolean
    ): List<Double> {
        val distractores = mutableSetOf<Double>()

        while (distractores.size < 2) {
            val diferencia = when (nivel) {
                NivelCalculo.BASICO -> listOf(-1.00, -0.50, 0.50, 1.00).random()
                NivelCalculo.MEDIO -> listOf(-0.40, -0.30, -0.20, 0.20, 0.30, 0.40).random()
                NivelCalculo.AVANZADO -> listOf(-1.20, -0.75, -0.35, 0.35, 0.75, 1.20).random()
            }

            val posible = redondear2(correcta + diferencia)

            if (posible != correcta && (permitirNegativos || posible >= 0.0)) {
                distractores.add(posible)
            }
        }

        return (distractores + correcta).shuffled()
    }

    private fun nombreNivel(nivel: NivelCalculo): String {
        return when (nivel) {
            NivelCalculo.BASICO -> "Básico"
            NivelCalculo.MEDIO -> "Medio"
            NivelCalculo.AVANZADO -> "Avanzado"
        }
    }

    private fun mostrarEjerciciosRecuperacionAleatorios() {
        val layout = crearBase()
        val indigo = Color.rgb(124, 77, 255)
        val indigoClaro = if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(237, 231, 246)

        layout.addView(titulo("Ejercicios aleatorios de recuperación"))

        layout.addView(
            tarjeta(
                "¿Qué practicarás?",
                "La app generará problemas nuevos para calcular el porcentaje de recuperación.\n\nRecuperación (%) = Muestra recuperada / Muestra perforada × 100",
                indigo,
                indigoClaro
            )
        )

        layout.addView(boton("Nivel básico", verde) {
            mostrarProblemaRecuperacion(NivelCalculo.BASICO)
        })

        layout.addView(boton("Nivel medio", naranjo) {
            mostrarProblemaRecuperacion(NivelCalculo.MEDIO)
        })

        layout.addView(boton("Nivel avanzado", rojo) {
            mostrarProblemaRecuperacion(NivelCalculo.AVANZADO)
        })
    }

    private fun mostrarProblemaRecuperacion(nivel: NivelCalculo) {
        val problema = generarProblemaRecuperacion(nivel)
        val layout = crearBase()
        val indigo = Color.rgb(124, 77, 255)
        val indigoClaro = if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(237, 231, 246)

        layout.addView(titulo("Problema de recuperación"))
        layout.addView(botonSecundario("Volver a niveles") { mostrarEjerciciosRecuperacionAleatorios() })

        val nombreNivel = nombreNivel(nivel)

        layout.addView(
            tarjeta(
                "Nivel $nombreNivel",
                "Calcula el porcentaje de recuperación con los siguientes datos:\n\n" +
                        "Muestra perforada: ${formato(problema.perforado)} m\n" +
                        "Muestra recuperada: ${formato(problema.recuperado)} m\n\n" +
                        "Fórmula:\n" +
                        "Recuperación (%) = recuperado / perforado × 100",
                indigo,
                indigoClaro
            )
        )

        val calcInline = crearCalculadoraBolsilloInline()
        lateinit var btnCalc: Button
        btnCalc = botonSecundario("🧮 Abrir Calculadora") {
            if (calcInline.visibility == View.VISIBLE) {
                calcInline.visibility = View.GONE
                btnCalc.text = "🧮 Abrir Calculadora"
            } else {
                calcInline.visibility = View.VISIBLE
                btnCalc.text = "🧮 Cerrar Calculadora"
            }
        }
        layout.addView(btnCalc)
        layout.addView(calcInline)
        layout.addView(subtitulo("¿Cuál es el porcentaje de recuperación?"))

        problema.opciones.forEachIndexed { index, opcion ->
            layout.addView(
                boton("${formato(opcion)} %", azul) {
                    val correcto = index == problema.respuestaCorrecta

                    val mensaje = if (correcto) {
                        "Correcto.\n\n" +
                                "Recuperación = ${formato(problema.recuperado)} / ${formato(problema.perforado)} × 100\n" +
                                "Recuperación = ${formato(problema.porcentajeCorrecto)} %\n\n" +
                                problema.interpretacion
                    } else {
                        "Revisar.\n\n" +
                                "La respuesta correcta era: ${formato(problema.porcentajeCorrecto)} %\n\n" +
                                problema.interpretacion
                    }

                    mostrarDialogo(
                        if (correcto) "Correcto" else "Respuesta incorrecta",
                        mensaje
                    )
                }
            )
        }

        layout.addView(
            boton("Generar otro problema del mismo nivel", naranjo) {
                mostrarProblemaRecuperacion(nivel)
            }
        )

        layout.addView(
            boton("Cambiar nivel", indigo) {
                mostrarEjerciciosRecuperacionAleatorios()
            }
        )
    }

    private fun generarProblemaRecuperacion(nivel: NivelCalculo): ProblemaRecuperacion {
        val perforado = when (nivel) {
            NivelCalculo.BASICO -> listOf(1.00, 1.50, 2.00, 2.50, 3.00).random()
            NivelCalculo.MEDIO -> redondear2((80..310).random() / 100.0)
            NivelCalculo.AVANZADO -> redondear2((50..320).random() / 100.0)
        }

        val recuperado = when (nivel) {
            NivelCalculo.BASICO -> {
                val porcentaje = listOf(50.0, 60.0, 70.0, 80.0, 90.0, 100.0).random()
                redondear2(perforado * porcentaje / 100)
            }

            NivelCalculo.MEDIO -> {
                val porcentaje = (450..1010).random() / 10.0
                redondear2(perforado * porcentaje / 100)
            }

            NivelCalculo.AVANZADO -> {
                val tipoCaso = (1..4).random()
                val porcentaje = when (tipoCaso) {
                    1 -> (200..500).random() / 10.0
                    2 -> (500..700).random() / 10.0
                    3 -> (700..1000).random() / 10.0
                    else -> (1001..1250).random() / 10.0
                }
                redondear2(perforado * porcentaje / 100)
            }
        }

        val porcentajeCorrecto = redondear2((recuperado / perforado) * 100)

        val opciones = generarOpcionesPorcentaje(porcentajeCorrecto, nivel)
        val respuestaCorrecta = opciones.indexOf(porcentajeCorrecto)

        return ProblemaRecuperacion(
            nivel = nivel,
            perforado = perforado,
            recuperado = recuperado,
            porcentajeCorrecto = porcentajeCorrecto,
            opciones = opciones,
            respuestaCorrecta = respuestaCorrecta,
            interpretacion = interpretarRecuperacion(porcentajeCorrecto)
        )
    }

    private fun interpretarRecuperacion(porcentaje: Double): String {
        return when {
            porcentaje > 100 -> "Interpretación: recuperación mayor al 100%. Revisar si existe muestra recuperada de una corrida anterior."
            porcentaje >= 90 -> "Interpretación: muy buena recuperación. Mantener registro claro del tramo."
            porcentaje >= 70 -> "Interpretación: recuperación aceptable. Revisar estado del testigo y compactación."
            porcentaje >= 50 -> "Interpretación: recuperación baja. Registrar observación y condición de muestra."
            else -> "Interpretación: recuperación crítica. Comunicar al supervisor y dejar registro."
        }
    }

    private fun generarOpcionesPorcentaje(correcta: Double, nivel: NivelCalculo): List<Double> {
        val distractores = mutableSetOf<Double>()

        while (distractores.size < 2) {
            val diferencia = when (nivel) {
                NivelCalculo.BASICO -> listOf(-20.0, -10.0, 10.0, 20.0).random()
                NivelCalculo.MEDIO -> listOf(-15.0, -7.5, -5.0, 5.0, 7.5, 15.0).random()
                NivelCalculo.AVANZADO -> listOf(-25.0, -12.0, -6.0, 6.0, 12.0, 25.0).random()
            }

            val posible = redondear2(correcta + diferencia)

            if (posible >= 0 && posible != correcta) {
                distractores.add(posible)
            }
        }

        return (distractores + correcta).shuffled()
    }

    private fun mostrarEjerciciosRegularizacionAleatorios() {
        val layout = crearBase()
        val vermillion = Color.rgb(216, 67, 21)
        val vermillionClaro = if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(251, 233, 231)

        layout.addView(titulo("Ejercicios aleatorios de regularización"))

        layout.addView(
            tarjeta(
                "¿Qué practicarás?",
                "La app generará problemas nuevos para ubicar un taco de regularizado dentro de un tramo con recuperación parcial.\n\nDistancia física = Distancia teórica × Recuperado / Perforado",
                vermillion,
                vermillionClaro
            )
        )

        layout.addView(boton("Nivel básico", verde) {
            mostrarProblemaRegularizacion(NivelCalculo.BASICO)
        })

        layout.addView(boton("Nivel medio", naranjo) {
            mostrarProblemaRegularizacion(NivelCalculo.MEDIO)
        })

        layout.addView(boton("Nivel avanzado", rojo) {
            mostrarProblemaRegularizacion(NivelCalculo.AVANZADO)
        })
    }

    private fun mostrarProblemaRegularizacion(nivel: NivelCalculo) {
        val problema = generarProblemaRegularizacion(nivel)
        val layout = crearBase()
        val vermillion = Color.rgb(216, 67, 21)
        val vermillionClaro = if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(251, 233, 231)

        layout.addView(titulo("Problema de regularización"))
        layout.addView(botonSecundario("Volver a niveles") { mostrarEjerciciosRegularizacionAleatorios() })

        val nombreNivel = nombreNivel(nivel)
        val perforado = problema.tacoFinal - problema.tacoInicial
        val distanciaTeorica = problema.metrajeRegularizar - problema.tacoInicial

        layout.addView(
            tarjeta(
                "Nivel $nombreNivel",
                "Calcula a qué distancia física desde el taco inicial debe ubicarse el taco de regularizado.\n\n" +
                        "Taco inicial: ${formato(problema.tacoInicial)} m\n" +
                        "Taco final: ${formato(problema.tacoFinal)} m\n" +
                        "Metros perforados: ${formato(perforado)} m\n" +
                        "Metros recuperados: ${formato(problema.recuperado)} m\n" +
                        "Metraje a regularizar: ${formato(problema.metrajeRegularizar)} m\n\n" +
                        "Distancia teórica:\n" +
                        "${formato(problema.metrajeRegularizar)} - ${formato(problema.tacoInicial)} = ${formato(distanciaTeorica)} m",
                vermillion,
                vermillionClaro
            )
        )

        val calcInline = crearCalculadoraBolsilloInline()
        lateinit var btnCalc: Button
        btnCalc = botonSecundario("🧮 Abrir Calculadora") {
            if (calcInline.visibility == View.VISIBLE) {
                calcInline.visibility = View.GONE
                btnCalc.text = "🧮 Abrir Calculadora"
            } else {
                calcInline.visibility = View.VISIBLE
                btnCalc.text = "🧮 Cerrar Calculadora"
            }
        }
        layout.addView(btnCalc)
        layout.addView(calcInline)
        layout.addView(subtitulo("¿A qué distancia desde el taco inicial va el regularizado?"))

        problema.opciones.forEachIndexed { index, opcion ->
            layout.addView(
                boton("${formato(opcion)} m", azul) {
                    val correcto = index == problema.respuestaCorrecta

                    val mensaje = if (correcto) {
                        "Correcto.\n\n" +
                                "Distancia física = distancia teórica × recuperado / perforado\n" +
                                "Distancia física = ${formato(distanciaTeorica)} × ${formato(problema.recuperado)} / ${formato(perforado)}\n" +
                                "Distancia física = ${formato(problema.distanciaCorrecta)} m\n\n" +
                                "Recuperación del tramo: ${formato(problema.recuperacionPorcentaje)} %\n\n" +
                                problema.interpretacion
                    } else {
                        "Revisar.\n\n" +
                                "La respuesta correcta era: ${formato(problema.distanciaCorrecta)} m\n\n" +
                                "Distancia física = ${formato(distanciaTeorica)} × ${formato(problema.recuperado)} / ${formato(perforado)}\n" +
                                "Distancia física = ${formato(problema.distanciaCorrecta)} m\n\n" +
                                "Recuperación del tramo: ${formato(problema.recuperacionPorcentaje)} %\n\n" +
                                problema.interpretacion
                    }

                    mostrarDialogo(
                        if (correcto) "Correcto" else "Respuesta incorrecta",
                        mensaje
                    )
                }
            )
        }

        layout.addView(
            boton("Generar otro problema del mismo nivel", naranjo) {
                mostrarProblemaRegularizacion(nivel)
            }
        )

        layout.addView(
            boton("Cambiar nivel", vermillion) {
                mostrarEjerciciosRegularizacionAleatorios()
            }
        )
    }

    private fun generarProblemaRegularizacion(nivel: NivelCalculo): ProblemaRegularizacion {
        // 1. Elegir metraje a regularizar como un número entero par
        val metrajeRegularizar = when (nivel) {
            NivelCalculo.BASICO -> ((51..150).random() * 2).toDouble()
            NivelCalculo.MEDIO -> ((151..750).random() * 2).toDouble()
            NivelCalculo.AVANZADO -> ((151..750).random() * 2).toDouble()
        }

        // 2. Elegir la distancia teórica desde el inicio del taco
        val distanciaTeorica = when (nivel) {
            NivelCalculo.BASICO -> listOf(0.50, 1.00, 1.50, 2.00).random()
            NivelCalculo.MEDIO -> redondear2((20..200).random() / 100.0)
            NivelCalculo.AVANZADO -> redondear2((10..300).random() / 100.0)
        }

        // 3. El taco inicial es el metraje a regularizar menos la distancia teórica
        val tacoInicial = redondear2(metrajeRegularizar - distanciaTeorica)

        // 4. El tramo perforado debe ser mayor que la distancia teórica
        val perforado = when (nivel) {
            NivelCalculo.BASICO -> {
                val opcionesValidas = listOf(1.50, 2.00, 2.50, 3.00).filter { it > distanciaTeorica }
                if (opcionesValidas.isNotEmpty()) opcionesValidas.random() else 3.00
            }
            NivelCalculo.MEDIO -> redondear2(distanciaTeorica + (20..150).random() / 100.0)
            NivelCalculo.AVANZADO -> redondear2(distanciaTeorica + (10..180).random() / 100.0)
        }

        val tacoFinal = redondear2(tacoInicial + perforado)

        val recuperacionObjetivo = when (nivel) {
            NivelCalculo.BASICO -> listOf(70.0, 80.0, 90.0, 100.0).random()
            NivelCalculo.MEDIO -> (550..1000).random() / 10.0
            NivelCalculo.AVANZADO -> {
                val tipoCaso = (1..3).random()
                when (tipoCaso) {
                    1 -> (300..550).random() / 10.0
                    2 -> (550..900).random() / 10.0
                    else -> (900..1100).random() / 10.0
                }
            }
        }

        val recuperado = redondear2(perforado * recuperacionObjetivo / 100)
        val distanciaCorrecta = redondear2(distanciaTeorica * recuperado / perforado)
        val recuperacionPorcentaje = redondear2(recuperado / perforado * 100)

        val opciones = generarOpcionesRegularizacion(distanciaCorrecta, nivel)
        val respuestaCorrecta = opciones.indexOf(distanciaCorrecta)

        return ProblemaRegularizacion(
            nivel = nivel,
            tacoInicial = tacoInicial,
            tacoFinal = tacoFinal,
            recuperado = recuperado,
            metrajeRegularizar = metrajeRegularizar,
            distanciaCorrecta = distanciaCorrecta,
            recuperacionPorcentaje = recuperacionPorcentaje,
            opciones = opciones,
            respuestaCorrecta = respuestaCorrecta,
            interpretacion = interpretarRegularizacion(recuperacionPorcentaje)
        )
    }

    private fun interpretarRegularizacion(recuperacion: Double): String {
        return when {
            recuperacion > 100 -> "Interpretación: recuperación mayor al 100%. Revisar si existe muestra recuperada de una corrida anterior antes de regularizar."
            recuperacion >= 90 -> "Interpretación: muy buena recuperación. La ubicación del regularizado debería ser más directa."
            recuperacion >= 70 -> "Interpretación: recuperación aceptable. Aplicar cálculo y criterio geológico."
            recuperacion >= 50 -> "Interpretación: recuperación baja. Revisar condición de testigo antes de marcar."
            else -> "Interpretación: recuperación crítica. Requiere criterio geológico y registro claro del ajuste."
        }
    }

    private fun generarOpcionesRegularizacion(correcta: Double, nivel: NivelCalculo): List<Double> {
        val distractores = mutableSetOf<Double>()

        while (distractores.size < 2) {
            val diferencia = when (nivel) {
                NivelCalculo.BASICO -> listOf(-0.50, -0.30, 0.30, 0.50).random()
                NivelCalculo.MEDIO -> listOf(-0.25, -0.15, -0.10, 0.10, 0.15, 0.25).random()
                NivelCalculo.AVANZADO -> listOf(-0.40, -0.20, -0.08, 0.08, 0.20, 0.40).random()
            }

            val posible = redondear2(correcta + diferencia)

            if (posible >= 0 && posible != correcta) {
                distractores.add(posible)
            }
        }

        return (distractores + correcta).shuffled()
    }

    private fun mostrarEjerciciosPerforadoAleatorios() {
        val layout = crearBase()
        val verdeColor = verde
        val verdeClaroColor = if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(232, 245, 233)

        layout.addView(titulo("Ejercicios aleatorios de perforado"))

        layout.addView(
            tarjeta(
                "¿Qué practicarás?",
                "La app generará problemas operacionales para determinar el metraje perforado en terreno usando dos métodos:\n\n" +
                        "1. Método Contras: Perforado = Contra Anterior - Contra Actual\n" +
                        "2. Método Fondo: Perforado = Fondo Actual - Fondo Anterior",
                verdeColor,
                verdeClaroColor
            )
        )

        layout.addView(boton("Nivel básico", verde) {
            mostrarProblemaPerforado(NivelCalculo.BASICO)
        })

        layout.addView(boton("Nivel medio", naranjo) {
            mostrarProblemaPerforado(NivelCalculo.MEDIO)
        })

        layout.addView(boton("Nivel avanzado", rojo) {
            mostrarProblemaPerforado(NivelCalculo.AVANZADO)
        })
    }

    private fun mostrarProblemaPerforado(nivel: NivelCalculo) {
        val problema = generarProblemaPerforado(nivel)
        val layout = crearBase()
        val verdeColor = verde
        val verdeClaroColor = if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(232, 245, 233)

        layout.addView(titulo("Problema de perforado"))
        layout.addView(botonSecundario("Volver a niveles") { mostrarEjerciciosPerforadoAleatorios() })

        val nombreNivel = nombreNivel(nivel)

        val sbDatos = StringBuilder()
        sbDatos.append("Determina el metraje perforado en terreno con los siguientes datos operacionales:\n\n")
        
        if (problema.contraAnterior != null) {
            sbDatos.append("• Contra Anterior: ${formato(problema.contraAnterior)} m\n")
        }
        if (problema.contraActual != null) {
            sbDatos.append("• Contra Actual: ${formato(problema.contraActual)} m\n")
        }
        if (problema.fondoAnterior != null) {
            sbDatos.append("• Fondo Anterior: ${formato(problema.fondoAnterior)} m\n")
        }
        if (problema.fondoActual != null) {
            sbDatos.append("• Fondo Actual: ${formato(problema.fondoActual)} m\n")
        }

        layout.addView(
            tarjeta(
                "Nivel $nombreNivel",
                sbDatos.toString().trim(),
                verdeColor,
                verdeClaroColor
            )
        )

        val calcInline = crearCalculadoraBolsilloInline()
        lateinit var btnCalc: Button
        btnCalc = botonSecundario("🧮 Abrir Calculadora") {
            if (calcInline.visibility == View.VISIBLE) {
                calcInline.visibility = View.GONE
                btnCalc.text = "🧮 Abrir Calculadora"
            } else {
                calcInline.visibility = View.VISIBLE
                btnCalc.text = "🧮 Cerrar Calculadora"
            }
        }
        layout.addView(btnCalc)
        layout.addView(calcInline)
        layout.addView(subtitulo("¿Cuál es el metraje perforado estimado?"))

        problema.opciones.forEachIndexed { index, opcion ->
            layout.addView(
                boton("${formato(opcion)} m", azul) {
                    val correcto = index == problema.respuestaCorrecta

                    val mensaje = if (correcto) {
                        "Correcto.\n\n" +
                                "Desarrollo del cálculo:\n" +
                                "${problema.interpretacion}"
                    } else {
                        "Revisar.\n\n" +
                                "La respuesta correcta era: ${formato(problema.perforadoCorrecto)} m\n\n" +
                                "Desarrollo del cálculo:\n" +
                                "${problema.interpretacion}"
                    }

                    mostrarDialogo(
                        if (correcto) "Correcto" else "Respuesta incorrecta",
                        mensaje
                    )
                }
            )
        }

        layout.addView(
            boton("Generar otro problema del mismo nivel", naranjo) {
                mostrarProblemaPerforado(nivel)
            }
        )

        layout.addView(
            boton("Cambiar nivel", verdeColor) {
                mostrarEjerciciosPerforadoAleatorios()
            }
        )
    }

    private fun generarProblemaPerforado(nivel: NivelCalculo): ProblemaPerforado {
        val metodo = when (nivel) {
            NivelCalculo.BASICO -> listOf("contras", "fondos").random()
            NivelCalculo.MEDIO -> listOf("contras", "fondos").random()
            NivelCalculo.AVANZADO -> "ambos"
        }

        var contraAnterior: Double? = null
        var contraActual: Double? = null
        var fondoAnterior: Double? = null
        var fondoActual: Double? = null
        var perforadoCorrecto = 0.0
        val sbInterpretacion = StringBuilder()

        when (metodo) {
            "contras" -> {
                val baseContra = when (nivel) {
                    NivelCalculo.BASICO -> listOf(3.00, 4.00, 5.00).random()
                    else -> redondear2((150..450).random() / 100.0)
                }
                val perforadoVal = when (nivel) {
                    NivelCalculo.BASICO -> listOf(1.50, 2.00, 3.00).random()
                    else -> redondear2((100..300).random() / 100.0)
                }
                contraAnterior = redondear2(baseContra)
                contraActual = redondear2(baseContra - perforadoVal)
                perforadoCorrecto = perforadoVal

                sbInterpretacion.append("• Método por Contras:\n")
                sbInterpretacion.append("  Fórmula: Perforado = Contra Anterior - Contra Actual\n")
                sbInterpretacion.append("  Cálculo: ${formato(contraAnterior)} m - ${formato(contraActual)} m\n")
                sbInterpretacion.append("  Resultado: ${formato(perforadoCorrecto)} m\n\n")
                sbInterpretacion.append("💡 Tip de Terreno: Este método es infalible si el largo de la sarta de barras no cambió durante la corrida.")
            }
            "fondos" -> {
                val baseFondo = when (nivel) {
                    NivelCalculo.BASICO -> listOf(30.00, 45.00, 60.00).random()
                    else -> redondear2((3000..7500).random() / 100.0)
                }
                val perforadoVal = when (nivel) {
                    NivelCalculo.BASICO -> listOf(1.50, 2.00, 3.00).random()
                    else -> redondear2((100..300).random() / 100.0)
                }
                fondoAnterior = redondear2(baseFondo)
                fondoActual = redondear2(baseFondo + perforadoVal)
                perforadoCorrecto = perforadoVal

                sbInterpretacion.append("• Método por Fondos:\n")
                sbInterpretacion.append("  Fórmula: Perforado = Fondo Actual - Fondo Anterior\n")
                sbInterpretacion.append("  Cálculo: ${formato(fondoActual)} m - ${formato(fondoAnterior)} m\n")
                sbInterpretacion.append("  Resultado: ${formato(perforadoCorrecto)} m\n\n")
                sbInterpretacion.append("💡 Tip de Terreno: Este método mide el avance real de la perforación en el fondo del pozo.")
            }
            else -> {
                // "ambos" (Avanzado)
                val baseFondo = redondear2((5000..12000).random() / 100.0)
                val perforadoVal = redondear2((120..290).random() / 100.0)
                
                fondoAnterior = redondear2(baseFondo)
                fondoActual = redondear2(baseFondo + perforadoVal)
                
                val baseContra = redondear2((200..500).random() / 100.0)
                contraAnterior = redondear2(baseContra)
                contraActual = redondear2(baseContra - perforadoVal)
                
                perforadoCorrecto = perforadoVal

                sbInterpretacion.append("• Al contar con ambos datos, puedes validar la consistencia:\n")
                sbInterpretacion.append("  1. Por Contras: ${formato(contraAnterior)} m - ${formato(contraActual)} m = ${formato(perforadoCorrecto)} m\n")
                sbInterpretacion.append("  2. Por Fondos: ${formato(fondoActual)} m - ${formato(fondoAnterior)} m = ${formato(perforadoCorrecto)} m\n\n")
                sbInterpretacion.append("✅ Ambos métodos coinciden perfectamente en ${formato(perforadoCorrecto)} m.")
            }
        }

        val opciones = generarOpcionesNumericas(perforadoCorrecto, nivel, permitirNegativos = false)
        val respuestaCorrecta = opciones.indexOf(perforadoCorrecto)

        return ProblemaPerforado(
            nivel = nivel,
            contraAnterior = contraAnterior,
            contraActual = contraActual,
            fondoAnterior = fondoAnterior,
            fondoActual = fondoActual,
            perforadoCorrecto = perforadoCorrecto,
            opciones = opciones,
            respuestaCorrecta = respuestaCorrecta,
            interpretacion = sbInterpretacion.toString().trim(),
            metodoUsado = metodo
        )
    }

    private fun mostrarDificultadRonda15() {
        val layout = crearBase()
        val azulColor = azul
        val azulClaroColor = if (modoOscuro) Color.rgb(30, 41, 59) else Color.rgb(224, 242, 241)

        layout.addView(titulo("Ronda de 15 Ejercicios"))

        layout.addView(
            tarjeta(
                "¿Qué es esta ronda?",
                "La app generará de manera dinámica e interactiva 15 problemas prácticos de terreno calculados según tu nivel de dificultad.\n\n" +
                        "La ronda contiene una combinación equilibrada con al menos 2 ejercicios de cada una de las 5 competencias clave:\n\n" +
                        "• Cálculo de Contras (Físico/Operacional)\n" +
                        "• Cálculo de Fondos de pozo\n" +
                        "• Porcentaje de Recuperación física\n" +
                        "• Regularización física de tacos\n" +
                        "• Metraje perforado estimado",
                azulColor,
                azulClaroColor
            )
        )

        layout.addView(subtitulo("Selecciona la dificultad de la ronda:"))

        layout.addView(boton("Nivel Básico", verde) {
            iniciarRonda15(NivelCalculo.BASICO)
        })

        layout.addView(boton("Nivel Medio", naranjo) {
            iniciarRonda15(NivelCalculo.MEDIO)
        })

        layout.addView(boton("Nivel Avanzado", rojo) {
            iniciarRonda15(NivelCalculo.AVANZADO)
        })

        layout.addView(botonSecundario("Volver a Ejercicios") {
            mostrarEjercicios()
        })
    }

    private fun iniciarRonda15(dificultad: NivelCalculo) {
        ejercicioIndex = 0
        ejerciciosActuales = generarRonda15Ejercicios(dificultad)
        mostrarEjercicioSecuencial()
    }

    private fun generarRonda15Ejercicios(dificultad: NivelCalculo): List<EjercicioPractico> {
        val pool = mutableListOf<EjercicioPractico>()

        val nivelContra = when (dificultad) {
            NivelCalculo.BASICO -> NivelContra.BASICO
            NivelCalculo.MEDIO -> NivelContra.MEDIO
            NivelCalculo.AVANZADO -> NivelContra.AVANZADO
        }

        // 1. Contra (al menos 2)
        for (i in 1..2) {
            pool.add(convertirContraAEjercicio(generarProblemaContra(nivelContra)))
        }

        // 2. Fondo (al menos 2)
        for (i in 1..2) {
            pool.add(convertirFondoAEjercicio(generarProblemaFondo(dificultad)))
        }

        // 3. Recuperación (al menos 2)
        for (i in 1..2) {
            pool.add(convertirRecuperacionAEjercicio(generarProblemaRecuperacion(dificultad)))
        }

        // 4. Regularización (al menos 2)
        for (i in 1..2) {
            pool.add(convertirRegularizacionAEjercicio(generarProblemaRegularizacion(dificultad)))
        }

        // 5. Perforado (al menos 2)
        for (i in 1..2) {
            pool.add(convertirPerforadoAEjercicio(generarProblemaPerforado(dificultad)))
        }

        // 6. Los otros 5 elegidos completamente al azar de cualquiera de los tipos
        for (i in 1..5) {
            val tipo = (1..5).random()
            val ejercicio = when (tipo) {
                1 -> convertirContraAEjercicio(generarProblemaContra(nivelContra))
                2 -> convertirFondoAEjercicio(generarProblemaFondo(dificultad))
                3 -> convertirRecuperacionAEjercicio(generarProblemaRecuperacion(dificultad))
                4 -> convertirRegularizacionAEjercicio(generarProblemaRegularizacion(dificultad))
                else -> convertirPerforadoAEjercicio(generarProblemaPerforado(dificultad))
            }
            pool.add(ejercicio)
        }

        return pool.shuffled()
    }

    private fun convertirContraAEjercicio(problema: ProblemaContra): EjercicioPractico {
        val enunciado = if (problema.metodoUsado == "anterior_perforado") {
            "Calcula la contra actual con los siguientes datos operacionales:\n\n" +
                    "• Contra anterior: ${formato(problema.contraAnterior!!)} m\n" +
                    "• Metraje perforado: ${formato(problema.perforado!!)} m\n" +
                    "• Largo de barra del pozo: ${formato(problema.largoBarra!!)} m\n\n" +
                    "Fórmula básica:\n" +
                    "Contra actual = Contra anterior - Perforado\n" +
                    "⚠️ Regla de Terreno: Recuerda aplicar el ajuste de adición de barra si corresponde."
        } else {
            val profundidadCalculada =
                (problema.cantidadBarras!! * problema.largoBarra!!) +
                        problema.largoHerramienta!! -
                        problema.puntoMuerto!!
            "Calcula la contra estimada con los siguientes datos:\n\n" +
                    "• Cantidad de barras: ${formato(problema.cantidadBarras!!)}\n" +
                    "• Largo de barra: ${formato(problema.largoBarra!!)} m\n" +
                    "• Largo herramienta: ${formato(problema.largoHerramienta!!)} m\n" +
                    "• Punto muerto: ${formato(problema.puntoMuerto!!)} m\n" +
                    "• Fondo del pozo: ${formato(problema.fondoPozo!!)} m\n\n" +
                    "Fórmula:\n" +
                    "Contra = profundidad calculada - fondo del pozo\n" +
                    "Profundidad = (Barras × Largo) + Herramienta - Punto muerto"
        }

        val retro = if (problema.metodoUsado == "anterior_perforado") {
            val seAgregoBarra = problema.contraAnterior!! < problema.perforado!!
            val contraAnteriorAjustada = if (seAgregoBarra) problema.contraAnterior!! + problema.largoBarra!! else problema.contraAnterior!!
            val pasoAjuste = if (seAgregoBarra) {
                "Como la contra anterior (${formato(problema.contraAnterior!!)} m) es menor al metraje perforado (${formato(problema.perforado!!)} m), significa operacionalmente que se agregó una barra nueva de ${formato(problema.largoBarra!!)} m.\n" +
                "   • Contra Anterior Ajustada = ${formato(problema.contraAnterior!!)} m + ${formato(problema.largoBarra!!)} m = ${formato(contraAnteriorAjustada)} m\n\n"
            } else {
                ""
            }
            val formulaUsada = if (seAgregoBarra) {
                "Contra actual = (Contra anterior + Largo barra) - Perforado"
            } else {
                "Contra actual = Contra anterior - Perforado"
            }
            val calculoDesarrollado = if (seAgregoBarra) {
                "Contra actual = (${formato(problema.contraAnterior!!)} m + ${formato(problema.largoBarra!!)} m) - ${formato(problema.perforado!!)} m\n" +
                "Contra actual = ${formato(contraAnteriorAjustada)} m - ${formato(problema.perforado!!)} m = ${formato(problema.contraCorrecta)} m"
            } else {
                "Contra actual = ${formato(problema.contraAnterior!!)} m - ${formato(problema.perforado!!)} m = ${formato(problema.contraCorrecta)} m"
            }

            pasoAjuste +
                    "Fórmula:\n" +
                    "   • $formulaUsada\n\n" +
                    "Desarrollo:\n" +
                    "   • $calculoDesarrollado\n\n" +
                    problema.interpretacion
        } else {
            val profundidadCalculada =
                (problema.cantidadBarras!! * problema.largoBarra!!) +
                        problema.largoHerramienta!! -
                        problema.puntoMuerto!!
            "Contra = profundidad calculada - fondo del pozo\n" +
                    "Contra = ${formato(profundidadCalculada)} - ${formato(problema.fondoPozo!!)}\n" +
                    "Contra = ${formato(problema.contraCorrecta)} m\n\n" +
                    problema.interpretacion
        }

        return EjercicioPractico(
            titulo = "Cálculo de Contra",
            enunciado = enunciado,
            opciones = problema.opciones.map { "${formato(it)} m" },
            correcta = problema.respuestaCorrecta,
            retroalimentacion = retro
        )
    }

    private fun convertirFondoAEjercicio(problema: ProblemaFondo): EjercicioPractico {
        val profundidadCalculada =
            (problema.cantidadBarras * problema.largoBarra) +
                    problema.largoHerramienta -
                    problema.puntoMuerto
        val enunciado = "Calcula el fondo del pozo estimado con los siguientes datos:\n\n" +
                "• Cantidad de barras: ${formato(problema.cantidadBarras)}\n" +
                "• Largo de barra: ${formato(problema.largoBarra)} m\n" +
                "• Largo herramienta: ${formato(problema.largoHerramienta)} m\n" +
                "• Punto muerto: ${formato(problema.puntoMuerto)} m\n" +
                "• Contra: ${formato(problema.contra)} m\n\n" +
                "Fórmula:\n" +
                "Fondo del Pozo = profundidad calculada - Contra\n" +
                "Profundidad = (Barras × Largo) + Herramienta - Punto muerto"

        val retro = "Fondo del Pozo = profundidad calculada - Contra\n" +
                "Fondo del Pozo = ${formato(profundidadCalculada)} - ${formato(problema.contra)}\n" +
                "Fondo del Pozo = ${formato(problema.fondoCorrecto)} m\n\n" +
                problema.interpretacion

        return EjercicioPractico(
            titulo = "Cálculo de Fondo",
            enunciado = enunciado,
            opciones = problema.opciones.map { "${formato(it)} m" },
            correcta = problema.respuestaCorrecta,
            retroalimentacion = retro
        )
    }

    private fun convertirRecuperacionAEjercicio(problema: ProblemaRecuperacion): EjercicioPractico {
        val enunciado = "Determina el porcentaje de recuperación obtenido con los siguientes datos:\n\n" +
                "• Metraje perforado: ${formato(problema.perforado)} m\n" +
                "• Muestra recuperada física: ${formato(problema.recuperado)} m\n\n" +
                "Fórmula:\n" +
                "Recuperación (%) = (Recuperado / Perforado) × 100"

        val retro = "Recuperación (%) = (Recuperado / Perforado) × 100\n" +
                "Recuperación (%) = (${formato(problema.recuperado)} / ${formato(problema.perforado)}) × 100\n" +
                "Recuperación (%) = ${formato(problema.porcentajeCorrecto)}%\n\n" +
                problema.interpretacion

        return EjercicioPractico(
            titulo = "Porcentaje de Recuperación",
            enunciado = enunciado,
            opciones = problema.opciones.map { "${formato(it)}%" },
            correcta = problema.respuestaCorrecta,
            retroalimentacion = retro
        )
    }

    private fun convertirRegularizacionAEjercicio(problema: ProblemaRegularizacion): EjercicioPractico {
        val enunciado = "Determina la ubicación física real a regularizar con los siguientes datos operacionales:\n\n" +
                "• Taco Inicial: ${formato(problema.tacoInicial)} m\n" +
                "• Taco Final: ${formato(problema.tacoFinal)} m\n" +
                "• Metros recuperados físicos: ${formato(problema.recuperado)} m\n" +
                "• Metraje teórico a regularizar: ${formato(problema.metrajeRegularizar)} m\n\n" +
                "Fórmulas:\n" +
                "• Distancia Teórica = Metraje a Regularizar - Taco Inicial\n" +
                "• Metraje Perforado = Taco Final - Taco Inicial\n" +
                "• Ubicación Física = Distancia Teórica × (Recuperado / Perforado)"

        return EjercicioPractico(
            titulo = "Regularización de Tacos",
            enunciado = enunciado,
            opciones = problema.opciones.map { "${formato(it)} m" },
            correcta = problema.respuestaCorrecta,
            retroalimentacion = problema.interpretacion
        )
    }

    private fun convertirPerforadoAEjercicio(problema: ProblemaPerforado): EjercicioPractico {
        val sbDatos = StringBuilder()
        sbDatos.append("Determina el metraje perforado en terreno con los siguientes datos operacionales:\n\n")
        
        if (problema.contraAnterior != null) {
            sbDatos.append("• Contra Anterior: ${formato(problema.contraAnterior)} m\n")
        }
        if (problema.contraActual != null) {
            sbDatos.append("• Contra Actual: ${formato(problema.contraActual)} m\n")
        }
        if (problema.fondoAnterior != null) {
            sbDatos.append("• Fondo Anterior: ${formato(problema.fondoAnterior)} m\n")
        }
        if (problema.fondoActual != null) {
            sbDatos.append("• Fondo Actual: ${formato(problema.fondoActual)} m\n")
        }
        
        sbDatos.append("\nMétodos disponibles:\n")
        sbDatos.append("1. Contras: Perforado = Contra Anterior - Contra Actual\n")
        sbDatos.append("2. Fondos: Perforado = Fondo Actual - Fondo Anterior")

        return EjercicioPractico(
            titulo = "Metraje Perforado",
            enunciado = sbDatos.toString().trim(),
            opciones = problema.opciones.map { "${formato(it)} m" },
            correcta = problema.respuestaCorrecta,
            retroalimentacion = problema.interpretacion
        )
    }

    private fun crearCalculadoraBolsilloInline(): LinearLayout {
        val calcView = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(16), dp(16), dp(16), dp(16))
            background = fondoRedondeado(superficieSuave, radio = 22)
            visibility = View.GONE
            
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, dp(4), 0, dp(12))
            }
        }

        // Fila de Cabecera con Título y Toggle Científico
        val headerLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = android.view.Gravity.CENTER_VERTICAL
            setPadding(0, 0, 0, dp(8))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        val tvTitulo = TextView(this).apply {
            text = "🧮 Calculadora Integrada"
            textSize = 16f
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setTextColor(azulOscuro)
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        }
        headerLayout.addView(tvTitulo)

        // Pantalla de la calculadora
        val display = EditText(this).apply {
            textSize = 20f
            setTextColor(Color.WHITE)
            background = fondoRedondeado(Color.rgb(15, 23, 42), radio = 14)
            gravity = android.view.Gravity.END or android.view.Gravity.CENTER_VERTICAL
            setPadding(dp(12), dp(12), dp(12), dp(12))
            inputType = InputType.TYPE_CLASS_TEXT
            
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, dp(6))
            }
        }

        // Panel Científico (TableLayout)
        val scientificPanel = android.widget.TableLayout(this).apply {
            visibility = View.GONE
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, dp(4))
            }
        }

        val btnModo = Button(this).apply {
            text = "🔬 Científica"
            textSize = 12f
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setTextColor(azul)
            background = fondoRedondeado(superficie, radio = 10)
            setPadding(dp(8), dp(4), dp(8), dp(4))
            
            setOnClickListener {
                if (scientificPanel.visibility == View.VISIBLE) {
                    scientificPanel.visibility = View.GONE
                    text = "🔬 Científica"
                } else {
                    scientificPanel.visibility = View.VISIBLE
                    text = "🧮 Estándar"
                }
            }
        }
        headerLayout.addView(btnModo)
        calcView.addView(headerLayout)
        calcView.addView(display)

        // Resultado en tiempo real
        val tvResultado = TextView(this).apply {
            text = "="
            textSize = 16f
            setTypeface(Typeface.DEFAULT, Typeface.BOLD)
            setTextColor(verde)
            gravity = android.view.Gravity.END
            setPadding(0, 0, dp(6), dp(10))
        }
        calcView.addView(tvResultado)

        // Escuchador de cambios en tiempo real
        display.addTextChangedListener(object : android.text.TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                val expresion = s.toString().trim()
                if (expresion.isEmpty()) {
                    tvResultado.text = "="
                    return
                }
                try {
                    val exprLimpia = expresion
                        .lowercase()
                        .replace("x", "*")
                        .replace("÷", "/")
                        .replace(",", ".")
                        .replace("√", "sqrt")
                    val resultado = evaluarMatematicas(exprLimpia)
                    tvResultado.text = "= ${formato(resultado)}"
                    tvResultado.setTextColor(verde)
                } catch (e: Exception) {
                    tvResultado.text = "Error de sintaxis"
                    tvResultado.setTextColor(rojo)
                }
            }
            override fun afterTextChanged(s: android.text.Editable?) {}
        })

        // Rellenar botones científicos
        val filasCientificas = listOf(
            listOf("sin", "cos", "tan", "^"),
            listOf("√", "π", "e", "log")
        )

        filasCientificas.forEach { fila ->
            val tableRow = android.widget.TableRow(this).apply {
                layoutParams = android.widget.TableLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
            }

            fila.forEach { texto ->
                val btnColor = purpura

                val btn = Button(this).apply {
                    text = texto
                    textSize = 14f
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                    setTextColor(Color.WHITE)
                    background = fondoRedondeado(btnColor, radio = 10)
                    setPadding(0, dp(8), 0, dp(8))

                    layoutParams = android.widget.TableRow.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                        setMargins(dp(3), dp(3), dp(3), dp(3))
                    }

                    setOnClickListener {
                        when (texto) {
                            "sin" -> display.append("sin(")
                            "cos" -> display.append("cos(")
                            "tan" -> display.append("tan(")
                            "√" -> display.append("√(")
                            "log" -> display.append("log(")
                            "π" -> display.append("π")
                            "e" -> display.append("e")
                            else -> display.append(texto)
                        }
                    }
                }
                tableRow.addView(btn)
            }
            scientificPanel.addView(tableRow)
        }
        calcView.addView(scientificPanel)

        // Grid de botones estándar
        val gridLayout = android.widget.TableLayout(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        val filasBotones = listOf(
            listOf("C", "(", ")", "÷"),
            listOf("7", "8", "9", "x"),
            listOf("4", "5", "6", "-"),
            listOf("1", "2", "3", "+"),
            listOf("0", ".", "DEL", "=")
        )

        filasBotones.forEach { fila ->
            val tableRow = android.widget.TableRow(this).apply {
                layoutParams = android.widget.TableLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
            }

            fila.forEach { texto ->
                val btnColor = when (texto) {
                    "C" -> rojo
                    "=", "DEL" -> naranjo
                    "+", "-", "x", "÷", "(", ")" -> azul
                    else -> if (modoOscuro) Color.rgb(51, 65, 85) else Color.rgb(226, 232, 240)
                }

                val btn = Button(this).apply {
                    text = texto
                    textSize = 16f
                    setTypeface(Typeface.DEFAULT, Typeface.BOLD)
                    
                    val red = Color.red(btnColor)
                    val green = Color.green(btnColor)
                    val blue = Color.blue(btnColor)
                    val luminancia = 0.299 * red + 0.587 * green + 0.114 * blue
                    if (luminancia > 180.0) {
                        setTextColor(Color.rgb(15, 23, 42))
                    } else {
                        setTextColor(Color.WHITE)
                    }

                    background = fondoRedondeado(btnColor, radio = 10)
                    setPadding(0, dp(8), 0, dp(8))

                    layoutParams = android.widget.TableRow.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                        setMargins(dp(3), dp(3), dp(3), dp(3))
                    }

                    setOnClickListener {
                        when (texto) {
                            "C" -> display.text.clear()
                            "DEL" -> {
                                val str = display.text.toString()
                                if (str.isNotEmpty()) {
                                    display.setText(str.substring(0, str.length - 1))
                                    display.setSelection(display.text.length)
                                }
                            }
                            "=" -> {
                                val str = display.text.toString()
                                try {
                                    val exprLimpia = str
                                        .lowercase()
                                        .replace("x", "*")
                                        .replace("÷", "/")
                                        .replace(",", ".")
                                        .replace("√", "sqrt")
                                    val valFinal = evaluarMatematicas(exprLimpia)
                                    display.setText(formato(valFinal))
                                    display.setSelection(display.text.length)
                                } catch (e: Exception) {
                                    tvResultado.text = "Error"
                                    tvResultado.setTextColor(rojo)
                                }
                            }
                            else -> {
                                display.append(texto)
                            }
                        }
                    }
                }
                tableRow.addView(btn)
            }
            gridLayout.addView(tableRow)
        }
        calcView.addView(gridLayout)

        return calcView
    }

    private fun evaluarMatematicas(str: String): Double {
        return object : Any() {
            var pos = -1
            var ch = 0

            fun nextChar() {
                ch = if (++pos < str.length) str[pos].code else -1
            }

            fun eat(charToEat: Int): Boolean {
                while (ch == ' '.code) nextChar()
                if (ch == charToEat) {
                    nextChar()
                    return true
                }
                return false
            }

            fun parse(): Double {
                nextChar()
                val x = parseExpression()
                if (pos < str.length) throw RuntimeException("Carácter inesperado: " + ch.toChar())
                return x
            }

            fun parseExpression(): Double {
                var x = parseTerm()
                while (true) {
                    if (eat('+'.code)) x += parseTerm()
                    else if (eat('-'.code)) x -= parseTerm()
                    else return x
                }
            }

            fun parseTerm(): Double {
                var x = parseFactor()
                while (true) {
                    if (eat('*'.code)) x *= parseFactor()
                    else if (eat('/'.code)) x /= parseFactor()
                    else return x
                }
            }

            fun parseFactor(): Double {
                if (eat('+'.code)) return parseFactor()
                if (eat('-'.code)) return -parseFactor()

                var x: Double
                val startPos = pos
                if (eat('('.code)) {
                    x = parseExpression()
                    eat(')'.code)
                } else if (ch >= '0'.code && ch <= '9'.code || ch == '.'.code) {
                    while (ch >= '0'.code && ch <= '9'.code || ch == '.'.code) nextChar()
                    x = str.substring(startPos, pos).toDouble()
                } else if (ch >= 'a'.code && ch <= 'z'.code || ch == 'π'.code) {
                    while (ch >= 'a'.code && ch <= 'z'.code || ch == 'π'.code) nextChar()
                    val name = str.substring(startPos, pos)
                    if (name == "pi" || name == "π") {
                        x = Math.PI
                    } else if (name == "e") {
                        x = Math.E
                    } else {
                        eat('('.code)
                        val arg = parseExpression()
                        eat(')'.code)
                        x = when (name) {
                            "sin" -> Math.sin(Math.toRadians(arg))
                            "cos" -> Math.cos(Math.toRadians(arg))
                            "tan" -> Math.tan(Math.toRadians(arg))
                            "sqrt" -> Math.sqrt(arg)
                            "log" -> Math.log10(arg)
                            "ln" -> Math.log(arg)
                            else -> throw RuntimeException("Función desconocida: $name")
                        }
                    }
                } else {
                    throw RuntimeException("Esperado número, función o paréntesis")
                }

                if (eat('^'.code)) x = Math.pow(x, parseFactor())

                return x
            }
        }.parse()
    }
}

enum class NivelCalculo {
    BASICO,
    MEDIO,
    AVANZADO
}

data class ProblemaFondo(
    val nivel: NivelCalculo,
    val cantidadBarras: Double,
    val largoBarra: Double,
    val largoHerramienta: Double,
    val puntoMuerto: Double,
    val contra: Double,
    val fondoCorrecto: Double,
    val opciones: List<Double>,
    val respuestaCorrecta: Int,
    val interpretacion: String
)

enum class NivelContra {
    BASICO,
    MEDIO,
    AVANZADO
}

data class ProblemaContra(
    val nivel: NivelContra,
    val cantidadBarras: Double?,
    val largoBarra: Double?,
    val largoHerramienta: Double?,
    val puntoMuerto: Double?,
    val fondoPozo: Double?,
    val contraCorrecta: Double,
    val opciones: List<Double>,
    val respuestaCorrecta: Int,
    val interpretacion: String,
    val contraAnterior: Double? = null,
    val perforado: Double? = null,
    val metodoUsado: String = "barras"
)

data class ProblemaRecuperacion(
    val nivel: NivelCalculo,
    val perforado: Double,
    val recuperado: Double,
    val porcentajeCorrecto: Double,
    val opciones: List<Double>,
    val respuestaCorrecta: Int,
    val interpretacion: String
)

data class ProblemaRegularizacion(
    val nivel: NivelCalculo,
    val tacoInicial: Double,
    val tacoFinal: Double,
    val recuperado: Double,
    val metrajeRegularizar: Double,
    val distanciaCorrecta: Double,
    val recuperacionPorcentaje: Double,
    val opciones: List<Double>,
    val respuestaCorrecta: Int,
    val interpretacion: String
)

data class ProblemaPerforado(
    val nivel: NivelCalculo,
    val contraAnterior: Double?,
    val contraActual: Double?,
    val fondoAnterior: Double?,
    val fondoActual: Double?,
    val perforadoCorrecto: Double,
    val opciones: List<Double>,
    val respuestaCorrecta: Int,
    val interpretacion: String,
    val metodoUsado: String
)
