# Etapa 3 — motor de dosis y parámetros versionados

Fecha: 15 de septiembre de 2026.

## Resultado

La lógica aritmética se extrajo de las tres pantallas a un motor de dominio independiente de Flutter y SQLite. Paciente y cuidador comparten la política `domestico_v1`; enfermería usa `hospitalario_v1`. Se mantiene explícita la diferencia heredada: la primera admite una corrección negativa y la segunda la limita a cero. Esta extracción permite revisar y probar ambas políticas; no acredita su adecuación clínica.

Se eliminó el reemplazo de parámetros faltantes por I:C=15, FSI=50 y objetivo=100, así como el reemplazo de divisores inválidos por 1 en enfermería. Los campos clínicos son de solo lectura en los tres roles operativos. Los descuentos fijos de actividad dejaron de ser valores predeterminados de las pantallas: el motor exige un ajuste explícito en la versión autorizada para la actividad elegida.

**Efecto visible:** tras actualizar una instalación existente, las calculadoras quedan bloqueadas porque todavía no existe una configuración autorizada. La aplicación informa la causa y permite recargar parámetros. El registro de glucosa y las administraciones confirmadas continúan funcionando. No se agregan autorizaciones médicas como parte de la migración.

## Persistencia y verificación

SQLite pasa de versión 2 a 3; también admite la actualización directa desde la versión 1.

La tabla `parametros_dosis` identifica ámbito, paciente, versión, estado, método de cálculo, I:C, FSI, objetivo, límites de entrada, umbral de bloqueo, ajustes de actividad, autor de la autorización, fechas de autorización y vigencia y referencia de validación. No tiene valores clínicos por defecto. Las versiones no pueden editarse ni borrarse: un cambio, incluida la revocación, requiere una nueva versión.

Se adopta una regla conservadora: la versión más reciente gobierna la disponibilidad. Si esa versión es borrador, revocada, futura, vencida o inválida, se bloquea; no se recupera silenciosamente una versión anterior. El futuro flujo médico debe tener en cuenta esta regla al publicar borradores o revocaciones.

La lectura de una configuración comprueba la relación local entre sesión y paciente, el ámbito, la vigencia, la integridad de los datos, el método compatible y la existencia de un usuario local con rol `medico` indicado como autorizador. Antes de calcular se vuelve a consultar su vigencia; si la versión difiere de la mostrada, se exige recargar. Esta comprobación local es infraestructura: no prueba la identidad profesional ni sustituye autorización de servidor, firma o revisión clínica.

Guardar un cálculo vuelve a verificar la versión **dentro de la transacción**, recalcula el resultado y rechaza una dosis enviada que no corresponda a las entradas y a los parámetros. Cada cálculo nuevo conserva identificador y versión de parámetros, versión de motor e instantánea de la configuración. No se confía en valores I:C/FSI enviados libremente desde la pantalla.

Los cálculos históricos conservan contenido e identificadores. Sus nuevas columnas de autorización quedan nulas; no se les atribuye validación retroactiva. Lecturas, administraciones y reportes existentes se conservan.

## Alcance del motor

- Rechaza configuración ausente, inválida o fuera de vigencia, datos faltantes, valores no finitos, carbohidratos negativos, valores fuera del intervalo configurado y glucosa inferior al umbral configurado.
- Conserva la precisión decimal de los parámetros; las pantallas no los convierten a enteros al cargarlos.
- Usa exclusivamente ajustes de actividad especificados. La política hospitalaria no acepta descuentos por actividad.
- Guarda el resultado numérico sin una regla nueva de redondeo clínico. La interfaz lo presenta con un decimal, incluida enfermería, que antes mostraba un entero diferente del valor persistido.
- Las fórmulas heredadas están identificadas por versión; ninguna se transforma en una recomendación validada por el hecho de pasar pruebas de software.

## Pruebas

Se mantienen y adaptan las pruebas de etapas anteriores. Se añadieron casos del motor puro, persistencia SQLite e interfaz: configuración ausente/corrupta, estado borrador/revocado, caducidad, motor incompatible, límites y datos numéricos inválidos, precisión decimal, versión cambiada entre cálculo y guardado, autor no médico, rechazo de edición/borrado de versiones, recálculo en persistencia y migración v2→v3 sin autorización retroactiva.

Los datos que simulan configuraciones autorizadas están exclusivamente en `test/support/parametros_prueba.dart`, identificados como `TEST_ONLY_NO_VALIDACION_CLINICA`. No se incorporan a las instalaciones de la app ni se ejecuta un proceso de autorización en producción.

Resultado final: **94 pruebas aprobadas** en la copia de trabajo y en el proyecto original después de aplicar los cambios. Comando: `flutter --suppress-analytics --no-version-check test --no-pub`.

Análisis estático: **0 errores, 6 advertencias preexistentes y 254 avisos informativos**. Se eliminaron dos campos sin uso en las pantallas modificadas. `git diff --check` sin incidencias. No se probó en dispositivo físico ni se utilizaron datos reales de pacientes.

El código está aplicado en el repositorio. La migración se ejecutará cuando la aplicación abra su base con esta versión; durante este trabajo no se abrió ni modificó una base instalada con datos reales.

## Pendientes antes de habilitar la calculadora para uso clínico

1. Validar con las asesoras el método de corrección, insulina activa, ejercicio, límites, objetivos, redondeo e incremento del dispositivo; resolver las contradicciones de la matriz y registrar decisiones y referencias concretas.
2. Implementar el perfil médico, su vínculo autorizado con cada paciente y el flujo de publicación/revocación. Esta etapa prepara almacenamiento y consumo, pero no crea ese perfil ni una ruta para que los roles operativos se autoautoricen.
3. Incorporar autenticación y autorización del servidor, sincronización y política de vigencia offline. El archivo SQLite sigue siendo local; no se afirma protección frente a manipulación directa.
4. Definir, si se aprueban, parámetros por franja horaria. El contrato actual contiene una configuración por paciente y versión; no presume esa decisión clínica.
5. Continuar con alertas, reportes por turno, adherencia y pruebas de accesibilidad, pendientes de las etapas anteriores.

La matriz compartida continúa siendo un borrador sin validación formal registrada. Este bloque no declara cumplimiento integral ni certificación de la American Diabetes Association.
