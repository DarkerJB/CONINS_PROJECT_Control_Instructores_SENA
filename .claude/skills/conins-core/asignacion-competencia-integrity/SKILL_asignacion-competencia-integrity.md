# asignacion-competencia-integrity — CONINS v4

## Proposito

Garantizar la integridad de las asignaciones academicas respetando la jerarquia real del negocio:

**Instructor → Ficha (con flag es_lider_ficha) → Competencia → RAPs heredados → Ambiente**

Los RAPs NO se asignan individualmente. Se heredan al asignar una competencia.

---

## Jerarquia de asignacion

```
asignacion             (instructor_id, ficha_id, es_lider_ficha, es_provisional)
  └── asignacion_competencia  (asignacion_id, competencia_id, ambiente_excepcion_id)
        └── competencia (codigo, nombre, programa_id)
              └── raps  ← heredados por competencia_id, nunca asignados uno a uno
```

---

## Reglas de integridad

### R1 — Unicidad
```sql
UNIQUE(instructor_id, ficha_id)        -- tabla asignacion
UNIQUE(asignacion_id, competencia_id)  -- tabla asignacion_competencia
```

### R2 — Competencia contratada (validar antes de INSERT)
```ts
// services/asignacion.service.ts
const habilitada = await db.query(
  `SELECT 1 FROM instructor_competencias_habilitadas
   WHERE instructor_id = ? AND competencia_id = ?`,
  [instructor_id, competencia_id]
);
if (!habilitada.length) throw new BusinessError('Competencia no contratada por este instructor', 422);
```

### R3 — Area del instructor vs programa (validar antes de INSERT)
```ts
const instructor = await instructorModel.findById(instructor_id);
const programa   = await programaModel.findByFicha(ficha_id);

if (instructor.tipo_area !== programa.tipo_area && !es_provisional) {
  throw new BusinessError('El area del instructor no coincide con el area del programa', 422);
}
// Si es_provisional = TRUE → esta validacion se omite (autorizacion ya registrada)
```

### R4 — Herencia de RAPs
```ts
// ✅ Correcto — RAPs se consultan por competencia, no se insertan
const raps = await rapModel.findByCompetencia(competencia_id);

// ❌ Incorrecto — no existe asignacion_rap como tabla de trabajo
await db.query('INSERT INTO asignacion_rap ...');
```

### R5 — Ambiente efectivo
```ts
// Leer siempre asi:
const ambiente_id = asignacion_competencia.ambiente_excepcion_id
  ?? ficha.ambiente_id;
```

### R6 — Soft delete
```sql
-- Nunca DELETE fisico
UPDATE asignacion SET activo = FALSE WHERE id = ?;
UPDATE asignacion_competencia SET activo = FALSE WHERE id = ?;
-- Todas las queries de listado: WHERE activo = TRUE
```

### R7 — Unicidad de RAP por ficha (validacion en service — RN-06)
```ts
// RN-06: Un RAP no puede tener dos instructores distintos en la misma ficha.
// NO es constraint UNIQUE de BD — la tabla asignacion_rap fue eliminada en v4.
// La validacion se hace en el service al asignar una competencia:

async function validarSinRapSolapado(ficha_id: number, nuevaCompetenciaId: number): Promise<void> {
  // 1. Obtener RAPs de la nueva competencia
  const rapsNuevos = await rapModel.findByCompetencia(nuevaCompetenciaId);
  const rapIds = rapsNuevos.map(r => r.id);

  // 2. Verificar si otro instructor en la misma ficha ya tiene competencia con esos RAPs
  const solapamiento = await db.query(
    `SELECT ac.id
     FROM asignacion_competencia ac
     JOIN asignacion a ON a.id = ac.asignacion_id
     WHERE a.ficha_id = ?
       AND ac.competencia_id != ?
       AND ac.activo = TRUE
       AND a.activo = TRUE
       AND ac.competencia_id IN (
         SELECT r.competencia_id FROM raps r WHERE r.id IN (?)
       )`,
    [ficha_id, nuevaCompetenciaId, rapIds]
  );

  if (solapamiento.length > 0) {
    throw new ConflictError('Un RAP de esta competencia ya esta asignado a otro instructor en la misma ficha', 409);
  }
}
```

---

## Flujo de creacion de asignacion

```
1. Verificar instructor activo (activo = TRUE)
2. Verificar ficha activa
3. Verificar UNIQUE(instructor_id, ficha_id) — upsert si ya existe
4. Validar area instructor vs programa (saltar si es_provisional)
5. Insertar/actualizar asignacion con es_lider_ficha y es_provisional
6. Para cada competencia_id:
   a. Verificar competencia en instructor_competencias_habilitadas
   b. Verificar UNIQUE(asignacion_id, competencia_id)
   c. Validar unicidad de RAP por ficha (R7 — RN-06)
   d. Insertar asignacion_competencia
   e. RAPs se heredan — no hacer nada mas
7. Si hay ambiente_excepcion_id: verificar que el ambiente exista y este activo
```

---

## Cambio de instructor en competencia activa

```ts
// En asignacion_competencia:
await db.query(`
  UPDATE asignacion_competencia SET
    instructor_anterior_id = (SELECT instructor_id FROM asignacion WHERE id = asignacion_id),
    fecha_cambio = CURDATE(),
    observacion = ?
  WHERE id = ?
`, [motivo, ac_id]);

// Luego crear nueva asignacion para el nuevo instructor
// Los RAPs ya evaluados permanen en Sofia Plus — CONINS no los modifica
```

---

## Dos ejes que NO deben mezclarse

| Eje | Campo | Valores | Aplica a |
|---|---|---|---|
| Clasificacion administrativa | `programas.tipo_linea` | `medular` / `transversal` | Programa del centro |
| Clasificacion pedagogica | `instructores.tipo_area` | `tecnica` / `transversal` | Competencias del instructor |

Un instructor de ADSO (programa transversal del CDMC) que dicta algoritmos tiene `tipo_area = 'tecnica'`.
Un instructor de bilinguismo tiene `tipo_area = 'transversal'`. Ambos son del programa transversal.

---

## Errores criticos a evitar

```ts
// ❌ UNIQUE(ficha_id, rap_id) como constraint de BD — la tabla asignacion_rap no existe
// ❌ Asignar RAPs uno a uno
// ❌ Tabla asignacion_rap como tabla central
// ❌ Ignorar instructor_competencias_habilitadas antes de asignar
// ❌ No registrar es_provisional cuando aplica
// ❌ DELETE fisico en lugar de activo = FALSE
// ❌ No validar solapamiento de RAPs al asignar competencia (R7/RN-06)
```
