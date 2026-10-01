import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_helper.dart';
import '../../database/eventos_clinicos.dart';
import '../../database/gestores/gestor_pacientes.dart';
import '../../database/gestores/gestor_usuarios.dart';
import '../../dominio/motor_dosis.dart';
import '../../modelos/entradas_calculo_dosis.dart';
import '../../modelos/paciente_clinico.dart';
import '../../modelos/parametros_dosis.dart';

/// Controlador que maneja la lógica de negocio y el estado de la Calculadora de Dosis.
/// Separa la responsabilidad visual (la pantalla) de la matemática y los datos (este controlador).
class ControladorCalculadora extends ChangeNotifier {
  // ==========================================
  // 1. ESTADOS DE LA INTERFAZ (UI STATE)
  // ==========================================
  bool cargandoPrefs = true;
  bool mostrarPreguntaInicial = false;
  bool mostrarExplicacion = false;
  bool guardando = false;
  bool calculado = false;

  // ==========================================
  // 2. ENTRADAS DEL USUARIO (INPUTS)
  // ==========================================
  final TextEditingController glucosaCtrl = TextEditingController();
  final TextEditingController carbsCtrl = TextEditingController();
  final TextEditingController relacionICCtrl = TextEditingController();
  final TextEditingController fsiCtrl = TextEditingController();
  final TextEditingController objetivoCtrl = TextEditingController();

  String actividadSeleccionada = 'Sedentario';
  String momentoComida = 'Almuerzo';

  // ==========================================
  // 3. DATOS CLÍNICOS Y RESULTADOS (BUSINESS STATE)
  // ==========================================
  int? pacienteId;
  int? _pacienteIdProporcionado;
  AmbitoPaciente _ambitoPaciente = AmbitoPaciente.personal;
  AmbitoPaciente get ambitoPaciente => _ambitoPaciente;
  
  ParametrosDosis? parametros;
  String estadoConfiguracion = MotorDosis.faltaConfiguracion;

  // Resultados del cálculo
  double dosisComida = 0;
  double dosisCorreccion = 0;
  double dosisTotal = 0;
  double dosisAjustada = 0;
  double ajusteActividad = 0;
  String estadoGlucosa = '';

  // Metadatos internos para validar y guardar en base de datos
  EntradasCalculoDosis? _entradasCalculadas;
  String? _parametrosCalculadosId;
  String? _calculoId;
  DateTime? _fechaCalculo;
  Map<String, Object?> _detalleCalculo = {};

  // ==========================================
  // 4. INICIALIZACIÓN Y LIMPIEZA
  // ==========================================
  ControladorCalculadora() {
    // Si el usuario cambia un dato después de haber calculado, el cálculo se invalida.
    for (final ctrl in [glucosaCtrl, carbsCtrl, relacionICCtrl, fsiCtrl, objetivoCtrl]) {
      ctrl.addListener(_invalidarSiCambioEntrada);
    }
  }

  Future<void> inicializar({int? pacienteIdProporcionado, AmbitoPaciente ambito = AmbitoPaciente.personal}) async {
    _pacienteIdProporcionado = pacienteIdProporcionado;
    _ambitoPaciente = ambito;
    await _verificarTutorial();
    await cargarDatosPaciente();
  }

  @override
  void dispose() {
    glucosaCtrl.dispose();
    carbsCtrl.dispose();
    relacionICCtrl.dispose();
    fsiCtrl.dispose();
    objetivoCtrl.dispose();
    super.dispose();
  }

  // ==========================================
  // 5. MÉTODOS DE NEGOCIO (LOGIC)
  // ==========================================

  Future<void> _verificarTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final prefKey = _ambitoPaciente == AmbitoPaciente.familiar 
        ? 'tutorial_conteo_cuidador_visto' 
        : 'tutorial_conteo_visto';
    final tutorialVisto = prefs.getBool(prefKey) ?? false;

