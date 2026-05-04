import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import 'enfermeros/pantalla_inicio_enfermero.dart';
import 'paciente/pantalla_inicio_paciente.dart';
import 'cuidadores/pantalla_inicio_cuidador.dart';

//------------------------------------------------------------------------------------------------
class PantallaCuestionarioEnfermero extends StatefulWidget {
  const PantallaCuestionarioEnfermero({super.key});

  @override
  State<PantallaCuestionarioEnfermero> createState() => _PantallaCuestionarioEnfermeroState();
}

class _PantallaCuestionarioEnfermeroState extends State<PantallaCuestionarioEnfermero> with SingleTickerProviderStateMixin {
  String? areaSeleccionada;
  late AnimationController _controladorPrincipal;

  late Animation<double> _animacionOpacidadHeader;
  late Animation<Offset> _animacionSlidePaso1;
  late Animation<Offset> _animacionSlidePaso2;
  late Animation<Offset> _animacionSlidePaso3;
  late Animation<Offset> _animacionSlideBoton;

  final TextEditingController _cedulaCtrl = TextEditingController();
  final TextEditingController _institucionCtrl = TextEditingController();
  final TextEditingController _otraAreaCtrl = TextEditingController();

  final List<String> areas = [
    'Medicina Interna',
    'Endocrinología',
    'Urgencias',
    'Pediatría',
    'Otra'
  ];

  @override
  void initState() {
    super.initState();
    _controladorPrincipal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animacionOpacidadHeader = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.0, 0.2, curve: Curves.easeIn)),
    );

    _animacionSlidePaso1 = Tween<Offset>(begin: const Offset(0.5, 0.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.1, 0.4, curve: Curves.easeOutCubic)),
    );

    _animacionSlidePaso2 = Tween<Offset>(begin: const Offset(0.5, 0.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic)),
    );

    _animacionSlidePaso3 = Tween<Offset>(begin: const Offset(0.5, 0.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic)),
    );

    _animacionSlideBoton = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic)),
    );

    _controladorPrincipal.forward();
  }

  @override
  void dispose() {
    _controladorPrincipal.dispose();
    _cedulaCtrl.dispose();
    _institucionCtrl.dispose();
    _otraAreaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarDatosYFinalizar() async {
    final db = DatabaseHelper();
    final usuarioId = await db.obtenerSesionActiva();

    if (usuarioId != null) {
      await db.insertarEnfermero({
        'usuario_id': usuarioId,
        'cedula': _cedulaCtrl.text,
        'institucion': _institucionCtrl.text,
        'area': areaSeleccionada == 'Otra' ? _otraAreaCtrl.text : (areaSeleccionada ?? ''),
      });
    }

    if (!mounted) return;
    _mostrarDialogoFinalizacion();
  }

  void _mostrarDialogoFinalizacion() {
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
                const Text('Tu perfil médico ha sido verificado y guardado exitosamente.\n\n¡Bienvenido a Insul App!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFFE8E8E8))),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const PantallaInicioEnfermero()),
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
    return Scaffold(
      backgroundColor: const Color(0xFF1C63BB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _animacionOpacidadHeader,
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medical_information, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Perfil Médico',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Hagamos tu perfil oficial.\nPara garantizar la seguridad de los pacientes, necesitamos agregar información sobre tí.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Color(0xFFE8E8E8)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),

              SlideTransition(
                position: _animacionSlidePaso1,
                child: _crearCampoTexto(titulo: 'Cédula Profesional', hint: 'Ej. 12345678', esNumero: true, icono: Icons.badge_outlined, controlador: _cedulaCtrl),
              ),
              const SizedBox(height: 20),

              SlideTransition(
                position: _animacionSlidePaso2,
                child: _crearCampoTexto(titulo: 'Institución Médica', hint: 'Hospital o Clínica donde laboras', icono: Icons.local_hospital_outlined, controlador: _institucionCtrl),
              ),
              const SizedBox(height: 20),

              SlideTransition(
                position: _animacionSlidePaso3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Área a la que pertenece',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: areas.map((area) => ChoiceChip(
                        label: Text(area),
                        selected: areaSeleccionada == area,
                        selectedColor: const Color(0xFF00D1FF).withOpacity(0.3),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: areaSeleccionada == area ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        side: BorderSide(
                          color: areaSeleccionada == area ? const Color(0xFF00D1FF) : const Color(0xFFD2D2D2),
                          width: 1.5,
                        ),
                        onSelected: (selected) {
                          setState(() { areaSeleccionada = selected ? area : null; });
                        },
                      )).toList(),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: areaSeleccionada == 'Otra'
                          ? Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: _crearCampoTexto(titulo: 'Especifica el área', hint: 'Escribe tu área médica', icono: Icons.edit_outlined, controlador: _otraAreaCtrl),
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 45),

              SlideTransition(
                position: _animacionSlideBoton,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _guardarDatosYFinalizar();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008CCF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: const BorderSide(color: Color(0xFFD2D2D2), width: 1.5)
                      ),
                    ),
                    child: const Text('Finalizar Registro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearCampoTexto({required String titulo, required String hint, bool esNumero = false, required IconData icono, required TextEditingController controlador}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controlador,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          inputFormatters: esNumero ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: InputDecoration(
            prefixIcon: Icon(icono, color: const Color(0xFF1C63BB)),
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF848282)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFD2D2D2), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFD2D2D2), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF008CCF), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

//------------------------------------------------------------------------------------------------
class PantallaCuestionarioPaciente extends StatefulWidget {
  const PantallaCuestionarioPaciente({super.key});

  @override
  State<PantallaCuestionarioPaciente> createState() => _PantallaCuestionarioPacienteState();
}

class _PantallaCuestionarioPacienteState extends State<PantallaCuestionarioPaciente> {
  final PageController _pageController = PageController();
  int _pasoActual = 0;
  final int _totalPasos = 6;
  bool _aceptoTerminos = false;

  String? _sexo;
  final TextEditingController _edadCtrl = TextEditingController();
  String? _tiempoDx;
  String? _tipoDiabetes;
  final TextEditingController _alergiasCtrl = TextEditingController();
  final TextEditingController _hospitalizacionesCtrl = TextEditingController();
  final TextEditingController _pesoCtrl = TextEditingController();
  final TextEditingController _alturaCtrl = TextEditingController();

  final FocusNode _pesoFocus = FocusNode();
  final FocusNode _alturaFocus = FocusNode();

  double _imc = 0.0;

  final TextEditingController _hipoCtrl = TextEditingController(text: '70');
  final TextEditingController _hiperCtrl = TextEditingController(text: '180');
  final TextEditingController _rangoMinCtrl = TextEditingController(text: '80');
  final TextEditingController _rangoMaxCtrl = TextEditingController(text: '130');
  final TextEditingController _fsiCtrl = TextEditingController(text: '50');
  final TextEditingController _ricCtrl = TextEditingController(text: '15');

  String? _metodoInsulina;
  String? _tipoInsulinaInyeccion;

  final TextEditingController _insulinaBasalMarcaCtrl = TextEditingController();
  final TextEditingController _insulinaBasalDosisCtrl = TextEditingController();
  final TextEditingController _insulinaRapidaMarcaCtrl = TextEditingController();
  final TextEditingController _insulinaRapidaPatronCtrl = TextEditingController();
  final TextEditingController _bombaUnidadesCtrl = TextEditingController();
  final TextEditingController _bombaFrecuenciaCtrl = TextEditingController();

  final TextEditingController _medOralNombreCtrl = TextEditingController();
  final TextEditingController _medOralDosisCtrl = TextEditingController();

  final TextEditingController _otroMedNombreCtrl = TextEditingController();
  final TextEditingController _otroMedGramajeCtrl = TextEditingController();
  final TextEditingController _otroMedPropositoCtrl = TextEditingController();
  final TextEditingController _otroMedFrecuenciaCtrl = TextEditingController();

  List<Map<String, String>> _otrosMedicamentos = [];
  bool _mostrarFormularioOtroMed = false;
  int? _indiceEditando;

  String? _frecuenciaMonitoreo;
  final TextEditingController _otroMonitoreoCtrl = TextEditingController();

  String? _actividadFisica;
  final TextEditingController _emergenciaNombreCtrl = TextEditingController();
  final TextEditingController _emergenciaParentescoCtrl = TextEditingController();
  final TextEditingController _emergenciaTelefonoCtrl = TextEditingController();
  final TextEditingController _medicoNombreCtrl = TextEditingController();

