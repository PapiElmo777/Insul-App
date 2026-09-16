import '../database_helper.dart';
import '../../modelos/paciente_clinico.dart';

class GestorCuidadores {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // METODOS PARA EL ROL DE CUIDADOR
  Future<int> insertarPacienteCuidador(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.insert('pacientes_cuidador', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerPacientesPorCuidador(int cuidadorId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query('pacientes_cuidador', where: 'cuidador_id = ?', whereArgs: [cuidadorId]);
  }

  Future<int> insertarOtroMedicamentoCuidador(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.insert('otros_medicamentos_cuidador', datos);
  }

  Future<int> insertarRegistroGlucosaCuidador(Map<String, dynamic> datos) async =>
      (await _dbHelper.eventos).registrarLectura(PacienteClinico(AmbitoPaciente.familiar, datos['paciente_cuidador_id'] as int), datos);


  Future<List<Map<String, dynamic>>> obtenerRegistrosGlucosaCuidador(int pacienteCuidadorId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query('registros_glucosa_cuidador',
        where: 'paciente_cuidador_id = ?',
        whereArgs: [pacienteCuidadorId],
        orderBy: 'fecha DESC'
    );
  }

  Future<int> actualizarPacienteCuidador(int id, Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.update(
      'pacientes_cuidador',
      datos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> actualizarMedicamentoCuidador(int id, Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.update(
      'otros_medicamentos_cuidador',
      datos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> obtenerMedicamentosDePacienteCuidador(int pacienteCuidadorId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query('otros_medicamentos_cuidador', where: 'paciente_cuidador_id = ?', whereArgs: [pacienteCuidadorId]);
  }

  Future<void> eliminarMedicamentoCuidador(int id) async {
    final baseDatos = await _dbHelper.db;
    await baseDatos.delete('otros_medicamentos_cuidador', where: 'id = ?', whereArgs: [id]);
  }

  // ── REPORTES DE CUIDADOR ───────────────────────────────────────────────
  Future<void> insertarReporteCuidador(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    await baseDatos.insert('reportes_cuidador', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerReportesDeFamiliar(int pacienteCuidadorId) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.query(
        'reportes_cuidador',
        where: 'paciente_cuidador_id = ?',
        whereArgs: [pacienteCuidadorId],
        orderBy: 'fecha DESC'
    );
  }

  Future<void> eliminarReporteCuidador(String id) async {
    final baseDatos = await _dbHelper.db;
    await baseDatos.delete('reportes_cuidador', where: 'id = ?', whereArgs: [id]);
  }
}