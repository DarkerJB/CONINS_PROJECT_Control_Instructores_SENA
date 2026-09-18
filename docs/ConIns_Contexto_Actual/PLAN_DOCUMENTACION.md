# CONINS — Plan de Documentación Completa (F5)
**Centro del Diseño y Manufactura del Cuero (CDMC) — SENA**
**Versión:** 1.0 · **Fecha:** 18/09/2026 · **Responsables:** Jair (backend/BD/análisis) · Laura (frontend/diseño)

Este documento organiza la **documentación completa** que se producirá en la Fase 5, indicando
para cada entregable su estado, el responsable y las **fuentes ya existentes** que se reutilizan
(para no partir de cero). Sirve como índice maestro de la entrega documental.

---

## 1. Estado de la documentación

Convención: ✅ listo · 🔄 en curso · ⬜ pendiente · ♻️ existe base reutilizable (requiere consolidar/actualizar)

| # | Entregable | Estado | Fuente base existente | Responsable |
|---|---|---|---|---|
| D1 | **ERS** (Especificación de Requisitos de Software, IEEE 830 / estándar SENA) | ♻️ 🔄 | RF v10.3 (64 RF) + RNF v1.1 + Lógica de Negocio v5.7 + contexto general | Jair |
| D2 | **Manual de usuario** (por rol: Subdirector, Coordinación, Asistente, Instructor) | ⬜ | Frontend actual + flujos de RF v10.3 | Laura + Jair |
| D3 | **Manual técnico / de instalación y despliegue** (intranet CDMC) | ♻️ 🔄 | `Servidor/CONINS_Descripcion_y_Requerimientos_Servidor` + README + `.env.example` + `db:setup/db:reset` | Jair |
| D4 | **Diccionario de datos** (35 tablas) | ♻️ | `D:\2_ConIns\Entrega_Lider_IA\CONINS_Diccionario_de_Datos.md` (actualizar a 35 tablas) | Jair |
| D5 | **Modelo de datos** (MER / diagrama entidad-relación) | ⬜ | `database.sql` (fuente de verdad) | Jair |
| D6 | **Manual de la API** (endpoints, contratos, códigos de error) | ⬜ | `routes/` + schemas Zod + reportes a Laura | Jair |
| D7 | **Diagramas** (arquitectura, casos de uso, flujos principales) | ⬜ | Lógica de Negocio v5.7 (flujos) + contexto general | Jair + Laura |
| D8 | **Plan e informe de pruebas** (por módulo, con criterios de aceptación) | ♻️ | Simulacros con datos reales ADSO (F4) + `REVISION_SEGURIDAD.md` | Jair + Laura |
| D9 | **Manual de administración** (respaldos, usuario Administrador, operación) | ⬜ | contexto general + requerimientos de servidor | Jair |
| D10 | **Acta de entrega y socialización** (GFPI + firmas) | ⬜ | Formatos SENA (GFPI-F-023, GFPI-F-147) | Jair + Laura |
| D11 | **Guía de identidad visual aplicada** | ✅ ♻️ | `SENA_identidad_visual_resumen_tecnico.md` | Laura |

---

## 2. Fuentes de verdad (insumos ya consolidados)

Estos documentos del repo son la materia prima; la documentación completa los **consolida y da
formato de entrega**, no los reescribe:

- **Requisitos funcionales:** `CONINS_Requisitos_Funcionales_v10_2.txt` (interno v10.3, 64 RF, 12 módulos).
- **Requisitos no funcionales:** `CONINS_Requisitos_No_Funcionales_v1_1.txt` (24 RNF, 8 categorías).
- **Reglas de negocio:** `CONINS_Logica_Negocio_v5_7.txt` (RN-01 a RN-35, rev 18/09/2026).
- **Contexto general:** `CONINS_contexto_general.md` (v9.10) — estado, arquitectura, schema 35 tablas.
- **Cronograma:** `CRONOGRAMA.md` (v4.9).
- **Historial de cambios:** `CHANGELOG.md` (al 18/09/2026).
- **Esquema BD (fuente de verdad):** `backend/database.sql` (35 tablas).
- **Despliegue:** `D:\2_ConIns\Servidor\CONINS_Descripcion_y_Requerimientos_Servidor` (.md/.docx/.pdf).
- **Identidad visual:** `SENA_identidad_visual_resumen_tecnico.md`.

---

## 3. Estructura propuesta de la ERS (D1)

1. Introducción — propósito, alcance, definiciones/acrónimos, referencias.
2. Descripción general — perspectiva y funciones del producto, usuarios y roles, restricciones,
   supuestos y dependencias (no reemplaza Sofía Plus).
3. Requisitos específicos — funcionales (los 64 RF por módulo), no funcionales (24 RNF),
   reglas de negocio (RN-01 a RN-35), interfaces (usuario, hardware, software, comunicaciones).
4. Modelo de datos — MER + diccionario de datos (referencia a D4/D5).
5. Requisitos de despliegue — intranet CDMC (referencia a D3).
6. Anexos — matriz de trazabilidad RF ↔ RN ↔ endpoint, glosario SENA.

---

## 4. Pendientes de contenido antes de cerrar la documentación

- **D4 (diccionario):** actualizar de 33 → 35 tablas y las columnas nuevas
  (`instructores.tipo_vinculacion`; `horarios.programa_id/modalidad/observaciones`).
- **R3 backend:** calendario parametrizable debe incluir formación complementaria (afecta D6).
- **R3 frontend (Laura):** pantallas de complementaria y filtros (afecta D2).
- **Datos de despliegue reales:** nombre en DNS interno / IP y tipo de certificado (los define TI).
- **Unificación de repos** a `DarkerJB/CONINS_PROJECT` antes de congelar la documentación técnica.

---

*Este índice se actualiza a medida que avanza la Fase 5. Cada entregable, al completarse, se marca
✅ y se enlaza desde aquí.*
