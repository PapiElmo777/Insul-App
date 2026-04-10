import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _glucosaCtrl = TextEditingController();
  final TextEditingController _observacionCtrl = TextEditingController();
  final TextEditingController _insulinaCtrl = TextEditingController();
  late List<Map<String, dynamic>> _historialGlucosa;
  late List<Map<String, dynamic>> _medicamentos;
  late List<String> _observaciones;

  @override
  void initState() {
    super.initState();

    _historialGlucosa = widget.paciente['historialGlucosa'] ?? <Map<String, dynamic>>[];
    _medicamentos = widget.paciente['medicamentos'] ?? <Map<String, dynamic>>[];
    _observaciones = widget.paciente['observacionesTurno'] ?? <String>[];
    if (widget.paciente['historialInsulina'] == null) {
      widget.paciente['historialInsulina'] = <Map<String, dynamic>>[];
    }
    if (_observaciones.isEmpty && widget.paciente['estadoGeneral'] != null && widget.paciente['estadoGeneral'].toString().isNotEmpty) {
      _observaciones.add('NOTA DE INGRESO:\n${widget.paciente['estadoGeneral']}');
    }
  }

  @override
  void dispose() {
    _glucosaCtrl.dispose();
    _observacionCtrl.dispose();
    _insulinaCtrl.dispose();
    super.dispose();
  }

  // Calculos
  double _calcularPromedio() {
    if (_historialGlucosa.isEmpty) return 0;
    double suma = 0;
    for (var item in _historialGlucosa) {
      suma += item['valor'];
    }
    return suma / _historialGlucosa.length;
  }

  double _calcularTIR() {
    if (_historialGlucosa.isEmpty) return 0;
    int enRango = 0;
    for (var item in _historialGlucosa) {
      int val = item['valor'];
      if (val >= 80 && val <= 130) enRango++;
    }
    return (enRango / _historialGlucosa.length) * 100;
  }

  void _mostrarDialogoAgregarGlucosa() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Registrar Toma de Glucosa', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _glucosaCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: 'Ej. 110', suffixText: 'mg/dL', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                if (_glucosaCtrl.text.isNotEmpty) {
                  int nuevoValor = int.parse(_glucosaCtrl.text);
                  setState(() {
                    _historialGlucosa.insert(0, {
                      'valor': nuevoValor,
                      'fecha': DateTime.now(),
                    });
                    widget.paciente['glucosa'] = nuevoValor;
                    if (nuevoValor < 80 || nuevoValor > 130) {
                      widget.paciente['estadoGlucosa'] = (nuevoValor < 70 || nuevoValor > 180) ? 'peligro' : 'alerta';
                    } else {
                      widget.paciente['estadoGlucosa'] = 'normal';
                    }
                  });
                  _glucosaCtrl.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoAgregarInsulina() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Suministrar Insulina', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _insulinaCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: 'Unidades administradas', suffixText: 'UI', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                if (_insulinaCtrl.text.isNotEmpty) {
                  setState(() {
                    widget.paciente['historialInsulina'].insert(0, {
                      'unidades': int.parse(_insulinaCtrl.text),
                      'fecha': DateTime.now(),
                    });
                  });
                  _insulinaCtrl.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Registrar Dosis', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoObservacion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Añadir Observación', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _observacionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Escriba nota del turno...', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                if (_observacionCtrl.text.isNotEmpty) {
                  setState(() {
                    String hora = DateFormat('hh:mm a').format(DateTime.now());
                    _observaciones.insert(0, "[$hora] Enf. ${widget.nombreEnfermero}:\n${_observacionCtrl.text}");
                  });
                  _observacionCtrl.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Añadir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Color(0xFF1C63BB),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFF00D1FF), width: 3)),
                      child: const Icon(Icons.person, color: Color(0xFF1C63BB), size: 40),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.paciente['nombre'] ?? 'Paciente', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 5),
                          Text(widget.paciente['ubicacion'] ?? 'Ubicación sin asignar', style: const TextStyle(fontSize: 14, color: Color(0xFFE8E8E8))),
                          const SizedBox(height: 2),
                          Text('Edad: ${widget.paciente['edad'] ?? '--'} | Dieta: ${widget.paciente['dieta'] ?? 'Normal'}', style: const TextStyle(fontSize: 12, color: Color(0xFFE8E8E8))),
                        ],
                      ),
                    ),
                    // Boton Editar
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Grafica
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Control Glucémico', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                        TextButton.icon(
                          onPressed: _mostrarDialogoAgregarGlucosa,
                          icon: const Icon(Icons.add, color: Color(0xFF0C80EB)),
                          label: const Text('Añadir Medida', style: TextStyle(color: Color(0xFF0C80EB), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    // Recordatorio
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(color: const Color(0xFFE8F4F8), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF008CCF))),
                      child: Row(
                        children: [
                          const Icon(Icons.alarm, color: Color(0xFF008CCF)),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Tipo: ${widget.paciente['tipoDiabetes'] ?? 'No especificado'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF008CCF)))),
                        ],
                      ),
                    ),

                    // Grafico / Historial
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2))),
                      child: _historialGlucosa.isEmpty
                          ? const Center(child: Text('Aún no hay medidas registradas', style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(15),
                        itemCount: _historialGlucosa.length,
                        itemBuilder: (context, index) {
                          final lectura = _historialGlucosa[index];
                          final fechaStr = DateFormat('dd/MM\nhh:mm a').format(lectura['fecha'] as DateTime);
                          int valor = lectura['valor'];
                          Color c = (valor >= 80 && valor <= 130) ? const Color(0xFF06CA23) : const Color(0xFFE00925);
                        //agregar los 3 colores para los rangos
                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(valor.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: c)),
                                const SizedBox(height: 5),
                                Container(width: 20, height: (valor.toDouble() / 3).clamp(10.0, 80.0), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(5))),
                                const SizedBox(height: 5),
                                Text(fechaStr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Promedio y TIR
                    Row(
                      children: [
                        Expanded(child: _crearTarjetaStat('Promedio', '${_calcularPromedio().toStringAsFixed(1)}', 'mg/dL', Icons.timeline, const Color(0xFF008CCF))),
                        const SizedBox(width: 15),
                        Expanded(child: _crearTarjetaStat('TIR', '${_calcularTIR().toStringAsFixed(0)}%', 'En rango', Icons.check_circle, const Color(0xFF06CA23))),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 50, thickness: 1),

              // Insulina
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Suministro de Insulina', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                        TextButton.icon(
                          onPressed: _mostrarDialogoAgregarInsulina,
                          icon: const Icon(Icons.colorize, color: Color(0xFF0C80EB)),
                          label: const Text('Suministrar', style: TextStyle(color: Color(0xFF0C80EB), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD2D2D2))),
                      child: widget.paciente['historialInsulina'].isEmpty
                          ? const Text('No se ha suministrado insulina.', style: TextStyle(color: Colors.grey))
                          : Column(
                        children: List.generate(widget.paciente['historialInsulina'].length, (index) {
                          final ins = widget.paciente['historialInsulina'][index];
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
              ),
              const Divider(height: 50, thickness: 1),

              // Medicamentos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Checklist de Medicamentos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 15),
                    if (_medicamentos.isEmpty)
                      const Text('No hay medicamentos registrados.', style: TextStyle(color: Colors.grey)),
                    ...List.generate(_medicamentos.length, (index) {
                      final med = _medicamentos[index];
                      bool suministrado = med['suministrado'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: suministrado ? const Color(0xFF06CA23) : const Color(0xFFFF4A4A), width: 1.5)
                        ),
                        child: CheckboxListTile(
                          title: Text('${med['nombre']} - ${med['dosis']}', style: TextStyle(fontWeight: FontWeight.bold, decoration: suministrado ? TextDecoration.lineThrough : null)),
                          subtitle: Text(med['frecuencia']),
                          value: suministrado,
                          activeColor: const Color(0xFF06CA23),
                          checkColor: Colors.white,
                          onChanged: (bool? val) {
                            setState(() { med['suministrado'] = val!; });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const Divider(height: 50, thickness: 1),

              // Observaciones
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Observaciones de Turno', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                        TextButton.icon(
                          onPressed: _mostrarDialogoObservacion,
                          icon: const Icon(Icons.note_add, color: Color(0xFF0C80EB)),
                          label: const Text('Añadir', style: TextStyle(color: Color(0xFF0C80EB), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Alergias
                    if (widget.paciente['alergias'] != null && widget.paciente['alergias'] != 'Ninguna')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(color: const Color(0xFFFFE5E5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFF4A4A))),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4A4A)),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Alergias: ${widget.paciente['alergias']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF4A4A)))),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),
                    ...List.generate(_observaciones.length, (index) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: const Color(0xFFFFF9E6), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFFFD166))),
                        child: Text(_observaciones[index], style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // Estadisticas de glucosa
  Widget _crearTarjetaStat(String titulo, String valor, String subtitulo, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD2D2D2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 28),
          const SizedBox(height: 10),
          Text(valor, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(subtitulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}