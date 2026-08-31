import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/models/mapa_punto.dart';
import 'package:aprender_a_controlar/models/faena_mapa.dart';
import 'package:aprender_a_controlar/services/utm_converter.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';

class MapaNuevoPuntoDialog extends StatefulWidget {
  final FaenaMapa faena;
  final LatLngPoint? coordenadaInicial;

  const MapaNuevoPuntoDialog({
    super.key,
    required this.faena,
    this.coordenadaInicial,
  });

  @override
  State<MapaNuevoPuntoDialog> createState() => _MapaNuevoPuntoDialogState();
}

class _MapaNuevoPuntoDialogState extends State<MapaNuevoPuntoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _esteCtrl;
  late TextEditingController _norteCtrl;
  late TextEditingController _cotaCtrl;
  late TextEditingController _azimutCtrl;
  late TextEditingController _inclinacionCtrl;
  late TextEditingController _profundidadCtrl;
  late TextEditingController _observacionesCtrl;

  CategoriaPunto _categoria = CategoriaPunto.pozoDdh;
  final String _estado = 'En perforación';

  @override
  void initState() {
    super.initState();
    final initLat = widget.coordenadaInicial?.latitude ?? widget.faena.centerLat;
    final initLng = widget.coordenadaInicial?.longitude ?? widget.faena.centerLng;
    final initUtm = UtmConverter.latLonToUtm(initLat, initLng);

    _nombreCtrl = TextEditingController(text: 'DDH-PEL-');
    _esteCtrl = TextEditingController(text: initUtm.easting.toStringAsFixed(1));
    _norteCtrl = TextEditingController(text: initUtm.northing.toStringAsFixed(1));
    _cotaCtrl = TextEditingController(text: '3200');
    _azimutCtrl = TextEditingController(text: '0');
    _inclinacionCtrl = TextEditingController(text: '-90');
    _profundidadCtrl = TextEditingController(text: '300');
    _observacionesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _esteCtrl.dispose();
    _norteCtrl.dispose();
    _cotaCtrl.dispose();
    _azimutCtrl.dispose();
    _inclinacionCtrl.dispose();
    _profundidadCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final double easting = double.tryParse(_esteCtrl.text.replaceAll(',', '.')) ?? 0;
    final double northing = double.tryParse(_norteCtrl.text.replaceAll(',', '.')) ?? 0;
    final double? cota = double.tryParse(_cotaCtrl.text.replaceAll(',', '.'));
    final double? azimut = double.tryParse(_azimutCtrl.text.replaceAll(',', '.'));
    final double? inclinacion = double.tryParse(_inclinacionCtrl.text.replaceAll(',', '.'));
    final double? profundidad = double.tryParse(_profundidadCtrl.text.replaceAll(',', '.'));

    final latLon = UtmConverter.utmToLatLon(
      widget.faena.husoUtm,
      widget.faena.hemisferio,
      easting,
      northing,
      altitude: cota,
    );

    final nuevoPunto = MapaPunto(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      nombre: _nombreCtrl.text.trim(),
      categoria: _categoria,
      latitud: latLon.latitude,
      longitud: latLon.longitude,
      esteUtm: easting,
      norteUtm: northing,
      husoUtm: widget.faena.husoUtm,
      hemisferio: widget.faena.hemisferio,
      cota: cota,
      azimutPozo: azimut,
      inclinacionPozo: inclinacion,
      profundidadObjetivo: profundidad,
      estado: _estado,
      observaciones: _observacionesCtrl.text.trim().isEmpty ? null : _observacionesCtrl.text.trim(),
      esPersonalizado: true,
    );

    Navigator.of(context).pop(nuevoPunto);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Dialog(
      backgroundColor: colors.superficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.naranjo.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _categoria.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nuevo Pozo o Punto de Terreno',
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nombre
                  TextFormField(
                    controller: _nombreCtrl,
                    style: TextStyle(color: colors.azulOscuro),
                    decoration: InputDecoration(
                      labelText: 'Nombre / Identificador',
                      labelStyle: TextStyle(color: colors.grisSecundario),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa un nombre' : null,
                  ),
                  const SizedBox(height: 12),

                  // Categoría
                  DropdownButtonFormField<CategoriaPunto>(
                    value: _categoria,
                    dropdownColor: colors.superficie,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Punto',
                      labelStyle: TextStyle(color: colors.grisSecundario),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: CategoriaPunto.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          '${cat.emoji}  ${cat.titulo}',
                          style: TextStyle(color: colors.azulOscuro),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _categoria = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Coordenadas UTM
                  Text(
                    'Coordenadas UTM (Huso ${widget.faena.husoUtm}${widget.faena.hemisferio})',
                    style: TextStyle(
                      color: colors.azulOscuro,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _esteCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: colors.azulOscuro),
                          decoration: InputDecoration(
                            labelText: 'Este X (m)',
                            labelStyle: TextStyle(color: colors.grisSecundario),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Inválido' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _norteCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: colors.azulOscuro),
                          decoration: InputDecoration(
                            labelText: 'Norte Y (m)',
                            labelStyle: TextStyle(color: colors.grisSecundario),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Inválido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Cota y Profundidad
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cotaCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: colors.azulOscuro),
                          decoration: InputDecoration(
                            labelText: 'Cota Z (msnm)',
                            labelStyle: TextStyle(color: colors.grisSecundario),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _profundidadCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: colors.azulOscuro),
                          decoration: InputDecoration(
                            labelText: 'Prof. Obj (m)',
                            labelStyle: TextStyle(color: colors.grisSecundario),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Azimut e Inclinación (para pozos)
                  if (_categoria == CategoriaPunto.pozoDdh || _categoria == CategoriaPunto.pozoRc) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _azimutCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(color: colors.azulOscuro),
                            decoration: InputDecoration(
                              labelText: 'Azimut (°)',
                              labelStyle: TextStyle(color: colors.grisSecundario),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _inclinacionCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            style: TextStyle(color: colors.azulOscuro),
                            decoration: InputDecoration(
                              labelText: 'Inclinación / Dip (°)',
                              labelStyle: TextStyle(color: colors.grisSecundario),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Observaciones
                  TextFormField(
                    controller: _observacionesCtrl,
                    maxLines: 2,
                    style: TextStyle(color: colors.azulOscuro),
                    decoration: InputDecoration(
                      labelText: 'Observaciones / Notas',
                      labelStyle: TextStyle(color: colors.grisSecundario),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: colors.grisSecundario),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.naranjo,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Guardar Punto'),
                        onPressed: _guardar,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
