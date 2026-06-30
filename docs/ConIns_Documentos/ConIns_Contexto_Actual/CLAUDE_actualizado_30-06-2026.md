# CONINS — AI GOVERNANCE (actualizado 30/06/2026)
# Para aplicar: copiar este contenido sobre D:\2_ConIns\ConIns_Project\.claude\CLAUDE.md

## CONTEXT

CONINS = Control de Instructores, CDMC-SENA, Itagui.
Gestion de carga academica de instructores. NO es gestor de notas (eso es Sofia Plus).

Documentos fuente de verdad (leer antes de cada tarea):
1. `D:\2_ConIns\ConIns_Documentos\ConIns_Contexto_Actual\CHANGELOG.md` — historial de cambios
2. `D:\2_ConIns\ConIns_Documentos\ConIns_Contexto_Actual\CONINS_contexto_general.md` — contexto completo del negocio
3. `D:\2_ConIns\ConIns_Documentos\ConIns_Contexto_Actual\CONINS_Requisitos_Funcionales_v6_1.txt` — 47 RF en 8 modulos
4. `D:\2_ConIns\ConIns_Documentos\ConIns_Contexto_Actual\CONINS_Logica_Negocio_v5.md` — reglas de negocio y arquitectura
5. `D:\2_ConIns\ConIns_Documentos\ConIns_Contexto_Actual\CRONOGRAMA.md` — fases, fechas y estados
6. `D:\2_ConIns\ConIns_Documentos\ConIns_Contexto_Actual\SENA_identidad_visual_resumen_tecnico.md` — paleta y tipografia SENA

> Ruta corregida 30/06/2026: la carpeta anterior `ConIns_Documentacion_e_Insumos\ConIns_Contexto_General` no existe — fue renombrada a `ConIns_Documentos\ConIns_Contexto_Actual`. El RF vigente tambien cambio de nombre (v6.txt → v6_1.txt, 45 → 47 RF).

Skills del proyecto (leer en disco antes de proponer):
- `asignacion-competencia-integrity` — `.claude/skills/conins-core/asignacion-competencia-integrity/SKILL_asignacion-competencia-integrity.md`
- `auth-multirole` — `.claude/skills/conins-core/auth-multirole/SKILL_auth-multirole.md`
- `role-based-access-control` — `.claude/skills/conins-core/role-based-access-control/SKILL_role-based-access-control.md`
- `horario-carga-validation` — `.claude/skills/conins-core/horario-carga-validation/SKILL_horario-carga-validation.md`
- `backend-clean-architecture` — `.claude/skills/conins-core/backend-clean-architecture/SKILL_backend-clean-architecture.md`

## STACK

Frontend: Next.js 15 (Pages Router) + React 19 + TypeScript + Tailwind CSS 4 + Lucide React + Fetch nativo
Backend: Node.js + Express 5 + TypeScript + MVC + ESM6
Auth: JWT + bcrypt
Correo: Nodemailer (condicional — solo si SMTP configurado en .env)
BD: MySQL — conIns (schema v5, 25 tablas — verificado 30/06/2026 por conteo directo sobre database.sql)

## ESTADO ACTUAL (30/06/2026)

Modulos backend implementados:
- Auth (login, crear-password, cambiar-password, perfil, usuarios CRUD + rol como texto + tipo_documento/documento + ultimo_acceso*)
- Instructores (CRUD + competencias + novedades + detalle completo)
- Fichas (CRUD + finalizar + toggle estado + lider_id)
- Horarios (CRUD + toggle estado + aprobar/rechazar/suspender + validaciones RN-03/RN-04/RN-05/RN-09/RN-14)
- Asignaciones (CRUD + desactivar + provisionales + validaciones RN-06/RN-08/RN-12/RN-13 + trazabilidad RN-16)
- Notificaciones (RF-38 a RF-40 — internas + correo Nodemailer; tabla `notificaciones` confirmada)
- Ambientes (CRUD completo + bloqueo + listar bloqueos)
- Consultas (carga horaria, horarios por ficha, ocupacion de ambientes)
- Auditoria (bitacora con triggers automaticos + endpoint API)
- Catalogo (GET areas, programas, competencias, raps, jornadas, ambientes, tipos-novedad-instructor/ambiente/ficha)
- Programas (GET lista simple para dropdowns + asignacion de programas a lider)

*`ultimo_acceso` se actualiza en login pero NO se devuelve aun en GET /api/auth/usuarios — ver P21.

Reglas de negocio implementadas: RN-01 a RN-17 completas (RN-09 y RN-13 cerradas — confirmado en codigo).

## ARQUITECTURA BACKEND

Estructura: backend/ → config, controllers, services, models, middleware, routes, utils, constants, schemas
Flujo request: verifyToken → requireRole → Controller → permisoService → domainService → Model → DB
Controllers: solo HTTP, sin logica de negocio
Services: toda la logica de negocio, validaciones, reglas
Models: queries SQL puras con parameterized queries (mysql2 con placeholders ?)
Security: helmet, express-rate-limit, zod validation, audit logging

