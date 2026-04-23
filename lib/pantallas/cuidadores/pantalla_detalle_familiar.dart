import 'package:flutter/material.dart';
import 'tab_glucosa_familiar.dart';
import 'tab_medicamentos_familiar.dart';

class PantallaDetalleFamiliar extends StatefulWidget {
  final Map<String, dynamic> paciente;

  const PantallaDetalleFamiliar({super.key, required this.paciente});

  @override
  State<PantallaDetalleFamiliar> createState() => _PantallaDetalleFamiliarState();
}

class _PantallaDetalleFamiliarState extends State<PantallaDetalleFamiliar> {
  int _indiceActual = 0;
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
      body: Column(
        children: [
          _construirHeaderFamiliar(),
          Expanded(
            child: _construirCuerpoActual(),
          )
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _indiceActual,
            onTap: (index) => setState(() => _indiceActual = index),
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

  Widget _construirHeaderFamiliar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 15, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        color: Color(0xFF1C63BB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Perfil de ${widget.paciente['nombre']}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Datos físicos
                Text(
                  'Edad: ${widget.paciente['edad']} años | Estatura: ${widget.paciente['altura']} cm | Peso: ${widget.paciente['peso']} kg',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),

                // Etiqueta de Parentesco
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D1FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, color: Color(0xFF00D1FF), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Parentesco: ${widget.paciente['parentesco']}',
                        style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCuerpoActual() {
    switch (_indiceActual) {
      case 0:
        return TabGlucosaFamiliar(paciente: widget.paciente);
      case 1:
        return const Center(
          child: Text('Aquí se conectará la Calculadora de Dosis', style: TextStyle(color: Colors.grey)),
        );
      case 2:
        return TabMedicamentosFamiliar(paciente: widget.paciente);
      case 3:
        return const Center(
          child: Text('Aquí se conectarán los Registros/Historial', style: TextStyle(color: Colors.grey)),
        );
      case 4:
        return const Center(
          child: Text('Aquí se conectará la ID Médica', style: TextStyle(color: Colors.grey)),
        );
      default:
        return const Center(child: Text('Vista no encontrada'));
    }
  }
}