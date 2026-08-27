# Reconciliación frontend — `alertas.tsx` (sesión 26/08)

**De:** Jair (backend) · **Para:** Laura (frontend)
**Archivo único a tocar:** `src/pages/alertas.tsx`
**Objetivo:** conservar tu trabajo nuevo (badge/icono/filtro `RAP_COMPARTIDO`, `leida`, `marcarTodas`) y reaplicar encima dos arreglos cosméticos que tu versión del 26/08 revirtió.

> Para tu Cowork: este .md es la instrucción completa. Aplica los dos parches de abajo sobre tu `src/pages/alertas.tsx` actual, corre `tsc --noEmit` y verifica visualmente una alerta de tipo `RAP_COMPARTIDO`. No toques ningún otro archivo. El backend ya está alineado, no requiere cambios.

---

## Contexto (por qué)

El backend, para las alertas **estructurales** (tipo `RAP_COMPARTIDO`), envía:

- `semana = null`
- `total_horas = null`
- `instructor_id` = uno de los instructores implicados, pero los DOS nombres ya van dentro de `mensaje`.

Tu versión del 26/08 renderiza `instructor_nombre`, `Semana del {semana}` y `{total_horas}h` sin condicional. Con esos campos en `null` el resultado en pantalla es:

- Nombre del instructor abajo, que parece "la firma de quien avisó" (confunde a coordinación).
- Texto fantasma `Semana del 31 dic` y `NaNh` en las alertas estructurales.

Los dos parches lo corrigen: se ocultan esos campos cuando no aplican, y los nombres siguen visibles dentro del `mensaje`.

---

## Parche 1 — tipo `Alerta` (campos nullable)

El backend puede mandar `null` en `semana` y `total_horas`. Ajusta el tipo:

```ts
// ANTES
  semana: string
  total_horas: number

// DESPUÉS
  semana: string | null
  total_horas: number | null
```

(Deja `leida: boolean`, `atendida: boolean`, `ficha_id`, `rap_id` como los tienes — están bien y coinciden con el backend.)

---

## Parche 2 — línea meta de la tarjeta (render condicional)

Reemplaza el bloque de la línea meta (en tu archivo, el `<div className="flex items-center gap-4 text-xs text-gray-400 mt-2"> ... </div>`, aprox. líneas 289–297):

```tsx
<div className="flex items-center gap-4 text-xs text-gray-400 mt-2">
  {alerta.tipo !== "RAP_COMPARTIDO" && (
    <><span>{alerta.instructor_nombre}</span><span>·</span></>
  )}
  {alerta.semana && (
    <><span>Semana del {new Date(alerta.semana).toLocaleDateString("es-CO", { day: "numeric", month: "short" })}</span><span>·</span></>
  )}
  {alerta.total_horas != null && (
    <><span>{alerta.total_horas}h</span><span>·</span></>
  )}
  <span>{formatTimeAgo(alerta.created_at)}</span>
</div>
```

Reglas que aplica:
- `RAP_COMPARTIDO` no muestra `instructor_nombre` en la meta (los dos nombres ya están en `mensaje`).
- `semana` solo se muestra si viene con valor (no `null`).
- `total_horas` solo se muestra si es distinto de `null` (usa `!= null` para permitir `0`).
- El "hace X" (`formatTimeAgo`) siempre se muestra al final; los `·` cuelgan de cada bloque, así no quedan separadores sueltos.

---

## Verificación (para tu Cowork)

1. `npm run build` o `npx tsc --noEmit` → sin errores.
2. Con la BD cargada, entra a **Alertas** como Coordinadora o Asistente y busca una alerta `RAP compartido`:
   - No debe aparecer un nombre de instructor suelto abajo (solo "hace X").
   - No debe aparecer `Semana del 31 dic` ni `NaNh`.
   - El mensaje sí debe nombrar el resultado de aprendizaje, el grupo y los dos instructores.
3. Una alerta normal (p. ej. `HORAS_EXCEDIDAS`) sí conserva instructor, semana y horas.

---

## Nota de estado — backend (informativo, sin acción para ti)

Ya verificado y alineado con tu 26/08:
- Columna `leida` en `alertas` + `PATCH /api/alertas/:id/leida` + `PATCH /api/alertas/marcar-todas`.
- `GET /api/alertas?solo_no_atendidas=true` soportado.
- `ficha_id` y `rap_id` en el `SELECT` de listado.
- `M1` (consultas) y `M2` (bitácora) con `requireRole([...ROLES_ADMIN])` — tu ocultamiento de menú + bloqueo de API = doble capa.

Pendientes menores de mi lado (no te afectan): scoping de `marcar-todas` por rol y retiro de la ruta muerta `/auth/register`.

---

## Nota — "Horas/sem" en el listado de Instructores (informativo, sin acción para ti)

Reportado que la columna **Horas/sem** salía en 0h para todos. Verificado: **no es bug de frontend.** Tu `instructores.tsx` lee `inst.horas_semana` correctamente y el backend lo devuelve bien.

Causa: la BD en ejecución tenía un seed anterior a la carga de horarios, y el cálculo es por **regla de negocio = carga de la semana en curso** (lunes actual). Con la BD recargada (`database.sql` + `seed_data.sql`), en la semana actual (08-24) los instructores con horario muestran su carga (6h–36h); los que no tienen clase esa semana muestran 0h, que es correcto. Después de una semana sin datos cargados (p. ej. tras 08-31, hasta la planeación de septiembre) es normal ver 0h.

No requiere cambios de frontend.
