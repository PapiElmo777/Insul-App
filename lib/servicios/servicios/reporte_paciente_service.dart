import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;

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

PdfColor _colorSemaforo(int v, int hipo, int hiper, int rMin, int rMax) {
  if (v < hipo)   return _C.rojo;
  if (v < rMin)   return _C.naranja;
  if (v <= rMax)  return _C.verde;
  if (v <= hiper) return _C.naranja;
  return _C.rojo;
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

class _TirRow {
  final String label, rango;
  final double pct;
  final PdfColor color;
  final int count;
  final bool meta;
  const _TirRow(this.label, this.rango, this.pct, this.color, this.count, {this.meta = false});
}

class _BarRow {
  final String label, rango;
  final double pct;
  final PdfColor color;
  final int count;
  const _BarRow(this.label, this.rango, this.pct, this.color, this.count);
}

class ReportePacienteService {
  static Future<Uint8List> generarReporteAGP({
    required Map<String, dynamic> paciente,
    required List<Map<String, dynamic>> registros,
  }) async {
    final pdf = pw.Document(
      title: 'Informe AGP - InsulApp',
      author: 'InsulApp',
      subject: 'Perfil Ambulatorio de Glucosa',
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
      ),
    );

    final fechaImpresion = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Logo
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

    // Parámetros clínicos
    final int hipo  = paciente['limiteHipo'] ?? 70;
    final int hiper = paciente['hiperLimit'] ?? 180;
    final int rMin  = paciente['rangoMin']   ?? 80;
    final int rMax  = paciente['rangoMax']   ?? 130;

    // Estadísticas
    final int total = registros.length;
    double promedio = 0, cv = 0;
    int cHipo = 0, cBajo = 0, cNormal = 0, cElevado = 0, cHiper = 0;
    int minVal = 9999, maxVal = 0;

    if (total > 0) {
      double suma = 0;
      for (final r in registros) {
        final int v = r['valor'] as int;
        suma += v;
        if (v < minVal) minVal = v;
        if (v > maxVal) maxVal = v;
        if      (v <  hipo ) cHipo++;
        else if (v <  rMin ) cBajo++;
        else if (v <= rMax ) cNormal++;
        else if (v <= hiper) cElevado++;
        else                 cHiper++;
      }
      promedio = suma / total;
      double sumaCuad = 0;
      for (final r in registros) {
        sumaCuad += math.pow((r['valor'] as int) - promedio, 2);
      }
      final desvStd = math.sqrt(sumaCuad / total);
      cv = promedio > 0 ? (desvStd / promedio) * 100 : 0.0;
    }

    final double pHipo    = total > 0 ? (cHipo    / total) * 100 : 0;
    final double pBajo    = total > 0 ? (cBajo    / total) * 100 : 0;
    final double pNormal  = total > 0 ? (cNormal  / total) * 100 : 0;
    final double pElevado = total > 0 ? (cElevado / total) * 100 : 0;
    final double pHiper   = total > 0 ? (cHiper   / total) * 100 : 0;

    // Rango de fechas
    String rangoFechas = '--';
    if (registros.isNotEmpty) {
      final sorted = List<Map<String, dynamic>>.from(registros)
        ..sort((a, b) => (a['fecha'] as DateTime).compareTo(b['fecha'] as DateTime));
      final ini  = DateFormat('dd MMM yyyy').format(sorted.first['fecha'] as DateTime);
      final fin  = DateFormat('dd MMM yyyy').format(sorted.last['fecha'] as DateTime);
      final dias = (sorted.last['fecha'] as DateTime).difference(sorted.first['fecha'] as DateTime).inDays + 1;
      rangoFechas = '$ini - $fin ($dias días)';
    }

    // PÁGINA
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 34),
        footer: (ctx) => _footer(ctx, fechaImpresion),
        build: (ctx) => [
          _header(logoWidget, paciente, fechaImpresion, rangoFechas),
          pw.SizedBox(height: 14),

          _tituloSeccion('RESUMEN GLUCÉMICO'),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 58,
                child: pw.Column(children: [
                  pw.Row(children: [
                    _tarjetaMetrica('Glucosa Promedio', '${promedio.round()} mg/dL', _C.azul, _C.azulClaro, nota: 'Meta: <154 mg/dL'),
                    pw.SizedBox(width: 7),
                    _tarjetaMetrica('Variabilidad (CV)', '${cv.toStringAsFixed(1)}%', cv > 36 ? _C.naranja : _C.verde, cv > 36 ? _C.naranjaBg : _C.verdeBg, nota: 'Meta: <36%'),
                    pw.SizedBox(width: 7),
                    _tarjetaMetrica('Total Lecturas', '$total', _C.gris700, _C.gris100),
                  ]),
                  pw.SizedBox(height: 7),
                  pw.Row(children: [
                    _tarjetaMetrica('Mínimo Registrado', total > 0 ? '$minVal mg/dL' : '--', _C.rojo, _C.rojoBg),
                    pw.SizedBox(width: 7),
                    _tarjetaMetrica('Máximo Registrado', total > 0 ? '$maxVal mg/dL' : '--', _C.rojo, _C.rojoBg),
                    pw.SizedBox(width: 7),
                    _tarjetaMetrica('En Rango (TIR)', '${pNormal.toStringAsFixed(0)}%', _C.verde, _C.verdeBg, nota: 'Meta: >70%'),
                  ]),
                ]),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                flex: 42,
                child: _panelTIR(
                  pHipo: pHipo, pBajo: pBajo, pNormal: pNormal,
                  pElevado: pElevado, pHiper: pHiper,
                  cHipo: cHipo, cBajo: cBajo, cNormal: cNormal,
                  cElevado: cElevado, cHiper: cHiper,
                  hipo: hipo, hiper: hiper, rMin: rMin, rMax: rMax,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          _tituloSeccion('PERFIL AMBULATORIO DE GLUCOSA (AGP)'),
          pw.SizedBox(height: 5),
          pw.Text(
            'Curva de tendencia histórica con líneas de referencia clínica. '
                'Los puntos se colorean: Verde = Normal, Naranja = Bajo/Elevado, Rojo = Hipoglucemia/Hiperglucemia.',
            style: const pw.TextStyle(fontSize: 7.5, color: _C.gris700),
          ),
          pw.SizedBox(height: 8),
          _graficaAGP(registros, hipo, hiper, rMin, rMax),
          pw.SizedBox(height: 16),

          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _tituloSeccion('DISTRIBUCIÓN DE LECTURAS'),
                    pw.SizedBox(height: 8),
                    _distribucion(
                      pHipo: pHipo, pBajo: pBajo, pNormal: pNormal,
                      pElevado: pElevado, pHiper: pHiper,
                      cHipo: cHipo, cBajo: cBajo, cNormal: cNormal,
                      cElevado: cElevado, cHiper: cHiper,
                      hipo: hipo, hiper: hiper, rMin: rMin, rMax: rMax,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _tituloSeccion('NOTAS CLÍNICAS RECIENTES'),
                    pw.SizedBox(height: 8),
                    _notas(registros),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          _leyenda(),
          pw.SizedBox(height: 8),
          _disclaimer(),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _header(
      pw.Widget? logoWidget,
      Map<String, dynamic> paciente,
      String fecha,
      String rangoFechas,
      ) {
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
                    pw.Text('Monitoreo, cuidado y salud en tus manos',
                        style: const pw.TextStyle(fontSize: 8, color: _C.cian)),
                  ],
                ),
              ]),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('INFORME AGP',
                      style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold,
                        color: _C.blanco,
                      )),
                  pw.Text('Perfil Ambulatorio de Glucosa',
                      style: const pw.TextStyle(fontSize: 8, color: _C.cian)),
                ],
              ),
            ],
          ),
        ),
        // Banda datos paciente
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
                  pw.Text(_limpiarTexto(paciente['nombre'] ?? 'Paciente'),
                      style: pw.TextStyle(
                        fontSize: 13, fontWeight: pw.FontWeight.bold,
                        color: _C.blanco,
                      )),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Edad: ${paciente['edad'] ?? '--'} años  |  '
                        'Tipo Diabetes: ${_limpiarTexto(paciente['tipoDiabetes'] ?? '--')}',
                    style: const pw.TextStyle(fontSize: 8, color: _C.gris300),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text('Período: $rangoFechas', style: const pw.TextStyle(fontSize: 8, color: _C.gris300)),
                  if ((paciente['peso'] ?? 0) > 0 || (paciente['altura'] ?? 0) > 0)
                    pw.Text(
                      'Peso: ${paciente['peso'] ?? '--'} kg  |  '
                          'Talla: ${paciente['altura'] ?? '--'} cm  |  '
                          'IMC: ${paciente['imc'] != null ? (paciente['imc'] as double).toStringAsFixed(1) : '--'}',
                      style: const pw.TextStyle(fontSize: 8, color: _C.gris300),
                    ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Para atención de:', style: const pw.TextStyle(fontSize: 8, color: _C.gris500)),
                  pw.Text(
                      'Dr(a). ${_limpiarTexto(paciente['medico'] ?? 'Médico Tratante')}',
                      style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold,
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

  static pw.Widget _tarjetaMetrica(
      String label, String valor,
      PdfColor colorTexto, PdfColor colorFondo, {String? nota}
      ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(9),
        decoration: pw.BoxDecoration(
          color: colorFondo,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: colorTexto, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                  fontSize: 7.5, color: _C.gris700,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.SizedBox(height: 4),
            pw.Text(valor,
                style: pw.TextStyle(
                  fontSize: 13, fontWeight: pw.FontWeight.bold,
                  color: colorTexto,
                )),
            if (nota != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(nota, style: const pw.TextStyle(fontSize: 6.5, color: _C.gris500)),
            ],
          ],
        ),
      ),
    );
  }

  static pw.Widget _panelTIR({
    required double pHipo, required double pBajo, required double pNormal,
    required double pElevado, required double pHiper,
    required int cHipo, required int cBajo, required int cNormal,
    required int cElevado, required int cHiper,
    required int hipo, required int hiper, required int rMin, required int rMax,
  }) {
    final categorias = [
      _TirRow('Muy Elevado', '>$hiper mg/dL', pHiper, _C.rojo, cHiper),
      _TirRow('Elevado', '${rMax + 1}-$hiper', pElevado, _C.naranja, cElevado),
      _TirRow('En Rango', '$rMin-$rMax', pNormal, _C.verde, cNormal, meta: true),
      _TirRow('Bajo', '$hipo-$rMin', pBajo, _C.naranja, cBajo),
      _TirRow('Muy Bajo', '<$hipo mg/dL', pHipo, _C.rojo, cHipo),
    ];

    const barH = 165.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _C.gris100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _C.gris300, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('TIEMPO EN RANGO (TIR)',
              style: pw.TextStyle(
                fontSize: 7.5, fontWeight: pw.FontWeight.bold,
                color: _C.azul, letterSpacing: 0.4,
              )),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 26, height: barH,
                decoration: pw.BoxDecoration(
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  border: pw.Border.all(color: _C.gris300, width: 0.5),
                ),
                child: pw.Column(
                  children: categorias.map((c) {
                    final segH = (c.pct / 100) * barH;
                    if (segH < 0.5) return pw.SizedBox();
                    return pw.Container(width: 26, height: segH, color: c.color);
                  }).toList(),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Column(
                  children: categorias.map((c) => _filaTIR(c)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _filaTIR(_TirRow c) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(children: [
            pw.Container(
              width: 9, height: 9,
              decoration: pw.BoxDecoration(
                color: c.color,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
            ),
            pw.SizedBox(width: 4),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(children: [
                  pw.Text(c.label,
                      style: pw.TextStyle(
                        fontSize: 7, fontWeight: pw.FontWeight.bold,
                        color: c.color,
                      )),
                  if (c.meta)
                    pw.Container(
                      margin: const pw.EdgeInsets.only(left: 3),
                      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      color: _C.verde,
                      child: pw.Text('META',
                          style: pw.TextStyle(
                            fontSize: 5, fontWeight: pw.FontWeight.bold,
                            color: _C.blanco,
                          )),
                    ),
                ]),
                pw.Text(c.rango, style: const pw.TextStyle(fontSize: 6, color: _C.gris500)),
              ],
            ),
          ]),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('${c.pct.toStringAsFixed(0)}%',
                  style: pw.TextStyle(
                    fontSize: 9, fontWeight: pw.FontWeight.bold, color: c.color,
                  )),
              pw.Text('${c.count} lect.', style: const pw.TextStyle(fontSize: 6, color: _C.gris500)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _graficaAGP(
      List<Map<String, dynamic>> registros,
      int hipo, int hiper, int rMin, int rMax,
      ) {
    if (registros.isEmpty) {
      return pw.Container(
        height: 190,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          color: _C.gris100,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: _C.gris300),
        ),
        child: pw.Text('Sin datos para graficar.', style: const pw.TextStyle(color: _C.gris500)),
      );
    }

    final regsOrdenados = List<Map<String, dynamic>>.from(registros)
      ..sort((a, b) => (a['fecha'] as DateTime).compareTo(b['fecha'] as DateTime));

    final List<pw.PointChartValue> lineaPrincipal = [];
    for (int i = 0; i < regsOrdenados.length; i++) {
      lineaPrincipal.add(pw.PointChartValue(
        i.toDouble(),
        (regsOrdenados[i]['valor'] as int).toDouble(),
      ));
    }

    final double n = regsOrdenados.length.toDouble();
    final List<pw.Dataset> datasets = [];

    // --- BANDAS DE COLOR (FONDO) ---
    datasets.add(pw.LineDataSet(
      data: [pw.PointChartValue(0, (hiper + 50).toDouble()), pw.PointChartValue(n, (hiper + 50).toDouble())],
      lineWidth: 0, color: _C.rojoBg, drawPoints: false, isCurved: false, drawSurface: true, surfaceOpacity: 1,
    ));
    datasets.add(pw.LineDataSet(
      data: [pw.PointChartValue(0, hiper.toDouble()), pw.PointChartValue(n, hiper.toDouble())],
      lineWidth: 0, color: _C.naranjaBg, drawPoints: false, isCurved: false, drawSurface: true, surfaceOpacity: 1,
    ));
    datasets.add(pw.LineDataSet(
      data: [pw.PointChartValue(0, rMax.toDouble()), pw.PointChartValue(n, rMax.toDouble())],
      lineWidth: 0, color: _C.verdeBg, drawPoints: false, isCurved: false, drawSurface: true, surfaceOpacity: 1,
    ));
    datasets.add(pw.LineDataSet(
      data: [pw.PointChartValue(0, rMin.toDouble()), pw.PointChartValue(n, rMin.toDouble())],
      lineWidth: 0, color: _C.naranjaBg, drawPoints: false, isCurved: false, drawSurface: true, surfaceOpacity: 1,
    ));
    datasets.add(pw.LineDataSet(
      data: [pw.PointChartValue(0, hipo.toDouble()), pw.PointChartValue(n, hipo.toDouble())],
      lineWidth: 0, color: _C.rojoBg, drawPoints: false, isCurved: false, drawSurface: true, surfaceOpacity: 1,
    ));

    datasets.add(pw.LineDataSet(
      data: [pw.PointChartValue(0, rMax.toDouble()), pw.PointChartValue(n, rMax.toDouble())],
      lineWidth: 1.2, color: _C.verde, drawPoints: false, isCurved: false,
    ));
    datasets.add(pw.LineDataSet(
      data: [pw.PointChartValue(0, rMin.toDouble()), pw.PointChartValue(n, rMin.toDouble())],
      lineWidth: 1.2, color: _C.verde, drawPoints: false, isCurved: false,
    ));
    datasets.add(pw.LineDataSet(
      data: [pw.PointChartValue(0, hiper.toDouble()), pw.PointChartValue(n, hiper.toDouble())],
      lineWidth: 0.8, color: _C.naranja, drawPoints: false, isCurved: false,
    ));
    datasets.add(pw.LineDataSet(
      data: [pw.PointChartValue(0, hipo.toDouble()), pw.PointChartValue(n, hipo.toDouble())],
      lineWidth: 0.8, color: _C.naranja, drawPoints: false, isCurved: false,
    ));

    datasets.add(pw.LineDataSet(
      data: lineaPrincipal,
      lineWidth: 2.0,
      color: _C.azul,
      drawPoints: false,
      isCurved: true,
    ));

    for (int i = 0; i < regsOrdenados.length; i++) {
      final int val = regsOrdenados[i]['valor'] as int;
      final PdfColor pc = _colorSemaforo(val, hipo, hiper, rMin, rMax);
      datasets.add(pw.LineDataSet(
        data: [pw.PointChartValue(i.toDouble(), val.toDouble())],
        lineWidth: 0,
        color: pc,
        drawPoints: true,
        pointSize: 3.5,
        pointColor: pc,
      ));
    }

    final int stepX = math.max(1, regsOrdenados.length ~/ 8);
    final List<double> xTicks = [];
    for (int i = 0; i < regsOrdenados.length; i += stepX) {
      xTicks.add(i.toDouble());
    }

    return pw.Container(
      height: 195,
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: _C.blanco,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _C.gris300, width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(6),
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis(
            xTicks,
            buildLabel: (v) {
              final idx = v.toInt();
              if (idx >= 0 && idx < regsOrdenados.length) {
                return pw.Text(
                  DateFormat('dd/MM').format(regsOrdenados[idx]['fecha'] as DateTime),
                  style: const pw.TextStyle(fontSize: 6, color: _C.gris700),
                );
              }
              return pw.Text('');
            },
            ticks: false,
          ),
          yAxis: pw.FixedAxis(
            [0, hipo.toDouble(), rMin.toDouble(), rMax.toDouble(), hiper.toDouble(), (hiper + 50).toDouble()],
            buildLabel: (v) => pw.Text(
              '${v.toInt()}',
              style: const pw.TextStyle(fontSize: 6.5, color: _C.gris700),
            ),
          ),
        ),
        datasets: datasets,
      ),
    );
  }

  static pw.Widget _distribucion({
    required double pHipo, required double pBajo, required double pNormal,
    required double pElevado, required double pHiper,
    required int cHipo, required int cBajo, required int cNormal,
    required int cElevado, required int cHiper,
    required int hipo, required int hiper, required int rMin, required int rMax,
  }) {
    final filas = [
      _BarRow('Hipoglucemia', '<$hipo mg/dL',              pHipo,    _C.rojo,    cHipo),
      _BarRow('Bajo',         '$hipo-$rMin mg/dL',         pBajo,    _C.naranja, cBajo),
      _BarRow('Normal',       '$rMin-$rMax mg/dL',         pNormal,  _C.verde,   cNormal),
      _BarRow('Elevado',      '${rMax + 1}-$hiper mg/dL',  pElevado, _C.naranja, cElevado),
      _BarRow('Hiperglucemia', '>$hiper mg/dL',            pHiper,   _C.rojo,    cHiper),
    ];

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _C.blanco,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _C.gris300, width: 0.5),
      ),
      child: pw.Column(
        children: filas.map((f) => _barraHoriz(f)).toList(),
      ),
    );
  }

  static pw.Widget _barraHoriz(_BarRow f) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 9),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(children: [
                pw.Container(
                  width: 8, height: 8,
                  decoration: pw.BoxDecoration(
                    color: f.color,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Text(f.label,
                    style: pw.TextStyle(
                      fontSize: 7.5, fontWeight: pw.FontWeight.bold,
                      color: _C.gris900,
                    )),
              ]),
              pw.Text('${f.pct.toStringAsFixed(1)}%  (${f.count})',
                  style: pw.TextStyle(
                    fontSize: 7.5, fontWeight: pw.FontWeight.bold,
                    color: f.color,
                  )),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(f.rango, style: const pw.TextStyle(fontSize: 6.5, color: _C.gris500)),
          pw.SizedBox(height: 3),

          pw.Row(
            children: [
              if (f.pct > 0)
                pw.Expanded(
                  flex: (f.pct * 100).toInt(),
                  child: pw.Container(
                    height: 9,
                    decoration: pw.BoxDecoration(
                      color: f.color,
                      borderRadius: pw.BorderRadius.only(
                        topLeft: const pw.Radius.circular(5),
                        bottomLeft: const pw.Radius.circular(5),
                        topRight: f.pct >= 100 ? const pw.Radius.circular(5) : pw.Radius.zero,
                        bottomRight: f.pct >= 100 ? const pw.Radius.circular(5) : pw.Radius.zero,
                      ),
                    ),
                  ),
                ),
              if (f.pct < 100)
                pw.Expanded(
                  flex: ((100 - f.pct) * 100).toInt() == 0 ? 1 : ((100 - f.pct) * 100).toInt(),
                  child: pw.Container(
                    height: 9,
                    decoration: pw.BoxDecoration(
                      color: _C.gris200,
                      borderRadius: pw.BorderRadius.only(
                        topRight: const pw.Radius.circular(5),
                        bottomRight: const pw.Radius.circular(5),
                        topLeft: f.pct <= 0 ? const pw.Radius.circular(5) : pw.Radius.zero,
                        bottomLeft: f.pct <= 0 ? const pw.Radius.circular(5) : pw.Radius.zero,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _notas(List<Map<String, dynamic>> registros) {
    final conNotas = registros
        .where((r) => (r['notas'] ?? '').toString().isNotEmpty)
        .take(7)
        .toList();

    if (conNotas.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: _C.gris100,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: _C.gris300, width: 0.5),
        ),
        child: pw.Center(
          child: pw.Text('No hay notas clínicas registradas.',
              style: const pw.TextStyle(fontSize: 8, color: _C.gris500)),
        ),
      );
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _C.blanco,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _C.gris300, width: 0.5),
      ),
      child: pw.Column(
        children: conNotas.map((r) {
          final fecha = DateFormat('dd/MM/yy HH:mm').format(r['fecha'] as DateTime);
          final val = r['valor'] as int;
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 4, height: 4,
                  margin: const pw.EdgeInsets.only(top: 3, right: 5),
                  decoration: const pw.BoxDecoration(color: _C.azul, shape: pw.BoxShape.circle),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('$fecha - $val mg/dL',
                          style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: _C.azul)),
                      pw.Text('"${_limpiarTexto(r['notas'])}"',
                          style: const pw.TextStyle(fontSize: 7, color: _C.gris700)),
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

  static pw.Widget _leyenda() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _C.azulClaro,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: _C.azul, width: 0.5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Leyenda:', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: _C.azul)),
          _chipLeyenda('Hipoglucemia', _C.rojo),
          _chipLeyenda('Bajo', _C.naranja),
          _chipLeyenda('Normal / Meta', _C.verde),
          _chipLeyenda('Elevado', _C.naranja),
          _chipLeyenda('Hiperglucemia', _C.rojo),
        ],
      ),
    );
  }

  static pw.Widget _chipLeyenda(String label, PdfColor color) {
    return pw.Row(children: [
      pw.Container(
        width: 10, height: 10,
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        ),
      ),
      pw.SizedBox(width: 4),
      pw.Text(label, style: const pw.TextStyle(fontSize: 7, color: _C.gris900)),
      pw.SizedBox(width: 12),
    ]);
  }

  static pw.Widget _disclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: const pw.BoxDecoration(
        color: _C.gris100,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        'Este informe es una herramienta de apoyo clínico generada automáticamente por InsulApp. '
            'No sustituye el criterio médico profesional ni emite diagnósticos. '
            'Las decisiones terapéuticas deben basarse en la evaluación integral del médico tratante. '
            'Parámetros de referencia basados en las Guías ADA 2024.',
        style: const pw.TextStyle(fontSize: 6.5, color: _C.gris700),
      ),
    );
  }

  static pw.Widget _footer(pw.Context ctx, String fecha) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 6),
      padding: const pw.EdgeInsets.only(top: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: _C.gris300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('InsulApp - Sistema de Monitoreo Glucémico', style: const pw.TextStyle(fontSize: 7, color: _C.gris500)),
          pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 7, color: _C.gris500)),
          pw.Text(fecha, style: const pw.TextStyle(fontSize: 7, color: _C.gris500)),
        ],
      ),
    );
  }
}