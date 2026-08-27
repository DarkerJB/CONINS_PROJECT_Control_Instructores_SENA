# Migración — Administrador: de virtual (.env) a usuario real de la BD

**Fecha:** 26/08/2026 · **Backend:** Jair
**Motivo:** el Administrador se entregará al centro (persona de soporte del sistema). Debe ser un usuario gestionable, no un usuario virtual del `.env`.

---

## Qué cambió

Antes: el Administrador era **virtual** — vivía solo en el `.env` (`SUPER_USER` / `SUPER_USER_PASSWORD` en texto plano), con `id: 0`, sin fila en `usuarios`. No se podía editar desde la app, no recibía notificaciones, y la clave se cambiaba a mano en el `.env`.

Ahora: el Administrador es un **usuario real de la BD**:

- Rol nuevo en `roles`: `(5, 'Administrador', 0)` — nivel 0, por encima de Subdirector.
- Usuario bootstrap en `database.sql`: `id 1`, `admin@conins.sena`, clave **`ConinsAdmin2026*`** (bcrypt), rol Administrador.
- Login reordenado: **el usuario real de la BD tiene prioridad**. El `.env` (`SUPER_USER`) queda solo como **break-glass de emergencia**: el login lo usa únicamente si NO existe un usuario con ese correo en la BD (es decir, queda dormido mientras exista el admin real).

Beneficios: se edita desde la UI, recibe notificaciones, clave con bcrypt que la persona de soporte define, integridad de FK completa, y el `id 0` mágico queda relegado solo al acceso de emergencia.

---

## Qué tienes que hacer

1. **Recargar la BD** (drop + `database.sql` + `seed_data.sql`) para que se cree el rol 5 y el usuario admin.
2. **Entrar con las credenciales nuevas:** `admin@conins.sena` / `ConinsAdmin2026*`.
   - Ojo: tu login anterior de admin usaba la clave del `.env`. Ahora usa la de la BD (`ConinsAdmin2026*`). El del `.env` solo funcionaría si borras el usuario real.
3. **En el handover al centro:** la persona de soporte cambia correo y clave desde la app (o por "recuperar contraseña"). Ahí puedes vaciar/eliminar `SUPER_USER` del `.env` de producción.

---

## Archivos tocados

- `backend/database.sql` — rol Administrador (5) + usuario bootstrap (id 1) + usuario_roles.
- `backend/services/auth.service.ts` — login DB-first; `.env` como break-glass.
- `backend/.env.example` — comentario aclarando el rol de emergencia.
- Verificado: `tsc` limpio; bcrypt de la clave OK; `RolModel` devuelve `['Administrador']` para el JWT; `requireRole` sigue dando bypass al rol Administrador.

---

## Pendiente manual (no pude tocarlo)

- **`.claude/CLAUDE.md`** está protegido. Actualiza la sección ROLES: ahora son **5 roles** (agregar `Administrador — soporte, control total, nivel 0`) y anota que dejó de ser virtual (usuario real id 1, rol 5, break-glass en `.env`). También `ROLES_ADMIN` en el código ya incluye Administrador.

## Nota para Laura (frontend)

No requiere cambios para funcionar (el login es igual). Opcional a futuro: como ahora el Administrador es un usuario real, aparecerá en la gestión de usuarios y podrá editarse; si quieres, se puede permitir cambiar su correo/clave desde ahí.
