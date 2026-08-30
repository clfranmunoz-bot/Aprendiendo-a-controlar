import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/app_routes.dart';
import 'package:aprender_a_controlar/screens/calculadoras/recuperacion_tab.dart';
import 'package:aprender_a_controlar/screens/calculadoras/contra_tab.dart';
import 'package:aprender_a_controlar/screens/calculadoras/fondo_tab.dart';
import 'package:aprender_a_controlar/screens/calculadoras/regularizacion_tab.dart';
import 'package:aprender_a_controlar/screens/calculadoras/perforado_tab.dart';

class CalculadorasScreen extends StatefulWidget {
  final int initialTab;
  final Function(String)? onNavigate;

  const CalculadorasScreen({
    super.key,
    this.initialTab = 0,
    this.onNavigate,
  });

  @override
  State<CalculadorasScreen> createState() => _CalculadorasScreenState();
}

class _CalculadorasScreenState extends State<CalculadorasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculadoras operacionales"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: "Volver al Inicio",
            onPressed: () {
              if (widget.onNavigate != null) {
                widget.onNavigate!(AppRoutes.home);
              } else {
                Navigator.popUntil(context, (r) => r.isFirst);
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: colors.azul,
          unselectedLabelColor: colors.grisTexto,
          indicatorColor: colors.azul,
          tabs: const [
            Tab(text: "Recuperación"),
            Tab(text: "Contra"),
            Tab(text: "Fondo Pozo"),
            Tab(text: "Regularización"),
            Tab(text: "Perforado"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RecuperacionTab(),
          ContraTab(),
          FondoTab(),
          RegularizacionTab(),
          PerforadoTab(),
        ],
      ),
    );
  }
}
