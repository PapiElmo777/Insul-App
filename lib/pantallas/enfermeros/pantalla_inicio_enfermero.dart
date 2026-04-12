import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import '../../servicios/reporte_enfermero_service.dart';
import 'pantalla_agregar_paciente.dart';
import 'pantalla_detalle_paciente.dart';

class PantallaInicioEnfermero extends StatefulWidget {
  final String nombreEnfermero;

  const PantallaInicioEnfermero({
    super.key,
    this.nombreEnfermero = 'Alfredo',
  });

  @override
  State<PantallaInicioEnfermero> createState() => _PantallaInicioEnfermeroState();
}

class _PantallaInicioEnfermeroState extends State<PantallaInicioEnfermero> {
  int _indiceNavegacionActual = 0;
  String _fechaFormateada = '';
  List<Map<String, dynamic>> _listaPacientes = [];
  List<Map<String, dynamic>> _reportesGenerados = [];

  String cedulaEnfermero = '12345678';
  String areaEnfermero = 'Medicina Interna';
  String hospitalEnfermero = 'Hospital Ángeles';

  @override
  void initState() {
    super.initState();
    _inicializarFecha();
  }

  Future<void> _inicializarFecha() async {
    await initializeDateFormatting('es_ES', null);
    _actualizarFecha();
  }

  void _actualizarFecha() {
    final DateTime ahora = DateTime.now();
    final DateFormat formateador = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es_ES');
    String fecha = formateador.format(ahora);
    if (fecha.isNotEmpty) {
      fecha = fecha[0].toUpperCase() + fecha.substring(1);
    }

    setState(() {
      _fechaFormateada = fecha;
    });
  }

