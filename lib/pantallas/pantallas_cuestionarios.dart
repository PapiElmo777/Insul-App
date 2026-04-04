import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    super.dispose();
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
                child: _crearCampoTexto(titulo: 'Cédula Profesional', hint: 'Ej. 12345678', esNumero: true, icono: Icons.badge_outlined),
              ),
              const SizedBox(height: 20),

              SlideTransition(
                position: _animacionSlidePaso2,
                child: _crearCampoTexto(titulo: 'Institución Médica', hint: 'Hospital o Clínica donde laboras', icono: Icons.local_hospital_outlined),
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
                        child: _crearCampoTexto(titulo: 'Especifica el área', hint: 'Escribe tu área médica', icono: Icons.edit_outlined),
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
                    onPressed: () {},
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

  Widget _crearCampoTexto({required String titulo, required String hint, bool esNumero = false, required IconData icono}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        const SizedBox(height: 5),
        TextField(
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
  final int _totalPasos = 5;
  bool _aceptoTerminos = false;

  // Variables Fase 1 (Perfil Clínico)
  String? _sexo;
  final TextEditingController _edadCtrl = TextEditingController();
  String? _tiempoDx;
  String? _tipoDiabetes;
  final TextEditingController _alergiasCtrl = TextEditingController();
  final TextEditingController _pesoCtrl = TextEditingController();
  final TextEditingController _alturaCtrl = TextEditingController();
  double _imc = 0.0;

  // Variables Fase 2 (Parámetros de Control)
  final TextEditingController _hipoCtrl = TextEditingController(text: '70');
  final TextEditingController _hiperCtrl = TextEditingController(text: '180');
  final TextEditingController _rangoMinCtrl = TextEditingController(text: '80');
  final TextEditingController _rangoMaxCtrl = TextEditingController(text: '130');

  // PENDIENTES
  final TextEditingController _fsiCtrl = TextEditingController();
  final TextEditingController _ricCtrl = TextEditingController();

  final List<String> _opcionesTiempoDx = ['Menos de 1 año', '1 a 5 años', '5 a 10 años', 'Más de 10 años'];
  final List<String> _opcionesTipoDiabetes = ['Tipo 1', 'Tipo 2', 'Gestacional', 'LADA / Otro'];

  @override
  void initState() {
    super.initState();
    _pesoCtrl.addListener(_calcularIMC);
    _alturaCtrl.addListener(_calcularIMC);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _edadCtrl.dispose();
    _alergiasCtrl.dispose();
    _pesoCtrl.dispose();
    _alturaCtrl.dispose();
    _hipoCtrl.dispose();
    _hiperCtrl.dispose();
    _rangoMinCtrl.dispose();
    _rangoMaxCtrl.dispose();
    _fsiCtrl.dispose();
    _ricCtrl.dispose();
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
                  _construirFase0Advertencias(),
                  _construirFase1Perfil(),
                  _construirFase2Parametros(),
                  _construirFasePlaceholder('Fase 3: Medicación'),
                  _construirFasePlaceholder('Fase 4: Estilo de Vida'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== FASE 0 ====================
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
          const Text('Paso 1 de 4', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
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

          Row(
            children: [
              Expanded(child: _crearCampoTexto(titulo: 'Peso (kg)', hint: 'Ej. 75', controlador: _pesoCtrl, esNumero: true)),
              const SizedBox(width: 15),
              Expanded(child: _crearCampoTexto(titulo: 'Altura (cm)', hint: 'Ej. 170', controlador: _alturaCtrl, esNumero: true)),
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
          const Text('Paso 2 de 4', style: TextStyle(fontSize: 16, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
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

          //grafico
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
                const Text('Configuración Avanzada (Pendiente)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _crearCampoTexto(titulo: 'Factor de Sensibilidad (FSI)', hint: 'En desarrollo...', controlador: _fsiCtrl, esNumero: false, activo: false),
                const SizedBox(height: 10),
                _crearCampoTexto(titulo: 'Relación Insulina/Carbos (RIC)', hint: 'En desarrollo...', controlador: _ricCtrl, esNumero: false, activo: false),
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

  //grafico
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
                      const Text('Hipo', style: TextStyle(color: Color(
                          0xFFFF6B6B), fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFF6B6B), //
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

  Widget _crearCampoTexto({required String titulo, required String hint, required TextEditingController controlador, required bool esNumero, bool activo = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: activo ? Colors.white : Colors.grey)),
        const SizedBox(height: 5),
        TextField(
          controller: controlador,
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
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true, value: valorActual, hint: Text(hint, style: const TextStyle(color: Colors.grey)),
          onChanged: onChange,
          items: opciones.map((String valor) => DropdownMenuItem<String>(value: valor, child: Text(valor))).toList(),
        ),
      ),
    );
  }
}
//------------------------------------------------------------------------------------------------
class PantallaCuestionarioCuidador extends StatelessWidget {
  const PantallaCuestionarioCuidador({super.key});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Cuestionario Cuidador')), body: const Center(child: Text('Preguntas para Cuidadores'))); }
}