  final List<String> _opcionesTiempoDx = ['Menos de 1 año', '1 a 5 años', '5 a 10 años', 'Más de 10 años'];
  final List<String> _opcionesTipoDiabetes = ['Tipo 1', 'Tipo 2', 'Gestacional', 'LADA / Otro'];
  final List<String> _opcionesMonitoreo = [
    'Ayunas y antes de comidas',
    'Al despertar y antes de dormir',
    'Antes y después de comer',
    'Solo si hay síntomas',
    'Monitoreo continuo (Sensor)',
    'Otro protocolo'
  ];
  final List<String> _opcionesActividad = [
    'Sedentario',
    'Ligero (1-2 días/sem)',
    'Moderado (3-5 días/sem)',
    'Intenso (6-7 días/sem)',
    'Atleta de alto rendimiento'
  ];

  @override
  void initState() {
    super.initState();
    _pesoFocus.addListener(() {
      if (!_pesoFocus.hasFocus) _calcularIMC();
    });
    _alturaFocus.addListener(() {
      if (!_alturaFocus.hasFocus) _calcularIMC();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _edadCtrl.dispose();
    _alergiasCtrl.dispose();
    _hospitalizacionesCtrl.dispose();
    _pesoCtrl.dispose();
    _alturaCtrl.dispose();
    _pesoFocus.dispose();
    _alturaFocus.dispose();

    _hipoCtrl.dispose();
    _hiperCtrl.dispose();
    _rangoMinCtrl.dispose();
    _rangoMaxCtrl.dispose();
    _fsiCtrl.dispose();
    _ricCtrl.dispose();
    _insulinaBasalMarcaCtrl.dispose();
    _insulinaBasalDosisCtrl.dispose();
    _insulinaRapidaMarcaCtrl.dispose();
    _insulinaRapidaPatronCtrl.dispose();
    _bombaUnidadesCtrl.dispose();
    _bombaFrecuenciaCtrl.dispose();
    _medOralNombreCtrl.dispose();
    _medOralDosisCtrl.dispose();
    _otroMedNombreCtrl.dispose();
    _otroMedGramajeCtrl.dispose();
    _otroMedPropositoCtrl.dispose();
    _otroMedFrecuenciaCtrl.dispose();
    _otroMonitoreoCtrl.dispose();
    _emergenciaNombreCtrl.dispose();
    _emergenciaParentescoCtrl.dispose();
    _emergenciaTelefonoCtrl.dispose();
    _medicoNombreCtrl.dispose();
    super.dispose();
  }

  void _calcularIMC() {
    if (_pesoCtrl.text.isNotEmpty && _alturaCtrl.text.isNotEmpty) {
      double? peso = double.tryParse(_pesoCtrl.text);
      double? alturaCm = double.tryParse(_alturaCtrl.text);

      if (peso != null && alturaCm != null && alturaCm > 0) {
        double alturaMetros = alturaCm / 100;
        setState(() {
          _imc = peso / (alturaMetros * alturaMetros);
        });
      }
    } else {
      setState(() { _imc = 0.0; });
    }
  }

  void _guardarMedicamento() {
    if (_otroMedNombreCtrl.text.isNotEmpty && _otroMedGramajeCtrl.text.isNotEmpty) {
      setState(() {
        if (_indiceEditando != null) {
          _otrosMedicamentos[_indiceEditando!] = {
            'nombre': _otroMedNombreCtrl.text,
            'gramaje': _otroMedGramajeCtrl.text,
            'proposito': _otroMedPropositoCtrl.text,
            'frecuencia': _otroMedFrecuenciaCtrl.text,
          };
        } else {
          _otrosMedicamentos.add({
            'nombre': _otroMedNombreCtrl.text,
            'gramaje': _otroMedGramajeCtrl.text,
            'proposito': _otroMedPropositoCtrl.text,
            'frecuencia': _otroMedFrecuenciaCtrl.text,
          });
        }
        _limpiarYOCultarFormulario();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre y el gramaje son obligatorios.')),
      );
    }
  }

  void _editarMedicamento(int index) {
    setState(() {
      final med = _otrosMedicamentos[index];
      _otroMedNombreCtrl.text = med['nombre'] ?? '';
      _otroMedGramajeCtrl.text = med['gramaje'] ?? '';
      _otroMedPropositoCtrl.text = med['proposito'] ?? '';
      _otroMedFrecuenciaCtrl.text = med['frecuencia'] ?? '';

      _indiceEditando = index;
      _mostrarFormularioOtroMed = true;
    });
  }

  void _limpiarYOCultarFormulario() {
    setState(() {
      _otroMedNombreCtrl.clear();
      _otroMedGramajeCtrl.clear();
      _otroMedPropositoCtrl.clear();
      _otroMedFrecuenciaCtrl.clear();
      _indiceEditando = null;
      _mostrarFormularioOtroMed = false;
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

  Future<void> _guardarDatosPacienteYFinalizar({bool irAIdentificacion = false}) async {
    final db = DatabaseHelper();
    final usuarioId = await db.obtenerSesionActiva();
    String nombreUsuario = 'Paciente';

    if (_metodoInsulina != 'Inyecciones') {
      _insulinaBasalMarcaCtrl.clear();
      _insulinaBasalDosisCtrl.clear();
      _insulinaRapidaMarcaCtrl.clear();
      _insulinaRapidaPatronCtrl.clear();
    } else {
      if (_tipoInsulinaInyeccion == 'Basal') {
        _insulinaRapidaMarcaCtrl.clear();
        _insulinaRapidaPatronCtrl.clear();
      } else if (_tipoInsulinaInyeccion == 'Bolo') {
        _insulinaBasalMarcaCtrl.clear();
        _insulinaBasalDosisCtrl.clear();
      }
    }

    if (_metodoInsulina != 'Bomba') {
      _bombaUnidadesCtrl.clear();
      _bombaFrecuenciaCtrl.clear();
    }

    try {
      if (usuarioId != null) {
        final pacienteData = {
          'usuario_id': usuarioId,
          'sexo': _sexo ?? '',
          'edad': int.tryParse(_edadCtrl.text) ?? 0,
          'tiempo_dx': _tiempoDx ?? '',
          'tipo_diabetes': _tipoDiabetes ?? '',
          'alergias': _alergiasCtrl.text,
          'hospitalizaciones': _hospitalizacionesCtrl.text.isEmpty ? 'Ninguna' : _hospitalizacionesCtrl.text,
          'peso': double.tryParse(_pesoCtrl.text) ?? 0.0,
          'altura': double.tryParse(_alturaCtrl.text) ?? 0.0,
          'imc': _imc,
          'limite_hipo': double.tryParse(_hipoCtrl.text) ?? 70.0,
          'limite_hiper': double.tryParse(_hiperCtrl.text) ?? 180.0,
          'rango_min': double.tryParse(_rangoMinCtrl.text) ?? 80.0,
          'rango_max': double.tryParse(_rangoMaxCtrl.text) ?? 130.0,
          'metodo_insulina': _metodoInsulina ?? '',
          'insulina_basal_marca': _insulinaBasalMarcaCtrl.text,
          'insulina_basal_dosis': _insulinaBasalDosisCtrl.text,
          'insulina_rapida_marca': _insulinaRapidaMarcaCtrl.text,
          'insulina_rapida_patron': _insulinaRapidaPatronCtrl.text,
          'bomba_unidades': _bombaUnidadesCtrl.text,
          'bomba_frecuencia': _bombaFrecuenciaCtrl.text,
          'med_oral_nombre': _medOralNombreCtrl.text,
          'med_oral_dosis': _medOralDosisCtrl.text,
          'frecuencia_monitoreo': _frecuenciaMonitoreo ?? '',
          'actividad_fisica': _actividadFisica ?? '',
          'emergencia_nombre': _emergenciaNombreCtrl.text,
          'emergencia_parentesco': _emergenciaParentescoCtrl.text,
          'emergencia_telefono': _emergenciaTelefonoCtrl.text,
          'medico_nombre': _medicoNombreCtrl.text,
        };

        final pacienteId = await db.insertarPaciente(pacienteData);

        for (var med in _otrosMedicamentos) {
          await db.insertarOtroMedicamento({
            'paciente_id': pacienteId,
            'nombre': med['nombre'],
            'gramaje': med['gramaje'],
            'proposito': med['proposito'],
            'frecuencia': med['frecuencia'],
          });
        }

        final usuario = await db.obtenerUsuarioPorId(usuarioId);
        if (usuario != null) {
          nombreUsuario = usuario['nombre'] as String;
        }
      }
    } catch (e) {
      debugPrint('Error guardando datos del paciente: $e');
    }

    if (!mounted) return;

    if (irAIdentificacion) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => PantallaInicioPaciente(
            nombrePaciente: nombreUsuario,
            indiceInicial: 5,
          ),
        ),
            (Route<dynamic> route) => false,
      );
    } else {
      _mostrarDialogoFinalizacion(nombreUsuario);
    }
  }

  void _mostrarDialogoFinalizacion(String nombrePaciente) {
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
                const Text('Tus datos clínicos han sido guardados exitosamente.\n\n¡Bienvenido a Insul App!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFFE8E8E8))),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaInicioPaciente(
                            nombrePaciente: nombrePaciente,
                            indiceInicial: 0,
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
                  _construirFase0Advertencias(),
                  _construirFase1Perfil(),
                  _construirFase2Parametros(),
                  _construirFase3Medicacion(),
                  _construirFase4EstiloVida(),
                  _construirFase5Identificacion(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFase0Advertencias() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.security, size: 60, color: Colors.white),
          const SizedBox(height: 20),
          const Text('Antes de comenzar', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          _crearTarjetaGlass(
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('¿Por qué pedimos estos datos?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text(
                  'Insul App necesita conocer tu perfil clínico para personalizar los cálculos, ajustar las alertas y brindarte una experiencia adaptada a tu tipo de diabetes.',
                  style: TextStyle(fontSize: 15, color: Color(0xFFE8E8E8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _crearTarjetaGlass(
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Aviso Médico Importante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text(
                  'Esta aplicación NO sustituye una consulta médica ni emite diagnósticos. Su objetivo es ser una herramienta de apoyo que se adapta a las directrices de tu médico.',
                  style: TextStyle(fontSize: 15, color: Color(0xFFE8E8E8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Checkbox(
                value: _aceptoTerminos,
                activeColor: const Color(0xFF00D1FF),
                checkColor: const Color(0xFF1C63BB),
                side: const BorderSide(color: Colors.white, width: 2),
                onChanged: (val) {
                  setState(() { _aceptoTerminos = val ?? false; });
                },
              ),
              const Expanded(
                child: Text('He leído y comprendo esta información.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _aceptoTerminos ? _siguientePaso : null,
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

  Widget _construirFase1Perfil() {
    bool fase1Completa = _sexo != null && _edadCtrl.text.isNotEmpty && _tiempoDx != null && _tipoDiabetes != null && _pesoCtrl.text.isNotEmpty && _alturaCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Perfil Clínico', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 1 de 5', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          const Text('Género', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _crearChipSeleccion('Hombre', _sexo == 'Hombre', () => setState(() => _sexo = 'Hombre'))),
              const SizedBox(width: 15),
              Expanded(child: _crearChipSeleccion('Mujer', _sexo == 'Mujer', () => setState(() => _sexo = 'Mujer'))),
            ],
          ),
          const SizedBox(height: 20),

          _crearCampoTexto(titulo: 'Edad', hint: 'Años', controlador: _edadCtrl, esNumero: true),
          const SizedBox(height: 3),

          const Text('Tiempo con diagnóstico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 5),
          _crearDropdown(valorActual: _tiempoDx, hint: 'Selecciona una opción', opciones: _opcionesTiempoDx, onChange: (val) => setState(() => _tiempoDx = val)),
          const SizedBox(height: 20),

          const Text('Tipo de Diabetes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 5),
          _crearDropdown(valorActual: _tipoDiabetes, hint: 'Ej. Tipo 1', opciones: _opcionesTipoDiabetes, onChange: (val) => setState(() => _tipoDiabetes = val)),
          const SizedBox(height: 20),

          _crearCampoTexto(titulo: 'Alergias Conocidas (Opcional)', hint: 'Ej. Penicilina, Ninguna', controlador: _alergiasCtrl, esNumero: false),
          const SizedBox(height: 20),

          _crearCampoTexto(titulo: 'Hospitalizaciones Recientes (Opcional)', hint: 'Ej. Ninguna', controlador: _hospitalizacionesCtrl, esNumero: false),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _crearCampoTexto(titulo: 'Peso (kg)', hint: 'Ej. 75', controlador: _pesoCtrl, esNumero: true, focusNode: _pesoFocus)),
              const SizedBox(width: 15),
              Expanded(child: _crearCampoTexto(titulo: 'Altura (cm)', hint: 'Ej. 170', controlador: _alturaCtrl, esNumero: true, focusNode: _alturaFocus)),
            ],
          ),
          const SizedBox(height: 15),

          _crearTarjetaGlass(
              hijo: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tu I.M.C. calculado:', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                    _imc > 0 ? _imc.toStringAsFixed(1) : '--',
                    style: const TextStyle(fontSize: 24, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold),
                  ),
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

  Widget _construirFase2Parametros() {
    bool fase2Completa = _hipoCtrl.text.isNotEmpty && _hiperCtrl.text.isNotEmpty && _rangoMinCtrl.text.isNotEmpty && _rangoMaxCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Parámetros de Control', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 2 de 5', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),

          _crearTarjetaGlass(
            hijo: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF00D1FF), size: 30),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    'Los valores por defecto y acciones correctivas están basados en las Guías Oficiales de la ADA. Puedes modificarlos si tu médico te indicó rangos distintos.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          _construirGraficoGlucosa(),
          const SizedBox(height: 30),

          _crearCampoTexto(titulo: 'Límite de Hipoglucemia (mg/dL)', hint: 'Ej. 70', controlador: _hipoCtrl, esNumero: true),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
            child: Text('⚠️ Debajo de este valor, la app disparará el protocolo de acción inmediata.', style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 13)),
          ),

          _crearCampoTexto(titulo: 'Límite de Hiperglucemia (mg/dL)', hint: 'Ej. 180', controlador: _hiperCtrl, esNumero: true),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
            child: Text('⚠️ Por encima de este valor, se activarán las alertas de control.', style: TextStyle(color: Color(0xFFFFB347), fontSize: 13)),
          ),

          const Text('Rangos Normales Objetivo (mg/dL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _crearCampoTexto(titulo: 'Mínimo', hint: '80', controlador: _rangoMinCtrl, esNumero: true)),
              const SizedBox(width: 15),
              Expanded(child: _crearCampoTexto(titulo: 'Máximo', hint: '130', controlador: _rangoMaxCtrl, esNumero: true)),
            ],
          ),
          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(15)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Configuración Avanzada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _crearCampoTexto(titulo: 'Factor de Sensibilidad (FSI)', hint: 'Ej. 50', controlador: _fsiCtrl, esNumero: true, activo: true),
                const SizedBox(height: 10),
                _crearCampoTexto(titulo: 'Relación Insulina/Carbos (RIC)', hint: 'Ej. 15', controlador: _ricCtrl, esNumero: true, activo: true),
              ],
            ),
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

    return _crearTarjetaGlass(
        hijo: Column(
          children: [
            const Text('Espectro de Glucosa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
            const SizedBox(height: 20),
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
                      Text('< $hipo', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
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
                      Text('$rMin - $rMax', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
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
                      Text('> $hiper', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            )
          ],
        )
    );
  }

  Widget _construirFase3Medicacion() {
    bool fase3Completa = _frecuenciaMonitoreo != null &&
        (_frecuenciaMonitoreo != 'Otro protocolo' || _otroMonitoreoCtrl.text.isNotEmpty);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Medicación Habitual', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 3 de 5', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          if (_tipoDiabetes == 'Tipo 1') ...[
            const Text('Método de aplicación de Insulina', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _crearChipSeleccion('Inyecciones', _metodoInsulina == 'Inyecciones', () => setState(() => _metodoInsulina = 'Inyecciones'))),
                const SizedBox(width: 15),
                Expanded(child: _crearChipSeleccion('Bomba', _metodoInsulina == 'Bomba', () => setState(() => _metodoInsulina = 'Bomba'))),
              ],
            ),
            const SizedBox(height: 20),

            if (_metodoInsulina == 'Inyecciones') ...[
              const Text('Tipo de Insulina', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _crearChipSeleccion('Basal', _tipoInsulinaInyeccion == 'Basal', () => setState(() => _tipoInsulinaInyeccion = 'Basal'))),
                  const SizedBox(width: 10),
                  Expanded(child: _crearChipSeleccion('Bolo', _tipoInsulinaInyeccion == 'Bolo', () => setState(() => _tipoInsulinaInyeccion = 'Bolo'))),
                  const SizedBox(width: 10),
                  Expanded(child: _crearChipSeleccion('Ambas', _tipoInsulinaInyeccion == 'Ambas', () => setState(() => _tipoInsulinaInyeccion = 'Ambas'))),
                ],
              ),
              const SizedBox(height: 20),

              if (_tipoInsulinaInyeccion == 'Basal' || _tipoInsulinaInyeccion == 'Ambas') ...[
                _crearTarjetaGlass(
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Insulina Basal (Larga duración)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      const Text('Mantiene tu glucosa estable en ayunas.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 15),
                      _crearCampoTexto(titulo: 'Marca (Ej. Lantus, Tresiba)', hint: 'Escribe la marca', controlador: _insulinaBasalMarcaCtrl, esNumero: false),
                      const SizedBox(height: 15),
                      _crearCampoTexto(titulo: 'Dosis Fija Diaria (Unidades)', hint: 'Ej. 20', controlador: _insulinaBasalDosisCtrl, esNumero: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_tipoInsulinaInyeccion == 'Bolo' || _tipoInsulinaInyeccion == 'Ambas') ...[
                _crearTarjetaGlass(
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Insulina de Bolo (Acción rápida)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      const Text('Para cubrir comidas o corregir niveles altos.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 15),
                      _crearCampoTexto(titulo: 'Marca (Ej. Humalog, Novolog)', hint: 'Escribe la marca', controlador: _insulinaRapidaMarcaCtrl, esNumero: false),
                      const SizedBox(height: 15),
                      _crearCampoTexto(titulo: 'Patrón de uso', hint: 'Ej. 5 U por comida...', controlador: _insulinaRapidaPatronCtrl, esNumero: false),
                    ],
                  ),
                ),
              ],

            ] else if (_metodoInsulina == 'Bomba') ...[
              _crearCampoTexto(titulo: 'Unidades Base', hint: 'Ej. 0.5 U/hr', controlador: _bombaUnidadesCtrl, esNumero: false),
              const SizedBox(height: 20),
              _crearCampoTexto(titulo: 'Frecuencia / Configuración', hint: 'Ej. Liberación continua...', controlador: _bombaFrecuenciaCtrl, esNumero: false),
            ],
            const SizedBox(height: 30),
          ] else ...[
            const Text('Medicamento Principal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            _crearCampoTexto(titulo: 'Nombre', hint: 'Ej. Metformina', controlador: _medOralNombreCtrl, esNumero: false),
            const SizedBox(height: 20),
            _crearCampoTexto(titulo: 'Dosis y Frecuencia', hint: 'Ej. 850mg cada 12 hrs', controlador: _medOralDosisCtrl, esNumero: false),
            const SizedBox(height: 30),
          ],

          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Otros Medicamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  const Text('Para presión, colesterol, suplementos, etc.', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                  const SizedBox(height: 20),

                  if (_otrosMedicamentos.isNotEmpty) ...[
                    ..._otrosMedicamentos.asMap().entries.map((entry) {
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
                                    Text('${med['nombre']} ${med['gramaje']}mg', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 3),
                                    Text('${med['proposito']} • ${med['frecuencia']}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                  ],
                                )
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF008CCF)),
                              onPressed: () => _editarMedicamento(idx),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                              onPressed: () => setState(() => _otrosMedicamentos.removeAt(idx)),
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
                    child: _mostrarFormularioOtroMed
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
                          const Text('Detalles del Medicamento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(flex: 2, child: _crearCampoTexto(titulo: 'Nombre', hint: 'Ej. Losartán', controlador: _otroMedNombreCtrl, esNumero: false)),
                              const SizedBox(width: 15),
                              Expanded(flex: 1, child: _crearCampoTexto(titulo: 'Gramaje', hint: 'Ej. 50', controlador: _otroMedGramajeCtrl, esNumero: true)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _crearCampoTexto(titulo: '¿Para qué es?', hint: 'Ej. Presión', controlador: _otroMedPropositoCtrl, esNumero: false),
                          const SizedBox(height: 15),
                          _crearCampoTexto(titulo: 'Frecuencia', hint: 'Ej. 1 al día', controlador: _otroMedFrecuenciaCtrl, esNumero: false),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _limpiarYOCultarFormulario,
                                child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _guardarMedicamento,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00D1FF),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Text(_indiceEditando != null ? 'Actualizar' : 'Guardar', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                        : Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() { _mostrarFormularioOtroMed = true; _indiceEditando = null; }),
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00D1FF)),
                        label: const Text('Añadir medicamento', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              )
          ),
          const SizedBox(height: 30),

          const Text('Protocolo de Monitoreo de Glucosa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          const Text('¿Cada cuánto te indicó el médico medir tu azúcar?', style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 10),
          _crearDropdown(
              valorActual: _frecuenciaMonitoreo,
              hint: 'Selecciona una frecuencia',
              opciones: _opcionesMonitoreo,
              onChange: (val) => setState(() => _frecuenciaMonitoreo = val)
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _frecuenciaMonitoreo == 'Otro protocolo'
                ? Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: _crearCampoTexto(
                  titulo: 'Especifica tu protocolo',
                  hint: 'Ej. Cada 4 horas / Madrugada',
                  controlador: _otroMonitoreoCtrl,
                  esNumero: false
              ),
            )
                : const SizedBox.shrink(),
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
  Widget _construirFase4EstiloVida() {
    bool fase4Completa = _actividadFisica != null &&
        _emergenciaNombreCtrl.text.isNotEmpty &&
        _emergenciaParentescoCtrl.text.isNotEmpty &&
        _emergenciaTelefonoCtrl.text.isNotEmpty &&
        _medicoNombreCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estilo de Vida y Seguridad', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 4 de 5', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nivel de Actividad Física', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  const Text('El ejercicio aumenta la sensibilidad a la insulina, usaremos esto para ajustar sugerencias.', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                  const SizedBox(height: 15),
                  _crearDropdown(
                      valorActual: _actividadFisica,
                      hint: 'Selecciona tu nivel',
                      opciones: _opcionesActividad,
                      onChange: (val) => setState(() => _actividadFisica = val)
                  ),
                ],
              )
          ),
          const SizedBox(height: 20),

          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.emergency, color: Color(0xFFFF6B6B)),
                      SizedBox(width: 10),
                      Text('Contacto de Emergencia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _crearCampoTexto(titulo: 'Nombre del contacto', hint: 'Ej. María Pérez', controlador: _emergenciaNombreCtrl, esNumero: false),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(flex: 1, child: _crearCampoTexto(titulo: 'Parentesco', hint: 'Ej. Madre', controlador: _emergenciaParentescoCtrl, esNumero: false)),
                      const SizedBox(width: 15),
                      Expanded(flex: 2, child: _crearCampoTexto(titulo: 'Teléfono', hint: '10 dígitos', controlador: _emergenciaTelefonoCtrl, esNumero: true)),
                    ],
                  ),
                ],
              )
          ),
          const SizedBox(height: 20),

          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.medical_information, color: Color(0xFF00D1FF)),
                      SizedBox(width: 10),
                      Text('Médico Tratante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('¿A quién irán dirigidos tus reportes clínicos?', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                  const SizedBox(height: 20),
                  _crearCampoTexto(titulo: 'Nombre completo del Médico', hint: 'Ej. Dr. Roberto Gómez', controlador: _medicoNombreCtrl, esNumero: false),
                ],
              )
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase4Completa ? _siguientePaso : null,
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

  Widget _construirFase5Identificacion() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.badge, size: 60, color: Colors.white),
          const SizedBox(height: 20),
          const Text('Identificación Médica', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 5 de 5', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          _crearTarjetaGlass(
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('¿Por qué es vital?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text(
                  'Las directrices de la ADA (Asociación Americana de Diabetes) establecen que toda persona con diabetes debe portar una identificación médica visible.  En caso de una emergencia donde el paciente no pueda comunicarse, esto puede salvar tu vida indicando a los paramédicos cómo actuar.',
                  style: TextStyle(fontSize: 15, color: Color(0xFFE8E8E8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          const Text('¿Deseas configurar tu Identificación Médica de Emergencia ahora?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () {
                _guardarDatosPacienteYFinalizar(irAIdentificacion: true);
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
                _guardarDatosPacienteYFinalizar(irAIdentificacion: false);
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

  Widget _crearChipSeleccion(String texto, bool seleccionado, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF00D1FF).withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: seleccionado ? const Color(0xFF00D1FF) : const Color(0xFFD2D2D2), width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
            texto,
            style: TextStyle(color: seleccionado ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
        ),
      ),
    );
  }

  Widget _crearCampoTexto({required String titulo, required String hint, required TextEditingController controlador, required bool esNumero, bool activo = true, FocusNode? focusNode}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: activo ? Colors.white : Colors.grey)),
        const SizedBox(height: 5),
        TextField(
          controller: controlador,
          focusNode: focusNode,
          enabled: activo,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          inputFormatters: esNumero ? [FilteringTextInputFormatter.digitsOnly] : [],
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: Color(0xFF848282)),
            filled: true, fillColor: activo ? Colors.white : Colors.grey.shade300,
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

class PantallaCuestionarioCuidador extends StatefulWidget {
  const PantallaCuestionarioCuidador({super.key});

  @override
  State<PantallaCuestionarioCuidador> createState() => _PantallaCuestionarioCuidadorState();
}

class _PantallaCuestionarioCuidadorState extends State<PantallaCuestionarioCuidador> {
  final PageController _pageController = PageController();
  int _pasoActual = 0;
  final int _totalPasos = 7;
  bool _aceptoTerminos = false;

  String? _tipoPaciente;
  final TextEditingController _parentescoCtrl = TextEditingController();
  final TextEditingController _nombrePacienteCtrl = TextEditingController();

  String? _sexoPaciente;
  final TextEditingController _edadPacienteCtrl = TextEditingController();
  String? _tiempoDxPaciente;
  String? _tipoDiabetesPaciente;
  final TextEditingController _alergiasPacienteCtrl = TextEditingController();
  final TextEditingController _hospitalizacionesCtrl = TextEditingController();
  final TextEditingController _pesoPacienteCtrl = TextEditingController();
  final TextEditingController _alturaPacienteCtrl = TextEditingController();

  final FocusNode _pesoFocus = FocusNode();
  final FocusNode _alturaFocus = FocusNode();

  double _imcPaciente = 0.0;

  final TextEditingController _hipoCtrl = TextEditingController(text: '70');
  final TextEditingController _hiperCtrl = TextEditingController(text: '180');
  final TextEditingController _rangoMinCtrl = TextEditingController(text: '80');
  final TextEditingController _rangoMaxCtrl = TextEditingController(text: '130');
  final TextEditingController _fsiCtrl = TextEditingController(text: '50');
  final TextEditingController _ricCtrl = TextEditingController(text: '15');

  String? _metodoInsulinaPaciente;
  String? _tipoInsulinaInyeccionPaciente;

  final TextEditingController _insulinaBasalMarcaCtrl = TextEditingController();
  final TextEditingController _insulinaBasalDosisCtrl = TextEditingController();
  final TextEditingController _insulinaRapidaMarcaCtrl = TextEditingController();
  final TextEditingController _insulinaRapidaPatronCtrl = TextEditingController();
  final TextEditingController _bombaUnidadesCtrl = TextEditingController();
  final TextEditingController _bombaFrecuenciaCtrl = TextEditingController();
  final TextEditingController _medOralNombreCtrl = TextEditingController();
  final TextEditingController _medOralDosisCtrl = TextEditingController();

  final TextEditingController _otroMedNombreCtrl = TextEditingController();
  final TextEditingController _otroMedGramajeCtrl = TextEditingController();
  final TextEditingController _otroMedPropositoCtrl = TextEditingController();
  final TextEditingController _otroMedFrecuenciaCtrl = TextEditingController();

  List<Map<String, String>> _otrosMedicamentos = [];
  bool _mostrarFormularioOtroMed = false;
  int? _indiceEditando;
  String? _frecuenciaMonitoreoPaciente;
  final TextEditingController _otroMonitoreoCtrl = TextEditingController();

  // Variables Estilo de Vida y Seguridad
  final TextEditingController _medicoNombreCtrl = TextEditingController();
  String? _riesgoCaidas;
  String? _estadoCognitivo;
  String? _autonomiaMenor;
  final TextEditingController _contactoEscolarCtrl = TextEditingController();
  final List<String> _opcionesTiempoDx = ['Menos de 1 año', '1 a 5 años', '5 a 10 años', 'Más de 10 años'];
  final List<String> _opcionesTipoDiabetes = ['Tipo 1', 'Tipo 2', 'Gestacional', 'LADA / Otro'];
  final List<String> _opcionesMonitoreo = [
    'Ayunas y antes de comidas',
    'Al despertar y antes de dormir',
    'Antes y después de comer',
    'Solo si hay síntomas',
    'Monitoreo continuo (Sensor)',
    'Otro protocolo'
  ];
  final List<String> _opcionesRiesgoCaidas = ['Sí usa', 'No usa'];
  final List<String> _opcionesEstadoCognitivo = ['Sí', 'A veces', 'No'];

  @override
  void initState() {
    super.initState();
    _pesoFocus.addListener(() {
      if (!_pesoFocus.hasFocus) _calcularIMCPaciente();
    });
    _alturaFocus.addListener(() {
      if (!_alturaFocus.hasFocus) _calcularIMCPaciente();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _parentescoCtrl.dispose();
    _nombrePacienteCtrl.dispose();
    _edadPacienteCtrl.dispose();
    _alergiasPacienteCtrl.dispose();
    _hospitalizacionesCtrl.dispose();
    _pesoPacienteCtrl.dispose();
    _alturaPacienteCtrl.dispose();
    _pesoFocus.dispose();
    _alturaFocus.dispose();
    _hipoCtrl.dispose();
    _hiperCtrl.dispose();
    _rangoMinCtrl.dispose();
    _rangoMaxCtrl.dispose();
    _fsiCtrl.dispose();
    _ricCtrl.dispose();
    _insulinaBasalMarcaCtrl.dispose();
    _insulinaBasalDosisCtrl.dispose();
    _insulinaRapidaMarcaCtrl.dispose();
    _insulinaRapidaPatronCtrl.dispose();
    _bombaUnidadesCtrl.dispose();
    _bombaFrecuenciaCtrl.dispose();
    _medOralNombreCtrl.dispose();
    _medOralDosisCtrl.dispose();
    _otroMedNombreCtrl.dispose();
    _otroMedGramajeCtrl.dispose();
    _otroMedPropositoCtrl.dispose();
    _otroMedFrecuenciaCtrl.dispose();
    _otroMonitoreoCtrl.dispose();
    _medicoNombreCtrl.dispose();
    _contactoEscolarCtrl.dispose();
    super.dispose();
  }

  void _calcularIMCPaciente() {
    if (_pesoPacienteCtrl.text.isNotEmpty && _alturaPacienteCtrl.text.isNotEmpty) {
      double? peso = double.tryParse(_pesoPacienteCtrl.text);
      double? alturaCm = double.tryParse(_alturaPacienteCtrl.text);

      if (peso != null && alturaCm != null && alturaCm > 0) {
        double alturaMetros = alturaCm / 100;
        setState(() {
          _imcPaciente = peso / (alturaMetros * alturaMetros);
        });
      }
    } else {
      setState(() { _imcPaciente = 0.0; });
    }
  }

  void _guardarMedicamento() {
    if (_otroMedNombreCtrl.text.isNotEmpty && _otroMedGramajeCtrl.text.isNotEmpty) {
      setState(() {
        if (_indiceEditando != null) {
          _otrosMedicamentos[_indiceEditando!] = {
            'nombre': _otroMedNombreCtrl.text,
            'gramaje': _otroMedGramajeCtrl.text,
            'proposito': _otroMedPropositoCtrl.text,
            'frecuencia': _otroMedFrecuenciaCtrl.text,
          };
        } else {
          _otrosMedicamentos.add({
            'nombre': _otroMedNombreCtrl.text,
            'gramaje': _otroMedGramajeCtrl.text,
            'proposito': _otroMedPropositoCtrl.text,
            'frecuencia': _otroMedFrecuenciaCtrl.text,
          });
        }
        _limpiarYOCultarFormulario();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre y el gramaje son obligatorios.')),
      );
    }
  }

  void _editarMedicamento(int index) {
    setState(() {
      final med = _otrosMedicamentos[index];
      _otroMedNombreCtrl.text = med['nombre'] ?? '';
      _otroMedGramajeCtrl.text = med['gramaje'] ?? '';
      _otroMedPropositoCtrl.text = med['proposito'] ?? '';
      _otroMedFrecuenciaCtrl.text = med['frecuencia'] ?? '';

      _indiceEditando = index;
      _mostrarFormularioOtroMed = true;
    });
  }

  void _limpiarYOCultarFormulario() {
    setState(() {
      _otroMedNombreCtrl.clear();
      _otroMedGramajeCtrl.clear();
      _otroMedPropositoCtrl.clear();
      _otroMedFrecuenciaCtrl.clear();
      _indiceEditando = null;
      _mostrarFormularioOtroMed = false;
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

  Future<void> _guardarDatosPacienteYFinalizar({bool irAIdentificacion = false}) async {
    final db = DatabaseHelper();
    final usuarioId = await db.obtenerSesionActiva();
    String nombreCuidador = 'Cuidador';

    if (_metodoInsulinaPaciente != 'Inyecciones') {
      _insulinaBasalMarcaCtrl.clear();
      _insulinaBasalDosisCtrl.clear();
      _insulinaRapidaMarcaCtrl.clear();
      _insulinaRapidaPatronCtrl.clear();
    } else {
      if (_tipoInsulinaInyeccionPaciente == 'Basal') {
        _insulinaRapidaMarcaCtrl.clear();
        _insulinaRapidaPatronCtrl.clear();
      } else if (_tipoInsulinaInyeccionPaciente == 'Bolo') {
        _insulinaBasalMarcaCtrl.clear();
        _insulinaBasalDosisCtrl.clear();
      }
    }

    if (_metodoInsulinaPaciente != 'Bomba') {
      _bombaUnidadesCtrl.clear();
      _bombaFrecuenciaCtrl.clear();
    }

    try {
      if (usuarioId != null) {
        final pacienteData = {
          'cuidador_id': usuarioId,
          'tipo_paciente': _tipoPaciente ?? '',
          'parentesco': _parentescoCtrl.text,
          'nombre': _nombrePacienteCtrl.text,
          'sexo': _sexoPaciente ?? '',
          'edad': int.tryParse(_edadPacienteCtrl.text) ?? 0,
          'tiempo_dx': _tiempoDxPaciente ?? '',
          'tipo_diabetes': _tipoDiabetesPaciente ?? '',
          'alergias': _alergiasPacienteCtrl.text,
          'hospitalizaciones': _hospitalizacionesCtrl.text.isEmpty ? 'Ninguna' : _hospitalizacionesCtrl.text,
          'peso': double.tryParse(_pesoPacienteCtrl.text) ?? 0.0,
          'altura': double.tryParse(_alturaPacienteCtrl.text) ?? 0.0,
          'imc': _imcPaciente,
          'limite_hipo': double.tryParse(_hipoCtrl.text) ?? 70.0,
          'limite_hiper': double.tryParse(_hiperCtrl.text) ?? 180.0,
          'rango_min': double.tryParse(_rangoMinCtrl.text) ?? 80.0,
          'rango_max': double.tryParse(_rangoMaxCtrl.text) ?? 130.0,
          'metodo_insulina': _metodoInsulinaPaciente ?? '',
          'insulina_basal_marca': _insulinaBasalMarcaCtrl.text,
          'insulina_basal_dosis': _insulinaBasalDosisCtrl.text,
          'insulina_rapida_marca': _insulinaRapidaMarcaCtrl.text,
          'insulina_rapida_patron': _insulinaRapidaPatronCtrl.text,
          'bomba_unidades': _bombaUnidadesCtrl.text,
          'bomba_frecuencia': _bombaFrecuenciaCtrl.text,
          'med_oral_nombre': _medOralNombreCtrl.text,
          'med_oral_dosis': _medOralDosisCtrl.text,
          'frecuencia_monitoreo': _frecuenciaMonitoreoPaciente ?? '',
          'medico_nombre': _medicoNombreCtrl.text,
          'riesgo_caidas': _riesgoCaidas ?? '',
          'estado_cognitivo': _estadoCognitivo ?? '',
          'autonomia_menor': _autonomiaMenor ?? '',
          'contacto_escolar': _contactoEscolarCtrl.text,
        };

        final pacienteId = await db.insertarPacienteCuidador(pacienteData);

        for (var med in _otrosMedicamentos) {
          await db.insertarOtroMedicamentoCuidador({
            'paciente_cuidador_id': pacienteId,
            'nombre': med['nombre'],
            'gramaje': med['gramaje'],
            'proposito': med['proposito'],
            'frecuencia': med['frecuencia'],
          });
        }

        final usuario = await db.obtenerUsuarioPorId(usuarioId);
        if (usuario != null) {
          nombreCuidador = usuario['nombre'] as String;
        }
      }
    } catch (e) {
      debugPrint('Error guardando cuidador: $e');
    }

    if (!mounted) return;

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
      _mostrarDialogoFinalizacion(nombreCuidador);
    }
  }

  void _mostrarDialogoFinalizacion(String nombreCuidador) {
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
                  _construirFase0Advertencias(),
                  _construirFase1TipoPaciente(),
                  _construirFase2PerfilPaciente(),
                  _construirFase3Parametros(),
                  _construirFase4Medicacion(),
                  _construirFase5EstiloVida(),
                  _construirFase6Identificacion(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFase0Advertencias() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety, size: 60, color: Colors.white),
          const SizedBox(height: 20),
          const Text('Bienvenido Cuidador', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          _crearTarjetaGlass(
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('¿Por qué pedimos estos datos?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text(
                  'Para ayudarte a brindar el mejor cuidado, Insul App necesita conocer el perfil clínico de la persona a tu cargo. Esto nos permitirá ajustar las alertas, recordatorios y protocolos de acción.',
                  style: TextStyle(fontSize: 15, color: Color(0xFFE8E8E8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _crearTarjetaGlass(
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Aviso Médico Importante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text(
                  'Esta aplicación es una herramienta de apoyo para tu labor diaria. NO sustituye la consulta médica ni emite diagnósticos. Todas las decisiones críticas deben basarse en las indicaciones del médico tratante.',
                  style: TextStyle(fontSize: 15, color: Color(0xFFE8E8E8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Checkbox(
                value: _aceptoTerminos,
                activeColor: const Color(0xFF00D1FF),
                checkColor: const Color(0xFF1C63BB),
                side: const BorderSide(color: Colors.white, width: 2),
                onChanged: (val) {
                  setState(() { _aceptoTerminos = val ?? false; });
                },
              ),
              const Expanded(
                child: Text('He leído y comprendo mi responsabilidad al usar la app.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _aceptoTerminos ? _siguientePaso : null,
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

  Widget _construirFase1TipoPaciente() {
    bool fase1Completa = _tipoPaciente != null && _parentescoCtrl.text.isNotEmpty && _nombrePacienteCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Datos Generales del Paciente', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 1 de 6', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          const Text('¿A quién estás cuidando?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 15),

          _crearOpcionPaciente(
            titulo: 'Adulto Mayor',
            icono: Icons.elderly,
            seleccionado: _tipoPaciente == 'Adulto Mayor',
            onTap: () => setState(() => _tipoPaciente = 'Adulto Mayor'),
          ),
          const SizedBox(height: 10),
          _crearOpcionPaciente(
            titulo: 'Menor de Edad / Niño',
            icono: Icons.child_care,
            seleccionado: _tipoPaciente == 'Menor de Edad',
            onTap: () => setState(() => _tipoPaciente = 'Menor de Edad'),
          ),
          const SizedBox(height: 10),
          _crearOpcionPaciente(
            titulo: 'Persona con Discapacidad',
            icono: Icons.accessible,
            seleccionado: _tipoPaciente == 'Discapacidad',
            onTap: () => setState(() => _tipoPaciente = 'Discapacidad'),
          ),
          const SizedBox(height: 30),

          _crearCampoTexto(
              titulo: 'Tu parentesco o relación con el paciente',
              hint: 'Ej. Hijo, Madre, Enfermero particular...',
              controlador: _parentescoCtrl,
              esNumero: false
          ),
          const SizedBox(height: 20),
          _crearCampoTexto(
              titulo: 'Nombre del paciente',
              hint: 'Ej. Juan Pérez',
              controlador: _nombrePacienteCtrl,
              esNumero: false
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

  Widget _construirFase2PerfilPaciente() {
    bool fase2Completa = _sexoPaciente != null && _edadPacienteCtrl.text.isNotEmpty && _tiempoDxPaciente != null && _tipoDiabetesPaciente != null && _pesoPacienteCtrl.text.isNotEmpty && _alturaPacienteCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Perfil Clínico del Paciente', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 2 de 6', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          const Text('Sexo Biológico del Paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _crearChipSeleccion('Hombre', _sexoPaciente == 'Hombre', () => setState(() => _sexoPaciente = 'Hombre'))),
              const SizedBox(width: 15),
              Expanded(child: _crearChipSeleccion('Mujer', _sexoPaciente == 'Mujer', () => setState(() => _sexoPaciente = 'Mujer'))),
            ],
          ),
          const SizedBox(height: 20),

          _crearCampoTexto(titulo: 'Edad del Paciente', hint: 'Años', controlador: _edadPacienteCtrl, esNumero: true),
          const SizedBox(height: 3),

          const Text('Tiempo con diagnóstico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 5),
          _crearDropdown(valorActual: _tiempoDxPaciente, hint: 'Selecciona una opción', opciones: _opcionesTiempoDx, onChange: (val) => setState(() => _tiempoDxPaciente = val)),
          const SizedBox(height: 20),

          const Text('Tipo de Diabetes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 5),
          _crearDropdown(valorActual: _tipoDiabetesPaciente, hint: 'Ej. Tipo 1', opciones: _opcionesTipoDiabetes, onChange: (val) => setState(() => _tipoDiabetesPaciente = val)),
          const SizedBox(height: 20),

          _crearCampoTexto(titulo: 'Alergias Conocidas (Opcional)', hint: 'Ej. Penicilina, Ninguna', controlador: _alergiasPacienteCtrl, esNumero: false),
          const SizedBox(height: 20),

          _crearCampoTexto(titulo: 'Hospitalizaciones Recientes (Opcional)', hint: 'Ej. Ninguna', controlador: _hospitalizacionesCtrl, esNumero: false),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _crearCampoTexto(titulo: 'Peso (kg)', hint: 'Ej. 75', controlador: _pesoPacienteCtrl, esNumero: true, focusNode: _pesoFocus)),
              const SizedBox(width: 15),
              Expanded(child: _crearCampoTexto(titulo: 'Altura (cm)', hint: 'Ej. 170', controlador: _alturaPacienteCtrl, esNumero: true, focusNode: _alturaFocus)),
            ],
          ),
          const SizedBox(height: 15),

          _crearTarjetaGlass(
              hijo: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('I.M.C. del Paciente:', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                    _imcPaciente > 0 ? _imcPaciente.toStringAsFixed(1) : '--',
                    style: const TextStyle(fontSize: 24, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold),
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

  Widget _construirFase3Parametros() {
    bool fase3Completa = _hipoCtrl.text.isNotEmpty && _hiperCtrl.text.isNotEmpty && _rangoMinCtrl.text.isNotEmpty && _rangoMaxCtrl.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Parámetros de Control', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 3 de 6', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),

          _crearTarjetaGlass(
            hijo: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF00D1FF), size: 30),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    'Los valores por defecto están basados en las Guías Oficiales de la ADA. Puedes modificarlos si el médico del paciente indicó rangos distintos.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          _construirGraficoGlucosa(),
          const SizedBox(height: 30),

          _crearCampoTexto(titulo: 'Límite de Hipoglucemia (mg/dL)', hint: 'Ej. 70', controlador: _hipoCtrl, esNumero: true),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
            child: Text('⚠️ Debajo de este valor, la app disparará el protocolo de acción inmediata para el paciente.', style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 13)),
          ),

          _crearCampoTexto(titulo: 'Límite de Hiperglucemia (mg/dL)', hint: 'Ej. 180', controlador: _hiperCtrl, esNumero: true),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
            child: Text('⚠️ Por encima de este valor, se activarán las alertas de control.', style: TextStyle(color: Color(0xFFFFB347), fontSize: 13)),
          ),

          const Text('Rangos Normales Objetivo (mg/dL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _crearCampoTexto(titulo: 'Mínimo', hint: '80', controlador: _rangoMinCtrl, esNumero: true)),
              const SizedBox(width: 15),
              Expanded(child: _crearCampoTexto(titulo: 'Máximo', hint: '130', controlador: _rangoMaxCtrl, esNumero: true)),
            ],
          ),
          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(15)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Configuración Avanzada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _crearCampoTexto(titulo: 'Factor de Sensibilidad (FSI)', hint: 'Ej. 50', controlador: _fsiCtrl, esNumero: true, activo: true),
                const SizedBox(height: 10),
                _crearCampoTexto(titulo: 'Relación Insulina/Carbos (RIC)', hint: 'Ej. 15', controlador: _ricCtrl, esNumero: true, activo: true),
              ],
            ),
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

  Widget _construirGraficoGlucosa() {
    String hipo = _hipoCtrl.text.isEmpty ? '--' : _hipoCtrl.text;
    String rMin = _rangoMinCtrl.text.isEmpty ? '--' : _rangoMinCtrl.text;
    String rMax = _rangoMaxCtrl.text.isEmpty ? '--' : _rangoMaxCtrl.text;
    String hiper = _hiperCtrl.text.isEmpty ? '--' : _hiperCtrl.text;

    return _crearTarjetaGlass(
        hijo: Column(
          children: [
            const Text('Espectro de Glucosa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
            const SizedBox(height: 20),
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
                      Text('< $hipo', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
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
                      Text('$rMin - $rMax', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
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
                      Text('> $hiper', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            )
          ],
        )
    );
  }

  Widget _construirFase4Medicacion() {
    bool fase4Completa = _frecuenciaMonitoreoPaciente != null &&
        (_frecuenciaMonitoreoPaciente != 'Otro protocolo' || _otroMonitoreoCtrl.text.isNotEmpty);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Medicación del Paciente', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 4 de 6', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          if (_tipoDiabetesPaciente == 'Tipo 1') ...[
            const Text('Método de aplicación de Insulina', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _crearChipSeleccion('Inyecciones', _metodoInsulinaPaciente == 'Inyecciones', () => setState(() => _metodoInsulinaPaciente = 'Inyecciones'))),
                const SizedBox(width: 15),
                Expanded(child: _crearChipSeleccion('Bomba', _metodoInsulinaPaciente == 'Bomba', () => setState(() => _metodoInsulinaPaciente = 'Bomba'))),
              ],
            ),
            const SizedBox(height: 20),

            if (_metodoInsulinaPaciente == 'Inyecciones') ...[
              const Text('Tipo de Insulina', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _crearChipSeleccion('Basal', _tipoInsulinaInyeccionPaciente == 'Basal', () => setState(() => _tipoInsulinaInyeccionPaciente = 'Basal'))),
                  const SizedBox(width: 10),
                  Expanded(child: _crearChipSeleccion('Bolo', _tipoInsulinaInyeccionPaciente == 'Bolo', () => setState(() => _tipoInsulinaInyeccionPaciente = 'Bolo'))),
                  const SizedBox(width: 10),
                  Expanded(child: _crearChipSeleccion('Ambas', _tipoInsulinaInyeccionPaciente == 'Ambas', () => setState(() => _tipoInsulinaInyeccionPaciente = 'Ambas'))),
                ],
              ),
              const SizedBox(height: 20),

              if (_tipoInsulinaInyeccionPaciente == 'Basal' || _tipoInsulinaInyeccionPaciente == 'Ambas') ...[
                _crearTarjetaGlass(
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Insulina Basal (Larga duración)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      const Text('Mantiene la glucosa del paciente estable en ayunas.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 15),
                      _crearCampoTexto(titulo: 'Marca (Ej. Lantus, Tresiba)', hint: 'Escribe la marca', controlador: _insulinaBasalMarcaCtrl, esNumero: false),
                      const SizedBox(height: 15),
                      _crearCampoTexto(titulo: 'Dosis Fija Diaria (Unidades)', hint: 'Ej. 20', controlador: _insulinaBasalDosisCtrl, esNumero: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_tipoInsulinaInyeccionPaciente == 'Bolo' || _tipoInsulinaInyeccionPaciente == 'Ambas') ...[
                _crearTarjetaGlass(
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Insulina de Bolo (Acción rápida)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      const Text('Para cubrir comidas o corregir niveles altos.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 15),
                      _crearCampoTexto(titulo: 'Marca (Ej. Humalog, Novolog)', hint: 'Escribe la marca', controlador: _insulinaRapidaMarcaCtrl, esNumero: false),
                      const SizedBox(height: 15),
                      _crearCampoTexto(titulo: 'Patrón de uso', hint: 'Ej. 5 U por comida...', controlador: _insulinaRapidaPatronCtrl, esNumero: false),
                    ],
                  ),
                ),
              ],
            ] else if (_metodoInsulinaPaciente == 'Bomba') ...[
              _crearCampoTexto(titulo: 'Unidades Base', hint: 'Ej. 0.5 U/hr', controlador: _bombaUnidadesCtrl, esNumero: false),
              const SizedBox(height: 20),
              _crearCampoTexto(titulo: 'Frecuencia / Configuración', hint: 'Ej. Liberación continua...', controlador: _bombaFrecuenciaCtrl, esNumero: false),
            ],
            const SizedBox(height: 30),
          ] else ...[
            const Text('Medicamento Principal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            _crearCampoTexto(titulo: 'Nombre', hint: 'Ej. Metformina', controlador: _medOralNombreCtrl, esNumero: false),
            const SizedBox(height: 20),
            _crearCampoTexto(titulo: 'Dosis y Frecuencia', hint: 'Ej. 850mg cada 12 hrs', controlador: _medOralDosisCtrl, esNumero: false),
            const SizedBox(height: 30),
          ],

          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Otros Medicamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  const Text('Para presión, colesterol, suplementos, etc.', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                  const SizedBox(height: 20),

                  if (_otrosMedicamentos.isNotEmpty) ...[
                    ..._otrosMedicamentos.asMap().entries.map((entry) {
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
                                    Text('${med['nombre']} ${med['gramaje']}mg', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 3),
                                    Text('${med['proposito']} • ${med['frecuencia']}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                  ],
                                )
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF008CCF)),
                              onPressed: () => _editarMedicamento(idx),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                              onPressed: () => setState(() => _otrosMedicamentos.removeAt(idx)),
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
                    child: _mostrarFormularioOtroMed
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
                          const Text('Detalles del Medicamento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(flex: 2, child: _crearCampoTexto(titulo: 'Nombre', hint: 'Ej. Losartán', controlador: _otroMedNombreCtrl, esNumero: false)),
                              const SizedBox(width: 15),
                              Expanded(flex: 1, child: _crearCampoTexto(titulo: 'Gramaje', hint: 'Ej. 50', controlador: _otroMedGramajeCtrl, esNumero: true)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _crearCampoTexto(titulo: '¿Para qué es?', hint: 'Ej. Presión', controlador: _otroMedPropositoCtrl, esNumero: false),
                          const SizedBox(height: 15),
                          _crearCampoTexto(titulo: 'Frecuencia', hint: 'Ej. 1 al día', controlador: _otroMedFrecuenciaCtrl, esNumero: false),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _limpiarYOCultarFormulario,
                                child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _guardarMedicamento,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00D1FF),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Text(_indiceEditando != null ? 'Actualizar' : 'Guardar', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                        : Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() { _mostrarFormularioOtroMed = true; _indiceEditando = null; }),
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00D1FF)),
                        label: const Text('Añadir medicamento', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              )
          ),
          const SizedBox(height: 30),

          const Text('Protocolo de Monitoreo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          const Text('¿Cada cuánto indicó el médico medir el azúcar del paciente?', style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 10),
          _crearDropdown(
              valorActual: _frecuenciaMonitoreoPaciente,
              hint: 'Selecciona una frecuencia',
              opciones: _opcionesMonitoreo,
              onChange: (val) => setState(() => _frecuenciaMonitoreoPaciente = val)
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _frecuenciaMonitoreoPaciente == 'Otro protocolo'
                ? Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: _crearCampoTexto(
                  titulo: 'Especifica el protocolo',
                  hint: 'Ej. Cada 4 horas / Madrugada',
                  controlador: _otroMonitoreoCtrl,
                  esNumero: false
              ),
            )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase4Completa ? _siguientePaso : null,
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

  Widget _construirFase5EstiloVida() {
    bool fase5Completa = _medicoNombreCtrl.text.isNotEmpty;

    if (_tipoPaciente == 'Adulto Mayor') {
      fase5Completa = fase5Completa && _riesgoCaidas != null && _estadoCognitivo != null;
    } else if (_tipoPaciente == 'Menor de Edad') {
      fase5Completa = fase5Completa && _autonomiaMenor != null && _contactoEscolarCtrl.text.isNotEmpty;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estilo de Vida y Seguridad', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          const Text('Paso 5 de 6', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.shield_outlined, color: Color(0xFF00D1FF), size: 28),
                      SizedBox(width: 10),
                      Text('Seguridad y Vigilancia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Como cuidador, eres el pilar principal. Mantén las notificaciones de Insul App activadas y verifica constantemente el estado del paciente. La tecnología es un apoyo, pero tu atención es insustituible.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              )
          ),
          const SizedBox(height: 25),
          _crearTarjetaGlass(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Médico Tratante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  const Text('¿A quién irán dirigidos los reportes clínicos?', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                  const SizedBox(height: 20),
                  _crearCampoTexto(titulo: 'Nombre completo del Médico', hint: 'Ej. Dra. Carmen Ruiz', controlador: _medicoNombreCtrl, esNumero: false),
                ],
              )
          ),
          const SizedBox(height: 25),
          if (_tipoPaciente == 'Adulto Mayor') ...[
            _crearTarjetaGlass(
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Consideraciones del Adulto Mayor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 20),

                    const Text('Riesgo de Caídas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 5),
                    const Text('¿El paciente usa andadera, bastón o silla de ruedas? (Una baja de azúcar causa mareos y puede ser crítico).', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                    const SizedBox(height: 10),
                    _crearDropdown(
                        valorActual: _riesgoCaidas,
                        hint: 'Selecciona opción',
                        opciones: _opcionesRiesgoCaidas,
                        onChange: (val) => setState(() => _riesgoCaidas = val)
                    ),
                    const SizedBox(height: 20),

                    const Text('Estado Cognitivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 5),
                    const Text('¿El paciente es capaz de avisar verbalmente si se siente mal?', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                    const SizedBox(height: 10),
                    _crearDropdown(
                        valorActual: _estadoCognitivo,
                        hint: 'Selecciona opción',
                        opciones: _opcionesEstadoCognitivo,
                        onChange: (val) => setState(() => _estadoCognitivo = val)
                    ),
                  ],
                )
            ),
            const SizedBox(height: 40),
          ],
          if (_tipoPaciente == 'Menor de Edad') ...[
            _crearTarjetaGlass(
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Consideraciones del Menor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 20),

                    const Text('Autonomía', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 5),
                    const Text('¿El niño ya reconoce sus propios síntomas cuando se le baja el azúcar?', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _crearChipSeleccion('Sí', _autonomiaMenor == 'Sí', () => setState(() => _autonomiaMenor = 'Sí'))),
                        const SizedBox(width: 15),
                        Expanded(child: _crearChipSeleccion('Aún no', _autonomiaMenor == 'Aún no', () => setState(() => _autonomiaMenor = 'Aún no'))),
                      ],
                    ),
                    const SizedBox(height: 25),

                    const Text('Contacto Escolar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 5),
                    const Text('Solicitamos el teléfono de la escuela o maestro para generar un "Protocolo de Emergencia Escolar" en el futuro.', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                    const SizedBox(height: 10),
                    _crearCampoTexto(titulo: 'Teléfono', hint: '10 dígitos', controlador: _contactoEscolarCtrl, esNumero: true),
                  ],
                )
            ),
            const SizedBox(height: 40),
          ],

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: fase5Completa ? _siguientePaso : null,
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

  Widget _construirFase6Identificacion() {
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

          _crearTarjetaGlass(
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
                _guardarDatosPacienteYFinalizar(irAIdentificacion: true);
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
                _guardarDatosPacienteYFinalizar(irAIdentificacion: false);
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

  Widget _crearOpcionPaciente({required String titulo, required IconData icono, required bool seleccionado, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF00D1FF).withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: seleccionado ? const Color(0xFF00D1FF) : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icono, color: seleccionado ? Colors.white : const Color(0xFF1C63BB), size: 28),
            const SizedBox(width: 15),
            Text(
                titulo,
                style: TextStyle(
                    color: seleccionado ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearChipSeleccion(String texto, bool seleccionado, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF00D1FF).withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: seleccionado ? const Color(0xFF00D1FF) : const Color(0xFFD2D2D2), width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
            texto,
            style: TextStyle(color: seleccionado ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
        ),
      ),
    );
  }

  Widget _crearCampoTexto({
    required String titulo,
    required String hint,
    required TextEditingController controlador,
    required bool esNumero,
    bool activo = true,
    FocusNode? focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: activo ? Colors.white : Colors.grey)),
        const SizedBox(height: 5),
        TextField(
          controller: controlador,
          focusNode: focusNode,
          enabled: activo,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: Color(0xFF848282)),
            filled: true, fillColor: activo ? Colors.white : Colors.grey.shade300,
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