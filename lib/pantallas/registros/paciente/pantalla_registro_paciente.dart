import 'package:flutter/material.dart';
import 'controlador_registro_paciente.dart';
import 'pasos/paso_0_advertencias.dart';
import 'pasos/paso_1_perfil.dart';
import 'pasos/paso_2_parametros.dart';
import 'pasos/paso_3_medicacion.dart';
import 'pasos/paso_4_estilo_vida.dart';
import 'pasos/paso_5_identificacion.dart';

class PantallaCuestionarioPaciente extends StatefulWidget {
  const PantallaCuestionarioPaciente({super.key});

  @override
  State<PantallaCuestionarioPaciente> createState() => _PantallaCuestionarioPacienteState();
}

class _PantallaCuestionarioPacienteState extends State<PantallaCuestionarioPaciente> {
  final ControladorRegistroPaciente _controlador = ControladorRegistroPaciente();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controlador,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF1C63BB),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _controlador.pasoAnterior(context),
                        child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: List.generate(_controlador.totalPasos, (index) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                                height: 4.0,
                                decoration: BoxDecoration(
                                  color: index <= _controlador.pasoActual ? const Color(0xFF00D1FF) : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controlador.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Paso0Advertencias(controlador: _controlador),
                      Paso1Perfil(controlador: _controlador),
                      Paso2Parametros(controlador: _controlador),
                      Paso3Medicacion(controlador: _controlador),
                      Paso4EstiloVida(controlador: _controlador),
                      Paso5Identificacion(controlador: _controlador),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
