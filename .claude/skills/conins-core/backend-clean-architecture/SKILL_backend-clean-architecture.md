# backend-clean-architecture — CONINS v4

## Proposito

Definir la arquitectura limpia del backend de CONINS, separando responsabilidades y acomodando la complejidad real: roles contextuales, asignaciones jerarquicas, validaciones de negocio por capas y flexibilidad para escalar.

---

## Flujo obligatorio de una request

```
Request
  → verifyToken           (estas autenticado?)
  → requireRole([...])    (tienes rol global para esto? — solo si aplica)
  → Controller            (maneja HTTP — delgado)
  → permisoService        (puedes acceder a ESTE recurso especifico?)
  → domainService         (logica de negocio)
  → Model                 (query SQL pura)
  → DB
  → Response
```

---

## Estructura de archivos (TypeScript + ESM6 + MVC)

```
backend/
├── config/
│   └── db.ts                 # Conexion MySQL
├── controllers/              # Solo HTTP — sin logica de negocio
│   ├── auth.controller.ts
│   ├── asignacion.controller.ts
│   ├── horario.controller.ts
│   ├── instructor.controller.ts
│   ├── ficha.controller.ts
│   ├── ambiente.controller.ts
│   ├── alerta.controller.ts
│   ├── notificacion.controller.ts
│   └── catalogo.controller.ts
├── services/                 # Logica de negocio
│   ├── auth.service.ts
│   ├── asignacion.service.ts
│   ├── horario.service.ts
│   ├── permiso.service.ts
│   ├── alerta.service.ts
│   ├── notificacion.service.ts    # Nodemailer + notificaciones internas
│   ├── instructor.service.ts
│   └── catalogo.service.ts
├── models/                   # Queries SQL puras
│   ├── usuario.model.ts
│   ├── rol.model.ts
│   ├── asignacion.model.ts
│   ├── asignacion-competencia.model.ts
│   ├── horario.model.ts
│   ├── instructor.model.ts
│   ├── competencia.model.ts
│   ├── rap.model.ts
│   ├── ficha.model.ts
│   ├── programa.model.ts
│   ├── ambiente.model.ts
│   ├── jornada.model.ts
│   ├── alerta.model.ts
│   └── notificacion.model.ts
├── middleware/
│   ├── auth.middleware.ts         # verifyToken + requireRole
│   └── error.handler.ts
├── routes/
│   ├── auth.routes.ts
│   ├── asignacion.routes.ts
│   ├── horario.routes.ts
│   ├── instructor.routes.ts
│   ├── ficha.routes.ts
│   ├── ambiente.routes.ts
│   ├── alerta.routes.ts
│   ├── notificacion.routes.ts
│   └── catalogo.routes.ts
├── utils/
│   ├── errors.ts            # AppError, NotFoundError, ConflictError, etc.
│   ├── response.ts          # ApiResponse.success / .created / .error
│   └── async-handler.ts
├── constants/
│   ├── roles.ts             # ROLES.SUBDIRECTOR, etc.
│   ├── horario.ts           # LIMITES_HORAS por tipo_contrato
│   ├── alertas.ts           # TIPOS_ALERTA
│   └── etiquetas.ts         # ETIQUETAS.FICHA = 'ficha' (configurable)
├── database.sql             # Schema v4 — 20 tablas
├── seed_data.sql
└── server.ts                # Express 5 entry point
```

---

## Responsabilidades por capa

### Routes — solo endpoints y middlewares
```ts
// routes/ficha.routes.ts
router.get('/:ficha_id',
  verifyToken,
  fichaController.getDetalle    // permisoService va dentro del controller
);

router.post('/',
  verifyToken,
  requireRole([ROLES.SUBDIRECTOR, ROLES.COORDINADOR_MEDULAR, ROLES.COORDINADOR_TRANSVERSAL]),
  asignacionController.crear
);
```

