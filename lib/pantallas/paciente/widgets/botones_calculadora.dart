import 'package:flutter/material.dart';
import '../controlador_calculadora.dart';
import 'constantes_calculadora.dart';

class BotonesCalculadoraWidget extends StatelessWidget {
  final ControladorCalculadora controlador;
  final VoidCallback onCalcular;
  final VoidCallback onGuardar;

  const BotonesCalculadoraWidget({
    super.key,
    required this.controlador,
    required this.onCalcular,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton.icon(
            onPressed: onCalcular,
            icon: const Icon(Icons.calculate_outlined, size: 22),
            label: const Text(TextosCalculadora.btnCalcular, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1C63BB), foregroundColor: Colors.white, elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        if (controlador.calculado) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton.icon(
              onPressed: controlador.guardando ? null : onGuardar,
              icon: const Icon(Icons.save_alt, size: 22, color: Color(0xFF1C63BB)),
              label: const Text(TextosCalculadora.btnGuardar, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, elevation: 0,
                side: const BorderSide(color: Color(0xFF1C63BB), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 48,
            child: OutlinedButton.icon(
              onPressed: controlador.limpiarInputs,
              icon: const Icon(Icons.refresh_outlined, size: 20),
              label: const Text(TextosCalculadora.btnLimpiar, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF9E9E9E), side: const BorderSide(color: Color(0xFFD2D2D2), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
