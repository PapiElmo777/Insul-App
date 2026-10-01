import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../controlador_detalle_paciente.dart';

class SeccionControlGlucemico extends StatelessWidget {
  final ControladorDetallePaciente controlador;

  const SeccionControlGlucemico({super.key, required this.controlador});

  void _mostrarDetallesPunto(BuildContext context, Map<String, dynamic> registro) {
    String estado = controlador.obtenerEstadoGlucosa(registro['valor']);
    Color colorEstado = controlador.obtenerColorEstado(estado);
    String fecha = DateFormat("EEEE, d 'de' MMMM yyyy", 'es_ES').format(registro['fecha']);
    String hora = DateFormat("HH:mm a", 'es_ES').format(registro['fecha']);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Detalle de Lectura', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 20)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: colorEstado),
                    ),
                    child: Text(estado, style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${registro['valor']}', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 48, color: colorEstado, height: 1.0)),
                  const SizedBox(width: 5),
                  const Text('mg/dL', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF1C63BB), size: 20),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fecha', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(fecha[0].toUpperCase() + fecha.substring(1), style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF1C63BB), size: 20),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hora', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(hora, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ).whenComplete(() {
      controlador.setIndiceGrafica(null);
    });
  }

  void _mostrarDialogoAgregarGlucosa(BuildContext context) {
    final TextEditingController glucosaCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Registrar Toma de Glucosa', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: glucosaCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: 'Ej. 110', suffixText: 'mg/dL', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (glucosaCtrl.text.isNotEmpty) {
                  int nuevoValor = int.parse(glucosaCtrl.text);
                  if (nuevoValor < 20 || nuevoValor > 600) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, ingresa un valor de glucosa realista (20 - 600 mg/dL)', style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        )
                    );
                    return;
                  }
                  await controlador.agregarGlucosa(nuevoValor);
                  if (context.mounted) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    int limiteHipo = controlador.paciente['hipoLimit'] ?? 70;
    int limiteHiper = controlador.paciente['hiperLimit'] ?? 180;
    int rangoMin = controlador.paciente['rangoMin'] ?? 80;
    int rangoMax = controlador.paciente['rangoMax'] ?? 130;
    List<Map<String, dynamic>> registrosGrafica = controlador.historialGlucosa.reversed.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text('Control Glucémico', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black))),
              TextButton.icon(
                onPressed: () => _mostrarDialogoAgregarGlucosa(context),
                icon: const Icon(Icons.add, color: Color(0xFF0C80EB), size: 20),
                label: const Text('Añadir', style: TextStyle(color: Color(0xFF0C80EB), fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(color: const Color(0xFFE8F4F8), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF008CCF))),
            child: Row(
              children: [
                const Icon(Icons.alarm, color: Color(0xFF008CCF)),
                const SizedBox(width: 10),
                Expanded(child: Text('Tipo: ${controlador.paciente['tipoDiabetes'] ?? 'No especificado'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF008CCF)))),
              ],
            ),
          ),

          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2))),
            child: registrosGrafica.isEmpty
                ? const Center(child: Text('Aún no hay medidas registradas', style: TextStyle(color: Colors.grey)))
                : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 30, top: 10, bottom: 5),
                  width: registrosGrafica.length > 5 ? registrosGrafica.length * 50.0 : MediaQuery.of(context).size.width - 40,
                  child: GestureDetector(
                    onTapUp: (details) {
                      double offsetX = 40.0;
                      double paddingX = 20.0;
                      double startX = offsetX + paddingX;

                      double customPaintWidth = (registrosGrafica.length > 5 ? registrosGrafica.length * 50.0 : MediaQuery.of(context).size.width - 40) - 40.0;
                      double graphWidth = customPaintWidth - offsetX;
                      double activeWidth = graphWidth - (paddingX * 2);

                      double stepX = registrosGrafica.length > 1 ? activeWidth / (registrosGrafica.length - 1) : activeWidth / 2;
                      double dx = details.localPosition.dx;

                      int index = ((dx - startX) / stepX).round();

                      if (index >= 0 && index < registrosGrafica.length) {
                        double pointX = registrosGrafica.length == 1 ? startX + (activeWidth / 2) : startX + (index * stepX);
                        if ((dx - pointX).abs() < 30.0) {
                          controlador.setIndiceGrafica(index);
                          int indiceReal = (registrosGrafica.length - 1) - index;
                          _mostrarDetallesPunto(context, controlador.historialGlucosa[indiceReal]);
                        }
                      }
                    },
                    child: CustomPaint(
                      painter: GraficaEnfermeroPainter(
                        historial: registrosGrafica,
                        limiteHipo: limiteHipo,
                        limiteHiper: limiteHiper,
                        rangoMin: rangoMin,
                        rangoMax: rangoMax,
                        indiceSeleccionado: controlador.indiceSeleccionadoGrafica,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(child: _crearTarjetaStat('Promedio', '${controlador.calcularPromedio().toStringAsFixed(1)}', 'mg/dL', Icons.timeline, const Color(0xFF008CCF))),
              const SizedBox(width: 15),
              Expanded(child: _crearTarjetaStat('TIR', '${controlador.calcularTIR().toStringAsFixed(0)}%', 'En rango', Icons.check_circle, const Color(0xFF2E7D32))),
            ],
          ),
        ],
      ),
    );
  }
}

