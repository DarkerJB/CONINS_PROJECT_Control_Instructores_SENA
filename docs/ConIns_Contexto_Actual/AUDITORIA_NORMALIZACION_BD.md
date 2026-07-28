# Auditoría de normalización — Base de datos CONINS

**Fecha:** 24 de julio de 2026
**Autor:** Jair (con revisión asistida)
**Alcance:** las 29 tablas del schema v5

---

## Cómo leer esta auditoría (criterios)

Reviso cada tabla contra tres preguntas prácticas:

1. **¿Guarda un solo tipo de cosa?** (evitar mezclar entidades distintas).
2. **¿Cada dato vive en un solo lugar?** (evitar el mismo dato en dos sitios que
   se puedan desincronizar).
3. **¿Es un dato que se guarda o uno que se calcula?** Un dato que se puede
   derivar de otros (ej. "¿está disponible?") normalmente **no se almacena**, se
   calcula al leer — así nunca queda desactualizado.

Veredictos que uso:

- ✅ **Bien** — mantener como está.
- 🟡 **Consolidar** — redundancia estructural real, candidata a unir.
- ⚠️ **Dispersión** — un mismo concepto repartido en varios sitios; decidir fuente única.
- 🔵 **Estado calculado** — no es problema de tabla; exponer un valor derivado en la API.

---

## Resumen por tabla

| Tabla | Veredicto | Nota |
|---|---|---|
| jornadas | ✅ Bien | Catálogo simple |
| roles | ✅ Bien | Comentario `nivel` obsoleto (dice "3=Lider") — corregir texto |
| areas | ✅ Bien | Agrupador de programas — NO duplica programas (ver abajo) |
| usuarios | ✅ Bien | — |
| usuario_roles | ✅ Bien | N:M correcto |
| instructores | ✅ Bien | Extiende usuario (1:1) |
| programas | ✅ Bien | Pertenece a un área (N:1) |
| competencias | ✅ Bien | `codigo` sin UNIQUE — revisar |
| raps | ✅ Bien | `codigo` sin UNIQUE — revisar |
| ambientes | ✅ Bien | — |
| fichas | ⚠️ Dispersión | 3 campos de estado solapados: `estado`, `activo`, `etapa` + `lider_id` |
| asignacion | ⚠️ Dispersión | `es_lider_ficha` solapa con `fichas.lider_id` |
| asignacion_competencia | ✅ Bien | — |
| asignacion_rap | ✅ Bien | Nueva (RF-42) |
| rap_ficha_seguimiento | 🔵 Mejora | Repite `(asignacion_competencia_id, rap_id)` que ya está en asignacion_rap |
| lider_programa | ✅ Bien | Referente de programa (N:M) |
| instructor_competencias_habilitadas | ✅ Bien | N:M correcto |
| tipos_actividad | ✅ Bien | — |
| horarios | ✅ Bien | Tabla central |
| alertas | ✅ Bien | Solapa conceptualmente con notificaciones (mantener) |
| tipos_novedad_instructor | 🟡 Consolidar | Idéntica a las otras dos `tipos_novedad_*` |
| tipos_novedad_ambiente | 🟡 Consolidar | Idéntica |
| tipos_novedad_ficha | 🟡 Consolidar | Idéntica |
| instructor_novedades | ✅ Bien | Evento con ventana; mantener separada |
| ficha_novedades | ✅ Bien | Evento con ventana; mantener separada |
| ambiente_bloqueos | 🔵 Estado calculado | Exponer `disponible` derivado en la API |
| notificaciones | ✅ Bien | — |
| auditoria | ✅ Bien | Bitácora transversal |
| password_reset_tokens | ✅ Bien | — |

**Balance:** de 29 tablas, 22 están bien. Hay 3 candidatas claras a consolidar,
2 casos de dispersión de concepto, 1 mejora fina y 1 estado calculado.

---

## Tus dos ejemplos, resueltos

### Áreas vs Programas → NO es redundancia (mantener)

