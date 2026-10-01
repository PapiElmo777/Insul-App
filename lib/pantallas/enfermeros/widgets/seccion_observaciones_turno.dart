import 'package:flutter/material.dart';
import '../controlador_detalle_paciente.dart';

class SeccionObservacionesTurno extends StatelessWidget {
  final ControladorDetallePaciente controlador;

  const SeccionObservacionesTurno({super.key, required this.controlador});

  void _mostrarDialogoObservacion(BuildContext context) {
    final TextEditingController observacionCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Añadir Observación', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: observacionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Escriba nota del turno...', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (observacionCtrl.text.isNotEmpty) {
                  await controlador.agregarObservacion(observacionCtrl.text);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Añadir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text('Observaciones de Turno', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black))),
              TextButton.icon(
                onPressed: () => _mostrarDialogoObservacion(context),
                icon: const Icon(Icons.note_add, color: Color(0xFF0C80EB), size: 20),
                label: const Text('Añadir', style: TextStyle(color: Color(0xFF0C80EB), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (controlador.paciente['alergias'] != null && controlador.paciente['alergias'] != 'Ninguna')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(color: const Color(0xFFFFE5E5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD32F2F))),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F)),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Alergias: ${controlador.paciente['alergias']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)))),
                ],
              ),
            ),

          const SizedBox(height: 10),
          ...List.generate(controlador.observacionesBD.length, (index) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: const Color(0xFFFFF9E6), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFFFD166))),
              child: Text(controlador.observacionesBD[index], style: const TextStyle(fontSize: 14, color: Colors.black87)),
            );
          }),
        ],
      ),
    );
  }
}
