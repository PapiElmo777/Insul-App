import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controlador_detalle_paciente.dart';

class SeccionCabeceraPaciente extends StatelessWidget {
  final ControladorDetallePaciente controlador;

  const SeccionCabeceraPaciente({super.key, required this.controlador});

  void _mostrarDialogoEditarPerfil(BuildContext context) {
    final TextEditingController nombreEditCtrl = TextEditingController(text: controlador.paciente['nombre']);
    final TextEditingController edadEditCtrl = TextEditingController(text: controlador.paciente['edad']?.toString());
    final TextEditingController expEditCtrl = TextEditingController(text: controlador.paciente['expediente']);
    final TextEditingController ubiEditCtrl = TextEditingController(text: controlador.paciente['ubicacion']);
    final TextEditingController dietaEditCtrl = TextEditingController(text: controlador.paciente['dieta']);
    final TextEditingController alergiasEditCtrl = TextEditingController(text: controlador.paciente['alergias']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _crearCampoEdicion('Nombre', nombreEditCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Edad', edadEditCtrl, esNumero: true),
                const SizedBox(height: 10),
                _crearCampoEdicion('Expediente', expEditCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Ubicación (Cama/Piso)', ubiEditCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Dieta', dietaEditCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Alergias', alergiasEditCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                await controlador.actualizarPerfil({
                  'nombre': nombreEditCtrl.text,
                  'edad': edadEditCtrl.text,
                  'expediente': expEditCtrl.text,
                  'ubicacion': ubiEditCtrl.text,
                  'dieta': dietaEditCtrl.text,
                  'alergias': alergiasEditCtrl.text.isEmpty ? 'Ninguna' : alergiasEditCtrl.text,
                });
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _crearCampoEdicion(String label, TextEditingController controlador, {bool esNumero = false}) {
    return TextField(
      controller: controlador,
      keyboardType: esNumero ? TextInputType.number : TextInputType.text,
      inputFormatters: esNumero ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF008CCF), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Color(0xFF1C63BB),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controlador.paciente['nombre'] ?? 'Paciente', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(controlador.paciente['ubicacion'] ?? 'Ubicación sin asignar', style: const TextStyle(fontSize: 18, color: Color(0xFFE8E8E8))),
                const SizedBox(height: 4),
                Text('Edad: ${controlador.paciente['edad'] ?? '--'} | Dieta: ${controlador.paciente['dieta'] ?? 'Normal'}', style: const TextStyle(fontSize: 16, color: Color(0xFFE8E8E8))),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 28),
              onPressed: () => _mostrarDialogoEditarPerfil(context),
            ),
          ),
        ],
      ),
    );
  }
}
