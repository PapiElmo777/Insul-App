import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dashboard/controlador_dashboard_paciente.dart';
import 'dashboard/widgets/tab_inicio.dart';
import 'dashboard/widgets/tab_historial.dart';
import 'pantalla_registros_paciente.dart';
import 'pantalla_perfil_paciente.dart';
import 'pantalla_medicamentos_paciente.dart';
import 'pantalla_calculadora_dosis.dart';
import 'identificacion_medica/pantalla_identificacion_medica.dart';

class PantallaInicioPaciente extends StatefulWidget {
  final String nombrePaciente;
  final int indiceInicial;

  const PantallaInicioPaciente({
    super.key,
    this.nombrePaciente = 'Paciente',
    this.indiceInicial = 0,
  });

  @override
  State<PantallaInicioPaciente> createState() => _PantallaInicioPacienteState();
}

class _PantallaInicioPacienteState extends State<PantallaInicioPaciente> {
  late ControladorDashboardPaciente _controlador;
  late int _indiceNavegacionActual;
  int _refreshKeyMedicamentos = 0;

  @override
  void initState() {
    super.initState();
    _indiceNavegacionActual = widget.indiceInicial;
    _controlador = ControladorDashboardPaciente(nombrePacienteInicial: widget.nombrePaciente);
    _controlador.addListener(_onControladorActualizado);
  }

  @override
  void dispose() {
    _controlador.removeListener(_onControladorActualizado);
    _controlador.dispose();
    super.dispose();
  }

  void _onControladorActualizado() {
    setState(() {
      _refreshKeyMedicamentos++;
    });
  }

  void _navegarA(int index) {
    setState(() {
      _indiceNavegacionActual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controlador,
      builder: (context, child) {
        if (_controlador.cargandoDatos) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7FA),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB))),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: IndexedStack(
            index: _indiceNavegacionActual,
            children: [
              TabInicio(
                controlador: _controlador,
                onNavegar: _navegarA,
              ),
              SafeArea(
                child: PantallaRegistrosPaciente(
                  registros: _controlador.registrosGlucosa,
                  limiteHipo: _controlador.limiteHipo,
                  limiteHiper: _controlador.limiteHiper,
                  rangoMin: _controlador.rangoMin,
                  rangoMax: _controlador.rangoMax,
                  onAgregarRegistro: (nuevoRegistro) async {
                    await _controlador.guardarNuevaMedida(
                      nuevoRegistro['valor'],
                      nuevoRegistro['momento'],
                      nuevoRegistro['notas'],
                      nuevoRegistro['fecha'] as DateTime,
                    );
                  },
                ),
              ),
              PantallaCalculadoraDosis(onRegistroGuardado: _controlador.cargarDatosBD),
              TabHistorial(controlador: _controlador),
              SafeArea(
                key: ValueKey('meds_$_refreshKeyMedicamentos'),
                child: const PantallaMedicamentosPaciente(),
              ),
              SafeArea(
                child: PantallaIdentificacionMedica(onActualizarDashboard: _controlador.cargarDatosBD),
              ),
              SafeArea(
                child: TabPerfilPaciente(
                  nombrePaciente: widget.nombrePaciente,
                  onActualizarDashboard: _controlador.cargarDatosBD,
                ),
              ),
            ],
          ),
          bottomNavigationBar: _construirBottomNavigation(),
        );
      },
    );
  }

  Widget _construirBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        child: BottomNavigationBar(
          currentIndex: _indiceNavegacionActual,
          onTap: _navegarA,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2F2F2F),
          unselectedItemColor: const Color(0xFF888888),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_filled, size: 28, color: _indiceNavegacionActual == 0 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)),
                  if (_indiceNavegacionActual == 0) _puntoRojo(),
                ],
              ),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart_rounded, size: 28, color: _indiceNavegacionActual == 1 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)),
                  if (_indiceNavegacionActual == 1) _puntoRojo(),
                ],
              ),
              label: 'Estadísticas',
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calculate, size: 28, color: _indiceNavegacionActual == 2 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)),
                  if (_indiceNavegacionActual == 2) _puntoRojo(),
                ],
              ),
              label: 'Cálculo',
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf_sharp, size: 28, color: _indiceNavegacionActual == 3 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)),
                  if (_indiceNavegacionActual == 3) _puntoRojo(),
                ],
              ),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.medication, size: 28, color: _indiceNavegacionActual == 4 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)),
                  if (_indiceNavegacionActual == 4) _puntoRojo(),
                ],
              ),
              label: 'Medicamentos',
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.badge, size: 28, color: _indiceNavegacionActual == 5 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)),
                  if (_indiceNavegacionActual == 5) _puntoRojo(),
                ],
              ),
              label: 'ID Médica',
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 28, color: _indiceNavegacionActual == 6 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)),
                  if (_indiceNavegacionActual == 6) _puntoRojo(),
                ],
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _puntoRojo() {
    return Container(margin: const EdgeInsets.only(top: 4), width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFFFF4A4A), shape: BoxShape.circle));
  }
}

class VisorAGPPantalla extends StatelessWidget {
  final Uint8List bytes;

  const VisorAGPPantalla({
    super.key,
    required this.bytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C63BB),
        title: const Text('Informe AGP Generado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PdfPreview(
        build: (format) async => bytes,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: 'Reporte_AGP_InsulApp.pdf',
      ),
    );
  }
}
