# InsulApp — seguimiento de requisitos y primer bloque

Fecha: 9 de septiembre de 2026.

## Base documental y alcance

Se revisaron el contenido y las tablas de `InsulApp_Especificacion_Funcional.docx` y `InsulApp_Matriz_Validacion_Clinica-2.docx`, compartidos por el responsable del proyecto. Los documentos originales no se modificaron.

La especificación establece el alcance objetivo; su descripción no prueba que cada función exista en el código. La matriz identifica expresamente sus respuestas como un borrador generado por IA pendiente de revisión de Ileana Leal o Mónica Lizárraga. No se registran aprobaciones clínicas en este bloque.

Decisiones de producto recogidas: cuatro roles como objetivo; configuración clínica reservada al médico; hasta cinco perfiles familiares y 50 pacientes por unidad institucional; menores fuera del alcance actual; usabilidad de adultos mayores pendiente. Una administración requiere confirmación explícita y debe distinguirse de una dosis calculada.

## Bloque 1: integridad de registros y resultados

| ID local | Cambio realizado | Comprobación |
| --- | --- | --- |
| INT-01 | Los formularios de glucosa de paciente, registros familiar y glucosa familiar dejan de añadir notas que afirmaban que se realizó un protocolo a partir de dos lecturas. Se conserva la nota escrita por la persona. | Seis pruebas de interfaz: lectura previa de 50 y nueva de 100, con nota vacía y explícita en cada formulario. |
| INT-02 | Las calculadoras de paciente y cuidador invalidan el resultado cuando cambia glucosa, carbohidratos, I:C, FSI, objetivo, actividad o momento de comida. Guardar exige que las entradas coincidan con las del resultado. | Edición de cada entrada; selección de texto sin modificación; recálculo y comprobación de datos guardados. |
| INT-03 | El guardado usa una instantánea coherente, bloquea pulsaciones repetidas mientras escribe y muestra un error recuperable si falla. Una edición durante la escritura no se borra al terminar. | Simulación de fallo, reintento y escritura pendiente en ambos roles. |
| REF-01 | Se comparte un tipo inmutable para las entradas del cálculo. | Compilación y pruebas de las dos pantallas. |

Se sustituye la prueba de contador de la plantilla Flutter, ajena a la aplicación, por pruebas de los formularios reales. Las pruebas simulan el canal nativo de SQLite y las preferencias: comprueban interacción y datos enviados a persistencia, no una instalación física ni la corrección clínica de las dosis.

## Limitaciones que siguen abiertas

Este bloque no cambia las fórmulas, los valores predeterminados, los descuentos por actividad ni los protocolos clínicos existentes. Tampoco implementa el perfil médico o acredita conformidad con ADA. Persisten diferencias sustanciales respecto de la especificación.

El texto heredado `Dosis ADA Calculada` sigue presente en el formato de notas. Debe reemplazarse junto con los lectores/reportes que lo interpretan, mediante eventos estructurados. Los registros históricos no se reescribieron; las antiguas notas automáticas no demuestran que se realizara una intervención.

La protección contra repetición cubre una escritura en curso desde la misma pantalla. No equivale a idempotencia entre dispositivos o sesiones ni a una bitácora clínica completa.

## Orden propuesto para los siguientes bloques

1. **Persistencia y eventos clínicos:** migraciones SQLite versionadas y pruebas de conservación de datos; entidades separadas para lectura, cálculo, administración confirmada y alerta; registrar paciente, autor, fecha, estado y procedencia. Mantener registros antiguos como históricos sin inferir administraciones desde notas. Criterio de salida: calcular no incrementa administraciones ni adherencia; confirmar crea un evento explícito y trazable.
2. **Parámetros y motor de cálculo:** separar reglas de las pantallas, eliminar dependencias en notas libres y definir un contrato de parámetros autorizado/versionado. Preparar bloqueo por configuración faltante y permisos. Las fórmulas, límites, redondeo, insulina activa y ejercicio necesitan una decisión clínica documentada antes de activarse. Criterio de salida: reglas aprobadas identificables por versión y casos de prueba revisados por el especialista.
3. **Alertas y reportes:** registrar el ciclo de vida de alertas y confirmaciones; filtrar turnos por intervalo y paciente; distinguir porcentaje de lecturas en rango de métricas derivadas de monitorización continua. Revisar el nombre y la metodología de AGP/TIR antes de presentarlos como equivalentes. Criterio de salida: cada dato exportado puede rastrearse a un evento y su periodo.
4. **Perfil médico e infraestructura pendiente:** autenticación y permisos efectivos, vínculo con paciente, autorización y auditoría de parámetros, sincronización con resolución de conflictos, recordatorios y notificaciones. El control de permisos debe incluir persistencia/servidor, no solo ocultar botones. Criterio de salida: pruebas de acceso por rol y de aislamiento entre pacientes.
5. **Validación final:** revisión clínica de reglas y textos, pruebas en dispositivos, accesibilidad con usuarios mayores y conciliación de las promesas de la memoria/plan con evidencias verificables.

Los identificadores anteriores son de seguimiento interno, no numeración original de los entregables.

## Puntos que deben aclararse en la matriz

- La primera tabla carece de la columna de validación que sí aparece en las siguientes. Añadir estado, responsable, fecha, versión, referencia y observaciones a cada regla antes de aprobarla.
- Corregir “Estado actual”: autorización exclusiva por médico y sincronización offline describen objetivos que todavía no están implementados.
- Precisar si una lectura fuera de 20–600 se rechaza o puede guardarse tras confirmación, cómo se registra esa excepción y cómo se maneja un valor HI/LO del dispositivo. Especificar el comportamiento sin inventar límites clínicos.
- Revisar conjuntamente los protocolos de hipoglucemia: la matriz mezcla un umbral numérico con severidad clínica y contiene caminos de escalamiento que requieren conciliación profesional.
- No adoptar la frase sobre “mayor tolerancia a hipoglucemia leve” en menores. Mantener esta población fuera de alcance y corregir la propuesta con el especialista. Referencias para la revisión: [ADA 2026, objetivos glucémicos e hipoglucemia](https://doi.org/10.2337/dc26-S006) y [ADA 2026, niños y adolescentes](https://doi.org/10.2337/dc26-S014).
- Obtener decisiones explícitas sobre franjas de I:C, FSI, objetivo, insulina activa, incremento de dosis, ejercicio y escalamiento. Las sugerencias cuantitativas del borrador no se convierten automáticamente en requisitos aprobados.

## Resultado de verificación

28 pruebas automatizadas aprobadas tanto en la copia de trabajo como en el proyecto original después de aplicar. Comando: `flutter --suppress-analytics --no-version-check test --no-pub`. Análisis estático: 0 errores, 8 advertencias y 269 avisos informativos; no se considera un análisis limpio y la limpieza restante se mantiene pendiente. `git diff --check` sin incidencias. No se ejecutaron pruebas clínicas, pruebas en dispositivo físico ni validación de dosis para uso real.


## Avance de la etapa 2

Se implementó la separación de lecturas, cálculos y administraciones confirmadas, con migración SQLite v1 a v2. El alcance, las pruebas y las limitaciones actualizadas están en [Etapa 2 — eventos clínicos](etapa2_eventos_clinicos.md). Esta actualización sustituye las limitaciones del bloque 1 relativas al almacenamiento nuevo en notas; las reglas clínicas continúan pendientes.
