import 'package:flutter/material.dart';
import '../../modelos/paciente_clinico.dart';
import '../paciente/controlador_calculadora.dart';
import '../paciente/widgets/tutorial_calculadora.dart';
import '../paciente/widgets/formulario_calculadora.dart';
import '../paciente/widgets/resultado_calculadora.dart';
import '../paciente/widgets/botones_calculadora.dart';

class TabCalculadoraFamiliar extends StatefulWidget {
  final Map<String, dynamic> paciente;
  final VoidCallback? onRegistroGuardado;

  const TabCalculadoraFamiliar({
    super.key,
    required this.paciente,
    this.onRegistroGuardado,
  });

  @override
  State<TabCalculadoraFamiliar> createState() => _TabCalculadoraFamiliarState();
}

class _TabCalculadoraFamiliarState extends State<TabCalculadoraFamiliar> with TickerProviderStateMixin {
  late final ControladorCalculadora _controlador;

  // ── Animación ──────────────────────────────────────────────
  late AnimationController _resultCtrl;
  late Animation<double>   _resultAnim;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorCalculadora();
    _controlador.addListener(_onControladorCambiado);
    _controlador.inicializar(
      pacienteIdProporcionado: widget.paciente['id'] as int?,
      ambito: AmbitoPaciente.familiar,
    );

    _resultCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _resultAnim = CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOutBack);
  }

  void _onControladorCambiado() {
    if (_controlador.calculado && !_resultCtrl.isAnimating && _resultCtrl.value == 0) {
      _resultCtrl.forward(from: 0);
    } else if (!_controlador.calculado) {
      _resultCtrl.reset();
    }
  }

  @override
  void dispose() {
    _controlador.removeListener(_onControladorCambiado);
    _controlador.dispose();
    _resultCtrl.dispose();
    super.dispose();
  }

  void _calcularDosisWrapper() {
    _controlador.calcularDosis(
      mostrarError: _mostrarError,
      onCalculoExitoso: () {
        FocusScope.of(context).unfocus();
      },
    );
  }

  void _guardarRegistroWrapper() {
    _controlador.guardarRegistro(
      mostrarExito: _mostrarExito,
      mostrarError: _mostrarError,
      onRegistroGuardado: () {
        widget.onRegistroGuardado?.call();
      },
    );
  }

  void _mostrarExito(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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

  Widget _construirHeaderEspecializado() {
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calculadora de Dosis',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Para ${widget.paciente['nombre']}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white, size: 28),
            onPressed: () {
              _controlador.activarExplicacion();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) {
        if (_controlador.cargandoPrefs) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7FA),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB))),
          );
        }

        if (_controlador.mostrarPreguntaInicial) return PreguntaInicialWidget(controlador: _controlador);
        if (_controlador.mostrarExplicacion) return ExplicacionTutorialWidget(controlador: _controlador);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Column(
            children: [
              _construirHeaderEspecializado(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AvisoMedicoWidget(),
                      const SizedBox(height: 20),
                      SeccionMomentoWidget(controlador: _controlador),
                      const SizedBox(height: 16),
                      SeccionDatosWidget(controlador: _controlador),
                      const SizedBox(height: 16),
                      SeccionActividadWidget(controlador: _controlador),
                      const SizedBox(height: 16),
                      SeccionAvanzadosWidget(controlador: _controlador),
                      const SizedBox(height: 24),

                      if (_controlador.estadoGlucosa == 'Hipoglucemia') const AlertasClinicasWidget(),

                      BotonesCalculadoraWidget(
                        controlador: _controlador,
                        onCalcular: _calcularDosisWrapper,
                        onGuardar: _guardarRegistroWrapper,
                      ),

                      const SizedBox(height: 20),

                      if (_controlador.calculado) ScaleTransition(scale: _resultAnim, child: SeccionResultadoWidget(controlador: _controlador)),
                      
                      const SizedBox(height: 24),
                      const ReferenciaCalculoWidget(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}