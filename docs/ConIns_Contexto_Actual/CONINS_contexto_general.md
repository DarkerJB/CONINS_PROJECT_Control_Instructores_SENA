# CONINS — Contexto General
### Sistema de Control de Instructores · SENA CDMC
**Versión:** 9.5 · **Fecha:** 15 de Julio 2026
**Basado en:** RF v8.0 · ERS v3.0 · Lógica de Negocio v5.4 · CRONOGRAMA v4.3 · CHANGELOG al 15/07/2026

---

## ⚡ Estado actual del proyecto

| Fase | Período | Estado |
|---|---|---|
| F1 — Análisis y requisitos | 09/04 – 30/04/2026 | ✅ Completada |
| F2 — Modelado y diseño | 04/05 – 15/05/2026 | ✅ Completada anticipadamente |
| F3 — Construcción | 19/05 – 06/08/2026 | 🔄 En curso |
| F4 — Pruebas y ajustes | 10/08 – 28/08/2026 | ⬜ Pendiente |
| F5 — Documentación y despliegue | 31/08 – 18/09/2026 | ⬜ Pendiente |

**Hitos cerrados al 15/07/2026:**
- **Reestructuración completa de RF v8.0** (53 RF, 11 módulos, numeración secuencial sin huecos). Ver `CONINS_Requisitos_Funcionales_v8_0.txt`
- **database.sql y seed_data.sql corregidos**: eliminado `tipo_contrato` de DDL `instructores`, triggers de auditoría, `sp_crear_instructor`, vistas `vw_carga_horaria_instructor` y `vw_asignaciones_activas`; `INSERT INTO tipos_actividad` → `INSERT IGNORE`; `seed_data.sql` instructores sin columna `tipo_contrato`
- **Lógica de Negocio v5.4**: roles corregidos a 4 vigentes, RN-03 universal, RN-15 actualizada (RAPs heredados), schema 28 tablas

**Hitos cerrados al 14/07/2026:**
- `tipo_contrato` eliminado del backend (modelo, schema Zod, service, controller) — RN-03 activa para todos los instructores
- Endpoints `POST /api/auth/recuperar-contrasena` y `POST /api/auth/resetear-contrasena` con tabla `password_reset_tokens` (token hex 64 chars, expira 1h, un solo uso)
- `fichas.findById` incluye fechas lectiva/productiva, ambiente y lider_nombre
- Novedades de ficha (RF-17 v8.0): `GET /api/fichas/:id/novedades`, `POST`, `PATCH /:novedadId`
- `onAlertaCargaHoraria` conectado en `horario.controller.ts`
- Frontend: `recuperar-contrasena.tsx` (flujo 3 pasos), `LoginForm` link actualizado, `exportPDF.ts` null fix, `api.ts` con `solicitarRecuperacion` y `resetearContrasena`
- Seed ADSO real: 22 competencias (7 técnicas + 12 transversales + 1 productiva + 2 TEST), 79 RAPs, 91 entradas `instructor_competencias_habilitadas`

**Hitos cerrados al 07/07/2026:**
- Frontend de rama `dev/laura` migrado a `main` — 11 páginas + 18 componentes integrados
- Fixes: CORS middleware order, GROUP BY en asignacion.model.ts, tsx watch --ignore log, super admin JWT id:0

**Hitos cerrados al 06/07/2026:**
- RF v7.0 (49 RF) — roles unificados a 4, lider_programa como figura informativa
- Todos los gaps P21-P25 cerrados: filtrado por rol (P22), update() horario revalida RN-03/RN-05 (P23), alias /api/notificaciones/mis (P24), ultimo_acceso en GET /api/auth/usuarios (P21)
- Módulos nuevos backend: rap-seguimiento (RF-50 previo), tipos-actividad endpoint
- Schema verificado en 27 tablas (tipos_actividad tabla 26, rap_ficha_seguimiento tabla 27)

**Hitos cerrados al 30/06/2026:**
- Sincronización con frontend de Laura: dropdowns dinámicos, campos tipo_documento/documento, lider_id en fichas, modal "Asignar programas a líder", exportación PDF
- Corrección de conteo schema: 25 tablas / v5 (verificado directo en database.sql)

---

## 1. Descripción oficial del sistema

