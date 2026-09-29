import 'package:flutter/material.dart';
import '../controlador_registro_cuidador.dart';
import '../ui_helpers.dart';

class Paso5EstiloVida extends StatelessWidget {
  final ControladorRegistroCuidador controlador;

  const Paso5EstiloVida({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    bool fase5Completa = controlador.medicoNombreCtrl.text.isNotEmpty;

    if (controlador.tipoPaciente == 'Adulto Mayor') {
      fase5Completa = fase5Completa && controlador.riesgoCaidas != null && controlador.estadoCognitivo != null;
    } else if (controlador.tipoPaciente == 'Menor de Edad') {
      fase5Completa = fase5Completa && controlador.autonomiaMenor != null && controlador.contactoEscolarCtrl.text.isNotEmpty;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estilo de Vida y Seguridad', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 5 de 6', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.shield_outlined, color: Color(0xFF00D1FF), size: 28),
                      SizedBox(width: 10),
                      Text('Seguridad y Vigilancia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Como cuidador, eres el pilar principal. Mantén las notificaciones de Insul App activadas y verifica constantemente el estado del paciente. La tecnología es un apoyo, pero tu atención es insustituible.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              )
          ),
          const SizedBox(height: 25),
          crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Médico Tratante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  const Text('¿A quién irán dirigidos los reportes clínicos?', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                  const SizedBox(height: 20),
                  crearCampoTexto(titulo: 'Nombre completo del Médico', hint: 'Ej. Dra. Carmen Ruiz', controlador: controlador.medicoNombreCtrl, esNumero: false),
                ],
              )
          ),
          const SizedBox(height: 25),
          if (controlador.tipoPaciente == 'Adulto Mayor') ...[
            crearTarjetaGlass(
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Consideraciones del Adulto Mayor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 20),

                    const Text('Riesgo de Caídas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 5),
                    const Text('¿El paciente usa andadera, bastón o silla de ruedas? (Una baja de azúcar causa mareos y puede ser crítico).', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                    const SizedBox(height: 10),
                    crearDropdown(
                        valorActual: controlador.riesgoCaidas,
                        hint: 'Selecciona opción',
                        opciones: controlador.opcionesRiesgoCaidas,
                        onChange: (val) => controlador.setRiesgoCaidas(val)
                    ),
                    const SizedBox(height: 20),

                    const Text('Estado Cognitivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 5),
                    const Text('¿El paciente es capaz de avisar verbalmente si se siente mal?', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                    const SizedBox(height: 10),
                    crearDropdown(
                        valorActual: controlador.estadoCognitivo,
                        hint: 'Selecciona opción',
                        opciones: controlador.opcionesEstadoCognitivo,
                        onChange: (val) => controlador.setEstadoCognitivo(val)
                    ),
                  ],
                )
            ),
            const SizedBox(height: 40),
          ],
          if (controlador.tipoPaciente == 'Menor de Edad') ...[
            crearTarjetaGlass(
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Consideraciones del Menor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 20),

                    const Text('Autonomía', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 5),
                    const Text('¿El niño ya reconoce sus propios síntomas cuando se le baja el azúcar?', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: crearChipSeleccion('Sí', controlador.autonomiaMenor == 'Sí', () => controlador.setAutonomiaMenor('Sí'))),
                        const SizedBox(width: 15),
                        Expanded(child: crearChipSeleccion('Aún no', controlador.autonomiaMenor == 'Aún no', () => controlador.setAutonomiaMenor('Aún no'))),
                      ],
                    ),
                    const SizedBox(height: 25),

                    const Text('Contacto Escolar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 5),
                    const Text('Solicitamos el teléfono de la escuela o maestro para generar un "Protocolo de Emergencia Escolar" en el futuro.', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                    const SizedBox(height: 10),
                    crearCampoTexto(titulo: 'Teléfono', hint: '10 dígitos', controlador: controlador.contactoEscolarCtrl, esNumero: true),
                  ],
                )
            ),
            const SizedBox(height: 40),
          ],

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase5Completa ? controlador.siguientePaso : null,
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
