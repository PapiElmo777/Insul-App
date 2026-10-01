import 'package:flutter/material.dart';
import 'controlador_registro_cuidador.dart';
import 'pasos/paso_0_advertencias.dart';
import 'pasos/paso_1_tipo_paciente.dart';
import 'pasos/paso_2_perfil_paciente.dart';
import 'pasos/paso_3_parametros.dart';
import 'pasos/paso_4_medicacion.dart';
import 'pasos/paso_5_estilo_vida.dart';
import 'pasos/paso_6_identificacion.dart';

class PantallaCuestionarioCuidador extends StatefulWidget {
  const PantallaCuestionarioCuidador({super.key});

  @override
  State<PantallaCuestionarioCuidador> createState() => _PantallaCuestionarioCuidadorState();
}

class _PantallaCuestionarioCuidadorState extends State<PantallaCuestionarioCuidador> {
  final ControladorRegistroCuidador _controlador = ControladorRegistroCuidador();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C63BB),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controlador,
          builder: (context, _) {
            return Column(
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
                      Paso1TipoPaciente(controlador: _controlador),
                      Paso2PerfilPaciente(controlador: _controlador),
                      Paso3Parametros(controlador: _controlador),
                      Paso4Medicacion(controlador: _controlador),
                      Paso5EstiloVida(controlador: _controlador),
                      Paso6Identificacion(controlador: _controlador),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

