import 'package:flutter/material.dart';
import '../controlador_registro_paciente.dart';
import '../ui_helpers.dart';

class Paso2Parametros extends StatelessWidget {
  final ControladorRegistroPaciente controlador;

  const Paso2Parametros({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    bool fase2Completa = controlador.hipoCtrl.text.isNotEmpty &&
        controlador.hiperCtrl.text.isNotEmpty &&
        controlador.rangoMinCtrl.text.isNotEmpty &&
        controlador.rangoMaxCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Parámetros de Control', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 2 de 5', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),

          crearTarjetaGlass(
            hijo: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF00D1FF), size: 30),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    'Los valores por defecto y acciones correctivas están basados en las Guías Oficiales de la ADA. Puedes modificarlos si tu médico te indicó rangos distintos.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          _construirGraficoGlucosa(),
          const SizedBox(height: 30),

          crearCampoTexto(titulo: 'Límite de Hipoglucemia (mg/dL)', hint: 'Ej. 70', controlador: controlador.hipoCtrl, esNumero: true, onChanged: controlador.refrescarUI),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
            child: Text('⚠️ Debajo de este valor, la app disparará el protocolo de acción inmediata.', style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 13)),
          ),

          crearCampoTexto(titulo: 'Límite de Hiperglucemia (mg/dL)', hint: 'Ej. 180', controlador: controlador.hiperCtrl, esNumero: true, onChanged: controlador.refrescarUI),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
            child: Text('⚠️ Por encima de este valor, se activarán las alertas de control.', style: TextStyle(color: Color(0xFFFFB347), fontSize: 13)),
          ),

          const Text('Rangos Normales Objetivo (mg/dL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: crearCampoTexto(titulo: 'Mínimo', hint: '80', controlador: controlador.rangoMinCtrl, esNumero: true, onChanged: controlador.refrescarUI)),
              const SizedBox(width: 15),
              Expanded(child: crearCampoTexto(titulo: 'Máximo', hint: '130', controlador: controlador.rangoMaxCtrl, esNumero: true, onChanged: controlador.refrescarUI)),
            ],
          ),
          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(15)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Configuración Avanzada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                crearCampoTexto(titulo: 'Factor de Sensibilidad (FSI)', hint: 'Ej. 50', controlador: controlador.fsiCtrl, esNumero: true, activo: true, onChanged: controlador.refrescarUI),
                const SizedBox(height: 10),
                crearCampoTexto(titulo: 'Relación Insulina/Carbos (RIC)', hint: 'Ej. 15', controlador: controlador.ricCtrl, esNumero: true, activo: true, onChanged: controlador.refrescarUI),
              ],
            ),
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

  Widget _construirGraficoGlucosa() {
    String hipo = controlador.hipoCtrl.text.isEmpty ? '--' : controlador.hipoCtrl.text;
    String rMin = controlador.rangoMinCtrl.text.isEmpty ? '--' : controlador.rangoMinCtrl.text;
    String rMax = controlador.rangoMaxCtrl.text.isEmpty ? '--' : controlador.rangoMaxCtrl.text;
    String hiper = controlador.hiperCtrl.text.isEmpty ? '--' : controlador.hiperCtrl.text;

    return crearTarjetaGlass(
        hijo: Column(
          children: [
            const Text('Espectro de Glucosa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Text('Hipo', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFF6B6B),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('< $hipo', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Text('Normal', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        color: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 8),
                      Text('$rMin - $rMax', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Text('Hiper', style: TextStyle(color: Color(0xFFFFB347), fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFFB347),
                            borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('> $hiper', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            )
          ],
        )
    );
  }
}
