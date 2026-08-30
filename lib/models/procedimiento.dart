import 'package:flutter/material.dart';

class Procedimiento {
  final String codigo;
  final String titulo;
  final String categoria;
  final String url;
  final IconData icono;

  const Procedimiento({
    required this.codigo,
    required this.titulo,
    required this.categoria,
    required this.url,
    required this.icono,
  });
}

final List<Procedimiento> listaProcedimientos = [
  const Procedimiento(
    codigo: "PE-GM-001",
    titulo: "PROCEDIMIENTO OPERACIÓN INVIERNO 2026 V4",
    categoria: "Operaciones",
    url: "https://drive.google.com/drive/folders/1eLFE6oj27x0d163tl5QihuHYrOjsR1zC?usp=sharing",
    icono: Icons.ac_unit,
  ),
  const Procedimiento(
    codigo: "PRO-OP-CSO-MLP-03",
    titulo: "POSTURA DE CADENAS 2026",
    categoria: "Seguridad y Vehículos",
    url: "https://drive.google.com/drive/folders/1lY7OgSoP1NLhFVsHtmRemypUuWjaMNd5?usp=sharing",
    icono: Icons.link_off,
  ),
  const Procedimiento(
    codigo: "PRO-OP-MLP-08",
    titulo: "TRASLADO Y USO DE CASETA GEOATACAMA V.09",
    categoria: "Operaciones",
    url: "https://drive.google.com/drive/folders/1RxwQPKUw-SWHdi2UbojG532IyesjBZDi?usp=sharing",
    icono: Icons.roofing,
  ),
  const Procedimiento(
    codigo: "PRO-OP-MLP-CS-02",
    titulo: "CONDUCCIÓN DE VEHÍCULO LIVIANO",
    categoria: "Seguridad y Vehículos",
    url: "https://drive.google.com/drive/folders/1EvIQTbOUdP6Sxm68uzNnYIbGnZYoY0od?usp=sharing",
    icono: Icons.directions_car,
  ),
  const Procedimiento(
    codigo: "PRO-OP-MLP-CS-07",
    titulo: "CONTROL OPERACIONAL DE SONDAJE DIAMANTINO V11",
    categoria: "Operaciones",
    url: "https://drive.google.com/drive/folders/1bzEFb3uH_yc75Xi_tFmyqD5rJW_4w_ps?usp=sharing",
    icono: Icons.construction,
  ),
  const Procedimiento(
    codigo: "RO-GR-OPI-001",
    titulo: "REGLAMENTO OPERACIONES EN CONDICIONES CLIMÁTICAS ADVERSAS 2026 V10",
    categoria: "Operaciones",
    url: "https://drive.google.com/drive/folders/1cFEaXxSyTvFlbLuN1TgDqlwegr159XtD?usp=sharing",
    icono: Icons.thunderstorm,
  ),
  const Procedimiento(
    codigo: "PRO-SO-MLP-CS-05",
    titulo: "Procedimiento FYS",
    categoria: "Seguridad",
    url: "https://drive.google.com/drive/folders/184iFQelwfW16sgan0iMkWD2Y7VKVUj_d?usp=sharing",
    icono: Icons.shield,
  ),
  const Procedimiento(
    codigo: "PRO-SO-MLP-06",
    titulo: "PLAN DE GESTIÓN DE RIESGOS DE EMERGENCIAS, CATÁSTROFES O DESASTRES",
    categoria: "Emergencias y Riesgos",
    url: "https://drive.google.com/drive/folders/1RjaFt78RHCHACYtCfpCO-AReHrgsaEb3?usp=sharing",
    icono: Icons.emergency,
  ),
];
