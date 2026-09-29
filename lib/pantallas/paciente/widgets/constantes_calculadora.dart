class TextosCalculadora {
  // Botones
  static const String btnCalcular = 'Calcular Dosis';
  static const String btnGuardar = 'Guardar en Historial';
  static const String btnLimpiar = 'Limpiar cálculo';

  // Alertas
  static const String avisoMedico = 'Esta calculadora requiere parámetros y un método de cálculo autorizados para el paciente. Consulta siempre con tu médico antes de ajustar tus dosis de insulina.';
  static const String alertaHipoglucemia = 'ATENCIÓN: Tu glucosa indica hipoglucemia. NO te administres insulina ahora. Consume 15 g de carbohidratos de acción rápida y espera 15 minutos.';
  static const String alertaDescargo = 'El resultado no confirma una administración.';
  
  // Secciones
  static const String seccionMomento = 'Momento de la comida';
  static const String seccionDatos = 'Datos de la comida';
  static const String seccionActividad = 'Actividad física del día';
  static const String subtituloActividad = 'Solo se aplican ajustes incluidos en la configuración autorizada';
  static const String seccionAvanzados = 'Parámetros clínicos autorizados';
  
  // Referencia Carbohidratos
  static const String refCarbsTitulo = 'Ver referencia rápida de alimentos';
  static const String refCarbsSubtitulo = 'Carbohidratos por porción (aprox.)';

  // Campos de Texto
  static const String campoCarbsTitulo = 'Carbohidratos a ingerir';
  static const String campoCarbsHint = 'ej. 45';
  static const String campoCarbsAyuda = 'Introduce los gramos de carbohidratos de los alimentos.';
  static const String campoGlucosaTitulo = 'Glucosa actual (antes de comer)';
  static const String campoGlucosaHint = 'ej. 130';
  static const String campoGlucosaAyuda = 'Mide tu glucosa justo antes de comer';
  
  // Parámetros
  static const String paramRecargar = 'Recargar parámetros';
  static const String paramConfigurar = 'Configurar con referencias ADA 2026';
  static const String paramICTitulo = 'Relación Insulina:Carbohidratos (I:C)';
  static const String paramICAyuda = '1 UI cubre esta cantidad de gramos de carbohidratos.';
  static const String paramFSITitulo = 'Factor de Sensibilidad a Insulina (FSI)';
  static const String paramFSIAyuda = 'Cuánto baja su glucosa con 1 UI.';
  static const String paramObjetivoTitulo = 'Glucosa objetivo (antes de comer)';
  static const String paramObjetivoAyuda = 'Objetivo de la configuración autorizada.';
  static const String paramSinConfig = 'Sin configuración';
  
  // Método de Cálculo
  static const String metodoCalculoTitulo = 'Método de cálculo configurado';
  static const String metodoBoloComida = 'Bolo de comida';
  static const String metodoBoloCorreccion = 'Bolo de corrección';
  static const String metodoAutorizacion = 'La autorización debe incluir este método de cálculo.';

  // Resultados y Desglose
  static const String resDosisCalculada = 'Dosis Calculada';
  static const String resInsulinaRapida = 'Insulina de acción rápida (bolo)';
  static const String resUnidadesInsulina = 'Unidades de Insulina';
  static const String resDesgloseCalculo = 'Desglose del cálculo';
  static const String resCorreccionAlta = 'Corrección (alta)';
  static const String resCorreccionBaja = 'Corrección (baja)';
  static const String resSubtotal = 'Subtotal';
  static const String resAjusteActividad = 'Ajuste actividad';
  static const String resDosisTotal = 'DOSIS TOTAL AJUSTADA';
  
  // Estados de Glucosa (Chips)
  static const String glucosaMsgHipo = '⚠️ Glucosa muy baja. Trata la hipoglucemia.';
  static const String glucosaMsgHiper = '⚠️ Glucosa muy alta. Corrección incluida.';
  static const String glucosaMsgNormal = 'Glucosa en rango adecuado para proceder.';

  // Tutorial
  static const String tutTituloPrincipal = 'Cálculo de Dosis y Carbohidratos';
  static const String tutPreguntaInicial = 'Antes de empezar, ¿sabes cómo funciona el conteo de carbohidratos para calcular tu insulina?';
  static const String tutBtnConozco = 'Sí, ya lo conozco';
  static const String tutBtnExplicame = 'No, explícamelo por favor';
  static const String tutTituloExplicacion = '¿Qué es el Conteo de Carbohidratos?';
  static const String tutDescExplicacion = 'Es un método respaldado por médicos para calcular la cantidad EXACTA de insulina rápida que necesitas inyectarte antes de comer. Todo depende de la comida y de tu glucosa actual.';
  static const String tutSubtituloExp = '¿Cómo funciona en Insul App?';
  static const String tutPaso1Titulo = 'Tu Glucosa Actual';
  static const String tutPaso1Desc = 'Primero revisamos cómo está tu azúcar. Si está alta, la app calculará una "Dosis de Corrección" para bajarla a tu rango normal usando tu Factor de Sensibilidad (FSI).';
  static const String tutPaso2Titulo = 'Lo que vas a comer';
  static const String tutPaso2Desc = 'Si comes una manzana (15g de carbohidratos), la app calculará cuánta insulina necesitas SOLO para esa manzana usando tu Relación Insulina/Carbohidrato (RIC).';
  static const String tutPaso3Titulo = 'El Cálculo Final';
  static const String tutPaso3Desc = 'La app suma ambas cantidades y te dice la dosis total segura a inyectar:\n\nComida: 1.0 U\nCorrección: + 1.5 U\nTotal a Inyectar = 2.5 Unidades.';
  static const String tutBtnEntendido = '¡Entendido! Vamos a calcular';
}
