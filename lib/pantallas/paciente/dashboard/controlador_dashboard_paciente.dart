import 'package:flutter/material.dart';
import 'package:insulapp/database/gestores/gestor_pacientes.dart';
import 'package:insulapp/database/gestores/gestor_usuarios.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../servicios/servicios/reporte_paciente_service.dart';

class ControladorDashboardPaciente extends ChangeNotifier {
  final String nombrePacienteInicial;

  ControladorDashboardPaciente({this.nombrePacienteInicial = 'Paciente'}) {
    _inicializarFecha();
    cargarDatosBD();
  }

  String _fechaFormateada = '';
  String get fechaFormateada => _fechaFormateada;

  int? _pacienteId;
  int? get pacienteId => _pacienteId;

  bool _cargandoDatos = true;
  bool get cargandoDatos => _cargandoDatos;

  File? _imagenPerfil;
  File? get imagenPerfil => _imagenPerfil;

  Map<String, dynamic> _datosPacienteComp = {};
  Map<String, dynamic> get datosPacienteComp => _datosPacienteComp;

  List<Map<String, dynamic>> _reportesGenerados = [];
  List<Map<String, dynamic>> get reportesGenerados => _reportesGenerados;

  int limiteHipo = 70;
  int limiteHiper = 180;
  int rangoMin = 80;
  int rangoMax = 130;

  List<Map<String, dynamic>> _registrosGlucosa = [];
  List<Map<String, dynamic>> get registrosGlucosa => _registrosGlucosa;

  Future<void> cargarDatosBD() async {
    _cargandoDatos = true;
    notifyListeners();

    final usuarioId = await GestorUsuario().obtenerSesionActiva();

    if (usuarioId != null) {
      final usuario = await GestorUsuario().obtenerUsuarioPorId(usuarioId);
      final paciente = await GestorPacientes().obtenerPacientePorUsuario(usuarioId);
      if (paciente != null) {
        _pacienteId = paciente['id'];

        _datosPacienteComp = {
          'nombre': usuario?['nombre'] ?? nombrePacienteInicial,
          'edad': paciente['edad'],
          'peso': paciente['peso'],
          'altura': paciente['altura'],
          'imc': paciente['imc'],
          'tipoDiabetes': paciente['tipo_diabetes'],
          'medico': paciente['medico_nombre'],
          'limiteHipo': (paciente['limite_hipo'] as num?)?.toInt() ?? 70,
          'hiperLimit': (paciente['limite_hiper'] as num?)?.toInt() ?? 180,
          'rangoMin': (paciente['rango_min'] as num?)?.toInt() ?? 80,
          'rangoMax': (paciente['rango_max'] as num?)?.toInt() ?? 130,
        };

        if (usuario?['foto_perfil'] != null && usuario!['foto_perfil'].toString().isNotEmpty) {
          _imagenPerfil = File(usuario!['foto_perfil']);
        } else {
          _imagenPerfil = null;
        }

        limiteHipo = _datosPacienteComp['limiteHipo'];
        limiteHiper = _datosPacienteComp['hiperLimit'];
        rangoMin = _datosPacienteComp['rangoMin'];
        rangoMax = _datosPacienteComp['rangoMax'];

        final registrosBD = await GestorPacientes().obtenerRegistrosGlucosa(_pacienteId!);
        _registrosGlucosa = registrosBD
            .where((r) => (r['valor'] as num) > 0)
            .map((r) => {
          'valor': (r['valor'] as num).toInt(),
          'momento': r['momento'],
          'fecha': DateTime.parse(r['fecha']),
          'notas': r['notas'] ?? '',
        }).toList();

        final reportesBD = await GestorPacientes().obtenerReportesDePaciente(_pacienteId!);
        _reportesGenerados = reportesBD.map((r) => {
          'id': r['id'].toString(),
          'periodo': r['periodo'],
          'fecha': DateTime.parse(r['fecha']),
          'bytes': r['archivo_bytes'] as Uint8List,
        }).toList();
      }
    }

    _cargandoDatos = false;
    notifyListeners();
  }

  Future<void> _inicializarFecha() async {
    await initializeDateFormatting('es_ES', null);
    final DateTime ahora = DateTime.now();
    final DateFormat formateador = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es_ES');
    String fecha = formateador.format(ahora);
    if (fecha.isNotEmpty) {
      fecha = fecha[0].toUpperCase() + fecha.substring(1);
    }
    _fechaFormateada = fecha;
    notifyListeners();
  }

