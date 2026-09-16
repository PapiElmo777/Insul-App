import 'package:sqflite/sqflite.dart';

class EsquemaParametros {
  static Future<void> crear(DatabaseExecutor db) async {
    await db.execute('''CREATE TABLE parametros_dosis (
      id TEXT PRIMARY KEY NOT NULL,
      ambito TEXT NOT NULL CHECK (ambito IN ('personal','familiar','institucional')),
      paciente_id INTEGER NOT NULL,
      version INTEGER NOT NULL CHECK (version > 0),
      estado TEXT NOT NULL CHECK (estado IN ('borrador','autorizada','revocada')),
      motor_version TEXT NOT NULL,
      ric REAL, fsi REAL, objetivo REAL,
      glucosa_min REAL, glucosa_max REAL, umbral_hipo REAL,
      ajustes_actividad_json TEXT,
      autorizado_por INTEGER, autorizada_en TEXT,
      vigente_desde TEXT, vigente_hasta TEXT, referencia_validacion TEXT,
      creado_por INTEGER NOT NULL, creado_en TEXT NOT NULL,
      UNIQUE (ambito, paciente_id, version),
      CHECK (estado != 'autorizada' OR (
        ric > 0 AND ric IS NOT NULL AND fsi > 0 AND fsi IS NOT NULL AND
        objetivo > 0 AND objetivo IS NOT NULL AND glucosa_min IS NOT NULL AND
        glucosa_max > glucosa_min AND umbral_hipo IS NOT NULL AND
        ajustes_actividad_json IS NOT NULL AND autorizado_por IS NOT NULL AND
        autorizada_en IS NOT NULL AND vigente_desde IS NOT NULL AND vigente_hasta IS NOT NULL AND
        referencia_validacion IS NOT NULL AND length(trim(referencia_validacion)) > 0
      ))
    )''');
    await db.execute('''CREATE TRIGGER parametros_dosis_inmutables
      BEFORE UPDATE ON parametros_dosis BEGIN
      SELECT RAISE(ABORT, 'Crear una nueva versión de parámetros'); END''');
    await db.execute('''CREATE TRIGGER parametros_dosis_no_borrar
      BEFORE DELETE ON parametros_dosis BEGIN
      SELECT RAISE(ABORT, 'Conservar el historial de parámetros'); END''');
    await db.execute(
      'ALTER TABLE calculos_dosis ADD COLUMN parametros_id TEXT',
    );
    await db.execute(
      'ALTER TABLE calculos_dosis ADD COLUMN parametros_version INTEGER',
    );
    await db.execute(
      'ALTER TABLE calculos_dosis ADD COLUMN motor_version TEXT',
    );
    // Las filas históricas siguen sin versión: no se atribuye autorización retroactiva.
  }
}
