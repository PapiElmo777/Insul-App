import 'package:flutter/material.dart';
import '../controlador_detalle_paciente.dart';

class SeccionChecklistMedicamentos extends StatelessWidget {
  final ControladorDetallePaciente controlador;

  const SeccionChecklistMedicamentos({super.key, required this.controlador});

  Future<void> _confirmarMedicamento(BuildContext context, Map<String, dynamic> med, bool aplicado) async {
    if (controlador.guardandoMedicamento) return;
    
    final confirmado = await showDialog<bool>(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Text(aplicado ? 'Confirmar administración' : 'Corregir registro'),
        content: Text(aplicado
          ? 'Confirma que ya se administró ${med['nombre']} (${med['dosis']}).'
          : 'Se anulará la confirmación de ${med['nombre']} y se conservará la corrección en la bitácora.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(aplicado ? 'Ya fue administrado' : 'Anular confirmación'))
        ],
      )
    );
    
    if (confirmado != true || !context.mounted) {
      return;
    }
    
    final exito = await controlador.confirmarMedicamento(med, aplicado);
    if (!exito && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo registrar o actualizar. Intenta de nuevo o recarga la vista.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Checklist de Medicamentos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 15),
          if (controlador.medicamentos.isEmpty)
            const Text('No hay medicamentos registrados.', style: TextStyle(color: Colors.grey)),
          ...List.generate(controlador.medicamentos.length, (index) {
            final med = controlador.medicamentos[index];
            bool suministrado = med['suministrado'] == 1;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: suministrado ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F), width: 1.5)
              ),
              child: CheckboxListTile(
                title: Text('${med['nombre']} - ${med['dosis']}', style: TextStyle(fontWeight: FontWeight.bold, decoration: suministrado ? TextDecoration.lineThrough : null)),
                subtitle: Text('${med['frecuencia'] ?? ''}${med['suministrado_legacy'] == 1 && !suministrado ? ' · Registro anterior marcado, sin fecha verificable' : ''}'),
                value: suministrado,
                activeColor: const Color(0xFF2E7D32),
                checkColor: Colors.white,
                onChanged: controlador.guardandoMedicamento ? null : (val) => _confirmarMedicamento(context, med, val ?? false),
              ),
            );
          }),
        ],
      ),
    );
  }
}
