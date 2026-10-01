import 'package:flutter/material.dart';
import '../controlador_dashboard_enfermero.dart';
import '../pantalla_agregar_paciente.dart';
import '../pantalla_detalle_paciente.dart';

class TabInicioEnfermero extends StatelessWidget {
  final ControladorDashboardEnfermero controlador;

  const TabInicioEnfermero({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    int totalPacientes = controlador.listaPacientes.length;
    int pacientesEstables = 0;
    int pacientesPrioridad = 0;

    for (var p in controlador.listaPacientes) {
      int val = p['glucosa'] ?? 0;
      int hipo = p['hipoLimit'] ?? 70;
      int hiper = p['hiperLimit'] ?? 180;
      int rMin = p['rangoMin'] ?? 80;
      int rMax = p['rangoMax'] ?? 130;

      if (val != 0) {
        if (val >= rMin && val <= rMax) {
          pacientesEstables++;
        } else if (val < hipo || val > hiper) {
          pacientesPrioridad++;
        }
      }
    }

    List<Map<String, dynamic>> pacientesFiltrados = List.from(controlador.listaPacientes.where((p) {
      String termino = controlador.busquedaCtrl.text.toLowerCase();
      String nombre = (p['nombre'] ?? '').toLowerCase();
      String ubicacion = (p['ubicacion'] ?? '').toLowerCase();
      return nombre.contains(termino) || ubicacion.contains(termino);
    }));

    if (controlador.ordenarPorUrgencia) {
      pacientesFiltrados.sort((a, b) {
        int scoreA = controlador.calcularNivelUrgencia(a);
        int scoreB = controlador.calcularNivelUrgencia(b);
        if (scoreA == scoreB) {
          return (a['ubicacion'] ?? '').compareTo(b['ubicacion'] ?? '');
        }
        return scoreB.compareTo(scoreA);
      });
    } else {
      pacientesFiltrados.sort((a, b) => (a['ubicacion'] ?? '').compareTo(b['ubicacion'] ?? ''));
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 30.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF1C63BB),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hola, Enf. ${controlador.nombreEnfermeroLocal}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5),
                              Text(controlador.fechaFormateada, style: const TextStyle(fontSize: 14, color: Color(0xFFE8E8E8))),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () { controlador.cambiarTab(4); },
                          child: Container(
                            width: 55, height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(color: Colors.white, width: 2),
                              image: controlador.imagenPerfil != null ? DecorationImage(image: FileImage(controlador.imagenPerfil!), fit: BoxFit.cover) : const DecorationImage(image: AssetImage('assets/enfermero_placeholder.png'), fit: BoxFit.cover),
                            ),
                            child: controlador.imagenPerfil == null ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  children: [
                    Expanded(child: _crearTarjetaDashboard('Total', totalPacientes.toString(), Icons.people, const Color(0xFF1C63BB))),
                    const SizedBox(width: 10),
                    Expanded(child: _crearTarjetaDashboard('Estables', pacientesEstables.toString(), Icons.check_circle, const Color(0xFF2E7D32))),
                    const SizedBox(width: 10),
                    Expanded(child: _crearTarjetaDashboard('Atención', pacientesPrioridad.toString(), Icons.warning, const Color(0xFFD32F2F))),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mis Pacientes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black)),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (controlador.enfermeroId == null) return;
                        final nuevoPaciente = await Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaAgregarPaciente(enfermeroId: controlador.enfermeroId!)));
                        if (nuevoPaciente == true) await controlador.cargarDatosBD();
                      },
                      icon: const Icon(Icons.add, size: 20, color: Colors.white),
                      label: const Text('Añadir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C80EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),

              _construirLeyendaColores(),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5)),
                  child: TextField(
                    controller: controlador.busquedaCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Buscar paciente o cama...',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF1C63BB)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Ordenar por:', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    FilterChip(
                      label: Text('Nivel de Urgencia', style: TextStyle(color: controlador.ordenarPorUrgencia ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                      selected: controlador.ordenarPorUrgencia,
                      onSelected: (val) {
                        controlador.alternarOrdenPorUrgencia(val);
                      },
                      selectedColor: const Color(0xFFD32F2F),
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: controlador.ordenarPorUrgencia ? Colors.transparent : const Color(0xFFD2D2D2))
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),

        if (pacientesFiltrados.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                controlador.listaPacientes.isEmpty ? 'No tienes pacientes asignados.\nToca "Añadir" para comenzar.' : 'No se encontraron pacientes.',
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final paciente = pacientesFiltrados[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: TarjetaPaciente(
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
                childCount: pacientesFiltrados.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _crearTarjetaDashboard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.3), width: 1)),
      child: Column(
        children: [
          Icon(icono, color: color, size: 28),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _construirLeyendaColores() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _itemLeyenda(const Color(0xFFD32F2F), 'Hipo/Hiper'),
            const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFE65100), 'Bajo/Elevado'),
            const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFF2E7D32), 'Normal'),
            const SizedBox(width: 15),
            _itemLeyenda(Colors.grey, 'Sin Dato'),
          ],
        ),
      ),
    );
  }

  Widget _itemLeyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(texto, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class TarjetaPaciente extends StatelessWidget {
  final Map<String, dynamic> paciente;
  final VoidCallback onTap;

  const TarjetaPaciente({
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
    bool esAlerta = false;
    bool lecturaAtrasada = false;
    String tiempoTranscurrido = '--';

    if (fechaUltG != null) {
      final diff = DateTime.now().difference(fechaUltG);
      if (diff.inHours >= 4) {
        lecturaAtrasada = true;
      }
      if (diff.inMinutes < 60) {
        tiempoTranscurrido = 'Hace ${diff.inMinutes} min';
      } else {
        tiempoTranscurrido = 'Hace ${diff.inHours} hrs';
      }
    } else {
      lecturaAtrasada = true;
      tiempoTranscurrido = 'Sin registros';
    }

    if (val == 0) {
      colorIndicador = Colors.grey;
    } else if (val < hipo || val > hiper) {
      colorIndicador = const Color(0xFFD32F2F);
      esAlerta = true;
    } else if (val >= rMin && val <= rMax) {
      colorIndicador = const Color(0xFF2E7D32);
    } else {
      colorIndicador = const Color(0xFFE65100);
    }

    if (lecturaAtrasada && !esAlerta) {
      esAlerta = true;
      colorIndicador = const Color(0xFFE65100);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: esAlerta ? colorIndicador : const Color(0xFFD2D2D2),
              width: esAlerta ? 2.5 : 1.5
          ),
          boxShadow: esAlerta
              ? [BoxShadow(color: colorIndicador.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (esAlerta && !lecturaAtrasada) Padding(padding: const EdgeInsets.only(right: 5), child: Icon(Icons.warning_amber_rounded, color: colorIndicador, size: 20)),
                      if (lecturaAtrasada) Padding(padding: const EdgeInsets.only(right: 5), child: Icon(Icons.timer_off_outlined, color: colorIndicador, size: 20)),
                      Expanded(
                        child: Text(
                          paciente['nombre'] ?? 'Paciente',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Cama/Ubicación: ${paciente['ubicacion'] ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        'Última glucosa',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: lecturaAtrasada ? colorIndicador : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: lecturaAtrasada ? colorIndicador.withOpacity(0.1) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(
                            tiempoTranscurrido,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: lecturaAtrasada ? colorIndicador : Colors.black54)
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: colorIndicador, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(
                        paciente['glucosa'] == 0 ? '-- mg/dL' : '${paciente['glucosa']} mg/dL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: paciente['glucosa'] == 0 ? Colors.black : colorIndicador,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
