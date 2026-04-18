import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_helper.dart';

class PantallaCalculadoraDosis extends StatefulWidget {
  final VoidCallback? onRegistroGuardado;

  const PantallaCalculadoraDosis({
    super.key,
    this.onRegistroGuardado,
  });

  @override
  State<PantallaCalculadoraDosis> createState() => _PantallaCalculadoraDosisState();
}

class _PantallaCalculadoraDosisState extends State<PantallaCalculadoraDosis> with TickerProviderStateMixin {
  // ── Estados de Introducción (Onboarding) ───────────────────
  bool _cargandoPrefs = true;
  bool _mostrarPreguntaInicial = false;
  bool _mostrarExplicacion = false;

  // ── Controladores ──────────────────────────────────────────
  final _glucosaCtrl   = TextEditingController();
  final _carbsCtrl     = TextEditingController();
  final _relacionICCtrl = TextEditingController();
  final _fsiCtrl       = TextEditingController();
  final _objetivoCtrl  = TextEditingController();

  // ── Estado de Base de Datos y Lógica ───────────────────────
  int? _pacienteId;
  String _actividadSeleccionada = 'Sedentario';
  String _momentoComida         = 'Almuerzo';
  bool   _mostrarAvanzado       = false;
  bool   _calculado             = false;

  // Valores base desde BD
  double _ricBD = 15;
  double _fsiBD = 50;
  double _objetivoBD = 100;

  // ── Resultados ─────────────────────────────────────────────
  double _dosisComida      = 0;
  double _dosisCorreccion  = 0;
  double _dosisTotal       = 0;
  double _dosisAjustada    = 0;
  double _ajusteActividad  = 0;
  String _estadoGlucosa    = '';

  // ── Animación ──────────────────────────────────────────────
  late AnimationController _resultCtrl;
  late Animation<double>   _resultAnim;

  // ── Actividades físicas ────────────────────────────────────
  final _actividades = const [
    _Actividad('Sedentario', Icons.weekend_outlined, 0.00, 'Sin actividad física hoy'),
    _Actividad('Ligero', Icons.directions_walk_outlined, 0.10, 'Caminata corta, tareas del hogar'),
    _Actividad('Moderado', Icons.directions_bike_outlined, 0.20, '30-60 min ejercicio moderado'),
    _Actividad('Intenso', Icons.fitness_center_outlined, 0.30, 'Más de 60 min o ejercicio de alta intensidad'),
  ];

  final _momentos = const ['Desayuno', 'Almuerzo', 'Cena', 'Merienda', 'Otro'];

  @override
  void initState() {
    super.initState();
    _resultCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _resultAnim = CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOutBack);

