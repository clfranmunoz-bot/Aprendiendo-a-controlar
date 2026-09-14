class ChatbotKnowledgeService {
  // Red amplia de sinónimos y jerga operacional de perforación diamantina (DDH)
  static const Map<String, String> _synonyms = {
    'largo': 'medida',
    'distancia': 'medida',
    'metros': 'medida',
    'metraje': 'medida',
    'dimension': 'medida',
    'tamano': 'medida',
    'cuanto': 'medida',

    'tubo': 'barra',
    'caneria': 'barra',
    'cañeria': 'barra',
    'varilla': 'barra',
    'barras': 'barra',

    'tomamuestra': 'barril',
    'tomamuestras': 'barril',
    'barriles': 'barril',
    'tubo interior': 'barril',
    'tubo externo': 'barril',

    'instructivo': 'procedimiento',
    'instructivos': 'procedimiento',
    'norma': 'procedimiento',
    'normas': 'procedimiento',
    'reglamento': 'procedimiento',
    'protocolo': 'procedimiento',
    'protocolos': 'procedimiento',
    'manual': 'procedimiento',
    'guia': 'procedimiento',
    'pasos': 'procedimiento',

    'papel': 'documento',
    'papeles': 'documento',
    'archivo': 'documento',
    'archivos': 'documento',
    'formato': 'documento',
    'registro': 'documento',
    'registros': 'documento',
    'permiso': 'documento',
    'permisos': 'documento',
    'ficha': 'documento',
    'cartilla': 'documento',

    'falla': 'problema',
    'fallas': 'problema',
    'atascado': 'problema',
    'atrapado': 'problema',
    'quemado': 'problema',
    'molido': 'problema',
    'perdio': 'problema',
    'perdida': 'problema',
    'baja': 'problema',
    'caida': 'problema',
    'error': 'problema',
    'fatigado': 'fatiga',
    'somnolencia': 'fatiga',
    'sueno': 'fatiga',
    'cansancio': 'fatiga',
    'microsueno': 'fatiga',
    'velocidades': 'velocidad',
    'rapido': 'velocidad',
    'limite': 'velocidad',
    'kmh': 'velocidad',
    'seguro': 'seguridad',
    'epp': 'seguridad',
    'riesgo': 'seguridad',
    'riesgos': 'seguridad',
    'pee': 'emergencia',
    'evacuacion': 'emergencia',
    'pesa': 'peso',
    'pesan': 'peso',
    'pesado': 'peso',
    'kilos': 'peso',
    'kilo': 'peso',
    'kg': 'peso',
    'kgs': 'peso',
    'tonelada': 'peso',
    'toneladas': 'peso',
    'tonelaje': 'peso',
    'carga': 'peso',
  };

  static final List<Map<String, dynamic>> _knowledgeBase = [
    // 1. CÁLCULO DE CONTRA Y FORMULAS
    {
      "intent": "formula_contra",
      "keywords": ["contra", "sobrante", "acoplar", "adicion", "ajustada", "calculo contra"],
      "question": "¿Cómo se calcula la contra?",
      "response": "🧮 **FÓRMULA Y PROCEDIMIENTO DE CONTRA**\n\n"
          "• **Sin adición de barra (Perforación normal):**\n"
          r"$$\text{Contra} = \text{Contra Anterior} - \text{Perforado}$$" "\n\n"
          "• **Con adición de barra (Contra Ajustada):**\n"
          r"1. $$\text{Contra Ajustada} = \text{Contra Anterior} + \text{Largo de Barra (3.00m)}$$" "\n"
          r"2. $$\text{Nueva Contra} = \text{Contra Ajustada} - \text{Perforado}$$" "\n\n"
          "💡 Tip: Puedes pedirme un cálculo en vivo escribiendo por ejemplo:\n"
          "'Contra anterior 0.80, agregué barra de 3.00 y perforé 1.50'",
      "navRoute": "calculadoras",
      "navLabel": "🧮 Abrir Calculadora Operacional",
    },

    // 2. RECUPERACIÓN Y PORCENTAJE
    {
      "intent": "formula_recuperacion",
      "keywords": ["recuperacion", "porcentaje", "rec", "testigo", "porcentaje recuperacion", "perdida testigo"],
      "question": "¿Cómo se calcula el porcentaje de recuperación?",
      "response": "📊 **FÓRMULA DE RECUPERACIÓN DE TESTIGO (%REC)**\n\n"
          r"$$\%\text{Rec} = rac{\text{Testigo Recuperado (m)}}{\text{Perforado (m)}} \times 100$$" "\n\n"
          "• **Ejemplo:** Si perforaste **1.50 m** y el testigo en la bandeja mide **1.42 m**:\n"
          r"$$\%\text{Rec} = rac{1.42}{1.50} \times 100 = 94.67\%$$" "\n\n"
          "⚠️ **Criterio de Castigo:** Si %Rec < 95%, se considera pérdida parcial de muestra. Debes colocar un marcador de profundidad/taco de madera con la pérdida exacta (0.08 m).",
      "navRoute": "calculadoras",
      "navLabel": "🧮 Abrir Calculadoras",
    },

    // 3. FONDO DEL POZO
    {
      "intent": "formula_fondo",
      "keywords": ["fondo", "profundidad", "cota", "metros pozo", "profundidad total"],
      "question": "¿Cómo se calcula el fondo del pozo?",
      "response": "📐 **FÓRMULA DE FONDO DEL POZO**\n\n"
          "Existen 2 formas de verificar el fondo del pozo:\n\n"
          "1. **Por avance acumulado:**\n"
          r"$$\text{Fondo Nuevo} = \text{Fondo Anterior} + \text{Perforado}$$" "\n\n"
          "2. **Por Herramientas en pozo:**\n"
          r"$$\text{Fondo} = \text{Herramientas Totales} - \text{Contra}$$" "\n\n"
          "💡 Ambos métodos deben coincidir exactamente.* Si hay diferencia, revisa la cuenta de barras o el punto muerto.",
      "navRoute": "calculadoras",
      "navLabel": "🧮 Ir a Calculadora de Fondo",
    },

    // 4. METRAJES DE BARRAS
    {
      "intent": "barra",
      "keywords": ["barra", "barras", "tubo", "cañeria", "varilla", "largo barra"],
      "question": "¿Cuánto mide una barra de perforación?",
      "response": "📏 **METRAJE DE BARRAS DE PERFORACIÓN**\n\n"
          "• **Barra estándar DDH:** **3.00 metros** (2.90 m a 3.00 m según serie HQ / NQ / PQ).\n"
          "• **Barra corta / de ajuste:** **1.50 metros** (usada para ajustes de carrera o embocado).\n\n"
          "⚠️ Importante: Verifica siempre con huincha la medida real del hilo a hilo antes de acoplar a la sarta.",
    },

    // 5. BARRIL CORTO Y LARGO
    {
      "intent": "barril",
      "keywords": ["barril", "barril corto", "barril largo", "tomamuestra", "tubo interior", "carro"],
      "question": "¿Cuánto miden los barriles tomamuestras?",
      "response": "📦 **METRAJES DE BARRILES TOMAMUESTRAS**\n\n"
          "• **Barril Largo Estándar:** **4.15 metros** (diseñado para alojar tubos interiores de 3.00 m de roca).\n"
          "• **Barril Corto:** **2.60 metros** (usado en terrenos muy fracturados o inicios de pozo para carreras de 1.50 m).\n"
          "• **Extensión Reflex (Orientador):** **+0.40 metros**.\n\n"
          "💡 Recuerda sumar la extensión Reflex a la sarta si estás usando orientador de núcleo.*",
      "navRoute": "glosario",
      "navLabel": "📚 Ver Esquema de Herramientas",
    },

    // 6. PUNTO MUERTO
    {
      "intent": "puntomuerto",
      "keywords": ["punto muerto", "pm", "marca cabezal", "referencia"],
      "question": "¿Qué es y cuánto mide el Punto Muerto (PM)?",
      "response": "📍 **PUNTO MUERTO (PM)**\n\n"
          "El **Punto Muerto** es la distancia fija desde el nivel del suelo (o borde de la boca del pozo) hasta la marca cero de lectura en el cabezal de rotación.\n\n"
          "• **Medida típica:** Varía entre **0.40 m y 0.60 m** según el modelo de la máquina sondeadora.\n"
          "• **Aplicación:** Se resta a la sarta total para calcular el fondo real disponible.\n"
          r"$$\text{Herr} = (\text{Barras} \times 3.00) + \text{Barril} + \text{Reflex} - \text{PM}$$",
    },

    // 7. DIAGNÓSTICO: TESTIGO QUEMADO O MOLIDO
    {
      "intent": "problema_testigo_quemado",
      "keywords": ["quemado", "molido", "destruido", "testigo rotulo", "roca moliendo", "recalentado"],
      "question": "¿Por qué el testigo viene quemado o molido y qué hacer?",
      "response": "🚨 **DIAGNÓSTICO: TESTIGO QUEMADO O MOLIDO**\n\n"
          "**Causas probables:**\n"
          "1. **Falta de fluido de agua:** El flujo de agua en la corona no es suficiente para enfriar y limpiar la muestra.\n"
          "2. **Avance excesivo con presión baja:** Forzar la rotación cuando el tubo interior está bloqueado.\n"
          "3. **Corona tapada / atascada:** Trozo de roca fracturada trabó la entrada del tubo interior.\n\n"
          "**Acción inmediata de terreno:**\n"
          "1. 🛑 Detén la rotación inmediatamente.\n"
          "2. 💦 Aumenta el caudal de bomba y verifica el retorno de fluido.\n"
          "3. 🎣 Saca el tubo interior con el overshot/pescador para inspeccionar el portatestigo y resorte trampa.\n"
          "4. 📄 Registra el metraje exacto donde ocurrió la molienda en el reporte.",
      "navRoute": "checklist_turno",
      "navLabel": "📋 Ver Protocolo en Checklist",
    },

    // 8. DIAGNÓSTICO: PÉRDIDA DE RETORNO DE FLUIDO DE AGUA
    {
      "intent": "problema_perdida_retorno",
      "keywords": ["perdida agua", "sin retorno", "se fue el agua", "pozo chupando", "sin fluido", "retorno cero"],
      "question": "¿Qué hacer si hay pérdida total o parcial del retorno de agua?",
      "response": "🚨 **DIAGNÓSTICO: PÉRDIDA DE RETORNO DE AGUA**\n\n"
          "**Causas probables:**\n"
          "1. La perforación cortó una falla, falla abierta, falla geológica o cavidad en la roca.\n"
          "2. Pérdida de sello en las paredes del pozo.\n\n"
          "**Acción inmediata de terreno:**\n"
          "1. ⚠️ **No avances sin agua:** Perforar en seco quemará la corona diamantada y atrapará la sarta.\n"
          "2. 🧪 **Prepara lodo con polímero / bentonita:** Agrega viscosante a la piscina para sellar las fracturas del pozo.\n"
          "3. ⏱️ Si la pérdida es total, informa de inmediato al Supervisor para evaluar aplicar producto obturante o cementación del tramo.",
      "navRoute": "recordatorios",
      "navLabel": "⏰ Crear Alarma de Control de Agua",
    },

    // 9. DIAGNÓSTICO: OVERSHOT / PESCADOR NO ENGANCHA
    {
      "intent": "problema_overshot",
      "keywords": ["overshot", "pescador", "no engancha", "tubo suelto", "no saca tubo", "huinche"],
      "question": "¿Qué hacer si el overshot / pescador no engancha el tubo interior?",
      "response": "🚨 **DIAGNÓSTICO: OVERSHOT NO ENGANCHA EL TUBO**\n\n"
          "**Causas probables:**\n"
          "1. Lodo/sedimento acumulado sobre la cabeza del cabezal de pesca.\n"
          "2. Perros/gatillos del overshot desgastados o sin tensión en el resorte.\n"
          "3. El tubo interior no bajó hasta el fondo (se quedó colgado).\n\n"
          "**Acción inmediata:**\n"
          "1. 🎣 Levanta el overshot 5 metros y déjalo caer libremente con agua en bombeo para lavar la cabeza de pesca.\n"
          "2. 🔍 Si persiste, saca el overshot a superficie y revisa la tensión de los pernos y mordazas.\n"
          "3. ❌ Nunca tires con exceso de tonelaje del cable de huinche para evitar cortarlo.",
    },

    // 10. DIAGNÓSTICO: CAÍDA REPENTINA DE PRESIÓN DE AGUA
    {
      "intent": "problema_presion_agua",
      "keywords": ["caida presion", "bomba agua", "sin presion", "presion cero", "manguera", "presion baja"],
      "question": "¿Por qué cae la presión de agua bruscamente?",
      "response": "🚨 **DIAGNÓSTICO: CAÍDA BRUSCA DE PRESIÓN DE AGUA**\n\n"
          "**Causas probables:**\n"
          "1. **Desacople en la sarta:** Una barra se desatornilló o se cortó en el pozo.\n"
          "2. **Falla en swivel de agua / prensa empaque:** Pérdida por sellos gastados.\n"
          "3. **Fuga en mangueras de alta presión** o válvula de alivio activada en la bomba.\n\n"
          "**Acción inmediata:**\n"
          "1. Detén el motor de rotación.\n"
          "2. Inspecciona las conexiones de superficie y la bomba Tríplex.\n"
          "3. Si la superficie está bien, verifica el peso en el manómetro para comprobar la integridad de la sarta.",
    },

    // 11. ROTULACIÓN Y MARCADORES DE BANDEJAS
    {
      "intent": "rotulacion_cajas",
      "keywords": ["caja", "cajas", "bandeja", "bandejas", "rotular", "rotulacion", "taco", "tacos", "marcador"],
      "question": "¿Cómo se rotulan las cajas porta-testigos y se colocan tacos?",
      "response": "🏷️ **NORMAS DE ROTULACIÓN DE CAJAS Y TACOS**\n\n"
          "1. **Datos de portada en la caja:**\n"
          "   • Nombre del Proyecto / Sondeo (Ej: DDH-2026-04)\n"
          "   • Número de Caja correlativo (Ej: Caja N° 12)\n"
          "   • Desde Metros ➔ Hasta Metros del tramo.\n\n"
          "2. **Colocación de tacos de madera / separadores:**\n"
          "   • Se coloca taco blanco al final de cada carrera de perforación marcando la profundidad exacta.\n"
          "   • Si hay **pérdida de testigo**, se inserta taco rojo/marcado con la cantidad de metros perdidos.\n"
          "   • Dirección del testigo: De izquierda a derecha y de arriba a abajo en los canales de la bandeja.",
    },

    // 12. SERIES DIAMANTINAS (HQ, NQ, PQ)
    {
      "intent": "series_diamantinas",
      "keywords": ["hq", "nq", "pq", "diametro", "serie", "diamantina", "tamano testigo"],
      "question": "¿Cuáles son los diámetros de la serie HQ, NQ y PQ?",
      "response": "💎 **DIÁMETROS DE PERFORACIÓN Y TESTIGO (SERIE Q)**\n\n"
          "• **Serie PQ (Diámetro mayor):**\n"
          "  - Diámetro Pozo: **122.6 mm** | Testigo: **85.0 mm** (3.345 pulg)\n"
          "  - Usado en inicios de pozo o aluviales.\n\n"
          "• **Serie HQ (Estándar habitual):**\n"
          "  - Diámetro Pozo: **96.0 mm** | Testigo: **63.5 mm** (2.500 pulg)\n"
          "  - Diámetro más común en minería diamantina.\n\n"
          "• **Serie NQ (Profundidad):**\n"
          "  - Diámetro Pozo: **75.7 mm** | Testigo: **47.6 mm** (1.875 pulg)\n"
          "  - Usado en tramos profundos para reducir peso de sarta.",
    },

    // 13. DOCUMENTOS OBLIGATORIOS
    {
      "intent": "documentos_obligatorios",
      "keywords": ["documento", "documentos", "obligatorio", "papel", "registro", "permiso", "art", "artp", "cerc", "epr", "epa"],
      "question": "¿Cuáles son los Documentos Obligatorios?",
      "response": "📄 **DOCUMENTOS OBLIGATORIOS REGISTRADOS EN LA APP**\n\n"
          "1. **Permisos:** Trabajos cruzados, Permiso de ingreso al área.\n"
          "2. **Checklists:** EPR (Protección respiratoria), EPA (Protección auditiva), Checklist Herramientas de Mano.\n"
          "3. **Controles:** Cartilla CERC (Eventos de Riesgo Crítico), ARTP (Análisis de Riesgo del Trabajo).",
      "navRoute": "documentos_obligatorios",
      "navLabel": "📄 Abrir Documentos Obligatorios",
    },


    // ==========================================
    // PROCEDIMIENTOS E INSTRUCTIVOS OFICIALES OP (11 DOCUMENTOS)
    // ==========================================

    // OP-1: OPERACIÓN INVIERNO (PE-GM-001)
    {
      "intent": "op_invierno",
      "keywords": ["invierno", "nieve", "pe-gm-001", "viento blanco", "anticongelante", "temperatura", "refugio", "helada"],
      "question": "¿Qué exige el Procedimiento de Operación Invierno (PE-GM-001)?",
      "response": "❄️ **PROCEDIMIENTO OPERACIÓN INVIERNO 2026 (PE-GM-001 V4)**\n\n"
          "• **Vestimenta Obligatoria:** Uso de 3 capas térmicas, parkas térmicas de alta visibilidad, guantes impermeables y calzado con aislamiento.\n"
          "• **Previsión en Equipos:** Verificación diaria de niveles de líquido anticongelante en motores, calentadores de combustible y drenaje de agua en líneas de aire.\n"
          "• **Alertas y Comunicaciones:** En Alerta Naranja/Roja por viento blanco o nevada, se prohíbe el tránsito entre plataformas y se activa la permanencia en refugios climatizados con stock de emergencia para 48 hrs.\n"
          "• **Velocidad Máxima:** Máximo 30 km/h en caminos con nieve/hielo y uso obligatorio de cadenas.",
      "navRoute": "procedimientos_teoricos",
      "navLabel": "📑 Ver Documentos OP en App",
    },

    // OP-2: POSTURA DE CADENAS (PRO-OP-CSO-MLP-03)
    {
      "intent": "op_postura_cadenas",
      "keywords": ["cadenas", "postura cadenas", "pro-op-cso-mlp-03", "arana", "nieve cadenas", "ruedas motrices", "tara"],
      "question": "¿Cómo se instalan las cadenas para nieve según PRO-OP-CSO-MLP-03?",
      "response": "⚙️ **POSTURA Y RETIRO DE CADENAS (PRO-OP-CSO-MLP-03 V06)**\n\n"
          "1. **Ubicación:** Se instalan en las ruedas motrices (eje trasero en 4x2 / 4 ruedas en 4x4 si la pendiente > 15%).\n"
          "2. **Procedimiento de Colocación:** Estender la cadena recta sin torceduras, avanzar el vehículo 50 cm sobre ella, enganchar la traba interior y luego el gancho exterior.\n"
          "3. **Tensión:** Colocar el pulpo/araña elástica tensora de seguridad.\n"
          "4. **Revisión Obligatoria:** Avanzar 50 a 100 metros, detenerse en zona segura y volver a re-tensar la cadena.\n"
          "5. **Velocidad Máxima:** No superar jamás los **30 km/h** con cadenas instaladas. Retirar inmediatamente al ingresar a pavimento seco.",
      "navRoute": "procedimientos_teoricos",
      "navLabel": "📑 Ver Procedimiento de Cadenas",
    },

    // OP-3: GYRO MASTER (PRO-OP-GEO-MLP-01)
    {
      "intent": "op_gyro_master",
      "keywords": ["gyro master", "giroscopio master", "trayectoria continuo", "pro-op-geo-mlp-01", "azimut continuo"],
      "question": "¿Cómo funciona la medición con Gyro Master (PRO-OP-GEO-MLP-01)?",
      "response": "🧭 **MEDICIÓN DE TRAYECTORIA GYRO MASTER (PRO-OP-GEO-MLP-01 V01)**\n\n"
          "• **Tecnología:** Giroscopio continuo de alta precisión no magnético (no le afectan rocas magnetizadas o hierro).\n"
          "• **Punto de Referencia Inicial:** Alineación de superficie (Surface Alignment) usando estacas geotécnicas u orientador óptico de azimut.\n"
          "• **Velocidad de Bajada:** Máximo 15 a 20 metros por minuto en bajada continua.\n"
          "• **Control de Calidad (QC):** Se compara la medición de bajada (Inrun) con la de subida (Outrun); la diferencia de posición final debe ser menor a 0.5% de la profundidad total del pozo.",
      "navRoute": "procedimientos_teoricos",
      "navLabel": "📑 Ver Manual Gyro Master",
    },

    // OP-4: OMNIX 42 (PRO-OP-GEO-MLP-01)
    {
      "intent": "op_omnix_42",
      "keywords": ["omnix 42", "omnix", "giroscopio omnix", "medicion desvio", "inclinacion omnix"],
      "question": "¿Qué establece el procedimiento para Giroscopio OMNIX 42?",
      "response": "📊 **MEDICIÓN DE TRAYECTORIA OMNIX 42 (PRO-OP-GEO-MLP-01 V07)**\n\n"
          "• **Modo de Operación:** Registro por estaciones discontinuas (multishot o single shot) a intervalos regulares (ej. cada 5m o 10m).\n"
          "• **Sincronización:** Calibración del tiempo del reloj interno de la sonda con la consola antes de iniciar la corrida en pozo.\n"
          "• **Parada por Estación:** Mantener la sonda inmóvil durante 15 a 30 segundos en cada punto de lectura para estabilizar los sensores de inclinación y azimut.",
    },

    // OP-5: GYRO FINDER (PRO-OP-GEO-MLP-02)
    {
      "intent": "op_gyro_finder",
      "keywords": ["gyro finder", "finder", "pro-op-geo-mlp-02", "medicion desvio finder"],
      "question": "¿Qué indica el procedimiento Gyro Finder (PRO-OP-GEO-MLP-02)?",
      "response": "🔍 **MEDICIÓN DE SONDAJE GYRO FINDER (PRO-OP-GEO-MLP-02)**\n\n"
          "• **Sistemas de bajada:** Soporta modo Drop (dejado caer libre dentro del tubo antes de sacar sarta) o Wireline (con huinche cable de acero).\n"
          "• **Verificación previa:** Chequeo de voltaje de batería > 3.6V y sello tórico (O-Ring) lubricado y en perfecto estado para evitar filtración de fluido a alta presión de pozo.",
    },

    // OP-6: CASETA GEOATACAMA (PRO-OP-MLP-08)
    {
      "intent": "op_caseta_geoatacama",
      "keywords": ["caseta", "caseta geoatacama", "pro-op-mlp-08", "vientos caseta", "extintor caseta", "generador caseta"],
      "question": "¿Cuáles son las normas de traslado y uso de la caseta de sondaje (PRO-OP-MLP-08)?",
      "response": "🏠 **TRASLADO Y USO DE CASETA GEOATACAMA (PRO-OP-MLP-08 V09)**\n\n"
          "• **Instalación y Nivelación:** La caseta debe quedar sobre suelo firme compactado y nivelada con gatas mecánicas / cuñas de madera duras.\n"
          "• **Vientos de Amarre:** Fijación obligatoria con 4 vientos de cable de acero instalados en los esquinales hacia estacas/anclajes de terreno para resistir ráfagas de viento > 70 km/h.\n"
          "• **Seguridad Eléctrica y Fuego:** Extintor PQS de 10 kg cargado al día cerca de la puerta, barra a tierra conectada al generador eléctrico y luz de emergencia operacional.",
      "navRoute": "procedimientos_teoricos",
      "navLabel": "📑 Ver Procedimiento Caseta",
    },

    // OP-7: CONDUCCIÓN VEHÍCULO LIVIANO 4X4 (PRO-OP-MLP-CS-02)
    {
      "intent": "op_conduccion_4x4",
      "keywords": ["conduccion", "vehiculo liviano", "4x4", "traccion 4h", "traccion 4l", "pro-op-mlp-cs-02", "fatiga", "frenado"],
      "question": "¿Cuáles son los estándares de conducción 4x4 en mina (PRO-OP-MLP-CS-02)?",
      "response": "🛻 **CONDUCCIÓN DE VEHÍCULO LIVIANO 4X4 (PRO-OP-MLP-CS-02 V15)**\n\n"
          "• **Tracción Obligatoria:** Tracción **4H** activada en todos los caminos no pavimentados de la mina. Usar **4L (Reducida)** en bajadas pronunciadas o barro/nieve sin abusar del freno de pie.\n"
          "• **Revisión Pre-Uso (Checklist 360°):** Neumáticos de repuesto cargados, niveles de aceite/agua, frenos, pértiga con luz encendida y baliza destellante.\n"
          "• **Control de Fatiga:** Detención obligatoria de 15 minutos para descanso tras 2 horas continuas de conducción o ante cualquier síntoma de somnolencia.",
      "navRoute": "procedimientos_teoricos",
      "navLabel": "📑 Ver Procedimiento Conducción",
    },

    // OP-8: CONTROL OPERACIONAL SONDAJE DIAMANTINO (PRO-OP-MLP-CS-07)
    {
      "intent": "op_control_sondaje",
      "keywords": ["control operacional", "sondaje diamantino", "pro-op-mlp-cs-07", "carrera", "perforacion diamantina"],
      "question": "¿Qué exige el Procedimiento Principal de Sondaje Diamantino (PRO-OP-MLP-CS-07)?",
      "response": "💎 **CONTROL OPERACIONAL DE SONDAJE DIAMANTINO (PRO-OP-MLP-CS-07 V11)**\n\n"
          "Este es el **procedimiento pilar** de la plataforma:\n"
          "1. **Supervisión de Sarta:** Medición exacta con huincha metálica de cada barra ingresada al pozo.\n"
          "2. **Control de Carrera:** Verificación de carrera libre del tubo interior (3.00m o 1.50m) antes de perforar.\n"
          "3. **Extracción y Lavado:** Extraer el testigo con cuidado, lavar el barro suavemente para no alterar las fracturas naturales y disponer en la bandeja porta-testigo de izquierda a derecha.\n"
          "4. **Medición de Recuperación:** Medir con regla/huincha el testigo recuperado e insertar tacos de profundidad.",
      "navRoute": "checklist_turno",
      "navLabel": "📋 Ver Paso a Paso en Turno",
    },

    // OP-9: MAPEO GEOTÉCNICO Y RQD (PRO-OP-MLP-CS-10)
    {
      "intent": "op_mapeo_geotecnico_rqd",
      "keywords": ["geotecnico", "mapeo", "rqd", "pro-op-mlp-cs-10", "orientado", "linea guia", "alfa", "beta", "macizo rocoso"],
      "question": "¿Cómo se realiza el Mapeo Geotécnico y cálculo de RQD (PRO-OP-MLP-CS-10)?",
      "response": "📐 **MAPEO GEOTÉCNICO Y RQD (PRO-OP-MLP-CS-10 V7)**\n\n"
          "• **Cálculo de RQD (Rock Quality Designation):**\n"
          r"$$	ext{RQD \%} = rac{\sum 	ext{Trozos de testigo } \ge 10\,	ext{cm}}{	ext{Largo de Carrera Total (m)}} 	imes 100$$" "\n\n"
          "• **Línea de Referencia Orientada:** Unir las marcas de la extensión Reflex trazando una línea recta continua con crayón sobre el lomo del testigo.\n"
          "• **Medición de Estructuras:** Registrar el ángulo Alfa (α - inclinación de la falla respecto al eje del testigo) y Beta (β - rotación horaria respecto a la línea guía).",
      "navRoute": "calculadoras",
      "navLabel": "🧮 Abrir Calculadoras",
    },

    // OP-10: REGLAMENTO CLIMA ADVERSO Y ALERTAS (RO-GR-OPI-001)
    {
      "intent": "op_clima_adverso",
      "keywords": ["clima adverso", "ro-gr-opi-001", "alerta amarilla", "alerta naranja", "alerta roja", "rayos", "tormenta electrica", "viento"],
      "question": "¿Cuáles son las Alertas por Clima Adverso (RO-GR-OPI-001)?",
      "response": "🌩️ **REGLAMENTO DE CONDICIONES CLIMÁTICAS ADVERSAS (RO-GR-OPI-001 V10)**\n\n"
          "• **Niveles de Alerta por Viento:**\n"
          "  - **Alerta Amarilla (50 - 70 km/h):** Precaución, afianzar elementos sueltos en plataforma.\n"
          "  - **Alerta Naranja (70 - 90 km/h):** Prohibido trabajos en altura (armado de torre/castillo) y maniobras con grúa.\n"
          "  - **Alerta Roja (> 90 km/h):** Paralización total de faena y refugio inmediato.\n\n"
          "• **Tormenta Eléctrica (Regla de los 30 Segundos):** Si el intervalo entre el destello del rayo y el sonido del trueno es **menor a 30 segundos** (distancia < 10 km), detener la perforación, bajar el mástil y refugiarse en vehículo/caseta.",
      "navRoute": "procedimientos_teoricos",
      "navLabel": "📑 Ver Reglamento de Clima",
    },

    // OP-11: REGLAMENTO DE AISLACIÓN Y BLOQUEO DE ENERGÍAS (RO-SSO-SEG-005)
    {
      "intent": "op_bloqueo_energias",
      "keywords": ["bloqueo", "aislacion", "ro-sso-seg-005", "candado", "tarjeta roja", "energia cero", "desenergizar", "bloqueo 5 pasos"],
      "question": "¿Cuáles son los 5 Pasos del Bloqueo de Energías (RO-SSO-SEG-005)?",
      "response": "🔒 **REGLAMENTO DE AISLACIÓN Y BLOQUEO DE ENERGÍAS (RO-SSO-SEG-005 V10)**\n\n"
          "Los **5 Pasos Obligatorios de Bloqueo Seguro** antes de intervenir la máquina sondeadora:\n"
          "1. **Identificar:** Identificar todas las fuentes de energía (eléctrica, hidráulica, mecánica, presión acumulada en acumulador de nitrógeno).\n"
          "2. **Informar:** Notificar al operador y personal del área sobre la intervención.\n"
          "3. **Aislar:** Cortar el interruptor principal / disyuntor y cerrar válvulas hidráulicas.\n"
          "4. **Bloquear y Etiquetar:** Instalar tu **Candado Personal de Bloqueo Rojo** + **Tarjeta de Advertencia Personal** en la pinza/mando múltiple.\n"
          "5. **Verificar Energía Cero:** Probar presionar el botón de arranque o accionar mandos para comprobar que el equipo NO se mueve y purgar la presión de mangueras hidráulicas.",
      "navRoute": "documentos_obligatorios",
      "navLabel": "📄 Ver Permisos y Bloqueo",
    },

        // 15. PESO DE CAJAS Y BANDEJAS PORTA-TESTIGOS
    {
      "intent": "peso_caja_bandeja",
      "keywords": ["peso", "pesa", "pesan", "pesado", "kg", "kilos", "peso caja", "peso bandeja", "peso muestra", "cuanto pesa", "carga", "ergonomia", "mmc"],
      "question": "¿Cuánto pesa una caja / bandeja porta-testigo con muestras?",
      "response": "⚖️ **PESO DE CAJAS Y BANDEJAS PORTA-TESTIGOS**\n\n"
          "• **Peso Promedio de Caja Llena (HQ/NQ):** Entre **18 kg y 25 kg** (según la densidad de la roca y la humedad del testigo).\n"
          "• **Límite de Manipulación Manual de Carga (MMC):** Según el estándar de seguridad minera, el límite máximo para levantamiento manual por **1 trabajador es de 25 kg**.\n\n"
          "⚠️ **Regla de Seguridad:** Si la caja con muestras de roca densa (ej. sulfuros masivos o magnetita) supera los 25 kg, es **obligatorio realizar el levantamiento entre 2 trabajadores** o usar mesas transportadoras de polines para evitar lesiones lumbares.",
    },

    // 16. PESO DE BARRAS Y SARTA TOTAL
    {
      "intent": "peso_barras_sarta",
      "keywords": ["peso barra", "cuanto pesa barra", "peso sarta", "peso hq", "peso nq", "peso pq", "tonelaje sarta", "tonelaje pozo"],
      "question": "¿Cuánto pesan las barras de perforación y la sarta?",
      "response": "⚖️ **PESOS DE BARRAS DE PERFORACIÓN (SERIE Q)**\n\n"
          "• **Barra HQ (3.00 m):** Aprox. **25 kg** por barra.\n"
          "• **Barra NQ (3.00 m):** Aprox. **19 kg** por barra.\n"
          "• **Barra PQ (3.00 m):** Aprox. **38 kg** por barra.\n\n"
          "💡 **Ejemplo de Peso de Sarta en Pozo:**\n"
          "Si la sarta tiene **50 barras HQ (150 metros de pozo)**:\n"
          r"$$	ext{Peso Total Sarta} = 50 	imes 25\,	ext{kg} = 1.250\,	ext{kg} = 1.25\,	ext{toneladas}$$",
    },

        // 17. CONTROL DE FATIGA Y SOMNOLENCIA (PRO-OP-MLP-CS-02 / SSO)
    {
      "intent": "control_de_fatiga",
      "keywords": ["control de fatiga", "fatiga", "somnolencia", "sueno", "cansancio", "pausa activa", "descanso", "microsueno", "que es el control de fatiga"],
      "question": "¿En qué consiste el Control de Fatiga y Somnolencia en conducción y faena?",
      "response": "😴 **ESTÁNDAR DE CONTROL DE FATIGA Y SOMNOLENCIA**\n\n"
          "• **Detención Obligatoria por Conducción:** Detener la marcha 15 minutos obligatorios para descanso y pausa activa tras **2 horas continuas de conducción** en caminos de faena.\n"
          "• **Identificación de Síntomas:** Parpadeo pesado, bostezos frecuentes, pérdida de foco visual o desvío involuntario del carril.\n"
          "• **Procedimiento de Seguridad:** Informar inmediatamente al supervisor directo, detener el vehículo o la máquina en lugar seguro y solicitar relevo o pausa sin temor a sanción.\n"
          "• **Verificación Pre-Turno:** Declarar en la encuesta de fatiga horas reales de sueño nocturno (mínimo 7 horas recomendadas).",
      "navRoute": "procedimientos_teoricos",
      "navLabel": "📑 Ver Procedimiento de Conducción y Fatiga",
    },

    // 18. VELOCIDADES MÁXIMAS EN MINA (PRO-OP-MLP-CS-02 / PE-GM-001)
    {
      "intent": "velocidad_maxima_mina",
      "keywords": ["velocidad maxima", "velocidad", "limite velocidad", "km h", "velocidad mina", "conducir velocidad", "velocidad maxima en la mina"],
      "question": "¿Cuál es la velocidad máxima de conducción en mina y plataformas?",
      "response": "🚗 **MÁXIMOS DE VELOCIDAD DE CONDUCCIÓN EN MINA**\n\n"
          "• **Con Cadenas de Nieve Instaladas:** Máximo **30 km/h** en cualquier tramo (asfalto, tierra o nieve).\n"
          "• **Caminos de Plataforma y Accesos a Pozos (Tierra/Ripio):** Máximo **30 km/h** con tracción 4H activada.\n"
          "• **Caminos Troncales de Mina:** Respetar la señalética oficial (habitualmente **40 km/h a 50 km/h** según la curva o visibilidad).\n"
          "• **Cercanía a Personas o Equipos en Maniobra:** Velocidad a paso de hombre (máximo **10 km/h**).",
      "navRoute": "procedimientos_teoricos",
      "navLabel": "📑 Ver Estándar de Conducción",
    },

    // 19. MEDIDAS DE SEGURIDAD EN CONTROL DE SONDAJE (PRO-OP-MLP-CS-07)
    {
      "intent": "seguridad_sondaje",
      "keywords": ["medidas de seguridad", "seguridad sondaje", "seguridad control", "riesgos sondaje", "medidas seguridad", "seguridad del control de sondaje"],
      "question": "¿Cuáles son las medidas de seguridad obligatorias en el control de sondaje?",
      "response": "🛡️ **MEDIDAS DE SEGURIDAD OBLIGATORIAS EN SONDAJE DIAMANTINO**\n\n"
          "1. **EPP Obligatorio:** Casco de seguridad con barbiquejo, lentes con protección UV, guantes anti-corte/antibalístico, zapatos de seguridad con caña alta y protección auditiva.\n"
          "2. **Distancia de Seguridad:** Prohibido ubicarse en la línea de fuego o cerca de la sarta en rotación (riesgo de atrapamiento con barra giratoria).\n"
          "3. **Aislación y Bloqueo (5 Pasos):** Antes de desatornillar corona, reparar prensa o manipular winche, aplicar bloqueo personal de energía con candado rojo y tarjeta.\n"
          "4. **Presión de Agua y Fluidos:** Verificar que la línea no mantenga presión atrapada antes de desconectar mangueras o prensa empaque.\n"
          "5. **Orden y Limpieza:** Mantener plataformas libres de barro, grasa y herramientas sueltas para evitar caídas al mismo nivel.",
      "navRoute": "procedimientos_teoricos",
      "navLabel": "📑 Ver Control Operacional Sondaje",
    },

    // 20. PEE - PLAN DE EMERGENCIA Y EVACUACIÓN
    {
      "intent": "pee_procedimiento",
      "keywords": ["pee", "plan de emergencia", "procedimiento emergencia", "evacuacion", "alerta emergencia", "que es un pee"],
      "question": "¿Qué es el PEE (Plan de Emergencia y Evacuación)?",
      "response": "🚨 **PEE — PLAN DE EMERGENCIA Y EVACUACIÓN**\n\n"
          "El **PEE** es el procedimiento obligatorio de respuesta rápida ante eventos críticos en plataforma (amago de incendio, accidente grave, derrame masivo o clima extremo):\n"
          "1. **Dar la Alarma:** Comunicar de inmediato al canal de radio de emergencia o frecuencia de faena (Mayday / Emergencia Operacional).\n"
          "2. **Detener Equipos:** Accionar el **Paro de Emergencia (E-Stop)** de la sonda si es seguro hacerlo.\n"
          "3. **Punto de Encuentro de Emergencia (PEE):** Evacuar de forma ordenada hacia la zona segura señalizada en la plataforma.\n"
          "4. **Conteo de Personal:** El controlador o jefe de plataforma verifica la presencia de todo el personal mediante la nómina del turno.",
      "navRoute": "documentos_obligatorios",
      "navLabel": "📄 Ver Plan de Emergencia",
    },

        // 21. DEFINICIÓN DIRECTA DE EPP
    {
      "intent": "epp_definicion",
      "keywords": ["epp", "que es un epp", "que es epp", "que son los epp", "que son epp", "cuales son los epp", "definicion epp", "significado epp", "que significa epp", "elementos de proteccion personal"],
      "question": "¿Qué es un EPP y cuáles son los obligatorios?",
      "response": "🛡️ **EPP — Elementos de Protección Personal**\n\n"
          "Son los equipos y prendas de uso individual obligatorio para proteger la salud e integridad física del trabajador en faena.\n\n"
          "• **EPP Básico Obligatorio en Sondaje:**\n"
          "  - Casco de seguridad con barbiquejo.\n"
          "  - Lentes de seguridad con filtro UV.\n"
          "  - Guantes de seguridad anti-corte / antibalísticos.\n"
          "  - Calzado de seguridad de caña alta con puntera.\n"
          "  - Protectores auditivos (tipo copa o tapones).\n"
          "  - Ropa de trabajo térmica / reflectante de alta visibilidad.",
    },

    // 22. DEFINICIÓN DIRECTA DE CONTRA
    {
      "intent": "contra_definicion",
      "keywords": ["que es la contra", "que es contra", "definicion contra", "concepto contra"],
      "question": "¿Qué es la Contra?",
      "response": "📏 **CONTRA EN SONDAJE**\n\n"
          "La **Contra** es la medida sobrante de la barra de perforación que queda fuera del pozo (sobre la mesa rotatoria/mandril) al finalizar una carrera. Sirve para calcular con precisión milimétrica la profundidad real alcanzada por el pozo.",
      "navRoute": "calculadoras",
      "navLabel": "🧮 Abrir Calculadora de Contra",
    },

    // 23. DEFINICIÓN DIRECTA DE SARTA
    {
      "intent": "sarta_definicion",
      "keywords": ["que es la sarta", "que es sarta", "definicion sarta", "sarta de perforacion"],
      "question": "¿Qué es la sarta de perforación?",
      "response": "🛠️ **SARTA DE PERFORACIÓN**\n\n"
          "La **Sarta** es la columna continua formada por el ensamblaje de barras de perforación roscadas entre sí, el barril porta-testigos y la corona diamantada que descienden dentro del pozo para cortar la roca.",
    },

    // 24. DEFINICIÓN DIRECTA DE CORONA
    {
      "intent": "corona_definicion",
      "keywords": ["que es la corona", "que es corona", "definicion corona", "corona diamantada"],
      "question": "¿Qué es la corona diamantada?",
      "response": "💎 **CORONA DIAMANTADA**\n\n"
          "Es la herramienta de corte impregnada con partículas de diamante sintético situada en el extremo inferior de la sarta. Es la encargada de desgastar y cortar la roca por rotación y avance para extraer el testigo.",
    },

        // 25. ACCIDENTE O EVENTO DE ALTO POTENCIAL (HPO)
    {
      "intent": "accidente_alto_potencial",
      "keywords": ["accidente de alto potencial", "accidente alto potencial", "alto potencial", "casi accidente", "incidente grave", "que es un accidente de alto potencial"],
      "question": "¿Qué es un Accidente o Evento de Alto Potencial (HPO)?",
      "response": "⚠️ **ACCIDENTE DE ALTO POTENCIAL**\n\n"
          "Es aquel incidente o desvío operacional crítico que, bajo condiciones ligeramente distintas, **tuvo el potencial real de causar una lesión grave o fatalidad**.\n\n"
          "• **Ejemplos en Plataforma:** Caída de barra/herramienta desde altura, rotura de manguera de alta presión sin guaya de seguridad, falla de frenos en vehículo o maniobra de izaje con personal bajo la carga.\n"
          "• **Acción Obligatoria:** Detener la tarea de inmediato, aislar el área y reportar de forma urgente a la supervisión.",
      "navRoute": "documentos_obligatorios",
      "navLabel": "📄 Ver Procedimiento de Reportabilidad",
    },

    // 26. SEGREGACIÓN DE ÁREAS EN PLATAFORMA
    {
      "intent": "segregacion_areas",
      "keywords": ["segregacion", "segregacion de areas", "delimitacion", "barrera de seguridad", "cono de seguridad", "zona restringida", "que es la segregacion"],
      "question": "¿Qué es la Segregación de Áreas en plataforma?",
      "response": "🚧 **SEGREGACIÓN DE ÁREAS EN PLATAFORMA**\n\n"
          "Es la **delimitación física obligatoria** mediante conos, cadenas, cintas de peligro o barreras duras para restringir el acceso de personal no autorizado a zonas de riesgo activo.\n\n"
          "• **Zonas que Exigen Segregación:**\n"
          "  - Área de la sarta giratoria (línea de fuego).\n"
          "  - Radio de maniobra de grúas e izaje.\n"
          "  - Área de maniobra y acople de camiones.\n"
          "  - Cerca del generador o zona de alta tensión.",
      "navRoute": "documentos_obligatorios",
      "navLabel": "📄 Ver Estándar de Segregación",
    },

        // 14. PROCEDIMIENTOS DE LA APP
    {
      "intent": "procedimientos_teoricos",
      "keywords": ["procedimiento", "procedimientos", "protocolo", "instructivo", "norma", "pe-gm-001", "cadenas", "caseta", "invierno"],
      "question": "¿Qué Procedimientos existen en la app?",
      "response": "📑 **PROCEDIMIENTOS OPERACIONALES EN LA APP**\n\n"
          "• **PE-GM-001:** Operación Invierno 2026 V4\n"
          "• **PRO-OP-MLP-08:** Uso Caseta GeoAtacama V.09\n"
          "• **PRO-OP-MLP-CS-07:** Control Operacional Sondaje Diamantino V11\n"
          "• **PRO-OP-CSO-MLP-03:** Postura de Cadenas\n"
          "• **PRO-OP-MLP-CS-02:** Conducción Vehículo Liviano\n"
          "• **PRO-SO-MLP-CS-05:** Procedimiento FYS",
      "navRoute": "procedimientos_teoricos",
      "navLabel": "📑 Abrir Procedimientos",
    },
  ];

  static String _normalize(String text) {
    var str = text.toLowerCase().trim();
    str = str.replaceAll(RegExp(r'[áàäâ]'), 'a');
    str = str.replaceAll(RegExp(r'[éèëê]'), 'e');
    str = str.replaceAll(RegExp(r'[íìïî]'), 'i');
    str = str.replaceAll(RegExp(r'[óòöô]'), 'o');
    str = str.replaceAll(RegExp(r'[úùüû]'), 'u');
    str = str.replaceAll(RegExp(r'[^\w\s\.\,]'), ' ');
    return str.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // CÁLCULO NUMÉRICO INTELIGENTE EN VIVO
  static Map<String, dynamic>? _calcularInteligente(String consulta) {
    final query = _normalize(consulta);

    final RegExp numRegExp = RegExp(r'(\d+[.,]?\d*)');
    final matches = numRegExp.allMatches(query);
    final List<double> numeros = [];

    for (final m in matches) {
      final strNum = m.group(0)?.replaceAll(',', '.');
      if (strNum != null) {
        final val = double.tryParse(strNum);
        if (val != null) {
          numeros.add(val);
        }
      }
    }

    // 0. RECONOCER CASO CÁLCULO DE PESO DE SARTA
    if (query.contains("peso") && (query.contains("barra") || query.contains("sarta")) && numeros.isNotEmpty) {
      final numBarras = numeros[0];
      final esNq = query.contains("nq");
      final esPq = query.contains("pq");
      final pesoUnit = esNq ? 19.0 : (esPq ? 38.0 : 25.0);
      final tipoBarra = esNq ? "NQ" : (esPq ? "PQ" : "HQ");

      final pesoTotalKg = numBarras * pesoUnit;
      final pesoTon = pesoTotalKg / 1000.0;

      final resp = "🧮 **CÁLCULO AUTOMÁTICO DE PESO DE SARTA**\n\n"
          "• **Cantidad de Barras:** `${numBarras.toInt()} barras ${tipoBarra}`\n"
          "• **Peso Unitario por Barra:** `${pesoUnit.toStringAsFixed(1)} kg`\n"
          "• **Largo de Sarta Estimado:** `${(numBarras * 3.0).toStringAsFixed(1)} m`\n\n"
          "⚖️ **PESO TOTAL DE SARTA = ${pesoTotalKg.toStringAsFixed(1)} kg (${pesoTon.toStringAsFixed(2)} toneladas)**\n\n"
          "Peso Total Sarta = ${pesoTotalKg.toStringAsFixed(1)} kg (${pesoTon.toStringAsFixed(2)} toneladas)";

      return {
        "question": consulta,
        "response": resp,
      };
    }

    // 1. RECONOCER CASO CÁLCULO DE CONTRA
    if (query.contains("contra") && numeros.length >= 2) {
      double contraAnt = 0.0;
      double barra = 3.00;
      double avance = 0.0;

      if (numeros.length == 2) {
        contraAnt = numeros[0];
        avance = numeros[1];
      } else if (numeros.length >= 3) {
        contraAnt = numeros[0];
        barra = numeros[1];
        avance = numeros[2];
      }

      final contraAjustada = contraAnt + barra;
      final nuevaContra = contraAjustada - avance;

      final resp = "🧮 **CÁLCULO AUTOMÁTICO DE CONTRA**\n\n"
          "• **Contra Anterior:** `${contraAnt.toStringAsFixed(2)} m`\n"
          "• **Adición de Barra:** `+${barra.toStringAsFixed(2)} m`\n"
          "➜ **Contra Ajustada:** `${contraAjustada.toStringAsFixed(2)} m`\n"
          "• **Perforado / Avance:** `-${avance.toStringAsFixed(2)} m`\n\n"
          "✅ **NUEVA CONTRA RESULTANTE = ${nuevaContra.toStringAsFixed(2)} m**\n\n"
          r"$$\text{Nueva Contra} = (" + "${contraAnt.toStringAsFixed(2)} + ${barra.toStringAsFixed(2)}) - ${avance.toStringAsFixed(2)} = ${nuevaContra.toStringAsFixed(2)}" r"\text{ m}$$";

      return {
        "question": consulta,
        "response": resp,
        "navRoute": "calculadoras",
        "navLabel": "🧮 Abrir Calculadoras",
      };
    }

    // 2. RECONOCER CASO CÁLCULO DE RECUPERACIÓN (%REC)
    if ((query.contains("recuperacion") || query.contains("rec") || query.contains("testigo") || query.contains("perfore")) && numeros.length >= 2) {
      double perforado = numeros[0];
      double recuperado = numeros[1];

      // Si el usuario especificó "recupere X y perfore Y", ajustar orden
      if (query.indexOf("recuper") < query.indexOf("perfor") && query.contains("perfor")) {
        recuperado = numeros[0];
        perforado = numeros[1];
      }

      if (perforado > 0) {
        final recPct = (recuperado / perforado) * 100.0;
        final perd = perforado - recuperado;

        String alertMsg;
        if (recPct > 100.0) {
          alertMsg = "ℹ️ **Recuperación > 100% (${recPct.toStringAsFixed(1)}%):** Anomalía operacional común por **rezago de testigo** atrapado en la corrida anterior (+${(recuperado - perforado).toStringAsFixed(2)} m de exceso).";
        } else if (recPct >= 95.0) {
          alertMsg = "✅ **Recuperación Óptima (${recPct.toStringAsFixed(1)}%):** Cumple con el estándar minero (+95%).";
        } else {
          alertMsg = "⚠️ **Alerta de Pérdida (${recPct.toStringAsFixed(1)}%):** %Rec < 95%. Debes colocar un taco de madera/marcador indicando una pérdida de ${perd.toStringAsFixed(2)} m.";
        }

        final resp = "🧮 **CÁLCULO DE RECUPERACIÓN DE TESTIGO**\n\n"
            "• **Metros Perforados:** `${perforado.toStringAsFixed(2)} m`\n"
            "• **Testigo Recuperado:** `${recuperado.toStringAsFixed(2)} m`\n\n"
            "📊 **PORCENTAJE DE RECUPERACIÓN = ${recPct.toStringAsFixed(2)}%**\n"
            "${recPct <= 100 ? "• **Pérdida de testigo:** `${perd.toStringAsFixed(2)} m`\n\n" : "\n"}"
            "$alertMsg";

        return {
          "question": consulta,
          "response": resp,
          "navRoute": "calculadoras",
          "navLabel": "🧮 Ir a Calculadora",
        };
      }
    }

    return null;
  }

  static Map<String, dynamic> buscarRespuesta(String consulta) {
    final calculoAuto = _calcularInteligente(consulta);
    if (calculoAuto != null) {
      return calculoAuto;
    }

    final normQuery = _normalize(consulta);
    final normWords = normQuery.split(' ');

    // Acceso directo garantizado para EPP (singular/plural)
    if (normWords.contains("epp") || normQuery.contains("proteccion personal")) {
      for (final item in _knowledgeBase) {
        if (item["intent"] == "epp_definicion") {
          return item;
        }
      }
    }

    final normalizedQuery = _normalize(consulta);
    final rawWords = normalizedQuery.split(' ');

    final stopWords = {
      'el', 'la', 'los', 'las', 'un', 'una', 'unos', 'unas', 'de', 'del', 'a', 'ante',
      'bajo', 'con', 'en', 'entre', 'hacia', 'hasta', 'para', 'por', 'segun',
      'sin', 'sobre', 'tras', 'que', 'cual', 'cuales', 'como', 'donde', 'cuando', 'existe',
      'existen', 'hay', 'tengo', 'tener', 'saber', 'dime', 'dices', 'hacer', 'me', 'se', 'bot',
      'al', 'su', 'sus', 'es', 'son'
    };

    final List<String> filteredQueryTokens = [];
    for (final word in rawWords) {
      if (word.isEmpty || stopWords.contains(word)) continue;
      filteredQueryTokens.add(word);
      if (_synonyms.containsKey(word)) {
        filteredQueryTokens.add(_synonyms[word]!);
      }
    }

    if (filteredQueryTokens.isEmpty) {
      return {
        "question": "Consulta general",
        "response": "🤖 **DrillBot 2.0 — Asistente Técnico**\n\n"
            "Puedo ayudarte con:\n"
            "1. 🧮 **Cálculos automáticos:** Escribe por ejemplo 'contra anterior 0.80 agregue barra 3.00 avance 1.50' o 'perfore 1.50 y recupere 1.42'.\n"
            "2. 🚨 **Diagnósticos en Pozo:** Pregunta sobre 'testigo quemado', 'perdida de agua', 'overshot no engancha', 'caida de presion'.\n"
            "3. 🛠️ **Metrajes:** 'cuanto mide la barra', 'medida del barril corto', 'punto muerto'.\n"
            "4. 📋 **Protocolos y Documentos:** 'artp', 'cerc', 'rotulacion de cajas'.",
      };
    }

    Map<String, dynamic>? mejorMatch;
    double maxScore = 0.0;

    for (final item in _knowledgeBase) {
      final List<String> keywords = List<String>.from(item['keywords']);
      final Set<String> itemTokens = {};
      
      for (final kw in keywords) {
        final kwNorm = _normalize(kw);
        for (final w in kwNorm.split(' ')) {
          if (w.isNotEmpty && !stopWords.contains(w)) {
            itemTokens.add(w);
            if (_synonyms.containsKey(w)) {
              itemTokens.add(_synonyms[w]!);
            }
          }
        }
      }

      if (itemTokens.isEmpty) continue;

      double score = 0.0;

      // 1. Coincidencia por frase exacta completa (+100 puntos)
      for (final kw in keywords) {
        final kwNorm = _normalize(kw);
        if (kwNorm.length >= 4 && normalizedQuery.contains(kwNorm)) {
          score += 100.0;
          break;
        }
      }

      // 2. Porcentaje de tokens de la pregunta del usuario que coinciden (+50 puntos por ratio completo)
      int matchedCount = 0;
      for (final qTok in filteredQueryTokens) {
        if (itemTokens.contains(qTok)) {
          matchedCount++;
        } else {
          for (final iTok in itemTokens) {
            if (qTok.length >= 4 && iTok.length >= 4 && (qTok.contains(iTok) || iTok.contains(qTok))) {
              matchedCount++;
              break;
            }
          }
        }
      }

      final double ratio = matchedCount / filteredQueryTokens.length;
      score += ratio * 50.0;

      if (score > maxScore) {
        maxScore = score;
        mejorMatch = item;
      }
    }

    // Exigir un puntaje mínimo firme (35.0) para responder una intención
    if (mejorMatch != null && maxScore >= 35.0) {
      return mejorMatch;
    }

    return {
      "question": consulta,
      "response": "Disculpa, no logré comprender tu pregunta con la suficiente certeza técnica.\n\n"
          "Como asistente de apoyo operacional, prefiero no dar información imprecisa en terreno. Prueba con preguntas más directas como:\n"
          "• ¿Cómo se calcula la contra?\n"
          "• ¿Qué hacer si hay pérdida de agua?\n"
          "• ¿Por qué el testigo viene quemado?\n"
          "• ¿Cuánto mide una barra de perforación?\n\n"
          "O escribe los datos numéricos de tu turno para que realice el cálculo por ti.",
    };
  }

  static Map<String, List<String>> obtenerCategoriasSugerencias() {
    return {
      "🧮 Fórmulas": [
        "¿Cómo se calcula la contra?",
        "Contra anterior 0.80 agregué barra 3.00 avance 1.50",
        "Perforé 1.50m y recuperé 1.42m",
        "¿Cómo se calcula el fondo del pozo?",
      ],
      "🚨 Diagnóstico Pozo": [
        "¿Por qué el testigo viene quemado o molido?",
        "¿Qué hacer si hay pérdida de agua?",
        "¿Qué hacer si el overshot no engancha?",
        "¿Por qué cae la presión de agua?",
      ],
      "🛠️ Metrajes & Pesos": [
        "¿Cuánto pesa una caja / bandeja porta-testigo con muestras?",
        "¿Cuánto pesan las barras de perforación y la sarta?",
        "Cuanto pesan 40 barras HQ",
        "¿Cuánto mide una barra de perforación?",
        "¿Cuánto miden los barriles tomamuestras?",
        "¿Qué es el Punto Muerto (PM)?",
        "Diámetros HQ vs NQ vs PQ",
      ],
      "📋 Protocolos": [
        "¿Cuáles son los Documentos Obligatorios?",
        "¿Qué Procedimientos existen en la app?",
        "¿Cómo se rotulan las cajas y tacos?",
      ],
      "📂 Procedimientos OP": [
        "¿Cuáles son los 5 Pasos del Bloqueo de Energías (RO-SSO-SEG-005)?",
        "¿Cuáles son las Alertas por Clima Adverso (RO-GR-OPI-001)?",
        "¿Qué exige el Procedimiento de Operación Invierno (PE-GM-001)?",
        "¿Cómo se instalan las cadenas para nieve según PRO-OP-CSO-MLP-03?",
        "¿Cuáles son los estándares de conducción 4x4 en mina (PRO-OP-MLP-CS-02)?",
        "¿Cómo funciona la medición con Gyro Master (PRO-OP-GEO-MLP-01)?",
        "¿Cómo se realiza el Mapeo Geotécnico y cálculo de RQD (PRO-OP-MLP-CS-10)?",
      ],
    };
  }
}
