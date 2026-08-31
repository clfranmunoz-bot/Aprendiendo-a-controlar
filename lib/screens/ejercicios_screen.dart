import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/app_routes.dart';
import 'package:aprender_a_controlar/screens/ejercicios/ejercicios_dashboard.dart';
import 'package:aprender_a_controlar/screens/ejercicios/ejercicios_ronda_view.dart';
import 'package:aprender_a_controlar/screens/ejercicios/ejercicios_entrenador_temas.dart';
import 'package:aprender_a_controlar/screens/ejercicios/ejercicios_banco_estatico.dart';

class EjerciciosScreen extends StatefulWidget {
  final Function(String)? onNavigate;

  const EjerciciosScreen({super.key, this.onNavigate});

  @override
  State<EjerciciosScreen> createState() => _EjerciciosScreenState();
}

enum ScreenMode {
  dashboard,
  activeDynamicRound,
  activeTopicTrainer,
  staticBank,
}

enum TrainerTopic { contra, fondo, recuperacion, regularizacion, perforado }

class _EjerciciosScreenState extends State<EjerciciosScreen> {
  ScreenMode _mode = ScreenMode.dashboard;
  TrainerTopic _trainerTopic = TrainerTopic.contra;
  String _title = "Ejercicios Prácticos";

  void _backToDashboard() {
    setState(() {
      _mode = ScreenMode.dashboard;
      _title = "Ejercicios Prácticos";
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_mode == ScreenMode.dashboard) {
              Navigator.pop(context);
            } else {
              // Ronda handles its own PopScope internally for active round warning.
              // So calling maybePop will trigger its PopScope or proceed back.
              if (_mode == ScreenMode.activeDynamicRound) {
                Navigator.maybePop(context);
              } else {
                _backToDashboard();
              }
            }
          },
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<ScreenMode>(_mode),
              child: _buildBody(colors),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppColors colors) {
    switch (_mode) {
      case ScreenMode.dashboard:
        return EjerciciosDashboard(
          onStartRound: () {
            setState(() {
              _mode = ScreenMode.activeDynamicRound;
            });
          },
          onStartTopicTrainer: (topic) {
            setState(() {
              _trainerTopic = topic;
              _mode = ScreenMode.activeTopicTrainer;
              final topicName = switch (topic) {
                TrainerTopic.contra => "Contra",
                TrainerTopic.fondo => "Fondo Pozo",
                TrainerTopic.recuperacion => "Recuperación",
                TrainerTopic.regularizacion => "Regularización",
                TrainerTopic.perforado => "Perforado",
              };
              _title = "Entrenador: $topicName";
            });
          },
          onStartStaticBank: () {
            setState(() {
              _mode = ScreenMode.staticBank;
              _title = "Banco de 60 Casos";
            });
          },
        );
      case ScreenMode.activeDynamicRound:
        return EjerciciosRondaView(
          onBack: _backToDashboard,
          onTitleChanged: (newTitle) {
            setState(() {
              _title = newTitle;
            });
          },
        );
      case ScreenMode.activeTopicTrainer:
        return EjerciciosEntrenadorTemas(
          onBack: _backToDashboard,
          initialTopic: _trainerTopic,
        );
      case ScreenMode.staticBank:
        return EjerciciosBancoEstatico(
          onBack: _backToDashboard,
        );
    }
  }
}
