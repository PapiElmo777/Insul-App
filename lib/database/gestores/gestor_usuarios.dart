import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';


class GestorUsuario{

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertarUsuario(Map<String, dynamic> datos) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.insert('usuarios', datos,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<Map<String, dynamic>?> obtenerUsuarioPorCorreo(String correo) async {
    final baseDatos = await _dbHelper.db;
    final resultado = await baseDatos.query(
      'usuarios',
      where: 'correo = ?',
      whereArgs: [correo],
      limit: 1,
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  Future<Map<String, dynamic>?> obtenerUsuarioPorId(int id) async {
    final baseDatos = await _dbHelper.db;
    final resultado = await baseDatos.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  Future<int> actualizarFotoPerfil(int usuarioId, String rutaFoto) async {
    final baseDatos = await _dbHelper.db;
    return await baseDatos.update(
      'usuarios',
      {'foto_perfil': rutaFoto},
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
  }

  // ── SESIÓN ────────────────────────────────────────────────────────────────

  Future<void> guardarSesion(int usuarioId) async {
    final baseDatos = await _dbHelper.db;
    await baseDatos.insert(
      'sesion',
      {'id': 1, 'usuario_id': usuarioId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> obtenerSesionActiva() async {
    final baseDatos = await _dbHelper.db;
    final resultado = await baseDatos.query('sesion', where: 'id = 1', limit: 1);
    if (resultado.isNotEmpty) return resultado.first['usuario_id'] as int?;
    return null;
  }

  Future<void> cerrarSesion() async {
    final baseDatos = await _dbHelper.db;
    await baseDatos.delete('sesion', where: 'id = 1');
  }
}



