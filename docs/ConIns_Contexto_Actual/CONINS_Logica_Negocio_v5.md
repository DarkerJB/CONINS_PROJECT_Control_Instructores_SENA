# CONINS — Lógica de Negocio
## Centro del Diseño y Manufactura del Cuero · CDMC SENA
**Versión:** 5.4 · **Fecha:** 15 de Julio 2026
**Basado en:** RF v8.0 · ERS v3.0 · sesiones 23/04, 28/04, 04/05, 11/06, 06/07 y 15/07/2026

> Nota de vigencia (15/07/2026): documento actualizado a v5.4. Cambios principales respecto a v5.3: roles del sistema corregidos a los 4 vigentes (Subdirector, Coordinadora Academica, Asistente Coordinacion, Instructor); tipo_contrato eliminado de instructores — RN-03 activa para todos; RN-15 actualizada (RAPs heredados al asignar competencia); schema actualizado a 28 tablas (se agrega password_reset_tokens); RF actualizados a v8.0 (53 RF en 11 modulos); pendientes actualizados al 15/07/2026. CHANGELOG.md y CONINS_contexto_general.md siguen siendo fuente de verdad para el estado mas reciente.

---

## 1. Objetivo del sistema

CONINS es un sistema de **control de malla de horarios** del CDMC. Su pregunta central es:

> **¿Qué instructor cubre qué competencia, en qué ficha, en qué ambiente y en qué jornada?**

No es un sistema curricular, no es un gestor de infraestructura, no reemplaza a Sofía Plus.

**Lo que CONINS NO gestiona:**

| Dato | Quién lo gestiona |
|---|---|
| Notas y juicios evaluativos | Sofía Plus |
| Creación/edición de programas de formación | Datos oficiales SENA (seed, sin CRUD) |
| Competencias y RAPs como catálogo | Sofía Plus → seed, sin CRUD |
| Ambientes como infraestructura | Datos fijos (seed, sin CRUD) |
| Jornadas | Datos fijos e institucionales (seed, sin CRUD) |
| Estado del curso (EN EJECUCIÓN, TERMINADA) | Sofía Plus |

---

## 2. Datos precargados — sin CRUD en la UI

| Dato | Razón |
|---|---|
| Programas de formación | Definidos institucionalmente por el SENA |
| Competencias y RAPs | Datos normativos de Sofía Plus |
| Ambientes | Aulas 200–208 y talleres T1–T4 — fijos |
| Jornadas | Mañana, mixta, noche y virtual — fijas |
| Usuarios del arranque | El CDMC ya tiene correos y roles de todo el personal activo |

---

## 3. Acceso al sistema — onboarding de dos pasos

**Paso 1 (RF-07) — El administrador habilita la cuenta:**
Registra al usuario con correo, nombre, rol, tipo y numero de documento. La cuenta queda sin contraseña — el usuario aun no puede entrar.

**Paso 2 (RF-01) — El usuario crea su contraseña:**
Va a `/auth` → tab "Crear contraseña" → ingresa su correo. Si existe en BD → guarda contraseña → puede hacer login. Si no → alerta amarilla + HTTP 403.

**Paso 3 en adelante:** login normal con correo + contraseña (RF-02).

**Recuperacion de contraseña (RF-04):** desde `/recuperar-contrasena`. El sistema genera un token de un solo uso (expiracion 1 hora) y lo envia al correo del usuario. El usuario visita el enlace y establece nueva contraseña. Requiere SMTP configurado en `.env`.

### Pantalla pública `/auth`

```
Tab "Iniciar sesión"              Tab "Crear contraseña"
──────────────────────            ──────────────────────────────────
Campo: correo                     Campo: correo
Campo: contraseña (toggle)        Campo: contraseña nueva (toggle)
Botón: Iniciar sesión             Campo: confirmar contraseña (toggle)
Link: ¿Olvidaste contraseña?      Botón: Crear contraseña
  → /recuperar-contrasena           Alerta amarilla si correo no en BD
```

Sin selector de rol · sin campo nombre · sin registro con redes sociales.

### Estrategia de arranque

1. El seed carga todos los usuarios actuales del CDMC con correo, nombre y rol — sin contraseña.
2. El admin inicial (Subdirector) entra con contraseña definida en el seed.
3. RF-13 (crear usuarios desde dashboard) aplica para nuevos ingresos futuros.

**Campo de login:** correo electrónico registrado en BD. Puede ser `@sena.edu.co` o correo personal — sin restricción de dominio. (P3 resuelto 04/05/2026)

---

## 4. Roles del sistema — tabla `roles` (4 entradas exactas, Title Case)

