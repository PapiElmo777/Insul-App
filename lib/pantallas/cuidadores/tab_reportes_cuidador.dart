import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../../../database/database_helper.dart';
import '../../../servicios/servicios/reporte_paciente_service.dart';

class TabReportesCuidador extends StatefulWidget {
  const TabReportesCuidador({super.key});

  @override
  State<TabReportesCuidador> createState() => _TabReportesCuidadorState();
}

class _TabReportesCuidadorState extends State<TabReportesCuidador> {
  List<Map<String, dynamic>> _familiares = [];
  Map<String, dynamic>? _familiarSeleccionado;
  List<Map<String, dynamic>> _reportesGuardados = [];

  bool _cargando = true;
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    _cargarFamiliares();
  }

  Future<void> _cargarFamiliares() async {
    try {
      final dbHelper = DatabaseHelper();
      final userId = await dbHelper.obtenerSesionActiva();

      if (userId != null) {
        final data = await dbHelper.obtenerPacientesPorCuidador(userId);
        if (mounted) {
          setState(() {
            _familiares = List<Map<String, dynamic>>.from(data);
            if (_familiares.isNotEmpty) {
              _familiarSeleccionado = _familiares.first;
              _cargarReportes(); // Cargamos los reportes del primer familiar
            } else {
              _cargando = false;
            }
          });
        }
      } else {
        if (mounted) setState(() => _cargando = false);
      }
    } catch (e) {
      debugPrint("Error al cargar familiares: $e");
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cargarReportes() async {
    if (_familiarSeleccionado == null) return;

    setState(() => _cargando = true);
    final dbHelper = DatabaseHelper();
    final reportes = await dbHelper.obtenerReportesDeFamiliar(_familiarSeleccionado!['id']);

    if (mounted) {
      setState(() {
        _reportesGuardados = List<Map<String, dynamic>>.from(reportes);
        _cargando = false;
      });
    }
  }

  Future<void> _generarNuevoReporte() async {
    if (_familiarSeleccionado == null) return;

    setState(() => _generando = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generando reporte...'), duration: Duration(seconds: 2)),
    );

    try {
      final dbHelper = DatabaseHelper();
      final paciente = _familiarSeleccionado!;
      final registrosRaw = await dbHelper.obtenerRegistrosGlucosaCuidador(paciente['id']);
      final registrosSoloGlucosa = registrosRaw.where((r) {
        final val = double.tryParse(r['valor'].toString()) ?? 0.0;
        return val > 0;
      }).toList();

      if (registrosSoloGlucosa.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay suficientes lecturas de glucosa para generar un reporte válido.'), backgroundColor: Colors.orange),
          );
          setState(() => _generando = false);
        }
        return;
      }

      // Adaptador para el servicio de PDF
      final pacienteReporte = {
        'nombre': paciente['nombre']?.toString() ?? 'Familiar',
        'edad': int.tryParse(paciente['edad'].toString()) ?? 0,
        'tipoDiabetes': paciente['tipo_diabetes']?.toString() ?? 'No especificado',
        'peso': double.tryParse(paciente['peso'].toString()) ?? 0.0,
        'altura': double.tryParse(paciente['altura'].toString()) ?? 0.0,
        'imc': double.tryParse(paciente['imc'].toString()) ?? 0.0,
        'limiteHipo': int.tryParse(paciente['limite_hipo'].toString()) ?? 70,
        'hiperLimit': int.tryParse(paciente['limite_hiper'].toString()) ?? 180,
        'rangoMin': int.tryParse(paciente['rango_min'].toString()) ?? 80,
        'rangoMax': int.tryParse(paciente['rango_max'].toString()) ?? 130,
        'medico': paciente['medico_nombre']?.toString() ?? 'No especificado',
      };

      final registrosParseados = registrosSoloGlucosa.map((r) {
        DateTime fecha;
        try {
          fecha = DateTime.parse(r['fecha'].toString());
        } catch (e) {
          fecha = DateTime.now();
        }
        return {
          ...r,
          'fecha': fecha,
          'valor': double.tryParse(r['valor'].toString()) ?? 0.0,
        };
      }).toList();

      // Rango de fechas para el título del reporte
      final sorted = List<Map<String, dynamic>>.from(registrosParseados)..sort((a, b) => (a['fecha'] as DateTime).compareTo(b['fecha'] as DateTime));
      final iniStr = DateFormat('dd MMM yy').format(sorted.first['fecha'] as DateTime);
      final finStr = DateFormat('dd MMM yy').format(sorted.last['fecha'] as DateTime);
      final periodo = '$iniStr - $finStr';

      final pdfBytes = await ReportePacienteService.generarReporteAGP(
        paciente: pacienteReporte,
        registros: registrosParseados,
      );

      // Guardar permanentemente en la Base de Datos
      await dbHelper.insertarReporteCuidador({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'paciente_cuidador_id': paciente['id'],
        'periodo': periodo,
        'fecha': DateTime.now().toIso8601String(),
        'archivo_bytes': pdfBytes,
      });

      // Recargar la lista visual
      await _cargarReportes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte generado y guardado con éxito.'), backgroundColor: Color(0xFF2E7D32)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  void _verReporte(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  void _compartirReporte(Uint8List bytes, String nombrePaciente) async {
    await Printing.sharePdf(bytes: bytes, filename: 'Reporte_AGP_${nombrePaciente.replaceAll(" ", "_")}.pdf');
  }

  void _eliminarReporte(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reporte', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
        content: const Text('¿Estás seguro de que deseas eliminar este reporte de tu historial local?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = DatabaseHelper();
      await db.eliminarReporteCuidador(id);
      _cargarReportes();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando && _familiares.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 25),
            decoration: const BoxDecoration(
              color: Color(0xFF1C63BB),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historiales y Reportes', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 5),
                Text('Administra los reportes de tus familiares.', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          if (_familiares.isEmpty)
            const Expanded(child: Center(child: Text('No tienes familiares registrados.', style: TextStyle(color: Colors.grey))))
          else
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selecciona a tu familiar:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: const Color(0xFFD2D2D2)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Map<String, dynamic>>(
                              value: _familiarSeleccionado,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1C63BB)),
                              items: _familiares.map((fam) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: fam,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person, color: Color(0xFF1C63BB), size: 20),
                                      const SizedBox(width: 10),
                                      Text(fam['nombre'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _familiarSeleccionado = val);
                                  _cargarReportes();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _generando ? null : _generarNuevoReporte,
                            icon: _generando
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.add_chart, color: Colors.white),
                            label: Text(_generando ? 'Procesando...' : 'Generar Nuevo Reporte AGP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C80EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, thickness: 1, color: Color(0xFFD2D2D2)),
                  Expanded(
                    child: _cargando
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB)))
                        : _reportesGuardados.isEmpty
                        ? const Center(child: Text('Aún no has generado reportes para este familiar.', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      itemCount: _reportesGuardados.length,
                      itemBuilder: (context, index) {
                        final reporte = _reportesGuardados[index];
                        final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(reporte['fecha']));
                        final bytes = reporte['archivo_bytes'] as Uint8List;

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.grey.shade300)
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _verReporte(bytes),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
                                    child: const Icon(Icons.picture_as_pdf, color: Color(0xFFD32F2F), size: 28),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Reporte AGP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text('Periodo: ${reporte['periodo']}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                        Text('Creado: $fechaFormateada', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.share, color: Color(0xFF1C63BB)),
                                        onPressed: () => _compartirReporte(bytes, _familiarSeleccionado!['nombre']),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                                        onPressed: () => _eliminarReporte(reporte['id']),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}