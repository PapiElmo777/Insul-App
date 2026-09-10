import 'dart:convert';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../modelos/paciente_clinico.dart';

/// Persistencia local. La autorización remota corresponde a una etapa posterior.
class EventosClinicos {
  final Database db;
  EventosClinicos(this.db);

  static String nuevoId() => List.generate(
    16,
    (_) => Random.secure().nextInt(256),
  ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  Future<int> _autor(DatabaseExecutor tx, PacienteClinico p) async {
    final sesion = await tx.query('sesion', where: 'id = 1', limit: 1);
    final autor = sesion.isEmpty ? null : sesion.first['usuario_id'] as int?;
    if (autor == null) throw StateError('Se requiere una sesión activa.');
    final List<Map<String, Object?>> pacientes;
    switch (p.ambito) {
      case AmbitoPaciente.personal:
        pacientes = await tx.query(
          'pacientes',
          where: 'id = ? AND usuario_id = ?',
          whereArgs: [p.id, autor],
        );
      case AmbitoPaciente.familiar:
        pacientes = await tx.query(
          'pacientes_cuidador',
          where: 'id = ? AND cuidador_id = ?',
          whereArgs: [p.id, autor],
        );
      case AmbitoPaciente.institucional:
        pacientes = await tx.rawQuery(
          'SELECT p.id FROM pacientes_enfermero p JOIN enfermeros e ON e.id = p.enfermero_id WHERE p.id = ? AND e.usuario_id = ?',
          [p.id, autor],
        );
    }
    if (pacientes.isEmpty) {
      throw StateError('El paciente no pertenece a la sesión activa.');
    }
    return autor;
  }

  Future<bool> _yaExiste(
    DatabaseExecutor tx,
    String tabla,
    Map<String, Object?> datos,
  ) async {
    final previos = await tx.query(
      tabla,
      where: 'id = ?',
      whereArgs: [datos['id']],
    );
    if (previos.isEmpty) return false;
    // Reintentar una misma operación no crea otra fila ni cambia su contenido.
    for (final clave in datos.keys.where((k) => k != 'fecha_registro')) {
      if (previos.first[clave] != datos[clave]) {
        throw StateError('La operación ya existe con otros datos.');
      }
    }
    return true;
  }

  Future<int> registrarLectura(
    PacienteClinico paciente,
    Map<String, dynamic> datos,
  ) async {
    final valor = datos['valor'];
    if (valor is! num || !valor.isFinite || valor <= 0) {
      throw ArgumentError('La lectura debe ser positiva y finita.');
    }
    return db.transaction((tx) async {
      final autor = await _autor(tx, paciente);
      return tx.insert(paciente.tablaLecturas, {
        paciente.columnaPaciente: paciente.id,
        'valor': valor,
        'fecha': datos['fecha'] ?? DateTime.now().toIso8601String(),
        'autor_usuario_id': autor,
        'procedencia': 'registro_manual',
        if (paciente.ambito != AmbitoPaciente.institucional) ...{
          'momento': datos['momento'],
          'notas': datos['notas'] ?? '',
        },
      });
    });
  }

  Future<void> guardarCalculo({
    required String id,
    required PacienteClinico paciente,
    required double glucosa,
    required double dosis,
    required Map<String, Object?> entradas,
    required String momento,
    required DateTime fecha,
  }) async {
    if (!glucosa.isFinite || glucosa <= 0 || !dosis.isFinite || dosis < 0) {
      throw ArgumentError('El cálculo contiene valores inválidos.');
    }
    await db.transaction((tx) async {
      final autor = await _autor(tx, paciente);
      final datos = <String, Object?>{
        'id': id,
        'ambito': paciente.ambito.name,
        'paciente_id': paciente.id,
        'autor_usuario_id': autor,
        'fecha': fecha.toUtc().toIso8601String(),
        'procedencia': 'calculadora_local',
        'estado': 'calculada',
        'entradas_json': jsonEncode(entradas),
        'dosis': dosis,
        'momento': momento,
      };
      if (await _yaExiste(tx, 'calculos_dosis', datos)) return;
      final lectura = <String, Object?>{
        paciente.columnaPaciente: paciente.id,
        'valor': glucosa,
        'fecha': fecha.toIso8601String(),
        'autor_usuario_id': autor,
        'procedencia': 'calculadora',
        if (paciente.ambito != AmbitoPaciente.institucional) ...{
          'momento': momento,
          'notas': '',
        },
      };
      final lecturaId = await tx.insert(paciente.tablaLecturas, lectura);
      await tx.insert('calculos_dosis', {...datos, 'lectura_id': lecturaId});
    });
  }

  Future<void> confirmarAdministracion({
    required String id,
    required PacienteClinico paciente,
    required bool confirmada,
    required String medicamento,
    required String dosisTexto,
    required DateTime fecha,
    double? cantidad,
    String? unidad,
    String momento = 'Otro',
    String notas = '',
    String? calculoId,
    int? medicamentoEnfermeroId,
  }) async {
    if (!confirmada) {
      throw ArgumentError('La administración necesita confirmación explícita.');
    }
    if (medicamento.trim().isEmpty ||
        dosisTexto.trim().isEmpty ||
        (cantidad != null && (!cantidad.isFinite || cantidad <= 0))) {
      throw ArgumentError('La administración contiene datos inválidos.');
    }
    await db.transaction((tx) async {
      final autor = await _autor(tx, paciente);
      if (calculoId != null) {
        final calculos = await tx.query(
          'calculos_dosis',
          where: 'id = ? AND ambito = ? AND paciente_id = ?',
          whereArgs: [calculoId, paciente.ambito.name, paciente.id],
        );
        if (calculos.isEmpty) {
          throw ArgumentError('El cálculo no corresponde al paciente.');
        }
      }
      if (medicamentoEnfermeroId != null) {
        if (paciente.ambito != AmbitoPaciente.institucional) {
          throw ArgumentError('Ámbito incorrecto.');
        }
        final meds = await tx.query(
          'medicamentos_enfermero',
          where: 'id = ? AND paciente_id = ?',
          whereArgs: [medicamentoEnfermeroId, paciente.id],
        );
        if (meds.isEmpty) {
          throw ArgumentError('El medicamento no corresponde al paciente.');
        }
      }
      final datos = <String, Object?>{
        'id': id,
        'ambito': paciente.ambito.name,
        'paciente_id': paciente.id,
        'autor_usuario_id': autor,
        'fecha': fecha.toUtc().toIso8601String(),
        'fecha_registro': DateTime.now().toUtc().toIso8601String(),
        'procedencia': 'confirmacion_usuario',
        'estado': 'confirmada',
        'medicamento': medicamento.trim(),
        'dosis_texto': dosisTexto.trim(),
        'cantidad': cantidad,
        'unidad': unidad,
        'momento': momento,
        'notas': notas,
        'calculo_id': calculoId,
        'medicamento_enfermero_id': medicamentoEnfermeroId,
      };
      if (!await _yaExiste(tx, 'administraciones', datos)) {
        await tx.insert('administraciones', datos);
      }
    });
  }

  Future<List<Map<String, Object?>>> calculos(PacienteClinico p) async {
    await _autor(db, p);
    return db.query(
      'calculos_dosis',
      where: 'ambito = ? AND paciente_id = ?',
      whereArgs: [p.ambito.name, p.id],
      orderBy: 'fecha DESC, id DESC',
    );
  }

  Future<List<Map<String, Object?>>> administraciones(
    PacienteClinico p, {
    DateTime? desde,
    DateTime? hasta,
  }) async {
    await _autor(db, p);
    return db.query(
      'administraciones',
      where:
          "ambito = ? AND paciente_id = ? AND estado = 'confirmada'${desde == null ? '' : ' AND fecha >= ?'}${hasta == null ? '' : ' AND fecha < ?'}",
      whereArgs: [
        p.ambito.name,
        p.id,
        if (desde != null) desde.toUtc().toIso8601String(),
        if (hasta != null) hasta.toUtc().toIso8601String(),
      ],
      orderBy: 'fecha DESC, id DESC',
    );
  }

  Future<void> anularAdministracion(
    PacienteClinico p,
    String id,
    String motivo,
  ) async {
    if (motivo.trim().isEmpty) {
      throw ArgumentError('Falta el motivo de corrección.');
    }
    await db.transaction((tx) async {
      final autor = await _autor(tx, p);
      final n = await tx.update(
        'administraciones',
        {
          'estado': 'anulada',
          'anulada_por': autor,
          'fecha_anulacion': DateTime.now().toUtc().toIso8601String(),
          'motivo_anulacion': motivo.trim(),
        },
        where:
            "id = ? AND ambito = ? AND paciente_id = ? AND estado = 'confirmada'",
        whereArgs: [id, p.ambito.name, p.id],
      );
      if (n != 1) {
        throw StateError('No hay una administración confirmada para corregir.');
      }
    });
  }
}
