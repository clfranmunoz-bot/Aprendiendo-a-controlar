class NotaCampo {
  final String id;
  final String titulo;
  final String contenido;
  final String categoria; // Operaciones, Medición, Muestra, Maquinaria, Seguridad
  final DateTime fecha;
  final bool revisadoConSupervisor;
  final String? pathFoto;

  NotaCampo({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.categoria,
    required this.fecha,
    this.revisadoConSupervisor = false,
    this.pathFoto,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'contenido': contenido,
        'categoria': categoria,
        'fecha': fecha.toIso8601String(),
        'revisadoConSupervisor': revisadoConSupervisor,
        'pathFoto': pathFoto,
      };

  factory NotaCampo.fromJson(Map<String, dynamic> json) => NotaCampo(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        contenido: json['contenido'] as String,
        categoria: json['categoria'] as String? ?? 'Operaciones',
        fecha: DateTime.parse(json['fecha'] as String),
        revisadoConSupervisor: json['revisadoConSupervisor'] as bool? ?? false,
        pathFoto: json['pathFoto'] as String?,
      );

  NotaCampo copyWith({
    String? id,
    String? titulo,
    String? contenido,
    String? categoria,
    DateTime? fecha,
    bool? revisadoConSupervisor,
    String? pathFoto,
  }) {
    return NotaCampo(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      categoria: categoria ?? this.categoria,
      fecha: fecha ?? this.fecha,
      revisadoConSupervisor: revisadoConSupervisor ?? this.revisadoConSupervisor,
      pathFoto: pathFoto ?? this.pathFoto,
    );
  }
}
