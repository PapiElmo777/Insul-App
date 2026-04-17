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
        insulina_basal_horario TEXT,
        insulina_rapida_marca TEXT,
        insulina_rapida_patron TEXT,
        insulina_rapida_horario TEXT,
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
      CREATE TABLE reportes_paciente (
        id TEXT PRIMARY KEY,
        paciente_id INTEGER NOT NULL,
        periodo TEXT,
        fecha TEXT,
        archivo_bytes BLOB,
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

    // ────────────────────────────────────────────────────────────────────────
    // TABLAS EXCLUSIVAS PARA EL ENFERMERO Y SUS PACIENTES LOCALES
    // ────────────────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE pacientes_enfermero (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        enfermero_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        edad TEXT,
        expediente TEXT,
        ubicacion TEXT,
        tipo_diabetes TEXT,
        alergias TEXT,
        dieta TEXT,
        estado_general TEXT,
        insulina_basal_horario TEXT,
        insulina_rapida_horario TEXT,
        hipo_limit INTEGER DEFAULT 70,
        hiper_limit INTEGER DEFAULT 180,
        rango_min INTEGER DEFAULT 80,
        rango_max INTEGER DEFAULT 130,
        FOREIGN KEY (enfermero_id) REFERENCES enfermeros(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE medicamentos_enfermero (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        nombre TEXT,
        dosis TEXT,
        frecuencia TEXT,
        suministrado INTEGER DEFAULT 0,
        FOREIGN KEY (paciente_id) REFERENCES pacientes_enfermero(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE insulina_enfermero (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        unidades INTEGER,
        fecha TEXT,
        FOREIGN KEY (paciente_id) REFERENCES pacientes_enfermero(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE glucosa_enfermero (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        valor INTEGER,
        fecha TEXT,
        FOREIGN KEY (paciente_id) REFERENCES pacientes_enfermero(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE observaciones_enfermero (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        nota TEXT,
        fecha TEXT,
        FOREIGN KEY (paciente_id) REFERENCES pacientes_enfermero(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reportes_enfermero (
        id TEXT PRIMARY KEY,
        enfermero_id INTEGER NOT NULL,
        turno TEXT,
        fecha TEXT,
        cantidad_pacientes INTEGER,
        archivo_bytes BLOB,
        FOREIGN KEY (enfermero_id) REFERENCES enfermeros(id) ON DELETE CASCADE
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

  // ── PACIENTES APP (CUENTAS REGISTRADAS) ───────────────────────────────────

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

  // Reportes PDF del Paciente
  Future<void> insertarReportePaciente(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    await baseDatos.insert('reportes_paciente', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerReportesDePaciente(int pacienteId) async {
    final baseDatos = await db;
    return await baseDatos.query(
      'reportes_paciente',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
      orderBy: 'fecha DESC',
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

  // ───────────────────────────────────────────────
  // MÉTODOS PARA EL ROL DE ENFERMERO
  // ───────────────────────────────────────────────

  Future<int> insertarPacienteEnfermero(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.insert('pacientes_enfermero', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerPacientesDeEnfermero(int enfermeroId) async {
    final baseDatos = await db;
    return await baseDatos.query('pacientes_enfermero', where: 'enfermero_id = ?', whereArgs: [enfermeroId]);
  }

  Future<int> actualizarPacienteEnfermero(int id, Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.update('pacientes_enfermero', datos, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> eliminarPacienteEnfermero(int id) async {
    final baseDatos = await db;
    await baseDatos.delete('pacientes_enfermero', where: 'id = ?', whereArgs: [id]);
  }

  // Medicamentos del Enfermero
  Future<int> insertarMedicamentoEnfermero(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.insert('medicamentos_enfermero', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerMedicamentosEnfermero(int pacienteId) async {
    final baseDatos = await db;
    return await baseDatos.query('medicamentos_enfermero', where: 'paciente_id = ?', whereArgs: [pacienteId]);
  }

  Future<void> actualizarEstadoMedicamentoEnfermero(int id, int suministrado) async {
    final baseDatos = await db;
    await baseDatos.update('medicamentos_enfermero', {'suministrado': suministrado}, where: 'id = ?', whereArgs: [id]);
  }

  // Glucosa del Enfermero
  Future<int> insertarGlucosaEnfermero(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.insert('glucosa_enfermero', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerGlucosaEnfermero(int pacienteId) async {
    final baseDatos = await db;
    return await baseDatos.query('glucosa_enfermero', where: 'paciente_id = ?', whereArgs: [pacienteId], orderBy: 'fecha DESC');
  }

  // Insulina del Enfermero
  Future<int> insertarInsulinaEnfermero(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.insert('insulina_enfermero', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerInsulinaEnfermero(int pacienteId) async {
    final baseDatos = await db;
    return await baseDatos.query('insulina_enfermero', where: 'paciente_id = ?', whereArgs: [pacienteId], orderBy: 'fecha DESC');
  }

  // Observaciones del Enfermero
  Future<int> insertarObservacionEnfermero(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    return await baseDatos.insert('observaciones_enfermero', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerObservacionesEnfermero(int pacienteId) async {
    final baseDatos = await db;
    return await baseDatos.query('observaciones_enfermero', where: 'paciente_id = ?', whereArgs: [pacienteId], orderBy: 'fecha DESC');
  }

  // Reportes PDF
  Future<void> insertarReporte(Map<String, dynamic> datos) async {
    final baseDatos = await db;
    await baseDatos.insert('reportes_enfermero', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerReportesDeEnfermero(int enfermeroId) async {
    final baseDatos = await db;
    return await baseDatos.query('reportes_enfermero', where: 'enfermero_id = ?', whereArgs: [enfermeroId], orderBy: 'fecha DESC');
  }
}