> Desarrollar un sistema de información web que permita gestionar, controlar y optimizar la asignación académica y operativa de los instructores del Centro del Diseño y Manufactura del Cuero (CDMC) del SENA, mediante la administración estructurada de competencias, resultados de aprendizaje (RAPs), ambientes de formación, fichas y horarios. El sistema garantiza el cumplimiento de la carga horaria reglamentaria, previene inconsistencias como la duplicidad de asignaciones por ficha, y gestiona situaciones operativas como novedades administrativas de instructores y bloqueos temporales de ambientes.
>
> La solución incorpora un modelo de control de acceso basado en roles jerárquicos (Subdirector, Coordinadores de Línea Medular y Transversal, Líderes de Programa e Instructores), con soporte para múltiples roles simultáneos por usuario. Incluye funcionalidades de consulta, filtrado, alertas automáticas, notificaciones internas y por correo electrónico, y generación de reportes exportables en PDF para la toma de decisiones por parte de los directivos del centro.
>
> La solución se implementa mediante una arquitectura web cliente-servidor: frontend desarrollado con Next.js 15 (Pages Router), React 19, TypeScript y Tailwind CSS 4, consumiendo una API REST construida con Node.js, Express 5 y TypeScript bajo arquitectura MVC con módulos ESM6. La persistencia de datos se gestiona en una base de datos relacional MySQL (25 tablas, schema v5 — verificado 30/06/2026 directamente sobre `database.sql`), administrada desde phpMyAdmin, garantizando integridad referencial, trazabilidad de asignaciones y disponibilidad de la información mediante eliminación lógica universal.

---

## 2. Equipo del proyecto

| Rol | Nombre | Contacto |
|---|---|---|
| Instructor líder técnico | Luis Eladio Porras Camargo | lporras@sena.edu.co · lporras567@gmail.com |
| Instructor líder anterior | Wilmar Alexander Zapata (Soywaz) | github.com/Soywaz/conins |
| Instructor de seguimiento | Gloria Eugenia Jaramillo | CDMC |
| Coordinadora Académica | Leidy Johana Ruiz Cortés | ljruizc@sena.edu.co |
| Aprendiz backend / BD / análisis | Jair Enrique González Buelvas | github.com/DarkerJB · rama `dev/Jair` |
| Aprendiz frontend / diseño | Laura Sofía Posada | github.com/Laura0513 · rama `dev/laura` |

### Repositorios y rutas locales

