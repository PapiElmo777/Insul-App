import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:insulapp/database/database_helper.dart';
import 'package:insulapp/database/eventos_clinicos.dart';
import 'package:insulapp/modelos/paciente_clinico.dart';

const personal = PacienteClinico(AmbitoPaciente.personal, 1);
const familiar = PacienteClinico(AmbitoPaciente.familiar, 1);
const hospital = PacienteClinico(AmbitoPaciente.institucional, 1);
final fecha = DateTime.utc(2026, 9, 9, 12);

Future<void> preparar(Database db) async {
  for (var i = 1; i <= 3; i++) {
    await db.insert('usuarios', {
      'id': i,
      'nombre': 'Prueba',
      'apellidos': 'Local',
      'correo': 'prueba$i@example.invalid',
      'contrasena': 'fixture',
      'rol': ['paciente', 'cuidador', 'enfermero'][i - 1],
    });
  }
  await db.insert('pacientes', {'id': 1, 'usuario_id': 1});
  await db.insert('pacientes_cuidador', {
    'id': 1,
    'cuidador_id': 2,
    'nombre': 'Familiar',
  });
  await db.insert('enfermeros', {'id': 1, 'usuario_id': 3});
  await db.insert('pacientes_enfermero', {
    'id': 1,
    'enfermero_id': 1,
    'nombre': 'Institucional',
  });
  await db.insert('sesion', {'id': 1, 'usuario_id': 1});
}

Future<void> calcular(
  EventosClinicos e, {
  PacienteClinico p = personal,
  String id = 'calculo',
}) => e.guardarCalculo(
  id: id,
  paciente: p,
  glucosa: 150.5,
  dosis: 3.5,
  entradas: {'ric': 15.0, 'carbohidratos': 30.0},
  momento: 'Almuerzo',
  fecha: fecha,
);

Future<void> confirmar(
  EventosClinicos e, {
  PacienteClinico p = personal,
  String id = 'aplicacion',
  bool confirmada = true,
  String? calculoId,
  DateTime? cuando,
}) => e.confirmarAdministracion(
  id: id,
  paciente: p,
  confirmada: confirmada,
  medicamento: 'Insulina de prueba',
  dosisTexto: '3 UI',
  cantidad: 3,
  unidad: 'UI',
  fecha: cuando ?? fecha,
  calculoId: calculoId,
);

