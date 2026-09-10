import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insulapp/widgets/dialogo_administracion.dart';
import 'package:insulapp/modelos/paciente_clinico.dart';
import 'package:insulapp/pantallas/enfermeros/pantalla_calculadora_enfermero.dart';
import 'support/base_datos_simulada.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late BaseDatosSimulada db;
  setUp(() {
    db = BaseDatosSimulada()..instalar();
  });

  Future<void> abrir(WidgetTester tester, AmbitoPaciente ambito) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => TextButton(
              onPressed: () => mostrarRegistroAdministracion(
                ctx,
                PacienteClinico(ambito, 1),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('insulina_aplicada')),
      'Insulina de prueba',
    );
    await tester.enterText(
      find.byKey(const ValueKey('unidades_aplicadas')),
      '3.5',
    );
  }

  for (final ambito in AmbitoPaciente.values) {
    testWidgets(
      '${ambito.name}: guardar requiere confirmación y solo inserta administración',
      (tester) async {
        await abrir(tester, ambito);
        await tester.tap(find.text('Guardar administración'));
        await tester.pumpAndSettle();
        expect(db.inserciones, isEmpty);
        expect(find.textContaining('Indica la insulina'), findsOneWidget);
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar administración'));
        await tester.pumpAndSettle();
        expect(db.inserciones, hasLength(1));
        expect(
          db.inserciones.single['sql'],
          contains('INSERT INTO administraciones'),
        );
        expect(db.inserciones.single['arguments'], contains(3.5));
        expect(db.inserciones.single['arguments'], contains(ambito.name));
        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  }
  testWidgets('cancelar no registra administración', (tester) async {
    await abrir(tester, AmbitoPaciente.personal);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(db.inserciones, isEmpty);
  });
  testWidgets(
    'fallo de administración conserva formulario y permite reintento',
    (tester) async {
      await abrir(tester, AmbitoPaciente.personal);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      db.fallaInsertar = true;
      await tester.tap(find.text('Guardar administración'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No se pudo guardar.'), findsOneWidget);
      final primerIntento = db.inserciones.single['arguments'];
      db.fallaInsertar = false;
      await tester.tap(find.text('Guardar administración'));
      await tester.pumpAndSettle();
      expect(db.inserciones, hasLength(2));
      expect(
        (db.inserciones.last['arguments'] as List).first,
        (primerIntento as List).first,
      );
    },
  );
  testWidgets('enfermería guarda un cálculo sin registrar insulina aplicada', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: PantallaCalculadoraEnfermero(
          paciente: {'id': 1, 'nombre': 'Prueba'},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final campos = find.byType(TextField);
    // Meta, FSI, RIC, glucosa y carbohidratos en el formulario institucional.
    await tester.enterText(campos.at(3), '150');
    await tester.enterText(campos.at(4), '30');
    await tester.pumpAndSettle();
    final guardar = find.text('Guardar cálculo');
    await tester.ensureVisible(guardar);
    await tester.tap(guardar);
    await tester.pumpAndSettle();
    expect(db.inserciones, hasLength(2));
    expect(
      db.inserciones.first['sql'],
      contains('INSERT INTO glucosa_enfermero'),
    );
    expect(db.inserciones.last['sql'], contains('INSERT INTO calculos_dosis'));
    expect(
      db.inserciones.where(
        (i) => (i['sql'] as String).contains('INSERT INTO insulina_enfermero'),
      ),
      isEmpty,
    );
    expect(
      db.inserciones.where(
        (i) => (i['sql'] as String).contains('INSERT INTO administraciones'),
      ),
      isEmpty,
    );
  });
}
