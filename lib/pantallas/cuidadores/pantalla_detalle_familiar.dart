import 'package:flutter/material.dart';
import 'tab_glucosa_familiar.dart';
import 'tab_calculadora_familiar.dart';
import 'tab_medicamentos_familiar.dart';
import 'tab_registros_familiar.dart';
import 'tab_identificacion_familiar.dart';

class PantallaDetalleFamiliar extends StatefulWidget {
  final Map<String, dynamic> paciente;

  const PantallaDetalleFamiliar({super.key, required this.paciente});

  @override
  State<PantallaDetalleFamiliar> createState() => _PantallaDetalleFamiliarState();
}

class _PantallaDetalleFamiliarState extends State<PantallaDetalleFamiliar> {
  int _indiceActual = 0;

  void _cambiarTab(int index) {
    setState(() {
      _indiceActual = index;
    });
  }

  BottomNavigationBarItem _crearBottomNavItem(IconData icono, int index, String label) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              icono,
              size: 28,
              color: _indiceActual == index ? Colors.black : const Color(0xFF888888)
          ),
          if (_indiceActual == index)
            Container(
                margin: const EdgeInsets.only(top: 4),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: Color(0xFFD32F2F),
                    shape: BoxShape.circle
                )
            ),
        ],
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _construirCuerpoActual(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _indiceActual,
            onTap: _cambiarTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: const Color(0xFF888888),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              _crearBottomNavItem(Icons.water_drop, 0, 'Glucosa'),
              _crearBottomNavItem(Icons.calculate, 1, 'Dosis'),
              _crearBottomNavItem(Icons.medication, 2, 'Meds'),
              _crearBottomNavItem(Icons.history, 3, 'Registros'),
              _crearBottomNavItem(Icons.badge, 4, 'ID Médica'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCuerpoActual() {
    switch (_indiceActual) {
      case 0:
        return TabGlucosaFamiliar(
            paciente: widget.paciente,
            onCambiarTab: _cambiarTab
        );
      case 1:
        return TabCalculadoraFamiliar(
          paciente: widget.paciente,
        );
      case 2:
        return TabMedicamentosFamiliar(
            paciente: widget.paciente
        );
      case 3:
        return TabRegistrosFamiliar(
            paciente: widget.paciente
        );
      case 4:
        return TabIdentificacionFamiliar(
          familiarId: widget.paciente['id'],
          onActualizarDashboard: () {
            setState(() {});
          },
        );
      default:
        return const Center(child: Text('Vista no encontrada'));
    }
  }
}