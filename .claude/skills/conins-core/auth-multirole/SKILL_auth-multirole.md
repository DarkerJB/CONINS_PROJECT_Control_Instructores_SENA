# auth-multirole — CONINS v4

## Proposito

Gestionar autenticacion y autorizacion en CONINS donde los roles son **acumulativos, contextuales y no excluyentes**. El mismo usuario puede tener multiples roles con alcances distintos segun el recurso que solicita.

---

## Roles del sistema

| Rol tecnico | Cargo real CDMC | Alcance |
|---|---|---|
| `subdirector` | Subdirector (e) Dyron Ramirez | Todo el CDMC |
| `coordinador_medular` | Coordinador Medular Paul Tamayo | Programas medulares (calzado, marroquineria, curticion) |
| `coordinador_transversal` | Coordinador Transversal Juan Pablo Hoyos | Programas transversales (ADSO, bilinguismo, etc.) |
| `lider_programa` | Lider de programa (ej. Carlos Alvarez en ADSO) | Su programa especifico |
| `instructor` | Instructor de competencias | Sus competencias asignadas |

> Un usuario puede tener todos estos roles simultaneamente.
> Juan Pablo Hoyos: `coordinador_transversal` + `lider_programa` (Bilinguismo) + posiblemente `instructor`
> Paul Tamayo: `coordinador_medular` + `instructor` (linea medular)
>
> `lider_ficha` NO es un rol — es `es_lider_ficha BOOLEAN DEFAULT FALSE` en `asignacion`. No otorga permisos en el sistema.

---

## Modelo de datos de roles

```sql
-- Roles globales del sistema (5 entradas exactas — nombres en snake_case)
roles (id, nombre, nivel)
  -- 1: 'subdirector'
  -- 2: 'coordinador_medular'
  -- 3: 'coordinador_transversal'
  -- 4: 'lider_programa'
  -- 5: 'instructor'

-- Asignacion de roles globales al usuario
usuario_roles (usuario_id, rol_id)

-- Rol contextual: liderazgo de programa
lider_programa (id, instructor_id, programa_id)

-- Rol contextual: asignacion a ficha con flag de liderazgo
asignacion (id, instructor_id, ficha_id, es_lider_ficha BOOLEAN, ...)

-- Rol contextual: competencias dictadas
asignacion_competencia (id, asignacion_id, competencia_id, ...)
```

---

## JWT — minimo y estable

```json
{
  "id": 12,
  "nombre": "Juan Pablo Hoyos Maya",
  "roles_globales": ["coordinador_transversal", "lider_programa"],
  "iat": 1234567890,
  "exp": 1234654290
}
```

> El JWT NO incluye fichas, programas ni competencias especificas.
> Esa informacion es dinamica y se consulta en BD por cada request.
> Incluirla en el token genera inconsistencias sin re-login.

---

## Flujo de autenticacion

### Onboarding de dos pasos

```
Paso 1 (admin):   Crea usuario con email + nombre + rol → password = NULL
Paso 2 (usuario): /auth tab "Crear contraseña" → ingresa email
                  ¿Existe en BD? Si → guarda password hash → puede login
                                 No → alerta amarilla → HTTP 403
Paso 3+:          Login normal con email + password
```

### Tabla usuarios (schema v4)

```sql
usuarios (
  id, nombre, email VARCHAR(100) UNIQUE,
  password VARCHAR(255) NULL DEFAULT NULL,  -- NULL = usuario sin activar
  activo BOOLEAN DEFAULT TRUE, created_at
)
```

### Login flow (TypeScript + ESM6)

```ts
// services/auth.service.ts
import { compare, hash } from 'bcrypt';
import { sign } from 'jsonwebtoken';

async function login(email: string, password: string) {
  const user = await userModel.findByEmail(email);
  if (!user) throw new NotFoundError('Correo no registrado', 403);
  if (user.password === null) throw new ForbiddenError('Cuenta sin activar. Cree su contraseña primero.', 403);
  if (!user.activo) throw new ForbiddenError('Cuenta deshabilitada', 403);

  const valid = await compare(password, user.password);
  if (!valid) throw new UnauthorizedError('Contraseña incorrecta', 401);

  const roles = await roleModel.findGlobalRoles(user.id);

  return sign(
    { id: user.id, nombre: user.nombre, roles_globales: roles },
    process.env.JWT_SECRET!,
    { expiresIn: '24h' }
  );
}

async function crearPassword(email: string, newPassword: string) {
  const user = await userModel.findByEmail(email);
  if (!user) throw new ForbiddenError('Correo no registrado en el sistema', 403);
  if (user.password !== null) throw new ConflictError('Este usuario ya tiene contraseña', 409);

  const hash = await bcrypt.hash(newPassword, 10);
  await userModel.updatePassword(user.id, hash);
}
```