| Ruta | Descripción |
|---|---|
| `https://github.com/Soywaz/conins` | Repo principal — rama `dev/Jair` (backend) y `dev/laura` (frontend) |
| `https://github.com/DarkerJB/ConIns_Project` | Repo de Jair — rama `main` (backend + frontend integrado) |
| `D:\2_ConIns\ConIns_Project\` | Workspace principal Jair — backend + frontend |
| `D:\2_ConIns\Jair_ConIns\` | Workspace anterior Jair — rama `dev/Jair` |
| `D:\2_ConIns\WAZ_ConIns\` | Referencia instructor — rama `main` |
| `D:\2_ConIns\Laura_Lovable\` | Diseño Lovable de Laura (referencia UI) |
| `D:\2_ConIns\Jair_ConIns\.agents\skills\conins-core\` | 5 skills de Claude Code |
| `D:\2_ConIns\Jair_ConIns\.claude\CLAUDE.md` | Governance del proyecto |

### Datos de etapa productiva

| Campo | Jair | Laura |
|---|---|---|
| Inicio | 09/04/2026 | 07/04/2026 |
| Fin | 07/10/2026 | 07/10/2026 |
| Días hábiles | 121 días / 1.089 h | 123 días / 1.107 h |
| Jornada | Lun–Vie 7:00–17:30 (9h efectivas) | ídem |

---

## 3. Stack tecnológico — vigente (confirmado en feedback 04/05/2026)

| Capa | Tecnología | Notas |
|---|---|---|
| Frontend | **Next.js 15** · React 19 · TypeScript · Tailwind CSS 4 | Pages Router · migra desde Vite en Fase 3 |
| Íconos | Lucide React | — |
| HTTP client | Fetch nativo | Axios eliminado el 28/04 |
| Backend | Node.js · Express 5 · TypeScript | Arquitectura MVC · ESM6 · migra desde JS en Fase 3 |
| Auth | JWT + bcrypt | — |
| Correo | Nodemailer | RF-38 — notificaciones al instructor |
| Base de datos | MySQL — `conIns` | 25 tablas · schema v5 — conteo corregido 30/06/2026 (antes documentado como 27/v5.2 por error) |
| Administración BD | phpMyAdmin · Laragon | Entorno local de desarrollo |
| Control de versiones | Git + GitHub | — |
| IDE | VS Code | — |

> **Nota Next.js 15 / Pages Router:** El cambio de Vite a Next.js fue confirmado en el feedback con Juan Pablo Hoyos, Wilmar Zapata y Gloria Jaramillo. Se usa **Pages Router** (`pages/`) por decisión deliberada del equipo — más sencillo y mejor documentado para el nivel y el tiempo disponible. **Zustand (`authStore`) queda en revisión:** Next.js tiene su propio sistema de gestión de sesión; evaluar si se mantiene o se reemplaza al iniciar Fase 3.

---

## 4. Directivos del CDMC y roles en CONINS

| Cargo | Nombre | Rol en CONINS | Alcance |
|---|---|---|---|
| Subdirector (e) | Dyron Javier Ramírez Osorio | `subdirector` | CDMC completo — administrador principal |
| Coordinadora Académica | Leidy Johana Ruiz Cortés | Supervisión general del proyecto | CDMC completo |
| Coordinador Académico Medular | Paul Ernesto Tamayo Caviedes | `coordinador_medular` | Calzado, marroquinería, curtición |
| Coordinador Académico Transversal (anterior) | Juan Pablo Hoyos Maya | `coordinador_transversal` + `lider_programa` (Bilingüismo) | Transversal + Bilingüismo |

---

## 5. Vocabulario SENA — crítico para variables, tablas y UI

| Término | Significado | Implementación |
|---|---|---|
| **Ficha** | Grupo de aprendices. Próximamente "grupo" | `numero_ficha` en BD — etiqueta configurable en frontend |
| **Programa medular** | Razón de ser del CDMC: calzado, marroquinería, curtición | Coordinado por `coordinador_medular` |
| **Programa transversal** | Programas de apoyo: ADSO, bilingüismo, diseño | Coordinado por `coordinador_transversal` |
| **Competencia** | Equivalente a asignatura. Agrupa RAPs | Unidad de asignación |
| **RAP** | Resultado de Aprendizaje. Se hereda al asignar competencia | Solo para conteo y validación de unicidad |
| **Ambiente** | Aula o taller físico | Aulas 200–208 · Talleres T1–T4 |
| **Líder de ficha** | Responsable administrativo del grupo | Campo `es_lider_ficha BOOLEAN` en `asignacion` — NO es rol |
| **Novedad administrativa** | Ausencia temporal del instructor (licencia, incapacidad, comisión) | Tabla `instructor_novedades` — excluye del sistema mientras vigente |
| **Bloqueo de ambiente** | Espacio no disponible temporalmente | Tabla `ambiente_bloqueos` — excluye mientras vigente |
| **Sofía Plus** | Plataforma oficial SENA | CONINS no la reemplaza |
| **HUI FORMACION** | Cursos LMS autogestionados | Fichas sin instructor presencial — seed sin asignación |

> ⚠️ **Dos ejes independientes — NO mezclar:**
> - **Medular / Transversal** = clasificación de *programas del centro*
> - **Técnica / Transversal** = clasificación de *áreas y competencias de instructores*

---

## 6. Roles del sistema — tabla `roles` (4 entradas exactas, Title Case)

| ID | Nombre en BD | Nivel | Alcance |
|---|---|---|---|
| 1 | `Subdirector` | 1 | CDMC completo — administrador principal |
| 2 | `Coordinadora Academica` | 2 | Alcance ADSO — todos los permisos de gestión |
| 3 | `Asistente Coordinacion` | 3 | Mismos permisos que Coordinadora Academica |
| 4 | `Instructor` | 4 | Solo lectura de sus fichas activas |

> Constantes en `backend/constants/roles.ts`. ROLES_ADMIN = [Subdirector, Coordinadora Academica, Asistente Coordinacion].
> `lider_programa` NO es un rol. Es una relación en tabla `lider_programa` — dato organizativo sin impacto en permisos.
> `es_lider_ficha` NO es un rol. Es `BOOLEAN DEFAULT FALSE` en tabla `asignacion` — dato organizativo sin impacto en permisos.
> Autorización en dos capas: `requireRole` (roles globales) + `permisoService` (acceso contextual por ficha/programa).

---

## 7. Flujo de autenticación — definitivo

### Pantalla pública `/auth` — dos tabs

```
Tab "Iniciar sesión"              Tab "Crear contraseña"
──────────────────────            ──────────────────────────────────
Campo: correo                     Campo: correo
Campo: contraseña (toggle)        Campo: contraseña nueva (toggle)
Botón: Iniciar sesión             Campo: confirmar contraseña (toggle)
Link: ¿Olvidaste contraseña?      Botón: Crear contraseña
                                  Alerta amarilla si correo no en BD
