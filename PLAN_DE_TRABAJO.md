# PLAN DE TRABAJO — CONINS
**Fecha:** 03 de Junio 2026
**Autor:** Jair Enrique Gonzalez Buelvas
**Revisado con:** Instructor técnico nuevo

---

## FASE 1 — BASE DE DATOS (MySQL actual)
**Tiempo estimado:** 3-5 días
**Dependencias:** Ninguna

### 1.1 Bitácora de auditoría (Alta prioridad)
- [ ] Crear tabla `auditoria` en `database.sql`
  - Columnas: id, usuario_id, accion (INSERT/UPDATE/DELETE), tabla_afectada, registro_id, datos_anteriores (JSON), datos_nuevos (JSON), ip, fecha
- [ ] Trigger `tr_instructores_audit` — INSERT/UPDATE/DELETE en `instructores`
- [ ] Trigger `tr_asignacion_audit` — INSERT/UPDATE/DELETE en `asignacion`
- [ ] Trigger `tr_horarios_audit` — INSERT/UPDATE/DELETE en `horarios`
- [ ] Trigger `tr_usuarios_audit` — INSERT/UPDATE/DELETE en `usuarios`
- [ ] Trigger `tr_fichas_audit` — INSERT/UPDATE/DELETE en `fichas`
- [ ] Trigger `tr_ambientes_audit` — INSERT/UPDATE/DELETE en `ambientes`
- [ ] Endpoint `GET /api/auditoria` — Consultar bitácora (solo admin/coordinador)

### 1.2 Triggers de validación (Alta prioridad)
- [ ] Trigger `tr_validar_solapamiento` — Antes de INSERT/UPDATE en `horarios`, verificar que no haya cruce de horarios para el mismo instructor
- [ ] Trigger `tr_validar_ambiente_ocupado` — Antes de INSERT/UPDATE en `horarios`, verificar que el ambiente no esté ocupado en misma jornada/día
- [ ] Trigger `tr_validar_carga_horaria` — Después de INSERT/UPDATE en `horarios`, alertar si instructor supera 40h semanales

### 1.3 Procedimientos almacenados (Media prioridad)
- [ ] `sp_crear_instructor()` — Crea usuario + instructor en una transacción
- [ ] `sp_asignar_competencias()` — Asigna múltiples competencias a una asignación
- [ ] `sp_registrar_novedad()` — Registra novedad + desactiva horarios temporalmente
- [ ] `sp_desactivar_asignacion()` — Desactiva asignación + competencias + registra trazabilidad
- [ ] `sp_finalizar_ficha()` — Finaliza ficha + desactiva asignaciones + registra fecha

### 1.4 Vistas (Media prioridad)
- [ ] `vw_carga_horaria_instructor` — Horas semanales por instructor con detalle
- [ ] `vw_ambientes_ocupados` — Ambientes con horarios activos por jornada/día
- [ ] `vw_asignaciones_activas` — Asignaciones activas con instructor, ficha, competencias
- [ ] `vw_instructores_con_novedad` — Instructores con novedad administrativa vigente
- [ ] `vw_alertas_pendientes` — Alertas no atendidas con prioridad

### 1.5 Backup/Restore (Alta prioridad)
- [ ] Script `scripts/db-backup.sh` — Genera `backup_YYYY-MM-DD.sql` con mysqldump
- [ ] Script `scripts/db-restore.sh` — Resta desde un .sql
- [ ] Agregar a `package.json`: `db:backup`, `db:restore`
- [ ] Configurar backup automático (cron o GitHub Actions scheduled)

---

## FASE 2 — BACKEND PENDIENTES (Laura)
**Tiempo estimado:** 2-3 días
**Dependencias:** Fase 1.1 (tabla auditoria)

- [ ] `POST /api/ambientes` — Crear ambiente
- [ ] `PUT /api/ambientes/:id` — Editar ambiente
- [ ] `POST /api/ambientes/:id/bloquear` — Registrar bloqueo
- [ ] `GET /api/asignaciones/historicas` — Asignaciones con activo=FALSE
- [ ] Middleware de auditoría API — Loguear requests (endpoint, método, usuario, IP, resultado)

---

## FASE 3 — FRONTEND MERGES
**Tiempo estimado:** 1-2 días
**Dependencias:** Fase 2

