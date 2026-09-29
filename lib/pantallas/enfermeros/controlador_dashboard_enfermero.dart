import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';

import '../../../database/gestores/gestor_enfermeros.dart';
import '../../../database/gestores/gestor_usuarios.dart';
import '../../../database/database_helper.dart';
import '../../../servicios/reporte_enfermero_service.dart';
import '../../login/pantalla_login.dart';
import 'pantalla_detalle_paciente.dart';

class ControladorDashboardEnfermero extends ChangeNotifier {
  bool cargandoDatos = true;
  int indiceNavegacionActual = 0;
  String fechaFormateada = '';
  
  List<Map<String, dynamic>> listaPacientes = [];
  List<Map<String, dynamic>> reportesGenerados = [];
  File? imagenPerfil;
  final TextEditingController busquedaCtrl = TextEditingController();
  bool ordenarPorUrgencia = false;

  int? enfermeroId;
  String nombreEnfermeroLocal = 'Enfermero';
  String cedulaEnfermero = '12345678';
  String areaEnfermero = 'Medicina Interna';
  String hospitalEnfermero = 'Hospital Ángeles';
  String correoEnfermero = 'alfredo.enfermero@insulapp.com';
  String telefonoEnfermero = '+52 123 456 7890';

  ControladorDashboardEnfermero({String nombreInicial = 'Enfermero'}) {
    nombreEnfermeroLocal = nombreInicial;
    _inicializarFecha();
    cargarDatosBD();
    busquedaCtrl.addListener(notifyListeners);
  }

