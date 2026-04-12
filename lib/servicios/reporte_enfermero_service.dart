import 'package:flutter/cupertino.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
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

class ReportePdfService {
  static Future<Uint8List> generarReporteTurno({
    required List<Map<String, dynamic>> pacientes,
    required DatosEnfermero enfermero,
    required String turno,
  }) async {
    final pdf = pw.Document();
    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    pw.ImageProvider? logoImage;
    try {
      final ByteData logoData = await rootBundle.load('assets/logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      logoImage = pw.MemoryImage(logoBytes);
    } catch (e) {
      debugPrint('No se pudo cargar el logo para el PDF: $e');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue900, width: 2),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('REPORTE CLÍNICO DE TURNO',
                        style: pw.TextStyle(
                          fontSize: 22,
                          color: PdfColors.blue900,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.Row(
                      children: [
                        if (logoImage != null) pw.Image(logoImage, width: 24, height: 24),
                        if (logoImage != null) pw.SizedBox(width: 8),
                        pw.RichText(
                          text: pw.TextSpan(
                            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 16),
                            children: [
                              pw.TextSpan(text: 'Insul ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              const pw.TextSpan(text: 'App'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Divider(color: PdfColors.blue900, thickness: 1.5),
                pw.SizedBox(height: 8),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Hospital: ${enfermero.hospital}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Área: ${enfermero.area}'),
                        pw.Text('Turno: $turno'),
                      ],
                    ),
                    pw.SizedBox(width: 40),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Responsable: ${enfermero.nombre}'),
                        pw.Text('Cédula: ${enfermero.cedula}'),
                        pw.Text('Emisión: $fecha'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 25),

          if (pacientes.isEmpty)
            pw.Center(child: pw.Text('No se registraron pacientes en este turno.'))
          else
            ...pacientes.map((p) => _pacienteBlock(p)),
          pw.SizedBox(height: 40),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                children: [
                  pw.Container(width: 200, height: 1, color: PdfColors.black),
                  pw.SizedBox(height: 5),
                  pw.Text('Firma del Profesional de Enfermería', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Enf. ${enfermero.nombre}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              )
            ],
          )
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pacienteBlock(Map<String, dynamic> paciente) {
    final historial = List<Map<String, dynamic>>.from(paciente['historialGlucosa'] ?? []);
    final historialInsulina = List<Map<String, dynamic>>.from(paciente['historialInsulina'] ?? []);
    final medicamentos = List<Map<String, dynamic>>.from(paciente['medicamentos'] ?? []);
    final observaciones = List<String>.from(paciente['observacionesTurno'] ?? []);

    double promedio = 0;
    if (historial.isNotEmpty) {
      promedio = historial.map((e) => e['valor'] as int).reduce((a, b) => a + b) / historial.length;
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('PACIENTE: ${paciente['nombre'] ?? 'Sin nombre'}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blueGrey900)),
              pw.Text('EXP: ${paciente['expediente'] ?? '--'}', style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text('Ubicación: ${paciente['ubicacion'] ?? '--'} | Edad: ${paciente['edad'] ?? '--'} | Dieta: ${paciente['dieta'] ?? '--'}'),
          pw.SizedBox(height: 10),

          pw.Row(
            children: [
              pw.Expanded(child: pw.Text('Glucosa Promedio: ${promedio.toStringAsFixed(1)} mg/dL')),
              pw.Expanded(child: pw.Text('Tipo Diabetes: ${paciente['tipoDiabetes'] ?? '--'}')),
            ],
          ),
          pw.SizedBox(height: 8),

          if (historial.isNotEmpty) ...[
            pw.Text('Registros de Glucosa:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey200),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headers: ['Fecha y Hora', 'Valor (mg/dL)'],
              data: historial.map((g) {
                String fechaFormateada = '--';
                if (g['fecha'] is DateTime) {
                  fechaFormateada = DateFormat('dd/MM HH:mm').format(g['fecha']);
                } else if (g['fecha'] != null) {
                  fechaFormateada = g['fecha'].toString();
                }
                return [fechaFormateada, '${g['valor'] ?? '--'}'];
              }).toList(),
            ),
            pw.SizedBox(height: 8),
          ],

          if (medicamentos.isNotEmpty) ...[
            pw.Text('Medicamentos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ...medicamentos.map((m) => pw.Text('- ${m['nombre']} | ${m['dosis']} | ${m['frecuencia']}', style: const pw.TextStyle(fontSize: 8))),
            pw.SizedBox(height: 8),
          ],

          if (historialInsulina.isNotEmpty) ...[
            pw.Text('Insulina Suministrada:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ...historialInsulina.map((i) {
              String fechaFormateada = '--';
              if (i['fecha'] is DateTime) {
                fechaFormateada = DateFormat('dd/MM HH:mm').format(i['fecha']);
              } else if (i['fecha'] != null) {
                fechaFormateada = i['fecha'].toString();
              }
              return pw.Text('- ${i['unidades']} UI - $fechaFormateada', style: const pw.TextStyle(fontSize: 8));
            }),
            pw.SizedBox(height: 8),
          ],

          if (observaciones.isNotEmpty) ...[
            pw.Text('Observaciones del Turno:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ...observaciones.map((obs) => pw.Text('- $obs', style: const pw.TextStyle(fontSize: 8))),
          ]
        ],
      ),
    );
  }
}