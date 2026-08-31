import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aprender_a_controlar/models/mapa_punto.dart';
import 'package:aprender_a_controlar/services/utm_converter.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';

class MapaPuntoDetalleSheet extends StatelessWidget {
  final MapaPunto punto;
  final LatLngPoint? posicionUsuario;
  final VoidCallback onNavegarHacia;
  final VoidCallback? onEliminar;

  const MapaPuntoDetalleSheet({
    super.key,
    required this.punto,
    this.posicionUsuario,
    required this.onNavegarHacia,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    DistanceAzimuth? distanciaRumbo;
    if (posicionUsuario != null) {
      distanciaRumbo = UtmConverter.calculateDistanceAndAzimuth(
        posicionUsuario!.latitude,
        posicionUsuario!.longitude,
        punto.latitud,
        punto.longitud,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.superficie,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador superior para arrastrar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header: Nombre y Categoría
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(punto.categoria.colorHex).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(punto.categoria.colorHex), width: 1.5),
                    ),
                    child: Text(
                      punto.categoria.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          punto.nombre,
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          punto.categoria.titulo,
                          style: TextStyle(
                            color: colors.grisSecundario,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: punto.estado == 'En perforación'
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      punto.estado,
                      style: TextStyle(
                        color: punto.estado == 'En perforación' ? Colors.blue : Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Banner de Navegación / Distancia en vivo
              if (distanciaRumbo != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2979FF).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.navigation, color: Color(0xFF2979FF), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distancia en línea recta',
                              style: TextStyle(color: colors.grisSecundario, fontSize: 11),
                            ),
                            Text(
                              distanciaRumbo.distanceFormatted,
                              style: TextStyle(
                                color: colors.azulOscuro,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rumbo / Azimut',
                            style: TextStyle(color: colors.grisSecundario, fontSize: 11),
                          ),
                          Text(
                            distanciaRumbo.azimuthFormatted,
                            style: const TextStyle(
                              color: Color(0xFF2979FF),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Coordenadas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.fondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildCoordRow(
                      context,
                      'UTM ${punto.husoUtm}${punto.hemisferio}',
                      'E: ${punto.esteUtm.toStringAsFixed(1)} m  |  N: ${punto.norteUtm.toStringAsFixed(1)} m',
                      copyText: '${punto.esteUtm.toStringAsFixed(1)}, ${punto.norteUtm.toStringAsFixed(1)}',
                    ),
                    const Divider(height: 12),
                    _buildCoordRow(
                      context,
                      'WGS84 Lat/Lon',
                      '${punto.latitud.toStringAsFixed(5)}°, ${punto.longitud.toStringAsFixed(5)}°',
                      copyText: '${punto.latitud.toStringAsFixed(6)}, ${punto.longitud.toStringAsFixed(6)}',
                    ),
                    if (punto.cota != null) ...[
                      const Divider(height: 12),
                      _buildCoordRow(
                        context,
                        'Cota Z (Elevación)',
                        '${punto.cota!.toStringAsFixed(0)} msnm',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Parámetros de Sondaje
              if (punto.azimutPozo != null || punto.inclinacionPozo != null || punto.profundidadObjetivo != null) ...[
                Text(
                  'Parámetros Técnicos de Perforación',
                  style: TextStyle(
                    color: colors.azulOscuro,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (punto.azimutPozo != null)
                      Expanded(
                        child: _buildParamBox(
                          context,
                          'Azimut',
                          '${punto.azimutPozo!.toStringAsFixed(1)}°',
                          Icons.explore,
                        ),
                      ),
                    if (punto.inclinacionPozo != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildParamBox(
                          context,
                          'Dip / Inclinación',
                          '${punto.inclinacionPozo!.toStringAsFixed(1)}°',
                          Icons.south_east,
                        ),
                      ),
                    ],
                    if (punto.profundidadObjetivo != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildParamBox(
                          context,
                          'Prof. Obj.',
                          '${punto.profundidadObjetivo!.toStringAsFixed(0)} m',
                          Icons.straighten,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Observaciones
              if (punto.observaciones != null && punto.observaciones!.isNotEmpty) ...[
                Text(
                  'Observaciones de Terreno',
                  style: TextStyle(
                    color: colors.azulOscuro,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  punto.observaciones!,
                  style: TextStyle(color: colors.grisSecundario, fontSize: 13),
                ),
                const SizedBox(height: 16),
              ],

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2979FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.near_me, size: 20),
                      label: const Text('Fijar Guía de Rumbo', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        onNavegarHacia();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  if (punto.esPersonalizado && onEliminar != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: 'Eliminar punto',
                      onPressed: () {
                        onEliminar!();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoordRow(BuildContext context, String label, String value, {String? copyText}) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: colors.grisSecundario, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: colors.azulOscuro, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        if (copyText != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            color: colors.grisSecundario,
            tooltip: 'Copiar coordenadas',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: copyText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coordenadas copiadas al portapapeles'), duration: Duration(seconds: 1)),
              );
            },
          ),
      ],
    );
  }

  Widget _buildParamBox(BuildContext context, String label, String value, IconData icon) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.fondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: colors.naranjo),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: colors.grisSecundario, fontSize: 10)),
          Text(value, style: TextStyle(color: colors.azulOscuro, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
