import 'package:flutter/material.dart';

class DocumentoObligatorio {
  final String titulo;
  final String categoria;
  final String url;
  final IconData icono;

  const DocumentoObligatorio({
    required this.titulo,
    required this.categoria,
    required this.url,
    required this.icono,
  });
}

final List<DocumentoObligatorio> listaDocumentosObligatorios = [
  const DocumentoObligatorio(
    titulo: "Trabajos cruzados",
    categoria: "Permisos",
    url: "https://drive.google.com/drive/folders/1gIcTYHyuup6ReYIfB76x5qJr1gcDakpd?usp=sharing",
    icono: Icons.swap_horiz,
  ),
  const DocumentoObligatorio(
    titulo: "Permiso ingreso al área",
    categoria: "Permisos",
    url: "https://drive.google.com/drive/folders/17FET-OwnQEoTfScgBVxmtr575eqJ8b3d?usp=sharing",
    icono: Icons.assignment_ind,
  ),
  const DocumentoObligatorio(
    titulo: "Checklist EPR",
    categoria: "Checklists",
    url: "https://drive.google.com/drive/folders/1uDfqiaFj1R6yJc_z9QUs8f0TyXDUkMOc?usp=sharing",
    icono: Icons.check_box,
  ),
  const DocumentoObligatorio(
    titulo: "Checklist EPA",
    categoria: "Checklists",
    url: "https://drive.google.com/drive/folders/1n7W8XNf5KrVW2x3ybT6EBFzC7pp25G5h?usp=sharing",
    icono: Icons.fact_check,
  ),
  const DocumentoObligatorio(
    titulo: "Checklist de Mano",
    categoria: "Checklists",
    url: "https://drive.google.com/drive/folders/1oqdhOHJt648UPJgSynfZUNLNBAroY-ud?usp=sharing",
    icono: Icons.checklist,
  ),
  const DocumentoObligatorio(
    titulo: "Cartilla CERC",
    categoria: "Controles",
    url: "https://drive.google.com/drive/folders/1_YFElNw4APR_rFHX4FhXQi5I0GZzFyDs?usp=sharing",
    icono: Icons.assignment,
  ),
  const DocumentoObligatorio(
    titulo: "ARTP Control",
    categoria: "Controles",
    url: "https://drive.google.com/drive/folders/11474k3ijqJMa4DFb4xFguf9Ws-7Nkxlq?usp=sharing",
    icono: Icons.verified_user,
  ),
];
