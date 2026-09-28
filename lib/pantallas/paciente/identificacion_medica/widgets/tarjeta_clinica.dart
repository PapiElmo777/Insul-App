import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controlador_id_medica.dart';

class TarjetaClinica extends StatelessWidget {
  final ControladorIdMedica controlador;

  const TarjetaClinica({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {

    String strInsulina = 'No usa / No configurado';
    if (controlador.datosCompletos['metodo_insulina'] != 'No usa' && controlador.datosCompletos['metodo_insulina'] != 'No especificado' && controlador.datosCompletos['metodo_insulina'] != null) {
      String metodo = controlador.datosCompletos['metodo_insulina'];
      List<String> lineas = [];
      if (controlador.datosCompletos['insulina_basal_marca'].toString().isNotEmpty) {
        String dosis = controlador.datosCompletos['insulina_basal_dosis'].toString();
        lineas.add('• Basal: ${controlador.datosCompletos['insulina_basal_marca']} ${dosis.isNotEmpty ? '($dosis UI)' : ''}');
      }
      if (controlador.datosCompletos['insulina_rapida_marca'].toString().isNotEmpty) {
        lineas.add('• Rápida: ${controlador.datosCompletos['insulina_rapida_marca']}');
      }
      strInsulina = lineas.isNotEmpty ? '$metodo:\n${lineas.join('\n')}' : metodo;
    }

    String strMeds = 'Ninguno registrado';
    if (controlador.medicamentos.isNotEmpty) {
      strMeds = controlador.medicamentos.map((m) => '• ${m['nombre']} (${m['gramaje']})').join('\n');
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF1C63BB),
          expandedHeight: 140.0,
          floating: true, snap: true, pinned: true, automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ID Médica', style: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.medical_information, color: Colors.white, size: 28)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text('Resumen clínico en caso de emergencia.', style: TextStyle(color: Color(0xFFE8E8E8), fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ──ENCABEZADO DE LA CREDENCIAL ──
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF1C63BB), width: 2), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(color: Color(0xFF1C63BB), borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.person, color: Color(0xFF1C63BB), size: 30)),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(controlador.datosCompletos['nombre_completo'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text('${controlador.datosCompletos['edad']} años  |  Sexo: ${controlador.datosCompletos['sexo']}', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ID Expediente', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                Text('#PAC-00${controlador.pacienteId ?? 'X'}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Fecha de Reporte', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                Text(DateFormat('dd/MM/yyyy').format(DateTime.now()), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ──INFORMACION CRITICA ──
                _construirSeccion(
                  titulo: 'Información Crítica',
                  icono: Icons.warning_rounded,
                  colorIcono: const Color(0xFFD32F2F),
                  contenido: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _filaInfo(Icons.medical_services, 'Diagnóstico', controlador.datosCompletos['tipo_diabetes'], color: const Color(0xFF1C63BB))),
                          Expanded(child: _filaInfo(Icons.water_drop, 'Tipo Sanguíneo', controlador.datosCompletos['tipo_sanguineo'], color: const Color(0xFFD32F2F), negrita: true)),
                        ],
                      ),
                      _filaInfo(Icons.colorize, 'Esquema de Insulina', strInsulina),
                      _filaInfo(Icons.medication, 'Fármacos Orales', strMeds),
                      _filaInfo(Icons.coronavirus, 'Enfermedades Crónicas', controlador.datosCompletos['enfermedades_cronicas']),
                      _filaInfo(Icons.no_meals, 'Alergias', controlador.datosCompletos['alergias'], color: const Color(0xFFD32F2F), negrita: true),
                      const Divider(height: 25),
                      _filaInfo(Icons.contact_emergency, 'Contacto de Emergencia', '${controlador.datosCompletos['emergencia_nombre']} \n📞 ${controlador.datosCompletos['emergencia_telefono']}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ──RESUMEN GLUCEMICO ──
                _construirSeccion(
                  titulo: 'Resumen Glucémico',
                  icono: Icons.pie_chart,
                  colorIcono: const Color(0xFF2E7D32),
                  contenido: Column(
                    children: [
                      Row(
                        children: [
                          _bloqueMetrica('Promedio', '${controlador.promedio}', 'mg/dL', const Color(0xFF1C63BB)),
                          const SizedBox(width: 10),
                          _bloqueMetrica('En Rango', '${controlador.tir}%', 'TIR Meta', const Color(0xFF2E7D32)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _minimetro('Hipo (<70)', '${controlador.pctHipo}%', const Color(0xFFD32F2F)),
                          _minimetro('Hiper (>180)', '${controlador.pctHiper}%', const Color(0xFFE65100)),
                          _minimetro('Mínima', '${controlador.minG}', const Color(0xFFD32F2F)),
                          _minimetro('Máxima', '${controlador.maxG}', const Color(0xFFE65100)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ──EVENTOS CLINICOS ──
                _construirSeccion(
                  titulo: 'Eventos Clínicos',
                  icono: Icons.local_hospital,
                  colorIcono: const Color(0xFF008CCF),
                  contenido: Column(
                    children: [
                      _filaInfo(Icons.hotel, 'Hospitalizaciones Recientes', controlador.datosCompletos['hospitalizaciones']),
                      _filaInfo(Icons.content_cut, 'Cirugías Previas', controlador.datosCompletos['cirugias']),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ──CONTACTO Y SEGUIMIENTO ──
                _construirSeccion(
                  titulo: 'Seguimiento Médico',
                  icono: Icons.business,
                  colorIcono: Colors.black87,
                  contenido: Column(
                    children: [
                      _filaInfo(Icons.person_pin, 'Médico Responsable', controlador.datosCompletos['medico_nombre']),
                      _filaInfo(Icons.local_hospital_rounded, 'Clínica / Institución', controlador.datosCompletos['clinica']),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () => controlador.generarPDFIdentificacion(context),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text('Descargar PDF de ID Médica', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      controlador.setIdentificacionCompletada(false);
                    },
                    icon: const Icon(Icons.edit, color: Color(0xFF1C63BB)),
                    label: const Text('Editar Información', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1C63BB), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirSeccion({required String titulo, required IconData icono, required Color colorIcono, required Widget contenido}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: colorIcono, size: 24),
              const SizedBox(width: 10),
              Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 20),
          contenido,
        ],
      ),
    );
  }

  Widget _filaInfo(IconData icono, String titulo, String valor, {Color color = Colors.black87, bool negrita = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(valor, style: TextStyle(fontSize: 14, color: color, fontWeight: negrita ? FontWeight.bold : FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bloqueMetrica(String titulo, String valor, String subtitulo, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(
          children: [
            Text(titulo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(valor, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color, height: 1)),
            Text(subtitulo, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _minimetro(String titulo, String valor, Color color) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(valor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