> **GAP CRITICO (P22 — verificado 30/06/2026):** GET /api/horarios, /fichas, /asignaciones y /alertas solo exigen verifyToken — devuelven el dataset completo del CDMC sin filtrar por rol. NO asumir que el backend ya filtra por rol en estos endpoints.

## ROLES DEL SISTEMA

5 roles exactos (snake_case en BD, Title Case solo en UI):
- subdirector — CDMC completo
- coordinador_medular — linea medular
- coordinador_transversal — linea transversal
- lider_programa — su programa especifico (tabla `lider_programa` en BD desde schema v4; expuesto en frontend desde 30/06/2026)
- instructor — solo lectura de sus asignaciones

lider_ficha NO es un rol. Es es_lider_ficha BOOLEAN en tabla asignacion.
No otorga permisos. No aparece en requireRole.

Autorizacion en dos capas:
- Middleware requireRole: roles globales (solo rutas de escritura)
- permisoService: acceso contextual por ficha/programa/linea

## ASIGNACIONES

Unidad: instructor → ficha → competencia
RAPs se heredan automaticamente al asignar competencia — NO se asignan uno a uno.

Validaciones obligatorias antes de INSERT:
1. instructor_competencias_habilitadas — competencia contratada (RN-13)
2. instructor.tipo_area == programa.tipo_area (omitir si es_provisional)
3. UNIQUE(instructor_id, ficha_id) en asignacion
4. UNIQUE(asignacion_id, competencia_id) en asignacion_competencia
5. RN-06 / RF-35: AsignacionModel.hasRapEnFicha — HTTP 409
6. RN-08: instructor sin novedad activa vigente
7. RN-12: alcance de lider/coordinador

## HORARIOS / CARGA

LIMITES_HORAS: de_planta { min:20, max:40 } — contratista { min:20, max:40 }

Alertas (soft — no bloquean INSERT):
- HORAS_EXCEDIDAS / HORAS_INSUFICIENTES / AMBIENTE_OCUPADO / ASIGNACION_PROVISIONAL / JORNADA_RESTRINGIDA

Reglas:
- RN-04: hard block superpuestos — HTTP 409 — revalidado en create() y update()
- RN-09: hard block ambiente bloqueado — revalidado en create() y update()
- RN-03 / RN-05: soft alerts — SOLO se calculan en create()
  > P23 (pendiente, alcance confirmado por Laura 30/06/2026): update() debe recalcularlas tambien
- Estados de horario: pendiente / aprobado / rechazado / suspendido

## NOTIFICACIONES (RF-38 a RF-40)

Endpoints confirmados en notificacion.routes.ts:
- GET /api/notificaciones — notificaciones del usuario autenticado segun JWT
- PATCH /api/notificaciones/:id/leida — marcar leida

## REGLAS DE NEGOCIO CLAVE

RN-01 a RN-17 todas implementadas (confirmado 30/06/2026).
Ver CONINS_contexto_general.md seccion 10 para tabla completa.

RF-37: cubierto parcialmente — update() solo revalida RN-04/RN-09; pendiente RN-03/RN-05 (P23, alcance confirmado).

## DATABASE

- Schema v5, 25 tablas — verificado 30/06/2026 por conteo directo (archivo dice "Schema: v5")
- Tablas: jornadas, roles, areas, usuarios, usuario_roles, instructores, programas, competencias, raps, ambientes, fichas, asignacion, asignacion_competencia, lider_programa, instructor_competencias_habilitadas, horarios, alertas, tipos_novedad_instructor, instructor_novedades, ambiente_bloqueos, tipos_novedad_ambiente, tipos_novedad_ficha, ficha_novedades, notificaciones, auditoria
- Soft delete universal: activo BOOLEAN NOT NULL DEFAULT TRUE
- Parameterized queries obligatorias

## PENDIENTES ACTIVOS

- P4: Lista oficial de instructores con correo estandarizado
- P8: Apellido co-lider Rivera / P9: Catalina / P10: Resoluciones
- P16: pruebas automatizadas / P17: xss-clean CSRF
- P21: agregar ultimo_acceso al SELECT/mapeo en usuario.model.ts (2 lineas)
- P22 (CRITICO): implementar filtrado por rol en GET /horarios, /fichas, /asignaciones, /alertas
- P23: completar update() en horario.service.ts para revalidar RN-03 y RN-05 (alcance confirmado por Laura)
- P25: alinear CONINS_Logica_Negocio_v5.md con conteo real (25 tablas, v5)

## OUTPUT

- Sin saludos, sin preambulos, sin cierres de cortesia
- Lenguaje tecnico directo — preferir diffs sobre archivos completos
- Mostrar plan → esperar aprobacion → ejecutar
- Sin emojis, sin em dashes, sin smart quotes

## HARD RULES

- Backend siempre es la autoridad — NO logica de negocio en frontend
- NO DELETE fisico — siempre activo = FALSE
- NO etiquetas UI hardcodeadas — usar terminology.ts
- NO modificar sin aprobacion / NO ignorar skills
- NO tratar es_lider_ficha como permiso
- NO asignar RAPs individualmente
- NO omitir trazabilidad al cambiar instructor en competencia activa
- NO asumir que GET /horarios, /fichas, /asignaciones, /alertas filtran por rol (P22 — no lo hacen)
