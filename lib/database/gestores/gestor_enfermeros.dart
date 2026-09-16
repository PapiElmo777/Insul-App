import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../modelos/paciente_clinico.dart';

class GestorEnfermeros {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ── ENFERMEROS ────────────────────────────────────────────────────────────

  Future<int> insertarEnfermero(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.insert('enfermeros', datos, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> obtenerEnfermeroPorUsuario(int usuarioId) async {
    final baseDatos = await _dbHelper.db;
    final resultado = await baseDatos.query(
      'enfermeros',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      limit: 1,
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  Future<int> actualizarEnfermero(int usuarioId, Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.update(
      'enfermeros',
      datos,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
  }

  // ── MÉTODOS ROL ENFERMERO ───────────────────────────────────────────────

  Future<int> insertarPacienteEnfermero(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.insert('pacientes_enfermero', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerPacientesDeEnfermero(int enfermeroId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query('pacientes_enfermero', where: 'enfermero_id = ?', whereArgs: [enfermeroId]);
  }

  Future<int> actualizarPacienteEnfermero(int id, Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.update('pacientes_enfermero', datos, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> eliminarPacienteEnfermero(int id) async {
    final baseDatos = await _dbHelper.db;
    await baseDatos.delete('pacientes_enfermero', where: 'id = ?', whereArgs: [id]);
  }

  // Medicamentos del Enfermero
  Future<int> insertarMedicamentoEnfermero(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.insert('medicamentos_enfermero', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerMedicamentosEnfermero(int pacienteId) async {
    final baseDatos = await _dbHelper.db;
    final esquema = await baseDatos.query('medicamentos_enfermero', where: 'paciente_id = ?', whereArgs: [pacienteId]);
    final confirmadas = await (await _dbHelper.eventos).administraciones(PacienteClinico(AmbitoPaciente.institucional, pacienteId));
    return esquema.map((m) {
      final aplicaciones = confirmadas.where((a) => a['medicamento_enfermero_id'] == m['id']);
      return {...m, 'suministrado_legacy': m['suministrado'],
        'suministrado': aplicaciones.isEmpty ? 0 : 1,
        'administracion_id': aplicaciones.isEmpty ? null : aplicaciones.first['id'],
      };
    }).toList();
  }

  // Glucosa del Enfermero
  Future<int> insertarGlucosaEnfermero(Map<String, dynamic> datos) async =>
      (await _dbHelper.eventos).registrarLectura(PacienteClinico(AmbitoPaciente.institucional, datos['paciente_id'] as int), datos);


  Future<List<Map<String, dynamic>>> obtenerGlucosaEnfermero(int pacienteId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query('glucosa_enfermero', where: 'paciente_id = ?', whereArgs: [pacienteId], orderBy: 'fecha DESC');
  }

  // Insulina del Enfermero
  Future<List<Map<String, dynamic>>> obtenerInsulinaEnfermero(int pacienteId) async {
    final registros = await (await _dbHelper.eventos).administraciones(PacienteClinico(AmbitoPaciente.institucional, pacienteId));
    return registros.where((r) => r['unidad'] == 'UI').map((r) => {
      ...r, 'unidades': r['cantidad'],
    }).toList();
  }

  // Observaciones del Enfermero
  Future<int> insertarObservacionEnfermero(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.insert('observaciones_enfermero', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerObservacionesEnfermero(int pacienteId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query('observaciones_enfermero', where: 'paciente_id = ?', whereArgs: [pacienteId], orderBy: 'fecha DESC');
  }

  // Reportes PDF
  Future<void> insertarReporte(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    await baseDatos.insert('reportes_enfermero', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerReportesDeEnfermero(int enfermeroId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query('reportes_enfermero', where: 'enfermero_id = ?', whereArgs: [enfermeroId], orderBy: 'fecha DESC');
  }

  // ── RECORDATORIOS DEL ENFERMERO ───────────────────────────────────────────
  Future<int> insertarRecordatorioEnfermero(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.insert('recordatorios_enfermero', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerRecordatoriosEnfermero(int enfermeroId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query('recordatorios_enfermero',
        where: 'enfermero_id = ?',
        whereArgs: [enfermeroId],
        orderBy: 'completado ASC, fecha_hora ASC'
    );
  }

  Future<void> actualizarEstadoRecordatorio(int id, int completado) async {
    final baseDatos = await _dbHelper.db;
    await baseDatos.update('recordatorios_enfermero', {'completado': completado}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> eliminarRecordatorio(int id) async {
    final baseDatos = await _dbHelper.db;
    await baseDatos.delete('recordatorios_enfermero', where: 'id = ?', whereArgs: [id]);
  }
}