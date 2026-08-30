class SeccionApp {
  final String id;
  final String titulo;
  final String descripcion;
  final String emoji;
  final int colorIndex; // 1 a 13 para mapear a AppColors.menuX
  final String pilar; // "campo", "manual", "entrenamiento", "asistentes"

  const SeccionApp({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.emoji,
    required this.colorIndex,
    this.pilar = "manual",
  });
}
