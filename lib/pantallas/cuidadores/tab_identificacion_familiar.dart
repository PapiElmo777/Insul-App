import 'package:flutter/material.dart';

import '../paciente/identificacion_medica/controlador_id_medica.dart';
import '../paciente/identificacion_medica/widgets/formulario_id.dart';
import '../paciente/identificacion_medica/widgets/tarjeta_clinica.dart';

class TabIdentificacionFamiliar extends StatefulWidget {
  final int familiarId;
  final VoidCallback onActualizarDashboard;

  const TabIdentificacionFamiliar({
    super.key,
    required this.familiarId,
    required this.onActualizarDashboard
  });

  @override
  State<TabIdentificacionFamiliar> createState() => _TabIdentificacionFamiliarState();
}

class _TabIdentificacionFamiliarState extends State<TabIdentificacionFamiliar> {
  late final ControladorIdMedica _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorIdMedica(
      onActualizarDashboard: widget.onActualizarDashboard, 
      pacienteIdProporcionado: widget.familiarId, 
      esCuidador: true
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controlador,
      builder: (context, child) {
        if (_controlador.cargando) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7FA), 
            body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB)))
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: _controlador.identificacionCompletada 
              ? TarjetaClinica(controlador: _controlador) 
              : FormularioId(controlador: _controlador),
        );
      },
    );
  }
}