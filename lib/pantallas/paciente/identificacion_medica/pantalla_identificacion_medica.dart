import 'package:flutter/material.dart';

import 'controlador_id_medica.dart';
import 'widgets/formulario_id.dart';
import 'widgets/tarjeta_clinica.dart';

class PantallaIdentificacionMedica extends StatefulWidget {
  final VoidCallback onActualizarDashboard;

  const PantallaIdentificacionMedica({super.key, required this.onActualizarDashboard});

  @override
  State<PantallaIdentificacionMedica> createState() => _PantallaIdentificacionMedicaState();
}

class _PantallaIdentificacionMedicaState extends State<PantallaIdentificacionMedica> {
  late final ControladorIdMedica _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorIdMedica(onActualizarDashboard: widget.onActualizarDashboard);
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
          return const Scaffold(backgroundColor: Color(0xFFF5F7FA), body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB))));
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
