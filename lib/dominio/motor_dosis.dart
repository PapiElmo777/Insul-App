import 'dart:math' as math;
import 'referencias_ada.dart';
import '../modelos/parametros_dosis.dart';

class CalculoNoDisponible implements Exception {
  final String mensaje;
  const CalculoNoDisponible(this.mensaje);
  @override
  String toString() => mensaje;
}

class ResultadoDosis {
  final double comida, correccion, total, ajuste, dosis;
  const ResultadoDosis(
    this.comida,
    this.correccion,
    this.total,
    this.ajuste,
    this.dosis,
  );
}

/// Extrae las dos políticas preexistentes. Su presencia no es validación clínica.
/// Solo se ejecutan con una versión de parámetros explícitamente autorizada.
class MotorDosis {
  static const domestico = 'domestico_v1';
  static const hospitalario = 'hospitalario_v1';
  static const faltaConfiguracion =
      'Cálculo no disponible: falta una configuración clínica autorizada y vigente.';

  static ParametrosDosis validarConfiguracion(
    ParametrosDosis? parametros,
    DateTime ahora,
  ) {
    final p = parametros;
    if (p == null || !p.vigente(ahora)) {
      throw const CalculoNoDisponible(faltaConfiguracion);
    }
    if (p.motor != domestico && p.motor != hospitalario) {
      throw const CalculoNoDisponible(
        'La versión del motor no es compatible con esta aplicación.',
      );
    }
    final valores = [
      p.ric,
      p.fsi,
      p.objetivo,
      p.glucosaMin,
      p.glucosaMax,
      p.umbralHipo,
    ];
    if (valores.any((v) => !v.isFinite || v <= 0) ||
        p.glucosaMin >= p.glucosaMax ||
        p.umbralHipo < ReferenciasAda.umbralHipo ||
        p.umbralHipo < p.glucosaMin ||
        p.umbralHipo > p.glucosaMax ||
        p.objetivo < p.glucosaMin ||
        p.objetivo > p.glucosaMax) {
      throw const CalculoNoDisponible(
        'La configuración clínica está incompleta o contiene valores inválidos.',
      );
    }
    if (p.ajustesActividad.isEmpty ||
        p.ajustesActividad.values.any((v) => !v.isFinite || v < 0 || v >= 1)) {
      throw const CalculoNoDisponible(
        'Los ajustes por actividad no son válidos.',
      );
    }
    return p;
  }

  static ResultadoDosis calcular({
    required ParametrosDosis? parametros,
    required double? glucosa,
    required double? carbohidratos,
    required String actividad,
    required DateTime ahora,
  }) {
    final p = validarConfiguracion(parametros, ahora);
    if (glucosa == null ||
        carbohidratos == null ||
        !glucosa.isFinite ||
        glucosa <= 0 ||
        !carbohidratos.isFinite ||
        carbohidratos < 0) {
      throw const CalculoNoDisponible(
        'Introduce glucosa y carbohidratos válidos.',
      );
    }
    // Política de seguridad de la app basada en el umbral ADA. No es una fórmula ADA de dosis.
    if (glucosa < ReferenciasAda.umbralHipo) {
      throw CalculoNoDisponible(glucosa < ReferenciasAda.umbralNivel2
        ? 'Glucosa inferior a 54 mg/dL: hipoglucemia nivel 2. No se calcula un bolo. Sigue tu plan de atención.'
        : 'Glucosa inferior a 70 mg/dL: no se calcula un bolo. Sigue tu plan de atención.');
    }
    if (glucosa < p.glucosaMin || glucosa > p.glucosaMax) {
      throw const CalculoNoDisponible(
        'La glucosa está fuera del intervalo autorizado para calcular.',
      );
    }
    if (glucosa < p.umbralHipo) {
      throw const CalculoNoDisponible(
        'La glucosa está por debajo del umbral autorizado para calcular. Consulta tu plan de atención.',
      );
    }
    final reduccion = p.ajustesActividad[actividad];
    if (reduccion == null ||
        !reduccion.isFinite ||
        reduccion < 0 ||
        reduccion >= 1) {
      throw const CalculoNoDisponible(
        'No hay un ajuste autorizado para la actividad seleccionada.',
      );
    }
    if (p.motor == hospitalario && reduccion != 0) {
      throw const CalculoNoDisponible(
        'Este motor no admite ajustes por actividad.',
      );
    }
    final comida = carbohidratos / p.ric;
    final diferencia = (glucosa - p.objetivo) / p.fsi;
    final correccion = p.motor == hospitalario
        ? math.max(0.0, diferencia)
        : diferencia;
    final total = comida + correccion;
    final ajuste = math.max(0.0, total) * reduccion;
    final dosis = math.max(0.0, total - ajuste);
    if ([comida, correccion, total, ajuste, dosis].any((v) => !v.isFinite)) {
      throw const CalculoNoDisponible(
        'No fue posible obtener un resultado numérico válido.',
      );
    }
    return ResultadoDosis(comida, correccion, total, ajuste, dosis);
  }
}
