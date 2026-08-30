class ChatbotKnowledgeService {
  // Red de sinónimos y alias semánticos operacionales
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
  };

  static final List<Map<String, dynamic>> _knowledgeBase = [
    // DOCUMENTOS OBLIGATORIOS REALES
    {
      "intent": "documentos_obligatorios",
      "keywords": [
        "documento",
        "documentos",
        "obligatorio",
        "papel",
        "archivo",
        "registro",
        "permiso",
        "art",
        "artp",
        "cerc",
        "epr",
        "epa",
        "checklist mano"
      ],
      "question": "¿Cuáles son los Documentos Obligatorios?",
      "response": r'''📄 **DOCUMENTOS OBLIGATORIOS REGISTRADOS EN LA APP**

Los 7 documentos oficiales que se encuentran disponibles en el módulo son:

📌 **Categoría: Permisos**
1. **Trabajos cruzados** (Enlace Drive disponible)
2. **Permiso ingreso al área** (Enlace Drive disponible)

📌 **Categoría: Checklists**
3. **Checklist EPR** (Equipo de Protección Respiratoria)
4. **Checklist EPA** (Equipo de Protección Auditiva)
5. **Checklist de Mano** (Herramientas manuales)

📌 **Categoría: Controles**
6. **Cartilla CERC** (Control de Eventos de Riesgo Crítico)
7. **ARTP Control** (Análisis de Riesgo del Trabajo y Entorno)

*(Puedes acceder y abrir cada documento en la sección "Documentos obligatorios" del menú lateral)*''',
    },

    // PROCEDIMIENTOS REALES DE LA APP
    {
      "intent": "procedimientos_teoricos",
      "keywords": [
        "procedimiento",
        "procedimientos",
        "protocolo",
        "instructivo",
        "norma",
        "reglamento",
        "pe-gm-001",
        "cadenas",
        "caseta",
        "invierno",
        "conduccion",
        "control operacional"
      ],
      "question": "¿Qué Procedimientos existen en la app?",
      "response": r'''📑 **PROCEDIMIENTOS OPERACIONALES REGISTRADOS EN LA APP**

Los 8 procedimientos oficiales registrados con su código son:

📌 **Categoría: Operaciones**
1. **PE-GM-001:** PROCEDIMIENTO OPERACIÓN INVIERNO 2026 V4
2. **PRO-OP-MLP-08:** TRASLADO Y USO DE CASETA GEOATACAMA V.09
3. **PRO-OP-MLP-CS-07:** CONTROL OPERACIONAL DE SONDAJE DIAMANTINO V11
4. **RO-GR-OPI-001:** REGLAMENTO OPERACIONES EN CONDICIONES CLIMÁTICAS ADVERSAS 2026 V10

📌 **Categoría: Seguridad y Vehículos**
5. **PRO-OP-CSO-MLP-03:** POSTURA DE CADENAS 2026
6. **PRO-OP-MLP-CS-02:** CONDUCCIÓN DE VEHÍCULO LIVIANO

📌 **Categoría: Seguridad y Emergencias**
7. **PRO-SO-MLP-CS-05:** Procedimiento FYS
8. **PRO-SO-MLP-06:** PLAN DE GESTIÓN DE RIESGOS DE EMERGENCIAS, CATÁSTROFES O DESASTRES

*(Puedes abrir y copiar el enlace de cada uno en la sección "Procedimientos" del menú lateral)*''',
    },

    // BARRA DE PERFORACION
    {
      "intent": "barra",
      "keywords": ["barra", "barras", "tubo", "cañeria", "varilla"],
      "question": "¿Cuánto mide una barra de perforación?",
      "response": r"Las barras de perforación diamantina estándar miden **3.00 metros** (o **2.90 metros** según la serie HQ/NQ/PQ).",
    },

    // BARRIL CORTO
    {
      "intent": "barrilcorto",
      "keywords": ["barril corto", "tomamuestra corto"],
      "question": "¿Cuánto mide el barril corto?",
      "response": r"El barril corto mide **2.60 metros**.",
    },

    // BARRIL LARGO
    {
      "intent": "barrillargo",
      "keywords": ["barril largo", "tomamuestra largo", "barril estandar"],
      "question": "¿Cuánto mide el barril largo?",
      "response": r"El barril largo estándar mide **4.15 metros** (utilizado para corridas de 3.00 m de roca).",
    },

    // EXTENSION REFLEX
    {
      "intent": "extensionreflex",
      "keywords": ["extension", "reflex", "orientacion"],
      "question": "¿Cuánto mide la extensión Reflex?",
      "response": r"La extensión Reflex mide **0.40 metros** (+0.40 m al sumar las herramientas).",
    },

    // PUNTO MUERTO
    {
      "intent": "puntomuerto",
      "keywords": ["punto muerto", "pm"],
      "question": "¿Qué es y cuánto mide el punto muerto?",
      "response": r"El **Punto Muerto (PM)** es la distancia fija desde el suelo a la marca de lectura del cabezal (usualmente entre **0.40 m y 0.60 m**). Se resta a la sarta.",
    },

    // FORMULAS DIRECTAS
    {
      "intent": "formula_contra",
      "keywords": ["contra", "sobrante", "acoplar", "adicion"],
      "question": "¿Cuál es la fórmula de la contra?",
      "response": r'''• **Sin adición de barra:**
$$\text{Contra} = \text{Contra Anterior} - \text{Perforado}$$

• **Con adición de barra (Contra Ajustada):**
$$\text{Contra Ajustada} = \text{Contra Anterior} + \text{Largo de Barra}$$
$$\text{Nueva Contra} = \text{Contra Ajustada} - \text{Perforado}$$''',
    },
    {
      "intent": "formula_herramientas",
      "keywords": ["herramientas", "sarta", "herramienta"],
      "question": "¿Cuál es la fórmula de Herramientas Totales?",
      "response": r"$$\text{Herr} = (\text{Barras} \times \text{Largo}) + \text{Barril} + \text{Extensión Reflex} - \text{PM}$$",
    },
    {
      "intent": "formula_recuperacion",
      "keywords": ["recuperacion", "porcentaje", "rec"],
      "question": "¿Cuál es la fórmula de recuperación?",
      "response": r"$$\%\text{Rec} = \frac{\text{Testigo Recuperado (m)}}{\text{Perforado (m)}} \times 100$$",
    },
    {
      "intent": "formula_fondo",
      "keywords": ["fondo", "profundidad", "cota"],
      "question": "¿Cuál es la fórmula del fondo del pozo?",
      "response": r"$$\text{Fondo} = \text{Herr} - \text{Contra}$$" "\n" r"O por avance acumulado: $\text{Fondo Nuevo} = \text{Fondo Anterior} + \text{Perforado}$",
    },
  ];

  static String _normalize(String text) {
    var str = text.toLowerCase().trim();
    str = str.replaceAll(RegExp(r'[áàäâ]'), 'a');
    str = str.replaceAll(RegExp(r'[éèëê]'), 'e');
    str = str.replaceAll(RegExp(r'[íìïî]'), 'i');
    str = str.replaceAll(RegExp(r'[óòöô]'), 'o');
    str = str.replaceAll(RegExp(r'[úùüû]'), 'u');
    str = str.replaceAll(RegExp(r'[^\w\s]'), ' ');
    return str.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static Set<String> _getSemanticTokens(String text) {
    final normalized = _normalize(text);
    final rawWords = normalized.split(' ');
    final Set<String> tokens = {};

    final stopWords = {
      'el', 'la', 'los', 'las', 'un', 'una', 'unos', 'unas', 'de', 'del', 'a', 'ante',
      'bajo', 'con', 'contra', 'en', 'entre', 'hacia', 'hasta', 'para', 'por', 'según',
      'sin', 'sobre', 'tras', 'que', 'cual', 'cuales', 'como', 'donde', 'cuando', 'existe',
      'existen', 'hay', 'tengo', 'tener', 'saber', 'dime', 'dices', 'hacer', 'me', 'se'
    };

    for (final word in rawWords) {
      if (word.isEmpty || stopWords.contains(word)) continue;
      tokens.add(word);
      if (_synonyms.containsKey(word)) {
        tokens.add(_synonyms[word]!);
      }
    }

    return tokens;
  }

  static Map<String, dynamic> buscarRespuesta(String consulta) {
    final queryTokens = _getSemanticTokens(consulta);

    if (queryTokens.isEmpty) {
      return {
        "question": "Consulta no especificada",
        "response": r'''Disculpa, soy un asistente básico de consulta rápida.

Para evitar informaciones inexactas o inseguras en terreno, solo respondo preguntas específicas y directas sobre:
• **Metrajes exactos** (barras, barriles, extensión Reflex)
• **Fórmulas de control** (contra, herramientas, recuperación, fondo)
• **Listas de Procedimientos y Documentos** de la app.

Por favor, realiza una pregunta directa o consulta con tu Instructor/Supervisor.''',
      };
    }

    Map<String, dynamic>? mejorMatch;
    double maxScore = 0.0;

    for (final item in _knowledgeBase) {
      final List<String> keywords = List<String>.from(item['keywords']);
      final Set<String> itemTokens = {};
      for (final kw in keywords) {
        itemTokens.addAll(_getSemanticTokens(kw));
      }

      int coincidences = 0;
      for (final qToken in queryTokens) {
        for (final iToken in itemTokens) {
          if (qToken == iToken) {
            coincidences += 3;
          } else if (qToken.length >= 4 && iToken.length >= 4 &&
              (qToken.contains(iToken) || iToken.contains(qToken))) {
            coincidences += 2;
          }
        }
      }

      double score = coincidences / (itemTokens.isEmpty ? 1 : itemTokens.length);

      if (score > maxScore) {
        maxScore = score;
        mejorMatch = item;
      }
    }

    // Strict threshold: If confidence is lower than 0.35, politely apologize to prevent unsafe answers
    if (mejorMatch != null && maxScore >= 0.35) {
      return mejorMatch;
    }

    return {
      "question": consulta,
      "response": r'''Disculpa, no logré comprender tu consulta con la suficiente certeza técnica.

Como asistente básico de apoyo, prefiero no dar respuestas inexactas para evitar confusiones en el pozo. Solo respondo preguntas sencillas y directas sobre:
• **Metrajes exactos:** *"¿cuánto mide una barra?"*, *"¿cuánto mide el barril corto?"*
• **Fórmulas:** *"fórmula de la contra"*, *"fórmula de herramientas"*
• **Módulos:** *"documentos obligatorios"*, *"procedimientos"*

Te sugiero reformular la pregunta de forma más directa o consultar directamente con tu Supervisor de Turno.''',
    };
  }

  static List<String> obtenerSugerenciasRapidas() {
    return _knowledgeBase.map((e) => e['question'] as String).toList();
  }
}
