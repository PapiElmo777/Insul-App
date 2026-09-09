import 'dart:math';
import 'database_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MOCK DATA GENERATOR  –  InsulApp
//
//  Perfil A  →  Enfermero  (a / a)
//    Carlos Mendoza – Medicina Interna – HGR#1
//    15 pacientes con historiales ricos y variados
//
//  Perfil B  →  Paciente   (b / b)
//    Alfredo García – DM Tipo 1, comorbilidades múltiples
//    90 registros glucémicos, uso de calculadora de carbos,
//    aplicaciones de insulina, ID médica completa
//
//  Perfil C  →  Cuidador   (c / c)
//    Laura Gómez – Cuida de 3 familiares:
//    1. Don Roberto (Padre) - DM2 complejo, adulto mayor.
//    2. Doña Rosa (Madre) - DM2 muy controlada.
//    3. Luis (Hijo) - DM1, adolescente escolar.
// ─────────────────────────────────────────────────────────────────────────────

class MockDataGenerator {
  static Future<void> poblarBaseDeDatos() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.db;

    // ──────────────────────────────────────────────────────────────────────────
    // 0. LIMPIEZA (evita duplicados en reinstalaciones)
    // ──────────────────────────────────────────────────────────────────────────
    for (final correo in ['a', 'b', 'c']) {
      final u = await dbHelper.obtenerUsuarioPorCorreo(correo);
      if (u == null) continue;
      final uid = u['id'] as int;

      if (u['rol'] == 'Enfermero') {
        final enf = await dbHelper.obtenerEnfermeroPorUsuario(uid);
        if (enf != null) {
          final pacs = await db.query('pacientes_enfermero',
              where: 'enfermero_id = ?', whereArgs: [enf['id']]);
          for (final p in pacs) {
            final pid = p['id'];
            for (final tabla in [
              'glucosa_enfermero', 'insulina_enfermero',
              'medicamentos_enfermero', 'observaciones_enfermero'
            ]) {
              await db.delete(tabla,
                  where: 'paciente_id = ?', whereArgs: [pid]);
            }
          }
          await db.delete('pacientes_enfermero',
              where: 'enfermero_id = ?', whereArgs: [enf['id']]);
          await db.delete('reportes_enfermero',
              where: 'enfermero_id = ?', whereArgs: [enf['id']]);
        }
        await db.delete('enfermeros',
            where: 'usuario_id = ?', whereArgs: [uid]);
      } else if (u['rol'] == 'Paciente') {
        final pac = await dbHelper.obtenerPacientePorUsuario(uid);
        if (pac != null) {
          final pid = pac['id'];
          await db.delete('registros_glucosa',
              where: 'paciente_id = ?', whereArgs: [pid]);
          await db.delete('otros_medicamentos',
              where: 'paciente_id = ?', whereArgs: [pid]);
          await db.delete('alimentos_frecuentes',
              where: 'paciente_id = ?', whereArgs: [pid]);
        }
        await db.delete('pacientes',
            where: 'usuario_id = ?', whereArgs: [uid]);
      } else if (u['rol'] == 'Cuidador') {
        final pacsCuidador = await db.query('pacientes_cuidador',
            where: 'cuidador_id = ?', whereArgs: [uid]);
        for (final p in pacsCuidador) {
          final pid = p['id'];
          await db.delete('registros_glucosa_cuidador',
              where: 'paciente_cuidador_id = ?', whereArgs: [pid]);
          await db.delete('otros_medicamentos_cuidador',
              where: 'paciente_cuidador_id = ?', whereArgs: [pid]);
          await db.delete('reportes_cuidador',
              where: 'paciente_cuidador_id = ?', whereArgs: [pid]);
        }
        await db.delete('pacientes_cuidador',
            where: 'cuidador_id = ?', whereArgs: [uid]);
      }
      await db.delete('usuarios', where: 'id = ?', whereArgs: [uid]);
    }

