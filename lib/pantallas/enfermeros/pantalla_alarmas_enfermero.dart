import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';

class PantallaAlarmasEnfermero extends StatefulWidget {
  final int enfermeroId;

  const PantallaAlarmasEnfermero({super.key, required this.enfermeroId});

  @override
  State<PantallaAlarmasEnfermero> createState() => _PantallaAlarmasEnfermeroState();
}

class _PantallaAlarmasEnfermeroState extends State<PantallaAlarmasEnfermero> {
  bool _cargando = true;
  List<Map<String, dynamic>> _recordatorios = [];
  List<Map<String, dynamic>> _listaPacientes = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final db = DatabaseHelper();
    final recordatoriosBD = await db.obtenerRecordatoriosEnfermero(widget.enfermeroId);
    final pacientesBD = await db.obtenerPacientesDeEnfermero(widget.enfermeroId);

    if (mounted) {
      setState(() {
        _recordatorios = recordatoriosBD;
        _listaPacientes = pacientesBD;
        _cargando = false;
      });
    }
  }

  void _mostrarDialogoAgregarRecordatorio() {
    String? pacienteSeleccionadoId;
    final TextEditingController mensajeCtrl = TextEditingController();
    DateTime fechaSeleccionada = DateTime.now();
    TimeOfDay horaSeleccionada = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.add_alert, color: Color(0xFF1C63BB)),
                  SizedBox(width: 10),
                  Text('Nuevo Aviso', style: TextStyle(color: Color(0xFF1C63BB), fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Paciente / Cama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      hint: const Text('Seleccionar...'),
                      items: _listaPacientes.map((p) {
                        return DropdownMenuItem<String>(
                          value: p['id'].toString(),
                          child: SizedBox(
                            width: 200,
                            child: Text('Cama ${p['ubicacion']} - ${p['nombre']}', overflow: TextOverflow.ellipsis),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() { pacienteSeleccionadoId = val; });
                      },
                    ),
                    const SizedBox(height: 15),

                    const Text('Recordatorio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: mensajeCtrl,
                      decoration: InputDecoration(
                        hintText: 'Ej. Medir glucosa, Antibiótico...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 15),

                    const Text('Fecha y Hora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: fechaSeleccionada,
                                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (pickedDate != null) {
                                setStateDialog(() {
                                  fechaSeleccionada = DateTime(
                                    pickedDate.year, pickedDate.month, pickedDate.day,
                                    fechaSeleccionada.hour, fechaSeleccionada.minute,
                                  );
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(DateFormat('dd/MM').format(fechaSeleccionada), style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: horaSeleccionada,
                              );
                              if (pickedTime != null) {
                                setStateDialog(() {
                                  horaSeleccionada = pickedTime;
                                  fechaSeleccionada = DateTime(
                                    fechaSeleccionada.year, fechaSeleccionada.month, fechaSeleccionada.day,
                                    pickedTime.hour, pickedTime.minute,
                                  );
                                });
                              }
                            },
                            icon: const Icon(Icons.access_time, size: 16),
                            label: Text(horaSeleccionada.format(context), style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () async {
                    if (pacienteSeleccionadoId == null || mensajeCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona paciente y escribe un mensaje')));
                      return;
                    }

                    final paciente = _listaPacientes.firstWhere((p) => p['id'].toString() == pacienteSeleccionadoId);
                    final db = DatabaseHelper();
                    await db.insertarRecordatorioEnfermero({
                      'enfermero_id': widget.enfermeroId,
                      'paciente_id': paciente['id'],
                      'paciente_nombre': paciente['nombre'],
                      'cama': paciente['ubicacion'],
                      'mensaje': mensajeCtrl.text,
                      'fecha_hora': fechaSeleccionada.toIso8601String(),
                      'completado': 0,
                    });

                    await _cargarDatos();
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _crearTarjetaRecordatorio(Map<String, dynamic> recordatorio, bool esPendiente) {
    final fechaHora = DateTime.parse(recordatorio['fecha_hora']);
    final horaStr = DateFormat('hh:mm a').format(fechaHora);
    final esUrgente = esPendiente && fechaHora.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: esPendiente ? (esUrgente ? const Color(0xFFFFEBEE) : Colors.white) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: esPendiente ? (esUrgente ? const Color(0xFFD32F2F) : const Color(0xFFD2D2D2)) : const Color(0xFFE0E0E0),
          width: esUrgente ? 2.0 : 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: esPendiente
            ? Icon(Icons.alarm, color: esUrgente ? const Color(0xFFD32F2F) : const Color(0xFFE65100), size: 30)
            : const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 30),
        title: Text(
          'Cama ${recordatorio['cama']} - ${recordatorio['paciente_nombre']}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            decoration: esPendiente ? null : TextDecoration.lineThrough,
            color: esPendiente ? Colors.black87 : Colors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              recordatorio['mensaje'],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: esPendiente ? (esUrgente ? const Color(0xFFD32F2F) : const Color(0xFF1C63BB)) : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text('Programado: $horaStr', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        trailing: esPendiente
            ? IconButton(
          icon: const Icon(Icons.check_box_outline_blank, size: 28, color: Colors.grey),
          onPressed: () async {
            final db = DatabaseHelper();
            await db.actualizarEstadoRecordatorio(recordatorio['id'], 1);
            await _cargarDatos();
          },
        )
            : IconButton(
          icon: const Icon(Icons.delete_outline, size: 28, color: Color(0xFFD32F2F)),
          onPressed: () async {
            final db = DatabaseHelper();
            await db.eliminarRecordatorio(recordatorio['id']);
            await _cargarDatos();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB)));
    }

    final pendientes = _recordatorios.where((r) => r['completado'] == 0).toList();
    final completados = _recordatorios.where((r) => r['completado'] == 1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recordatorios', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black)),
              IconButton(
                icon: const Icon(Icons.add_alert, color: Color(0xFF1C63BB), size: 32),
                onPressed: _mostrarDialogoAgregarRecordatorio,
              ),
            ],
          ),
        ),
        Expanded(
          child: _recordatorios.isEmpty
              ? const Center(
            child: Text('No hay alarmas ni recordatorios activos.', style: TextStyle(color: Colors.grey, fontSize: 16)),
          )
              : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            children: [
              if (pendientes.isNotEmpty) ...[
                const Text('Próximos / Pendientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                const SizedBox(height: 10),
                ...pendientes.map((r) => _crearTarjetaRecordatorio(r, true)).toList(),
              ],
              if (completados.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('Completados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                const SizedBox(height: 10),
                ...completados.map((r) => _crearTarjetaRecordatorio(r, false)).toList(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}