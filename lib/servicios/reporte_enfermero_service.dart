import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;

class DatosEnfermero {
  final String nombre;
  final String cedula;
  final String area;
  final String hospital;

  DatosEnfermero({
    required this.nombre,
    required this.cedula,
    required this.area,
    required this.hospital,
  });
}

class _C {
  static const azul       = PdfColor.fromInt(0xFF1C63BB);
  static const azulOscuro = PdfColor.fromInt(0xFF0D3F7A);
  static const azulClaro  = PdfColor.fromInt(0xFFE8F0FB);
  static const cian       = PdfColor.fromInt(0xFF00D1FF);

  static const rojo       = PdfColor.fromInt(0xFFD32F2F);
  static const rojoBg     = PdfColor.fromInt(0xFFFFEBEE);
  static const naranja    = PdfColor.fromInt(0xFFE65100);
  static const naranjaBg  = PdfColor.fromInt(0xFFFFF3E0);
  static const verde      = PdfColor.fromInt(0xFF2E7D32);
  static const verdeBg    = PdfColor.fromInt(0xFFE8F5E9);

  static const blanco     = PdfColors.white;
  static const gris100    = PdfColor.fromInt(0xFFF5F5F5);
  static const gris200    = PdfColor.fromInt(0xFFEEEEEE);
  static const gris300    = PdfColor.fromInt(0xFFE0E0E0);
  static const gris500    = PdfColor.fromInt(0xFF9E9E9E);
  static const gris700    = PdfColor.fromInt(0xFF616161);
  static const gris900    = PdfColor.fromInt(0xFF212121);
}

PdfColor _op(PdfColor c, double a) {
  return PdfColor(c.red, c.green, c.blue, a);
}

PdfColor _colorSemaforo(int v, int hipo, int hiper, int rMin, int rMax) {
  if (v < hipo)   return _C.rojo;
  if (v < rMin)   return _C.naranja;
  if (v <= rMax)  return _C.verde;
  if (v <= hiper) return _C.naranja;
  return _C.rojo;
}

String _estadoTexto(int v, int hipo, int hiper, int rMin, int rMax) {
  if (v < hipo)   return 'Hipo';
  if (v < rMin)   return 'Bajo';
  if (v <= rMax)  return 'Normal';
  if (v <= hiper) return 'Elevado';
  return 'Hiper';
}

String _limpiarTexto(String? text) {
  if (text == null) return '';
  return text
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll('‘', "'")
      .replaceAll('’', "'")
      .replaceAll('•', '-');
}

class ReportePdfService {
  static Future<Uint8List> generarReporteTurno({
    required List<Map<String, dynamic>> pacientes,
    required DatosEnfermero enfermero,
    required String turno,
  }) async {
    final pdf = pw.Document(
      title: 'Reporte de Turno - InsulApp',
      author: 'InsulApp',
      subject: 'Reporte Clínico de Enfermería',
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
      ),
    );

    final fechaImpresion = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pw.Widget? logoWidget;
    try {
      String svgData = await rootBundle.loadString('assets/logo1.svg');
      svgData = svgData.replaceAll(RegExp(r'fill="[^"]*"'), 'fill="#1C63BB"');
      svgData = svgData.replaceAll(RegExp(r'stroke="[^"]*"'), 'stroke="#1C63BB"');
      if (!svgData.contains('fill="#1C63BB"')) {
        svgData = svgData.replaceFirst('<svg', '<svg fill="#1C63BB"');
      }
      logoWidget = pw.SvgImage(svg: svgData, width: 35, height: 35);
    } catch (_) {
      print("No se pudo cargar el logo SVG.");
    }

