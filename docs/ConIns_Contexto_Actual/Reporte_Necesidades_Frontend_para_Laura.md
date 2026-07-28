# Necesidades de Frontend — feedback del líder técnico

**Para:** Laura Sofía Posada
**De:** Jair
**Fecha:** 24 de julio de 2026
**Objetivo:** que valides viabilidad en frontend, implementes lo que puedas y nos
des tus conclusiones. Marco con estado del backend para que sepas qué ya tiene
endpoint y qué depende de decisiones.

---

## 1. Reestructurar el panel lateral — Asignaciones como eje (PRIORIDAD ALTA)

**Lo que pide el líder:** "Asignaciones es el cerebro del sistema. En el sidebar,
las asignaciones aparecen al mismo nivel que los módulos que se asignan; los
módulos asignables deben estar **contenidos dentro** de Asignaciones."

**Qué significa en la UI:** hoy Instructores, Grupos, Programas, Competencias,
Ambientes y Horarios están al mismo nivel que Asignaciones. La idea es
jerarquizar: Asignaciones como sección padre, y debajo (o agrupados) los módulos
que participan en una asignación.

**Propuesta a validar (tú decides la forma final):**

```
ASIGNACIONES  (módulo eje)
  ├── Instructores
  ├── Grupos
  ├── Programas
  ├── Competencias y RAPs
  ├── Ambientes
  └── Horarios
ALERTAS Y NOTIFICACIONES
CONSULTA Y REPORTES
SEGURIDAD Y TRAZABILIDAD
SEGUIMIENTO DE RAPs
```

**Backend:** no requiere cambios — es reorganización de navegación y layout.
**Lo que necesito de ti:** ¿lo ves como menú anidado (acordeón), como sub-tabs
dentro de una vista de Asignaciones, o como agrupación visual? Tu criterio de UX.

---

## 2. Conectar los selectores de RAP (PRIORIDAD ALTA — ya tienes endpoint)

Esto ya te lo dejé listo en backend; es lo que te bloqueaba antes:

- **En asignaciones (RF-42):** multi-select de RAPs. Opciones con
  `GET /api/competencias/:id/raps`; guardar con
  `PUT /api/asignaciones/:id/competencia/:competenciaId/raps` (body `{rap_ids}`).
  El backend valida RN-06 (máx. 1 instructor por RAP por grupo) y devuelve 409 si
  se viola — solo muestras el error.
- **En horarios (RF-34):** selector de RAP en `CrearHorarioModal` /
  `EditarHorarioModal`. El horario acepta `rap_id`; el backend valida RN-27.
  Para poblar el selector usa
  `GET /api/asignaciones/:asignacionId/competencia/:competenciaId/raps`.

**Requiere:** correr la migración de BD que te pasé
(`backend/scripts/migracion_21-07_rap_directo.sql`).

---

## 3. Sedes del CDMC (PRIORIDAD MEDIA — depende de decisión de BD)

El líder pide agregar **sedes** (el CDMC tiene sedes externas que dependen de él).
Si lo aprobamos, en backend crearíamos la tabla `sedes` y un `sede_id` en
ambientes y grupos.

**Impacto en frontend (para que lo tengas presente, aún no implementar):**
- Selector de **sede** en los formularios de Ambientes y de Grupos.
- Posible filtro por sede en las vistas de consulta.

**Lo que necesito de ti:** ¿lo ves como un simple dropdown más, o implica repensar
alguna vista? Con tu respuesta definimos el alcance antes de tocar el schema.

---

## 4. Cursos complementarios (PRIORIDAD BAJA — casi listo)

La modalidad ya existe en backend (`tipo_formacion = 'complementaria'`). Solo
falta que el **formulario de Programas** ofrezca esa opción en el selector de tipo
de formación (junto a titulada y operario). Cambio mínimo.

---

## 5. Carga de datos vía Excel (PRIORIDAD MEDIA — a definir)

El líder quiere cargar datos masivamente vía Excel. Del lado backend haríamos un
importador (subir .xlsx → validar → insertar).

**Impacto en frontend:** una vista de **carga de archivo** (subir Excel, mostrar
resultado de la importación: filas ok / errores).

**Lo que necesito de ti:** ¿tienes preferencia de librería o patrón para el
uploader? ¿Lo imaginas por módulo (subir instructores, subir grupos…) o una sola
pantalla de importación?

---

## 6. Notificaciones de asignación (PRIORIDAD MEDIA)

El líder pide notificar por correo a quien se le hace una asignación. En backend
ya existe el módulo de notificaciones (campanita) y el envío por correo (falta
activar SMTP). Del lado frontend:

- Asegurar que la **campanita** muestre las notificaciones de asignación (ya
  existe el endpoint `GET /api/notificaciones/mis`).
- No requiere pantalla nueva; validar que el badge y el listado funcionen con
  este tipo de notificación.

---

## 7. Vista de instructores históricos (PRIORIDAD BAJA)

El líder quiere conservar a los instructores que ya no están en el CDMC. En
backend el soft-delete ya los conserva (`activo=FALSE`). En frontend bastaría un
**filtro o pestaña "Inactivos/Históricos"** en la vista de Instructores para
consultarlos, sin borrarlos.

---

## Resumen — qué te pido validar/implementar

| # | Necesidad | Prioridad | ¿Backend listo? |
|---|---|---|---|
| 1 | Sidebar: Asignaciones como eje, módulos anidados | 🔴 Alta | No aplica (solo frontend) |
| 2 | Selectores de RAP en asignaciones y horarios | 🔴 Alta | ✅ Sí (correr migración) |
| 3 | Selector de sede (ambientes/grupos) | 🟡 Media | Pendiente decisión BD |
| 4 | Cursos complementarios en form de Programas | 🟢 Baja | ✅ Sí |
| 5 | Pantalla de carga Excel | 🟡 Media | Pendiente definir |
| 6 | Notificaciones de asignación en campanita | 🟡 Media | ✅ Sí (falta SMTP) |
| 7 | Filtro de instructores históricos/inactivos | 🟢 Baja | ✅ Sí |

**Lo que necesitamos de ti:** valida cuáles son viables desde frontend, implementa
las que estén listas (sobre todo #1 y #2), y devuélvenos tus conclusiones y dudas
sobre #3 y #5 para cerrar el alcance antes de tocar el schema.

Gracias,
Jair
