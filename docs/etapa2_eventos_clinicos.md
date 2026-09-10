# Etapa 2 — separar cálculos y administraciones

Fecha: 9 de septiembre de 2026.

## Resultado y alcance

Se incorporó persistencia estructurada para distinguir una lectura, una dosis calculada y una administración confirmada. Las calculadoras de paciente, cuidador y enfermería guardan cálculos; ninguna confirma por sí sola una aplicación. Los flujos de registro de insulina de los tres roles requieren identificar la insulina, introducir las unidades realmente aplicadas y confirmar expresamente la administración.

El checklist hospitalario crea una confirmación explícita por medicamento; corregir esa confirmación conserva la fila original, el autor de la corrección, su fecha y un motivo. Los datos consultados para el historial y la exportación hospitalaria ya no interpretan un cálculo o una marca histórica sin fecha como una administración nueva.

## Datos y migración

- SQLite pasa de versión 1 a 2. Tanto instalaciones nuevas como actualizaciones usan el mismo esquema.
- La migración añade `calculos_dosis`, `administraciones` y la tabla base `alertas_clinicas`. Esta última queda preparada para la siguiente implementación del motor; no activa protocolos, notificaciones ni estados automáticos.
- Las tablas de glucosa se conservan y reciben columnas de autor y procedencia. Las filas anteriores mantienen sus valores originales y se identifican como `legado`; no se les inventa un autor.
- Las notas antiguas, incluidas `Dosis ADA Calculada` y `Dosis Manual`, permanecen intactas. No se convierten en administraciones ni se extraen cantidades mediante expresiones regulares. Las vistas las presentan separadas como antecedentes sin confirmación verificable.
- Se conserva `insulina_enfermero` como histórico, porque el flujo anterior mezclaba aplicaciones manuales y cálculos. Sus filas no acreditan, por sí mismas, una aplicación.
- Los nuevos eventos identifican ámbito, paciente, usuario autor, fecha, procedencia y estado. Los ámbitos personal, familiar e institucional distinguen identificadores numéricos que pueden coincidir.
- Antes de escribir o consultar eventos nuevos se comprueba la sesión local y la relación con el paciente. Esta comprobación no reemplaza la autenticación remota, las políticas de servidor o la protección del archivo SQLite.

Guardar un cálculo inserta su lectura de glucosa y el cálculo enlazado dentro de una transacción. Si una escritura falla, se revierten ambas. La administración se guarda en su propia tabla y ya no crea una glucosa de cero. Los identificadores de operación permiten reintentar el mismo evento sin duplicarlo; reutilizar un identificador con datos diferentes produce error.

Se guardan las entradas efectivas del cálculo y el resultado numérico, sin tratarlo como dosis administrada. En enfermería se deja de convertir el resultado a unidades enteras para insertarlo como suministro. Esto es una corrección de representación/persistencia, no la aprobación de una regla clínica de redondeo.

## Cambios de interfaz

1. Guardar en las calculadoras informa: “Cálculo guardado. No registra una administración”.
2. El registro de insulina tiene un diálogo compartido con confirmación explícita, validación de datos, bloqueo durante escritura y reintento ante fallo.
3. Los historiales separan administraciones confirmadas, cálculos guardados y registros anteriores sin confirmación verificable.
4. En enfermería, marcar un medicamento solicita confirmar que ya se administró; desmarcar solicita anular la confirmación. Las marcas anteriores quedan identificadas como históricas.

La estructura admite una administración vinculada a un cálculo y comprueba que ambos pertenezcan al mismo paciente. Esta etapa no agrega un botón de aplicación automática a las calculadoras.

## Verificación

La suite incorpora pruebas de interfaz y pruebas con SQLite real mediante las dependencias de desarrollo `sqflite_common_ffi` y `sqlite3`. Se conserva el resto de versiones del archivo de dependencias. Se siguió la [documentación del paquete](https://pub.dev/packages/sqflite_common_ffi) para utilizar SQLite en pruebas locales.

Cobertura relevante:

- Instalación nueva y migración de una base v1 conservando notas, fechas antiguas, registros hospitalarios y bytes de reportes.
- Reapertura sin duplicar datos y fallo de migración con reversión de columnas y conservación de la versión anterior.
- Separación lectura/cálculo/administración, enlace entre lectura y cálculo, metadatos y rechazo de glucosas cero como registro manual nuevo.
- Reversión de la lectura si falla la inserción del cálculo.
- Reintentos idempotentes, rechazo de operaciones con el mismo identificador y distinto contenido.
- Aislamiento entre ámbitos, ausencia de sesión y vínculo a cálculo/medicamento ajeno.
- Administración explícita, anulación trazable e intervalos de consulta en UTC con límite final excluido.
- Las tres calculadoras no registran administraciones al guardar; los tres diálogos requieren confirmación.
- Las consultas hospitalarias excluyen cálculos y antiguas marcas sin confirmación verificable.

Resultado final: **49 pruebas aprobadas**, tanto en la copia de trabajo como después de aplicar los cambios al proyecto original. Comando: `flutter --suppress-analytics --no-version-check test --no-pub`.

Análisis estático: **0 errores, 8 advertencias y 264 avisos informativos**. Las ocho advertencias ya existían; la limpieza general sigue pendiente. `git diff --check` sin incidencias. No se hicieron pruebas clínicas, pruebas en un dispositivo físico ni pruebas sobre una base de datos real de pacientes.

El código ya está aplicado en el repositorio. La migración de la base instalada se ejecutará al abrir esa base con la nueva versión de la aplicación; este trabajo no abrió ni modificó datos reales de pacientes.

## Pendientes y límites

- Las fórmulas, parámetros por defecto, descuentos por ejercicio y protocolos heredados siguen pendientes de la etapa clínica. La nueva persistencia no acredita cumplimiento ADA ni valida una dosis para uso real.
- La tabla de alertas es infraestructura, no un motor implementado. Sigue pendiente su ciclo completo y su integración en reportes.
- La exportación hospitalaria sigue pendiente de filtrado efectivo por turno y de presentar todas las administraciones como eventos individuales; el checklist todavía resume el estado del medicamento. No constituye una agenda de tomas ni resuelve administraciones repetidas por horario.
- Sigue pendiente incorporar la confirmación de medicamentos orales al flujo doméstico y familiar. Los eventos genéricos ya permiten almacenarlos; la interfaz implementada en estos ámbitos corresponde a insulina.
- No se calcula un porcentaje nuevo de adherencia. Para hacerlo faltan una pauta versionada y las tomas esperadas; no se deben derivar de cálculos guardados ni de notas antiguas.
- Los PDF históricos no se regeneran ni se reclasifican; el cambio afecta los registros nuevos y las consultas actuales.
- La bitácora de correcciones existe en persistencia y en el flujo de anulación hospitalaria; una pantalla completa de auditoría y corrección para los demás roles queda pendiente.
- El perfil médico, sincronización, autorización clínica, protección de credenciales y pruebas en dispositivos físicos corresponden a los siguientes bloques.

## Siguiente bloque

Separar el motor de cálculo de las pantallas y definir parámetros clínicos persistentes, versionados y autorizados. La matriz sigue siendo un borrador: no activar sus propuestas clínicas como reglas aprobadas. Preparar primero el comportamiento ante configuración ausente y casos de prueba para revisión de las asesoras.
