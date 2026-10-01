import 'package:flutter/material.dart';
import '../controlador_registro_cuidador.dart';
import '../ui_helpers.dart';
import '../../../../pantallas/cuidadores/pantalla_inicio_cuidador.dart';

class Paso6Identificacion extends StatelessWidget {
  final ControladorRegistroCuidador controlador;

  const Paso6Identificacion({super.key, required this.controlador});

  Future<void> _finalizar(BuildContext context, bool irAIdentificacion) async {
    final nombreCuidador = await controlador.guardarDatosBD();
    
    if (!context.mounted) return;

    if (irAIdentificacion) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => PantallaInicioCuidador(
            nombreCuidador: nombreCuidador,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      _mostrarDialogoFinalizacion(context, nombreCuidador);
    }
  }

  void _mostrarDialogoFinalizacion(BuildContext context, String nombreCuidador) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C63BB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF00D1FF), size: 60),
                const SizedBox(height: 20),
                const Text('¡Registro Finalizado!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                const Text('Los datos del paciente han sido guardados exitosamente.\n\n¡Bienvenido a Insul App!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFFE8E8E8))),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaInicioCuidador(
                            nombreCuidador: nombreCuidador,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D1FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Ir al Inicio', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.badge, size: 60, color: Colors.white),
          const SizedBox(height: 20),
          const Text('Identificación Médica', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 6 de 6', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          crearTarjetaGlass(
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('¿Por qué es vital?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text(
                  'Las directrices de la ADA (Asociación Americana de Diabetes) establecen que toda persona con diabetes debe portar una identificación médica visible. En caso de una emergencia donde el paciente no pueda comunicarse, esto puede salvar su vida indicando a los paramédicos cómo actuar.',
                  style: TextStyle(fontSize: 15, color: Color(0xFFE8E8E8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          const Text('¿Deseas configurar la Identificación Médica de Emergencia del paciente ahora?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () {
                _finalizar(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D1FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Sí, empezar ahora', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ),
          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity, height: 50,
            child: OutlinedButton(
              onPressed: () {
                _finalizar(context, false);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Hacerlo después', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
