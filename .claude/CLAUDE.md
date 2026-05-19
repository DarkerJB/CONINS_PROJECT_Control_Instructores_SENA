# CONINS — AI GOVERNANCE

## CONTEXT

CONINS = Control de Instructores, CDMC-SENA, Itagui.
Gestion de carga academica de instructores. NO es gestor de notas (eso es Sofia Plus).

Documentos fuente de verdad (leer antes de cada tarea):
1. `D:\2_ConIns\ConIns_Documentacion_e_Insumos\ConIns_Contexto_General\CHANGELOG.md` — historial de cambios
2. `D:\2_ConIns\ConIns_Documentacion_e_Insumos\ConIns_Contexto_General\CONINS_contexto_general.md` — contexto completo del negocio
3. `D:\2_ConIns\ConIns_Documentacion_e_Insumos\ConIns_Contexto_General\CONINS_Requisitos_Funcionales_v6.txt` — 45 RF en 8 modulos
4. `D:\2_ConIns\ConIns_Documentacion_e_Insumos\ConIns_Contexto_General\CONINS_Logica_Negocio_v5.md` — reglas de negocio y arquitectura
5. `D:\2_ConIns\ConIns_Documentacion_e_Insumos\ConIns_Contexto_General\CRONOGRAMA.md` — fases, fechas y estados
6. `D:\2_ConIns\ConIns_Documentacion_e_Insumos\ConIns_Contexto_General\SENA_identidad_visual_resumen_tecnico.md` — paleta y tipografia SENA

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
Correo: Nodemailer
BD: MySQL — conIns (schema v4, 20 tablas)

## ARQUITECTURA BACKEND

Estructura: backend/ → config, controllers, services, models, middleware, routes, utils, constants, schemas
Flujo request: verifyToken → requireRole → Controller → permisoService → domainService → Model → DB
Controllers: solo HTTP, sin logica de negocio
Services: toda la logica de negocio, validaciones, reglas
Models: queries SQL puras con parameterized queries (mysql2 con placeholders ?)
Security: helmet, express-rate-limit, zod validation, xss-clean, audit logging

## ROLES DEL SISTEMA

5 roles exactos (snake_case en BD, Title Case solo en UI):
- subdirector — CDMC completo
- coordinador_medular — linea medular (calzado, marroquineria, curticion)
- coordinador_transversal — linea transversal (ADSO, bilinguismo, diseño, gestion)
- lider_programa — su programa especifico
- instructor — solo lectura de sus asignaciones

lider_ficha NO es un rol. Es es_lider_ficha BOOLEAN en tabla asignacion.
No otorga permisos. No aparece en requireRole.

Dos ejes independientes — NO mezclar:
- programas.tipo_linea: medular | transversal (clasificacion administrativa del centro)
- instructores.tipo_area: tecnica | transversal (clasificacion pedagogica del instructor)

Autorizacion en dos capas:
- Middleware requireRole: roles globales unicamente
- permisoService: acceso contextual por ficha/programa/linea

## ASIGNACIONES

Unidad: instructor → ficha → competencia
RAPs se heredan automaticamente al asignar competencia — NO se asignan uno a uno.

Validaciones obligatorias antes de INSERT:
1. instructor_competencias_habilitadas — competencia contratada
2. instructor.tipo_area == programa.tipo_area (omitir si es_provisional)
3. UNIQUE(instructor_id, ficha_id) en asignacion
4. UNIQUE(asignacion_id, competencia_id) en asignacion_competencia
5. RN-06: validar que ningun RAP de la nueva competencia se solape con otro instructor en la misma ficha

Ambiente efectivo = asignacion_competencia.ambiente_excepcion_id ?? ficha.ambiente_id

## HORARIOS / CARGA

LIMITES_HORAS (confirmados 04/05/2026):
- de_planta:   { min: 20, max: 40 }
- contratista: { min: 20, max: 40 }

Alertas (todas soft — no bloquean INSERT):
- HORAS_EXCEDIDAS — carga > maximo
- HORAS_INSUFICIENTES — carga < minimo
- AMBIENTE_OCUPADO — ambiente ya ocupado en misma jornada
- ASIGNACION_PROVISIONAL — instructor fuera de su area
- INSTRUCTOR_PLANTA_JORNADA_NOCTURNA — planta en nocturna o fin de semana

Reglas:
- Calculo dinamico en horarioService — nunca en frontend
- Recalcular al crear y al deshabilitar bloques
- Jornada virtual no valida ambiente fisico
- RN-04: hard block si instructor tiene horarios superpuestos (HTTP 409)
- RN-05: soft alert si ambiente ya ocupado

## REGLAS DE NEGOCIO CLAVE

- RN-01: Onboarding dos pasos — sin password = HTTP 403
- RN-02: Correo como identificador unico — sin restriccion de dominio
- RN-06: Unicidad RAP por ficha — validacion en service, no constraint BD
- RN-08: Novedad administrativa excluye instructor — reincorporacion automatica
- RN-09: Bloqueo de ambiente excluye ambiente — reincorporacion automatica
- RN-10: Soft delete universal — activo = FALSE, nunca DELETE fisico
- RN-11: Provisional requiere autorizante, fecha, motivo
- RN-12: Lider solo asigna en sus programas
- RN-13: Competencia habilitada por contrato
- RN-14: Fichas virtuales sin ambiente fisico
- RN-15: RAPs heredados al asignar competencia

## DATABASE

- Schema v4, 20 tablas, cerrado 04/05/2026
- BD es fuente de verdad
- No modificar seed automaticamente
- Todas las tablas tienen activo BOOLEAN NOT NULL DEFAULT TRUE
- Queries de listado filtran WHERE activo = TRUE
- Parameterized queries obligatorias — nunca string concatenation

## PENDIENTES ACTIVOS

- P4: Lista oficial de instructores con correo estandarizado (bloquea seed)
- P8: Apellido co-lider Rivera (Tecnico Medular)
- P9: Apellido Catalina (lider Talento Humano)
- P10: Revisar Resolucion 1415/2012 y Acuerdo 0003/2017

## OUTPUT

- Sin saludos, sin preambulos, sin cierres de cortesia
- Lenguaje tecnico directo
- Preferir diffs sobre archivos completos
- Mostrar plan → esperar aprobacion → ejecutar
- Sin emojis, sin em dashes, sin smart quotes
- Conciso en salida, exhaustivo en razonamiento

## HARD RULES

- Backend siempre es la autoridad
- Frontend NO define logica de negocio ni calcula horas
- NO confiar en datos del cliente sin validar en backend
- NO logica duplicada entre capas
- NO DELETE fisico — siempre activo = FALSE
- NO etiquetas UI hardcodeadas ("ficha") — usar ETIQUETAS.FICHA
- NO modificar sin aprobacion
- NO ignorar skills
- NO asumir logica inexistente
- NO implementar areas bloqueadas
- NO tratar es_lider_ficha como permiso
- NO asignar RAPs individualmente
- NO omitir trazabilidad al cambiar instructor en competencia activa
