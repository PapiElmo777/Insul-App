import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:insulapp/pantallas/paciente/pantalla_registros_paciente.dart';
import 'package:insulapp/pantallas/cuidadores/tab_registros_familiar.dart';
import 'package:insulapp/pantallas/cuidadores/tab_glucosa_familiar.dart';
import 'support/base_datos_simulada.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting('es_ES'));
  for (final pantalla in [
    'paciente',
    'registros familiar',
    'glucosa familiar',
  ]) {
    for (final nota in ['', 'Registro escrito por el usuario']) {
      testWidgets('$pantalla conserva nota sin inventar protocolo: "$nota"', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(1000, 2500));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final db = BaseDatosSimulada()..instalar();
        Map<String, dynamic>? guardado;
        final historial = <Map<String, dynamic>>[
          {
            'id': 1,
            'valor': 50,
            'momento': 'Ayunas',
            'notas': '',
            'fecha': DateTime.now(),
          },
        ];
        db.historial = historial;
        final Widget contenido = switch (pantalla) {
          'paciente' => PantallaRegistrosPaciente(
            registros: historial,
            limiteHipo: 70,
            limiteHiper: 180,
            rangoMin: 80,
            rangoMax: 130,
            onAgregarRegistro: (r) {
              guardado = r;
            },
          ),
          'registros familiar' => const TabRegistrosFamiliar(
            paciente: {'id': 1, 'nombre': 'Prueba'},
          ),
          _ => TabGlucosaFamiliar(
            paciente: const {'id': 1, 'nombre': 'Prueba'},
            onCambiarTab: (_) {},
          ),
        };
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: contenido)));
        await tester.pumpAndSettle();
        final abrir = find.text(
          pantalla == 'glucosa familiar'
              ? 'Registrar Lectura de Glucosa'
              : 'Añadir Nueva Lectura',
        );
        await tester.ensureVisible(abrir);
        await tester.tap(abrir);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, '100');
        await tester.enterText(find.byType(TextField).last, nota);
        final guardar = find.text('Guardar Nueva Lectura');
        await tester.ensureVisible(guardar);
        await tester.tap(guardar);
        await tester.pumpAndSettle();
        if (pantalla == 'paciente') {
          expect(guardado?['notas'], nota);
        } else {
          expect(db.inserciones, hasLength(1));
          final args = db.inserciones.single['arguments'] as List;
          expect(args, contains(nota));
          expect(
            args.whereType<String>().any((s) => s.contains('Se realizó')),
            isFalse,
          );
        }
      });
    }
  }
}
