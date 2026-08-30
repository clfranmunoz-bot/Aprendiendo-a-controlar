import 'package:aprender_a_controlar/models/glosario.dart';

const List<String> categoriasGlosario = [
  'Todas',
  '🔧 Equipos y Herramientas',
  '📐 Medición y Cálculo',
  '🪨 Geología del Terreno',
  '📄 Documentación y Seguridad',
  '💧 Fluidos y Lodos',
];

const List<TerminoGlosario> bancoGlosario = [

  // ─── 🔧 EQUIPOS Y HERRAMIENTAS ───────────────────────────────────────────
  TerminoGlosario(
    termino: "Barril tomamuestra",
    definicion: "Conjunto de herramientas que se inserta en el interior de la sarta para capturar el testigo de roca. Está compuesto por el tubo exterior, el tubo interior, la laina y la corona.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Barril corto",
    definicion: "Barril tomamuestra con longitud de 2.60 metros, utilizado en terrenos muy fracturados, al inicio de un pozo o cuando el terreno es inestable.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Barril largo",
    definicion: "Barril tomamuestra estándar con longitud de 4.15 metros. Se utiliza en la mayoría de las corridas en roca competente, permitiendo corridas de hasta 3.00 metros de avance.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Casing",
    definicion: "Tubería metálica que se instala al inicio del pozo para estabilizar las paredes del terreno superficial e impedir derrumbes. Actúa como revestimiento del collar.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Corona diamantada",
    definicion: "Herramienta de corte ubicada en la punta de la sarta. Está impregnada de diamantes naturales o sintéticos y es la responsable de cortar la roca y generar el testigo.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Extensión Reflex (Reaming Shell)",
    definicion: "Tubería de extensión que se acopla entre el barril y las barras de perforación. Mide 0.40 metros y es utilizada cuando se trabaja con cámara de orientación Reflex.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Laina",
    definicion: "Pieza cilíndrica de PVC o aluminio ubicada en el interior del tubo interior del barril. Contiene físicamente el testigo de roca durante su extracción y traslado.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Pescante",
    definicion: "Herramienta que se baja por wire line para enganchar el cabezal del tubo interior y extraerlo del pozo junto con el testigo de roca.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Plataforma de trabajo",
    definicion: "Lugar físico preparado y habilitado donde se emplaza la máquina sondeadora. Debe tener nivel adecuado, segregación perimetral y libre de derrames.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Sarta de perforación",
    definicion: "Conjunto de barras de perforación enroscadas que transmiten la rotación desde el cabezal de la máquina hasta la corona. La sarta puede tener decenas de barras según la profundidad.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Taco de bloqueo",
    definicion: "Separador plástico rojo o de madera rotulado que se coloca entre corridas dentro de la bandeja para identificar el límite de cada carrera perforada.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Taco de regularización",
    definicion: "Taco especial que se ubica en los múltiplos exactos de 1 metro dentro del testigo para servir como referencia de regularización visual y documentar la pérdida de testigo.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Tricono",
    definicion: "Herramienta rotatoria con 3 conos de dientes de acero o insertos de carburo. Se usa cuando no se necesita recuperar testigo (tramos de avance, cambios de diámetro o terrenos muy sueltos).",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Wire line",
    definicion: "Cable acerado flexible de alta resistencia utilizado para bajar el pescante y extraer el tubo interior del pozo sin necesidad de sacar las barras de perforación.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Bandeja porta testigo",
    definicion: "Contenedor rectangular de madera o plástico donde se almacenan y trasladan las muestras de roca ordenadas de forma correlativa, respetando el sentido de avance del pozo.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Barra de perforación",
    definicion: "Tubo acerado de 3.00 metros (o 2.90 metros según serie) que se enrosca a otras barras para transmitir rotación y permitir el avance de la corona en profundidad.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Empate",
    definicion: "Operación de inicio de la perforación en el punto exacto del collar del pozo. Implica instalar el casing, emplazar la máquina y comenzar la perforación.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Cabezal hidráulico (rotador)",
    definicion: "Componente de la máquina que transmite la rotación a la sarta de barras. Es la parte superior de la máquina que gira y avanza con la perforación.",
    categoria: "🔧 Equipos y Herramientas",
  ),
  TerminoGlosario(
    termino: "Bomba de agua",
    definicion: "Equipo que impulsa el fluido de perforación (agua o lodo) a través de las barras hacia la corona para refrigerar, lubricar y transportar el detritus hacia la superficie.",
    categoria: "🔧 Equipos y Herramientas",
  ),

  // ─── 📐 MEDICIÓN Y CÁLCULO ────────────────────────────────────────────────
  TerminoGlosario(
    termino: "Contra (sobrante de sarta)",
    definicion: "Distancia que sobra entre el punto de referencia del cabezal y la marca de medición, luego de ajustar la sarta. Permite verificar la coherencia entre profundidad, barras y barril. Debe ser consultada al perforista y registrada en el cuaderno.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Punto Muerto (PM)",
    definicion: "Distancia fija y constante entre la superficie del terreno (nivel del collar del pozo) y la marca de referencia de lectura de la contra en el cabezal de la máquina. Su valor está entre 0.40 m y 0.60 m según el tipo de rig.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Herramientas Totales (Sarta)",
    definicion: "Suma total de la longitud de la sarta de perforación, calculada como: (N° de Barras × Largo de Barra) + Barril + Extensión Reflex − Punto Muerto.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Fondo del pozo",
    definicion: "Profundidad actual del pozo expresada en metros, calculada como: Herramientas Totales − Contra. O bien, como el fondo anterior más los metros perforados en la corrida.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Porcentaje de recuperación (%Rec)",
    definicion: "Relación entre el testigo recuperado físicamente y los metros perforados en esa corrida. Se calcula: (Testigo recuperado / Metros perforados) × 100. Indica la calidad de la muestra obtenida.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Regularización",
    definicion: "Proceso de marcar el testigo con tacos a múltiplos exactos de metro para referenciar la pérdida de muestra ocurrida. Permite al geólogo saber exactamente en qué profundidad se perdió testigo.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Azimut",
    definicion: "Ángulo horizontal de la orientación del pozo medido en grados desde el Norte geográfico (0°) en sentido horario. Indica hacia dónde apunta el pozo en planta.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Inclinación del pozo",
    definicion: "Ángulo de desviación del pozo con respecto a la horizontal. Un pozo vertical tiene inclinación de 90°; un pozo horizontal tiene 0°. Afecta el cálculo real de la profundidad verdadera.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "RQD (Rock Quality Designation)",
    definicion: "Indicador geotécnico de calidad de la roca. Se calcula sumando los trozos de testigo ≥10 cm y dividiéndolos por el largo perforado. Valores: 0-25% muy pobre, 25-50% pobre, 50-75% regular, 75-90% bueno, 90-100% excelente.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Corrida (carrera)",
    definicion: "Intervalo de perforación entre una extracción de testigo y la siguiente. Se identifica con su Desde y Hasta en metros, los metros perforados y el testigo recuperado.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Collar del pozo",
    definicion: "Punto exacto en la superficie donde inicia la perforación del pozo. Define la coordenada de referencia (Desde: 0.00 m) para todos los cálculos de profundidad.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Diámetro de perforación",
    definicion: "Tamaño del hoyo perforado definido por la serie de la herramienta. Los más comunes son: NQ (47.6 mm), HQ (63.5 mm) y PQ (83.0 mm). A mayor diámetro, mayor peso del testigo.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Serie NQ",
    definicion: "Serie de herramientas de perforación diamantina con diámetro de corona de 75.7 mm y testigo de 47.6 mm. Es la serie más usada en exploración geológica minera.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Serie HQ",
    definicion: "Serie de herramientas de perforación diamantina con diámetro de corona de 96 mm y testigo de 63.5 mm. Se usa cuando se requiere mayor volumen de muestra.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Serie PQ",
    definicion: "La serie de mayor diámetro (testigo de 83.0 mm). Se usa generalmente en los primeros metros del pozo o cuando la empresa requiere un testigo de gran diámetro para pruebas metalúrgicas.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Eje del testigo",
    definicion: "Línea imaginaria central longitudinal de la muestra cilíndrica. Es la referencia para orientar las marcas de regularización y para el análisis geológico estructural.",
    categoria: "📐 Medición y Cálculo",
  ),
  TerminoGlosario(
    termino: "Recuperación acumulada",
    definicion: "Suma de los testigos recuperados en todas las corridas hasta la profundidad actual del pozo. Sirve como indicador de la calidad operacional general del sondaje.",
    categoria: "📐 Medición y Cálculo",
  ),

  // ─── 🪨 GEOLOGÍA DEL TERRENO ─────────────────────────────────────────────
  TerminoGlosario(
    termino: "Testigo de roca",
    definicion: "Muestra cilíndrica continua de roca extraída durante la perforación. Es el producto principal del sondaje diamantino y la base del análisis geológico y geoquímico.",
    categoria: "🪨 Geología del Terreno",
  ),
  TerminoGlosario(
    termino: "Testigo molido",
    definicion: "Testigo reducido a fragmentos o polvo por la acción de la corona o por la fracturación extrema de la roca. Se guarda en bolsas transparentes rotuladas y NO se desecha.",
    categoria: "🪨 Geología del Terreno",
  ),
  TerminoGlosario(
    termino: "Veta",
    definicion: "Concentración mineral de forma tabular alojada en fracturas o zonas de debilidad de la roca. Es el objetivo geológico principal en muchos proyectos de exploración.",
    categoria: "🪨 Geología del Terreno",
  ),
  TerminoGlosario(
    termino: "Mineralización",
    definicion: "Presencia de minerales de interés económico (cobre, oro, plata, molibdeno, etc.) en la roca. Su identificación visual es una de las tareas del controlador durante el manejo del testigo.",
    categoria: "🪨 Geología del Terreno",
  ),
  TerminoGlosario(
    termino: "Zona de cizalle",
    definicion: "Zona de la roca deformada por movimientos tectónicos que produce un material altamente fracturado, foliado o pulverizado. Suele generar baja recuperación de testigo.",
    categoria: "🪨 Geología del Terreno",
  ),
  TerminoGlosario(
    termino: "Fracturación",
    definicion: "Grado de fragmentación natural de la roca. Alta fracturación implica menor recuperación de testigo, mayor riesgo de colapso del pozo y uso preferente de barril corto.",
    categoria: "🪨 Geología del Terreno",
  ),
  TerminoGlosario(
    termino: "Roca competente",
    definicion: "Roca masiva, dura y sin fracturación significativa. En roca competente se obtiene alta recuperación de testigo y se puede usar barril largo con corridas de hasta 3.00 m.",
    categoria: "🪨 Geología del Terreno",
  ),
  TerminoGlosario(
    termino: "Falla geológica",
    definicion: "Plano de fractura en la roca por donde ha ocurrido desplazamiento entre los bloques. Genera zonas de debilidad, testigo de mala calidad y posible pérdida del fluido de perforación.",
    categoria: "🪨 Geología del Terreno",
  ),
  TerminoGlosario(
    termino: "Pérdida de testigo",
    definicion: "Diferencia entre los metros perforados y el testigo efectivamente recuperado en una corrida. Puede ocurrir por fracturación extrema, caída del testigo o falla operacional.",
    categoria: "🪨 Geología del Terreno",
  ),
  TerminoGlosario(
    termino: "Sondaje Diamantino (DDH)",
    definicion: "Método de perforación que utiliza coronas diamantadas para extraer muestras cilíndricas continuas de roca (testigos). Es el estándar en exploración minera geológica.",
    categoria: "🪨 Geología del Terreno",
  ),

  // ─── 📄 DOCUMENTACIÓN Y SEGURIDAD ────────────────────────────────────────
  TerminoGlosario(
    termino: "ART (Análisis de Riesgo del Trabajo)",
    definicion: "Documento de evaluación de riesgos que debe completarse antes de iniciar cualquier actividad en terreno. Identifica los peligros, consecuencias y medidas de control de cada tarea.",
    categoria: "📄 Documentación y Seguridad",
  ),
  TerminoGlosario(
    termino: "ARTP Control",
    definicion: "Versión extendida del ART diseñada específicamente para el Control de Sondaje. Incluye análisis de peligros propios del manejo de testigo, trabajos en altura y uso de wire line.",
    categoria: "📄 Documentación y Seguridad",
  ),
  TerminoGlosario(
    termino: "Cartilla CERC",
    definicion: "Control de Eventos de Riesgo Crítico. Listado de verificación de salvaguardas obligatorias en las tareas con mayor potencial de fatalidad o lesión grave en el área de sondaje.",
    categoria: "📄 Documentación y Seguridad",
  ),
  TerminoGlosario(
    termino: "Checklist EPR",
    definicion: "Lista de verificación del Equipo de Protección Respiratoria. Confirma que los protectores respiratorios están en buen estado, tienen los filtros correctos y son usados por el personal.",
    categoria: "📄 Documentación y Seguridad",
  ),
  TerminoGlosario(
    termino: "Checklist EPA",
    definicion: "Lista de verificación del Equipo de Protección Auditiva. Confirma el uso correcto de protectores auditivos (fonos o tapones) en las áreas de alto nivel de ruido de la faena.",
    categoria: "📄 Documentación y Seguridad",
  ),
  TerminoGlosario(
    termino: "EPP (Equipo de Protección Personal)",
    definicion: "Conjunto de elementos de protección individual obligatorios en terreno: casco, lentes con protección lateral, guantes de impacto, zapatos de seguridad con puntera de acero y chaleco reflectante.",
    categoria: "📄 Documentación y Seguridad",
  ),
  TerminoGlosario(
    termino: "HDS (Hoja de Datos de Seguridad)",
    definicion: "Ficha técnica de cada producto químico utilizado en faena (lodos, Ez-Mud, aceites). Detalla composición, riesgos de salud, primeros auxilios, almacenamiento y manejo seguro.",
    categoria: "📄 Documentación y Seguridad",
  ),
  TerminoGlosario(
    termino: "Permiso de Trabajo en Caliente",
    definicion: "Autorización formal requerida antes de realizar trabajos que generen fuentes de ignición (soldadura, amolado, corte) en zonas con materiales inflamables o en la plataforma de sondaje.",
    categoria: "📄 Documentación y Seguridad",
  ),
  TerminoGlosario(
    termino: "Planilla de Control de Sondaje",
    definicion: "Documento oficial de registro por corrida donde el controlador anota: Desde, Hasta, metros perforados, largo de testigo recuperado, % recuperación, observaciones geológicas y datos de la sarta.",
    categoria: "📄 Documentación y Seguridad",
  ),
  TerminoGlosario(
    termino: "Rotulación de bandejas",
    definicion: "Proceso de marcar en forma indeleble cada bandeja porta testigo con: nombre del pozo, número de caja, metraje Desde-Hasta y flecha indicando el sentido de avance de la perforación.",
    categoria: "📄 Documentación y Seguridad",
  ),
  TerminoGlosario(
    termino: "Trabajos cruzados",
    definicion: "Permiso especial que se emite cuando dos o más grupos de trabajo coinciden en la misma área. Requiere coordinación entre supervisores para evitar interferencias y accidentes.",
    categoria: "📄 Documentación y Seguridad",
  ),
  TerminoGlosario(
    termino: "LOTO (Lockout-Tagout)",
    definicion: "Sistema de bloqueo con candado y tarjeta de seguridad personal que se aplica en mantención de equipos para asegurar que la máquina no pueda ser encendida por error durante el trabajo.",
    categoria: "📄 Documentación y Seguridad",
  ),

  // ─── 💧 FLUIDOS Y LODOS ──────────────────────────────────────────────────
  TerminoGlosario(
    termino: "Agua de retorno",
    definicion: "Fluido que regresa a la superficie después de circular por el interior de las barras, pasar por la corona y subir por el espacio anular entre la sarta y las paredes del pozo.",
    categoria: "💧 Fluidos y Lodos",
  ),
  TerminoGlosario(
    termino: "Pérdida de retorno",
    definicion: "Situación en que el fluido de perforación deja de regresar a la superficie porque se está filtrando a través de fracturas o cavidades del terreno. Es una de las fallas más frecuentes en faena.",
    categoria: "💧 Fluidos y Lodos",
  ),
  TerminoGlosario(
    termino: "Lodo de perforación",
    definicion: "Mezcla de agua con aditivos (polímeros, bentonita, Ez-Mud) que se inyecta al pozo para lubricar la corona, estabilizar las paredes, refrigerar las herramientas y extraer el detritus.",
    categoria: "💧 Fluidos y Lodos",
  ),
  TerminoGlosario(
    termino: "Ez-Mud (polímero)",
    definicion: "Aditivo polimérico soluble en agua utilizado para estabilizar paredes del pozo en terrenos sueltos o fracturados. Reduce la pérdida de fluido y mejora la lubricación.",
    categoria: "💧 Fluidos y Lodos",
  ),
  TerminoGlosario(
    termino: "Viscosidad del lodo",
    definicion: "Propiedad del fluido de perforación que determina su resistencia al flujo. Se mide con un embudo Marsh. Lodo muy viscoso puede atascar la sarta; muy fluido no arrastra el detritus.",
    categoria: "💧 Fluidos y Lodos",
  ),
  TerminoGlosario(
    termino: "Caudal de agua",
    definicion: "Volumen de fluido bombeado por unidad de tiempo (litros por minuto). Es un parámetro operacional crítico que el controlador debe monitorear durante la perforación.",
    categoria: "💧 Fluidos y Lodos",
  ),
  TerminoGlosario(
    termino: "Presión hidráulica",
    definicion: "Fuerza ejercida por el fluido de perforación medida en el manómetro (bar o psi). Variaciones bruscas de presión indican posibles atascamientos, pérdida de fluido o falla de corona.",
    categoria: "💧 Fluidos y Lodos",
  ),
  TerminoGlosario(
    termino: "Soluble Oil",
    definicion: "Lubricante soluble en agua que se agrega al fluido de perforación para reducir la fricción entre la sarta y las paredes del pozo. Ayuda a prevenir el atascamiento en tramos largos.",
    categoria: "💧 Fluidos y Lodos",
  ),
  TerminoGlosario(
    termino: "Detritus",
    definicion: "Material triturado por la corona que el fluido de perforación transporta desde el fondo del pozo hacia la superficie a través del espacio anular.",
    categoria: "💧 Fluidos y Lodos",
  ),
];
