import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class GraficaGlucosaUniversal extends StatelessWidget {
  final List<Map<String, dynamic>> registros;
  final int limiteHipo;
  final int limiteHiper;
  final int rangoMin;
  final int rangoMax;
  final int? indiceSeleccionado;
  final Function(int) onTapPunto;
  final double altura;

  const GraficaGlucosaUniversal({
    super.key,
    required this.registros,
    required this.limiteHipo,
    required this.limiteHiper,
    required this.rangoMin,
    required this.rangoMax,
    this.indiceSeleccionado,
    required this.onTapPunto,
    this.altura = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: altura,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2))),
      child: registros.isEmpty
          ? const Center(child: Text('Aún no hay medidas registradas', style: TextStyle(color: Colors.grey)))
          : ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 30, top: 10, bottom: 5),
            width: registros.length > 5 ? registros.length * 50.0 : MediaQuery.of(context).size.width - 40,
            child: GestureDetector(
              onTapUp: (details) {
                double offsetX = 40.0;
                double paddingX = 20.0;
                double startX = offsetX + paddingX;

                double customPaintWidth = (registros.length > 5 ? registros.length * 50.0 : MediaQuery.of(context).size.width - 40) - 40.0;
                double graphWidth = customPaintWidth - offsetX;
                double activeWidth = graphWidth - (paddingX * 2);

                double stepX = registros.length > 1 ? activeWidth / (registros.length - 1) : activeWidth / 2;
                double dx = details.localPosition.dx;

                int index = ((dx - startX) / stepX).round();

                if (index >= 0 && index < registros.length) {
                  double pointX = registros.length == 1 ? startX + (activeWidth / 2) : startX + (index * stepX);
                  if ((dx - pointX).abs() < 30.0) {
                    onTapPunto(index);
                  }
                }
              },
              child: CustomPaint(
                painter: _GraficaUniversalPainter(
                  historial: registros,
                  limiteHipo: limiteHipo,
                  limiteHiper: limiteHiper,
                  rangoMin: rangoMin,
                  rangoMax: rangoMax,
                  indiceSeleccionado: indiceSeleccionado,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GraficaUniversalPainter extends CustomPainter {
  final List<Map<String, dynamic>> historial;
  final int limiteHipo, limiteHiper, rangoMin, rangoMax;
  final int? indiceSeleccionado;

  _GraficaUniversalPainter({
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
      if ((item['valor'] as num) > maxY) maxY = (item['valor'] as num).toDouble() + 30;
      if ((item['valor'] as num) < minY) minY = (item['valor'] as num).toDouble() - 10;
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
      double y = valToY((historial[i]['valor'] as num).toDouble());
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
      int val = (historial[i]['valor'] as num).toInt();
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
        DateTime fecha = historial[i]['fecha'] is DateTime ? historial[i]['fecha'] : DateTime.tryParse(historial[i]['fecha'].toString()) ?? DateTime.now();
        TextPainter tpFecha = TextPainter(
          text: TextSpan(
            text: DateFormat('HH:mm').format(fecha),
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
  bool shouldRepaint(covariant _GraficaUniversalPainter oldDelegate) {
    return oldDelegate.indiceSeleccionado != indiceSeleccionado || oldDelegate.historial != historial;
  }
}
