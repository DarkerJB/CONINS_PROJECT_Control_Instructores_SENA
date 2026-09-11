# CONINS — Requerimientos de servidor y dominio

Documento tecnico para la socializacion del 09/09/2026 (uso del dominio y servidor del
CDMC). Escenario objetivo: **VM/servidor del propio centro** + **subdominio** bajo el
dominio del CDMC (ej. `conins.<dominio-del-centro>`).

Autor: equipo CONINS (aprendices). Dirigido a: coordinacion y area de TI del centro.

---

## 1. Que es lo que se va a alojar

CONINS es una aplicacion web de tres piezas que corren en un mismo servidor:

1. **Backend / API** — Node.js + Express (TypeScript). Expone la API REST. Puerto interno tipico: 5000.
2. **Frontend web** — Next.js (React). Sirve la interfaz que usan coordinacion, subdireccion e instructores. Puerto interno tipico: 3000.
3. **Base de datos** — MySQL. Guarda toda la informacion (instructores, grupos, horarios, asignaciones, auditoria).

Delante de todo va un **proxy inverso (Nginx)** que recibe el trafico del subdominio,
aplica HTTPS y lo reparte: la web al frontend y `/api` al backend. El usuario final solo
ve una direccion: `https://conins.<dominio-del-centro>`.

Todo el stack es **software libre (open source)**: no hay licencias que pagar.

---

## 2. Requerimientos del servidor (VM del centro)

| Recurso | Minimo | Recomendado | Por que |
|---|---|---|---|


Uso esperado: institucional/interno (coordinacion academica del centro), no es un portal
masivo. Con lo recomendado sobra para el volumen previsto.

### 2.6 Software a instalar en el servidor
- Node.js LTS (v20 o superior)
- MySQL 8
- Nginx (proxy inverso + HTTPS)
- Un gestor de procesos: PM2 (o servicios systemd) para mantener el backend y el frontend arriba y que reinicien solos.
- Git (para desplegar/actualizar el codigo)

> Nota Windows Server: el stack funciona igual en Windows (de hecho el desarrollo se hace
> en Windows con Laragon). Cambia el gestor de procesos (NSSM/servicio de Windows en vez
> de PM2/systemd) y el proxy (IIS o Nginx para Windows). Linux es lo recomendado por
> costo y estabilidad, pero no es un bloqueante.

---

## 3. Requerimientos de dominio y red

Como el centro ya tiene un dominio propio y CONINS iria en un **subdominio**:

1. **Registro DNS del subdominio** — crear un registro `A` (o `CNAME`) para
   `conins.<dominio-del-centro>` que apunte a la IP del servidor. Esto lo hace quien
   administra el dominio (area de TI o el proveedor donde se compro el dominio).
2. **Certificado SSL/HTTPS** — obligatorio (se manejan datos de personas). Dos opciones:
   - **Let's Encrypt** (gratuito, se renueva solo con certbot). Requiere que el servidor
     sea alcanzable en el puerto 80/443 para validar.
   - Un **certificado que provea el SENA/centro** (si tienen wildcard `*.dominio` o uno
     institucional). En ese caso solo se instala en Nginx.
3. **Puertos / firewall**:
   - Entrada: **80 (HTTP)** y **443 (HTTPS)** hacia el servidor (redirigir 80 a 443).
   - **SSH (22)** restringido solo a administradores.
   - MySQL (3306) y los puertos internos (3000/5000) **NO** se exponen a la red; solo los
     usa Nginx localmente. La BD nunca queda abierta a internet.
4. **Alcance**: definir si el subdominio se resuelve solo en la red interna del centro
   (intranet) o tambien fuera. Para uso de coordinacion probablemente baste intranet, lo
   que reduce la superficie de exposicion.

---

## 4. Configuracion de la aplicacion (para TI)

- **Variables de entorno (.env)** en el servidor: credenciales de la BD, secreto JWT,
  y opcionalmente SMTP. No van en el codigo ni en el repositorio.
- **Base de datos**: se crea la BD `conIns` y se carga el esquema (script `database.sql`
  que el equipo entrega). Se crea un usuario MySQL de la app con permisos solo sobre esa BD.
- **Correo (opcional)**: para recuperacion de contrasena y notificaciones por correo se
  necesita un **relay SMTP** institucional (usuario/clave). Si no se configura, la app
  funciona igual pero sin envio de correos.
- **Actualizaciones**: el despliegue se hace por Git; una actualizacion es traer cambios,
  reconstruir y reiniciar los procesos. Downtime minimo.

---

## 5. Respaldos y continuidad

- **Respaldo de BD**: volcado (`mysqldump`) diario automatico, con retencion (ej. 7-14
  dias) en el mismo servidor y copia fuera de el. El equipo ya tiene scripts de backup.
- **Responsable de operacion**: definir quien administra el servidor (parches del SO,
  monitoreo de que este arriba, espacio en disco). Puede ser TI del centro.
- **Auditoria**: la app ya registra en una tabla `auditoria` quien cambia que y cuando,
  lo que apoya trazabilidad y cumplimiento.

---

## 6. Seguridad y datos personales

- HTTPS obligatorio en todo el trafico.
- La BD no se expone a la red; solo la alcanza la app localmente.
- Se manejan datos personales de instructores (nombre, correo, documento): aplican las
  politicas de tratamiento de datos del SENA. Acceso restringido por rol dentro de la app
  (Subdirector, Coordinadora, Asistente, Instructor).
- Contrasenas almacenadas con hash (bcrypt), nunca en texto plano.

---

## 7. Lo que se pide concretamente en la reunion

1. Una **VM Linux** con las specs recomendadas (o Windows Server si es la politica del centro).
2. Un **subdominio** `conins.<dominio-del-centro>` apuntando a la IP del servidor.
3. **Certificado SSL** (permiso para Let's Encrypt, o que TI provea uno).
4. **Apertura de puertos 80/443** hacia el servidor (intranet o publico, a definir).
5. **Relay SMTP** institucional (opcional, para correos).
6. Definir **responsable de administracion** del servidor y **politica de respaldo**.

Costo: el software es libre (sin licencias). El costo real es la infraestructura (la VM,
que el centro ya puede proveer) y, si se decide, el certificado SSL (gratuito con Let's Encrypt).

---

## 8. Resumen de una linea

CONINS necesita una VM Linux modesta (4 vCPU / 8 GB / 60 GB), un subdominio del centro con
HTTPS, y apertura de 80/443; todo lo demas (Node, MySQL, Nginx, respaldos) es open source
y lo instala y opera el equipo con TI.