| ID | Nombre exacto en BD | Nivel | Alcance |
|---|---|---|---|
| 1 | `Subdirector` | 1 | CDMC completo — administrador principal |
| 2 | `Coordinadora Academica` | 2 | Alcance ADSO — todos los permisos de gestion |
| 3 | `Asistente Coordinacion` | 3 | Mismos permisos que Coordinadora Academica |
| 4 | `Instructor` | 4 | Solo lectura de sus fichas activas |

> Los nombres de rol usan Title Case con espacios (convención desde 01/07/2026). Constantes en `backend/constants/roles.ts`.
> `lider_programa` NO es un rol. Es una relacion en la tabla `lider_programa` (instructor_id, programa_id) — dato organizativo sin impacto en permisos ni en JWT.
> `es_lider_ficha` NO es un rol. Es un campo `BOOLEAN DEFAULT FALSE` en la tabla `asignacion` — dato organizativo sin impacto en permisos ni en `requireRole`.
> Los roles ROLES_ADMIN = [Subdirector, Coordinadora Academica, Asistente Coordinacion] tienen acceso de escritura completo. El rol Instructor tiene solo lectura filtrada por su instructor_id.

---

## 5. Reglas de negocio

### RN-01 · Onboarding obligatorio
```
Paso 1: admin crea cuenta (correo + nombre + rol) → sin contraseña
Paso 2: usuario crea contraseña desde /auth
Sin Paso 1 → HTTP 403 con mensaje descriptivo
```

### RN-02 · Correo como identificador único
```
Campo de login para todos los roles.
Puede ser @sena.edu.co o personal — sin restricción de dominio.
No se puede cambiar sin intervención del administrador.
```

### RN-03 · Jornada restringida
```
Si jornada = 'noche' O dia IN ('sabado', 'domingo')
→ Alerta JORNADA_RESTRINGIDA (no bloquear)
Aplica a todos los instructores — tipo_contrato eliminado 14/07/2026.
```

### RN-04 · Conflicto de instructor — hard block
```
Si EXISTS(horario con instructor_id = ? Y bloque superpuesto)
→ Bloquear, HTTP 409 con error descriptivo
```

### RN-05 · Conflicto de ambiente — soft alert
```
Si EXISTS(horario con ambiente_id = ? Y jornada_id = ? Y fecha = ?)
→ Permitir pero emitir alerta AMBIENTE_OCUPADO
(Talleres: pueden albergar varias fichas simultáneamente)
```

### RN-06 · Unicidad de RAP por ficha
```
UNIQUE(ficha_id, rap_id) en asignacion_raps
Si viola → HTTP 409
Un RAP no puede tener dos instructores distintos en la misma ficha.
Sí puede repetirse en fichas diferentes del mismo programa.
RAPs heredados al asignar la competencia — no se asignan individualmente.
```

### RN-07 · Límite de horas semanales
```
Si SUM(horas_semana) < 20 O > 40
→ Alerta CARGA_HORARIA (no bloquear)
Rango 20–40h confirmado para todos los instructores (P1 resuelto 04/05/2026)
```

### RN-08 · Novedad administrativa del instructor (RF-16)
```
Si EXISTS(instructor_novedades con instructor_id = ?
  Y fecha_inicio <= HOY Y fecha_regreso >= HOY Y activo = TRUE)
→ Excluir instructor de asignaciones
→ Reincorporar automáticamente al vencer fecha_regreso
activo del instructor permanece TRUE — la cuenta sigue activa.
```

### RN-09 · Bloqueo temporal de ambiente (RF-31)
```
Si EXISTS(ambiente_bloqueos con ambiente_id = ?
  Y fecha_inicio <= HOY Y fecha_fin >= HOY Y activo = TRUE)
→ Excluir ambiente de asignaciones (RF-28 valida esto)
→ Reincorporar automáticamente al vencer fecha_fin
```

### RN-10 · Soft delete universal
```
Ningún registro se elimina físicamente.
activo BOOLEAN NOT NULL DEFAULT TRUE en todas las tablas.
Todas las queries de listado filtran WHERE activo = TRUE.
```

### RN-11 · Asignación provisional (RF-33)
```
Solo la registra un administrador (Subdirector, Coordinadora Academica,
Asistente Coordinacion).
Campos obligatorios: instructor_id, ficha_id, autorizante
(autorizado_por_id), fecha_autorizacion, motivo.
Sin alguno → el sistema no registra la provisional.
```

### RN-12 · Solo administradores registran provisionales (RF-33)
```
El rol Instructor no puede registrar asignaciones provisionales.
lider_programa es un dato organizativo sin permisos — no aplica aqui.
Validacion en permisoService: requireRole([ROLES_ADMIN]).
```

