import 'package:flutter/material.dart';
import '../../../../database/gestores/gestor_enfermeros.dart';
import '../../../../database/database_helper.dart';
import '../../../../database/eventos_clinicos.dart';
import '../../../../modelos/paciente_clinico.dart';
import 'package:intl/intl.dart' hide TextDirection;

class ControladorDetallePaciente extends ChangeNotifier {
  final Map<String, dynamic> paciente;
  final String nombreEnfermero;

  List<Map<String, dynamic>> historialGlucosa = [];
  List<Map<String, dynamic>> medicamentos = [];
  List<Map<String, dynamic>> historialInsulina = [];
  List<Map<String, dynamic>> calculos = [];
  List<Map<String, dynamic>> insulinaAnterior = [];
  List<String> observacionesBD = [];
  
  bool cargando = true;
  bool guardandoMedicamento = false;
  int? indiceSeleccionadoGrafica;

  ControladorDetallePaciente({
    required this.paciente,
    required this.nombreEnfermero,
  });

  Future<void> cargarDatosPaciente() async {
    final pacienteId = paciente['id'];

    final glucosa = await GestorEnfermeros().obtenerGlucosaEnfermero(pacienteId);
    final meds = await GestorEnfermeros().obtenerMedicamentosEnfermero(pacienteId);
    final insul = await GestorEnfermeros().obtenerInsulinaEnfermero(pacienteId);
    final obs = await GestorEnfermeros().obtenerObservacionesEnfermero(pacienteId);
    final calculosObtenidos = await (await DatabaseHelper().eventos).calculos(PacienteClinico(AmbitoPaciente.institucional, pacienteId));
    final anteriores = await (await DatabaseHelper().db).query('insulina_enfermero', where: 'paciente_id = ?', whereArgs: [pacienteId]);

    historialGlucosa = glucosa.map((e) => {
      'valor': (e['valor'] as num?)?.toInt() ?? 0,
      'fecha': DateTime.tryParse(e['fecha']?.toString() ?? '')?.toLocal() ?? DateTime.now()
    }).toList();

    medicamentos = List<Map<String, dynamic>>.from(meds);
    calculos = calculosObtenidos;
    insulinaAnterior = anteriores;

    historialInsulina = insul.map((e) => {
      'unidades': e['unidades'] as num? ?? 0,
      'fecha': DateTime.tryParse(e['fecha']?.toString() ?? '')?.toLocal() ?? DateTime.now()
    }).toList();

    observacionesBD = obs.map((e) => e['nota']?.toString() ?? '').toList();

    if (observacionesBD.isEmpty && paciente['estadoGeneral'] != null && paciente['estadoGeneral'].toString().isNotEmpty) {
      observacionesBD.add('NOTA DE INGRESO:\n${paciente['estadoGeneral']}');
    }

    cargando = false;
    notifyListeners();
  }

  double calcularPromedio() {
    if (historialGlucosa.isEmpty) return 0;
    double suma = 0;
    for (var item in historialGlucosa) {
      suma += item['valor'];
    }
    return suma / historialGlucosa.length;
  }

  double calcularTIR() {
    if (historialGlucosa.isEmpty) return 0;
    int enRango = 0;
    int minG = paciente['rangoMin'] ?? 80;
    int maxG = paciente['rangoMax'] ?? 130;
    for (var item in historialGlucosa) {
      int val = item['valor'];
      if (val >= minG && val <= maxG) enRango++;
    }
    return (enRango / historialGlucosa.length) * 100;
  }

  String obtenerEstadoGlucosa(int valor) {
    int hipo = paciente['hipoLimit'] ?? 70;
    int hiper = paciente['hiperLimit'] ?? 180;
    int rMin = paciente['rangoMin'] ?? 80;
    int rMax = paciente['rangoMax'] ?? 130;

    if (valor < hipo) return 'Hipoglucemia';
    if (valor >= hipo && valor < rMin) return 'Bajo';
    if (valor >= rMin && valor <= rMax) return 'Normal';
    if (valor > rMax && valor <= hiper) return 'Elevado';
    return 'Hiperglucemia';
  }

  Color obtenerColorEstado(String estado) {
    if (estado == 'Hipoglucemia') return const Color(0xFFD32F2F);
    if (estado == 'Bajo') return const Color(0xFFE65100);
    if (estado == 'Normal') return const Color(0xFF2E7D32);
    if (estado == 'Elevado') return const Color(0xFFE65100);
    return const Color(0xFFD32F2F);
  }

  void setIndiceGrafica(int? index) {
    indiceSeleccionadoGrafica = index;
    notifyListeners();
  }

  Future<void> agregarGlucosa(int valor) async {
    await GestorEnfermeros().insertarGlucosaEnfermero({
      'paciente_id': paciente['id'],
      'valor': valor,
      'fecha': DateTime.now().toIso8601String()
    });
    await cargarDatosPaciente();
  }

  Future<void> agregarObservacion(String observacion) async {
    String hora = DateFormat('hh:mm a').format(DateTime.now());
    await GestorEnfermeros().insertarObservacionEnfermero({
      'paciente_id': paciente['id'],
      'nota': "[$hora] Enf. $nombreEnfermero:\n$observacion",
      'fecha': DateTime.now().toIso8601String()
    });
    await cargarDatosPaciente();
  }

  Future<void> actualizarPerfil(Map<String, dynamic> datosEditados) async {
    await GestorEnfermeros().actualizarPacienteEnfermero(paciente['id'], datosEditados);
    
    paciente['nombre'] = datosEditados['nombre'];
    paciente['edad'] = datosEditados['edad'];
    paciente['expediente'] = datosEditados['expediente'];
    paciente['ubicacion'] = datosEditados['ubicacion'];
    paciente['dieta'] = datosEditados['dieta'];
    paciente['alergias'] = datosEditados['alergias'];
    
    notifyListeners();
  }

  Future<bool> confirmarMedicamento(Map<String, dynamic> med, bool aplicado) async {
    if (guardandoMedicamento) return false;
    guardandoMedicamento = true;
    notifyListeners();

    bool exito = false;
    try {
      final eventos = await DatabaseHelper().eventos;
      final pacienteClinico = PacienteClinico(AmbitoPaciente.institucional, paciente['id']);
      if (aplicado) {
        await eventos.confirmarAdministracion(
          id: EventosClinicos.nuevoId(), 
          paciente: pacienteClinico,
          confirmada: true, 
          medicamento: med['nombre'] ?? '', 
          dosisTexto: med['dosis'] ?? '',
          fecha: DateTime.now(), 
          medicamentoEnfermeroId: med['id']
        );
      } else {
        await eventos.anularAdministracion(pacienteClinico, med['administracion_id'], 'Corrección explícita desde checklist de enfermería');
      }
      await cargarDatosPaciente();
      exito = true;
    } catch (e) {
      exito = false;
    } finally {
      guardandoMedicamento = false;
      notifyListeners();
    }
    return exito;
  }
}
