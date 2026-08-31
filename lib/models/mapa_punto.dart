enum CategoriaPunto {
  pozoDdh,
  pozoRc,
  plataforma,
  campamento,
  testigoteca,
  refugio,
  polvorin,
  botadero,
  acceso,
  peligro,
  personalizado,
}

extension CategoriaPuntoExtension on CategoriaPunto {
  String get titulo {
    switch (this) {
      case CategoriaPunto.pozoDdh:
        return 'Pozo Diamantina (DDH)';
      case CategoriaPunto.pozoRc:
        return 'Pozo Aire Reverso (RC)';
      case CategoriaPunto.plataforma:
        return 'Plataforma de Sondaje';
      case CategoriaPunto.campamento:
        return 'Campamento / Instalaciones';
      case CategoriaPunto.testigoteca:
        return 'Testigoteca / Sala Logueo';
      case CategoriaPunto.refugio:
        return 'Refugio Minero / Emergencia';
      case CategoriaPunto.polvorin:
        return 'Polvorín';
      case CategoriaPunto.botadero:
        return 'Botadero / Rajo';
      case CategoriaPunto.acceso:
        return 'Garita / Control de Acceso';
      case CategoriaPunto.peligro:
        return 'Zona de Precaución / Peligro';
      case CategoriaPunto.personalizado:
        return 'Punto de Terreno';
    }
  }

  String get emoji {
    switch (this) {
      case CategoriaPunto.pozoDdh:
        return '🎯';
      case CategoriaPunto.pozoRc:
        return '💨';
      case CategoriaPunto.plataforma:
        return '🏗️';
      case CategoriaPunto.campamento:
        return '🏕️';
      case CategoriaPunto.testigoteca:
        return '📦';
      case CategoriaPunto.refugio:
        return '🛡️';
      case CategoriaPunto.polvorin:
        return '⚡';
      case CategoriaPunto.botadero:
        return '⛏️';
      case CategoriaPunto.acceso:
        return '🚧';
      case CategoriaPunto.peligro:
        return '⚠️';
      case CategoriaPunto.personalizado:
        return '📍';
    }
  }

  int get colorHex {
    switch (this) {
      case CategoriaPunto.pozoDdh:
        return 0xFF2196F3; // Azul
      case CategoriaPunto.pozoRc:
        return 0xFF00BCD4; // Cyan
      case CategoriaPunto.plataforma:
        return 0xFFFF9800; // Naranja
      case CategoriaPunto.campamento:
        return 0xFF4CAF50; // Verde
      case CategoriaPunto.testigoteca:
        return 0xFF9C27B0; // Morado
      case CategoriaPunto.refugio:
        return 0xFFE91E63; // Rosa/Rojo
      case CategoriaPunto.polvorin:
        return 0xFFF44336; // Rojo fuerte
      case CategoriaPunto.botadero:
        return 0xFF795548; // Café
      case CategoriaPunto.acceso:
        return 0xFF607D8B; // Gris azulado
      case CategoriaPunto.peligro:
        return 0xFFFFC107; // Amarillo
      case CategoriaPunto.personalizado:
        return 0xFF00E676; // Verde brillante
    }
  }
}

class MapaPunto {
  final String id;
  final String nombre;
  final CategoriaPunto categoria;
  final double latitud;
  final double longitud;
  final double esteUtm;
  final double norteUtm;
  final int husoUtm;
  final String hemisferio;
  final double? cota; // Altitud msnm
  final double? azimutPozo; // Dirección del pozo
  final double? inclinacionPozo; // Dip (-90° vertical, -60°, etc.)
  final double? profundidadObjetivo; // Metros
  final String estado; // "En perforación", "Completado", "Planificado", "Stand-by", "Operativo"
  final String? observaciones;
  final bool esPersonalizado;
  final DateTime creadoEn;

  MapaPunto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.latitud,
    required this.longitud,
    required this.esteUtm,
    required this.norteUtm,
    this.husoUtm = 19,
    this.hemisferio = 'S',
    this.cota,
    this.azimutPozo,
    this.inclinacionPozo,
    this.profundidadObjetivo,
    this.estado = 'Operativo',
    this.observaciones,
    this.esPersonalizado = false,
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria.name,
      'latitud': latitud,
      'longitud': longitud,
      'esteUtm': esteUtm,
      'norteUtm': norteUtm,
      'husoUtm': husoUtm,
      'hemisferio': hemisferio,
      'cota': cota,
      'azimutPozo': azimutPozo,
      'inclinacionPozo': inclinacionPozo,
      'profundidadObjetivo': profundidadObjetivo,
      'estado': estado,
      'observaciones': observaciones,
      'esPersonalizado': esPersonalizado,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }

  factory MapaPunto.fromJson(Map<String, dynamic> json) {
    return MapaPunto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      categoria: CategoriaPunto.values.firstWhere(
        (c) => c.name == json['categoria'],
        orElse: () => CategoriaPunto.personalizado,
      ),
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      esteUtm: (json['esteUtm'] as num).toDouble(),
      norteUtm: (json['norteUtm'] as num).toDouble(),
      husoUtm: (json['husoUtm'] as int?) ?? 19,
      hemisferio: (json['hemisferio'] as String?) ?? 'S',
      cota: json['cota'] != null ? (json['cota'] as num).toDouble() : null,
      azimutPozo: json['azimutPozo'] != null ? (json['azimutPozo'] as num).toDouble() : null,
      inclinacionPozo: json['inclinacionPozo'] != null ? (json['inclinacionPozo'] as num).toDouble() : null,
      profundidadObjetivo:
          json['profundidadObjetivo'] != null ? (json['profundidadObjetivo'] as num).toDouble() : null,
      estado: (json['estado'] as String?) ?? 'Operativo',
      observaciones: json['observaciones'] as String?,
      esPersonalizado: (json['esPersonalizado'] as bool?) ?? false,
      creadoEn: json['creadoEn'] != null ? DateTime.parse(json['creadoEn'] as String) : null,
    );
  }
}
