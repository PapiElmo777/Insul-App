# Etapa 4 — referencias ADA 2026 y configuración pendiente

Fecha: 15 de septiembre de 2026.

## Cambios implementados

Las tres calculadoras permiten abrir **Configurar con referencias ADA 2026**. Se exige seleccionar el contexto y se muestran las fuentes. I:C, FSI y objetivo de corrección son opcionales, quedan vacíos inicialmente y solo permiten registrar valores positivos para revisión; no constituyen una prescripción autorizada.

| Contexto | Referencia mostrada (mg/dL) | Fuente |
| --- | --- | --- |
| Muchos adultos ambulatorios no embarazados | Preprandial 80–130; pico posprandial <180, 1–2 horas desde el inicio de la comida | [ADA 2026, capítulo 6, tabla 6.3](https://doi.org/10.2337/dc26-S006) |
| Hospitalización no crítica | 100–180 si puede alcanzarse sin hipoglucemia significativa | [ADA 2026, capítulo 16](https://doi.org/10.2337/dc26-S016) |
| Revisión individual | Sin meta numérica automática | [ADA 2026, capítulo 6](https://doi.org/10.2337/dc26-S006) |

Estas metas no se copian al objetivo de corrección de insulina. La referencia hospitalaria no cubre UCI ni protocolos intravenosos. Embarazo, fragilidad y otras situaciones especiales requieren revisión; menores siguen fuera del alcance actual.

El motor bloquea el cálculo de bolos con glucosa <70 y rechaza configuraciones que reduzcan ese umbral. Los mensajes distinguen nivel 1 (54 a <70) y nivel 2 (<54). El nivel 3 depende de alteración funcional que requiere asistencia, no de un umbral numérico. El bloqueo es una decisión de seguridad de InsulApp basada en estas definiciones, no una fórmula de dosificación emitida por ADA. Se validan primero las lecturas inválidas o no positivas. Fuente: [ADA 2026, capítulo 6, tabla 6.4](https://doi.org/10.2337/dc26-S006).

## Persistencia y autorización

SQLite pasa a versión 4. La nueva tabla `solicitudes_configuracion` guarda paciente, ámbito, autor, fecha, contexto, edición/fuente y valores propuestos, siempre pendientes. El guardado comprueba la sesión y pertenencia del paciente. Los reintentos con el mismo identificador y contenido no duplican solicitudes.

Las solicitudes se guardan separadas de las versiones de parámetros autorizados: no activan cálculos ni invalidan una pauta vigente. La migración conserva los datos previos sin crear aprobaciones. La pantalla presenta el historial local; no envía solicitudes a un médico ni implementa todavía su perfil.

## Pendientes para habilitar dosificación clínica

Es necesaria una pauta individual revisada con I:C, FSI, objetivo, límites, reglas de ejercicio, insulina activa e incremento/redondeo del dispositivo. No se asignan valores universales ni se interpretan los borradores de la matriz como autorizaciones. [ADA 2026, capítulo 9](https://doi.org/10.2337/dc26-S009) aborda ajuste individual de insulina y educación para la dosificación; [capítulo 5](https://doi.org/10.2337/dc26-S005) aborda actividad física y adaptación individual.

Continúan pendientes el flujo del médico para revisar y autorizar, permisos robustos y casos de validación clínica de las fórmulas. Este bloque no implementa insulina activa ni redondeo, no reemplaza las fórmulas heredadas por un algoritmo validado y no acredita cumplimiento integral o certificación ADA. Sin parámetros autorizados, las calculadoras permanecen bloqueadas.

## Verificación

109 pruebas automatizadas aprobadas: límites de hipoglucemia, referencias, separación entre solicitudes y autorizaciones, aislamiento por paciente/sesión, idempotencia, migración v3 a v4 e interacción de configuración en los tres ámbitos, además de las pruebas previas. Verificación final realizada también en el proyecto original después de aplicar los cambios. Análisis estático sin errores; permanecen seis advertencias anteriores. No se realizaron pruebas clínicas ni en dispositivo físico.
