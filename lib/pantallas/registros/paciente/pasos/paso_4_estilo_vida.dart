import 'package:flutter/material.dart';
import '../controlador_registro_paciente.dart';
import '../ui_helpers.dart';

class Paso4EstiloVida extends StatelessWidget {
  final ControladorRegistroPaciente controlador;

  const Paso4EstiloVida({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    bool fase4Completa = controlador.actividadFisica != null &&
        controlador.emergenciaNombreCtrl.text.isNotEmpty &&
        controlador.emergenciaParentescoCtrl.text.isNotEmpty &&
        controlador.emergenciaTelefonoCtrl.text.isNotEmpty &&
        controlador.medicoNombreCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estilo de Vida y Seguridad', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 4 de 5', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nivel de Actividad Física', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  const Text('El ejercicio aumenta la sensibilidad a la insulina, usaremos esto para ajustar sugerencias.', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                  const SizedBox(height: 15),
                  crearDropdown(
                      valorActual: controlador.actividadFisica,
                      hint: 'Selecciona tu nivel',
                      opciones: controlador.opcionesActividad,
                      onChange: controlador.actualizarActividadFisica
                  ),
                ],
              )
          ),
          const SizedBox(height: 20),

          crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.emergency, color: Color(0xFFFF6B6B)),
                      SizedBox(width: 10),
                      Text('Contacto de Emergencia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  crearCampoTexto(titulo: 'Nombre del contacto', hint: 'Ej. María Pérez', controlador: controlador.emergenciaNombreCtrl, esNumero: false, onChanged: controlador.refrescarUI),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(flex: 1, child: crearCampoTexto(titulo: 'Parentesco', hint: 'Ej. Madre', controlador: controlador.emergenciaParentescoCtrl, esNumero: false, onChanged: controlador.refrescarUI)),
                      const SizedBox(width: 15),
                      Expanded(flex: 2, child: crearCampoTexto(titulo: 'Teléfono', hint: '10 dígitos', controlador: controlador.emergenciaTelefonoCtrl, esNumero: true, onChanged: controlador.refrescarUI)),
                    ],
                  ),
                ],
              )
          ),
          const SizedBox(height: 20),

          crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.medical_information, color: Color(0xFF00D1FF)),
                      SizedBox(width: 10),
                      Text('Médico Tratante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('¿A quién irán dirigidos tus reportes clínicos?', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                  const SizedBox(height: 20),
                  crearCampoTexto(titulo: 'Nombre completo del Médico', hint: 'Ej. Dr. Roberto Gómez', controlador: controlador.medicoNombreCtrl, esNumero: false, onChanged: controlador.refrescarUI),
                ],
              )
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase4Completa ? controlador.siguientePaso : null,
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
