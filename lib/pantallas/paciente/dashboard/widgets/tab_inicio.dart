import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controlador_dashboard_paciente.dart';
import '../../../../widgets/universales/tarjetas_tir_promedio.dart';
import '../../../../widgets/universales/dialogo_tir.dart';

class TabInicio extends StatelessWidget {
  final ControladorDashboardPaciente controlador;
  final Function(int) onNavegar;

  const TabInicio({
    super.key,
    required this.controlador,
    required this.onNavegar,
  });

  @override
  Widget build(BuildContext context) {
    final ultimaG = controlador.obtenerUltimaGlucosa();
    final estadoG = controlador.obtenerEstadoGlucosa(ultimaG);

    Color colorFondo;
    Color colorTexto = Colors.white;
    Color colorBorde;

    if (estadoG == 'Hipoglucemia' || estadoG == 'Hiperglucemia') {
      colorFondo = const Color(0xFFFFEBEE);
      colorTexto = const Color(0xFFD32F2F);
      colorBorde = const Color(0xFFD32F2F);
    } else if (estadoG == 'Bajo' || estadoG == 'Elevado') {
      colorFondo = const Color(0xFFFFF3E0);
      colorTexto = const Color(0xFFE65100);
      colorBorde = const Color(0xFFE65100);
    } else {
      colorFondo = const Color(0xFFE8F5E9);
      colorTexto = const Color(0xFF2E7D32);
      colorBorde = const Color(0xFF2E7D32);
    }

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFF1C63BB),
            expandedHeight: 140.0,
            floating: true,
            snap: true,
            pinned: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${controlador.obtenerSaludo()},\n${controlador.datosPacienteComp['nombre'] ?? controlador.nombrePacienteInicial}',
                              style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 26, color: Colors.white, height: 1.2),
                            ),
                            const SizedBox(height: 8),
                            Text(controlador.fechaFormateada, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFFE8E8E8))),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          onNavegar(6);
                        },
                        child: Container(
                          width: 55, height: 55,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2), border: Border.all(color: Colors.white, width: 2)),
                          child: controlador.imagenPerfil != null
                              ? ClipOval(child: Image.file(controlador.imagenPerfil!, fit: BoxFit.cover, width: 55, height: 55))
                              : const Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ];
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD2D2D2), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Última Lectura',
                        style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF3F3F3F)),
                      ),
                      Icon(Icons.show_chart_rounded, color: Colors.grey.shade500, size: 24),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        controlador.registrosGlucosa.isEmpty ? '--' : ultimaG.toString(),
                        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 52, height: 1.0, color: Color(0xFF01689C)),
                      ),
                      const SizedBox(width: 6),
                      const Text('mg/dL', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 20, color: Color(0xFF848282))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (controlador.registrosGlucosa.isNotEmpty)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: colorFondo, border: Border.all(color: colorBorde, width: 1.5), borderRadius: BorderRadius.circular(20)),
                          child: Text(estadoG, style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 11, color: colorTexto)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF888888), width: 1.5), borderRadius: BorderRadius.circular(20)),
                          child: Text(controlador.obtenerMomentoUltimaLectura(), style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF888888))),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(controlador.obtenerTiempoUltimaLectura(), style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFFC5C5C5))),
                      GestureDetector(
                        onTap: () {
                          onNavegar(1);
                        },
                        child: const Text('Ver todos registros', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF888888), decoration: TextDecoration.underline)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            _construirLeyendaColores(),
            const SizedBox(height: 5),

            TarjetasTirPromedio(
              porcentajeTir: controlador.calcularTIR(),
              promedio: controlador.calcularPromedioGlucosa(),
              tieneRegistros: controlador.registrosGlucosa.isNotEmpty,
              onVerTir: () => _mostrarDialogoTIR(context),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Acciones Rápidas', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 24, color: Color(0xFF2F2F2F))),
                  const SizedBox(height: 15),
                  const Divider(color: Color(0xFFE8E8E8), thickness: 1.5, height: 1),
                  _crearAccionRapida(Icons.edit_document, 'Registrar Lectura de Glucosa', () {
                    _mostrarFormularioNuevaMedida(context);
                  }),
                  _crearAccionRapida(Icons.medication, 'Registrar Medicamento', () {
                    onNavegar(4);
                  }),
                  _crearAccionRapida(Icons.calculate, 'Calcular Dosis de Insulina', () {
                    onNavegar(2);
                  }),
                  const Divider(color: Color(0xFFE8E8E8), thickness: 1.5, height: 1),
                  _crearAccionRapida(Icons.timeline, 'Ver Historial Completo', () {
                    onNavegar(1);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Información importante', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2F2F2F))),
                  const SizedBox(height: 15),
                  _crearVinietaInfo('Esta aplicación es una herramienta de apoyo, no reemplaza la consulta médica'),
                  const SizedBox(height: 10),
                  _crearVinietaInfo('Consulta con tu médico para establecer tu rango objetivo personalizado'),
                  const SizedBox(height: 10),
                  _crearVinietaInfo('Mantén tu información actualizada para obtener mejores resultados.'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _construirLeyendaColores() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _itemLeyenda(const Color(0xFFD32F2F), 'Hipo'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFE65100), 'Bajo'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFF2E7D32), 'Normal'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFE65100), 'Elevado'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFD32F2F), 'Hiper'),
          ],
        ),
      ),
    );
  }

  Widget _itemLeyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(texto, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _crearAccionRapida(IconData icono, String texto, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            Icon(icono, color: const Color(0xFF1C63BB), size: 26),
            const SizedBox(width: 15),
            Expanded(child: Text(texto, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF2F2F2F)))),
          ],
        ),
      ),
    );
  }

  Widget _crearVinietaInfo(String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0, right: 8.0),
          child: Icon(Icons.circle, size: 6, color: Color(0xFF2F2F2F)),
        ),
        Expanded(child: Text(texto, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F), height: 1.4))),
      ],
    );
  }

  void _mostrarFormularioNuevaMedida(BuildContext context) {
    final TextEditingController valorCtrl = TextEditingController();
    final TextEditingController notasCtrl = TextEditingController();
    String momentoSeleccionado = 'Antes de comer';
    DateTime fechaSeleccionada = DateTime.now();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bottomSheetContext) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateSheet) {
                return Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 20, right: 20, top: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                        const SizedBox(height: 20),
                        const Text('Nueva Medición', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 22)),
                        const SizedBox(height: 25),

                        const Align(alignment: Alignment.centerLeft, child: Text('Nivel de Glucosa (mg/dL) *', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 5),
                        TextField(
                          controller: valorCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'ej. 120',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Align(alignment: Alignment.centerLeft, child: Text('Periodo:', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: momentoSeleccionado,
                              isExpanded: true,
                              items: ['Ayunas', 'Antes de comer', 'Después de comer', 'Antes de dormir', 'Madrugada', 'Otro']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) => setStateSheet(() => momentoSeleccionado = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Align(alignment: Alignment.centerLeft, child: Text('Notas: (opcional)', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 5),
                        TextField(
                          controller: notasCtrl,
                          decoration: InputDecoration(
                            hintText: 'Ej. Me siento mareado, comí pastel...',
                            hintStyle: const TextStyle(fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (valorCtrl.text.isNotEmpty) {
                                int valor = int.tryParse(valorCtrl.text) ?? 0;
                                if (valor < 20 || valor > 600) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Por favor, ingresa un valor de glucosa realista (20 - 600 mg/dL)', style: TextStyle(fontWeight: FontWeight.bold)),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      )
                                  );
                                  return;
                                }

                                await controlador.guardarNuevaMedida(valor, momentoSeleccionado, notasCtrl.text, fechaSeleccionada);
                                if (context.mounted) {
                                  Navigator.of(context, rootNavigator: true).pop();
                                }
                              }
                            },
                            icon: const Icon(Icons.save_alt, color: Colors.white),
                            label: const Text('Guardar Nueva Lectura', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C80EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  void _mostrarDialogoTIR(BuildContext context) {
    mostrarDialogoTIRUniversal(
      context,
      registros: controlador.registrosGlucosa,
      limiteHipo: controlador.limiteHipo,
      limiteHiper: controlador.limiteHiper,
      rangoMin: controlador.rangoMin,
      rangoMax: controlador.rangoMax,
    );
  }
}