    _verificarTutorial();
    _cargarDatosPaciente();
  }

  Future<void> _verificarTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final tutorialVisto = prefs.getBool('tutorial_conteo_visto') ?? false;

    if (mounted) {
      setState(() {
        if (!tutorialVisto) {
          _mostrarPreguntaInicial = true;
        }
        _cargandoPrefs = false;
      });
    }
  }

  Future<void> _marcarTutorialVisto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_conteo_visto', true);
    if (mounted) {
      setState(() {
        _mostrarPreguntaInicial = false;
        _mostrarExplicacion = false;
      });
    }
  }

  Future<void> _cargarDatosPaciente() async {
    final db = DatabaseHelper();
    final usuarioId = await db.obtenerSesionActiva();
    if (usuarioId != null) {
      final paciente = await db.obtenerPacientePorUsuario(usuarioId);
      if (paciente != null) {
        if (mounted) {
          setState(() {
            _pacienteId = paciente['id'];
            _fsiBD = (paciente['fsi'] as num?)?.toDouble() ?? 50.0;
            _ricBD = (paciente['ric'] as num?)?.toDouble() ?? 15.0;
            _objetivoBD = (paciente['glucosa_meta'] as num?)?.toDouble() ?? 100.0;

            _relacionICCtrl.text = _ricBD.toStringAsFixed(0);
            _fsiCtrl.text = _fsiBD.toStringAsFixed(0);
            _objetivoCtrl.text = _objetivoBD.toStringAsFixed(0);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _glucosaCtrl.dispose();
    _carbsCtrl.dispose();
    _relacionICCtrl.dispose();
    _fsiCtrl.dispose();
    _objetivoCtrl.dispose();
    _resultCtrl.dispose();
    super.dispose();
  }

  void _calcular() {
    final glucosa   = double.tryParse(_glucosaCtrl.text)   ?? 0;
    final carbs     = double.tryParse(_carbsCtrl.text)     ?? 0;
    final relIC     = double.tryParse(_relacionICCtrl.text) ?? _ricBD;
    final fsi       = double.tryParse(_fsiCtrl.text)       ?? _fsiBD;
    final objetivo  = double.tryParse(_objetivoCtrl.text)  ?? _objetivoBD;

    if (carbs <= 0 && glucosa <= 0) {
      _mostrarError('Ingresa al menos los gramos de carbohidratos o tu glucosa actual.');
      return;
    }

    if (glucosa > 0 && glucosa < 70) {
      _mostrarError('⚠️ Hipoglucemia detectada. Trata tu glucosa antes de inyectar insulina.');
      setState(() { _calculado = false; _estadoGlucosa = 'Hipoglucemia'; });
      return;
    }


    final dosisComida = relIC > 0 ? carbs / relIC : 0.0;
    final diff = glucosa - objetivo;
    final dosisCorreccion = fsi > 0 && glucosa > 0 ? diff / fsi : 0.0;
    final dosisTotal = dosisComida + dosisCorreccion;

    final act = _actividades.firstWhere((a) => a.nombre == _actividadSeleccionada);
    final ajuste = dosisTotal > 0 ? (dosisTotal * act.reduccion) : 0.0;
    final dosisAjustada = math.max(0.0, dosisTotal - ajuste);

    String estado = '';
    if (glucosa > 0) {
      if      (glucosa < 70)  estado = 'Hipoglucemia';
      else if (glucosa < 100) estado = 'Bajo';
      else if (glucosa <= 180) estado = 'Normal';
      else if (glucosa <= 250) estado = 'Elevado';
      else                    estado = 'Hiperglucemia';
    }

    setState(() {
      _dosisComida     = dosisComida;
      _dosisCorreccion = dosisCorreccion;
      _dosisTotal      = dosisTotal;
      _ajusteActividad = ajuste;
      _dosisAjustada   = dosisAjustada;
      _estadoGlucosa   = estado;
      _calculado       = true;
    });

    _resultCtrl.forward(from: 0);
    FocusScope.of(context).unfocus();
  }

  Future<void> _guardarRegistro() async {
    if (_pacienteId == null) return;

    final glucosa = double.tryParse(_glucosaCtrl.text) ?? 0;

    String notasExtra = "Dosis ADA Calculada: ${_dosisAjustada.toStringAsFixed(1)} UI. "
        "Carbos a ingerir: ${_carbsCtrl.text}g. Actividad: $_actividadSeleccionada.";

    final db = DatabaseHelper();

    if (glucosa > 0) {
      await db.insertarRegistroGlucosa({
        'paciente_id': _pacienteId,
        'valor': glucosa.toInt(),
        'momento': _momentoComida,
        'notas': notasExtra,
        'fecha': DateTime.now().toIso8601String(),
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cálculo y registro guardado con éxito!'), backgroundColor: Color(0xFF2E7D32)),
      );
      _limpiar();
      if (widget.onRegistroGuardado != null) {
        widget.onRegistroGuardado!();
      }
    }
  }

  void _limpiar() {
    setState(() {
      _glucosaCtrl.clear();
      _carbsCtrl.clear();
      _calculado            = false;
      _actividadSeleccionada = 'Sedentario';
      _momentoComida        = 'Almuerzo';
      _estadoGlucosa        = '';
    });
    _resultCtrl.reset();
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoPrefs) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB))),
      );
    }

    if (_mostrarPreguntaInicial) return _construirPreguntaInicial();
    if (_mostrarExplicacion) return _construirExplicacion();

    return _construirCalculadora();
  }

  // ── 1. PREGUNTA INICIAL ──────────────────────────────────
  Widget _construirPreguntaInicial() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle), child: const Icon(Icons.restaurant, size: 60, color: Color(0xFF1C63BB))),
                  const SizedBox(height: 25),
                  const Text('Cálculo de Dosis y Carbohidratos', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 15),
                  const Text('Antes de empezar, ¿sabes cómo funciona el conteo de carbohidratos para calcular tu insulina?', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4)),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        _marcarTutorialVisto();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C63BB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text('Sí, ya lo conozco', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: OutlinedButton(
                      onPressed: () => setState(() { _mostrarPreguntaInicial = false; _mostrarExplicacion = true; }),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF1C63BB), width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text('No, explícamelo por favor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
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

  // ── 2. EXPLICACIÓN ───────────────────────────────────────
  Widget _construirExplicacion() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Qué es el Conteo de Carbohidratos?', style: TextStyle(fontFamily: 'Montserrat', fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1C63BB))),
              const SizedBox(height: 15),
              const Text('Es un método respaldado por médicos para calcular la cantidad EXACTA de insulina rápida que necesitas inyectarte antes de comer. Todo depende de la comida y de tu glucosa actual.', style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),
              const SizedBox(height: 25),
              const Text('¿Cómo funciona en Insul App?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              _crearPasoTutorial('1', Icons.bloodtype, const Color(0xFFD32F2F), 'Tu Glucosa Actual', 'Primero revisamos cómo está tu azúcar. Si está alta, la app calculará una "Dosis de Corrección" para bajarla a tu rango normal usando tu Factor de Sensibilidad (FSI).'),
              _crearPasoTutorial('2', Icons.restaurant_menu, const Color(0xFFE65100), 'Lo que vas a comer', 'Si comes una manzana (15g de carbohidratos), la app calculará cuánta insulina necesitas SOLO para esa manzana usando tu Relación Insulina/Carbohidrato (RIC).'),
              _crearPasoTutorial('3', Icons.calculate, const Color(0xFF2E7D32), 'El Cálculo Final', 'La app suma ambas cantidades y te dice la dosis total segura a inyectar:\n\nComida: 1.0 U\nCorrección: + 1.5 U\nTotal a Inyectar = 2.5 Unidades.'),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    _marcarTutorialVisto();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('¡Entendido! Vamos a calcular', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearPasoTutorial(String numero, IconData icono, Color color, String titulo, String descripcion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icono, color: color, size: 28)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paso $numero: $titulo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 8),
                Text(descripcion, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ── 3. CALCULADORA ───────────────────────────────────────
  Widget _construirCalculadora() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1C63BB),
            iconTheme: const IconThemeData(color: Colors.white),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Cálculo de Dosis', style: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                          IconButton(
                            icon: const Icon(Icons.help_outline, color: Colors.white, size: 28),
                            onPressed: () {
                              setState(() {
                                _mostrarExplicacion = true;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text('Conteo de carbohidratos · ADA', style: TextStyle(color: Color(0xFFE8E8E8), fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _avisoMedico(),
                  const SizedBox(height: 20),
                  _seccionMomento(),
                  const SizedBox(height: 16),
                  _seccionDatos(),
                  const SizedBox(height: 16),
                  _seccionActividad(),
                  const SizedBox(height: 16),
                  _seccionAvanzados(),
                  const SizedBox(height: 24),

                  if (_estadoGlucosa == 'Hipoglucemia') _alertasClinicas(),

                  _botonCalcular(),
                  const SizedBox(height: 20),

                  if (_calculado) ScaleTransition(scale: _resultAnim, child: _seccionResultado()),
                  if (_calculado) const SizedBox(height: 16),
                  if (_calculado) _botonGuardar(),
                  if (_calculado) const SizedBox(height: 16),
                  if (_calculado) _botonLimpiar(),

                  const SizedBox(height: 24),
                  _referenciaADA(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avisoMedico() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFA000), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_information_outlined, color: Color(0xFFF57F17), size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Esta calculadora es una herramienta de apoyo basada en las guías ADA. Consulta siempre con tu médico antes de ajustar tus dosis de insulina.',
              style: TextStyle(fontSize: 12, color: Color(0xFF5D4037), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionMomento() {
    return _tarjeta(
      titulo: 'Momento de la comida',
      icono: Icons.schedule_outlined,
      hijo: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _momentos.map((m) {
            final sel = m == _momentoComida;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _momentoComida = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF1C63BB) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? const Color(0xFF1C63BB) : const Color(0xFFD2D2D2), width: 1.5),
                    boxShadow: sel ? [BoxShadow(color: const Color(0xFF1C63BB).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                  ),
                  child: Text(m, style: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: sel ? FontWeight.bold : FontWeight.w500, fontSize: 13)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _seccionDatos() {
    return _tarjeta(
      titulo: 'Datos de la comida',
      icono: Icons.restaurant_outlined,
      hijo: Column(
        children: [
          _campoTexto(
            controlador: _carbsCtrl,
            titulo: 'Carbohidratos a ingerir',
            hint: 'ej. 45',
            sufijo: 'g',
            icono: Icons.grain_outlined,
            color: const Color(0xFF2E7D32),
            ayuda: '1 porción = aprox. 15 g de carbohidratos (ADA)',
          ),
          const SizedBox(height: 14),
          _campoTexto(
            controlador: _glucosaCtrl,
            titulo: 'Glucosa actual (preprandial)',
            hint: 'ej. 130',
            sufijo: 'mg/dL',
            icono: Icons.water_drop_outlined,
            color: const Color(0xFF1C63BB),
            ayuda: 'Mide tu glucosa justo antes de comer',
          ),
          const SizedBox(height: 10),
          _referenciaCarbs(),
        ],
      ),
    );
  }

  Widget _referenciaCarbs() {
    final alimentos = [
      ('Tortilla de maíz', '12 g'), ('Arroz cocido ½ tz', '22 g'),
      ('Pan blanco 1 reba.', '13 g'), ('Manzana mediana', '25 g'),
      ('Refresco 355 ml', '38 g'), ('Frijoles ½ tz', '20 g'),
    ];

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: const Text('Ver referencia rápida de alimentos', style: TextStyle(fontSize: 12, color: Color(0xFF1C63BB), fontWeight: FontWeight.bold)),
      leading: const Icon(Icons.info_outline, color: Color(0xFF1C63BB), size: 18),
      iconColor: const Color(0xFF1C63BB),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFE8F0FB), borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Carbohidratos por porción (aprox.)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: alimentos.map((a) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD2D2D2), width: 1)),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 11),
                      children: [
                        TextSpan(text: '${a.$1}  ', style: const TextStyle(color: Colors.black87)),
                        TextSpan(text: a.$2, style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _seccionActividad() {
    return _tarjeta(
      titulo: 'Actividad física del día',
      icono: Icons.directions_run_outlined,
      subtitulo: 'El ejercicio aumenta la sensibilidad a la insulina (ADA)',
      hijo: Column(
        children: _actividades.map((act) {
          final sel = act.nombre == _actividadSeleccionada;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _actividadSeleccionada = act.nombre),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF1C63BB).withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sel ? const Color(0xFF1C63BB) : const Color(0xFFE0E0E0), width: sel ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: sel ? const Color(0xFF1C63BB) : const Color(0xFFF5F5F5), shape: BoxShape.circle),
                      child: Icon(act.icono, color: sel ? Colors.white : const Color(0xFF9E9E9E), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(act.nombre, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: sel ? const Color(0xFF1C63BB) : Colors.black87)),
                          Text(act.descripcion, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    if (act.reduccion > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: sel ? const Color(0xFF1C63BB) : const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                        child: Text('-${(act.reduccion * 100).toInt()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sel ? Colors.white : const Color(0xFF2E7D32))),
                      ),
                    if (sel) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.check_circle, color: Color(0xFF1C63BB), size: 18)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _seccionAvanzados() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE0E0E0))),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF1C63BB).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.tune, color: Color(0xFF1C63BB), size: 18),
          ),
          title: const Text('Parámetros clínicos (Editables)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          subtitle: const Text('Relación I:C y Factor de Sensibilidad', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          onExpansionChanged: (v) => setState(() => _mostrarAvanzado = v),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 14),
            _campoTexto(
              controlador: _relacionICCtrl,
              titulo: 'Relación Insulina:Carbohidratos (I:C)',
              hint: 'ej. 12', sufijo: 'g/UI', icono: Icons.science_outlined, color: const Color(0xFF6A1B9A),
              ayuda: '1 UI cubre esta cantidad de gramos de carbohidratos.',
            ),
            const SizedBox(height: 14),
            _campoTexto(
              controlador: _fsiCtrl,
              titulo: 'Factor de Sensibilidad a Insulina (FSI)',
              hint: 'ej. 50', sufijo: 'mg/dL/UI', icono: Icons.arrow_downward_outlined, color: const Color(0xFFD32F2F),
              ayuda: 'Cuánto baja tu glucosa con 1 UI.',
            ),
            const SizedBox(height: 14),
            _campoTexto(
              controlador: _objetivoCtrl,
              titulo: 'Glucosa objetivo preprandial',
              hint: 'ej. 100', sufijo: 'mg/dL', icono: Icons.flag_outlined, color: const Color(0xFF2E7D32),
              ayuda: 'ADA recomienda 80–130 mg/dL antes de comer',
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(10)),
              child: const Text('💡 Estos valores fueron cargados de tu perfil. Puedes ajustarlos temporalmente para este cálculo.', style: TextStyle(fontSize: 11, color: Color(0xFF4A148C))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionResultado() {
    final act = _actividades.firstWhere((a) => a.nombre == _actividadSeleccionada);
    final tieneCorreccion = _dosisCorreccion.abs() > 0.01;
    final tieneAjuste     = _ajusteActividad > 0.01;

    Color colorDosis = const Color(0xFF1C63BB);
    if (_dosisAjustada <= 0) colorDosis = const Color(0xFF2E7D32);
    if (_dosisAjustada > 15)  colorDosis = const Color(0xFFD32F2F);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C63BB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF1C63BB).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_outline, color: Color(0xFF00D1FF), size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dosis Calculada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Insulina de acción rápida (bolo)', style: TextStyle(fontSize: 11, color: Color(0xFF00D1FF))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(
                  '${_dosisAjustada.toStringAsFixed(1)} UI',
                  style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: colorDosis, height: 1),
                ),
                const Text('Unidades de Insulina', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Redondea al 0.5 UI más cercano con tu médico', style: TextStyle(fontSize: 11, color: Color(0xFF1565C0)), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Desglose del cálculo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00D1FF), letterSpacing: 0.5)),
                const SizedBox(height: 10),
                _filaDesglose(
                  icono: Icons.restaurant_outlined, label: 'Bolo de comida',
                  formula: '${_carbsCtrl.text.isNotEmpty ? _carbsCtrl.text : '0'} g ÷ ${_relacionICCtrl.text} g/UI',
                  valor: '+${_dosisComida.toStringAsFixed(1)} UI', colorValor: Colors.white,
                ),
                if (tieneCorreccion) ...[
                  const SizedBox(height: 6),
                  _filaDesglose(
                    icono: Icons.tune,
                    label: _dosisCorreccion >= 0 ? 'Corrección (alta)' : 'Corrección (baja)',
                    formula: '(${_glucosaCtrl.text} − ${_objetivoCtrl.text}) ÷ ${_fsiCtrl.text}',
                    valor: _dosisCorreccion >= 0 ? '+${_dosisCorreccion.toStringAsFixed(1)} UI' : '${_dosisCorreccion.toStringAsFixed(1)} UI',
                    colorValor: _dosisCorreccion >= 0 ? const Color(0xFFFF8A65) : const Color(0xFF81C784),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white24)),
                  _filaDesglose(
                    icono: Icons.functions, label: 'Subtotal', formula: '',
                    valor: '${_dosisTotal.toStringAsFixed(1)} UI', colorValor: Colors.white, negrita: true,
                  ),
                ],
                if (tieneAjuste) ...[
                  const SizedBox(height: 6),
                  _filaDesglose(
                    icono: act.icono, label: 'Ajuste actividad (${act.nombre})',
                    formula: '-${(act.reduccion * 100).toInt()}% por ejercicio',
                    valor: '-${_ajusteActividad.toStringAsFixed(1)} UI', colorValor: const Color(0xFF80CBC4),
                  ),
                ],
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white38)),
                _filaDesglose(
                  icono: Icons.check_circle_outline, label: 'DOSIS TOTAL AJUSTADA', formula: '',
                  valor: '${_dosisAjustada.toStringAsFixed(1)} UI', colorValor: const Color(0xFF00D1FF), negrita: true, grande: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_estadoGlucosa.isNotEmpty)
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child: _chipEstadoGlucosa()),
        ],
      ),
    );
  }

  Widget _filaDesglose({required IconData icono, required String label, required String formula, required String valor, required Color colorValor, bool negrita = false, bool grande = false}) {
    return Row(
      children: [
        Icon(icono, color: Colors.white54, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: grande ? 12 : 11, color: Colors.white, fontWeight: negrita ? FontWeight.bold : FontWeight.normal)),
              if (formula.isNotEmpty) Text(formula, style: const TextStyle(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ),
        Text(valor, style: TextStyle(fontSize: grande ? 16 : 13, fontWeight: negrita ? FontWeight.bold : FontWeight.w500, color: colorValor)),
      ],
    );
  }

  Widget _chipEstadoGlucosa() {
    Color c; IconData ic;
    switch (_estadoGlucosa) {
      case 'Hipoglucemia': c = const Color(0xFFD32F2F); ic = Icons.warning_rounded; break;
      case 'Bajo': c = const Color(0xFFE65100); ic = Icons.arrow_downward; break;
      case 'Normal': c = const Color(0xFF2E7D32); ic = Icons.check_circle; break;
      case 'Elevado': c = const Color(0xFFE65100); ic = Icons.arrow_upward; break;
      default: c = const Color(0xFFD32F2F); ic = Icons.warning_rounded;
    }
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withOpacity(0.5), width: 1)),
      child: Row(
        children: [
          Icon(ic, color: c, size: 18), const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Glucosa $_estadoGlucosa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c)),
                Text(
                  _estadoGlucosa == 'Hipoglucemia' ? '⚠️ Glucosa muy baja. Trata la hipoglucemia.'
                      : _estadoGlucosa == 'Hiperglucemia' ? '⚠️ Glucosa muy alta. Corrección incluida.'
                      : 'Glucosa en rango adecuado para proceder.',
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertasClinicas() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.6), width: 1.5),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.emergency_outlined, color: Color(0xFFFF5252), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'ATENCIÓN: Tu glucosa indica hipoglucemia. NO te administres insulina ahora. Consume 15 g de carbohidratos de acción rápida y espera 15 minutos.',
              style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w600, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _referenciaADA() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE0E0E0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.book_outlined, color: Color(0xFF1C63BB), size: 18),
            SizedBox(width: 8),
            Text('Fórmulas ADA (referencia)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
          ]),
          const SizedBox(height: 12),
          _filaFormula('Bolo de comida', 'Carbs (g) ÷ Relación I:C', const Color(0xFF2E7D32)),
          const SizedBox(height: 6),
          _filaFormula('Bolo de corrección', '(Glucosa actual − Objetivo) ÷ FSI', const Color(0xFF1C63BB)),
          const SizedBox(height: 10),
          const Text('Fuente: American Diabetes Association (2024)', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }

  Widget _filaFormula(String titulo, String formula, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 4, height: 4, margin: const EdgeInsets.only(top: 6, right: 8), decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12),
              children: [
                TextSpan(text: '$titulo: ', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                TextSpan(text: formula, style: const TextStyle(color: Color(0xFF616161))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _botonCalcular() {
    return SizedBox(
      width: double.infinity, height: 54,
      child: ElevatedButton.icon(
        onPressed: _calcular,
        icon: const Icon(Icons.calculate_outlined, size: 22),
        label: const Text('Calcular Dosis', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C63BB), foregroundColor: Colors.white, elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _botonGuardar() {
    return SizedBox(
      width: double.infinity, height: 54,
      child: ElevatedButton.icon(
        onPressed: _guardarRegistro,
        icon: const Icon(Icons.save_alt, size: 22, color: Color(0xFF1C63BB)),
        label: const Text('Guardar en Historial', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, elevation: 0,
          side: const BorderSide(color: Color(0xFF1C63BB), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _botonLimpiar() {
    return SizedBox(
      width: double.infinity, height: 48,
      child: OutlinedButton.icon(
        onPressed: _limpiar,
        icon: const Icon(Icons.refresh_outlined, size: 20),
        label: const Text('Limpiar cálculo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF9E9E9E), side: const BorderSide(color: Color(0xFFD2D2D2), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _tarjeta({required String titulo, required IconData icono, required Widget hijo, String? subtitulo}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: const Color(0xFF1C63BB).withOpacity(0.1), shape: BoxShape.circle), child: Icon(icono, color: const Color(0xFF1C63BB), size: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                  if (subtitulo != null) Text(subtitulo, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 14),
          hijo,
        ],
      ),
    );
  }

  Widget _campoTexto({required TextEditingController controlador, required String titulo, required String hint, required String sufijo, required IconData icono, required Color color, String? ayuda}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 6),
        TextField(
          controller: controlador,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
            prefixIcon: Icon(icono, color: color, size: 20),
            suffixText: sufijo, suffixStyle: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            filled: true, fillColor: const Color(0xFFF5F7FA),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1)),
          ),
        ),
        if (ayuda != null) ...[
          const SizedBox(height: 4),
          Text(ayuda, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
        ],
      ],
    );
  }
}

class _Actividad {
  final String nombre;
  final IconData icono;
  final double reduccion;
  final String descripcion;
  const _Actividad(this.nombre, this.icono, this.reduccion, this.descripcion);
}