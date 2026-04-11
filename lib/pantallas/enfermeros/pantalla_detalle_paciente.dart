import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

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
    int minG = widget.paciente['rangoMin'] ?? 80;
    int maxG = widget.paciente['rangoMax'] ?? 130;
    for (var item in _historialGlucosa) {
      int val = item['valor'];
      if (val >= minG && val <= maxG) enRango++;
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
                    int hipo = widget.paciente['hipoLimit'] ?? 70;
                    int hiper = widget.paciente['hiperLimit'] ?? 180;
                    int minG = widget.paciente['rangoMin'] ?? 80;
                    int maxG = widget.paciente['rangoMax'] ?? 130;
                    if (nuevoValor < hipo) {
                      widget.paciente['estadoGlucosa'] = 'peligro';
                    } else if (nuevoValor > hiper) {
                      widget.paciente['estadoGlucosa'] = 'peligro';
                    } else if (nuevoValor >= minG && nuevoValor <= maxG) {
                      widget.paciente['estadoGlucosa'] = 'normal';
                    } else {
                      widget.paciente['estadoGlucosa'] = 'alerta';
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.paciente['nombre'] ?? 'Paciente', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(widget.paciente['ubicacion'] ?? 'Ubicación sin asignar', style: const TextStyle(fontSize: 18, color: Color(0xFFE8E8E8))),
                          const SizedBox(height: 4),
                          Text('Edad: ${widget.paciente['edad'] ?? '--'} | Dieta: ${widget.paciente['dieta'] ?? 'Normal'}', style: const TextStyle(fontSize: 16, color: Color(0xFFE8E8E8))),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: IconButton(icon: const Icon(Icons.edit, color: Colors.white, size: 28), onPressed: () {}),
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
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2))),
                      child: _historialGlucosa.isEmpty
                          ? const Center(child: Text('Aún no hay medidas registradas', style: TextStyle(color: Colors.grey)))
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 30, top: 10, bottom: 5),
                            width: _historialGlucosa.length > 4 ? _historialGlucosa.length * 80.0 : MediaQuery.of(context).size.width - 40,
                            child: CustomPaint(
                              painter: _GraficaGlucosaPainter(
                                historial: _historialGlucosa.reversed.toList(),
                                hipo: widget.paciente['hipoLimit'] ?? 70,
                                hiper: widget.paciente['hiperLimit'] ?? 180,
                                rMin: widget.paciente['rangoMin'] ?? 80,
                                rMax: widget.paciente['rangoMax'] ?? 130,
                              ),
                            ),
                          ),
                        ),
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

              if (widget.paciente['tipoDiabetes'] != 'Tipo 2') ...[
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
              ],
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

class _GraficaGlucosaPainter extends CustomPainter {
  final List<Map<String, dynamic>> historial;
  final int hipo, hiper, rMin, rMax;

  _GraficaGlucosaPainter({
    required this.historial,
    required this.hipo,
    required this.hiper,
    required this.rMin,
    required this.rMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (historial.isEmpty) return;

    double maxY = hiper.toDouble() + 50.0;
    double minY = hipo.toDouble() - 20.0;
    if (minY < 0) minY = 0;

    for (var item in historial) {
      if (item['valor'] > maxY) maxY = item['valor'].toDouble() + 30;
      if (item['valor'] < minY) minY = item['valor'].toDouble() - 10;
    }

    double graphHeight = size.height - 40;
    double offsetX = 40.0;
    double graphWidth = size.width - offsetX;

    double valToY(double val) {
      return graphHeight - (((val - minY) / (maxY - minY)) * graphHeight) + 10;
    }

    Paint bgPaint = Paint();

    bgPaint.color = const Color(0xFFFF6B6B).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(hipo.toDouble()), size.width, graphHeight + 10), bgPaint);

    bgPaint.color = const Color(0xFFFFB347).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTRB(offsetX, 10, size.width, valToY(hiper.toDouble())), bgPaint);

    bgPaint.color = const Color(0xFF06CA23).withOpacity(0.15);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(rMax.toDouble()), size.width, valToY(rMin.toDouble())), bgPaint);

    bgPaint.color = const Color(0xFFD9E00C).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(hiper.toDouble()), size.width, valToY(rMax.toDouble())), bgPaint);

    bgPaint.color = const Color(0xFFD9E00C).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(rMin.toDouble()), size.width, valToY(hipo.toDouble())), bgPaint);

    Paint lineRef = Paint()..color = Colors.grey.withOpacity(0.3)..strokeWidth = 1;
    List<int> yLabels = [maxY.toInt(), hiper, rMax, rMin, hipo, minY.toInt()];
    yLabels = yLabels.toSet().toList()..sort((a, b) => b.compareTo(a));

    for (int yVal in yLabels) {
      double yPos = valToY(yVal.toDouble());
      canvas.drawLine(Offset(offsetX, yPos), Offset(size.width, yPos), lineRef);
      TextPainter tpY = TextPainter(
        text: TextSpan(text: '$yVal', style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      tpY.layout();
      tpY.paint(canvas, Offset(offsetX - tpY.width - 5, yPos - 6));
    }

    canvas.drawLine(Offset(offsetX, graphHeight + 10), Offset(size.width, graphHeight + 10), Paint()..color = Colors.grey..strokeWidth = 2);
    canvas.drawLine(Offset(offsetX, 10), Offset(offsetX, graphHeight + 10), Paint()..color = Colors.grey..strokeWidth = 2);

    List<Offset> points = [];
    double stepX = historial.length > 1 ? graphWidth / (historial.length - 1) : graphWidth / 2;

    for (int i = 0; i < historial.length; i++) {
      double x = historial.length == 1 ? offsetX + (graphWidth / 2) : offsetX + (i * stepX);
      double y = valToY(historial[i]['valor'].toDouble());
      points.add(Offset(x, y));
    }

    Paint linePaint = Paint()
      ..color = const Color(0xFF1C63BB)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    Path path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        double controlPointX = (points[i - 1].dx + points[i].dx) / 2;
        path.cubicTo(controlPointX, points[i - 1].dy, controlPointX, points[i].dy, points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    for (int i = 0; i < points.length; i++) {
      int val = historial[i]['valor'];
      Color c;
      if (val < hipo) c = const Color(0xFFFF6B6B);
      else if (val > hiper) c = const Color(0xFFFFB347);
      else if (val >= rMin && val <= rMax) c = const Color(0xFF06CA23);
      else c = const Color(0xFFD9E00C);
      canvas.drawCircle(points[i], 8.0, Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(points[i], 5.0, Paint()..color = c..style = PaintingStyle.fill);
      TextPainter tpVal = TextPainter(
        text: TextSpan(text: '$val', style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 13)),
        textDirection: TextDirection.ltr,
      );
      tpVal.layout();
      tpVal.paint(canvas, Offset(points[i].dx - tpVal.width / 2, points[i].dy - 24));
      TextPainter tpFecha = TextPainter(
        text: TextSpan(
          text: DateFormat('dd/MM\nHH:mm').format(historial[i]['fecha']),
          style: const TextStyle(color: Colors.black87, fontSize: 10, height: 1.2, fontWeight: FontWeight.w500),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tpFecha.layout();
      tpFecha.paint(canvas, Offset(points[i].dx - tpFecha.width / 2, graphHeight + 15));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}