  @override
  void dispose() {
    busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _inicializarFecha() async {
    await initializeDateFormatting('es_ES', null);
    final DateTime ahora = DateTime.now();
    final DateFormat formateador = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es_ES');
    String fecha = formateador.format(ahora);
    if (fecha.isNotEmpty) {
      fecha = fecha[0].toUpperCase() + fecha.substring(1);
    }
    fechaFormateada = fecha;
    notifyListeners();
  }

  void cambiarTab(int index) {
    indiceNavegacionActual = index;
    notifyListeners();
  }

  void alternarOrdenPorUrgencia(bool valor) {
    ordenarPorUrgencia = valor;
    notifyListeners();
  }

  Future<void> cargarDatosBD() async {
    final usuarioId = await GestorUsuario().obtenerSesionActiva();

    if (usuarioId != null) {
      final usuario = await GestorUsuario().obtenerUsuarioPorId(usuarioId);
      final enfermero = await GestorEnfermeros().obtenerEnfermeroPorUsuario(usuarioId);

      if (usuario != null && enfermero != null) {
        nombreEnfermeroLocal = usuario['nombre'] ?? nombreEnfermeroLocal;
        correoEnfermero = usuario['correo'] ?? '';
        telefonoEnfermero = usuario['telefono'] ?? '';
        cedulaEnfermero = enfermero['cedula'] ?? '';
        hospitalEnfermero = enfermero['institucion'] ?? '';
        areaEnfermero = enfermero['area'] ?? '';
        enfermeroId = enfermero['id'];

        if (usuario['foto_perfil'] != null && usuario['foto_perfil'].toString().isNotEmpty) {
          imagenPerfil = File(usuario['foto_perfil']);
        }

        final pacientesBD = await GestorEnfermeros().obtenerPacientesDeEnfermero(enfermeroId!);
        List<Map<String, dynamic>> pacientesTemp = [];

        for (var p in pacientesBD) {
          final glucosaBD = await GestorEnfermeros().obtenerGlucosaEnfermero(p['id']);
          int ultimaGlucosa = 0;
          DateTime? fechaUltimaGlucosa;

          if (glucosaBD.isNotEmpty) {
            ultimaGlucosa = (glucosaBD.first['valor'] as num).toInt();
            fechaUltimaGlucosa = DateTime.tryParse(glucosaBD.first['fecha'].toString());
          }

          pacientesTemp.add({
            'id': p['id'],
            'nombre': p['nombre'],
            'edad': p['edad'],
            'expediente': p['expediente'],
            'ubicacion': p['ubicacion'],
            'tipoDiabetes': p['tipo_diabetes'],
            'alergias': p['alergias'],
            'dieta': p['dieta'],
            'estadoGeneral': p['estado_general'],
            'hipoLimit': (p['hipo_limit'] as num?)?.toInt() ?? 70,
            'hiperLimit': (p['hiper_limit'] as num?)?.toInt() ?? 180,
            'rangoMin': (p['rango_min'] as num?)?.toInt() ?? 80,
            'rangoMax': (p['rango_max'] as num?)?.toInt() ?? 130,
            'glucosa': ultimaGlucosa,
            'fechaUltimaGlucosa': fechaUltimaGlucosa,
          });
        }
        listaPacientes = pacientesTemp;

        final reportesBD = await GestorEnfermeros().obtenerReportesDeEnfermero(enfermeroId!);
        reportesGenerados = reportesBD.map((r) => {
          'id': r['id'],
          'turno': r['turno'],
          'fecha': DateTime.parse(r['fecha']),
          'pacientes': r['cantidad_pacientes'],
          'bytes': r['archivo_bytes'] as Uint8List,
        }).toList();
      }
    }

    cargandoDatos = false;
    notifyListeners();
  }

  Future<void> seleccionarImagen(ImageSource origen) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? imagenSeleccionada = await picker.pickImage(source: origen);
      if (imagenSeleccionada != null) {
        final usuarioId = await GestorUsuario().obtenerSesionActiva();
        if (usuarioId != null) {
          await GestorUsuario().actualizarFotoPerfil(usuarioId, imagenSeleccionada.path);
        }
        imagenPerfil = File(imagenSeleccionada.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  Future<void> eliminarImagenPerfil() async {
    final usuarioId = await GestorUsuario().obtenerSesionActiva();
    if (usuarioId != null) {
      await GestorUsuario().actualizarFotoPerfil(usuarioId, '');
    }
    imagenPerfil = null;
    notifyListeners();
  }

  Future<void> actualizarPerfilEnfermero(String nombre, String correo, String telefono, String cedula, String hospital, String area) async {
    final usuarioId = await GestorUsuario().obtenerSesionActiva();
    if (usuarioId != null) {
      final baseDatos = await DatabaseHelper().db;
      await baseDatos.update('usuarios', {
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
      }, where: 'id = ?', whereArgs: [usuarioId]);

      await GestorEnfermeros().actualizarEnfermero(usuarioId, {
        'cedula': cedula,
        'institucion': hospital,
        'area': area,
      });

      nombreEnfermeroLocal = nombre;
      correoEnfermero = correo;
      telefonoEnfermero = telefono;
      cedulaEnfermero = cedula;
      hospitalEnfermero = hospital;
      areaEnfermero = area;
      notifyListeners();
    }
  }

  int calcularNivelUrgencia(Map<String, dynamic> p) {
    int val = p['glucosa'] ?? 0;
    int hipo = p['hipoLimit'] ?? 70;
    int hiper = p['hiperLimit'] ?? 180;
    int rMin = p['rangoMin'] ?? 80;
    int rMax = p['rangoMax'] ?? 130;
    DateTime? fechaUltima = p['fechaUltimaGlucosa'];

    if (val > 0 && (val < hipo || val > hiper)) return 4;
    if (fechaUltima == null) return 3;
    if (DateTime.now().difference(fechaUltima).inHours >= 4) return 3;
    if (val > 0 && (val < rMin || val > rMax)) return 2;

    return 1;
  }

  Future<Uint8List> generarYGuardarReporte(String turno) async {
    final usuarioId = await GestorUsuario().obtenerSesionActiva();
    final usuario = await GestorUsuario().obtenerUsuarioPorId(usuarioId!);
    final enfermeroData = await GestorEnfermeros().obtenerEnfermeroPorUsuario(usuarioId);

    final enfermeroObj = DatosEnfermero(
      nombre: usuario!['nombre'],
      cedula: enfermeroData!['cedula'],
      area: enfermeroData['area'],
      hospital: enfermeroData['institucion'],
    );

    List<Map<String, dynamic>> pacientesParaReporte = [];
    for (var p in listaPacientes) {
      final int id = p['id'];
      final glucosa = await GestorEnfermeros().obtenerGlucosaEnfermero(id);
      final medicamentos = await GestorEnfermeros().obtenerMedicamentosEnfermero(id);
      final insulina = await GestorEnfermeros().obtenerInsulinaEnfermero(id);
      final observaciones = await GestorEnfermeros().obtenerObservacionesEnfermero(id);

      pacientesParaReporte.add({
        ...p,
        'historialGlucosa': glucosa.map((e) => {'valor': e['valor'], 'fecha': DateTime.parse(e['fecha'])}).toList(),
        'historialInsulina': insulina.map((e) => {'unidades': e['unidades'], 'fecha': DateTime.parse(e['fecha']).toLocal()}).toList(),
        'medicamentos': medicamentos,
        'observacionesTurno': observaciones.map((e) => e['nota'].toString()).toList(),
      });
    }

    final bytes = await ReportePdfService.generarReporteTurno(
      pacientes: pacientesParaReporte,
      enfermero: enfermeroObj,
      turno: turno,
    );

    final String idUnico = DateTime.now().millisecondsSinceEpoch.toString();
    await GestorEnfermeros().insertarReporte({
      'id': idUnico,
      'enfermero_id': enfermeroId,
      'turno': turno,
      'fecha': DateTime.now().toIso8601String(),
      'cantidad_pacientes': listaPacientes.length,
      'archivo_bytes': bytes,
    });

    await cargarDatosBD();
    return bytes;
  }

  Future<void> eliminarPaciente(int id) async {
    await GestorEnfermeros().eliminarPacienteEnfermero(id);
    await cargarDatosBD();
  }

  Future<void> cerrarSesion() async {
    await GestorUsuario().cerrarSesion();
  }
}
