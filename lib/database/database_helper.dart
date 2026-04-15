import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instancia = DatabaseHelper._interno();
  static Database? _db;

  factory DatabaseHelper() => _instancia;
  DatabaseHelper._interno();

  Future<Database> get db async {
    _db ??= await _inicializarDB();
    return _db!;
  }

  Future<Database> _inicializarDB() async {
    final rutaDB = await getDatabasesPath();
    final ruta = join(rutaDB, 'insulapp.db');

    return await openDatabase(
      ruta,
      version: 1,
      onCreate: _crearTablas,
    );
  }

  Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellidos TEXT NOT NULL,
        correo TEXT NOT NULL UNIQUE,
        contrasena TEXT NOT NULL,
        telefono TEXT,
        lada TEXT DEFAULT '+52',
        rol TEXT NOT NULL,
        foto_perfil TEXT,
        fecha_registro TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE enfermeros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL UNIQUE,
        cedula TEXT,
        institucion TEXT,
        area TEXT,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE pacientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL UNIQUE,
        sexo TEXT,
        edad INTEGER,
        tiempo_dx TEXT,
        tipo_diabetes TEXT,
        alergias TEXT,
        peso REAL,
        altura REAL,
        imc REAL,
        limite_hipo REAL DEFAULT 70,
        limite_hiper REAL DEFAULT 180,
        rango_min REAL DEFAULT 80,
        rango_max REAL DEFAULT 130,
        metodo_insulina TEXT,
        insulina_basal_marca TEXT,
        insulina_basal_dosis TEXT,
        insulina_rapida_marca TEXT,
        insulina_rapida_patron TEXT,
        bomba_unidades TEXT,
        bomba_frecuencia TEXT,
        med_oral_nombre TEXT,
        med_oral_dosis TEXT,
        frecuencia_monitoreo TEXT,
        actividad_fisica TEXT,
        emergencia_nombre TEXT,
        emergencia_parentesco TEXT,
        emergencia_telefono TEXT,
        medico_nombre TEXT,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE otros_medicamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        gramaje TEXT NOT NULL,
        proposito TEXT,
        frecuencia TEXT,
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE registros_glucosa (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        valor REAL NOT NULL,
        momento TEXT,
        notas TEXT,
        fecha TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sesion (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        usuario_id INTEGER,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');
  }

  // ── USUARIOS ──────────────────────────────────────────────────────────────

  Future<int> insertarUsuario(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.insert('usuarios', datos,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<Map<String, dynamic>?> obtenerUsuarioPorCorreo(String correo) async {
    final baseDatos = await db;
    final resultado = await baseDatos.query(
      'usuarios',
      where: 'correo = ?',
      whereArgs: [correo],
      limit: 1,
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  Future<Map<String, dynamic>?> obtenerUsuarioPorId(int id) async {
    final baseDatos = await db;
    final resultado = await baseDatos.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  Future<int> actualizarFotoPerfil(int usuarioId, String rutaFoto) async {
    final baseDatos = await db;
    return await baseDatos.update(
      'usuarios',
      {'foto_perfil': rutaFoto},
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
  }

  // ── ENFERMEROS ────────────────────────────────────────────────────────────

  Future<int> insertarEnfermero(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.insert('enfermeros', datos,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> obtenerEnfermeroPorUsuario(int usuarioId) async {
    final baseDatos = await db;
    final resultado = await baseDatos.query(
      'enfermeros',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      limit: 1,
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  Future<int> actualizarEnfermero(int usuarioId, Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.update(
      'enfermeros',
      datos,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
  }

  // ── PACIENTES ─────────────────────────────────────────────────────────────

  Future<int> insertarPaciente(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.insert('pacientes', datos,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> obtenerPacientePorUsuario(int usuarioId) async {
    final baseDatos = await db;
    final resultado = await baseDatos.query(
      'pacientes',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      limit: 1,
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  Future<int> actualizarPaciente(int usuarioId, Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.update(
      'pacientes',
      datos,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
  }

  // ── OTROS MEDICAMENTOS ────────────────────────────────────────────────────

  Future<int> insertarOtroMedicamento(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.insert('otros_medicamentos', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerMedicamentosDePaciente(int pacienteId) async {
    final baseDatos = await db;
    return await baseDatos.query(
      'otros_medicamentos',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
    );
  }

  Future<void> eliminarMedicamentosDePaciente(int pacienteId) async {
    final baseDatos = await db;
    await baseDatos.delete(
      'otros_medicamentos',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
    );
  }

  // ── GLUCOSA ───────────────────────────────────────────────────────────────

  Future<int> insertarRegistroGlucosa(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.insert('registros_glucosa', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerRegistrosGlucosa(int pacienteId) async {
    final baseDatos = await db;
    return await baseDatos.query(
      'registros_glucosa',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
      orderBy: 'fecha DESC',
    );
  }

  Future<List<Map<String, dynamic>>> obtenerUltimosRegistrosGlucosa(
      int pacienteId, int limite) async {
    final baseDatos = await db;
    return await baseDatos.query(
      'registros_glucosa',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
      orderBy: 'fecha DESC',
      limit: limite,
    );
  }

  // ── SESIÓN ────────────────────────────────────────────────────────────────

  Future<void> guardarSesion(int usuarioId) async {
    final baseDatos = await db;
    await baseDatos.insert(
      'sesion',
      {'id': 1, 'usuario_id': usuarioId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> obtenerSesionActiva() async {
    final baseDatos = await db;
    final resultado = await baseDatos.query('sesion', where: 'id = 1', limit: 1);
    if (resultado.isNotEmpty) {
      return resultado.first['usuario_id'] as int?;
    }
    return null;
  }

  Future<void> cerrarSesion() async {
    final baseDatos = await db;
    await baseDatos.delete('sesion', where: 'id = 1');
  }
}
