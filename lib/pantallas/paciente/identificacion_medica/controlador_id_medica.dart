import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../../database/gestores/gestor_pacientes.dart';
import '../../../../database/gestores/gestor_usuarios.dart';
import '../../../../servicios/id_medica_service.dart';
class ControladorIdMedica extends ChangeNotifier {
  final VoidCallback onActualizarDashboard;
  final int? pacienteIdProporcionado;
  final bool esCuidador;
  ControladorIdMedica({
    required this.onActualizarDashboard,
    this.pacienteIdProporcionado,
    this.esCuidador = false,
  }) {
    cargarDatos();
  }
  bool cargando = true;
  bool identificacionCompletada = false;
  int? usuarioId;
  int? pacienteId;
  Map<String, dynamic> datosCompletos = {};
  List<Map<String, dynamic>> medicamentos = [];
  // Variables Resumen Glucemico
  int promedio = 0;
  int tir = 0;
  int pctHipo = 0;
  int pctHiper = 0;
  int minG = 0;
  int maxG = 0;
  // Controladores del Formulario Inicial
  final enfCronicasCtrl = TextEditingController();
  final alergiasCtrl = TextEditingController();
  final hospCtrl = TextEditingController();
  final cirugiasCtrl = TextEditingController();
  final emergenciaNombreCtrl = TextEditingController();
  final emergenciaTelCtrl = TextEditingController();
  final medicoCtrl = TextEditingController();
  final clinicaCtrl = TextEditingController();
  // Tipo SanguIneo
  String tipoSanguineoSeleccionado = 'Desconocido';
  final List<String> tiposSanguineos = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Desconocido'];
  void setTipoSanguineo(String tipo) {
    tipoSanguineoSeleccionado = tipo;
    notifyListeners();
  }
  void setIdentificacionCompletada(bool completada) {
    identificacionCompletada = completada;
    notifyListeners();
  }
  Future<void> cargarDatos() async {
    cargando = true;
    notifyListeners();
    final idUsuario = await GestorUsuario().obtenerSesionActiva();
    if (idUsuario != null) {
      usuarioId = idUsuario;
      
      Map<String, dynamic>? usuario;
      Map<String, dynamic>? paciente;
      
      if (esCuidador && pacienteIdProporcionado != null) {
        paciente = await GestorPacientes().obtenerPacientePorId(pacienteIdProporcionado!);
        if (paciente != null) {
           usuarioId = paciente['usuario_id']; // Forzamos usuarioId al del paciente
           usuario = await GestorUsuario().obtenerUsuarioPorId(usuarioId!);
        }
      } else {
        usuario = await GestorUsuario().obtenerUsuarioPorId(idUsuario);
        paciente = await GestorPacientes().obtenerPacientePorUsuario(idUsuario);
      }
      if (paciente != null && usuario != null) {
        pacienteId = paciente['id'];
        identificacionCompletada = (paciente['identificacion_completada'] ?? 0) == 1;
        datosCompletos = {
          'nombre_completo': '${usuario['nombre']} ${usuario['apellidos']}',
          'edad': paciente['edad']?.toString() ?? '--',
          'sexo': paciente['sexo'] ?? '--',
          'tipo_diabetes': paciente['tipo_diabetes'] ?? 'No especificado',
          'tipo_sanguineo': paciente['tipo_sanguineo'] ?? 'No sabe',
          'alergias': paciente['alergias'] ?? 'Ninguna',
          'enfermedades_cronicas': paciente['enfermedades_cronicas'] ?? 'Ninguna',
          'hospitalizaciones': paciente['hospitalizaciones'] ?? 'Ninguna',
          'cirugias': paciente['cirugias'] ?? 'Ninguna',
          'clinica': paciente['clinica'] ?? 'No especificada',
          'medico_nombre': paciente['medico_nombre'] ?? 'No asignado',
          'emergencia_nombre': paciente['emergencia_nombre'] ?? 'No asignado',
          'emergencia_telefono': paciente['emergencia_telefono'] ?? '--',
          'metodo_insulina': paciente['metodo_insulina'] ?? 'No usa',
          'insulina_basal_marca': paciente['insulina_basal_marca'] ?? '',
          'insulina_basal_dosis': paciente['insulina_basal_dosis'] ?? '',
          'insulina_rapida_marca': paciente['insulina_rapida_marca'] ?? '',
        };
        alergiasCtrl.text = datosCompletos['alergias'] == 'Ninguna' ? '' : datosCompletos['alergias'];
        enfCronicasCtrl.text = datosCompletos['enfermedades_cronicas'] == 'Ninguna' ? '' : datosCompletos['enfermedades_cronicas'];
        hospCtrl.text = datosCompletos['hospitalizaciones'] == 'Ninguna' ? '' : datosCompletos['hospitalizaciones'];
        cirugiasCtrl.text = datosCompletos['cirugias'] == 'Ninguna' ? '' : datosCompletos['cirugias'];
        emergenciaNombreCtrl.text = datosCompletos['emergencia_nombre'] == 'No asignado' ? '' : datosCompletos['emergencia_nombre'];
        emergenciaTelCtrl.text = datosCompletos['emergencia_telefono'] == '--' ? '' : datosCompletos['emergencia_telefono'];
        medicoCtrl.text = datosCompletos['medico_nombre'] == 'No asignado' ? '' : datosCompletos['medico_nombre'];
        clinicaCtrl.text = datosCompletos['clinica'] == 'No especificada' ? '' : datosCompletos['clinica'];
        if (tiposSanguineos.contains(datosCompletos['tipo_sanguineo'])) {
          tipoSanguineoSeleccionado = datosCompletos['tipo_sanguineo'];
        }
        final medsBD = await GestorPacientes().obtenerMedicamentosDePaciente(pacienteId!);
        medicamentos = List<Map<String, dynamic>>.from(medsBD);
        if (paciente['med_oral_nombre'] != null && paciente['med_oral_nombre'].toString().isNotEmpty) {
          medicamentos.insert(0, {'nombre': paciente['med_oral_nombre'], 'gramaje': paciente['med_oral_dosis'] ?? ''});
        }
        final registrosBD = await GestorPacientes().obtenerRegistrosGlucosa(pacienteId!);
        final lecturas = registrosBD.where((r) => (r['valor'] as num) > 0).toList();
        if (lecturas.isNotEmpty) {
          int suma = 0;
          int countNormal = 0;
          int countHipo = 0;
          int countHiper = 0;
          int min = 999;
          int max = 0;
          int limHipo = (paciente['limite_hipo'] as num?)?.toInt() ?? 70;
          int limHiper = (paciente['limite_hiper'] as num?)?.toInt() ?? 180;
          int rMin = (paciente['rango_min'] as num?)?.toInt() ?? 80;
          int rMax = (paciente['rango_max'] as num?)?.toInt() ?? 130;
          for (var r in lecturas) {
            int v = (r['valor'] as num).toInt();
            suma += v;
            if (v < min) min = v;
            if (v > max) max = v;
            if (v < limHipo) {
              countHipo++;
            } else if (v > limHiper) {
              countHiper++;
            } else if (v >= rMin && v <= rMax) {
              countNormal++;
            }
          }
          promedio = (suma / lecturas.length).round();
          minG = min;
          maxG = max;
          tir = ((countNormal / lecturas.length) * 100).round();
          pctHipo = ((countHipo / lecturas.length) * 100).round();
          pctHiper = ((countHiper / lecturas.length) * 100).round();
        }
      }
    }
    cargando = false;
    notifyListeners();
  }
  Future<void> guardarFormulario() async {
    if (usuarioId == null) return;
    await GestorPacientes().actualizarPaciente(usuarioId!, {
      'enfermedades_cronicas': enfCronicasCtrl.text.isEmpty ? 'Ninguna' : enfCronicasCtrl.text,
      'alergias': alergiasCtrl.text.isEmpty ? 'Ninguna' : alergiasCtrl.text,
      'tipo_sanguineo': tipoSanguineoSeleccionado,
      'hospitalizaciones': hospCtrl.text.isEmpty ? 'Ninguna' : hospCtrl.text,
      'cirugias': cirugiasCtrl.text.isEmpty ? 'Ninguna' : cirugiasCtrl.text,
      'emergencia_nombre': emergenciaNombreCtrl.text,
      'emergencia_telefono': emergenciaTelCtrl.text,
      'medico_nombre': medicoCtrl.text,
      'clinica': clinicaCtrl.text.isEmpty ? 'No especificada' : clinicaCtrl.text,
      'identificacion_completada': 1,
    });
    onActualizarDashboard();
    await cargarDatos();
  }
  Future<void> generarPDFIdentificacion(BuildContext context) async {
    try {
      final bytes = await IdentificacionMedicaService.generarPDF(
        datos: datosCompletos,
        medicamentos: medicamentos,
        promedio: promedio,
        tir: tir,
        pctHipo: pctHipo,
        pctHiper: pctHiper,
        minG: minG,
        maxG: maxG,
      );
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF1C63BB),
              title: const Text('Visor PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: PdfPreview(
              build: (format) async => bytes,
              pdfFileName: 'ID_Medica_${datosCompletos['nombre_completo'].toString().replaceAll(' ', '_')}.pdf',
            ),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
      }
    }
  }
  @override
  void dispose() {
    enfCronicasCtrl.dispose();
    alergiasCtrl.dispose();
    hospCtrl.dispose();
    cirugiasCtrl.dispose();
    emergenciaNombreCtrl.dispose();
    emergenciaTelCtrl.dispose();
    medicoCtrl.dispose();
    clinicaCtrl.dispose();
    super.dispose();
  }
}
