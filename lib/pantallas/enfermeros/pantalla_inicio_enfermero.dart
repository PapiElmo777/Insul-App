import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:typed_data';

import 'controlador_dashboard_enfermero.dart';
import 'tabs/tab_inicio_enfermero.dart';
import 'tabs/tab_directorio_pacientes.dart';
import 'tabs/tab_reportes_enfermero.dart';
import 'tabs/tab_perfil_enfermero.dart';
import 'pantalla_alarmas_enfermero.dart';

class PantallaInicioEnfermero extends StatefulWidget {
  final String nombreEnfermero;

  const PantallaInicioEnfermero({
    super.key,
    this.nombreEnfermero = 'Enfermero',
  });

  @override
  State<PantallaInicioEnfermero> createState() => _PantallaInicioEnfermeroState();
}

class _PantallaInicioEnfermeroState extends State<PantallaInicioEnfermero> {
  late ControladorDashboardEnfermero _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorDashboardEnfermero(nombreInicial: widget.nombreEnfermero);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) {
        if (_controlador.cargandoDatos || _controlador.enfermeroId == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB))),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: _construirTabActual(),
          ),
          bottomNavigationBar: _construirBottomNavigation(),
        );
      },
    );
  }

  Widget _construirTabActual() {
    switch (_controlador.indiceNavegacionActual) {
      case 0:
        return TabInicioEnfermero(controlador: _controlador);
      case 1:
        return TabDirectorioPacientes(controlador: _controlador);
      case 2:
        return PantallaAlarmasEnfermero(enfermeroId: _controlador.enfermeroId!);
      case 3:
        return TabReportesEnfermero(controlador: _controlador);
      case 4:
        return TabPerfilEnfermero(controlador: _controlador);
      default:
        return const Center(child: Text("Error de navegación"));
    }
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
          currentIndex: _controlador.indiceNavegacionActual,
          onTap: (index) {
            _controlador.cambiarTab(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF888888),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            _crearBottomNavItem(Icons.home_outlined, 0, 'Home'),
            _crearBottomNavItem(Icons.bar_chart, 1, 'Pacientes'),
            _crearBottomNavItem(Icons.notifications_active_outlined, 2, 'Alarmas'),
            _crearBottomNavItem(Icons.access_time, 3, 'Historial'),
            _crearBottomNavItem(Icons.person_outline, 4, 'Perfil'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _crearBottomNavItem(IconData icono, int index, String label) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 28, color: _controlador.indiceNavegacionActual == index ? Colors.black : const Color(0xFF888888)),
          if (_controlador.indiceNavegacionActual == index)
            Container(margin: const EdgeInsets.only(top: 4), width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle)),
        ],
      ),
      label: label,
    );
  }
}

class VisorPdfPantalla extends StatelessWidget {
  final Uint8List bytes;
  final String turno;
  final String reporteId;

  const VisorPdfPantalla({
    super.key,
    required this.bytes,
    required this.turno,
    required this.reporteId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C63BB),
        title: Text('Reporte de Turno $turno', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PdfPreview(
        key: Key(reporteId),
        build: (format) async => bytes,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: 'Reporte_Turno_${turno}_$reporteId.pdf',
      ),
    );
  }
}