import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insulapp/pantallas/paciente/pantalla_calculadora_dosis.dart';
import 'package:insulapp/pantallas/cuidadores/tab_calculadora_familiar.dart';
import 'support/base_datos_simulada.dart';

const carbohidratos = 'Carbohidratos a ingerir';
const glucosa = 'Glucosa actual (antes de comer)';
const guardar = 'Guardar en Historial';

Future<void> pulsar(WidgetTester tester, String texto) async {
  final finder = find.text(texto).first;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> editar(WidgetTester tester, String campo, String valor) async {
  final finder = find.byKey(ValueKey(campo));
  await tester.ensureVisible(finder);
  await tester.enterText(finder, valor);
  await tester.pumpAndSettle();
}

Future<void> montar(WidgetTester tester, bool familiar) async {
  await tester.binding.setSurfaceSize(const Size(1000, 2500));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  SharedPreferences.setMockInitialValues({
    'tutorial_conteo_visto': true,
    'tutorial_conteo_cuidador_visto': true,
  });
  await tester.pumpWidget(
    MaterialApp(
      home: familiar
          ? const Scaffold(
              body: TabCalculadoraFamiliar(
                paciente: {'id': 1, 'nombre': 'Prueba'},
              ),
            )
          : const PantallaCalculadoraDosis(),
    ),
  );
  await tester.pumpAndSettle();
  await editar(tester, carbohidratos, '30');
  await editar(tester, glucosa, '150');
  await pulsar(tester, 'Calcular Dosis');
  expect(find.text(guardar), findsOneWidget);
}

void main() {
  for (final familiar in [false, true]) {
    final rol = familiar ? 'cuidador' : 'paciente';
    group(rol, () {
      late BaseDatosSimulada db;
      setUp(() {
        db = BaseDatosSimulada()..instalar();
      });

      for (final campo in [carbohidratos, glucosa]) {
        testWidgets('$rol invalida el resultado al editar $campo', (
          tester,
        ) async {
          await montar(tester, familiar);
          await editar(tester, campo, '60');
          expect(find.text(guardar), findsNothing);
          expect(db.inserciones, isEmpty);
        });
      }
      for (final opcion in ['Ligero', 'Cena']) {
        testWidgets('$rol invalida el resultado al cambiar $opcion', (
          tester,
        ) async {
          await montar(tester, familiar);
          await pulsar(tester, opcion);
          expect(find.text(guardar), findsNothing);
        });
      }
      for (final campo in [
        'Relación Insulina:Carbohidratos (I:C)',
        'Factor de Sensibilidad a Insulina (FSI)',
        'Glucosa objetivo (antes de comer)',
      ]) {
        testWidgets('$rol invalida al cambiar $campo', (tester) async {
          await montar(tester, familiar);
          await pulsar(tester, 'Parámetros clínicos (Editables)');
          await editar(tester, campo, '20');
          expect(find.text(guardar), findsNothing);
        });
      }
      testWidgets(
        '$rol conserva resultado al cambiar solo selección de texto',
        (tester) async {
          await montar(tester, familiar);
          final campo = tester.widget<TextField>(
            find.byKey(const ValueKey(carbohidratos)),
          );
          campo.controller!.selection = const TextSelection.collapsed(
            offset: 1,
          );
          await tester.pumpAndSettle();
          expect(find.text(guardar), findsOneWidget);
        },
      );
      testWidgets('$rol recalcula y guarda los datos nuevos', (tester) async {
        await montar(tester, familiar);
        await editar(tester, carbohidratos, '60');
        await pulsar(tester, 'Calcular Dosis');
        await pulsar(tester, guardar);
        expect(db.inserciones, hasLength(2));
        expect(db.inserciones.first['arguments'], contains(150.0));
        expect(db.inserciones.last['arguments'].toString(), contains('5.0'));
        expect(
          db.inserciones.last['arguments'].toString(),
          contains('carbohidratos":60.0'),
        );
      });
      testWidgets('$rol muestra fallo de escritura y permite reintentar', (
        tester,
      ) async {
        await montar(tester, familiar);
        db.fallaInsertar = true;
        await pulsar(tester, guardar);
        expect(
          find.text('No se pudo guardar el cálculo. Intenta de nuevo.'),
          findsOneWidget,
        );
        expect(find.text(guardar), findsOneWidget);
        db.fallaInsertar = false;
        await pulsar(tester, guardar);
        expect(db.inserciones, hasLength(3));
      });
      testWidgets(
        '$rol evita duplicados y conserva cambios durante escritura',
        (tester) async {
          await montar(tester, familiar);
          db.escrituraPendiente = Completer<void>();
          await pulsar(tester, guardar);
          final boton = tester.widget<ElevatedButton>(
            find.ancestor(
              of: find.text(guardar),
              matching: find.byType(ElevatedButton),
            ),
          );
          expect(boton.onPressed, isNull);
          await editar(tester, carbohidratos, '60');
          db.escrituraPendiente!.complete();
          await tester.pumpAndSettle();
          expect(db.inserciones, hasLength(2));
          expect(
            db.inserciones.last['arguments'].toString(),
            contains('carbohidratos":30.0'),
          );
          final campo = tester.widget<TextField>(
            find.byKey(const ValueKey(carbohidratos)),
          );
          expect(campo.controller!.text, '60');
          expect(find.text(guardar), findsNothing);
        },
      );
    });
  }
}