  String obtenerSaludo() {
    var hora = DateTime.now().hour;
    if (hora < 12) {
      return 'Buenos días';
    } else if (hora < 19) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  int obtenerUltimaGlucosa() {
    if (_registrosGlucosa.isEmpty) return 0;
    return _registrosGlucosa.first['valor'];
  }

  String obtenerTiempoUltimaLectura() {
    if (_registrosGlucosa.isEmpty) return '--';
    final fecha = _registrosGlucosa.first['fecha'] as DateTime;
    return DateFormat("d/M/yyyy 'a las' HH:mm", 'es_ES').format(fecha);
  }

  String obtenerMomentoUltimaLectura() {
    if (_registrosGlucosa.isEmpty) return '--';
    return _registrosGlucosa.first['momento'];
  }

  String obtenerEstadoGlucosa(int valor) {
    if (valor < limiteHipo) return 'Hipoglucemia';
    if (valor >= limiteHipo && valor < rangoMin) return 'Bajo';
    if (valor >= rangoMin && valor <= rangoMax) return 'Normal';
    if (valor > rangoMax && valor <= limiteHiper) return 'Elevado';
    return 'Hiperglucemia';
  }

  int calcularPromedioGlucosa() {
    if (_registrosGlucosa.isEmpty) return 0;
    int suma = 0;
    for (var r in _registrosGlucosa) {
      suma += r['valor'] as int;
    }
    return (suma / _registrosGlucosa.length).round();
  }

  int calcularTIR() {
    if (_registrosGlucosa.isEmpty) return 0;
    int enRango = 0;
    for (var r in _registrosGlucosa) {
      int val = r['valor'] as int;
      if (val >= rangoMin && val <= rangoMax) {
        enRango++;
      }
    }
    return ((enRango / _registrosGlucosa.length) * 100).round();
  }

  Future<void> guardarNuevaMedida(int valor, String momento, String notas, DateTime fecha) async {
    if (_pacienteId != null) {
      await GestorPacientes().insertarRegistroGlucosa({
        'paciente_id': _pacienteId,
        'valor': valor,
        'momento': momento,
        'notas': notas,
        'fecha': fecha.toIso8601String(),
      });
      await cargarDatosBD();
    }
  }

  Future<Uint8List?> generarPDFAGP(BuildContext context, String periodoSeleccionado) async {
    DateTime ahora = DateTime.now();
    DateTime? limiteFecha;
    if (periodoSeleccionado == '7 Días') limiteFecha = ahora.subtract(const Duration(days: 7));
    else if (periodoSeleccionado == '14 Días') limiteFecha = ahora.subtract(const Duration(days: 14));
    else if (periodoSeleccionado == '1 Mes') limiteFecha = ahora.subtract(const Duration(days: 30));
    else if (periodoSeleccionado == '3 Meses') limiteFecha = ahora.subtract(const Duration(days: 90));

    final registrosSoloGlucosa = _registrosGlucosa.where((r) {
      if (limiteFecha != null) {
        DateTime fechaRegistro = r['fecha'] as DateTime;
        if (fechaRegistro.isBefore(limiteFecha)) return false;
      }
      return true;
    }).toList();

    if (registrosSoloGlucosa.length < 3) {
      throw Exception('No hay suficientes registros en el periodo seleccionado ($periodoSeleccionado). Se requiere un mínimo de 3 lecturas.');
    }

    final sorted = List<Map<String, dynamic>>.from(registrosSoloGlucosa)..sort((a, b) => (a['fecha'] as DateTime).compareTo(b['fecha'] as DateTime));
    final iniStr = DateFormat('dd MMM yy').format(sorted.first['fecha'] as DateTime);
    final finStr = DateFormat('dd MMM yy').format(sorted.last['fecha'] as DateTime);
    final periodo = '$periodoSeleccionado ($iniStr - $finStr)';

    final bytes = await ReportePacienteService.generarReporteAGP(
      paciente: _datosPacienteComp,
      registros: registrosSoloGlucosa,
    );
    final String idUnico = DateTime.now().millisecondsSinceEpoch.toString();

    await GestorPacientes().insertarReportePaciente({
      'id': idUnico,
      'paciente_id': _pacienteId,
      'periodo': periodo,
      'fecha': DateTime.now().toIso8601String(),
      'archivo_bytes': bytes,
    });

    await cargarDatosBD();
    return bytes;
  }
}
