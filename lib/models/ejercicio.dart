class EjercicioPractico {
  final String titulo;
  final String enunciado;
  final List<String> opciones;
  final int correcta;
  final String retroalimentacion;

  const EjercicioPractico({
    required this.titulo,
    required this.enunciado,
    required this.opciones,
    required this.correcta,
    required this.retroalimentacion,
  });
}