- [ ] Merge `api.ts` de Laura (140 líneas extra de endpoints)
- [ ] Merge páginas `ambientes.tsx`, `alertas.tsx`
- [ ] Merge componentes `ambientes/*` (4 modales)
- [ ] Merge `types/auth.ts`
- [ ] Merge `DashboardLayout.tsx` con alertasViewed

---

## FASE 4 — CONTINUOUS INTEGRATION
**Tiempo estimado:** 1-2 días
**Dependencias:** Ninguna (paralelizable con Fase 1)

- [ ] GitHub Actions workflow:
  - [ ] Lint (ESLint)
  - [ ] Typecheck (tsc --noEmit)
  - [ ] Build (npm run build)
  - [ ] Tests unitarios (si existen)
- [ ] Workflow de PR: requiere CI passing antes de merge
- [ ] Branch protection rules en `main`

---

## FASE 5 — DOCKER
**Tiempo estimado:** 2-3 días
**Dependencias:** Fase 1.5 (backup/restore funcionando)

- [ ] `Dockerfile` backend (Node.js Alpine)
- [ ] `Dockerfile` frontend (Next.js standalone)
- [ ] `docker-compose.yml` — Backend + Frontend + MySQL
- [ ] `.dockerignore` para ambos
- [ ] Variables de entorno via `.env` en compose
- [ ] Volume persistente para datos de MySQL
- [ ] Script `docker-compose up --build` funcional

---

## FASE 6 — MIGRACIÓN A POSTGRESQL
**Tiempo estimado:** 5-7 días
**Dependencias:** Fase 5 (Docker), Fase 1.1-1.5 (triggers/procs/vistas migrados)

- [ ] Cambiar `mysql2` a `pg` o `postgres.js` en `package.json`
- [ ] Reescribir `config/db.ts` para PostgreSQL
- [ ] Migrar `database.sql` a sintaxis PostgreSQL
  - `INT` → `INTEGER`
  - `BOOLEAN` → `BOOLEAN` (compatible)
  - `DATETIME` → `TIMESTAMP`
  - `AUTO_INCREMENT` → `SERIAL` o `GENERATED ALWAYS AS IDENTITY`
  - `VARCHAR` → `VARCHAR` (compatible)
  - `ENUM` → `CREATE TYPE ... AS ENUM`
- [ ] Migrar triggers a PL/pgSQL
- [ ] Migrar procedimientos a funciones PL/pgSQL
- [ ] Migrar vistas (sintaxis compatible en su mayoría)
- [ ] Actualizar todos los models que usen sintaxis MySQL específica
- [ ] Testear todos los endpoints con PostgreSQL
- [ ] Actualizar `docker-compose.yml` para usar PostgreSQL

---

## FASE 7 — USO DE DB DESDE CONSOLA
**Tiempo estimado:** 1 día
**Dependencias:** Fase 1.5, Fase 5

- [ ] Script `scripts/db-shell.sh` — Conectar a MySQL/PostgreSQL desde consola
- [ ] Script `scripts/db-seed.sh` — Ejecutar seed_data.sql
- [ ] Documentación de comandos útiles:
  - `SHOW TABLES` / `\dt`
  - `DESCRIBE tabla` / `\d tabla`
  - `SELECT COUNT(*) FROM tabla`
  - Backup/restore desde consola

---

## FASE 8 — COORDINACIÓN CON INSTRUCTOR TÉCNICO
**Continuo**

- [ ] Crear tablero en Trello con columnas: Backlog, En Progreso, En Revisión, Completado
- [ ] Mover cada tarea de este plan a Trello como tarjeta
- [ ] Asignar responsables y fechas límite
- [ ] Revisión semanal de avances

---

## RESUMEN DE FASES

| Fase | Descripción | Tiempo | Dependencias |
|---|---|---|---|
| 1 | DB: Auditoría, triggers, procedures, vistas, backup | 3-5 días | Ninguna |
| 2 | Backend pendientes de Laura | 2-3 días | Fase 1.1 |
| 3 | Frontend merges | 1-2 días | Fase 2 |
| 4 | Continuous Integration | 1-2 días | Ninguna (paralelo) |
| 5 | Docker | 2-3 días | Fase 1.5 |
| 6 | Migración PostgreSQL | 5-7 días | Fases 1, 5 |
| 7 | DB desde consola | 1 día | Fases 1.5, 5 |
| 8 | Coordinación Trello | Continuo | Ninguna |

**Tiempo total estimado:** 15-23 días hábiles

---

*CONINS · SENA CDMC · Plan de Trabajo · 03 de Junio 2026*