void main() {
  sqfliteFfiInit();
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

  test('instalación nueva crea esquema 2 y tablas separadas', () async {
    expect(await db.getVersion(), 2);
    for (final tabla in [
      'calculos_dosis',
      'administraciones',
      'alertas_clinicas',
    ]) {
      expect(await db.query(tabla), isEmpty);
    }
  });
  test('calcular guarda lectura y cálculo, nunca administración', () async {
    await calcular(eventos);
    final lecturas = await db.query('registros_glucosa');
    final calculos = await eventos.calculos(personal);
    expect(lecturas.single['valor'], 150.5);
    expect(lecturas.single['notas'], '');
    expect(calculos.single['lectura_id'], lecturas.single['id']);
    expect(jsonDecode(calculos.single['entradas_json'] as String)['ric'], 15.0);
    expect(calculos.single['autor_usuario_id'], 1);
    expect(await eventos.administraciones(personal), isEmpty);
  });
  test(
    'confirmar requiere acción explícita y no crea una glucosa cero',
    () async {
      await expectLater(
        confirmar(eventos, confirmada: false),
        throwsArgumentError,
      );
      expect(await eventos.administraciones(personal), isEmpty);
      await confirmar(eventos);
      expect(
        (await eventos.administraciones(personal)).single['estado'],
        'confirmada',
      );
      expect(await db.query('registros_glucosa'), isEmpty);
    },
  );
  test('confirmación vinculada conserva el cálculo como cálculo', () async {
    await calcular(eventos);
    await confirmar(eventos, calculoId: 'calculo');
    expect((await eventos.calculos(personal)).single['estado'], 'calculada');
    expect(
      (await eventos.administraciones(personal)).single['calculo_id'],
      'calculo',
    );
  });
  test(
    'reintentos no duplican lecturas, cálculos ni administraciones',
    () async {
      await calcular(eventos);
      await calcular(eventos);
      await confirmar(eventos);
      await confirmar(eventos);
      expect(await eventos.calculos(personal), hasLength(1));
      expect(await db.query('registros_glucosa'), hasLength(1));
      expect(await eventos.administraciones(personal), hasLength(1));
      await expectLater(
        eventos.confirmarAdministracion(
          id: 'aplicacion',
          paciente: personal,
          confirmada: true,
          medicamento: 'Distinta',
          dosisTexto: '5 UI',
          fecha: fecha,
        ),
        throwsStateError,
      );
    },
  );
  test('un fallo al insertar el cálculo revierte también la lectura', () async {
    await db.execute(
      "CREATE TRIGGER falla BEFORE INSERT ON calculos_dosis BEGIN SELECT RAISE(ABORT, 'fallo simulado'); END",
    );
    await expectLater(calcular(eventos), throwsA(isA<DatabaseException>()));
    expect(await db.query('registros_glucosa'), isEmpty);
    expect(await db.query('calculos_dosis'), isEmpty);
  });
  test('mismo id numérico en los tres ámbitos no mezcla pacientes', () async {
    await calcular(eventos);
    await expectLater(
      calcular(eventos, p: familiar, id: 'ajeno'),
      throwsStateError,
    );
    await db.update('sesion', {'usuario_id': 2});
    expect(await eventos.calculos(familiar), isEmpty);
    await calcular(eventos, p: familiar, id: 'familiar');
    await expectLater(
      confirmar(eventos, p: familiar, calculoId: 'calculo'),
      throwsArgumentError,
    );
    await db.update('sesion', {'usuario_id': 3});
    await calcular(eventos, p: hospital, id: 'hospital');
    expect(await eventos.administraciones(hospital), isEmpty);
    expect(await db.query('calculos_dosis'), hasLength(3));
  });
  test(
    'historial y datos del reporte hospitalario excluyen cálculos y marcas antiguas',
    () async {
      await db.update('sesion', {'usuario_id': 3});
      await db.insert('insulina_enfermero', {
        'paciente_id': 1,
        'unidades': 50,
        'fecha': '2026-09-01',
      });
      await db.insert('medicamentos_enfermero', {
        'id': 7,
        'paciente_id': 1,
        'nombre': 'Medicamento',
        'dosis': '1 tableta',
        'suministrado': 1,
      });
      await calcular(eventos, p: hospital);
      final helper = DatabaseHelper.conBase(db);
      expect(await helper.obtenerInsulinaEnfermero(1), isEmpty);
      expect(
        (await helper.obtenerMedicamentosEnfermero(1)).single['suministrado'],
        0,
      );
      await confirmar(eventos, p: hospital);
      expect(
        (await helper.obtenerInsulinaEnfermero(1)).single['unidades'],
        3.0,
      );
      await eventos.confirmarAdministracion(
        id: 'med7',
        paciente: hospital,
        confirmada: true,
        medicamento: 'Medicamento',
        dosisTexto: '1 tableta',
        fecha: fecha,
        medicamentoEnfermeroId: 7,
      );
      expect(
        (await helper.obtenerMedicamentosEnfermero(1)).single['suministrado'],
        1,
      );
      await eventos.anularAdministracion(hospital, 'med7', 'Error');
      expect(
        (await helper.obtenerMedicamentosEnfermero(1)).single['suministrado'],
        0,
      );
      expect(
        (await db.query('medicamentos_enfermero')).single['suministrado'],
        1,
      );
    },
  );
  test('sin sesión no escribe ni consulta información clínica nueva', () async {
    await db.delete('sesion');
    await expectLater(calcular(eventos), throwsStateError);
    await expectLater(eventos.administraciones(personal), throwsStateError);
    expect(await db.query('registros_glucosa'), isEmpty);
  });
  test('corrección conserva autor, motivo y registro original', () async {
    await confirmar(eventos);
    await eventos.anularAdministracion(
      personal,
      'aplicacion',
      'Error de registro',
    );
    expect(await eventos.administraciones(personal), isEmpty);
    final fila = (await db.query('administraciones')).single;
    expect(fila['estado'], 'anulada');
    expect(fila['anulada_por'], 1);
    expect(fila['motivo_anulacion'], 'Error de registro');
    expect(fila['cantidad'], 3.0);
  });
  test(
    'consulta de administraciones usa intervalo semiabierto y UTC',
    () async {
      await confirmar(eventos);
      await confirmar(
        eventos,
        id: 'siguiente',
        cuando: fecha.add(const Duration(hours: 8)),
      );
      final resultado = await eventos.administraciones(
        personal,
        desde: fecha,
        hasta: fecha.add(const Duration(hours: 8)),
      );
      expect(resultado, hasLength(1));
      expect(resultado.single['id'], 'aplicacion');
    },
  );
  test(
    'lectura manual registra autor y rechaza cero sin crear eventos de dosis',
    () async {
      await eventos.registrarLectura(personal, {
        'valor': 99.5,
        'notas': 'Observación',
        'fecha': fecha.toIso8601String(),
      });
      final lectura = (await db.query('registros_glucosa')).single;
      expect(lectura['autor_usuario_id'], 1);
      expect(lectura['procedencia'], 'registro_manual');
      await expectLater(
        eventos.registrarLectura(personal, {'valor': 0}),
        throwsArgumentError,
      );
      expect(await eventos.calculos(personal), isEmpty);
      expect(await eventos.administraciones(personal), isEmpty);
    },
  );
  test(
    'medicación hospitalaria exige pertenencia y conserva confirmación',
    () async {
      await db.update('sesion', {'usuario_id': 3});
      await db.insert('medicamentos_enfermero', {
        'id': 7,
        'paciente_id': 1,
        'nombre': 'Medicamento de prueba',
        'dosis': '1 tableta',
      });
      await eventos.confirmarAdministracion(
        id: 'med7',
        paciente: hospital,
        confirmada: true,
        medicamento: 'Medicamento de prueba',
        dosisTexto: '1 tableta',
        fecha: fecha,
        medicamentoEnfermeroId: 7,
      );
      expect(
        (await eventos.administraciones(
          hospital,
        )).single['medicamento_enfermero_id'],
        7,
      );
      await expectLater(
        eventos.confirmarAdministracion(
          id: 'ajeno',
          paciente: hospital,
          confirmada: true,
          medicamento: 'Otro',
          dosisTexto: '1 tableta',
          fecha: fecha,
          medicamentoEnfermeroId: 8,
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'fallo de migración revierte columnas nuevas y mantiene versión 1',
    () async {
      final carpeta = await Directory.systemTemp.createTemp(
        'insulapp_fallo_migracion_',
      );
      final ruta = '${carpeta.path}/prueba.db';
      var anterior = await databaseFactoryFfi.openDatabase(
        ruta,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (base, _) async {
            for (final sql in File(
              'test/fixtures/esquema_v1.sql',
            ).readAsStringSync().split(';')) {
              if (sql.trim().isNotEmpty) await base.execute(sql);
            }
            await base.execute('CREATE TABLE calculos_dosis(id TEXT)');
          },
        ),
      );
      await anterior.close();
      await expectLater(
        DatabaseHelper.abrirBase(ruta, fabrica: databaseFactoryFfi),
        throwsA(isA<DatabaseException>()),
      );
      anterior = await databaseFactoryFfi.openDatabase(ruta);
      try {
        expect(await anterior.getVersion(), 1);
        final columnas = await anterior.rawQuery(
          'PRAGMA table_info(registros_glucosa)',
        );
        expect(columnas.any((c) => c['name'] == 'procedencia'), isFalse);
      } finally {
        await anterior.close();
        await carpeta.delete(recursive: true);
      }
    },
  );
  test(
    'migración v1 conserva filas históricas y reapertura no duplica',
    () async {
      final carpeta = await Directory.systemTemp.createTemp(
        'insulapp_migracion_',
      );
      final ruta = '${carpeta.path}/prueba.db';
      var anterior = await databaseFactoryFfi.openDatabase(
        ruta,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (base, _) async {
            for (final sql in File(
              'test/fixtures/esquema_v1.sql',
            ).readAsStringSync().split(';')) {
              if (sql.trim().isNotEmpty) await base.execute(sql);
            }
          },
        ),
      );
      await preparar(anterior);
      final originales = <Map<String, Object?>>[
        {
          'paciente_id': 1,
          'valor': 150.0,
          'notas': 'Dosis ADA Calculada: 3 UI.',
          'fecha': '2026-09-01T12:00:00',
        },
        {
          'paciente_id': 1,
          'valor': 0.0,
          'notas': 'Dosis Manual: 4 UI.',
          'fecha': 'fecha antigua inválida',
        },
      ];
      for (final r in originales) {
        await anterior.insert('registros_glucosa', r);
      }
      await anterior.insert('insulina_enfermero', {
        'paciente_id': 1,
        'unidades': 5,
        'fecha': '2026-09-01',
      });
      await anterior.insert('reportes_paciente', {
        'id': 'pdf',
        'paciente_id': 1,
        'archivo_bytes': Uint8List.fromList([1, 2, 3]),
      });
      final antes = await anterior.query('registros_glucosa');
      await anterior.close();
      var migrada = await DatabaseHelper.abrirBase(
        ruta,
        fabrica: databaseFactoryFfi,
      );
      try {
        expect(await migrada.getVersion(), 2);
        final despues = await migrada.query('registros_glucosa');
        for (var i = 0; i < antes.length; i++) {
          for (final k in antes[i].keys) {
            expect(despues[i][k], antes[i][k]);
          }
          expect(despues[i]['procedencia'], 'legado');
          expect(despues[i]['autor_usuario_id'], isNull);
        }
        expect(await migrada.query('administraciones'), isEmpty);
        expect(await migrada.query('calculos_dosis'), isEmpty);
        expect(await migrada.query('insulina_enfermero'), hasLength(1));
        expect(
          (await migrada.query('reportes_paciente')).single['archivo_bytes'],
          [1, 2, 3],
        );
        await migrada.close();
        migrada = await DatabaseHelper.abrirBase(
          ruta,
          fabrica: databaseFactoryFfi,
        );
        expect(await migrada.query('registros_glucosa'), hasLength(2));
      } finally {
        await migrada.close();
        await carpeta.delete(recursive: true);
      }
    },
  );
}
