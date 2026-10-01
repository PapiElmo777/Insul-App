import 'package:flutter/material.dart';
import '../controlador_registro_cuidador.dart';
import '../ui_helpers.dart';

class Paso2PerfilPaciente extends StatelessWidget {
  final ControladorRegistroCuidador controlador;

  const Paso2PerfilPaciente({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    bool fase2Completa = controlador.sexoPaciente != null && controlador.edadPacienteCtrl.text.isNotEmpty && controlador.tiempoDxPaciente != null && controlador.tipoDiabetesPaciente != null && controlador.pesoPacienteCtrl.text.isNotEmpty && controlador.alturaPacienteCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Perfil Clínico del Paciente', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 2 de 6', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          const Text('Sexo Biológico del Paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: crearChipSeleccion('Hombre', controlador.sexoPaciente == 'Hombre', () => controlador.setSexoPaciente('Hombre'))),
              const SizedBox(width: 15),
              Expanded(child: crearChipSeleccion('Mujer', controlador.sexoPaciente == 'Mujer', () => controlador.setSexoPaciente('Mujer'))),
            ],
          ),
          const SizedBox(height: 20),

          crearCampoTexto(titulo: 'Edad del Paciente', hint: 'Años', controlador: controlador.edadPacienteCtrl, esNumero: true),
          const SizedBox(height: 3),

          const Text('Tiempo con diagnóstico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 5),
          crearDropdown(valorActual: controlador.tiempoDxPaciente, hint: 'Selecciona una opción', opciones: controlador.opcionesTiempoDx, onChange: (val) => controlador.setTiempoDxPaciente(val)),
          const SizedBox(height: 20),

          const Text('Tipo de Diabetes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 5),
          crearDropdown(valorActual: controlador.tipoDiabetesPaciente, hint: 'Ej. Tipo 1', opciones: controlador.opcionesTipoDiabetes, onChange: (val) => controlador.setTipoDiabetesPaciente(val)),
          const SizedBox(height: 20),

          crearCampoTexto(titulo: 'Alergias Conocidas (Opcional)', hint: 'Ej. Penicilina, Ninguna', controlador: controlador.alergiasPacienteCtrl, esNumero: false),
          const SizedBox(height: 20),

          crearCampoTexto(titulo: 'Hospitalizaciones Recientes (Opcional)', hint: 'Ej. Ninguna', controlador: controlador.hospitalizacionesCtrl, esNumero: false),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: crearCampoTexto(titulo: 'Peso (kg)', hint: 'Ej. 75', controlador: controlador.pesoPacienteCtrl, esNumero: true, focusNode: controlador.pesoFocus)),
              const SizedBox(width: 15),
              Expanded(child: crearCampoTexto(titulo: 'Altura (cm)', hint: 'Ej. 170', controlador: controlador.alturaPacienteCtrl, esNumero: true, focusNode: controlador.alturaFocus)),
            ],
          ),
          const SizedBox(height: 15),

          crearTarjetaGlass(
              hijo: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('I.M.C. del Paciente:', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                    controlador.imcPaciente > 0 ? controlador.imcPaciente.toStringAsFixed(1) : '--',
                    style: const TextStyle(fontSize: 24, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold),
                  ),
                ],
              )
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase2Completa ? controlador.siguientePaso : null,
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
