/// Referencias generales, no una prescripción ni parámetros de dosificación.
/// ADA Standards of Care 2026, tablas 6.3/6.4 y recomendaciones hospitalarias.
enum ContextoReferencia { adultoAmbulatorio, hospitalNoCritico, individualizar }

enum HipoglucemiaNumerica { ninguna, nivel1, nivel2 }

class ReferenciaAda {
  final ContextoReferencia contexto;
  final String nombre, descripcion, fuente, alcance;
  final double? metaMin, metaMax, picoPosprandialMenorQue;
  const ReferenciaAda(
    this.contexto,
    this.nombre,
    this.descripcion,
    this.fuente,
    this.alcance, {
    this.metaMin,
    this.metaMax,
    this.picoPosprandialMenorQue,
  });
  Map<String, Object?> get datos => {
    'edicion': 2026,
    'contexto': contexto.name,
    'fuente': fuente,
    'alcance': alcance,
    'meta_min': metaMin,
    'meta_max': metaMax,
    'pico_posprandial_menor_que': picoPosprandialMenorQue,
    'hipoglucemia_menor_que': ReferenciasAda.umbralHipo,
    'hipoglucemia_nivel2_menor_que': ReferenciasAda.umbralNivel2,
    'es_prescripcion': false,
  };
}

class ReferenciasAda {
  static const umbralHipo = 70.0;
  static const umbralNivel2 = 54.0;
  static const generales = ReferenciaAda(
    ContextoReferencia.adultoAmbulatorio,
    'Adulto ambulatorio no embarazado',
    'Referencia preprandial: 80–130 mg/dL. Pico posprandial: menos de 180 mg/dL, medido 1–2 horas después de comenzar la comida.',
    'https://doi.org/10.2337/dc26-S006',
    'Metas generales para muchos adultos no embarazados; requieren individualización.',
    metaMin: 80,
    metaMax: 130,
    picoPosprandialMenorQue: 180,
  );
  static const hospital = ReferenciaAda(
    ContextoReferencia.hospitalNoCritico,
    'Hospitalización no crítica',
    'Referencia hospitalaria no crítica: 100–180 mg/dL, si se logra sin hipoglucemia significativa.',
    'https://doi.org/10.2337/dc26-S016',
    'No corresponde a UCI, embarazo ni a un protocolo de insulina intravenosa.',
    metaMin: 100,
    metaMax: 180,
  );
  static const individualizar = ReferenciaAda(
    ContextoReferencia.individualizar,
    'Requiere revisión individual',
    'No se asignan metas automáticamente. Edad avanzada, fragilidad, comorbilidad, embarazo y enfermedad crítica requieren evaluación específica. Menores fuera del alcance actual.',
    'https://doi.org/10.2337/dc26-S006',
    'Sin propuesta numérica automática.',
  );
  static ReferenciaAda para(ContextoReferencia c) => switch (c) {
    ContextoReferencia.adultoAmbulatorio => generales,
    ContextoReferencia.hospitalNoCritico => hospital,
    ContextoReferencia.individualizar => individualizar,
  };
  static HipoglucemiaNumerica clasificar(double glucosa) {
    if (!glucosa.isFinite || glucosa <= 0) {
      throw ArgumentError('Lectura inválida');
    }
    if (glucosa < umbralNivel2) return HipoglucemiaNumerica.nivel2;
    if (glucosa < umbralHipo) return HipoglucemiaNumerica.nivel1;
    return HipoglucemiaNumerica.ninguna;
  }

  // Nivel 3 depende de la necesidad de asistencia, no de una cifra aislada.
}
