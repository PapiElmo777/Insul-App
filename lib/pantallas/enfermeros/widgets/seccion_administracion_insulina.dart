import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../modelos/paciente_clinico.dart';
import '../../../../widgets/dialogo_administracion.dart';
import '../controlador_detalle_paciente.dart';
import '../pantalla_calculadora_enfermero.dart';

class SeccionAdministracionInsulina extends StatelessWidget {
  final ControladorDetallePaciente controlador;

  const SeccionAdministracionInsulina({super.key, required this.controlador});

  Future<void> _mostrarDialogoAgregarInsulina(BuildContext context) async {
    final guardado = await mostrarRegistroAdministracion(
        context,
        PacienteClinico(AmbitoPaciente.institucional, controlador.paciente['id'])
    );
    if (guardado && context.mounted) {
      await controlador.cargarDatosPaciente();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controlador.paciente['tipoDiabetes'] == 'Tipo 2') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text('Administraciones de insulina confirmadas', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black))),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.calculate, color: Color(0xFFE65100), size: 22),
                      tooltip: 'Calculadora ADA',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      onPressed: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PantallaCalculadoraEnfermero(paciente: controlador.paciente))
                        );
                        if (result == true) {
                          await controlador.cargarDatosPaciente();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  TextButton.icon(
                    onPressed: () => _mostrarDialogoAgregarInsulina(context),
                    icon: const Icon(Icons.colorize, color: Color(0xFF0C80EB), size: 20),
                    label: const Text('Añadir', style: TextStyle(color: Color(0xFF0C80EB), fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
          if (controlador.calculos.isNotEmpty)
            ExpansionTile(
                title: const Text('Cálculos guardados (no administrados)'),
                children: controlador.calculos.map((r) => ListTile(
                    title: Text('${r['dosis']} UI · dosis calculada'),
                    subtitle: Text(r['fecha'].toString())
                )).toList()
            ),
          if (controlador.insulinaAnterior.isNotEmpty)
            ExpansionTile(
                title: const Text('Insulina histórica sin confirmación verificable'),
                children: controlador.insulinaAnterior.map((r) => ListTile(
                    title: Text('${r['unidades']} UI · registro anterior'),
                    subtitle: Text(r['fecha'].toString())
                )).toList()
            ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD2D2D2))),
            child: controlador.historialInsulina.isEmpty
                ? const Text('No hay administraciones confirmadas.', style: TextStyle(color: Colors.grey))
                : Column(
              children: List.generate(controlador.historialInsulina.length, (index) {
                final ins = controlador.historialInsulina[index];
                final fechaStr = DateFormat('dd MMM yyyy - hh:mm a').format(ins['fecha']);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: Color(0xFFE8F4F8), child: Icon(Icons.water_drop, color: Color(0xFF008CCF))),
                  title: Text('${ins['unidades']} Unidades', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(fechaStr),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
