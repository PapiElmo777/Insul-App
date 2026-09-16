import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:insulapp/database/database_helper.dart';
import 'package:insulapp/database/esquema_clinico.dart';
import 'package:insulapp/database/eventos_clinicos.dart';
import 'package:insulapp/dominio/motor_dosis.dart';
import 'package:insulapp/modelos/paciente_clinico.dart';
import 'support/parametros_prueba.dart';
import 'eventos_clinicos_test.dart' show preparar;

void main() {
  sqfliteFfiInit();
  const paciente = PacienteClinico(AmbitoPaciente.personal, 1);
  late Database db;
  late EventosClinicos eventos;
  setUp(() async {
    db = await DatabaseHelper.abrirBase(
      inMemoryDatabasePath,
      fabrica: databaseFactoryFfi,
    );
    await preparar(db);
    eventos = EventosClinicos(db);
  });
  tearDown(() => db.close());
  Future<void> guardar({
    String parametrosId = 'TEST_ONLY_personal_1',
    double dosis = 3,
  }) => eventos.guardarCalculo(
    id: 'calculo',
    parametrosId: parametrosId,
    paciente: paciente,
    glucosa: 150,
    dosis: dosis,
    entradas: {'carbohidratos': 30.0, 'actividad': 'Sedentario'},
    momento: 'Almuerzo',
    fecha: DateTime.now(),
  );
  final bloqueado = throwsA(isA<CalculoNoDisponible>());
  test(
    'instalación/migración no crea autorizaciones ni permite guardar sin ellas',
    () async {
      expect(await db.query('parametros_dosis'), isEmpty);
      expect(await eventos.parametrosVigentes(paciente), isNull);
      await expectLater(guardar(), bloqueado);
      expect(await db.query('calculos_dosis'), isEmpty);
      expect(await db.query('registros_glucosa'), isEmpty);
    },
  );
  test('no confía en la dosis enviada por la pantalla', () async {
    await prepararParametrosPrueba(db);
    await expectLater(guardar(dosis: 100), bloqueado);
    expect(await db.query('registros_glucosa'), isEmpty);
    await guardar();
    final r = (await db.query('calculos_dosis')).single;
    expect(r['parametros_id'], 'TEST_ONLY_personal_1');
    expect(r['parametros_version'], 1);
    expect(
      jsonDecode(r['entradas_json'] as String)['parametros']['autorizado_por'],
      99,
    );
  });
  for (final estado in ['autorizada', 'revocada', 'borrador']) {
    test(
      'una nueva versión $estado invalida un resultado anterior sin volver a una versión vieja',
      () async {
        await prepararParametrosPrueba(db);
        expect((await eventos.parametrosVigentes(paciente))?.version, 1);
        await db.insert(
          'parametros_dosis',
          parametrosDePrueba('personal', version: 2, estado: estado),
        );
        await expectLater(guardar(), bloqueado);
        expect(await db.query('registros_glucosa'), isEmpty);
        expect(
          (await eventos.parametrosVigentes(paciente))?.version,
          estado == 'autorizada' ? 2 : null,
        );
      },
    );
  }
  test('no admite autorización de paciente ni credenciales ausentes', () async {
    await db.insert('parametros_dosis', {
      ...parametrosDePrueba('personal'),
      'autorizado_por': 1,
    });
    expect(await eventos.parametrosVigentes(paciente), isNull);
    await expectLater(guardar(), bloqueado);
  });
  test('las versiones no se editan ni borran', () async {
    await prepararParametrosPrueba(db);
    await expectLater(
      db.update(
        'parametros_dosis',
        {'ric': 2},
        where: 'id = ?',
        whereArgs: ['TEST_ONLY_personal_1'],
      ),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      db.delete('parametros_dosis'),
      throwsA(isA<DatabaseException>()),
    );
  });
  test('configuración corrupta y vigencia vencida se bloquean', () async {
    await prepararParametrosPrueba(db);
    await db.insert('parametros_dosis', {
      ...parametrosDePrueba('personal', version: 2),
      'ajustes_actividad_json': 'incorrecto',
    });
    expect(await eventos.parametrosVigentes(paciente), isNull);
    await db.insert('parametros_dosis', {
      ...parametrosDePrueba('personal', version: 3),
      'vigente_hasta': '2020-01-01T00:00:00Z',
    });
    expect(await eventos.parametrosVigentes(paciente), isNull);
  });
  test('migra v2 sin atribuir autorización a cálculos históricos', () async {
    final carpeta = await Directory.systemTemp.createTemp('insulapp_v3_');
    final ruta = '${carpeta.path}/base.db';
    var base = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (tx, _) async {
          for (final sql in File(
            'test/fixtures/esquema_v1.sql',
          ).readAsStringSync().split(';')) {
            if (sql.trim().isNotEmpty) await tx.execute(sql);
          }
          await EsquemaClinico.actualizar(tx);
        },
      ),
    );
    await base.insert('calculos_dosis', {
      'id': 'antiguo',
      'ambito': 'personal',
      'paciente_id': 1,
      'autor_usuario_id': 1,
      'fecha': '2026-09-09T12:00:00',
      'procedencia': 'calculadora_local',
      'estado': 'calculada',
      'entradas_json': '{"ric":15}',
      'dosis': 3.0,
      'momento': 'Almuerzo',
      'lectura_id': 1,
    });
    final anterior = (await base.query('calculos_dosis')).single;
    await base.close();
    base = await DatabaseHelper.abrirBase(ruta, fabrica: databaseFactoryFfi);
    try {
      expect(await base.getVersion(), 4);
      final actual = (await base.query('calculos_dosis')).single;
      for (final k in anterior.keys) {
        expect(actual[k], anterior[k]);
      }
      expect(actual['parametros_id'], isNull);
      expect(await base.query('parametros_dosis'), isEmpty);
      await base.close();
      base = await DatabaseHelper.abrirBase(ruta, fabrica: databaseFactoryFfi);
      expect(await base.query('calculos_dosis'), hasLength(1));
    } finally {
      await base.close();
      await carpeta.delete(recursive: true);
    }
  });
}
