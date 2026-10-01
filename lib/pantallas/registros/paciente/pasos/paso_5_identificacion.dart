import 'package:flutter/material.dart';
import '../controlador_registro_paciente.dart';
import '../ui_helpers.dart';

class Paso5Identificacion extends StatelessWidget {
  final ControladorRegistroPaciente controlador;

  const Paso5Identificacion({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.badge, size: 60, color: Colors.white),
          const SizedBox(height: 20),
          const Text('Identificación Médica', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 5 de 5', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          crearTarjetaGlass(
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('¿Por qué es vital?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text(
                  'Las directrices de la ADA (Asociación Americana de Diabetes) establecen que toda persona con diabetes debe portar una identificación médica visible.  En caso de una emergencia donde el paciente no pueda comunicarse, esto puede salvar tu vida indicando a los paramédicos cómo actuar.',
                  style: TextStyle(fontSize: 15, color: Color(0xFFE8E8E8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          const Text('¿Deseas configurar tu Identificación Médica de Emergencia ahora?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () {
                controlador.guardarDatosPacienteYFinalizar(context, irAIdentificacion: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D1FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Sí, empezar ahora', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ),
          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity, height: 50,
            child: OutlinedButton(
              onPressed: () {
                controlador.guardarDatosPacienteYFinalizar(context, irAIdentificacion: false);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Hacerlo después', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
