# CONINS — Guion de sustentacion (reunion 09/09/2026)

Reunion: Mie 09/09, 2:00-3:00 PM, Teams. Convocan Leidy Ruiz y Walver Rodriguez.
Objetivo de ellos: conocer el proyecto y definir los requerimientos de servidor y dominio.
Objetivo nuestro: que quede aprobada la VM + el subdominio.

Duracion sugerida: ~15-20 min de exposicion + preguntas. Apoyarse en el documento
"CONINS_Requerimientos_Servidor_Dominio_09-09".

---

## 1. Que es CONINS (1-2 min)

- CONINS = Control de Instructores del CDMC. Es una aplicacion web para gestionar la
  **programacion academica de los instructores**: quien dicta que, cuando y en que ambiente.
- Centraliza en un solo lugar: instructores, grupos (fichas), competencias, RAPs,
  horarios, ambientes y alertas.
- Aclarar el limite: **no reemplaza Sofia Plus**. No maneja notas. Se enfoca en la carga
  academica y la coordinacion de instructores.
- Lo usa: subdireccion, coordinacion academica, asistente de coordinacion e instructores
  (cada rol ve lo que le corresponde).

## 2. En que estado esta (1 min)

- El sistema **ya esta funcionando**: backend, frontend y base de datos operativos.
- Hoy corre de forma **local** (en las maquinas del equipo, con MySQL). Esta listo para
  pasar a un servidor real y que lo use la coordinacion.
- Por eso venimos: necesitamos donde alojarlo para que este disponible de forma estable.

## 3. Por que necesitamos servidor y subdominio (2 min)

- Para que coordinacion y subdireccion **entren desde el navegador** a una direccion fija
  (`conins.<dominio-del-centro>`), sin depender de la maquina de un aprendiz.
- Para que los datos esten **centralizados, respaldados y con acceso controlado** por rol.
- Para que el sistema siga vivo cuando termine la etapa lectiva del equipo: quedar montado
  en la infraestructura del centro es lo que lo vuelve sostenible.

## 4. Que pedimos exactamente (nucleo de la reunion, 3-4 min)

Apoyarse en la tabla del documento tecnico. Pedir:

1. Una **maquina virtual** (Linux recomendado): 4 vCPU, 8 GB RAM, 60 GB de disco.
   (Minimo funcional: 2 vCPU, 4 GB, 40 GB.)
2. Un **subdominio** del dominio del centro, ej. `conins.<dominio>`, apuntando a esa VM.
3. **HTTPS/SSL** para el subdominio (podemos usar Let's Encrypt gratis, o el certificado
   que provea TI).
4. **Apertura de puertos 80 y 443** hacia la VM (definir si es solo intranet o tambien
   externo).
5. Opcional: un **correo SMTP institucional** para recuperacion de contrasena y avisos.
6. Definir **quien administra** la VM y la **politica de respaldo**.

## 5. Lo que NO implica (para bajar preocupaciones, 1-2 min)

- **Sin costo de licencias**: todo el software es libre (Node.js, MySQL, Nginx).
- **No expone la base de datos a internet**: la BD solo la usa la app internamente.
- **Consumo modesto**: es una app de uso institucional, no un portal masivo.
- **Datos protegidos**: HTTPS obligatorio, contrasenas cifradas, acceso por rol, y una
  bitacora de auditoria que registra quien cambia que.
- El equipo **instala y despliega**; a TI le pedimos la VM, el subdominio y los permisos.

## 6. Siguientes pasos propuestos (1 min)

1. TI aprueba y provisiona la VM + crea el subdominio.
2. El equipo despliega CONINS (Node + MySQL + Nginx) y configura HTTPS.
3. Carga de datos y pruebas con coordinacion.
4. Puesta en marcha y entrega de credenciales de administracion al centro.

---

## Preguntas probables y como responder

- **"Cuanto cuesta?"** → El software no cuesta (es libre). Solo la infraestructura (la VM,
  que el centro puede proveer). El SSL es gratis con Let's Encrypt.
- **"Es seguro tener datos de instructores ahi?"** → Si: HTTPS, contrasenas cifradas,
  acceso por rol, BD no expuesta a internet y auditoria de cambios. Aplican las politicas
  de datos del SENA.
- **"Quien lo mantiene cuando ustedes se vayan?"** → Queda documentado (diccionario de
  datos, scripts de despliegue y respaldo) y montado en infraestructura del centro; TI
  puede operarlo y el codigo queda entregado.
- **"Por que no un servicio en la nube?"** → Se puede, pero como el centro tiene servidor
  y dominio propios, montarlo interno evita costos recurrentes y mantiene los datos en la
  infraestructura del SENA. Es la opcion que proponemos.
- **"Y si solo hay Windows Server?"** → Tambien funciona; ajustamos el gestor de procesos
  y el proxy. Linux es lo recomendado, no un requisito rigido.

---

## Reparto sugerido (si exponen varios)

- Quien abre: que es CONINS + estado (puntos 1 y 2).
- Quien tecnico: requerimientos + seguridad (puntos 3, 4, 5).
- Quien cierra: siguientes pasos + preguntas (punto 6).
