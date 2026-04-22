import 'package:flutter/material.dart';

class PantallaDetalleFamiliar extends StatefulWidget {
  final Map<String, dynamic> paciente;

  const PantallaDetalleFamiliar({super.key, required this.paciente});

  @override
  State<PantallaDetalleFamiliar> createState() => _PantallaDetalleFamiliarState();
}

class _PantallaDetalleFamiliarState extends State<PantallaDetalleFamiliar> {
  int _indiceActual = 0;

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
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))
            ]
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _indiceActual,
            onTap: (index) => setState(() => _indiceActual = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF1C63BB),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.water_drop)),
              BottomNavigationBarItem(icon: Icon(Icons.calculate)),
              BottomNavigationBarItem(icon: Icon(Icons.medication)),
              BottomNavigationBarItem(icon: Icon(Icons.history)),
              BottomNavigationBarItem(icon: Icon(Icons.badge)),
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

  // Controlador de las pestañas internas
  Widget _construirCuerpoActual() {
    switch (_indiceActual) {
      case 0:
        return const Center(
          child: Text('Aquí se conectará el Dashboard de Glucosa', style: TextStyle(color: Colors.grey)),
        );
      case 1:
        return const Center(
          child: Text('Aquí se conectará la Calculadora de Dosis', style: TextStyle(color: Colors.grey)),
        );
      case 2:
        return const Center(
          child: Text('Aquí se conectarán los Medicamentos', style: TextStyle(color: Colors.grey)),
        );
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