```

### Flujo de dos pasos obligatorios

```
Paso 1 (admin):   Crea cuenta → correo + nombre + rol → sin contraseña
Paso 2 (usuario): /auth → tab "Crear contraseña" → ingresa correo
                  ¿Existe en BD? Sí → guarda contraseña → puede login
                                 No → alerta amarilla → HTTP 403
Paso 3 en adelante: login normal con correo + contraseña
```

**Arranque:** seed carga todos los usuarios actuales con correo, nombre y rol sin contraseña. Admin inicial (Subdirector) entra con contraseña definida en el seed. RF-13 para nuevos ingresos futuros.

---

## 8. Infraestructura física del CDMC

| Tipo | Identificadores | Notas |
|---|---|---|
| Aulas | 200 al 208 (9 aulas) | Formación general |
| Talleres | T1 al T4 (4 talleres) | Formación práctica — pueden albergar varias fichas simultáneamente |

| Jornada | Horario | Valida ambiente físico |
|---|---|---|
| Mañana | 06:00 – 12:00 | Sí |
| Mixta | 12:00 – 18:00 | Sí |
| Noche | 18:00 – 22:00 | Sí |
| Virtual | Sin horario fijo | No |

---

## 9. Áreas y líderes del CDMC

| Área | Líder(es) | Línea |
|---|---|---|
| ADSO | Carlos Álvarez | Transversal |
| Talento Humano | Catalina (apellido pendiente — P9) | Transversal |
| Contabilidad | Andrés Pareja | Transversal |
| Logística | William Ramírez | Transversal |
| SIG | Luis María Arango | Transversal |
| Transversales | Anderson Silva | Transversal |
| Bilingüismo | Juan Pablo Hoyos Maya | Transversal |
| Virtualidad | Paula Isaza | Transversal |
| Técnico Medular | Gloria Pabón + Rivera (apellido pendiente — P8) | Medular |
| Tecnólogo Medular | Freddy Calderón + Luisa Nieves | Medular |

---

## 10. Reglas de negocio vigentes

| RN | Regla | Tipo | Estado Backend |
|---|---|---|---|
| RN-01 | Onboarding dos pasos — sin paso 1 → HTTP 403 | Hard | ✅ Implementado |
| RN-02 | Correo como identificador único — sin restricción de dominio | Hard | ✅ Implementado |
| RN-03 | Alerta `JORNADA_RESTRINGIDA` si cualquier instructor tiene horario en jornada nocturna o fin de semana (tipo_contrato eliminado 14/07/2026) | Soft | ✅ Implementado |
| RN-04 | Hard block si instructor tiene horarios superpuestos — HTTP 409 | Hard | ✅ Implementado |
| RN-05 | Soft alert `AMBIENTE_OCUPADO` si ambiente ya ocupado en la misma jornada | Soft | ✅ Implementado |
| RN-06 | `UNIQUE(ficha_id, rap_id)` — mismo RAP no puede tener dos instructores en la misma ficha — HTTP 409 | Hard | ✅ Implementado |
| RN-07 | Alerta `CARGA_HORARIA` si instructor fuera del rango de horas (20–40h semanales) | Soft | ✅ Implementado |
| RN-08 | Instructor excluido mientras novedad vigente — reincorporación automática al vencer `fecha_regreso` | Auto | ✅ Implementado |
| RN-09 | Ambiente excluido mientras bloqueo vigente — reincorporación automática al vencer `fecha_fin` | Auto | ✅ Implementado |
| RN-10 | Soft delete universal — `activo BOOLEAN DEFAULT TRUE` en todas las tablas | Hard | ✅ Implementado |
| RN-11 | Asignación provisional — requiere autorizante, fecha y motivo — solo la registra un administrador | Hard | ✅ Implementado |
| RN-12 | Líder solo asigna dentro de sus programas — no registra provisionales | Hard | ✅ Implementado |
| RN-13 | Instructor solo asignable a competencias en `instructor_competencias_habilitadas` | Hard | ✅ Implementado |
| RN-14 | Fichas virtuales — sin asignación ni validación de ambiente físico | Hard | ✅ Implementado |
| RN-15 | RAPs heredados al asignar competencia — no se asignan individualmente | Hard | ✅ Implementado |
| RN-16 | Nomenclatura "ficha" configurable en frontend — no hardcodear | Soft | ✅ Implementado |

> **Nota (30/06/2026):** las RN de esta tabla están implementadas, pero RF-37 (más amplio que cualquier RN individual — "verificar que cambios en horarios/jornadas/instructores/ambientes no generen conflictos") solo se cubre completamente en `create()`. En `update()` de horario solo se revalidan RN-04 y RN-09; RN-03 y RN-05 no se recalculan al editar. Ver P23.

---

## 11. Modelo de datos — schema v5 (28 tablas — verificado 15/07/2026)

> **Historial de conteo:** 25 tablas (30/06/2026, corrección de error) → 27 tablas (06/07/2026, +tipos_actividad +rap_ficha_seguimiento) → 28 tablas (15/07/2026, +password_reset_tokens). La columna `tipo_contrato` fue eliminada de `instructores` el 14/07/2026. Lista completa de las 28: `jornadas, roles, areas, usuarios, usuario_roles, instructores, programas, competencias, raps, ambientes, fichas, asignacion, asignacion_competencia, lider_programa, instructor_competencias_habilitadas, horarios, alertas, tipos_novedad_instructor, instructor_novedades, ambiente_bloqueos, tipos_novedad_ambiente, tipos_novedad_ficha, ficha_novedades, notificaciones, auditoria, tipos_actividad, rap_ficha_seguimiento, password_reset_tokens`.

```
instructor
  └── asignacion  (instructor_id, ficha_id, es_lider_ficha, es_provisional)
        └── asignacion_competencia  (asignacion_id, competencia_id, ambiente_excepcion_id)
              └── competencia
                    └── raps  ← heredados automáticamente
