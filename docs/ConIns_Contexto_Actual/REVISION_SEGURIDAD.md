# Revisión de seguridad — Backend CONINS

**Fecha:** 5 de agosto de 2026
**Alcance:** API REST (Node.js + Express 5 + TypeScript + MySQL, auth JWT)
**Objetivo:** postura de seguridad actual, huecos reales priorizados, y qué NO
tiene sentido agregar a este stack (para no cargar deuda ni dar falsa sensación
de seguridad).

---

## 1. Lo que YA está protegido

| Área | Cómo | Estado |
|---|---|---|
| **Inyección SQL** | `mysql2` con consultas parametrizadas (`?`) en todos los modelos. Nunca se concatena input en el SQL. | ✅ Sólido |
| **Contraseñas** | Hash `bcrypt` (nunca en texto plano). | ✅ |
| **Autenticación** | JWT en header `Authorization: Bearer`. Expiración configurable. | ✅ |
| **Autorización** | Dos capas: `requireRole` (roles globales) + `permisoService` (alcance por ficha/programa). | ✅ |
| **Cabeceras HTTP** | `helmet` (X-Frame-Options, X-Content-Type-Options, etc.). | ✅ |
| **Rate limiting** | Global 100 req/15min + auth 10 req/15min. | ✅ (ver hueco #4) |
| **Tamaño de body** | 10kb global; 15mb solo en `/api/importar`. Evita payloads gigantes. | ✅ |
| **Fuga de errores** | El error handler devuelve un mensaje genérico al cliente ("Error interno del servidor"); el stack solo va al log del servidor. | ✅ |
| **Borrado** | Soft delete universal (`activo = FALSE`), no se pierden datos. | ✅ |
| **CORS** | Configurado con origen del frontend. | ✅ |

**Conclusión:** la base está bien. Las protecciones críticas (SQL injection,
passwords, auth) están cubiertas.

---

## 2. Huecos reales (priorizados)

### ✅ CERRADO (05/08) — Validación de entrada
Todos los endpoints de escritura que reciben un body ahora validan con `zod`
(`validate()`): ambientes, sedes, competencias/RAPs, horarios (editar, estado,
rechazar, suspender, multidia), asignaciones (editar, provisional, raps),
programa (referente), instructor (editar, competencia, baja), ficha (novedad).
Los endpoints restantes sin schema son **toggles/acciones sin body** (aprobar,
desactivar, finalizar, marcar-leida, toggle estado) — no reciben datos, no
requieren validación. Cobertura de validación de entrada: **completa**.

### 🔴 Alta (despliegue) — Secreto JWT débil
El `.env` de desarrollo usa `JWT_SECRET=conins-dev-secret-...-change-me`. Para
producción hace falta un secreto **fuerte y aleatorio** (ej. 32+ bytes), fuera
del repo, rotable.
**Acción:** generar secreto de producción al desplegar; nunca commitear.

### 🟢 Baja — HPP (HTTP Parameter Pollution)
Sin protección contra parámetros repetidos en query (`?x=a&x=b`). Riesgo **muy
bajo** aquí: la API usa casi solo JSON en el body y poquísimos query params.
Además, en Express 5 `req.query` es un getter inmutable, así que un middleware
casero para "aplanar" arrays sería un no-op silencioso — y meter seguridad que no
hace nada es peor que no ponerla. **Recomendación:** dejarlo pendiente; si en el
futuro crece la superficie de query params, usar una librería mantenida.

### 🟡 Media — Rate limiting desactivado en desarrollo
`skip: () => isDev` apaga el rate limiter cuando `NODE_ENV != production`. Está
bien para desarrollar, pero hay que **garantizar `NODE_ENV=production` en el
despliegue** para que se active.
**Acción:** checklist de despliegue.

### 🟢 Baja — Helmet con CSP desactivada
`contentSecurityPolicy: false`. Para una API que solo devuelve JSON es aceptable
(CSP protege el render de HTML, que aquí lo hace el frontend). Si algún día el
backend sirve HTML, activar CSP.

---

## 3. Lo que NO tiene sentido agregar (y por qué)

Importante para no meter "seguridad de cargo-cult" que da falsa tranquilidad:

- **CSRF** → **NO aplica.** El token de sesión viaja en el header
  `Authorization: Bearer`, no en una cookie. CSRF explota el envío **automático**
  de cookies por el navegador; un bearer token no se envía solo, hay que ponerlo
  a mano en cada request. Agregar CSRF a esta API sería incorrecto y estorboso.
  (Solo aplicaría si se cambiara a auth por cookie.)
- **`xss-clean`** → **NO usar.** El paquete está **deprecado/sin mantenimiento**.
  Además, para una API JSON el XSS se mitiga en el **render** (el frontend React
  escapa por defecto) y con validación de entrada. Sanitizar en el backend con
  una librería abandonada no es "vanguardia".
- **`express-mongo-sanitize`** → **NO aplica.** Es para MongoDB; aquí es MySQL.

---

## 4. Roadmap sugerido

| Prioridad | Acción | Momento |
|---|---|---|
| 🔴 | Schemas `zod` en rutas de escritura sin validar | En curso |
| 🔴 | Secreto JWT de producción (fuerte, fuera del repo) | Al desplegar |
| 🟡 | Middleware `hpp` | Hoy |
| 🟡 | Checklist de despliegue: `NODE_ENV=production`, `.env` seguro, HTTPS | Antes de entregar |
| 🟢 | Revisar CSP si el backend llegara a servir HTML | Solo si aplica |

**Nota final:** la seguridad "a la vanguardia acorde al stack" para esta API no es
acumular paquetes, sino: entradas validadas, secretos fuertes, consultas
parametrizadas (ya está), rate limiting activo en producción, y no exponer
información en errores (ya está). Este documento se irá actualizando conforme se
cierren los huecos.
