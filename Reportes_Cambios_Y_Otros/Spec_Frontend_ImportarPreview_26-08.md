# Spec Frontend — Importar con normalización y revisión

**De:** Jair (backend) · **Para:** Laura (frontend)
**Pantalla:** `Importar datos` (`importar.tsx`)
**Objetivo:** que el usuario suba el Excel **crudo del líder** (tal cual lo entrega), el sistema lo normalice y muestre una **previsualización** con lo que entendió, y solo escriba en la BD cuando el usuario confirme.

> Backend ya está listo y commiteado (`8aa01bd`). Esto es solo el frontend. Yo no toco `importar.tsx`; te dejo el contrato y el flujo.

---

## Flujo de 2 pasos

1. **Subir**: el usuario elige el archivo (crudo del líder o template) y selecciona el **programa** al que pertenece la planeación (ej. ADSO — 228118). Se llama a `POST /api/importar/preview`. **No escribe nada.**
2. **Revisar**: se muestra la previsualización en 4 bloques (abajo). Si el usuario aprueba, se llama a `POST /api/importar` con el template que devolvió el preview + los ambientes nuevos aprobados. **Ahí sí escribe.**

El selector de programa es obligatorio cuando el archivo es crudo. Si el usuario sube directamente el template de 4 hojas, el backend lo detecta y el programa no hace falta (el preview igual funciona).

---

## Endpoint 1 — Preview (no escribe)

`POST /api/importar/preview`  (requiere rol admin; ya protegido)

Request:
```json
{
  "archivo_base64": "<xlsx en base64>",
  "programa_codigo": "228118"
}
```

Response (`data`):
```json
{
  "formato": "crudo",
  "resumen": { "instructores": 13, "grupos": 7, "asignaciones": 31, "horarios": 128 },
  "nuevos": {
    "ambientes": ["Ambiente 200", "Ambiente 202"],
    "instructores": [
      { "nombre": "Pedro Perez", "email_sugerido": "pperez@sena.edu.co", "tipo_area": "tecnica" }
    ]
  },
  "errores": [
    { "hoja": "Transversales", "fila": 12, "entidad": "competencia", "valor": "Texto...", "motivo": "competencia sin coincidencia en catalogo (Sofia Plus)" }
  ],
  "posible_baja": {
    "asignaciones": [ { "instructor_email": "x@sena.edu.co", "numero_grupo": "3146109" } ]
  },
  "plantilla_base64": "<template de 4 hojas, en base64>"
}
```

Guarda `plantilla_base64` en el estado del componente — se reenvía en el paso 2.

---

## Endpoint 2 — Confirmar (escribe)

`POST /api/importar`  (igual que hoy, con un campo nuevo opcional)

Request:
```json
{
  "archivo_base64": "<el plantilla_base64 que devolvio el preview>",
  "crear_ambientes": ["Ambiente 200", "Ambiente 202"]
}
```

`crear_ambientes` = los nombres de ambientes nuevos que el usuario **aprobó** en el bloque "nuevos". El backend los crea antes de cargar. Si el usuario no aprueba alguno, no lo mandes: las filas con ese ambiente saldrán como error en el resumen (esperado).

Response: igual que hoy — `resumen` por hoja con `creados` y `errores[]` (fila + mensaje). Muéstralo como ya lo haces.

---

## Los 4 bloques de la previsualización

1. **Se creará automáticamente** — `resumen`: X grupos, Y asignaciones, Z horarios, N instructores. Es lo que entró bien.
2. **Nuevos — requieren aprobación** — `nuevos.ambientes` y `nuevos.instructores`. Cada uno con un checkbox "Crear". Los ambientes marcados van en `crear_ambientes`. Los instructores nuevos se crean solos al importar (via su email sugerido, que ya viene en el template); basta mostrarlos para que el usuario sepa que se darán de alta. Ideal: dejar editar el `email_sugerido` antes de confirmar (fase 2 si no da tiempo).
3. **Errores — corregir** — `errores[]`: tabla con hoja, fila, entidad, valor, motivo. Competencias/RAPs que no existen NO se inventan (son autoridad de Sofía Plus): el usuario corrige el Excel o carga primero el catálogo. Estas filas simplemente no se cargan.
4. **Posible baja — confirmar** — `posible_baja.asignaciones`: cosas que YA existen en el sistema (para los grupos de este archivo) y **no** aparecen en la planeación nueva. Por ahora es **solo informativo** (el backend no las da de baja todavía; eso es fase 2). Muéstralo como aviso: "estas asignaciones ya no aparecen — revisar".

Botón **"Cargar"** habilitado solo tras el preview. Al hacer clic → Endpoint 2 → mostrar el resumen final.

---

## Notas

- El backend detecta crudo vs template solo por los nombres de hoja, no te preocupes por eso.
- `formato` en la respuesta te dice cuál fue (`"crudo"` o `"template"`), por si quieres mostrarlo.
- El límite de subida ya está en 15mb para `/api/importar/*`.
- Pendiente de mi lado (fase 2, no bloquea la demo): aplicar la baja real (soft-delete) cuando el usuario confirme el bloque 4, y permitir editar el email del instructor nuevo antes de crear.
