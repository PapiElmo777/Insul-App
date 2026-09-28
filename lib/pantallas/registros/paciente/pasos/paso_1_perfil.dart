import 'package:flutter/material.dart';
import '../controlador_registro_paciente.dart';
import '../ui_helpers.dart';

class Paso1Perfil extends StatelessWidget {
  final ControladorRegistroPaciente controlador;

  const Paso1Perfil({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    bool fase1Completa = controlador.sexo != null &&
        controlador.edadCtrl.text.isNotEmpty &&
        controlador.tiempoDx != null &&
        controlador.tipoDiabetes != null &&
        controlador.pesoCtrl.text.isNotEmpty &&
        controlador.alturaCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Perfil Clínico', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 1 de 5', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          const Text('Género', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: crearChipSeleccion('Hombre', controlador.sexo == 'Hombre', () => controlador.actualizarSexo('Hombre'))),
              const SizedBox(width: 15),
              Expanded(child: crearChipSeleccion('Mujer', controlador.sexo == 'Mujer', () => controlador.actualizarSexo('Mujer'))),
            ],
          ),
          const SizedBox(height: 20),

          crearCampoTexto(titulo: 'Edad', hint: 'Años', controlador: controlador.edadCtrl, esNumero: true, onChanged: controlador.refrescarUI),
          const SizedBox(height: 3),

          const Text('Tiempo con diagnóstico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 5),
          crearDropdown(valorActual: controlador.tiempoDx, hint: 'Selecciona una opción', opciones: controlador.opcionesTiempoDx, onChange: controlador.actualizarTiempoDx),
          const SizedBox(height: 20),

          const Text('Tipo de Diabetes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 5),
          crearDropdown(valorActual: controlador.tipoDiabetes, hint: 'Ej. Tipo 1', opciones: controlador.opcionesTipoDiabetes, onChange: controlador.actualizarTipoDiabetes),
          const SizedBox(height: 20),

          crearCampoTexto(titulo: 'Alergias Conocidas (Opcional)', hint: 'Ej. Penicilina, Ninguna', controlador: controlador.alergiasCtrl, esNumero: false, onChanged: controlador.refrescarUI),
          const SizedBox(height: 20),

          crearCampoTexto(titulo: 'Hospitalizaciones Recientes (Opcional)', hint: 'Ej. Ninguna', controlador: controlador.hospitalizacionesCtrl, esNumero: false, onChanged: controlador.refrescarUI),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: crearCampoTexto(titulo: 'Peso (kg)', hint: 'Ej. 75', controlador: controlador.pesoCtrl, esNumero: true, focusNode: controlador.pesoFocus, onChanged: controlador.refrescarUI)),
              const SizedBox(width: 15),
              Expanded(child: crearCampoTexto(titulo: 'Altura (cm)', hint: 'Ej. 170', controlador: controlador.alturaCtrl, esNumero: true, focusNode: controlador.alturaFocus, onChanged: controlador.refrescarUI)),
            ],
          ),
          const SizedBox(height: 15),

          crearTarjetaGlass(
              hijo: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tu I.M.C. calculado:', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                    controlador.imc > 0 ? controlador.imc.toStringAsFixed(1) : '--',
                    style: const TextStyle(fontSize: 24, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold),
                  ),
                ],
              )
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
