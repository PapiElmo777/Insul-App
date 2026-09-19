import 'package:flutter/material.dart';
import 'controlador_calculadora.dart';
import 'widgets/tutorial_calculadora.dart';
import 'widgets/formulario_calculadora.dart';
import 'widgets/resultado_calculadora.dart';
import 'widgets/botones_calculadora.dart';

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
  late final ControladorCalculadora _controlador;

  // ── Animación ──────────────────────────────────────────────
  late AnimationController _resultCtrl;
  late Animation<double>   _resultAnim;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorCalculadora();
    _controlador.addListener(_onControladorCambiado);
    _controlador.inicializar();

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
                                  _controlador.activarExplicacion();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text('Conteo de carbohidratos', style: TextStyle(color: Color(0xFFE8E8E8), fontSize: 14)),
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

