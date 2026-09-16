import 'dart:convert';
import 'paciente_clinico.dart';

/// Una versión inmutable. Ningún valor clínico se completa por defecto.
class ParametrosDosis {
  final String id, estado, motor, referenciaValidacion;
  final PacienteClinico paciente;
  final int version, autorizadoPor;
  final DateTime autorizadaEn, vigenteDesde, vigenteHasta;
  final double ric, fsi, objetivo, glucosaMin, glucosaMax, umbralHipo;
  final Map<String, double> ajustesActividad;

  ParametrosDosis.desdeMapa(Map<String, Object?> r)
    : id = r['id'] as String,
      paciente = PacienteClinico(
        AmbitoPaciente.values.byName(r['ambito'] as String),
        r['paciente_id'] as int,
      ),
      version = r['version'] as int,
      estado = r['estado'] as String,
      motor = r['motor_version'] as String,
      referenciaValidacion = r['referencia_validacion'] as String,
      autorizadoPor = r['autorizado_por'] as int,
      autorizadaEn = DateTime.parse(r['autorizada_en'] as String),
      vigenteDesde = DateTime.parse(r['vigente_desde'] as String),
      vigenteHasta = DateTime.parse(r['vigente_hasta'] as String),
      ric = (r['ric'] as num).toDouble(),
      fsi = (r['fsi'] as num).toDouble(),
      objetivo = (r['objetivo'] as num).toDouble(),
      glucosaMin = (r['glucosa_min'] as num).toDouble(),
      glucosaMax = (r['glucosa_max'] as num).toDouble(),
      umbralHipo = (r['umbral_hipo'] as num).toDouble(),
      ajustesActividad = Map.unmodifiable(
        (jsonDecode(r['ajustes_actividad_json'] as String)
                as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      );

  bool vigente(DateTime ahora) =>
      estado == 'autorizada' &&
      !ahora.isBefore(vigenteDesde) &&
      ahora.isBefore(vigenteHasta) &&
      !autorizadaEn.isAfter(ahora) &&
      referenciaValidacion.trim().isNotEmpty;

  Map<String, Object?> get instantanea => {
    'id': id,
    'version': version,
    'ambito': paciente.ambito.name,
    'paciente_id': paciente.id,
    'estado': estado,
    'motor_version': motor,
    'ric': ric,
    'fsi': fsi,
    'objetivo': objetivo,
    'glucosa_min': glucosaMin,
    'glucosa_max': glucosaMax,
    'umbral_hipo': umbralHipo,
    'ajustes_actividad': ajustesActividad,
    'autorizado_por': autorizadoPor,
    'autorizada_en': autorizadaEn.toUtc().toIso8601String(),
    'vigente_desde': vigenteDesde.toUtc().toIso8601String(),
    'vigente_hasta': vigenteHasta.toUtc().toIso8601String(),
    'referencia_validacion': referenciaValidacion,
  };
}