### RN-13 · Competencia habilitada por contrato (RF-27)
```
Solo puede asignarse a competencias en instructor_competencias_habilitadas.
El sistema filtra y muestra solo las disponibles para ese instructor.
```

### RN-14 · Fichas virtuales
```
Si ficha.modalidad = 'virtual'
→ No se asigna ni valida ambiente físico
Lógica derivada de modalidad, no de jornada.
```

### RN-15 · RAPs heredados al asignar competencia
```
Al registrar asignacion_competencia, el sistema hereda automaticamente
todos los RAPs de esa competencia.
Los RAPs NO se asignan individualmente.
Un RAP no puede quedar asignado a dos instructores distintos en la
misma ficha (RN-06 garantiza unicidad — HTTP 409).
```

### RN-16 · Cambio de instructor en competencia activa
```
Nuevo instructor → asignacion_competencia actualizada.
Anterior → instructor_anterior_id con fecha_cambio.
RAPs ya evaluados permanecen en Sofía Plus.
```

### RN-17 · Nomenclatura configurable
```
"Ficha" → próximamente "grupo".
No hardcodear en frontend. Usar constante configurable.
```

---

## 6. Reglas de arquitectura

| Regla | Descripción |
|---|---|
| **Controller → solo HTTP** | `req/res`. Cero lógica de negocio. |
| **Service → lógica de negocio** | Validaciones, cálculos, reglas de negocio. |
| **DB → solo queries** | Sin lógica de negocio. |
| **Horas en backend** | `horarioService` calcula carga horaria. El frontend nunca calcula horas. |
| **Validaciones en backend** | El frontend nunca valida unicidad de RAP, roles ni reglas de negocio. |
| **JWT en header** | `Authorization: Bearer <token>`. Sin token → HTTP 401. |
| **Dos capas de autorización** | `requireRole([])` para roles globales + `permisoService` para acceso contextual. |
| **Errores descriptivos** | Los mensajes del backend se muestran en UI sin modificación. |
| **HTTP client: Fetch** | El frontend usa Fetch nativo. No Axios. |

---

## 7. Stack tecnológico (objetivo Fase 3)

| Capa | Tecnología |
|---|---|
| Frontend | **Next.js 15** (Pages Router) · React 19 · TypeScript · Tailwind CSS 4 · Lucide React |
| HTTP client | Fetch nativo |
| Backend | Node.js · Express 5 · TypeScript · MVC · ESM6 |
| Auth | JWT + bcrypt |
| Correo | Nodemailer |
| Base de datos | MySQL — `conIns` · phpMyAdmin · Laragon |
| IDE / VCS | VS Code · Git + GitHub |

> **Nota frontend:** Migración de Vite a Next.js 15 confirmada en feedback con Juan Pablo Hoyos, Wilmar Zapata y Gloria Jaramillo. Se usa Pages Router por decisión deliberada. Zustand en revisión para Fase 3 (P11).

---

## 8. Modelo de datos — schema v5 (28 tablas — verificado 15/07/2026)

> Nota de actualización (15/07/2026): schema en 28 tablas. Las 27 originales (verificadas 06/07/2026) mas `password_reset_tokens` agregada en sesion 14/07/2026 para el flujo de recuperacion de contrasena. La columna `tipo_contrato` fue eliminada de la tabla `instructores` en la misma sesion. Ver `CHANGELOG.md` y `CONINS_contexto_general.md` para el historial completo.

```
instructor
  └── asignacion  (instructor_id, ficha_id, es_lider_ficha, es_provisional)
        └── asignacion_competencia  (asignacion_id, competencia_id, ambiente_excepcion_id)
              └── competencia
                    └── raps  ← heredados automáticamente
```

**Catálogos base (seed):**
```sql
roles, programas, competencias, raps, ambientes, jornadas, fichas
-- programas.tipo_formacion ENUM('titulada','complementaria','operario')
-- fichas.etapa ENUM('lectiva','productiva')  ← confirmado 04/05/2026
```

**Usuarios y roles:**
```sql
usuarios, usuario_roles, instructores, lider_programa,
instructor_competencias_habilitadas
```

**Novedades y bloqueos:**
```sql
instructor_novedades (id, instructor_id, tipo_novedad_id FK, fecha_inicio,
                      fecha_regreso, observacion, activo)
ambiente_bloqueos    (id, ambiente_id, fecha_inicio, fecha_fin, motivo, activo)
```

**Asignaciones:**
```sql
asignacion (id, instructor_id, ficha_id,
            es_lider_ficha BOOLEAN DEFAULT FALSE,
            es_provisional BOOLEAN DEFAULT FALSE,
            autorizado_por_id, fecha_autorizacion, motivo_provisional, activo)

asignacion_competencia (id, asignacion_id, competencia_id,
                        instructor_anterior_id, fecha_cambio,
                        ambiente_excepcion_id, observacion, activo)
```