### Frontend — Next.js 15

> Next.js 15 con Pages Router. Sin Zustand para auth.
> Usar sesiones via HTTP-only cookies o contexto React nativo de Next.js.
> Fetch nativo como HTTP client.

---

## Autorizacion — dos capas obligatorias

### Capa 1 — Middleware `requireRole` (roles globales)
Para endpoints que requieren un tipo de usuario sin importar el contexto:

```ts
// constants/roles.ts
export const ROLES = {
  SUBDIRECTOR:              'subdirector',
  COORDINADOR_MEDULAR:      'coordinador_medular',
  COORDINADOR_TRANSVERSAL:  'coordinador_transversal',
  LIDER_PROGRAMA:           'lider_programa',
  INSTRUCTOR:               'instructor',
} as const;

export type RoleKey = typeof ROLES[keyof typeof ROLES];

// middleware/requireRole.ts
export const requireRole = (rolesPermitidos: RoleKey[]) =>
  (req: Request, res: Response, next: NextFunction) => {
    const userRoles = req.user.roles_globales ?? [];
    const tiene = rolesPermitidos.some(r => userRoles.includes(r));
    if (!tiene) return res.status(403).json({ error: 'Acceso denegado' });
    next();
  };
```

### Capa 2 — `permisoService` (acceso contextual)
Para recursos especificos donde el acceso depende del contexto:

```ts
// services/permiso.service.ts

async function puedeVerFicha(usuarioId: number, fichaId: number) {
  const roles = await getRolesGlobales(usuarioId);
  if (esAdmin(roles)) return { puede: true, nivel: 'total' };

  // ¿Es coordinador de la linea de este programa?
  const esCoordLinea = await verificarCoordinadorLinea(usuarioId, fichaId);
  if (esCoordLinea) return { puede: true, nivel: 'linea' };

  // ¿Es lider del programa de esta ficha?
  const esLiderProg = await liderProgramaModel.existsByUsuarioAndFicha(usuarioId, fichaId);
  if (esLiderProg) return { puede: true, nivel: 'programa' };

  // ¿Es instructor de alguna competencia en esta ficha?
  const esInstructor = await asignacionModel.esInstructor(usuarioId, fichaId);
  if (esInstructor) return { puede: true, nivel: 'instructor' };

  return { puede: false };
}

function esAdmin(roles: string[]) {
  return roles.some(r => [
    ROLES.SUBDIRECTOR,
    ROLES.COORDINADOR_MEDULAR,
    ROLES.COORDINADOR_TRANSVERSAL
  ].includes(r));
}
```

---

## Visibilidad por combinacion de roles

| Combinacion activa | Ve en el sistema |
|---|---|
| `subdirector` | Todo el CDMC sin excepcion |
| `coordinador_medular` | Todos los programas y fichas de la linea medular |
| `coordinador_transversal` | Todos los programas y fichas de la linea transversal |
| `lider_programa` | Su programa + sus propias asignaciones |
| `instructor` | Solo sus competencias y horarios |
| Combinacion multiple | Union de todas las visibilidades anteriores |

---

## Errores criticos

```ts
// ❌ Un solo "coordinador_academico" — hay dos coordinadores con lineas distintas
requireRole(['coordinador_academico'])

// ❌ Rol unico sin contexto
const { rol_nombre } = req.user;
if (rol_nombre !== 'coordinador') return 403;

// ❌ Fichas o programas en el token
{ "fichas_permitidas": [1, 3, 7] }  // se desactualiza sin re-login

// ❌ requireRole plano para recursos contextuales
requireRole(['lider_ficha'])  // lider_ficha no es un rol global

// ❌ Mezclar los dos ejes de clasificacion
// tipo_linea (medular/transversal) ≠ tipo_area (tecnica/transversal)
```