  Future<String?> preguntarTurno(BuildContext context) async {
    String? turnoSeleccionado = 'Matutino';

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
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
              onChanged: (value) => turnoSeleccionado = value,
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
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _indiceNavegacionActual == 0
            ? _construirTabHome()
            : _indiceNavegacionActual == 1
            ? _construirTabDirectorioPacientes()
            : _indiceNavegacionActual == 2
            ? _construirTabReporte()
            : const Center(child: Text("En construcción", style: TextStyle(color: Colors.grey))),
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _indiceNavegacionActual,
            onTap: (index) {
              setState(() {
                _indiceNavegacionActual = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: const Color(0xFF888888),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_outlined, size: 28, color: _indiceNavegacionActual == 0 ? Colors.black : const Color(0xFF888888)),
                    if (_indiceNavegacionActual == 0) _puntoRojo(),
                  ],
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bar_chart, size: 28, color: _indiceNavegacionActual == 1 ? Colors.black : const Color(0xFF888888)),
                    if (_indiceNavegacionActual == 1) _puntoRojo(),
                  ],
                ),
                label: 'Pacientes',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 28, color: _indiceNavegacionActual == 2 ? Colors.black : const Color(0xFF888888)),
                    if (_indiceNavegacionActual == 2) _puntoRojo(),
                  ],
                ),
                label: 'Historial',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border, size: 28, color: _indiceNavegacionActual == 3 ? Colors.black : const Color(0xFF888888)),
                label: 'Favoritos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 28, color: _indiceNavegacionActual == 4 ? Colors.black : const Color(0xFF888888)),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _puntoRojo() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Color(0xFFFF4A4A),
        shape: BoxShape.circle,
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
            _itemLeyenda(const Color(0xFFFF6B6B), 'Hipo'),
            const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFF06CA23), 'Normal'),
            const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFD9E00C), 'Precaución'),
            const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFFFB347), 'Hiper'),
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
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  Widget _construirTabHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, Enf. ${widget.nombreEnfermero}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2F2F2F),
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _fechaFormateada,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                  image: const DecorationImage(
                    image: AssetImage('assets/enfermero_placeholder.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Pacientes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final nuevoPaciente = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PantallaAgregarPaciente()),
                  );

                  if (nuevoPaciente != null) {
                    setState(() {
                      _listaPacientes.add(nuevoPaciente);
                    });
                  }
                },
                icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.white),
                label: const Text(
                  'Agregar Paciente',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C80EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFD2D2D2), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ),

        _construirLeyendaColores(),
        const SizedBox(height: 10),

        Expanded(
          child: _listaPacientes.isEmpty
              ? const Center(
            child: Text(
              'No tienes pacientes asignados.\nToca "Agregar Paciente" para comenzar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            itemCount: _listaPacientes.length,
            itemBuilder: (context, index) {
              final paciente = _listaPacientes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: _TarjetaPaciente(
                  paciente: paciente,
                  onTap: () async {
                    final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaDetallePaciente(paciente: paciente, nombreEnfermero: widget.nombreEnfermero)));
                    if (res == 'eliminar') {
                      setState(() {
                        _listaPacientes.remove(paciente);
                      });
                    } else {
                      setState(() {});
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

  Widget _construirTabDirectorioPacientes() {
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
          child: _listaPacientes.isEmpty
              ? const Center(
            child: Text(
              'No hay pacientes en el directorio.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            itemCount: _listaPacientes.length,
            itemBuilder: (context, index) {
              final paciente = _listaPacientes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: _TarjetaPacienteDetallada(
                  paciente: paciente,
                  onTap: () async {
                    final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaDetallePaciente(paciente: paciente, nombreEnfermero: widget.nombreEnfermero)));
                    if (res == 'eliminar') {
                      setState(() {
                        _listaPacientes.remove(paciente);
                      });
                    } else {
                      setState(() {});
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

  Widget _construirTabReporte() {
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
                Text('Pacientes activos: ${_listaPacientes.length}', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_listaPacientes.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay pacientes para generar el reporte.')));
                        return;
                      }

                      final turno = await preguntarTurno(context);
                      if (turno == null) return;

                      final enfermero = DatosEnfermero(
                        nombre: widget.nombreEnfermero,
                        cedula: cedulaEnfermero,
                        area: areaEnfermero,
                        hospital: hospitalEnfermero,
                      );

                      final bytes = await ReportePdfService.generarReporteTurno(
                        pacientes: _listaPacientes,
                        enfermero: enfermero,
                        turno: turno,
                      );
                      final String idUnico = DateTime.now().millisecondsSinceEpoch.toString();

                      setState(() {
                        _reportesGenerados.insert(0, {
                          'id': idUnico,
                          'fecha': DateTime.now(),
                          'turno': turno,
                          'pacientes': _listaPacientes.length,
                          'bytes': bytes,
                        });
                      });

                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisorPdfPantalla(
                            bytes: bytes,
                            turno: turno,
                            reporteId: idUnico,
                          ),
                        ),
                      );
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

          if (_reportesGenerados.isEmpty)
            const Text('Aún no se han generado reportes en este turno.', style: TextStyle(color: Colors.grey, fontSize: 14))
          else
            ...List.generate(_reportesGenerados.length, (index) {
              final reporte = _reportesGenerados[index];
              final fechaStr = DateFormat('dd/MM/yyyy HH:mm').format(reporte['fecha']);
              return Card(
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

class _TarjetaPaciente extends StatelessWidget {
  final Map<String, dynamic> paciente;
  final VoidCallback onTap;

  const _TarjetaPaciente({
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

    Color colorIndicador;
    if (val == 0) {
      colorIndicador = Colors.grey;
    } else if (val < hipo) {
      colorIndicador = const Color(0xFFFF6B6B);
    } else if (val > hiper) {
      colorIndicador = const Color(0xFFFFB347);
    } else if (val >= rMin && val <= rMax) {
      colorIndicador = const Color(0xFF06CA23);
    } else {
      colorIndicador = const Color(0xFFD9E00C);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paciente['nombre'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ultima glucosa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorIndicador,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        paciente['glucosa'] == 0 ? '-- mg/dL' : '${paciente['glucosa']} mg/dL',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (paciente['proximaDosis'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.colorize, color: Colors.black, size: 20),
                  const SizedBox(height: 4),
                  const Text(
                    'Proxima dosis',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    paciente['proximaDosis'],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaPacienteDetallada extends StatelessWidget {
  final Map<String, dynamic> paciente;
  final VoidCallback onTap;

  const _TarjetaPacienteDetallada({
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

    Color colorIndicador;
    if (val == 0) {
      colorIndicador = Colors.grey;
    } else if (val < hipo) {
      colorIndicador = const Color(0xFFFF6B6B);
    } else if (val > hiper) {
      colorIndicador = const Color(0xFFFFB347);
    } else if (val >= rMin && val <= rMax) {
      colorIndicador = const Color(0xFF06CA23);
    } else {
      colorIndicador = const Color(0xFFD9E00C);
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
                      Text(paciente['nombre'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black)),
                      Text('Edad: ${paciente['edad']} | Exp: ${paciente['expediente']}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
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
                      Text(paciente['ubicacion'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tipo Diabetes', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(paciente['tipoDiabetes'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
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
                          Text(paciente['glucosa'] == 0 ? '-- mg/dL' : '${paciente['glucosa']} mg/dL', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.colorize, size: 16, color: Colors.black54),
                      const SizedBox(width: 5),
                      Text(paciente['proximaDosis'] ?? 'Pendiente', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
                    ],
                  )
                ],
              ),
            ),

            if (paciente['alergias'] != null && paciente['alergias'] != 'Ninguna') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4A4A), size: 16),
                  const SizedBox(width: 5),
                  Expanded(child: Text('Alergias: ${paciente['alergias']}', style: const TextStyle(fontSize: 16, color: Color(0xFFFF4A4A), fontWeight: FontWeight.bold))),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}

class VisorPdfPantalla extends StatelessWidget {
  final Uint8List bytes;
  final String turno;
  final String reporteId;

  const VisorPdfPantalla({
    super.key,
    required this.bytes,
    required this.turno,
    required this.reporteId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C63BB),
        title: Text('Reporte de Turno $turno', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PdfPreview(
        key: Key(reporteId),
        build: (format) async => bytes,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: 'Reporte_Turno_${turno}_$reporteId.pdf',
      ),
    );
  }
}