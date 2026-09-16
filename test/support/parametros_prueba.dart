import 'dart:convert';
import 'package:sqflite/sqflite.dart';

/// Datos sintéticos exclusivos de test. No son una pauta ni una autorización clínica.
Map<String, Object?> parametrosDePrueba(
  String ambito, {
  int version = 1,
  String estado = 'autorizada',
}) => {
  'id': 'TEST_ONLY_${ambito}_$version',
  'ambito': ambito,
  'paciente_id': 1,
  'version': version,
  'estado': estado,
  'motor_version': ambito == 'institucional'
      ? 'hospitalario_v1'
      : 'domestico_v1',
  'ric': 15.0,
  'fsi': 50.0,
  'objetivo': 100.0,
  'glucosa_min': 20.0,
  'glucosa_max': 600.0,
  'umbral_hipo': 70.0,
  'ajustes_actividad_json': jsonEncode({
    'Sedentario': 0.0,
    'Ligero': 0.1,
    'Moderado': 0.2,
    'Intenso': 0.3,
  }),
  'autorizado_por': 99,
  'autorizada_en': '2020-01-01T00:00:00.000Z',
  'vigente_desde': '2020-01-01T00:00:00.000Z',
  'vigente_hasta': '2100-01-01T00:00:00.000Z',
  'referencia_validacion': 'TEST_ONLY_NO_VALIDACION_CLINICA',
  'creado_por': 99,
  'creado_en': '2020-01-01T00:00:00.000Z',
};

Future<void> prepararParametrosPrueba(Database db) async {
  await db.insert('usuarios', {
    'id': 99,
    'nombre': 'Test',
    'apellidos': 'Fixture',
    'correo': 'solo-pruebas@example.invalid',
    'contrasena': 'fixture',
    'rol': 'medico',
  });
  for (final ambito in ['personal', 'familiar', 'institucional']) {
    await db.insert('parametros_dosis', parametrosDePrueba(ambito));
  }
}
