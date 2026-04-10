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

  // Variables mediacion
  String? _tipoInsulina;
  final TextEditingController _insulinaMarcaCtrl = TextEditingController();
  final TextEditingController _insulinaDosisCtrl = TextEditingController();

  final TextEditingController _medOralNombreCtrl = TextEditingController();
  final TextEditingController _medOralGramajeCtrl = TextEditingController();
  final TextEditingController _medOralFrecuenciaCtrl = TextEditingController();

  List<Map<String, String>> _medicamentosOrales = [];
  bool _mostrarFormularioMedOral = false;
  int? _indiceEditandoMedOral;

  // Variables observaciones
  final TextEditingController _estadoGeneralCtrl = TextEditingController();
  final TextEditingController _alergiasCtrl = TextEditingController();
  final TextEditingController _dietaCtrl = TextEditingController();

  final List<String> _opcionesTipoDiabetes = ['Tipo 1', 'Tipo 2', 'Gestacional', 'LADA / Otro'];
  final List<String> _opcionesMonitoreo = [
    'Cada 2 horas',
    'Cada 4 horas',
    'Antes y después de comer',
    'Solo en ayunas',
    'Otro'
  ];
  final List<String> _opcionesTipoInsulina = [
    'Basal (Larga duración)',
    'Rápida (Bolo)',
    'Intermedia (NPH)',
    'Premezclada',
    'No usa insulina'
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
    _insulinaMarcaCtrl.dispose();
    _insulinaDosisCtrl.dispose();
    _medOralNombreCtrl.dispose();
    _medOralGramajeCtrl.dispose();
    _medOralFrecuenciaCtrl.dispose();
    _estadoGeneralCtrl.dispose();
    _alergiasCtrl.dispose();
    _dietaCtrl.dispose();
    super.dispose();
  }

  void _guardarMedOral() {
    if (_medOralNombreCtrl.text.isNotEmpty && _medOralGramajeCtrl.text.isNotEmpty) {
      setState(() {
        if (_indiceEditandoMedOral != null) {
          _medicamentosOrales[_indiceEditandoMedOral!] = {
            'nombre': _medOralNombreCtrl.text,
            'gramaje': _medOralGramajeCtrl.text,
            'frecuencia': _medOralFrecuenciaCtrl.text,
          };
        } else {
          _medicamentosOrales.add({
            'nombre': _medOralNombreCtrl.text,
            'gramaje': _medOralGramajeCtrl.text,
            'frecuencia': _medOralFrecuenciaCtrl.text,
          });
        }
        _limpiarYOCultarFormularioMedOral();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre y el gramaje son obligatorios.')),
      );
    }
  }

  void _editarMedOral(int index) {
    setState(() {
      final med = _medicamentosOrales[index];
      _medOralNombreCtrl.text = med['nombre'] ?? '';
      _medOralGramajeCtrl.text = med['gramaje'] ?? '';
      _medOralFrecuenciaCtrl.text = med['frecuencia'] ?? '';

      _indiceEditandoMedOral = index;
      _mostrarFormularioMedOral = true;
    });
  }

  void _limpiarYOCultarFormularioMedOral() {
    setState(() {
      _medOralNombreCtrl.clear();
      _medOralGramajeCtrl.clear();
      _medOralFrecuenciaCtrl.clear();
      _indiceEditandoMedOral = null;
      _mostrarFormularioMedOral = false;
    });
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
  void _mostrarDialogoExito() {
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
                const Text('¡Paciente Ingresado!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                const Text('Los datos del paciente han sido registrados exitosamente en su turno.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFFE8E8E8))),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      String dosisProxima = 'Pendiente';
                      if (_tipoDiabetes != 'Tipo 2' && _tipoInsulina != null && _tipoInsulina != 'No usa insulina' && _insulinaDosisCtrl.text.isNotEmpty) {
                        dosisProxima = 'Pendiente: ${_insulinaDosisCtrl.text} UI';
                      } else if (_medicamentosOrales.isNotEmpty) {
                        dosisProxima = 'Pendiente: Med. Oral';
                      }

                      Map<String, dynamic> nuevoPaciente = {
                        'nombre': '${_nombreCtrl.text} ${_apellidosCtrl.text}'.trim(),
                        'edad': _edadCtrl.text,
                        'expediente': _expedienteCtrl.text,
                        'ubicacion': _ubicacionCtrl.text.isNotEmpty ? _ubicacionCtrl.text : 'Ubicación sin asignar',
                        'tipoDiabetes': _tipoDiabetes ?? 'No especificado',
                        'alergias': _alergiasCtrl.text.isNotEmpty ? _alergiasCtrl.text : 'Ninguna',
                        'dieta': _dietaCtrl.text.isNotEmpty ? _dietaCtrl.text : 'Dieta normal',
                        'estadoGeneral': _estadoGeneralCtrl.text,
                        'hipoLimit': int.tryParse(_hipoCtrl.text) ?? 70,
                        'hiperLimit': int.tryParse(_hiperCtrl.text) ?? 180,
                        'rangoMin': int.tryParse(_rangoMinCtrl.text) ?? 80,
                        'rangoMax': int.tryParse(_rangoMaxCtrl.text) ?? 130,

                        'glucosa': 0,
                        'estadoGlucosa': 'normal',
                        'proximaDosis': dosisProxima,
                        'historialGlucosa': <Map<String, dynamic>>[],
                        'observacionesTurno': <String>[],
                      };

                      List<Map<String, dynamic>> listaMedicamentos = [];
                      if (_tipoDiabetes != 'Tipo 2' && _tipoInsulina != null && _tipoInsulina != 'No usa insulina') {
                        listaMedicamentos.add({
                          'nombre': 'Insulina $_tipoInsulina - ${_insulinaMarcaCtrl.text}',
                          'dosis': '${_insulinaDosisCtrl.text} UI',
                          'frecuencia': 'Según esquema',
                          'suministrado': false,
                        });
                      }
                      for (var med in _medicamentosOrales) {
                        listaMedicamentos.add({
                          'nombre': med['nombre'],
                          'dosis': med['gramaje'],
                          'frecuencia': med['frecuencia'],
                          'suministrado': false,
                        });
                      }
                      nuevoPaciente['medicamentos'] = listaMedicamentos;

                      Navigator.pop(context);
                      Navigator.pop(context, nuevoPaciente);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D1FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Volver a Mis Pacientes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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
                  _construirFase3Medicacion(),
                  _construirFase4Observaciones(),
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

  // pestaña 3
  Widget _construirFase3Medicacion() {
    bool fase3Completa = true;

    if (_tipoDiabetes != 'Tipo 2') {
      fase3Completa = _tipoInsulina != null;
      if (_tipoInsulina != null && _tipoInsulina != 'No usa insulina') {
        fase3Completa = fase3Completa && _insulinaMarcaCtrl.text.isNotEmpty && _insulinaDosisCtrl.text.isNotEmpty;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plan de Medicación', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 3 de 4: Esquema Clínico', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          if (_tipoDiabetes != 'Tipo 2') ...[
            _crearTarjetaGlass(
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Esquema de Insulina', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 20),
                    const Text('Tipo de Insulina Principal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 10),
                    _crearDropdown(
                        valorActual: _tipoInsulina,
                        hint: 'Seleccione el tipo',
                        opciones: _opcionesTipoInsulina,
                        onChange: (val) => setState(() => _tipoInsulina = val)
                    ),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: (_tipoInsulina != null && _tipoInsulina != 'No usa insulina')
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _crearCampoTexto(titulo: 'Marca de la Insulina', hint: 'Ej. Lantus, Humalog...', controlador: _insulinaMarcaCtrl, esNumero: false),
                          const SizedBox(height: 15),
                          _crearCampoTexto(titulo: 'Unidades Base Programadas', hint: 'Ej. 15 UI', controlador: _insulinaDosisCtrl, esNumero: false),
                        ],
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                )
            ),
            const SizedBox(height: 20),
          ],

          _crearTarjetaGlass(
              hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Medicamentos Orales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 5),
                    const Text('Agrega los fármacos que el paciente tomará en el hospital.', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                    const SizedBox(height: 20),
                    if (_medicamentosOrales.isNotEmpty) ...[
                      ..._medicamentosOrales.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Map<String, String> med = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
                                child: const Icon(Icons.medication, color: Color(0xFF1C63BB), size: 20),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${med['nombre']} ${med['gramaje']}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 3),
                                      Text('${med['frecuencia']}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                    ],
                                  )
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF008CCF)),
                                onPressed: () => _editarMedOral(idx),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                                onPressed: () => setState(() => _medicamentosOrales.removeAt(idx)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                    ],
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _mostrarFormularioMedOral
                          ? Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Detalle del Fármaco', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(flex: 2, child: _crearCampoTexto(titulo: 'Nombre', hint: 'Ej. Metformina', controlador: _medOralNombreCtrl, esNumero: false)),
                                const SizedBox(width: 15),
                                Expanded(flex: 1, child: _crearCampoTexto(titulo: 'Gramaje', hint: '850mg', controlador: _medOralGramajeCtrl, esNumero: false)),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _crearCampoTexto(titulo: 'Frecuencia de Toma', hint: 'Ej. 1 cada 12 horas', controlador: _medOralFrecuenciaCtrl, esNumero: false),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: _limpiarYOCultarFormularioMedOral,
                                  child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _guardarMedOral,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00D1FF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: Text(_indiceEditandoMedOral != null ? 'Actualizar' : 'Guardar', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                          : Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() { _mostrarFormularioMedOral = true; _indiceEditandoMedOral = null; }),
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00D1FF)),
                          label: const Text('Añadir medicamento oral', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ]
              )
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase3Completa ? _siguientePaso : null,
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

  // pestaña 4
  Widget _construirFase4Observaciones() {
    bool fase4Completa = _estadoGeneralCtrl.text.isNotEmpty && _dietaCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Observaciones', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 4 de 4: Contexto Clínico', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estado Clínico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),

                  const Text('Estado General al Ingreso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _estadoGeneralCtrl,
                    maxLines: 3,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Breve nota sobre cómo llega el paciente (ej. "lúcido", "con mareos", "deshidratado").',
                      hintStyle: const TextStyle(color: Color(0xFF848282)),
                      filled: true, fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _crearCampoTexto(titulo: 'Alergias Conocidas', hint: 'Ej. Penicilina, Látex, Ninguna', controlador: _alergiasCtrl, esNumero: false),
                ],
              )
          ),
          const SizedBox(height: 20),

          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nutrición', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  _crearCampoTexto(titulo: 'Dieta Asignada', hint: 'Ej. Baja en carbohidratos, Ayuno...', controlador: _dietaCtrl, esNumero: false),
                ],
              )
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase4Completa ? () {
                _mostrarDialogoExito();
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008CCF),
                disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Guardar Paciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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