    if (!tutorialVisto) {
      mostrarPreguntaInicial = true;
    }
    cargandoPrefs = false;
    notifyListeners();
  }

  Future<void> marcarTutorialVisto() async {
    final prefs = await SharedPreferences.getInstance();
    final prefKey = _ambitoPaciente == AmbitoPaciente.familiar 
        ? 'tutorial_conteo_cuidador_visto' 
        : 'tutorial_conteo_visto';
    await prefs.setBool(prefKey, true);
    mostrarPreguntaInicial = false;
    mostrarExplicacion = false;
    notifyListeners();
  }

  void activarExplicacion() {
    mostrarPreguntaInicial = false;
    mostrarExplicacion = true;
    notifyListeners();
  }

  Future<void> cargarDatosPaciente() async {
    try {
      int? id;
      if (_pacienteIdProporcionado != null) {
        id = _pacienteIdProporcionado;
      } else {
        final usuarioId = await GestorUsuario().obtenerSesionActiva();
        final paciente = usuarioId == null ? null : await GestorPacientes().obtenerPacientePorUsuario(usuarioId);
        id = paciente?['id'] as int?;
      }

      final parametrosVigentes = id == null
          ? null
          : await (await DatabaseHelper().eventos).parametrosVigentes(PacienteClinico(_ambitoPaciente, id));

      _invalidarCalculo();

      pacienteId = id;
      parametros = parametrosVigentes;
      estadoConfiguracion = parametrosVigentes == null
          ? MotorDosis.faltaConfiguracion
          : 'Configuración autorizada · versión ${parametrosVigentes.version}';
      
      relacionICCtrl.text = parametrosVigentes?.ric.toString() ?? '';
      fsiCtrl.text = parametrosVigentes?.fsi.toString() ?? '';
      objetivoCtrl.text = parametrosVigentes?.objetivo.toString() ?? '';
      
      notifyListeners();
    } catch (_) {
      _invalidarCalculo();
      parametros = null;
      estadoConfiguracion = 'No se pudo verificar la configuración clínica. Reintenta la carga.';
      notifyListeners();
    }
  }

  void seleccionarActividad(String actividad) {
    actividadSeleccionada = actividad;
    _invalidarSiCambioEntrada();
    notifyListeners();
  }

  void seleccionarMomento(String momento) {
    momentoComida = momento;
    _invalidarSiCambioEntrada();
    notifyListeners();
  }

  Future<void> calcularDosis({
    required Function(String) mostrarError,
    required VoidCallback onCalculoExitoso,
  }) async {
    _invalidarCalculo();
    final entradasSolicitadas = _capturarEntradas();
    try {
      final idPaciente = pacienteId;
      final vigente = idPaciente == null
          ? null
          : await (await DatabaseHelper().eventos).parametrosVigentes(PacienteClinico(_ambitoPaciente, idPaciente));

      if (entradasSolicitadas != _capturarEntradas()) return;
      if (vigente == null) throw const CalculoNoDisponible(MotorDosis.faltaConfiguracion);
      if (vigente.id != parametros?.id) {
        throw const CalculoNoDisponible('La configuración cambió. Recarga los parámetros antes de calcular.');
      }

      final glucosa = double.tryParse(glucosaCtrl.text);
      final carbs = double.tryParse(carbsCtrl.text);
      
      final resultado = MotorDosis.calcular(
        parametros: parametros,
        glucosa: glucosa,
        carbohidratos: carbs,
        actividad: actividadSeleccionada,
        ahora: DateTime.now(),
      );

      dosisComida = resultado.comida;
      dosisCorreccion = resultado.correccion;
      dosisTotal = resultado.total;
      ajusteActividad = resultado.ajuste;
      dosisAjustada = resultado.dosis;
      estadoGlucosa = ''; 
      calculado = true;
      
      _entradasCalculadas = _capturarEntradas();
      _parametrosCalculadosId = parametros!.id;
      _calculoId = EventosClinicos.nuevoId();
      _fechaCalculo = DateTime.now();
      _detalleCalculo = {
        'glucosa': glucosa,
        'carbohidratos': carbs,
        'actividad': actividadSeleccionada,
        'momento': momentoComida
      };

      notifyListeners();
      onCalculoExitoso();
    } on CalculoNoDisponible catch (e) {
      mostrarError(e.mensaje);
    } catch (_) {
      mostrarError('No se pudo verificar la configuración clínica. Reintenta la carga.');
    }
  }

  Future<void> guardarRegistro({
    required Function(String) mostrarExito,
    required Function(String) mostrarError,
    required VoidCallback onRegistroGuardado,
  }) async {
    if (guardando) return;
    final entradas = _entradasCalculadas;
    
    if (!calculado || entradas == null || entradas != _capturarEntradas()) {
      _invalidarCalculo();
      mostrarError('Los datos cambiaron. Calcula de nuevo antes de guardar.');
      return;
    }
    
    final idPaciente = pacienteId;
    if (idPaciente == null) {
      mostrarError('No se pudo identificar al paciente. Intenta cargar sus datos de nuevo.');
      return;
    }

    final glucosa = double.tryParse(entradas.glucosa) ?? 0;
    
    guardando = true;
    notifyListeners();

    try {
      await (await DatabaseHelper().eventos).guardarCalculo(
        id: _calculoId!,
        parametrosId: _parametrosCalculadosId!,
        paciente: PacienteClinico(_ambitoPaciente, idPaciente),
        glucosa: glucosa,
        dosis: dosisAjustada,
        entradas: Map<String, Object?>.from(_detalleCalculo),
        momento: entradas.momento,
        fecha: _fechaCalculo!,
      );

      mostrarExito('Cálculo guardado. No registra una administración.');
      
      if (_entradasCalculadas == entradas) {
        limpiarInputs();
      }
      onRegistroGuardado();
    } on CalculoNoDisponible catch (e) {
      _invalidarCalculo();
      mostrarError(e.mensaje);
    } catch (_) {
      mostrarError('No se pudo guardar el cálculo. Intenta de nuevo.');
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  void limpiarInputs() {
    _entradasCalculadas = null;
    glucosaCtrl.clear();
    carbsCtrl.clear();
    calculado = false;
    actividadSeleccionada = 'Sedentario';
    momentoComida = 'Almuerzo';
    estadoGlucosa = '';
    notifyListeners();
  }

  // ==========================================
  // 6. MÉTODOS PRIVADOS DE APOYO
  // ==========================================

  EntradasCalculoDosis _capturarEntradas() => (
        glucosa: glucosaCtrl.text,
        carbohidratos: carbsCtrl.text,
        relacionIC: relacionICCtrl.text,
        fsi: fsiCtrl.text,
        objetivo: objetivoCtrl.text,
        actividad: actividadSeleccionada,
        momento: momentoComida,
      );

  void _invalidarSiCambioEntrada() {
    if (_entradasCalculadas == null || _entradasCalculadas == _capturarEntradas()) return;
    _invalidarCalculo();
    notifyListeners();
  }

  void _invalidarCalculo() {
    _entradasCalculadas = null;
    calculado = false;
    estadoGlucosa = '';
  }
}
