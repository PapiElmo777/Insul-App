import 'package:flutter/material.dart';
import '../controlador_registro_cuidador.dart';
import '../ui_helpers.dart';

class Paso1TipoPaciente extends StatelessWidget {
  final ControladorRegistroCuidador controlador;

  const Paso1TipoPaciente({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    bool fase1Completa = controlador.tipoPaciente != null && controlador.parentescoCtrl.text.isNotEmpty && controlador.nombrePacienteCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Datos Generales del Paciente', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 1 de 6', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          const Text('¿A quién estás cuidando?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 15),

          crearOpcionPaciente(
            titulo: 'Adulto Mayor',
            icono: Icons.elderly,
            seleccionado: controlador.tipoPaciente == 'Adulto Mayor',
            onTap: () => controlador.setTipoPaciente('Adulto Mayor'),
          ),
          const SizedBox(height: 10),
          crearOpcionPaciente(
            titulo: 'Menor de Edad / Niño',
            icono: Icons.child_care,
            seleccionado: controlador.tipoPaciente == 'Menor de Edad',
            onTap: () => controlador.setTipoPaciente('Menor de Edad'),
          ),
          const SizedBox(height: 10),
          crearOpcionPaciente(
            titulo: 'Persona con Discapacidad',
            icono: Icons.accessible,
            seleccionado: controlador.tipoPaciente == 'Discapacidad',
            onTap: () => controlador.setTipoPaciente('Discapacidad'),
          ),
          const SizedBox(height: 30),

          crearCampoTexto(
              titulo: 'Tu parentesco o relación con el paciente',
              hint: 'Ej. Hijo, Madre, Enfermero particular...',
              controlador: controlador.parentescoCtrl,
              esNumero: false
          ),
          const SizedBox(height: 20),
          crearCampoTexto(
              titulo: 'Nombre del paciente',
              hint: 'Ej. Juan Pérez',
              controlador: controlador.nombrePacienteCtrl,
              esNumero: false
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase1Completa ? controlador.siguientePaso : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008CCF),
                disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Siguiente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
