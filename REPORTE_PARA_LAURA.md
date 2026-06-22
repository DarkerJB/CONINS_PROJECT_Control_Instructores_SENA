# REPORTE PARA LAURA — Frontend
**Fecha:** 10/06/2026 (noche)
**De:** Jair (Backend)

---

## 1. CAMBIOS EN BACKEND QUE AFECTAN EL FRONTEND

### 1.1 Módulo Novedades de Instructores — CAMBIO BREAKING

**Antes:**
```json
POST /api/instructores/:id/novedades
{ "tipo_novedad": "licencia", "fecha_inicio": "...", ... }
```

**Ahora:**
```json
POST /api/instructores/:id/novedades
{ "tipo_novedad_id": 1, "fecha_inicio": "...", "fecha_regreso": "...", "observacion": "..." }
```

**Accion requerida:** El modal de novedades debe usar un dropdown con los tipos de novedad en vez de texto libre.

**Endpoint nuevo para obtener los tipos:**
```
GET /api/catalogo/tipos-novedad-instructor
→ [{ id: 1, nombre: "licencia", descripcion: "..." }, ...]
```

> **Nota:** El endpoint `GET /api/catalogo/tipos-novedad-instructor` aun no existe en el backend. Lo creo ahora o prefieres que usemos un array hardcodeado en el frontend por ahora?

### 1.2 Módulo Usuarios — NUEVOS CAMPOS

La tabla `usuarios` ahora tiene dos campos nuevos:
- `tipo_documento` — ENUM: `cc`, `ce`, `ti`, `pasaporte`
- `documento` — VARCHAR(20) UNIQUE

**Endpoints afectados:**
- `PUT /api/auth/usuarios/:id` — Ahora acepta `tipo_documento` y `documento` en el body
- `GET /api/auth/usuarios` — Ahora devuelve `tipo_documento` y `documento` en la respuesta

**Accion requerida:** Si el modal de crear/editar usuario existe, agregar los dos campos.

### 1.3 Nuevos endpoints de catalogo (pendiente de implementar)

| Metodo | Endpoint | Respuesta | Estado |
|---|---|---|---|
| GET | `/api/catalogo/tipos-novedad-instructor` | Array de tipos | ⬜ Pendiente |
| GET | `/api/catalogo/tipos-novedad-ambiente` | Array de tipos | ⬜ Pendiente |
| GET | `/api/catalogo/tipos-novedad-ficha` | Array de tipos | ⬜ Pendiente |

---

## 2. NUEVAS TABLAS EN LA DB (schema v5.1 → 25 tablas)

| Tabla | Proposito | Afecta frontend? |
|---|---|---|
| `tipos_novedad_instructor` | Catalogo de tipos de novedad para instructores | Si — dropdown en modal novedades |
| `tipos_novedad_ambiente` | Catalogo de tipos de novedad para ambientes | Si — dropdown en modal bloqueos |
| `tipos_novedad_ficha` | Catalogo de tipos de novedad para fichas | Si — pagina nueva de novedades fichas |
| `ficha_novedades` | Novedades de fichas (comites, paros, etc) | Si — nueva pagina/endpoint |

---

## 3. PENDIENTES PARA EL FRONTEND

| # | Tarea | Prioridad | Detalle |
|---|---|---|---|
| 1 | **Modal novedades → dropdown** | Alta | Cambiar input de texto por dropdown con `tipo_novedad_id` |
| 2 | **Modal usuarios → documento** | Media | Agregar campos `tipo_documento` (select) y `documento` (input) |
| 3 | **Pagina novedades de fichas** | Media | Nueva pagina para gestionar `ficha_novedades` (RF-47) |
| 4 | **Modal bloqueo ambientes → dropdown** | Baja | Cambiar input de texto por dropdown con `tipo_novedad_id` |
| 5 | **Importar DB** | Alta | Importar `database.sql` v5.1 en phpMyAdmin para validar |

---

## 4. NUEVOS REQUISITOS FUNCIONALES (RF v6.1 — 47 RF)

| RF | Descripcion | Afecta frontend? |
|---|---|---|
| **RF-46** | Registrar y consultar tipo/numero de documento de identidad de usuarios | Si — campos en modal usuarios |
| **RF-47** | Registrar novedad administrativa de fichas (comite, paro, actividad fuera) | Si — nueva pagina |

---

## 5. ESTADO ACTUAL DEL PROYECTO

| Componente | Estado |
|---|---|
| Backend | 9 modulos completos, 25 tablas, 47 RF |
| Frontend | 11 paginas, 18 componentes modulares |
| DB | Schema v5.1 — 25 tablas (pendiente importar) |
| Reglas de negocio | RN-01 a RN-17 implementadas |
| Repos | Pushed a `dev/Jair` y `main` de ConIns_Project |

---

## 6. PROXIMOS PASOS

1. **Jair:** Crear endpoints `GET /api/catalogo/tipos-novedad-*` (3 endpoints)
2. **Laura:** Importar `database.sql` v5.1 en phpMyAdmin
3. **Laura:** Adaptar modal de novedades para usar `tipo_novedad_id`
4. **Laura:** Agregar campos de documento en modal de usuarios
5. **Jair + Laura:** Crear pagina de novedades de fichas (RF-47)
