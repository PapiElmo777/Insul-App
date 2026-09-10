import 'package:sqflite/sqflite.dart';

/// Migración aditiva: nunca interpreta notas antiguas como administraciones.
class EsquemaClinico {
  static const version = 2;

  static Future<void> actualizar(DatabaseExecutor db) async {
    for (final tabla in [
      'registros_glucosa',
      'registros_glucosa_cuidador',
      'glucosa_enfermero',
    ]) {
      await db.execute(
        'ALTER TABLE $tabla ADD COLUMN autor_usuario_id INTEGER',
      );
      await db.execute(
        "ALTER TABLE $tabla ADD COLUMN procedencia TEXT NOT NULL DEFAULT 'legado'",
      );
    }
    await db.execute('''CREATE TABLE calculos_dosis (
      id TEXT PRIMARY KEY NOT NULL,
      ambito TEXT NOT NULL CHECK (ambito IN ('personal','familiar','institucional')),
      paciente_id INTEGER NOT NULL,
      autor_usuario_id INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      procedencia TEXT NOT NULL,
      estado TEXT NOT NULL DEFAULT 'calculada' CHECK (estado = 'calculada'),
      entradas_json TEXT NOT NULL,
      dosis REAL NOT NULL CHECK (dosis >= 0),
      momento TEXT NOT NULL,
      lectura_id INTEGER NOT NULL,
      FOREIGN KEY (autor_usuario_id) REFERENCES usuarios(id)
    )''');
    await db.execute('''CREATE TABLE administraciones (
      id TEXT PRIMARY KEY NOT NULL,
      ambito TEXT NOT NULL CHECK (ambito IN ('personal','familiar','institucional')),
      paciente_id INTEGER NOT NULL,
      autor_usuario_id INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      fecha_registro TEXT NOT NULL,
      procedencia TEXT NOT NULL,
      estado TEXT NOT NULL CHECK (estado IN ('confirmada','anulada')),
      medicamento TEXT NOT NULL,
      dosis_texto TEXT NOT NULL,
      cantidad REAL CHECK (cantidad > 0),
      unidad TEXT,
      momento TEXT NOT NULL,
      notas TEXT NOT NULL,
      calculo_id TEXT,
      medicamento_enfermero_id INTEGER,
      anulada_por INTEGER,
      fecha_anulacion TEXT,
      motivo_anulacion TEXT,
      FOREIGN KEY (autor_usuario_id) REFERENCES usuarios(id),
      FOREIGN KEY (calculo_id) REFERENCES calculos_dosis(id)
    )''');
    // Base de persistencia para el posterior motor de alertas. No activa reglas.
    await db.execute('''CREATE TABLE alertas_clinicas (
      id TEXT PRIMARY KEY NOT NULL,
      ambito TEXT NOT NULL CHECK (ambito IN ('personal','familiar','institucional')),
      paciente_id INTEGER NOT NULL,
      autor_usuario_id INTEGER NOT NULL,
      lectura_id INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      procedencia TEXT NOT NULL,
      regla_version TEXT NOT NULL,
      estado TEXT NOT NULL CHECK (estado IN ('emitida','reconocida','cerrada')),
      detalle_json TEXT NOT NULL
    )''');
    for (final tabla in [
      'calculos_dosis',
      'administraciones',
      'alertas_clinicas',
    ]) {
      await db.execute(
        'CREATE INDEX idx_${tabla}_paciente_fecha ON $tabla(ambito, paciente_id, fecha)',
      );
    }
  }
}
