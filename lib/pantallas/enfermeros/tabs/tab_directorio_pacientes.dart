import 'package:flutter/material.dart';
import '../controlador_dashboard_enfermero.dart';
import '../pantalla_detalle_paciente.dart';

class TabDirectorioPacientes extends StatelessWidget {
  final ControladorDashboardEnfermero controlador;

  const TabDirectorioPacientes({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 10.0),
          child: Text(
            'Directorio de Pacientes',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black),
          ),
        ),

        const SizedBox(height: 10),
        Expanded(
          child: controlador.listaPacientes.isEmpty
              ? const Center(
            child: Text(
              'No hay pacientes en el directorio.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            itemCount: controlador.listaPacientes.length,
            itemBuilder: (context, index) {
              final paciente = controlador.listaPacientes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: TarjetaPacienteDetallada(
                  paciente: paciente,
                  onTap: () async {
                    final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaDetallePaciente(paciente: paciente, nombreEnfermero: controlador.nombreEnfermeroLocal)));
                    if (res == 'eliminar') {
                      await controlador.eliminarPaciente(paciente['id']);
                    } else {
                      await controlador.cargarDatosBD();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TarjetaPacienteDetallada extends StatelessWidget {
  final Map<String, dynamic> paciente;
  final VoidCallback onTap;

  const TarjetaPacienteDetallada({
    super.key,
    required this.paciente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    int val = paciente['glucosa'] ?? 0;
    int hipo = paciente['hipoLimit'] ?? 70;
    int hiper = paciente['hiperLimit'] ?? 180;
    int rMin = paciente['rangoMin'] ?? 80;
    int rMax = paciente['rangoMax'] ?? 130;
    DateTime? fechaUltG = paciente['fechaUltimaGlucosa'];

    Color colorIndicador;
    bool lecturaAtrasada = false;

    if (fechaUltG != null && DateTime.now().difference(fechaUltG).inHours >= 4) {
      lecturaAtrasada = true;
    }

    if (val == 0) {
      colorIndicador = Colors.grey;
    } else if (val < hipo || val > hiper) {
      colorIndicador = const Color(0xFFD32F2F);
    } else if (val >= rMin && val <= rMax) {
      colorIndicador = const Color(0xFF2E7D32);
    } else {
      colorIndicador = const Color(0xFFE65100);
    }

    if (lecturaAtrasada && colorIndicador == const Color(0xFF2E7D32)) {
      colorIndicador = const Color(0xFFE65100);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(paciente['nombre'] ?? 'Paciente', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black)),
                      Text('Edad: ${paciente['edad']?.toString() ?? '--'} | Exp: ${paciente['expediente'] ?? '--'}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ubicación', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(paciente['ubicacion'] ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tipo Diabetes', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(paciente['tipoDiabetes'] ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: colorIndicador, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Último registro:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(
                            paciente['glucosa'] == 0 ? '-- mg/dL' : '${paciente['glucosa']} mg/dL',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: paciente['glucosa'] == 0 ? Colors.black : colorIndicador,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      if (lecturaAtrasada) const Icon(Icons.timer_off, size: 16, color: Color(0xFFE65100)),
                      if (!lecturaAtrasada) const Icon(Icons.timer, size: 16, color: Colors.black54),
                      const SizedBox(width: 5),
                      Text(lecturaAtrasada ? 'Registro desactualizado' : 'A tiempo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: lecturaAtrasada ? const Color(0xFFE65100) : Colors.black54)),
                    ],
                  )
                ],
              ),
            ),

            if (paciente['alergias'] != null && paciente['alergias'] != 'Ninguna') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 16),
                  const SizedBox(width: 5),
                  Expanded(child: Text('Alergias: ${paciente['alergias']}', style: const TextStyle(fontSize: 16, color: Color(0xFFD32F2F), fontWeight: FontWeight.bold))),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
