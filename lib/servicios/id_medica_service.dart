import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class IdentificacionMedicaService {
  static Future<Uint8List> generarPDF({
    required Map<String, dynamic> datos,
    required List<Map<String, dynamic>> medicamentos,
    required int promedio,
    required int tir,
    required int pctHipo,
    required int pctHiper,
    required int minG,
    required int maxG,
  }) async {

    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
      ),
    );

    String strInsulina = 'No usa insulina';
    if (datos['metodo_insulina'] != 'No usa' && datos['metodo_insulina'] != 'No especificado' && datos['metodo_insulina'] != null) {
      String metodo = datos['metodo_insulina'];
      List<String> lineas = [];
      if (datos['insulina_basal_marca'].toString().isNotEmpty) {
        String dosis = datos['insulina_basal_dosis'].toString();
        lineas.add('• Basal: ${datos['insulina_basal_marca']} ${dosis.isNotEmpty ? '($dosis UI)' : ''}');
      }
      if (datos['insulina_rapida_marca'].toString().isNotEmpty) {
        lineas.add('• Rápida: ${datos['insulina_rapida_marca']}');
      }
      strInsulina = '$metodo\n${lineas.join('\n')}';
    }

    String strMeds = 'Ningún medicamento registrado';
    if (medicamentos.isNotEmpty) {
      strMeds = medicamentos.map((m) => '• ${m['nombre']} (${m['gramaje']})').join('\n');
    }

    final cAzul = PdfColor.fromInt(0xFF1C63BB);
    final cAzulOscuro = PdfColor.fromInt(0xFF0D3F7A);
    final cCian = PdfColor.fromInt(0xFF00D1FF);
    final cBlanco = PdfColors.white;
    final cGris100 = PdfColor.fromInt(0xFFF5F5F5);
    final cGris300 = PdfColor.fromInt(0xFFE0E0E0);
    final cGris500 = PdfColor.fromInt(0xFF9E9E9E);
    final cGris700 = PdfColor.fromInt(0xFF616161);
    final cRojo = PdfColor.fromInt(0xFFD32F2F);

    // Intentar cargar logo
    pw.Widget? logoWidget;
    try {
      String svgData = await rootBundle.loadString('assets/logo1.svg');
      svgData = svgData.replaceAll(RegExp(r'fill="[^"]*"'), 'fill="#1C63BB"');
      svgData = svgData.replaceAll(RegExp(r'stroke="[^"]*"'), 'stroke="#1C63BB"');
      if (!svgData.contains('fill="#1C63BB"')) {
        svgData = svgData.replaceFirst('<svg', '<svg fill="#1C63BB"');
      }
      logoWidget = pw.SvgImage(svg: svgData, width: 35, height: 35);
    } catch (_) {}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 34),
        footer: (ctx) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 6),
          padding: const pw.EdgeInsets.only(top: 5),
          decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: cGris300, width: 0.5))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('InsulApp - Identificación Médica Oficial', style: pw.TextStyle(fontSize: 7, color: cGris500)),
              pw.Text('Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: pw.TextStyle(fontSize: 7, color: cGris500)),
            ],
          ),
        ),
        build: (pw.Context context) {
          return [
            pw.Container(
              decoration: pw.BoxDecoration(
                color: cAzul,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
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
                            decoration: pw.BoxDecoration(color: cBlanco, shape: pw.BoxShape.circle),
                            padding: const pw.EdgeInsets.all(5),
                            child: logoWidget,
                          ),
                        pw.SizedBox(width: 10),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Insul App', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: cBlanco)),
                            pw.Text('Monitoreo, cuidado y salud en tus manos', style: pw.TextStyle(fontSize: 8, color: cCian)),
                          ],
                        ),
                      ]),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('ID MÉDICA', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: cBlanco)),
                          pw.Text('Información para Emergencias', style: pw.TextStyle(fontSize: 8, color: cCian)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: cAzulOscuro,
                    borderRadius: const pw.BorderRadius.only(bottomLeft: pw.Radius.circular(10), bottomRight: pw.Radius.circular(10)),
                  ),
                  padding: const pw.EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(datos['nombre_completo'], style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: cBlanco)),
                          pw.SizedBox(height: 3),
                          pw.Text('Edad: ${datos['edad']} años  |  Sexo: ${datos['sexo']}  |  Sangre: ${datos['tipo_sanguineo']}', style: pw.TextStyle(fontSize: 8, color: cGris300)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Avisar a:', style: pw.TextStyle(fontSize: 8, color: cGris500)),
                          pw.Text('${datos['emergencia_nombre']}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: cCian)),
                          pw.SizedBox(height: 2),
                          pw.Text('Tel: ${datos['emergencia_telefono']}', style: pw.TextStyle(fontSize: 9, color: cBlanco)),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            pw.SizedBox(height: 15),

            // INFO CRITICA
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(color: cAzul, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
              child: pw.Text('INFORMACIÓN CLÍNICA CRÍTICA', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: cBlanco, letterSpacing: 0.5)),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(color: cGris100, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)), border: pw.Border.all(color: cGris300, width: 0.5)),
                child: pw.Column(children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(width: 100, child: pw.Text('Diagnóstico Principal:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cGris700))),
                            pw.Expanded(child: pw.Text(datos['tipo_diabetes'], style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cAzul))),
                          ]
                      )
                  ),
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(width: 100, child: pw.Text('Alergias:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cGris700))),
                            pw.Expanded(child: pw.Text(datos['alergias'], style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cRojo))),
                          ]
                      )
                  ),
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(width: 100, child: pw.Text('Enfermedades Crónicas:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cGris700))),
                            pw.Expanded(child: pw.Text(datos['enfermedades_cronicas'], style: const pw.TextStyle(fontSize: 9))),
                          ]
                      )
                  ),
                ])
            ),
            pw.SizedBox(height: 15),

            // TRATAMIENTO E HISTORIAL
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: double.infinity, padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: pw.BoxDecoration(color: cAzul, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                              child: pw.Text('ESQUEMA DE TRATAMIENTO', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: cBlanco, letterSpacing: 0.5)),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text('Uso de Insulina:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cAzul)),
                            pw.SizedBox(height: 4),
                            pw.Text(strInsulina, style: const pw.TextStyle(fontSize: 8, lineSpacing: 1.5)),
                            pw.SizedBox(height: 12),
                            pw.Text('Medicamentos Orales:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cAzul)),
                            pw.SizedBox(height: 4),
                            pw.Text(strMeds, style: const pw.TextStyle(fontSize: 8, lineSpacing: 1.5)),
                          ]
                      )
                  ),
                  pw.SizedBox(width: 15),
                  pw.Expanded(
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: double.infinity, padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: pw.BoxDecoration(color: cAzul, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                              child: pw.Text('EVENTOS CLÍNICOS', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: cBlanco, letterSpacing: 0.5)),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text('Hospitalizaciones Recientes:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cAzul)),
                            pw.SizedBox(height: 4),
                            pw.Text(datos['hospitalizaciones'], style: const pw.TextStyle(fontSize: 8)),
                            pw.SizedBox(height: 12),
                            pw.Text('Cirugías Previas:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cAzul)),
                            pw.SizedBox(height: 4),
                            pw.Text(datos['cirugias'], style: const pw.TextStyle(fontSize: 8)),
                          ]
                      )
                  )
                ]
            ),
            pw.SizedBox(height: 15),

            // RESUMEN Y MEDICO
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: double.infinity, padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: pw.BoxDecoration(color: cAzul, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                              child: pw.Text('RESUMEN GLUCÉMICO HISTÓRICO', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: cBlanco, letterSpacing: 0.5)),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Container(
                                padding: const pw.EdgeInsets.all(10),
                                decoration: pw.BoxDecoration(borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)), border: pw.Border.all(color: cGris300, width: 0.5)),
                                child: pw.Column(
                                    children: [
                                      pw.Row(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Container(width: 80, child: pw.Text('Promedio:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cGris700))),
                                            pw.Expanded(child: pw.Text('$promedio mg/dL', style: const pw.TextStyle(fontSize: 9))),
                                          ]
                                      ),
                                      pw.SizedBox(height: 4),
                                      pw.Row(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Container(width: 80, child: pw.Text('Tiempo Rango:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cGris700))),
                                            pw.Expanded(child: pw.Text('$tir%', style: const pw.TextStyle(fontSize: 9))),
                                          ]
                                      ),
                                      pw.SizedBox(height: 4),
                                      pw.Row(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Container(width: 80, child: pw.Text('Hipo/Hiper:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cGris700))),
                                            pw.Expanded(child: pw.Text('$pctHipo% / $pctHiper%', style: const pw.TextStyle(fontSize: 9))),
                                          ]
                                      ),
                                    ]
                                )
                            )
                          ]
                      )
                  ),
                  pw.SizedBox(width: 15),
                  pw.Expanded(
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: double.infinity, padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: pw.BoxDecoration(color: cAzul, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                              child: pw.Text('SEGUIMIENTO MÉDICO', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: cBlanco, letterSpacing: 0.5)),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Container(
                                padding: const pw.EdgeInsets.all(10),
                                decoration: pw.BoxDecoration(borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)), border: pw.Border.all(color: cGris300, width: 0.5)),
                                child: pw.Column(
                                    children: [
                                      pw.Row(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Container(width: 50, child: pw.Text('Médico:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cGris700))),
                                            pw.Expanded(child: pw.Text(datos['medico_nombre'], style: const pw.TextStyle(fontSize: 9))),
                                          ]
                                      ),
                                      pw.SizedBox(height: 4),
                                      pw.Row(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Container(width: 50, child: pw.Text('Clínica:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: cGris700))),
                                            pw.Expanded(child: pw.Text(datos['clinica'], style: const pw.TextStyle(fontSize: 9))),
                                          ]
                                      ),
                                    ]
                                )
                            )
                          ]
                      )
                  )
                ]
            )
          ];
        },
      ),
    );

    return await pdf.save();
  }
}