**Horarios, alertas y notificaciones:**
```sql
horarios       (instructor_id, ficha_id, competencia_id, ambiente_id,
                 jornada_id, fecha, hora_inicio, hora_fin,
                 estado, motivo_rechazo, motivo_suspension, activo)
alertas        (instructor_id, tipo, mensaje, leida, generada_en)
notificaciones (usuario_id, tipo, mensaje, leida, generada_en)
```

---

## 9. Resumen de RF v8.0 — 53 RF en 11 módulos (vigente al 15/07/2026)

| Módulo | Rango | Total |
|---|---|---|
| AUTH — Autenticacion y gestion de cuentas | RF-01 al RF-07 | 7 |
| Instructores | RF-08 al RF-12 | 5 |
| Fichas | RF-13 al RF-17 | 5 |
| Programas | RF-18 al RF-19 | 2 |
| Ambientes | RF-20 al RF-24 | 5 |
| Horarios | RF-25 al RF-31 | 7 |
| Asignaciones | RF-32 al RF-36 | 5 |
| Alertas y Notificaciones | RF-37 al RF-43 | 7 |
| Consulta y Reportes | RF-44 al RF-47 | 4 |
| Seguridad y Trazabilidad | RF-48 al RF-51 | 4 |
| RAP-Seguimiento | RF-52 al RF-53 | 2 |
| **Total** | | **53** |

Ver `CONINS_Requisitos_Funcionales_v8_0.txt` para el texto completo de cada RF.

---

## 10. Pendientes activos (al 15/07/2026)

| # | Pendiente | Responsable | Prioridad |
|---|---|---|---|
| P4 | Lista oficial de instructores con correo estandarizado | CDMC → Jair | 🟡 Media |
| P8 | Apellido co-líder Rivera (Técnico Medular) | CDMC | 🟢 Baja |
| P9 | Apellido Catalina (líder Talento Humano) | CDMC | 🟢 Baja |
| P10 | Revisar Resolución 1415/2012 y Acuerdo 0003/2017 | Jair | 🟢 Baja |
| P16 | Configurar infraestructura de pruebas automatizadas | Jair + Laura | 🟡 Media |
| P17 | Implementar seguridad: xss-clean, CSRF, validacion en rutas pendientes | Jair | 🟡 Media |
| P26 | Expansion linea medular (Calzado/Cuero) — usuarios 5, 10, 11, 12 sin rol ni instructor hasta completarse | CDMC | 🟢 Baja |
| P27 | Configurar SMTP_USER y SMTP_PASS en .env para activar recuperacion de contrasena y notificaciones por correo | Jair | 🟡 Media |
| P28 | CrearBloqueHorarioModal usa ficha.id en lugar de ficha.programa_id para cargar competencias | Laura | 🟡 Media |

> Resueltos: P1-P3, P5-P7 (04-19/05/2026). P14, P15 (09/06/2026). P21-P25 (06-07/07/2026). L1-L6, SEED-ADSO (14/07/2026). database.sql + seed_data.sql fixes tipo_contrato (15/07/2026).

---

## 11. Historial de versiones

| Versión | Fecha | Cambios principales |
|---|---|---|
| v1 | Abril 2026 | Modelo inicial |
| v2 | Abril 2026 | Reestructuración — `asignacion → asignacion_competencia` |
| v3 | 23/04/2026 | Bloqueadores B1–B8 resueltos |
| v4 / v4.1 | 28/04/2026 | Flujo `/auth`, `lider_ficha` eliminado de roles, RF v6 |
| v5.0 | 28/04/2026 | RN-08, RN-09, schema 19 tablas |
| v5.1 | 06/05/2026 | Stack Next.js 15. P1–P3, P5–P6 resueltos. Schema v4, 20 tablas. |
| v5.2 | 11/06/2026 | horarios (estado, motivo_rechazo, motivo_suspension). 27 tablas, 47 RF. |
| v5.3 | 30/06/2026 | Schema v5, 25 tablas (corrección). tipo_novedad_id FK. Triggers corregidos. |
| **v5.4** | **15/07/2026** | **Roles corregidos a 4 vigentes. tipo_contrato eliminado de instructores y RN-03. RN-15 actualizada (RAPs heredados). Schema 28 tablas (+ password_reset_tokens). RF v8.0 (53 RF, 11 modulos). Pendientes actualizados.** |

---

*CONINS · SENA CDMC · Lógica de Negocio v5.4 · 15 de Julio 2026*
*Autores: Jair Enrique González Buelvas · Laura Sofía Posada*
