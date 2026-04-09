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

  // Variables control glucémico
  String? _tipoDiabetes;
  final TextEditingController _hipoCtrl = TextEditingController(text: '70');
  final TextEditingController _hiperCtrl = TextEditingController(text: '180');
  final TextEditingController _rangoMinCtrl = TextEditingController(text: '80');
  final TextEditingController _rangoMaxCtrl = TextEditingController(text: '130');
  String? _frecuenciaMonitoreo;

  final List<String> _opcionesTipoDiabetes = ['Tipo 1', 'Tipo 2', 'Gestacional', 'LADA / Otro'];
  final List<String> _opcionesMonitoreo = [
    'Cada 2 horas',
    'Cada 4 horas',
    'Antes y después de comer',
    'Solo en ayunas',
    'Otro'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _edadCtrl.dispose();
    _expedienteCtrl.dispose();
    _ubicacionCtrl.dispose();
    _hipoCtrl.dispose();
    _hiperCtrl.dispose();
    _rangoMinCtrl.dispose();
    _rangoMaxCtrl.dispose();
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
                  _construirFase2ControlGlucemico(),
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
//pestaña 1
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

  //pestaña 2
  Widget _construirFase2ControlGlucemico() {
    bool fase2Completa = _tipoDiabetes != null &&
        _frecuenciaMonitoreo != null &&
        _hipoCtrl.text.isNotEmpty &&
        _hiperCtrl.text.isNotEmpty &&
        _rangoMinCtrl.text.isNotEmpty &&
        _rangoMaxCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Control Glucémico', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 2 de 4: Parámetros', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Diagnóstico y Monitoreo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  const Text('Tipo de Diabetes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                  const SizedBox(height: 10),
                  _crearDropdown(
                      valorActual: _tipoDiabetes,
                      hint: 'Selecciona una opción',
                      opciones: _opcionesTipoDiabetes,
                      onChange: (val) => setState(() => _tipoDiabetes = val)
                  ),
                  const SizedBox(height: 20),

                  const Text('Frecuencia de Monitoreo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                  const SizedBox(height: 5),
                  const Text('¿Cada cuánto se le debe tomar la glucosa en su turno?', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                  const SizedBox(height: 10),
                  _crearDropdown(
                      valorActual: _frecuenciaMonitoreo,
                      hint: 'Selecciona la frecuencia',
                      opciones: _opcionesMonitoreo,
                      onChange: (val) => setState(() => _frecuenciaMonitoreo = val)
                  ),
                ],
              )
          ),
          const SizedBox(height: 20),
          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rango Meta de Glucosa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  const Text('Límites de atención clínica indicados por el médico tratante.', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                  const SizedBox(height: 25),
                  _construirGraficoGlucosa(),
                  const SizedBox(height: 30),

                  _crearCampoTexto(titulo: 'Límite Inferior (Hipoglucemia)', hint: 'Ej. 70 mg/dL', controlador: _hipoCtrl, esNumero: true),
                  const SizedBox(height: 15),
                  _crearCampoTexto(titulo: 'Límite Superior (Hiperglucemia)', hint: 'Ej. 180 mg/dL', controlador: _hiperCtrl, esNumero: true),
                  const SizedBox(height: 20),

                  const Text('Rango Objetivo (Normal)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _crearCampoTexto(titulo: 'Mínimo', hint: '80', controlador: _rangoMinCtrl, esNumero: true)),
                      const SizedBox(width: 15),
                      Expanded(child: _crearCampoTexto(titulo: 'Máximo', hint: '130', controlador: _rangoMaxCtrl, esNumero: true)),
                    ],
                  ),
                ],
              )
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase2Completa ? _siguientePaso : null,
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
  Widget _construirGraficoGlucosa() {
    String hipo = _hipoCtrl.text.isEmpty ? '--' : _hipoCtrl.text;
    String rMin = _rangoMinCtrl.text.isEmpty ? '--' : _rangoMinCtrl.text;
    String rMax = _rangoMaxCtrl.text.isEmpty ? '--' : _rangoMaxCtrl.text;
    String hiper = _hiperCtrl.text.isEmpty ? '--' : _hiperCtrl.text;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Text('Hipo', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('< $hipo', style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Text('Normal', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 8),
                  Text('$rMin - $rMax', style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Text('Hiper', style: TextStyle(color: Color(0xFFFFB347), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFB347),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('> $hiper', style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        )
      ],
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

  Widget _crearDropdown({required String? valorActual, required String hint, required List<String> opciones, required Function(String?) onChange}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          itemHeight: null,
          value: valorActual,
          hint: Text(hint, style: const TextStyle(color: Colors.grey)),
          onChanged: onChange,
          items: opciones.map((String valor) => DropdownMenuItem<String>(
              value: valor,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(valor, style: const TextStyle(color: Colors.black)),
              )
          )).toList(),
        ),
      ),
    );
  }
}