class GraficaEnfermeroPainter extends CustomPainter {
  final List<Map<String, dynamic>> historial;
  final int limiteHipo, limiteHiper, rangoMin, rangoMax;
  final int? indiceSeleccionado;

  GraficaEnfermeroPainter({
    required this.historial,
    required this.limiteHipo,
    required this.limiteHiper,
    required this.rangoMin,
    required this.rangoMax,
    this.indiceSeleccionado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (historial.isEmpty) return;

    double maxY = limiteHiper.toDouble() + 50.0;
    double minY = limiteHipo.toDouble() - 20.0;
    if (minY < 0) minY = 0;

    for (var item in historial) {
      if (item['valor'] > maxY) maxY = item['valor'].toDouble() + 30;
      if (item['valor'] < minY) minY = item['valor'].toDouble() - 10;
    }

    double graphHeight = size.height - 40;
    double offsetX = 40.0;
    double paddingX = 20.0;
    double startX = offsetX + paddingX;
    double graphWidth = size.width - offsetX;
    double activeWidth = graphWidth - (paddingX * 2);

    double valToY(double val) {
      return graphHeight - (((val - minY) / (maxY - minY)) * graphHeight) + 10;
    }

    Paint bgPaint = Paint();

    bgPaint.color = const Color(0xFFD32F2F).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(limiteHipo.toDouble()), size.width, graphHeight + 10), bgPaint);

    bgPaint.color = const Color(0xFFE65100).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(rangoMin.toDouble()), size.width, valToY(limiteHipo.toDouble())), bgPaint);

    bgPaint.color = const Color(0xFF2E7D32).withOpacity(0.15);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(rangoMax.toDouble()), size.width, valToY(rangoMin.toDouble())), bgPaint);

    bgPaint.color = const Color(0xFFE65100).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTRB(offsetX, valToY(limiteHiper.toDouble()), size.width, valToY(rangoMax.toDouble())), bgPaint);

    bgPaint.color = const Color(0xFFD32F2F).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTRB(offsetX, 10, size.width, valToY(limiteHiper.toDouble())), bgPaint);

    Paint lineRef = Paint()..color = Colors.grey.withOpacity(0.3)..strokeWidth = 1;
    List<int> yLabels = [maxY.toInt(), limiteHiper, rangoMax, rangoMin, limiteHipo, minY.toInt()];
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

    List<Offset> points = [];
    double stepX = historial.length > 1 ? activeWidth / (historial.length - 1) : activeWidth / 2;

    for (int i = 0; i < historial.length; i++) {
      double x = historial.length == 1 ? startX + (activeWidth / 2) : startX + (i * stepX);
      double y = valToY(historial[i]['valor'].toDouble());
      points.add(Offset(x, y));
    }

    Paint linePaint = Paint()
      ..color = const Color(0xFF1C63BB)
      ..strokeWidth = 3.0
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

      if (val < limiteHipo) c = const Color(0xFFD32F2F);
      else if (val > limiteHiper) c = const Color(0xFFD32F2F);
      else if (val >= rangoMin && val <= rangoMax) c = const Color(0xFF2E7D32);
      else if (val < rangoMin) c = const Color(0xFFE65100);
      else c = const Color(0xFFE65100);

      if (indiceSeleccionado == i) {
        canvas.drawCircle(points[i], 14.0, Paint()..color = c.withOpacity(0.4)..style = PaintingStyle.fill);
        canvas.drawCircle(points[i], 8.0, Paint()..color = Colors.white..style = PaintingStyle.fill);
        canvas.drawCircle(points[i], 6.0, Paint()..color = c..style = PaintingStyle.fill);
      } else {
        canvas.drawCircle(points[i], 6.0, Paint()..color = Colors.white..style = PaintingStyle.fill);
        canvas.drawCircle(points[i], 4.0, Paint()..color = c..style = PaintingStyle.fill);
      }

      if (historial.length <= 14 || val < limiteHipo || val > limiteHiper || indiceSeleccionado == i) {
        TextPainter tpVal = TextPainter(
          text: TextSpan(text: '$val', style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: indiceSeleccionado == i ? 13 : 11)),
          textDirection: TextDirection.ltr,
        );
        tpVal.layout();
        tpVal.paint(canvas, Offset(points[i].dx - tpVal.width / 2, points[i].dy - (indiceSeleccionado == i ? 24 : 20)));
      }

      if (i == 0 || i == points.length - 1 || historial.length <= 14) {
        TextPainter tpFecha = TextPainter(
          text: TextSpan(
            text: DateFormat('HH:mm').format(historial[i]['fecha']),
            style: const TextStyle(color: Colors.black87, fontSize: 9, fontWeight: FontWeight.w500),
          ),
          textDirection: TextDirection.ltr,
        );
        tpFecha.layout();
        tpFecha.paint(canvas, Offset(points[i].dx - tpFecha.width / 2, graphHeight + 10));
      }
    }
  }

  @override
  bool shouldRepaint(covariant GraficaEnfermeroPainter oldDelegate) {
    return oldDelegate.indiceSeleccionado != indiceSeleccionado || oldDelegate.historial != historial;
  }
}
