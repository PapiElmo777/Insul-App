import 'package:flutter/material.dart';
import '../controlador_calculadora.dart';
import 'constantes_calculadora.dart';

class PreguntaInicialWidget extends StatelessWidget {
  final ControladorCalculadora controlador;
  
  const PreguntaInicialWidget({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Color(0xFFD2D2D2), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle), child: const Icon(Icons.restaurant, size: 60, color: Color(0xFF1C63BB))),
                  const SizedBox(height: 25),
                  const Text(TextosCalculadora.tutTituloPrincipal, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 15),
                  const Text(TextosCalculadora.tutPreguntaInicial, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4)),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        controlador.marcarTutorialVisto();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1C63BB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text(TextosCalculadora.tutBtnConozco, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: OutlinedButton(
                      onPressed: () => controlador.activarExplicacion(),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF1C63BB), width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text(TextosCalculadora.tutBtnExplicame, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExplicacionTutorialWidget extends StatelessWidget {
  final ControladorCalculadora controlador;
  
  const ExplicacionTutorialWidget({super.key, required this.controlador});

  Widget _crearPasoTutorial(String numero, IconData icono, Color color, String titulo, String descripcion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Color(0xFFD2D2D2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icono, color: color, size: 28)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paso $numero: $titulo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 8),
                Text(descripcion, style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(TextosCalculadora.tutTituloExplicacion, style: TextStyle(fontFamily: 'Montserrat', fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1C63BB))),
              const SizedBox(height: 15),
              const Text(TextosCalculadora.tutDescExplicacion, style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),
              const SizedBox(height: 25),
              const Text(TextosCalculadora.tutSubtituloExp, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              _crearPasoTutorial('1', Icons.bloodtype, Color(0xFFD32F2F), TextosCalculadora.tutPaso1Titulo, TextosCalculadora.tutPaso1Desc),
              _crearPasoTutorial('2', Icons.restaurant_menu, Color(0xFFE65100), TextosCalculadora.tutPaso2Titulo, TextosCalculadora.tutPaso2Desc),
              _crearPasoTutorial('3', Icons.calculate, Color(0xFF2E7D32), TextosCalculadora.tutPaso3Titulo, TextosCalculadora.tutPaso3Desc),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    controlador.marcarTutorialVisto();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF008CCF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text(TextosCalculadora.tutBtnEntendido, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
