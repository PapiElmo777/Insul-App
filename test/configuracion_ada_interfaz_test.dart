import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insulapp/modelos/paciente_clinico.dart';
import 'package:insulapp/dominio/referencias_ada.dart';
import 'package:insulapp/pantallas/pantalla_configuracion_ada.dart';
import 'support/base_datos_simulada.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final ambito in AmbitoPaciente.values) {
    testWidgets(
      '${ambito.name}: contexto explícito y guardado pendiente sin prescripción ficticia',
      (tester) async {
        final db = BaseDatosSimulada()..instalar();
        await tester.binding.setSurfaceSize(const Size(1000, 2000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            home: PantallaConfiguracionAda(
              paciente: PacienteClinico(ambito, 1),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final input in tester.widgetList<TextField>(
          find.byType(TextField),
        )) {
          expect(input.controller!.text, isEmpty);
        }
        await tester.tap(find.text('Guardar para revisión'));
        await tester.pumpAndSettle();
        expect(db.inserciones, isEmpty);
        await tester.tap(
          find.byType(DropdownButtonFormField<ContextoReferencia>),
        );
        await tester.pumpAndSettle();
        final contexto = ambito == AmbitoPaciente.institucional
            ? 'Hospitalización no crítica'
            : 'Adulto ambulatorio no embarazado';
        await tester.tap(find.text(contexto).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar para revisión'));
        await tester.pumpAndSettle();
        expect(db.inserciones, hasLength(1));
        expect(
          db.inserciones.single['sql'],
          contains('INSERT INTO solicitudes_configuracion'),
        );
        expect(
          db.inserciones.single['arguments'].toString(),
          contains('"ric":null'),
        );
        expect(
          find.textContaining('Solicitud guardada localmente'),
          findsOneWidget,
        );
      },
    );
  }
}