```

**Catálogos base (seed — sin CRUD en UI):**
```sql
roles, programas, competencias, raps, ambientes, jornadas, fichas
```
`programas.tipo_formacion ENUM('titulada','complementaria','operario')`
`fichas (numero_ficha, programa_id, etapa, lider_id, activo)`
`fichas.etapa ENUM('lectiva','productiva')`

**Usuarios y roles:**
```sql
usuarios (id, nombre, email, password, tipo_documento, documento, ultimo_acceso, activo, created_at)
usuario_roles, instructores, lider_programa,
instructor_competencias_habilitadas
```

**Novedades y bloqueos:**
```sql
tipos_novedad_instructor (id, nombre, descripcion, activo) — seed: 6 tipos
tipos_novedad_ambiente   (id, nombre, descripcion, activo) — seed: 5 tipos
tipos_novedad_ficha      (id, nombre, descripcion, activo) — seed: 5 tipos
instructor_novedades (id, instructor_id, tipo_novedad_id, fecha_inicio, fecha_regreso, observacion, activo)
ficha_novedades      (id, ficha_id, tipo_novedad_id, fecha_inicio, fecha_regreso, observacion, activo)
ambiente_bloqueos    (id, ambiente_id, fecha_inicio, fecha_fin, motivo, activo)
```

**Asignaciones:**
```sql
asignacion            (instructor_id, ficha_id, es_lider_ficha, es_provisional,
                       autorizado_por_id, fecha_autorizacion, motivo_provisional, activo)
asignacion_competencia (asignacion_id, competencia_id, instructor_anterior_id,
                        fecha_cambio, ambiente_excepcion_id, observacion, activo)
```

**Horarios, alertas y notificaciones:**
```sql
horarios       (instructor_id, ficha_id, competencia_id, ambiente_id, jornada_id, fecha,
                 hora_inicio, hora_fin, estado, motivo_rechazo, motivo_suspension, activo)
