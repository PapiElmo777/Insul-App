import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PantallaAgregarPaciente extends StatefulWidget {
  const PantallaAgregarPaciente({super.key});

  @override
  State<PantallaAgregarPaciente> createState() => _PantallaAgregarPacienteState();
}

class _PantallaAgregarPacienteState extends State<PantallaAgregarPaciente> {
  final PageController _pageController = PageController();
  int _pasoActual = 0;
  final int _totalPasos = 4;

  // Variables datos del paciente
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _edadCtrl = TextEditingController();
  final TextEditingController _expedienteCtrl = TextEditingController();
  final TextEditingController _ubicacionCtrl = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _edadCtrl.dispose();
    _expedienteCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  void _siguientePaso() {
    if (_pasoActual < _totalPasos - 1) {
      setState(() { _pasoActual++; });
      _pageController.animateToPage(
        _pasoActual,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _pasoAnterior() {
    if (_pasoActual > 0) {
      setState(() { _pasoActual--; });
      _pageController.animateToPage(
        _pasoActual,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C63BB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pasoAnterior,
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: List.generate(_totalPasos, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            height: 4.0,
                            decoration: BoxDecoration(
                              color: index <= _pasoActual ? const Color(0xFF00D1FF) : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _construirFase1Identidad(),
                  _construirFasePlaceholder('Fase 2: Control Glucémico'),
                  _construirFasePlaceholder('Fase 3: Plan de Medicación'),
                  _construirFasePlaceholder('Fase 4: Observaciones de Ingreso'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFase1Identidad() {
    bool fase1Completa = _nombreCtrl.text.isNotEmpty &&
        _apellidosCtrl.text.isNotEmpty &&
        _edadCtrl.text.isNotEmpty &&
        _expedienteCtrl.text.isNotEmpty &&
        _ubicacionCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_add_alt_1, size: 50, color: Colors.white),
          const SizedBox(height: 15),
          const Text('Ingreso de Paciente', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 1 de 4: Identidad', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Datos Personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  _crearCampoTexto(titulo: 'Nombre(s)', hint: 'Ej. Juan Pablo', controlador: _nombreCtrl, esNumero: false),
                  const SizedBox(height: 15),
                  _crearCampoTexto(titulo: 'Apellidos', hint: 'Ej. Hernández', controlador: _apellidosCtrl, esNumero: false),
                  const SizedBox(height: 15),
                  _crearCampoTexto(titulo: 'Edad', hint: 'Años', controlador: _edadCtrl, esNumero: true),
                ],
              )
          ),
          const SizedBox(height: 20),

          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Datos Hospitalarios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  _crearCampoTexto(titulo: 'No. Expediente / Folio', hint: 'Ej. EXP-98765', controlador: _expedienteCtrl, esNumero: false),
                  const SizedBox(height: 15),
                  _crearCampoTexto(titulo: 'Ubicación Actual', hint: 'Ej. Piso 3 / Cama 12', controlador: _ubicacionCtrl, esNumero: false),
                ],
              )
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase1Completa ? _siguientePaso : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008CCF),
                disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Siguiente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirFasePlaceholder(String texto) {
    return Center(child: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 20), textAlign: TextAlign.center));
  }

  Widget _crearTarjetaGlass({required Widget hijo}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: hijo,
    );
  }

  Widget _crearCampoTexto({required String titulo, required String hint, required TextEditingController controlador, required bool esNumero}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
        const SizedBox(height: 5),
        TextField(
          controller: controlador,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          inputFormatters: esNumero ? [FilteringTextInputFormatter.digitsOnly] : [],
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: Color(0xFF848282)),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}