    await db.transaction((txn) async {
      final rnd = Random();

      // ════════════════════════════════════════════════════════════════════════
      // PERFIL A – ENFERMERO  (a / a)
      // ════════════════════════════════════════════════════════════════════════
      final int uidEnf = await txn.insert('usuarios', {
        'nombre': 'Carlos',
        'apellidos': 'Mendoza Ríos',
        'correo': 'a',
        'contrasena': 'a',
        'telefono': '6681234500',
        'rol': 'Enfermero',
      });

      final int idEnfermero = await txn.insert('enfermeros', {
        'usuario_id': uidEnf,
        'cedula': '78945612',
        'institucion': 'Hospital General Regional Núm. 1',
        'area': 'Medicina Interna',
      });

      final pacientesData = [
        ['María Guadalupe Pérez Torres', '58', 'Tipo 2', 'Diabético 1500 kcal', 'Estable',    'EXP-2026-101', 'Cama 10', 'Ninguna'],
        ['Juan Carlos López Herrera',    '65', 'Tipo 2', 'Blanda',              'En observación', 'EXP-2026-102', 'Cama 11', 'Penicilina'],
        ['Luis Alberto García Soto',     '72', 'Tipo 2', 'Astringente',         'Delicado',    'EXP-2026-103', 'Cama 12', 'Sulfa'],
        ['Ana Patricia Martínez Ruiz',   '45', 'Tipo 1', 'Normal',              'Estable',     'EXP-2026-104', 'Cama 13', 'Ninguna'],
        ['Pedro Ernesto Gómez Vidal',    '60', 'Tipo 2', 'Líquida',             'Grave', 'EXP-2026-105', 'Cama 14', 'AINEs'],
        ['Laura Sofía Díaz Medrano',     '38', 'Tipo 1', 'Normal',              'Pre-alta',    'EXP-2026-106', 'Cama 15', 'Ninguna'],
        ['Carmen Elena Álvarez Flores',  '70', 'Tipo 2', 'Blanda',              'Estable',     'EXP-2026-107', 'Cama 16', 'Latex'],
        ['Diego Armando Fernández Cruz', '52', 'Tipo 2', 'Diabético 1800 kcal', 'En observación', 'EXP-2026-108', 'Cama 17', 'Ninguna'],
        ['Valeria Josefina Ruiz Nava',   '29', 'Tipo 1', 'Normal',              'Estable',     'EXP-2026-109', 'Cama 18', 'Penicilina'],
        ['Miguel Ángel Romero Ibarra',   '67', 'Tipo 2', 'Blanda',              'Delicado',    'EXP-2026-110', 'Cama 19', 'Polvo'],
        ['Elena Concepción Vega Solís',  '55', 'Tipo 2', 'Normal',              'Pre-alta',    'EXP-2026-111', 'Cama 20', 'Ninguna'],
        ['Fernando José Morales Ríos',   '48', 'Tipo 1', 'Diabético 1600 kcal', 'Estable',     'EXP-2026-112', 'Cama 21', 'AINEs'],
        ['Sofía Isabela Castillo Prado', '33', 'Tipo 1', 'Normal',              'En observación', 'EXP-2026-113', 'Cama 22', 'Ninguna'],
        ['Roberto Isaac Vargas Leal',    '61', 'Tipo 2', 'Astringente',         'Estable',     'EXP-2026-114', 'Cama 23', 'Sulfa'],
        ['Patricia Ximena Soto Dávila',  '44', 'Tipo 2', 'Blanda',              'Delicado',    'EXP-2026-115', 'Cama 24', 'Ninguna'],
      ];

      final medsDM1 = [
        {'nombre': 'Insulina Glargina', 'dosis': '18 UI SC', 'frecuencia': '21:00 hrs'},
        {'nombre': 'Insulina Lispro',   'dosis': '6 UI SC',  'frecuencia': 'Antes de comer'},
        {'nombre': 'Omeprazol',         'dosis': '40 mg IV', 'frecuencia': 'Cada 24 hrs'},
        {'nombre': 'Paracetamol',       'dosis': '1 g VO',   'frecuencia': 'Cada 8 hrs PRN'},
      ];
      final medsDM2 = [
        {'nombre': 'Metformina',    'dosis': '850 mg VO', 'frecuencia': 'Cada 12 hrs'},
        {'nombre': 'Losartán',      'dosis': '50 mg VO',  'frecuencia': 'Cada 24 hrs'},
        {'nombre': 'Omeprazol',     'dosis': '40 mg IV',  'frecuencia': 'Cada 24 hrs'},
        {'nombre': 'Ketorolaco',    'dosis': '30 mg IV',  'frecuencia': 'Cada 8 hrs PRN'},
        {'nombre': 'Insulina NPH',  'dosis': '10 UI SC',  'frecuencia': '22:00 hrs'},
      ];

      final obsPool = [
        'Paciente refiere mareos al despertar. TA 130/85 mmHg. Glucosa 95 mg/dL preprandial.',
        'Tolera dieta blanda. Se mantiene eupneico en reposo. FC 78 lpm.',
        'Pico hiperglucémico tras comida (267 mg/dL). Se notifica a médico de guardia.',
        'Se administra analgésico por cefalea leve. EVA 3/10. Buena respuesta.',
        'Paciente sin alteraciones respiratorias durante la noche. SpO₂ 97%.',
        'Sitio de venoclisis limpio sin datos de flebitis. Se realiza curación.',
        'Episodio de hipoglucemia leve (62 mg/dL). Se administra glucosa oral 15 g.',
        'Diuresis adecuada. Balance hídrico ligeramente positivo.',
        'Glucosa en ayunas 142 mg/dL. Se ajusta dosis de insulina NPH según esquema.',
        'Paciente refiere dolor en sitio de venoclisis. Se recanaliza en MSD.',
        'Se educa a paciente sobre importancia del conteo de carbohidratos.',
      ];

      for (int i = 0; i < 15; i++) {
        final pd = pacientesData[i];
        final esDM1 = pd[2] == 'Tipo 1';

        final int pid = await txn.insert('pacientes_enfermero', {
          'enfermero_id':   idEnfermero,
          'nombre':         pd[0],
          'edad':           pd[1],
          'expediente':     pd[5],
          'ubicacion':      pd[6],
          'tipo_diabetes':  pd[2],
          'alergias':       pd[7],
          'dieta':          pd[3],
          'estado_general': pd[4],
          'hipo_limit':     70,
          'hiper_limit':    esDM1 ? 180 : 200,
          'rango_min':      esDM1 ? 80 : 90,
          'rango_max':      esDM1 ? 130 : 150,
        });

        final meds = esDM1 ? medsDM1 : medsDM2;
        final medsShuf = List.from(meds)..shuffle(rnd);
        for (int m = 0; m < 2 && m < medsShuf.length; m++) {
          await txn.insert('medicamentos_enfermero', {
            'paciente_id': pid,
            'nombre':      medsShuf[m]['nombre'],
            'dosis':       medsShuf[m]['dosis'],
            'frecuencia':  medsShuf[m]['frecuencia'],
            'suministrado': m == 0 ? 1 : (rnd.nextBool() ? 1 : 0),
          });
        }

        final obsShuf = List.from(obsPool)..shuffle(rnd);
        for (int o = 0; o < 2; o++) {
          final fechaObs = DateTime.now().subtract(Duration(hours: rnd.nextInt(12) + o * 4));
          await txn.insert('observaciones_enfermero', {
            'paciente_id': pid,
            'nota':        obsShuf[o],
            'fecha':       fechaObs.toIso8601String(),
          });
        }

        final baseGlucosa = pd[4] == 'Delicado' ? 160 : pd[4] == 'Grave' ? 200 : 120;
        final cantGlucosa = 20 + rnd.nextInt(10);

        for (int j = 0; j < cantGlucosa; j++) {
          final dias   = (j / 8).floor();
          final horas  = rnd.nextInt(24);
          final fecha  = DateTime.now().subtract(Duration(days: dias, hours: horas));

          int valor;
          final prob = rnd.nextInt(100);
          if (prob < 8) {
            valor = 55 + rnd.nextInt(14);
          } else if (prob < 18) {
            valor = (baseGlucosa + 60 + rnd.nextInt(60)).clamp(181, 280);
          } else {
            valor = (baseGlucosa - 30 + rnd.nextInt(80)).clamp(75, baseGlucosa + 40);
          }

          await txn.insert('glucosa_enfermero', {
            'paciente_id': pid,
            'valor':       valor,
            'fecha':       fecha.toIso8601String(),
          });

          if (esDM1 || valor > 180) {
            if (rnd.nextInt(100) > 45) {
              await txn.insert('insulina_enfermero', {
                'paciente_id': pid,
                'unidades':    valor > 180 ? 4 + rnd.nextInt(6) : 2 + rnd.nextInt(8),
                'fecha': fecha.add(Duration(minutes: 10 + rnd.nextInt(20))).toIso8601String(),
              });
            }
          }
        }
      }

      // ════════════════════════════════════════════════════════════════════════
      // PERFIL B – PACIENTE  (b / b)
      // ════════════════════════════════════════════════════════════════════════
      final int uidPac = await txn.insert('usuarios', {
        'nombre':     'Alfredo',
        'apellidos':  'García Montoya',
        'correo':     'b',
        'contrasena': 'b',
        'telefono':   '6681234567',
        'rol':        'Paciente',
      });

      final int idPaciente = await txn.insert('pacientes', {
        'usuario_id':             uidPac,
        'sexo':                   'Hombre',
        'edad':                   34,
        'tiempo_dx':              '5 a 10 años',
        'tipo_diabetes':          'Tipo 1',
        'tipo_sanguineo':         'O+',
        'alergias':               'Polvo, Penicilina, Sulfonamidas',
        'peso':                   78.5,
        'altura':                 175.0,
        'imc':                    25.6,
        'limite_hipo':            70.0,
        'limite_hiper':           180.0,
        'rango_min':              80.0,
        'rango_max':              130.0,
        'metodo_insulina':        'Inyecciones',
        'insulina_basal_marca':   'Tresiba',
        'insulina_basal_dosis':   '24',
        'insulina_basal_horario': '09:00 PM',
        'insulina_rapida_marca':  'Humalog',
        'insulina_rapida_patron': 'Conteo de carbohidratos (1:15 g/UI)',
        'insulina_rapida_horario':'Antes de cada comida',
        'med_oral_nombre':        'Metformina',
        'med_oral_dosis':         '850 mg',
        'frecuencia_monitoreo':   'Ayunas y antes de comidas',
        'actividad_fisica':       'Moderado (3-5 días/sem)',
        'emergencia_nombre':      'Martha García',
        'emergencia_parentesco':  'Madre',
        'emergencia_telefono':    '6689876543',
        'medico_nombre':          'Dr. Roberto Mendoza Avilés',
        'enfermedades_cronicas':  'Hipertensión Arterial Sistémica · Hipotiroidismo',
        'hospitalizaciones':      '12/Ene/2025 – Cetoacidosis Diabética Leve (DKA).',
        'cirugias':               'Apendicectomía Laparoscópica (2018)',
        'clinica':                'IMSS Bienestar – Clínica de Diabetes #49',
        'identificacion_completada': 1,
      });

      final otrosMeds = [
        {'nombre': 'Losartán', 'gramaje': '50 mg', 'proposito': 'Hipertensión', 'frecuencia': 'Cada 24 hrs'},
        {'nombre': 'Levotiroxina', 'gramaje': '100 mcg', 'proposito': 'Hipotiroidismo', 'frecuencia': 'En ayunas'},
        {'nombre': 'Atorvastatina', 'gramaje': '20 mg', 'proposito': 'Colesterol', 'frecuencia': 'Nocturno'},
      ];

      for (final med in otrosMeds) {
        await txn.insert('otros_medicamentos', {
          'paciente_id': idPaciente,
          ...med,
        });
      }

      final alimentosFrecuentes = [
        {'nombre': 'Tortilla de maíz (1 pza)', 'carbos_por_100g': 48.0, 'veces_usado': 15},
        {'nombre': 'Arroz blanco cocido', 'carbos_por_100g': 28.0, 'veces_usado': 12},
        {'nombre': 'Manzana mediana', 'carbos_por_100g': 14.0, 'veces_usado': 8},
      ];

      for (final alim in alimentosFrecuentes) {
        await txn.insert('alimentos_frecuentes', {
          'paciente_id':    idPaciente,
          'nombre':         alim['nombre'],
          'carbos_por_100g': alim['carbos_por_100g'],
          'veces_usado':    alim['veces_usado'],
        });
      }

      final escenarios = [
        [95,  'Ayunas',         'Bien. Glucosa estable toda la noche.'],
        [88,  'Ayunas',         'Dormí 8 hrs. Sin hipoglucemia nocturna.'],
        [112, 'Ayunas',         'Desperté un poco alto. Cené tarde.'],
        [98,  'Antes de comer', 'Dosis ADA: 3.0 UI. Carbos a ingerir: 45g.'],
        [115, 'Antes de comer', 'Dosis ADA: 4.5 UI. Carbos a ingerir: 60g.'],
        [145, 'Antes de comer', 'Dosis ADA: 6.0 UI (incluye corrección +1.5 UI).'],
        [128, 'Después de comer', '2 hrs post: bien. Dosis fue adecuada.'],
        [156, 'Después de comer', 'Un poco alto. Comí pizza.'],
        [105, 'Antes de dormir', 'Bien. Se aplica Tresiba 24UI.'],
        [58,  'Madrugada',      'HIPO: Desperté sudando. Tomé 15g glucosa oral.'],
        [245, 'Después de comer', 'HIPER: Comida de cumpleaños. Corrección 4UI.'],
        [110, 'Antes de comer', ''],
      ];

      int escenarioIdx = 0;
      for (int dia = 0; dia < 30; dia++) {
        final regsHoy = 2 + rnd.nextInt(3);
        final horasUnicas = {2, 7, 12, 14, 19, 22}..toList().shuffle(rnd);
        final horasLista = horasUnicas.toList();

        for (int r = 0; r < regsHoy && r < horasLista.length; r++) {
          final escenario = escenarios[escenarioIdx % escenarios.length];
          final fecha  = DateTime.now()
              .subtract(Duration(days: dia))
              .copyWith(hour: horasLista[r], minute: rnd.nextInt(30), second: 0);

          final glucosaVal = (escenario[0] as int) + (rnd.nextInt(11) - 5);

          await txn.insert('registros_glucosa', {
            'paciente_id': idPaciente,
            'valor':       glucosaVal.clamp(40, 400),
            'momento':     escenario[1] as String,
            'notas':       escenario[2] as String,
            'fecha':       fecha.toIso8601String(),
          });

          escenarioIdx++;
        }
      }

      // ════════════════════════════════════════════════════════════════════════
      // PERFIL C – CUIDADOR  (c / c)
      // ════════════════════════════════════════════════════════════════════════
      final int uidCuidador = await txn.insert('usuarios', {
        'nombre': 'Laura',
        'apellidos': 'Gómez Valdés',
        'correo': 'c',
        'contrasena': 'c',
        'telefono': '6681122334',
        'rol': 'Cuidador',
      });

      // --- FAMILIAR 1: Don Roberto (Padre, DM2 Complejo) ---
      final int idRoberto = await txn.insert('pacientes_cuidador', {
        'cuidador_id': uidCuidador,
        'tipo_paciente': 'Adulto Mayor',
        'parentesco': 'Padre',
        'nombre': 'Don Roberto Gómez',
        'sexo': 'Hombre',
        'edad': 78,
        'tiempo_dx': 'Más de 20 años',
        'tipo_diabetes': 'Tipo 2',
        'alergias': 'Ibuprofeno, Diclofenaco',
        'peso': 82.0,
        'altura': 1.68,
        'imc': 29.1,
        'limite_hipo': 80.0,
        'limite_hiper': 200.0,
        'rango_min': 90.0,
        'rango_max': 150.0,
        'metodo_insulina': 'Inyecciones',
        'insulina_basal_marca': 'Glargina (Lantus)',
        'insulina_basal_dosis': '30',
        'insulina_basal_horario': '08:00 AM',
        'insulina_rapida_marca': 'No usa',
        'insulina_rapida_patron': '',
        'insulina_rapida_horario': '',
        'bomba_unidades': '',
        'bomba_frecuencia': '',
        'med_oral_nombre': 'Sitagliptina / Metformina',
        'med_oral_dosis': '50/1000 mg',
        'frecuencia_monitoreo': '3 veces por semana',
        'medico_nombre': 'Dra. Silva (Geriatra)',
        'riesgo_caidas': 'Alto',
        'estado_cognitivo': 'Deterioro Cognitivo Leve',
        'autonomia_menor': 'Dependiente parcial',
        'contacto_escolar': '',
        'identificacion_completada': 1,
        'tipo_sanguineo': 'A+',
        'emergencia_nombre': 'Laura Gómez (Hija)',
        'emergencia_parentesco': 'Hija',
        'emergencia_telefono': '6681122334',
        'enfermedades_cronicas': 'Hipertensión Arterial, Insuficiencia Renal Crónica, Neuropatía Diabética, Osteoartritis',
        'hospitalizaciones': 'Sep 2024 - Neumonía adquirida en la comunidad. Mar 2023 - Crisis hipertensiva.',
        'cirugias': 'Cirugía de cataratas (Ojo derecho, 2021).',
        'clinica': 'ISSSTE Los Mochis',
      });

      final medsRoberto = [
        {'nombre': 'Amlodipino', 'gramaje': '5 mg', 'proposito': 'Hipertensión', 'frecuencia': '1 cada 24 hrs'},
        {'nombre': 'Pregabalina', 'gramaje': '75 mg', 'proposito': 'Neuropatía Diabética', 'frecuencia': '1 por la noche'},
        {'nombre': 'Paracetamol', 'gramaje': '500 mg', 'proposito': 'Osteoartritis', 'frecuencia': '1 cada 8 hrs'},
      ];
      for (final med in medsRoberto) {
        await txn.insert('otros_medicamentos_cuidador', { 'paciente_cuidador_id': idRoberto, ...med });
      }

      // --- FAMILIAR 2: Doña Rosa (Madre, DM2 Controlada) ---
      final int idRosa = await txn.insert('pacientes_cuidador', {
        'cuidador_id': uidCuidador,
        'tipo_paciente': 'Adulto Mayor',
        'parentesco': 'Madre',
        'nombre': 'Doña Rosa Valdés',
        'sexo': 'Mujer',
        'edad': 74,
        'tiempo_dx': '5 años',
        'tipo_diabetes': 'Tipo 2',
        'alergias': 'Ninguna',
        'peso': 65.0,
        'altura': 1.55,
        'imc': 27.0,
        'limite_hipo': 70.0,
        'limite_hiper': 180.0,
        'rango_min': 80.0,
        'rango_max': 140.0,
        'metodo_insulina': 'No usa',
        'insulina_basal_marca': '',
        'insulina_basal_dosis': '',
        'insulina_basal_horario': '',
        'insulina_rapida_marca': '',
        'insulina_rapida_patron': '',
        'insulina_rapida_horario': '',
        'med_oral_nombre': 'Metformina',
        'med_oral_dosis': '500 mg',
        'frecuencia_monitoreo': '1 vez al día',
        'medico_nombre': 'Dr. López',
        'riesgo_caidas': 'Bajo',
        'estado_cognitivo': 'Integro',
        'autonomia_menor': 'Independiente',
        'contacto_escolar': '',
        'identificacion_completada': 1,
        'tipo_sanguineo': 'O+',
        'emergencia_nombre': 'Laura Gómez (Hija)',
        'emergencia_parentesco': 'Hija',
        'emergencia_telefono': '6681122334',
        'enfermedades_cronicas': 'Hipertensión Arterial, Osteopenia',
        'hospitalizaciones': 'Ninguna reciente',
        'cirugias': 'Apéndice (hace 30 años)',
        'clinica': 'IMSS Clínica 49',
      });

      final medsRosa = [
        {'nombre': 'Losartán', 'gramaje': '50 mg', 'proposito': 'Hipertensión', 'frecuencia': '1 al día'},
        {'nombre': 'Calcitriol', 'gramaje': '0.25 mcg', 'proposito': 'Huesos', 'frecuencia': '1 al día'},
      ];
      for (final med in medsRosa) {
        await txn.insert('otros_medicamentos_cuidador', { 'paciente_cuidador_id': idRosa, ...med });
      }

      // --- FAMILIAR 3: Luisito (Hijo, DM1) ---
      final int idLuis = await txn.insert('pacientes_cuidador', {
        'cuidador_id': uidCuidador,
        'tipo_paciente': 'Menor de Edad',
        'parentesco': 'Hijo',
        'nombre': 'Luis Gómez',
        'sexo': 'Hombre',
        'edad': 14,
        'tiempo_dx': '2 años',
        'tipo_diabetes': 'Tipo 1',
        'alergias': 'Amoxicilina',
        'peso': 52.0,
        'altura': 1.62,
        'imc': 19.8,
        'limite_hipo': 75.0,
        'limite_hiper': 200.0,
        'rango_min': 80.0,
        'rango_max': 150.0,
        'metodo_insulina': 'Inyecciones',
        'insulina_basal_marca': 'Tresiba',
        'insulina_basal_dosis': '15',
        'insulina_basal_horario': '09:00 PM',
        'insulina_rapida_marca': 'Humalog',
        'insulina_rapida_patron': '1 UI por cada 15g de Carbohidratos',
        'insulina_rapida_horario': 'Antes de comer',
        'med_oral_nombre': '',
        'med_oral_dosis': '',
        'frecuencia_monitoreo': 'Antes de cada comida',
        'medico_nombre': 'Dra. Méndez (Endocrinóloga Pediatra)',
        'riesgo_caidas': 'N/A',
        'estado_cognitivo': 'N/A',
        'autonomia_menor': 'Supervisión en escuela',
        'contacto_escolar': 'Secundaria Técnica 2 - Prefecto Miguel (6681230000)',
        'identificacion_completada': 1,
        'tipo_sanguineo': 'A+',
        'emergencia_nombre': 'Laura Gómez (Madre)',
        'emergencia_parentesco': 'Madre',
        'emergencia_telefono': '6681122334',
        'enfermedades_cronicas': 'Ninguna otra',
        'hospitalizaciones': 'Debut Cetoacidosis (2024)',
        'cirugias': 'Ninguna',
        'clinica': 'IMSS Pediatría',
      });

      // Luis no tiene medicamentos extra registrados en esta tabla por ahora.

      // --- GENERAR REGISTROS DE GLUCOSA PARA LOS 3 ---
      for (int dia = 0; dia < 30; dia++) {

        // Glucosa Roberto (2 al día, picos postprandiales)
        final horasRoberto = [8, 14]..shuffle(rnd);
        for (int r = 0; r < 2; r++) {
          final hora = horasRoberto[r];
          final fecha = DateTime.now().subtract(Duration(days: dia)).copyWith(hour: hora, minute: rnd.nextInt(30));
          int valor = hora == 8 ? (100 + rnd.nextInt(40)) : (140 + rnd.nextInt(60));
          String momento = hora == 8 ? 'Ayunas' : 'Después de comer';
          String notas = valor > 180 ? 'Glucosa alta detectada.' : '';

          if (rnd.nextInt(100) < 5) { valor = 65 + rnd.nextInt(10); notas = 'Se sintió mareado.'; }

          await txn.insert('registros_glucosa_cuidador', {
            'paciente_cuidador_id': idRoberto, 'valor': valor, 'momento': momento, 'notas': notas, 'fecha': fecha.toIso8601String(),
          });
        }

        // Glucosa Rosa (1 al día, muy estable)
        final fechaRosa = DateTime.now().subtract(Duration(days: dia)).copyWith(hour: 9, minute: rnd.nextInt(30));
        int valorRosa = 95 + rnd.nextInt(30);
        await txn.insert('registros_glucosa_cuidador', {
          'paciente_cuidador_id': idRosa, 'valor': valorRosa, 'momento': 'Ayunas', 'notas': 'Todo bien', 'fecha': fechaRosa.toIso8601String(),
        });

        // Glucosa Luis (4 al día, alta variabilidad)
        final horasLuis = [7, 10, 14, 20]; // Desayuno, Receso, Comida, Cena
        for (int h in horasLuis) {
          final fecha = DateTime.now().subtract(Duration(days: dia)).copyWith(hour: h, minute: rnd.nextInt(30));
          int valor = 80 + rnd.nextInt(100); // Variabilidad normal de 80 a 180
          String notas = '';

          if (h == 10 && rnd.nextInt(100) < 15) {
            valor = 55 + rnd.nextInt(15);
            notas = 'Hipo en el receso, tomó un jugo.';
          } else if (h == 20 && rnd.nextInt(100) < 20) {
            valor = 200 + rnd.nextInt(60);
            notas = 'Cenó pizza, aplicó corrección.';
          }

          await txn.insert('registros_glucosa_cuidador', {
            'paciente_cuidador_id': idLuis, 'valor': valor, 'momento': h == 10 ? 'Otro' : 'Antes de comer', 'notas': notas, 'fecha': fecha.toIso8601String(),
          });
        }
      }
    });
  }
}

extension _SetInt on Set<int> {
  List<int> toList() => List<int>.from(this);
}