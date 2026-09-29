import 'package:flutter/material.dart';
import 'controlador_detalle_paciente.dart';
import 'widgets/seccion_cabecera_paciente.dart';
import 'widgets/seccion_control_glucemico.dart';
import 'widgets/seccion_administracion_insulina.dart';
import 'widgets/seccion_checklist_medicamentos.dart';
import 'widgets/seccion_observaciones_turno.dart';

class PantallaDetallePaciente extends StatefulWidget {
  final Map<String, dynamic> paciente;
  final String nombreEnfermero;

  const PantallaDetallePaciente({
    super.key,
    required this.paciente,
    required this.nombreEnfermero,
  });

  @override
  State<PantallaDetallePaciente> createState() => _PantallaDetallePacienteState();
}

class _PantallaDetallePacienteState extends State<PantallaDetallePaciente> {
  late ControladorDetallePaciente _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorDetallePaciente(
      paciente: widget.paciente,
      nombreEnfermero: widget.nombreEnfermero,
    );
    _controlador.cargarDatosPaciente();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _mostrarDialogoEliminar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Eliminar Paciente', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF4A4A))),
          content: const Text('¿Estás seguro de que deseas eliminar a este paciente? Toda su información y expediente clínico se perderá de forma permanente.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, 'eliminar');
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4A4A)),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) {
        if (_controlador.cargando) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7FA),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB))),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1C63BB),
              elevation: 0,
              title: const Text('Expediente Clínico', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SeccionCabeceraPaciente(controlador: _controlador),
                  const SizedBox(height: 20),
                  
                  SeccionControlGlucemico(controlador: _controlador),
                  const Divider(height: 50, thickness: 1),
                  
                  SeccionAdministracionInsulina(controlador: _controlador),
                  if (widget.paciente['tipoDiabetes'] != 'Tipo 2') 
                    const Divider(height: 50, thickness: 1),
                  
                  SeccionChecklistMedicamentos(controlador: _controlador),
                  const Divider(height: 50, thickness: 1),
                  
                  SeccionObservacionesTurno(controlador: _controlador),
                  const SizedBox(height: 40),

                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _mostrarDialogoEliminar,
                      icon: const Icon(Icons.delete_forever, color: Colors.white),
                      label: const Text('Eliminar Paciente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}