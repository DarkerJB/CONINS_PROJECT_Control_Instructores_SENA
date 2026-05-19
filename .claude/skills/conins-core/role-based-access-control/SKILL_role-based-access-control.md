# role-based-access-control — CONINS v4

## Proposito

Controlar el acceso a recursos en CONINS considerando que los roles son **acumulativos, contextuales y organizados en dos lineas de coordinacion** (medular y transversal).

---

## Modelo de roles

### Roles globales (tabla `usuario_roles` — 5 entradas exactas, snake_case en BD)
```ts
// constants/roles.ts
export const ROLES = {
  SUBDIRECTOR:              'subdirector',
  COORDINADOR_MEDULAR:      'coordinador_medular',    // Paul Tamayo — calzado, marroquineria, curticion
  COORDINADOR_TRANSVERSAL:  'coordinador_transversal', // Juan Pablo Hoyos — ADSO, bilinguismo, etc.
  LIDER_PROGRAMA:           'lider_programa',
  INSTRUCTOR:               'instructor',
} as const;

export type RoleKey = typeof ROLES[keyof typeof ROLES];

// Helpers
export const ROLES_ADMIN = [ROLES.SUBDIRECTOR, ROLES.COORDINADOR_MEDULAR, ROLES.COORDINADOR_TRANSVERSAL];
export const ROLES_COORDINADOR = [ROLES.COORDINADOR_MEDULAR, ROLES.COORDINADOR_TRANSVERSAL];
```

> `lider_ficha` NO es un rol global. Es `es_lider_ficha BOOLEAN DEFAULT FALSE` en `asignacion`.
> No otorga permisos adicionales en el sistema. No aparece en `ROLES`.

### Roles contextuales (no en el token — consultar en BD)
```sql
lider_programa      (instructor_id, programa_id)     -- lidera este programa
asignacion          (instructor_id, ficha_id, es_lider_ficha)  -- asignado a esta ficha
asignacion_competencia (asignacion_id, competencia_id) -- dicta esta competencia
```

---

## Arquitectura de autorizacion — dos capas

### Capa 1 — Middleware `requireRole` (roles globales)
```ts
// Usar SOLO para endpoints que requieren un nivel global sin importar el contexto
router.get('/instructores',
  verifyToken,
  requireRole(ROLES_ADMIN),
  instructorController.listarTodos
);
```

### Capa 2 — `permisoService` (acceso contextual)
```ts
// services/permiso.service.ts

async function puedeVerFicha(usuarioId: number, fichaId: number) {
  const roles = await getRolesGlobales(usuarioId);

  // Administradores: acceso total
  if (roles.includes(ROLES.SUBDIRECTOR)) {
    return { puede: true, nivel: 'total' };
  }

  // Coordinadores: solo su linea
  if (roles.includes(ROLES.COORDINADOR_MEDULAR)) {
    const esDeLinea = await esProgramaLinea(fichaId, 'medular');
    return { puede: esDeLinea, nivel: 'linea' };
  }
  if (roles.includes(ROLES.COORDINADOR_TRANSVERSAL)) {
    const esDeLinea = await esProgramaLinea(fichaId, 'transversal');
    return { puede: esDeLinea, nivel: 'linea' };
  }

  // Lider de programa: solo su programa
  const esLiderProg = await liderProgramaModel.existsByUsuarioAndFicha(usuarioId, fichaId);
  if (esLiderProg) return { puede: true, nivel: 'programa' };

  // Instructor: solo sus competencias
  const esInstructor = await asignacionModel.esInstructor(usuarioId, fichaId);
  if (esInstructor) return { puede: true, nivel: 'instructor' };

  return { puede: false };
}

async function puedeGestionarFicha(usuarioId: number, fichaId: number) {
  // Gestionar = modificar asignaciones, registrar horarios, etc.
  const acceso = await puedeVerFicha(usuarioId, fichaId);
  return acceso.puede && acceso.nivel !== 'instructor';
}

async function puedeAsignarProvisional(usuarioId: number) {
  // Solo coordinadores o subdirector (RN-11)
  const roles = await getRolesGlobales(usuarioId);
  return roles.some(r => ROLES_ADMIN.includes(r));
}

// Verificar linea via programas.tipo_linea (schema v4)
async function esProgramaLinea(fichaId: number, linea: 'medular' | 'transversal'): Promise<boolean> {
  const result = await db.query(
    `SELECT 1 FROM fichas f
     JOIN programas p ON p.id = f.programa_id
     WHERE f.id = ? AND p.tipo_linea = ? AND f.activo = TRUE`,
    [fichaId, linea]
  );
  return result.length > 0;
}
```

---

## Matriz de acceso por recurso

| Recurso | subdirector | coordinador_* | lider_programa | instructor |
|---|:---:|:---:|:---:|:---:|
| Ver todo el CDMC | Solo su linea | — | — |
| Gestionar instructores | su linea | — | — |
| Ver ficha | su linea | su programa | sus competencias |
| Gestionar ficha | su linea | su programa | — |
| Crear asignacion | — | — |
| Asignacion provisional | (con autorizacion) | — | — |
| Ver carga horaria propia | su linea | su programa | |
| Ver carga de otro instructor | su linea | su programa | — |
| Dashboard directivo | — | — |

---

## Patron completo de endpoint protegido

```ts
// Endpoint sin contexto (requiere rol global)
router.delete('/instructores/:id',
  verifyToken,
  requireRole(ROLES_ADMIN),
  instructorController.deshabilitar   // soft delete — activo = FALSE
);

// Endpoint con contexto (acceso depende del recurso)
router.get('/fichas/:ficha_id',
  verifyToken,
  fichaController.getDetalle   // permisoService dentro del controller
);

// controllers/ficha.controller.ts
async function getDetalle(req: Request, res: Response) {
  const acceso = await permisoService.puedeVerFicha(req.user.id, req.params.ficha_id);
  if (!acceso.puede) return res.status(403).json({ error: 'Sin acceso' });
  const datos = await fichaService.getDetalle(req.params.ficha_id, acceso.nivel);
  res.json(datos);
}
```

---

## Errores criticos

```ts
// ❌ Un solo "coordinador_academico" — hay dos con lineas distintas
requireRole(['coordinador_academico'])

// ❌ requireRole plano para recursos contextuales
requireRole(['lider_ficha'])  // lider_ficha no es un rol global

// ❌ Confundir tipo_linea del programa con tipo_area del instructor
// tipo_linea: 'medular' | 'transversal' → clasifica el programa en el CDMC
// tipo_area:  'tecnica' | 'transversal' → clasifica las competencias del instructor
// Son dos ejes independientes — no mezclar en validaciones

// ❌ Permisos en el token
{ "fichas_permitidas": [1, 3, 7] }

// ❌ DELETE fisico en lugar de activo = FALSE
await db.query('DELETE FROM instructores WHERE id = ?');
```
