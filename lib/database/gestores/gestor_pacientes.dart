import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../modelos/paciente_clinico.dart';

class GestorPacientes {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ── PACIENTES APP (CUENTAS REGISTRADAS) ───────────────────────────────────

  Future<int> insertarPaciente(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.insert('pacientes', datos, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> obtenerPacientePorUsuario(int usuarioId) async {
    final baseDatos = await _dbHelper.db;
    final resultado = await baseDatos.query(
      'pacientes',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      limit: 1,
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  Future<int> actualizarPaciente(int usuarioId, Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.update(
      'pacientes',
      datos,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
  }

  Future<int> insertarOtroMedicamento(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.insert('otros_medicamentos', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerMedicamentosDePaciente(int pacienteId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query(
      'otros_medicamentos',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
    );
  }

  Future<int> insertarRegistroGlucosa(Map<String, dynamic> datos) async =>
      (await _dbHelper.eventos).registrarLectura(PacienteClinico(AmbitoPaciente.personal, datos['paciente_id'] as int), datos);

  Future<List<Map<String, dynamic>>> obtenerRegistrosGlucosa(int pacienteId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query(
      'registros_glucosa',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
      orderBy: 'fecha DESC',
    );
  }

  // Reportes PDF del Paciente
  Future<void> insertarReportePaciente(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    await baseDatos.insert('reportes_paciente', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerReportesDePaciente(int pacienteId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query(
      'reportes_paciente',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
      orderBy: 'fecha DESC',
    );
  }

  // Alimentos frecuentes
  Future<void> guardarAlimentoFrecuente(int pacienteId, String nombre, double carbosPor100g) async {
    final baseDatos = await _dbHelper.db;
    final existe = await baseDatos.query('alimentos_frecuentes', where: 'paciente_id = ? AND nombre = ?', whereArgs: [pacienteId, nombre]);

    if (existe.isNotEmpty) {
      int usoActual = existe.first['veces_usado'] as int;
      await baseDatos.update('alimentos_frecuentes', {'veces_usado': usoActual + 1}, where: 'id = ?', whereArgs: [existe.first['id']]);
    } else {
      await baseDatos.insert('alimentos_frecuentes', {
        'paciente_id': pacienteId,
        'nombre': nombre,
        'carbos_por_100g': carbosPor100g,
        'veces_usado': 1
      });
    }
  }

  Future<List<Map<String, dynamic>>> obtenerAlimentosFrecuentes(int pacienteId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query(
      'alimentos_frecuentes',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
      orderBy: 'veces_usado DESC',
      limit: 10,
    );
  }
}
