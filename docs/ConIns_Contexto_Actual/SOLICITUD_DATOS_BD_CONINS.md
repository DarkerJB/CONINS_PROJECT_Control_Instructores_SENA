# Solicitud de datos para la base de datos — CONINS

**Para:** Luis Eladio Porras Camargo — Instructor líder técnico CDMC
**De:** Jair Enrique González Buelvas — Aprendiz backend / BD
**Fecha:** 24 de julio de 2026
**Asunto:** Datos reales necesarios para poblar la base de datos de CONINS

---

## Contexto breve

CONINS ya tiene el backend y el frontend funcionando con datos de prueba y con
la ficha ADSO 228118 (2995403) que sirvió de piloto. Para dejar el sistema listo
con información real del CDMC, necesitamos consolidar los datos de siete grupos
de información. Este documento lista **exactamente qué campos** requiere cada uno,
para que la entrega sea completa en una sola vuelta.

**Formato ideal de entrega:** un archivo Excel/CSV por cada sección (una hoja o
archivo por entidad), o los reportes oficiales de Sofía Plus donde ya vengan esos
campos. Si algo no aplica o no se tiene, marcarlo como "N/A" en vez de dejarlo en
blanco.

---

## 1. Reporte de Juicios Evaluativos (FUENTE PRINCIPAL — prioridad alta)

Es el insumo más importante. De ahí salimos con **competencias y RAPs reales**
por programa, igual que hicimos con la ficha 2995403 de ADSO.

**Qué pedimos:** un Reporte de Juicios Evaluativos por cada **programa/ficha
activa** que deba entrar al sistema.

**Campos que ese reporte debe permitirnos extraer:**

| Dato | Detalle |
|---|---|
| Programa | Código y nombre oficial |
| Ficha (grupo) | Número |
| Competencias | Código y nombre de cada competencia del programa |
| RAPs | Código y nombre/descripción de cada RAP, y a qué competencia pertenece |

> Nota: en el modelo actual cada RAP se asigna explícitamente a un instructor,
> por eso necesitamos el listado completo de RAPs con su código y a qué
> competencia pertenecen.

---

## 2. Lista completa de instructores (prioridad alta — cierra P4, P8, P9)

**Campos por instructor:**

| Campo | Formato / valores |
|---|---|
| Nombre completo | Nombres y apellidos |
| Correo | Institucional @sena.edu.co (identificador de acceso) |
| Tipo de documento | CC, CE, etc. |
| Número de documento | — |
| Tipo de área | **técnica**, **transversal** o **ambas** |
| Área / línea | ADSO, Bilingüismo, Talento Humano, Técnico Medular, etc. |
| Competencias que puede impartir | Lista de competencias habilitadas (por código o nombre) |
| ¿Es líder/referente de algún programa? | Sí/No y de cuál |

**Pendientes puntuales que se cierran aquí:**
- Apellido completo del co-líder **Rivera** (Técnico Medular).
- Apellido completo de **Catalina** (líder de Talento Humano).
- Instructores de la **línea medular (Calzado/Cuero)** que aún no están cargados.

---

## 3. Lista de programas de formación (prioridad media)

**Campos por programa:**

| Campo | Valores posibles |
|---|---|
| Código | Código oficial SENA (ej. 228118) |
| Nombre | Nombre oficial |
| Nivel | técnico / tecnólogo / curso especial |
| Línea | medular / transversal |
| Tipo de área | técnica / transversal |
| Tipo de formación | titulada / complementaria / operario |
| Modalidad | presencial / virtual / a distancia |
| Área a la que pertenece | ADSO, Diseño, Calzado, etc. |

---

## 4. Lista de fichas / grupos (prioridad media)

**Campos por ficha (grupo):**

| Campo | Detalle |
|---|---|
| Número de ficha | — |
| Programa | Al que pertenece |
| Jornada | mañana / mixta / noche / virtual |
| Ambiente por defecto | Aula o taller asignado |
| Instructor líder/referente | Quién responde por el grupo |
| Etapa actual | lectiva / productiva |
| Fecha inicio y fin — etapa lectiva | — |
| Fecha inicio y fin — etapa productiva | — |

---

## 5. Lista de ambientes y talleres (prioridad media)

**Campos por ambiente:**

| Campo | Valores |
|---|---|
| Nombre / identificador | Ej. Aula 205, Taller T2 |
| Tipo | aula / taller / laboratorio |
| Capacidad máxima | Número de personas |
| Área | Área a la que pertenece (o "compartido") |

> Hoy tenemos como referencia: Aulas 200 a 208 y Talleres T1 a T4. Necesitamos
> confirmar la lista real, sus capacidades y si hay laboratorios.

---

## 6. Áreas y líneas del centro (prioridad baja — confirmación)

**Campos por área:**

| Campo | Detalle |
|---|---|
| Nombre del área | ADSO, Bilingüismo, Talento Humano, Técnico Medular, etc. |
| Subtipo | Opcional (ej. "Técnico Operario Medular") |
| Línea | medular / transversal |

---

## 7. Catálogos a confirmar (prioridad baja)

**Jornadas** — confirmar los horarios reales de cada una:

| Jornada | Horario |
|---|---|
| Mañana | ¿06:00 – 12:00? |
| Mixta | ¿12:00 – 18:00? |
| Noche | ¿18:00 – 22:00? |
| Virtual | Sin horario fijo |

**Tipos de actividad** — confirmar la lista de actividades que hacen los
instructores y **cuáles suman a la carga horaria** (20–40h semanales) y cuáles
no (ej. "Disponible", "Alistamiento"). Y si alguna requiere ficha, ambiente o
competencia obligatoriamente.

---

## Resumen — qué necesitamos, en orden de prioridad

| # | Necesidad | Prioridad | Cierra |
|---|---|---|---|
| 1 | Reportes de Juicios Evaluativos por programa/ficha | 🔴 Alta | Competencias y RAPs reales |
| 2 | Lista completa de instructores con todos sus campos | 🔴 Alta | P4, P8, P9, línea medular |
| 3 | Lista de programas | 🟡 Media | Catálogo de programas |
| 4 | Lista de fichas/grupos con fechas de etapa | 🟡 Media | Grupos reales |
| 5 | Lista de ambientes y talleres con capacidad | 🟡 Media | Infraestructura real |
| 6 | Confirmación de áreas y líneas | 🟢 Baja | Catálogo de áreas |
| 7 | Confirmación de jornadas y tipos de actividad | 🟢 Baja | Catálogos operativos |

Con las secciones 1 y 2 completas ya podríamos avanzar bastante; las demás
terminan de dejar el sistema con información 100% real del CDMC.

Gracias,
Jair