    int totalHipo = 0, totalHiper = 0, totalNormal = 0;
    for (final p in pacientes) {
      final hist = List<Map<String, dynamic>>.from(p['historialGlucosa'] ?? []);
      final hipo  = (p['hipoLimit'] as num?)?.toInt() ?? 70;
      final hiper = (p['hiperLimit'] as num?)?.toInt() ?? 180;
      final rMin  = (p['rangoMin'] as num?)?.toInt() ?? 80;
      final rMax  = (p['rangoMax'] as num?)?.toInt() ?? 130;

      for (final r in hist) {
        final v = (r['valor'] as num?)?.toInt() ?? 0;
        if (v < hipo || v > hiper) totalHipo++;
        else if (v >= rMin && v <= rMax) totalNormal++;
        else totalHiper++;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 34),
        footer: (ctx) => _footer(ctx, fechaImpresion),
        build: (ctx) => [
          _headerEnfermero(logoWidget, enfermero, turno, fechaImpresion),
          pw.SizedBox(height: 14),

          _tituloSeccion('RESUMEN DEL TURNO'),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            _tarjetaMetrica('Total Pacientes', '${pacientes.length}', _C.azul, _C.azulClaro),
            pw.SizedBox(width: 7),
            _tarjetaMetrica('Lecturas en Rango', '$totalNormal', _C.verde, _C.verdeBg),
            pw.SizedBox(width: 7),
            _tarjetaMetrica('Fuera de Rango', '$totalHiper', _C.naranja, _C.naranjaBg),
            pw.SizedBox(width: 7),
            _tarjetaMetrica('Eventos Críticos', '$totalHipo', _C.rojo, _C.rojoBg),
          ]),
          pw.SizedBox(height: 16),

          _tituloSeccion('CENSO DE PACIENTES ASIGNADOS'),
          pw.SizedBox(height: 8),
          _tablaPacientes(pacientes),
          pw.SizedBox(height: 16),