alertas        (instructor_id, tipo, mensaje, leida, generada_en)
notificaciones (usuario_id, tipo, mensaje, leida, generada_en)
```

---

## 12. Requisitos Funcionales v8.0 — 53 RF en 11 módulos

| Módulo | Rango | Total |
|---|---|---|
| AUTH — Autenticación y gestión de cuentas | RF-01 al RF-07 | 7 |
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

Ver `CONINS_Requisitos_Funcionales_v8_0.txt` para el texto completo. El archivo v7_0.txt se conserva como historial.

---

## 13. Skills de Claude Code — `.agents/skills/conins-core/`

| Skill | Propósito |
|---|---|
| `asignacion-competencia-integrity` | Integridad: instructor → ficha → competencia → RAPs heredados |
| `auth-multirole` | JWT multirol · flujo `/auth` dos tabs · registro de dos pasos |
| `backend-clean-architecture` | Controller / service / model — validaciones solo en service |
| `horario-carga-validation` | Cálculo de carga horaria — siempre en backend |
| `role-based-access-control` | Dos capas: `requireRole` + `permisoService` · `lider_ficha` no es rol |

---

## 14. Pendientes activos (al 15/07/2026)

| # | Pendiente | Responsable | Prioridad |
|---|---|---|---|
| P4 | Lista oficial de instructores con correo estandarizado | CDMC → Jair | 🟡 Media |
| P8 | Apellido completo del co-líder Rivera (Técnico Medular) | CDMC | 🟢 Baja |
| P9 | Apellido completo de Catalina (líder Talento Humano) | CDMC | 🟢 Baja |
| P10 | Revisar Resolución 1415/2012 y Acuerdo 0003/2017 | Jair | 🟢 Baja |
| P16 | Configurar infraestructura de pruebas automatizadas | Jair + Laura | 🟡 Media — Fase 4 |
| P17 | Implementar seguridad: xss-clean, CSRF, validación en rutas pendientes | Jair | 🟡 Media |
| P26 | Expansión línea medular (Calzado/Cuero) — usuarios 5, 10, 11, 12 sin rol ni registro instructor hasta completarse | CDMC | 🟢 Baja |
| P27 | Configurar SMTP_USER y SMTP_PASS en .env para activar recuperación de contraseña y notificaciones por correo | Jair | 🟡 Media |
| P28 | CrearBloqueHorarioModal usa ficha.id en lugar de ficha.programa_id para cargar competencias dinámicas | Laura | 🟡 Media |

**Resueltos al 15/07/2026:** P1-P3, P5-P7 (04-19/05/2026) · P14, P15 (09/06/2026) · P21-P25 (06-07/07/2026) · L1-L6, SEED-ADSO (14/07/2026) · database.sql/seed_data.sql tipo_contrato cleanup (15/07/2026)

**Cuenta de prueba (QA, entorno local):** `instructor.prueba@sena.edu.co` — rol Instructor, para validar filtrado por rol y sidebar limitado.

---

## 15. Archivos de referencia del proyecto

| Archivo | Versión | Descripción |
|---|---|---|
| `CONINS_contexto_general.md` | v9.5 | Este documento — contexto completo actualizado |
| `CONINS_Requisitos_Funcionales_v8_0.txt` | v8.0 | 53 RF en 11 módulos — fuente de verdad vigente |
| `CONINS_Requisitos_Funcionales_v7_0.txt` | v7.0 | 49 RF — conservado como historial |
| `CONINS_Logica_Negocio_v5.md` | v5.4 | Reglas de negocio, schema 28 tablas, 4 roles vigentes |
| `CRONOGRAMA.md` | v4.3 | Fases, fechas y estados |
| `CHANGELOG.md` | 15/07/2026 | Historial detallado de cambios |
| `ERS_CONINS_v3.docx` | v3.0 | ERS IEEE 830-1998 — documento original (RF renumerados en v8.0) |
| `SENA_identidad_visual_resumen_tecnico.md` | — | Paleta, tipografía y logosímbolo SENA 2024 |
| `.claude/skills/conins-core/` | — | 5 skills del proyecto |
| `.claude/CLAUDE.md` | — | Governance del proyecto |

---

## 16. Referencia de chats del proyecto

| Chat | Última actualización | Tema principal |
|---|---|---|
| Contexto General (este) | 30/06/2026 | Contexto completo del proyecto |
| RF, RNF, CU, HU ConINs | 04/05/2026 | RF v6 (45 RF) · ERS v3 completo |
| Bitácora etapa productiva | 04/05/2026 | Bitácora mensual GFPI-F-147 |
| DB Laragon para phpMyAdmin | 30/06/2026 | Schema v5 · 25 tablas (corregido — antes "v5.2 · 27 tablas") + auditoria + triggers + procedures + vistas |
| GitHub ConIns | 04/05/2026 | Ramas y commits |
| Análisis de Documentos | 24/04/2026 | Glosario ERS · CSVs seed |
| Skills y CLAUDE.md | 24/04/2026 | 5 skills `conins-core` |

---

*CONINS · SENA CDMC · Contexto General v9.5 · 15 de Julio 2026*
*Autores: Jair Enrique González Buelvas · Laura Sofía Posada*
