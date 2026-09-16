import 'package:flutter_test/flutter_test.dart';
import 'package:insulapp/dominio/motor_dosis.dart';
import 'package:insulapp/modelos/parametros_dosis.dart';
import 'support/parametros_prueba.dart';

void main() {
  final ahora = DateTime.utc(2026, 9, 15);
  ParametrosDosis p([Map<String, Object?> cambios = const {}]) =>
      ParametrosDosis.desdeMapa({
        ...parametrosDePrueba('personal'),
        ...cambios,
      });
  ResultadoDosis calcular({
    ParametrosDosis? config,
    double? glucosa = 150,
    double? carbs = 30,
    String actividad = 'Sedentario',
  }) => MotorDosis.calcular(
    parametros: config ?? p(),
    glucosa: glucosa,
    carbohidratos: carbs,
    actividad: actividad,
    ahora: ahora,
  );
  final bloqueado = throwsA(isA<CalculoNoDisponible>());

  test('sin configuración no usa valores genéricos', () {
    expect(
      () => MotorDosis.calcular(
        parametros: null,
        glucosa: 150,
        carbohidratos: 30,
        actividad: 'Sedentario',
        ahora: ahora,
      ),
      bloqueado,
    );
  });
  test(
    'conserva la aritmética de las políticas heredadas sin declararlas aprobadas',
    () {
      expect(calcular().dosis, 3);
      expect(calcular(glucosa: 80).dosis, closeTo(1.6, 1e-12));
      expect(
        calcular(
          config: p({'motor_version': MotorDosis.hospitalario}),
          glucosa: 80,
        ).dosis,
        2,
      );
      expect(calcular(actividad: 'Ligero').dosis, closeTo(2.7, 1e-12));
      expect(calcular(glucosa: 80, carbs: 0).dosis, 0);
    },
  );
  for (final estado in ['borrador', 'revocada']) {
    test('bloquea estado $estado', () {
      expect(() => calcular(config: p({'estado': estado})), bloqueado);
    });
  }
  for (final cambio in <Map<String, Object?>>[
    {'vigente_hasta': '2026-09-15T00:00:00Z'},
    {'vigente_desde': '2027-01-01T00:00:00Z'},
    {'autorizada_en': '2027-01-01T00:00:00Z'},
    {'referencia_validacion': ''},
    {'motor_version': 'desconocido'},
    {'ric': 0.0},
    {'fsi': -1.0},
    {'objetivo': double.nan},
    {'glucosa_max': 10.0},
    {'umbral_hipo': 700.0},
    {'ajustes_actividad_json': '{"Sedentario":1.0}'},
  ]) {
    test('rechaza configuración inválida: $cambio', () {
      expect(() => calcular(config: p(cambio)), bloqueado);
    });
  }
  for (final valor in [null, -1.0, double.nan, double.infinity]) {
    test('rechaza carbohidratos inválidos $valor', () {
      expect(() => calcular(carbs: valor), bloqueado);
    });
  }
  for (final valor in [
    null,
    -1.0,
    19.0,
    601.0,
    double.nan,
    double.infinity,
    69.0,
  ]) {
    test('bloquea glucosa inválida o inferior al umbral $valor', () {
      expect(() => calcular(glucosa: valor), bloqueado);
    });
  }
  test('conserva parámetros decimales sin truncar', () {
    expect(
      calcular(config: p({'ric': 12.5, 'fsi': 40.5, 'objetivo': 100.5})).dosis,
      closeTo(30 / 12.5 + (150 - 100.5) / 40.5, 1e-12),
    );
  });
  test('actividad sin ajuste explícito bloquea el cálculo', () {
    expect(
      () => calcular(
        config: p({'ajustes_actividad_json': '{"Sedentario":0}'}),
        actividad: 'Ligero',
      ),
      bloqueado,
    );
  });
  test('hospitalario no acepta un descuento por ejercicio', () {
    expect(
      () => calcular(
        config: p({'motor_version': MotorDosis.hospitalario}),
        actividad: 'Ligero',
      ),
      bloqueado,
    );
  });
}