`areas` son las 10 líneas del centro (ADSO, Talento Humano, Bilingüismo, Técnico
Medular…). `programas` son los programas con código SENA (228118 "Tecnología en
ADSO", "Técnico en Asistencia Administrativa"…). Relación 1 área → N programas.
El nombre "ADSO" coincide, pero uno es el área y el otro un programa dentro de
ella. `programas` además carga código, nivel, modalidad, línea — que `areas` no
tiene. Fusionar rompería el agrupador que usan `ambientes`, instructores y el
alcance de coordinación.

### Ambiente_bloqueos → mantener tabla, exponer estado calculado

Un bloqueo es un **evento con ventana** (`fecha_inicio`, `fecha_fin`, `motivo`),
no un estado. Un booleano `bloqueado` en `ambientes` no puede decir "bloqueado
del 1 al 15 por mantenimiento", no guarda historial y no se libera solo (RN-09).
El "disponible/no disponible" que buscas **ya existe como valor calculado**
(`hasBloqueoVigente`). Recomendación: exponer en la API de ambientes un campo
derivado `disponible` para que la UI lo vea como estado, sin denormalizar.

---

## Hallazgos accionables (por prioridad)

### 1. 🟡 Consolidar los tres catálogos `tipos_novedad_*` (redundancia clara)

**Qué:** `tipos_novedad_instructor`, `tipos_novedad_ambiente` y
`tipos_novedad_ficha` tienen estructura idéntica (`id, nombre, descripcion,
activo`). Es el caso más claro de redundancia estructural.

**Propuesta:** una sola tabla `tipos_novedad` con columna
`contexto ENUM('instructor','ambiente','ficha')`.

**Beneficio:** un solo catálogo que mantener; menos tablas.
**Costo:** medio. Hay que migrar datos, ajustar las FK de `instructor_novedades`
y `ficha_novedades`, y tocar el `catalogo.controller` (endpoints tipos-novedad-*).
**Recomendación:** hacerlo **antes de cargar datos reales** — después cuesta más.

### 2. ⚠️ "Líder de grupo" está en dos sitios (dispersión real)

**Qué:** `fichas.lider_id` (FK a usuarios) y `asignacion.es_lider_ficha`
(boolean) expresan lo mismo: quién lidera el grupo. Uno permite un líder que no
sea instructor asignado; el otro marca a un instructor ya asignado.

**Riesgo:** pueden contradecirse (lider_id apunta a X, es_lider_ficha=TRUE en Y).
**Propuesta:** definir **una sola fuente de verdad**. Si el líder siempre es un
instructor asignado, basta `es_lider_ficha` y sobra `lider_id`. Si puede ser
alguien externo, dejar `lider_id` y quitar `es_lider_ficha`.
**Costo:** bajo-medio. Decisión de negocio + ajuste en fichas/asignacion.
**Nota:** `lider_programa` (referente de programa) es un concepto DISTINTO —
esa no entra aquí.

### 3. ⚠️ `fichas` tiene tres campos de estado que se solapan

**Qué:** `estado VARCHAR ('Activa'/'Finalizada')`, `activo BOOLEAN` y
`fecha_fin_ficha`. "Finalizada" ≈ `activo=FALSE` ≈ `fecha_fin_ficha` no nula.
Tres formas de decir casi lo mismo.

**Riesgo:** quedar en estados incoherentes (activa pero con fecha_fin, o
finalizada con activo=TRUE).
**Propuesta:** `activo` es soft-delete universal (se queda). El ciclo de vida del
grupo (activa/finalizada) puede vivir solo en `etapa` + `fecha_fin_ficha`, o en
un único `estado` bien definido — pero no las tres cosas sueltas.
**Costo:** bajo. Limpieza de reglas en `ficha.service`.

### 4. 🔵 `rap_ficha_seguimiento` repite una llave que ya existe

**Qué:** guarda `(asignacion_competencia_id, rap_id)`, que ahora también es la
llave de `asignacion_rap`. Es la misma relación instructor-RAP, duplicada.

**Propuesta:** que `rap_ficha_seguimiento` referencie `asignacion_rap.id` en vez
de repetir el par. Así el seguimiento cuelga de la asignación real del RAP.
**Costo:** bajo-medio. Ajuste de FK + `rap-seguimiento.service`. Conviene
resolverlo junto con P30.

### 5. ℹ️ Menores (bajo impacto)

- `roles.nivel` tiene comentario obsoleto ("3=Lider"); ya no existe ese rol.
- `competencias.codigo` y `raps.codigo` no son UNIQUE — si los códigos SENA son
  únicos, conviene la restricción para evitar duplicados al cargar datos reales.
- `alertas` y `notificaciones` se parecen (ambas son "mensajes a alguien"), pero
  `alertas` es específica de carga horaria con `total_horas`/`semana`. Mantener
  separadas; solo se anota.

---

## Recomendación final

Antes de cargar los datos reales del CDMC, vale la pena resolver lo que es más
barato ahora que después:

| Prioridad | Acción | Momento ideal |
|---|---|---|
| 🔴 Alta | #1 Consolidar `tipos_novedad_*` | Antes de datos reales |
| 🔴 Alta | #2 Definir fuente única de "líder de grupo" | Antes de datos reales |
| 🟡 Media | #3 Simplificar estados de `fichas` | Antes de datos reales |
| 🟡 Media | #4 `rap_ficha_seguimiento` → FK a `asignacion_rap` | Junto con P30 |
| 🟢 Baja | #5 UNIQUE en códigos, comentarios, etc. | Cuando se toque cada tabla |
| — | Áreas/Programas y Ambiente_bloqueos | Sin cambios (correctos) |

Lo demás (22 tablas) está bien normalizado. Si quieres, tomo #1, #2 y #3 como un
bloque de refactor de schema + backend y lo implemento con su migración, antes de
pedir los datos al instructor.
