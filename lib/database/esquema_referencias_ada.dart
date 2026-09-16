import 'package:sqflite/sqflite.dart';

class EsquemaReferenciasAda {
  static Future<void> crear(DatabaseExecutor db) async {
    await db.execute('''CREATE TABLE solicitudes_configuracion (
      id TEXT PRIMARY KEY NOT NULL,
      ambito TEXT NOT NULL CHECK (ambito IN ('personal','familiar','institucional')),
      paciente_id INTEGER NOT NULL,
      autor_usuario_id INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      contexto TEXT NOT NULL,
      referencia_json TEXT NOT NULL,
      parametros_propuestos_json TEXT NOT NULL,
      estado TEXT NOT NULL CHECK (estado = 'pendiente_revision')
    )''');
    await db.execute(
      'CREATE INDEX idx_solicitud_paciente ON solicitudes_configuracion(ambito, paciente_id, fecha)',
    );
  }
}
