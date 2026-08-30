class Pregunta {
  final String enunciado;
  final List<String> opciones;
  final int correcta;
  final String retroalimentacion;
  final String? codigoProcedimiento;

  const Pregunta({
    required this.enunciado,
    required this.opciones,
    required this.correcta,
    required this.retroalimentacion,
    this.codigoProcedimiento,
  });
}
