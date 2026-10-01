import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controlador_dashboard_enfermero.dart';
import '../pantalla_inicio_enfermero.dart'; // Para VisorPdfPantalla (O moverlo a un archivo separado)

class TabReportesEnfermero extends StatelessWidget {
  final ControladorDashboardEnfermero controlador;

  const TabReportesEnfermero({super.key, required this.controlador});

  Future<String?> preguntarTurno(BuildContext context) async {
    String? turnoSeleccionado = 'Matutino';
    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Generar Reporte de Turno', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona el turno que deseas finalizar:'),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: turnoSeleccionado,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: ['Matutino', 'Vespertino', 'Nocturno']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setStateDialog(() { turnoSeleccionado = value; });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, turnoSeleccionado),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C80EB)),
                child: const Text('Generar PDF', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Finalización de Turno', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 10),
          const Text('Genera el reporte clínico consolidado de todos tus pacientes en formato PDF para la entrega de turno.', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                const Icon(Icons.picture_as_pdf, size: 80, color: Color(0xFF1C63BB)),
                const SizedBox(height: 20),
                const Text('Reporte Consolidado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text('Pacientes activos: ${controlador.listaPacientes.length}', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (controlador.listaPacientes.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay pacientes para generar el reporte.')));
                        return;
                      }

                      final turno = await preguntarTurno(context);
                      if (turno == null) return;

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );

                      try {
                        final bytes = await controlador.generarYGuardarReporte(turno);
                        if (!context.mounted) return;
                        Navigator.pop(context); // cerrar cargador

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VisorPdfPantalla(
                              bytes: bytes,
                              turno: turno,
                              reporteId: DateTime.now().millisecondsSinceEpoch.toString(), // o el que devolvió el gestor
                            ),
                          ),
                        );
                      } catch (e) {
                        if (context.mounted) {
                           Navigator.pop(context);
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar: $e')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C63BB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('GENERAR Y VISUALIZAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text('Nota:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const Text('Este reporte incluye historial de glucosa, administración de insulina y notas clínicas de cada paciente.', style: TextStyle(color: Colors.black54, fontSize: 13)),

          const SizedBox(height: 40),
          const Divider(thickness: 1, color: Color(0xFFD2D2D2)),
          const SizedBox(height: 20),

          const Text('Historial de Reportes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 15),

          if (controlador.reportesGenerados.isEmpty)
            const Text('Aún no se han generado reportes en este turno.', style: TextStyle(color: Colors.grey, fontSize: 14))
          else
            ...List.generate(controlador.reportesGenerados.length, (index) {
              final reporte = controlador.reportesGenerados[index];
              final fechaStr = DateFormat('dd/MM/yyyy HH:mm').format(reporte['fecha']);
              return Card(
                key: Key(reporte['id']),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Color(0xFFD2D2D2)),
                ),
                elevation: 0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
                    child: const Icon(Icons.description, color: Color(0xFF1C63BB)),
                  ),
                  title: Text('Turno ${reporte['turno']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text('$fechaStr\n${reporte['pacientes']} pacientes reportados'),
                  trailing: const Icon(Icons.visibility, color: Color(0xFF0C80EB)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VisorPdfPantalla(
                          bytes: reporte['bytes'],
                          turno: reporte['turno'],
                          reporteId: reporte['id'],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}
