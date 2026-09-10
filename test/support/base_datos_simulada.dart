import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simula solo el límite nativo SQLite, conservando el flujo real de la pantalla.
class BaseDatosSimulada {
  final inserciones = <Map<dynamic, dynamic>>[];
  List<Map<String, dynamic>> historial = [];
  bool fallaInsertar = false;
  Completer<void>? escrituraPendiente;

  void instalar() {
    if (databaseFactoryOrNull == null) {
      databaseFactory = databaseFactorySqflitePlugin;
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.tekartik.sqflite'), (
          call,
        ) async {
          final args = call.arguments;
          switch (call.method) {
            case 'getDatabasesPath':
              return '/tmp/insulapp-pruebas';
            case 'openDatabase':
              return 1;
            case 'query':
              final sql = args['sql'] as String;
              if (sql.contains('user_version')) {
                return {
                  'columns': ['user_version'],
                  'rows': [
                    [1],
                  ],
                };
              }
              if (sql.contains('FROM sesion')) {
                return {
                  'columns': ['usuario_id'],
                  'rows': [
                    [1],
                  ],
                };
              }
              if (sql.contains('FROM pacientes ')) {
                return {
                  'columns': ['id'],
                  'rows': [
                    [1],
                  ],
                };
              }
              if (sql.contains('FROM registros_glucosa')) {
                return historial
                    .map(
                      (r) => {
                        ...r,
                        'fecha': (r['fecha'] as DateTime).toIso8601String(),
                      },
                    )
                    .toList();
              }
              return <String, dynamic>{};
            case 'insert':
              inserciones.add(Map<dynamic, dynamic>.from(args as Map));
              if (fallaInsertar) throw PlatformException(code: 'sqlite_error');
              await escrituraPendiente?.future;
              return 1;
            case 'execute':
            case 'closeDatabase':
              return null;
            default:
              throw StateError('Operación SQLite no prevista: ${call.method}');
          }
        });
  }
}
