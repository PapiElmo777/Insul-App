import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:insulapp/dominio/referencias_ada.dart';
import 'package:insulapp/dominio/motor_dosis.dart';
import 'package:insulapp/modelos/parametros_dosis.dart';
import 'package:insulapp/modelos/paciente_clinico.dart';
import 'package:insulapp/database/database_helper.dart';
import 'package:insulapp/database/eventos_clinicos.dart';
import 'package:insulapp/database/esquema_clinico.dart';
import 'package:insulapp/database/esquema_parametros.dart';
import 'support/parametros_prueba.dart';
import 'eventos_clinicos_test.dart' show preparar;

void main() {
  sqfliteFfiInit();
  test(
    'referencias por contexto conservan fuente y no son una prescripción',
    () {
      expect(ReferenciasAda.generales.metaMin, 80);
      expect(ReferenciasAda.generales.metaMax, 130);
      expect(ReferenciasAda.generales.picoPosprandialMenorQue, 180);
      expect(ReferenciasAda.hospital.metaMin, 100);
      expect(ReferenciasAda.hospital.metaMax, 180);
      expect(ReferenciasAda.hospital.picoPosprandialMenorQue, isNull);
      expect(ReferenciasAda.individualizar.metaMin, isNull);
      expect(ReferenciasAda.generales.datos['es_prescripcion'], false);
    },
  );
  for (final caso in [
    (53.9, HipoglucemiaNumerica.nivel2),
    (54.0, HipoglucemiaNumerica.nivel1),
    (69.9, HipoglucemiaNumerica.nivel1),
    (70.0, HipoglucemiaNumerica.ninguna),
  ]) {
    test('clasificación en frontera ${caso.$1}', () {
      expect(ReferenciasAda.clasificar(caso.$1), caso.$2);
    });
  }
  test('clasificación rechaza lecturas inválidas', () {
    for (final v in [0.0, -1.0, double.infinity, double.nan]) {
      expect(() => ReferenciasAda.clasificar(v), throwsArgumentError);
    }
  });
  test('una configuración no puede rebajar el bloqueo por hipoglucemia', () {
    final p = ParametrosDosis.desdeMapa({
      ...parametrosDePrueba('personal'),
      'umbral_hipo': 50.0,
    });
    expect(
      () => MotorDosis.calcular(
        parametros: p,
        glucosa: 65,
        carbohidratos: 30,
        actividad: 'Sedentario',
        ahora: DateTime.now(),
      ),
      throwsA(isA<CalculoNoDisponible>()),
    );
  });
  for (final ambito in AmbitoPaciente.values) {
    test(
      'guardar referencia ${ambito.name} conserva pendientes y no autoriza parámetros',
      () async {
        final db = await DatabaseHelper.abrirBase(
          inMemoryDatabasePath,
          fabrica: databaseFactoryFfi,
        );
        try {
          await preparar(db);
          await db.update('sesion', {'usuario_id': ambito.index + 1});
          final e = EventosClinicos(db), p = PacienteClinico(ambito, 1);
          final c = ambito == AmbitoPaciente.institucional
              ? ContextoReferencia.hospitalNoCritico
              : ContextoReferencia.adultoAmbulatorio;
          final fecha = DateTime.utc(2026, 9, 15);
          for (var i = 0; i < 2; i++) {
            await e.guardarSolicitudConfiguracion(
              id: 'test',
              paciente: p,
              contexto: c,
              fecha: fecha,
            );
          }
          final s = (await e.solicitudesConfiguracion(p)).single;
          expect(s['estado'], 'pendiente_revision');
          expect(s['autor_usuario_id'], ambito.index + 1);
          final propuestos = jsonDecode(
            s['parametros_propuestos_json'] as String,
          );
          for (final k in [
            'ric',
            'fsi',
            'objetivo',
            'insulina_activa',
            'redondeo',
            'ajustes_actividad',
          ]) {
            expect(propuestos[k], isNull);
          }
          expect(await db.query('parametros_dosis'), isEmpty);
          expect(await e.parametrosVigentes(p), isNull);
        } finally {
          await db.close();
        }
      },
    );
  }
  test(
    'solicitud no invalida una configuración previamente autorizada',
    () async {
      final db = await DatabaseHelper.abrirBase(
        inMemoryDatabasePath,
        fabrica: databaseFactoryFfi,
      );
      try {
        await preparar(db);
        await prepararParametrosPrueba(db);
        final e = EventosClinicos(db);
        const p = PacienteClinico(AmbitoPaciente.personal, 1);
        await e.guardarSolicitudConfiguracion(
          id: 'test',
          paciente: p,
          contexto: ContextoReferencia.adultoAmbulatorio,
          fecha: DateTime.now(),
          ric: 12.5,
          fsi: 40,
        );
        expect((await e.parametrosVigentes(p))?.version, 1);
        final v = jsonDecode(
          (await e.solicitudesConfiguracion(
                p,
              )).single['parametros_propuestos_json']
              as String,
        );
        expect(v['ric'], 12.5);
        expect(v['fsi'], 40);
        expect(v['objetivo'], isNull);
        await expectLater(
          e.guardarSolicitudConfiguracion(
            id: 'otro',
            paciente: p,
            contexto: ContextoReferencia.hospitalNoCritico,
            fecha: DateTime.now(),
          ),
          throwsArgumentError,
        );
        await db.update('sesion', {'usuario_id': 2});
        await expectLater(e.solicitudesConfiguracion(p), throwsStateError);
      } finally {
        await db.close();
      }
    },
  );
  test('migración v3 a v4 conserva parámetros y no crea solicitudes', () async {
    final carpeta = await Directory.systemTemp.createTemp('insulapp_v4_');
    final ruta = '${carpeta.path}/base.db';
    var db = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (tx, _) async {
          for (final sql in File(
            'test/fixtures/esquema_v1.sql',
          ).readAsStringSync().split(';')) {
            if (sql.trim().isNotEmpty) await tx.execute(sql);
          }
          await EsquemaClinico.actualizar(tx);
          await EsquemaParametros.crear(tx);
        },
      ),
    );
    await preparar(db);
    await prepararParametrosPrueba(db);
    final antes = await db.query('parametros_dosis');
    await db.close();
    db = await DatabaseHelper.abrirBase(ruta, fabrica: databaseFactoryFfi);
    try {
      expect(await db.getVersion(), 4);
      expect(await db.query('parametros_dosis'), antes);
      expect(await db.query('solicitudes_configuracion'), isEmpty);
    } finally {
      await db.close();
      await carpeta.delete(recursive: true);
    }
  });
}