          _disclaimer(),
          if (pacientes.isEmpty) ...[
            pw.SizedBox(height: 40),
            _seccionFirma(enfermero),
          ]
        ],
      ),
    );

    for (int i = 0; i < pacientes.length; i += 2) {
      final grupo = pacientes.sublist(i, math.min(i + 2, pacientes.length));
      final bool esUltimoGrupo = (i + 2 >= pacientes.length);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 34),
          footer: (ctx) => _footer(ctx, fechaImpresion),
          build: (ctx) => [
            for (int j = 0; j < grupo.length; j++) ...[
              _bloquePacienteDetalle(grupo[j]),
              if (j < grupo.length - 1) pw.SizedBox(height: 16),
            ],
            if (esUltimoGrupo) ...[
              pw.SizedBox(height: 35),
              _seccionFirma(enfermero),
            ]
          ],
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _headerEnfermero(
      pw.Widget? logoWidget, DatosEnfermero enf, String turno, String fecha) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        color: _C.azul,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(children: [
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Row(children: [
                if (logoWidget != null)
                  pw.Container(
                    width: 38, height: 38,
                    decoration: const pw.BoxDecoration(
                      color: _C.blanco, shape: pw.BoxShape.circle,
                    ),
                    padding: const pw.EdgeInsets.all(5),
                    child: logoWidget,
                  ),
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Insul App',
                        style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold,
                          color: _C.blanco,
                        )),
                    pw.Text('Sistema de Enfermería y Monitoreo',
                        style: const pw.TextStyle(fontSize: 8, color: _C.cian)),
                  ],
                ),
              ]),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('REPORTE DE TURNO',
                      style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold,
                        color: _C.blanco,
                      )),
                  pw.Text('Turno $turno',
                      style: const pw.TextStyle(fontSize: 8, color: _C.cian)),
                ],
              ),
            ],
          ),
        ),
        // Banda de datos del enfermero
        pw.Container(
          decoration: const pw.BoxDecoration(
            color: _C.azulOscuro,
            borderRadius: pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(10),
              bottomRight: pw.Radius.circular(10),
            ),
          ),
          padding: const pw.EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Enf. ${_limpiarTexto(enf.nombre)}',
                      style: pw.TextStyle(
                        fontSize: 13, fontWeight: pw.FontWeight.bold,
                        color: _C.blanco,
                      )),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Cédula: ${_limpiarTexto(enf.cedula)}  |  Área: ${_limpiarTexto(enf.area)}',
                    style: const pw.TextStyle(fontSize: 8, color: _C.gris300),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Institución:', style: const pw.TextStyle(fontSize: 8, color: _C.gris500)),
                  pw.Text(
                      _limpiarTexto(enf.hospital),
                      style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold,
                        color: _C.cian,
                      )),
                  pw.SizedBox(height: 6),
                  pw.Text('Generado: $fecha', style: const pw.TextStyle(fontSize: 8, color: _C.gris300)),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  static pw.Widget _tablaPacientes(List<Map<String, dynamic>> pacientes) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _C.blanco,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _C.gris300, width: 0.5),
      ),
      child: pw.Table(
        border: pw.TableBorder.symmetric(
          inside: const pw.BorderSide(color: _C.gris200, width: 0.5),
        ),
        columnWidths: {
          0: const pw.FlexColumnWidth(3),
          1: const pw.FlexColumnWidth(1.5),
          2: const pw.FlexColumnWidth(1.5),
          3: const pw.FlexColumnWidth(1.5),
          4: const pw.FlexColumnWidth(1.5),
          5: const pw.FlexColumnWidth(2),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _C.azulClaro),
            children: ['PACIENTE', 'CAMA', 'TIPO', 'GLUCOSA', 'ESTADO', 'ALERGIAS']
                .map((h) => pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(h,
                  style: pw.TextStyle(
                      fontSize: 7.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _C.azulOscuro)),
            ))
                .toList(),
          ),
          ...pacientes.map((p) {
            final hist = List<Map<String, dynamic>>.from(p['historialGlucosa'] ?? []);
            final hipo  = (p['hipoLimit'] as num?)?.toInt() ?? 70;
            final hiper = (p['hiperLimit'] as num?)?.toInt() ?? 180;
            final rMin  = (p['rangoMin'] as num?)?.toInt() ?? 80;
            final rMax  = (p['rangoMax'] as num?)?.toInt() ?? 130;

            int ultimaG = 0;
            if (hist.isNotEmpty) {
              ultimaG = (hist.first['valor'] as num?)?.toInt() ?? 0;
            }

            final colorG = ultimaG > 0 ? _colorSemaforo(ultimaG, hipo, hiper, rMin, rMax) : _C.gris500;
            final estado = ultimaG > 0 ? _estadoTexto(ultimaG, hipo, hiper, rMin, rMax) : '--';
            final alergias = (p['alergias'] ?? 'Ninguna').toString();

            return pw.TableRow(
              children: [
                _celda(p['nombre'] ?? '--', bold: true),
                _celda(p['ubicacion'] ?? '--'),
                _celda(p['tipoDiabetes'] ?? '--'),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(ultimaG > 0 ? '$ultimaG mg/dL' : '--',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: colorG)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: _op(colorG, 0.1),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(estado,
                        style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: colorG)),
                  ),
                ),
                _celda(alergias, color: alergias == 'Ninguna' ? _C.gris700 : _C.rojo),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  static pw.Widget _celda(String texto, {bool bold = false, PdfColor color = _C.gris700}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(_limpiarTexto(texto),
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          )),
    );
  }

  static pw.Widget _bloquePacienteDetalle(Map<String, dynamic> p) {
    final hist = List<Map<String, dynamic>>.from(p['historialGlucosa'] ?? []);
    final meds = List<Map<String, dynamic>>.from(p['medicamentos'] ?? []);
    final histIns = List<Map<String, dynamic>>.from(p['historialInsulina'] ?? []);
    final rawObs = p['observacionesTurno'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> obsConvertidas = rawObs.map((o) {
      if (o is String) return {'nota': o};
      if (o is Map) return Map<String, dynamic>.from(o);
      return {'nota': o.toString()};
    }).toList();

    final hipo  = (p['hipoLimit'] as num?)?.toInt() ?? 70;
    final hiper = (p['hiperLimit'] as num?)?.toInt() ?? 180;
    final rMin  = (p['rangoMin'] as num?)?.toInt() ?? 80;
    final rMax  = (p['rangoMax'] as num?)?.toInt() ?? 130;

    double promedio = 0; int enRango = 0;
    if (hist.isNotEmpty) {
      double suma = 0;
      for (final r in hist) {
        final v = (r['valor'] as num?)?.toInt() ?? 0;
        suma += v;
        if (v >= rMin && v <= rMax) enRango++;
      }
      promedio = suma / hist.length;
    }
    final tir = hist.isNotEmpty ? (enRango / hist.length * 100).toStringAsFixed(0) : '--';
    final ultVal = hist.isNotEmpty ? (hist.first['valor'] as num?)?.toInt() ?? 0 : 0;
    final colorUlt = ultVal > 0 ? _colorSemaforo(ultVal, hipo, hiper, rMin, rMax) : _C.gris500;

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _C.blanco,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _C.gris300, width: 0.5),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const pw.BoxDecoration(
              color: _C.azulOscuro,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(_limpiarTexto(p['nombre'] ?? 'Paciente'),
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _C.blanco)),
                    pw.SizedBox(height: 2),
                    pw.Text('Cama: ${_limpiarTexto(p['ubicacion'])} | Exp: ${_limpiarTexto(p['expediente'])} | DM ${_limpiarTexto(p['tipoDiabetes'])}',
                        style: const pw.TextStyle(fontSize: 7.5, color: _C.gris300)),
                  ],
                ),
                if (ultVal > 0)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: _op(colorUlt, 0.2),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      border: pw.Border.all(color: colorUlt),
                    ),
                    child: pw.Text('$ultVal mg/dL',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: colorUlt)),
                  )
              ],
            ),
          ),

          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              children: [
                pw.Row(children: [
                  _tarjetaMetrica('Promedio', '${promedio.round()} mg/dL', _C.azul, _C.azulClaro),
                  pw.SizedBox(width: 6),
                  _tarjetaMetrica('TIR (En rango)', '$tir%', _C.verde, _C.verdeBg),
                  pw.SizedBox(width: 6),
                  _tarjetaMetrica('Lecturas', '${hist.length}', _C.gris700, _C.gris100),
                ]),
                pw.SizedBox(height: 10),

                if (hist.isNotEmpty) ...[
                  _graficaTurno(hist, hipo, hiper, rMin, rMax),
                  pw.SizedBox(height: 10),
                ],

                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 38,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _tituloSeccion('MEDICAMENTOS'),
                          pw.SizedBox(height: 4),
                          _listaCajas(meds, tipo: 1),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      flex: 24,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _tituloSeccion('INSULINA'),
                          pw.SizedBox(height: 4),
                          _listaCajas(histIns, tipo: 2),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      flex: 38,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _tituloSeccion('NOTAS'),
                          pw.SizedBox(height: 4),
                          _listaCajas(obsConvertidas, tipo: 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  static pw.Widget _graficaTurno(List<Map<String, dynamic>> registros, int hipo, int hiper, int rMin, int rMax) {
    final regs = List<Map<String, dynamic>>.from(registros)
      ..sort((a, b) => (a['fecha'] as DateTime).compareTo(b['fecha'] as DateTime));

    final List<pw.PointChartValue> pts = [];
    for (int i = 0; i < regs.length; i++) {
      pts.add(pw.PointChartValue(i.toDouble(), (regs[i]['valor'] as num).toDouble()));
    }

    final double n = regs.length.toDouble();
    final List<pw.Dataset> datasets = [
      pw.LineDataSet(data: [pw.PointChartValue(0, (hiper + 50).toDouble()), pw.PointChartValue(n, (hiper + 50).toDouble())], lineWidth: 0, color: _C.rojoBg, drawPoints: false, drawSurface: true),
      pw.LineDataSet(data: [pw.PointChartValue(0, hiper.toDouble()), pw.PointChartValue(n, hiper.toDouble())], lineWidth: 0, color: _C.naranjaBg, drawPoints: false, drawSurface: true),
      pw.LineDataSet(data: [pw.PointChartValue(0, rMax.toDouble()), pw.PointChartValue(n, rMax.toDouble())], lineWidth: 0, color: _C.verdeBg, drawPoints: false, drawSurface: true),
      pw.LineDataSet(data: [pw.PointChartValue(0, rMin.toDouble()), pw.PointChartValue(n, rMin.toDouble())], lineWidth: 0, color: _C.naranjaBg, drawPoints: false, drawSurface: true),
      pw.LineDataSet(data: [pw.PointChartValue(0, hipo.toDouble()), pw.PointChartValue(n, hipo.toDouble())], lineWidth: 0, color: _C.rojoBg, drawPoints: false, drawSurface: true),
      pw.LineDataSet(data: [pw.PointChartValue(0, rMax.toDouble()), pw.PointChartValue(n, rMax.toDouble())], lineWidth: 1, color: _C.verde, drawPoints: false),
      pw.LineDataSet(data: [pw.PointChartValue(0, rMin.toDouble()), pw.PointChartValue(n, rMin.toDouble())], lineWidth: 1, color: _C.verde, drawPoints: false),
      pw.LineDataSet(data: [pw.PointChartValue(0, hiper.toDouble()), pw.PointChartValue(n, hiper.toDouble())], lineWidth: 0.8, color: _C.naranja, drawPoints: false),
      pw.LineDataSet(data: [pw.PointChartValue(0, hipo.toDouble()), pw.PointChartValue(n, hipo.toDouble())], lineWidth: 0.8, color: _C.naranja, drawPoints: false),
      pw.LineDataSet(data: pts, lineWidth: 1.5, color: _C.azul, drawPoints: false, isCurved: true),
    ];

    for (int i = 0; i < regs.length; i++) {
      final val = (regs[i]['valor'] as num).toInt();
      final pc = _colorSemaforo(val, hipo, hiper, rMin, rMax);
      datasets.add(pw.LineDataSet(
        data: [pw.PointChartValue(i.toDouble(), val.toDouble())],
        lineWidth: 0, color: pc, drawPoints: true, pointSize: 3, pointColor: pc,
      ));
    }

    final xTicks = <double>[];
    for (int i = 0; i < regs.length; i += math.max(1, regs.length ~/ 6)) {
      xTicks.add(i.toDouble());
    }

    return pw.Container(
      height: 120,
      decoration: pw.BoxDecoration(
        color: _C.blanco,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: _C.gris300, width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(5),
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis(xTicks, buildLabel: (v) {
            final idx = v.toInt();
            if (idx >= 0 && idx < regs.length) {
              return pw.Text(DateFormat('HH:mm').format(regs[idx]['fecha'] as DateTime), style: const pw.TextStyle(fontSize: 5, color: _C.gris700));
            }
            return pw.Text('');
          }, ticks: false),
          yAxis: pw.FixedAxis([0, hipo.toDouble(), rMin.toDouble(), rMax.toDouble(), hiper.toDouble(), (hiper + 50).toDouble()],
              buildLabel: (v) => pw.Text('${v.toInt()}', style: const pw.TextStyle(fontSize: 5.5, color: _C.gris700))),
        ),
        datasets: datasets,
      ),
    );
  }

  static pw.Widget _listaCajas(List<dynamic> items, {required int tipo}) {
    if (items.isEmpty) {
      String txt = tipo == 1 ? 'Sin medicación' : tipo == 2 ? 'Sin insulina' : 'Sin notas';
      items = [{'empty': txt}];
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: _C.gris100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: _C.gris300, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.take(4).map((item) {
          String titulo = '';
          String subtitulo = '';
          PdfColor colorPunto = _C.gris500;

          if (item is Map && item.containsKey('empty')) {
            titulo = item['empty'];
            colorPunto = _C.gris300;
          } else if (tipo == 1) {
            titulo = '${item['nombre'] ?? ''} ${item['dosis'] != null ? '- ${item['dosis']}' : ''}';
            subtitulo = item['frecuencia'] ?? '';
            final sum = (item['suministrado'] == 1 || item['suministrado'] == true);
            if (item.containsKey('suministrado')) {
              subtitulo += sum ? ' (Aplicado)' : ' (Pendiente)';
            }
            colorPunto = sum ? _C.verde : _C.naranja;
          } else if (tipo == 2) {
            titulo = '${item['unidades']} UI';
            colorPunto = _C.azul;
            if (item['fecha'] != null) {
              final f = item['fecha'] is DateTime ? item['fecha'] : DateTime.tryParse(item['fecha'].toString());
              if (f != null) subtitulo = DateFormat('dd/MM HH:mm').format(f);
            }
          } else if (tipo == 3) {
            titulo = _limpiarTexto(item['nota'] ?? item['observacion']);
            colorPunto = _C.naranja;
            if (item['fecha'] != null) {
              final f = item['fecha'] is DateTime ? item['fecha'] : DateTime.tryParse(item['fecha'].toString());
              if (f != null) subtitulo = DateFormat('dd/MM HH:mm').format(f);
            }
          }

          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 3.5, height: 3.5,
                  margin: const pw.EdgeInsets.only(top: 3, right: 4),
                  decoration: pw.BoxDecoration(color: colorPunto, shape: pw.BoxShape.circle),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(titulo, style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: _C.gris900)),
                      if (subtitulo.isNotEmpty)
                        pw.Text(subtitulo, style: const pw.TextStyle(fontSize: 5.5, color: _C.gris700)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static pw.Widget _tituloSeccion(String texto) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const pw.BoxDecoration(
        color: _C.azul,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(texto,
          style: pw.TextStyle(
            fontSize: 8.5, fontWeight: pw.FontWeight.bold,
            color: _C.blanco, letterSpacing: 0.5,
          )),
    );
  }

  static pw.Widget _tarjetaMetrica(String label, String valor, PdfColor colorTexto, PdfColor colorFondo) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: colorFondo,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: colorTexto, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 7, color: _C.gris700, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 3),
            pw.Text(valor, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: colorTexto)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _seccionFirma(DatosEnfermero enf) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 40, bottom: 10),
      alignment: pw.Alignment.center,
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(
            width: 250,
            height: 1,
            color: _C.gris900,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Enf. ${_limpiarTexto(enf.nombre)}',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _C.gris900),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Cédula: ${_limpiarTexto(enf.cedula)}',
            style: const pw.TextStyle(fontSize: 9, color: _C.gris700),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Firma de Entrega de Turno',
            style: const pw.TextStyle(fontSize: 9, color: _C.gris500),
          ),
        ],
      ),
    );
  }

  static pw.Widget _disclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: const pw.BoxDecoration(
        color: _C.gris100,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        'Documento clínico confidencial generado por InsulApp. Para uso exclusivo del personal de salud. '
            'Las decisiones terapéuticas requieren validación médica.',
        style: const pw.TextStyle(fontSize: 6.5, color: _C.gris700),
      ),
    );
  }

  static pw.Widget _footer(pw.Context ctx, String fecha) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 6),
      padding: const pw.EdgeInsets.only(top: 5),
      decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _C.gris300, width: 0.5))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('InsulApp - Reporte de Enfermería', style: const pw.TextStyle(fontSize: 7, color: _C.gris500)),
          pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 7, color: _C.gris500)),
          pw.Text(fecha, style: const pw.TextStyle(fontSize: 7, color: _C.gris500)),
        ],
      ),
    );
  }
}