### Controllers — HTTP puro, sin logica
```ts
// controllers/ficha.controller.ts
async function getDetalle(req: Request, res: Response) {
  try {
    const { ficha_id } = req.params;
    const acceso = await permisoService.puedeVerFicha(req.user.id, ficha_id);
    if (!acceso.puede) return res.status(403).json({ error: 'Sin acceso' });

    const datos = await fichaService.getDetalle(ficha_id, acceso.nivel);
    res.json(datos);
  } catch (err) {
    res.status(err.status || 500).json({ error: err.message });
  }
}
```

### Services — toda la logica de negocio
```ts
// services/asignacion.service.ts
async function crear(usuarioId: number, payload: CrearAsignacionDTO) {
  // 1. Validar instructor y ficha activos
  // 2. Si es_provisional: registrar autorizado_por_id = usuarioId
  // 3. Validar area instructor vs programa (saltar si es_provisional)
  // 4. Insertar asignacion
  // 5. Para cada competencia: validar en instructor_competencias_habilitadas → insertar asignacion_competencia
  // 6. Validar unicidad de RAP por ficha (RN-06)
  // 7. RAPs heredados automaticamente — no insertar nada mas
  // 8. Recalcular carga horaria si aplica
  // 9. Generar notificaciones (RF-38/39/40)
}
```

### Models — queries SQL puras
```ts
// models/asignacion.model.ts
async function findByFicha(fichaId: number) {
  return db.query(
    `SELECT a.*, u.nombre FROM asignacion a
     JOIN instructores i ON i.id = a.instructor_id
     JOIN usuarios u ON u.id = i.usuario_id
     WHERE a.ficha_id = ? AND a.activo = TRUE`,
    [fichaId]
  );
}
```

---

## Services del dominio CONINS

| Service | Responsabilidad principal |
|---|---|
| `asignacion.service` | Crear/modificar asignaciones instructor→ficha→competencia. Validar area, contrato, provisional, unicidad RAP (RN-06) |
| `horario.service` | Registrar bloques, calcular carga semanal, validar conflictos, disparar alertas |
| `permiso.service` | Resolver acceso contextual por ficha/programa/linea. Fuente de verdad de permisos |
| `alerta.service` | Crear, actualizar y limpiar alertas. AMBIENTE_OCUPADO, HORAS_*, JORNADA_RESTRINGIDA |
| `notificacion.service` | Notificaciones internas + Nodemailer para instructores (RF-38) |
| `instructor.service` | Perfil, tipo de contrato, tipo de area, competencias habilitadas, novedades |
| `catalogo.service` | Ambientes, jornadas, programas, competencias — lectura de catalogos |

---

## Reglas hard

- Logica de negocio en controllers
- Queries SQL fuera de models
- Permisos contextuales en middleware (van en `permisoService`)
- Logica de frontend definiendo roles o calculando horas
- Constantes de negocio hardcodeadas — siempre en `constants/`
- DELETE fisico — siempre `activo = FALSE`
- Etiquetas UI hardcodeadas ("ficha") — usar `ETIQUETAS.FICHA`
- Password NULL en BD significa usuario sin activar (onboarding paso 1)

---

## Ejemplo completo correcto

```ts
// routes/asignacion.routes.ts
router.post('/',
  verifyToken,
  requireRole([ROLES.SUBDIRECTOR, ROLES.COORDINADOR_MEDULAR, ROLES.COORDINADOR_TRANSVERSAL]),
  asignacionController.crear
);

// controllers/asignacion.controller.ts
async function crear(req: Request, res: Response) {
  try {
    const resultado = await asignacionService.crear(req.user.id, req.body);
    res.status(201).json(resultado);
  } catch (err) {
    res.status(err.status || 500).json({ error: err.message });
  }
}

// services/asignacion.service.ts
async function crear(usuarioId: number, payload: CrearAsignacionDTO) {
  const { instructor_id, ficha_id, competencia_ids, es_lider_ficha, es_provisional } = payload;
  // ... validaciones → inserts → recalcular carga → notificaciones
}

// models/asignacion.model.ts
async function insert(data: AsignacionInsert) {
  return db.query('INSERT INTO asignacion SET ?', [data]);
}
```
