class TerminoGlosario {
  final String termino;
  final String definicion;
  final String categoria;

  const TerminoGlosario({
    required this.termino,
    required this.definicion,
    this.categoria = 'General',
  });
}
