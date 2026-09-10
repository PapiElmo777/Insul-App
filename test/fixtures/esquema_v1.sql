-- Esquema original congelado para probar migraciones, sin datos personales.
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
      );
CREATE TABLE enfermeros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL UNIQUE,
        cedula TEXT,
        institucion TEXT,
        area TEXT,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
      );
CREATE TABLE pacientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL UNIQUE,
        sexo TEXT,
        edad INTEGER,
        tiempo_dx TEXT,
        tipo_diabetes TEXT,
        tipo_sanguineo TEXT, 
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
        enfermedades_cronicas TEXT,
        hospitalizaciones TEXT,
        cirugias TEXT,
        clinica TEXT,
        identificacion_completada INTEGER DEFAULT 0,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
      );
CREATE TABLE otros_medicamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        gramaje TEXT NOT NULL,
        proposito TEXT,
        frecuencia TEXT,
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE
      );
CREATE TABLE alimentos_frecuentes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        carbos_por_100g REAL NOT NULL,
        veces_usado INTEGER DEFAULT 1,
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE
      );
CREATE TABLE registros_glucosa (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        valor REAL NOT NULL,
        momento TEXT,
        notas TEXT,
        fecha TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE
      );
CREATE TABLE reportes_paciente (
        id TEXT PRIMARY KEY,
        paciente_id INTEGER NOT NULL,
        periodo TEXT,
        fecha TEXT,
        archivo_bytes BLOB,
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE
      );
CREATE TABLE sesion (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        usuario_id INTEGER,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      );
CREATE TABLE recordatorios_enfermero (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        enfermero_id INTEGER NOT NULL,
        paciente_id INTEGER,
        paciente_nombre TEXT,
        cama TEXT,
        mensaje TEXT NOT NULL,
        fecha_hora TEXT NOT NULL,
        completado INTEGER DEFAULT 0,
        FOREIGN KEY (enfermero_id) REFERENCES enfermeros(id) ON DELETE CASCADE
      );
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
      );
CREATE TABLE medicamentos_enfermero (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        nombre TEXT,
        dosis TEXT,
        frecuencia TEXT,
        suministrado INTEGER DEFAULT 0,
        FOREIGN KEY (paciente_id) REFERENCES pacientes_enfermero(id) ON DELETE CASCADE
      );
CREATE TABLE insulina_enfermero (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        unidades INTEGER,
        fecha TEXT,
        FOREIGN KEY (paciente_id) REFERENCES pacientes_enfermero(id) ON DELETE CASCADE
      );
CREATE TABLE glucosa_enfermero (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        valor INTEGER,
        fecha TEXT,
        FOREIGN KEY (paciente_id) REFERENCES pacientes_enfermero(id) ON DELETE CASCADE
      );
CREATE TABLE observaciones_enfermero (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        nota TEXT,
        fecha TEXT,
        FOREIGN KEY (paciente_id) REFERENCES pacientes_enfermero(id) ON DELETE CASCADE
      );
CREATE TABLE reportes_enfermero (
        id TEXT PRIMARY KEY,
        enfermero_id INTEGER NOT NULL,
        turno TEXT,
        fecha TEXT,
        cantidad_pacientes INTEGER,
        archivo_bytes BLOB,
        FOREIGN KEY (enfermero_id) REFERENCES enfermeros(id) ON DELETE CASCADE
      );
CREATE TABLE pacientes_cuidador (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cuidador_id INTEGER NOT NULL,
        tipo_paciente TEXT,
        parentesco TEXT,
        nombre TEXT NOT NULL,
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
        medico_nombre TEXT,
        riesgo_caidas TEXT,
        estado_cognitivo TEXT,
        autonomia_menor TEXT,
        contacto_escolar TEXT,
        identificacion_completada INTEGER DEFAULT 0,
        tipo_sanguineo TEXT,
        emergencia_nombre TEXT,
        emergencia_parentesco TEXT,
        emergencia_telefono TEXT,
        enfermedades_cronicas TEXT,
        hospitalizaciones TEXT,
        cirugias TEXT,
        clinica TEXT,
        FOREIGN KEY (cuidador_id) REFERENCES usuarios(id) ON DELETE CASCADE
      );
CREATE TABLE otros_medicamentos_cuidador (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_cuidador_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        gramaje TEXT NOT NULL,
        proposito TEXT,
        frecuencia TEXT,
        FOREIGN KEY (paciente_cuidador_id) REFERENCES pacientes_cuidador(id) ON DELETE CASCADE
      );
CREATE TABLE registros_glucosa_cuidador (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_cuidador_id INTEGER NOT NULL,
        valor REAL NOT NULL,
        momento TEXT,
        notas TEXT,
        fecha TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (paciente_cuidador_id) REFERENCES pacientes_cuidador(id) ON DELETE CASCADE
      );
CREATE TABLE reportes_cuidador (
        id TEXT PRIMARY KEY,
        paciente_cuidador_id INTEGER NOT NULL,
        periodo TEXT,
        fecha TEXT,
        archivo_bytes BLOB,
        FOREIGN KEY (paciente_cuidador_id) REFERENCES pacientes_cuidador(id) ON DELETE CASCADE
      );
