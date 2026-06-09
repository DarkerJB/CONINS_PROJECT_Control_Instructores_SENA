# RESUMEN DE CAMBIOS PARA LAURA
**Fecha:** 09/06/2026 (noche)
**De:** Jair (Backend)
**Para:** Laura (Frontend)

---

## NUEVOS ENDPOINTS IMPLEMENTADOS

### Ambientes (RF-31)
| Metodo | Endpoint | Body | Descripcion |
|---|---|---|---|
| POST | `/api/ambientes` | `{ nombre, tipo, capacidad, area_id }` | Crear ambiente |
| PUT | `/api/ambientes/:id` | `{ nombre, tipo, capacidad, area_id, activo }` | Editar ambiente |
| POST | `/api/ambientes/:id/bloquear` | `{ fecha_inicio, fecha_fin, motivo }` | Registrar bloqueo |
| GET | `/api/ambientes/:id/bloqueos` | — | Listar bloqueos de un ambiente |

### Asignaciones (RF-42)
| Metodo | Endpoint | Descripcion |
|---|---|---|
| GET | `/api/asignaciones/historicas` | Asignaciones con `activo = FALSE` |

### Horarios (RF-22)
| Metodo | Endpoint | Body | Descripcion |
|---|---|---|---|
| PUT | `/api/horarios/:id` | `{ dia_ids: [1,3,5], hora_inicio, hora_fin, jornada_id, ambiente_id }` | Edicion de dias multiples |

### Consultas/Reportes (RF-41 a RF-45)
| Metodo | Endpoint | Descripcion |
|---|---|---|
| GET | `/api/consultas/carga-horaria` | Carga por instructor (total_horas, fichas_count, competencias_count, estado) |
| GET | `/api/consultas/horarios-ficha` | Horario semanal por ficha (lunes a sabado) |
| GET | `/api/consultas/ocupacion-ambientes` | % uso de cada ambiente |

### Auditoria
| Metodo | Endpoint | Descripcion |
|---|---|---|
| GET | `/api/auditoria` | Bitacora de auditoria con filtros (?tabla, ?usuario_id, ?accion, ?desde, ?hasta) |
| GET | `/api/auditoria/:tabla/:id` | Historial de un registro especifico |

---

## REGLAS DE NEGOCIO NUEVAS (IMPORTANTE PARA EL FRONTEND)

### RN-09 — Bloqueo de ambiente
Si intentas crear un horario en un ambiente que tiene un bloqueo temporal vigente, el backend devuelve:
```json
{ "success": false, "message": "El ambiente tiene un bloqueo temporal vigente en esa semana (RN-09)" }
```
**Status:** 400 Bad Request

### RN-13 — Competencia habilitada
Si intentas asignar una competencia a un instructor que no la tiene en `instructor_competencias_habilitadas`, el backend devuelve:
```json
{ "success": false, "message": "El instructor no tiene habilitada esta competencia segun su contrato (RN-13)" }
```
**Status:** 400 Bad Request

---

## FORMATO DE RESPUESTA
Todos los endpoints devuelven:
```json
{ "success": true, "message": "...", "data": [...] }
```

En caso de error:
```json
{ "success": false, "message": "Descripcion del error" }
```

---

## NOTAS TECNICAS
- Soft delete usa `activo = false`, nunca DELETE fisico
- Dias: 1=Lun, 2=Mar, 3=Mie, 4=Jue, 5=Vie, 6=Sab
- Jornadas: 1=Manana, 2=Mixta, 3=Noche, 4=Virtual
- Todos los endpoints requieren token JWT en header `Authorization: Bearer <token>`
- Los endpoints POST/PUT/DELETE requieren rol: Subdirector, Coordinador Medular o Coordinador Transversal
