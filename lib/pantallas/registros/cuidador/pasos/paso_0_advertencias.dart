import 'package:flutter/material.dart';
import '../controlador_registro_cuidador.dart';
import '../ui_helpers.dart';

class Paso0Advertencias extends StatelessWidget {
  final ControladorRegistroCuidador controlador;

  const Paso0Advertencias({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety, size: 60, color: Colors.white),
          const SizedBox(height: 20),
          const Text('Bienvenido Cuidador', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          crearTarjetaGlass(
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('¿Por qué pedimos estos datos?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text(
                  'Para ayudarte a brindar el mejor cuidado, Insul App necesita conocer el perfil clínico de la persona a tu cargo. Esto nos permitirá ajustar las alertas, recordatorios y protocolos de acción.',
                  style: TextStyle(fontSize: 15, color: Color(0xFFE8E8E8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          crearTarjetaGlass(
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Aviso Médico Importante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text(
                  'Esta aplicación es una herramienta de apoyo para tu labor diaria. NO sustituye la consulta médica ni emite diagnósticos. Todas las decisiones críticas deben basarse en las indicaciones del médico tratante.',
                  style: TextStyle(fontSize: 15, color: Color(0xFFE8E8E8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Checkbox(
                value: controlador.aceptoTerminos,
                activeColor: const Color(0xFF00D1FF),
                checkColor: const Color(0xFF1C63BB),
                side: const BorderSide(color: Colors.white, width: 2),
                onChanged: (val) {
                  controlador.setAceptoTerminos(val ?? false);
                },
              ),
              const Expanded(
                child: Text('He leído y comprendo mi responsabilidad al usar la app.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: controlador.aceptoTerminos ? controlador.siguientePaso : null,
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
