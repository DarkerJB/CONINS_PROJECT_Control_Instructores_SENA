# horario-carga-validation — CONINS v4

## Proposito

Gestionar y validar la carga horaria semanal de instructores, considerando:
- El rango valido es 20-40h para ambos tipos de contrato (confirmado 04/05/2026)
- El calculo siempre es dinamico en backend
- Las alertas se sincronizan en cada cambio de horario
- La jornada virtual no aplica validaciones de ambiente fisico

---

## Limites de carga horaria (confirmados)

```ts
// constants/horario.ts
export const LIMITES_HORAS: Record<string, { min: number; max: number }> = {
  de_planta:   { min: 20, max: 40 },
  contratista: { min: 20, max: 40 },
};
```

> Centralizar aqui para cambiar en un solo lugar si la normativa cambia.

---

## Contexto del sistema

- Tabla `horarios`: bloques de tiempo por instructor
  - `dia_semana TINYINT` (1=Lunes ... 7=Domingo)
  - `semana DATE` (fecha del lunes de la semana)
  - `motivo_suspension TEXT NULL` (RF-36)
- Tabla `instructores`: incluye `tipo_contrato` (de_planta | contratista)
- Tabla `jornadas`: manana (06-12), mixta (12-18), noche (18-22), virtual (sin horario)
- Tabla `alertas`: alertas activas del sistema con `semana`, `total_horas`, `atendida`
- Service central: `horario.service.ts`

---

## Logica de calculo

```ts
// services/horario.service.ts

async function calcularCargaSemanal(instructorId: number, semana: Date): Promise<number> {
  const bloques = await horarioModel.findByInstructorAndSemana(instructorId, semana);
  return bloques.reduce((total, b) => {
    const inicio = new Date(`1970-01-01T${b.hora_inicio}`);
    const fin    = new Date(`1970-01-01T${b.hora_fin}`);
    return total + (fin.getTime() - inicio.getTime()) / 3600000;
  }, 0);
}

async function evaluarCarga(instructorId: number, semana: Date) {
  const instructor = await instructorModel.findById(instructorId);
  const limites    = LIMITES_HORAS[instructor.tipo_contrato];
  const total      = await calcularCargaSemanal(instructorId, semana);

  if (total > limites.max) {
    await alertaService.crear(instructorId, TIPOS_ALERTA.HORAS_EXCEDIDAS, {
      total, max: limites.max, semana
    });
  } else if (total < limites.min) {
    await alertaService.crear(instructorId, TIPOS_ALERTA.HORAS_INSUFICIENTES, {
      total, min: limites.min, semana
    });
  } else {
    await alertaService.limpiar(instructorId, [
      TIPOS_ALERTA.HORAS_EXCEDIDAS,
      TIPOS_ALERTA.HORAS_INSUFICIENTES
    ], semana);
  }

  return { total, limites, estado: total > limites.max ? 'excedido' : total < limites.min ? 'insuficiente' : 'ok' };
}
```

---

## Cuando recalcular

| Evento | Accion |
|---|---|
| Crear bloque de horario | `evaluarCarga(instructorId, semana_del_bloque)` |
| Deshabilitar bloque (activo=FALSE) | `evaluarCarga(instructorId, semana_del_bloque)` |
| Modificar bloque | `evaluarCarga` en semana anterior Y nueva |
| Cambiar `tipo_contrato` del instructor | Recalcular todas sus semanas activas |

---

## Validacion de jornada y ambiente

```ts
async function registrarBloque(payload: CrearHorarioDTO) {
  const { instructor_id, ficha_id, ambiente_id, jornada_id, dia_semana, hora_inicio, hora_fin } = payload;

  // 1. Verificar conflicto de horario del instructor (mismo dia y hora)
  const conflictoInstructor = await horarioModel.findConflictoInstructor(
    instructor_id, dia_semana, hora_inicio, hora_fin
  );
  if (conflictoInstructor) throw new ConflictError('El instructor ya tiene clase en ese horario', 409);

  // 2. Verificar disponibilidad de ambiente (solo si jornada != virtual)
  const jornada = await jornadaModel.findById(jornada_id);
  if (jornada.nombre !== 'virtual' && ambiente_id) {
    const ambienteOcupado = await horarioModel.findConflictoAmbiente(
      ambiente_id, dia_semana, hora_inicio, hora_fin
    );
    if (ambienteOcupado) {
      // Alerta soft — NO bloquea, solo notifica (RN-05)
      await alertaService.crear(instructor_id, TIPOS_ALERTA.AMBIENTE_OCUPADO, {
        ambiente_id, dia_semana
      });
    }
  }

  // 3. Insertar bloque
  await horarioModel.insert(payload);

  // 4. Recalcular carga semanal
  return evaluarCarga(instructor_id, payload.semana);
}
```

---

## Tipos de alerta

```ts
// constants/alertas.ts
export const TIPOS_ALERTA = {
  HORAS_EXCEDIDAS:                  'HORAS_EXCEDIDAS',
  HORAS_INSUFICIENTES:              'HORAS_INSUFICIENTES',
  AMBIENTE_OCUPADO:                 'AMBIENTE_OCUPADO',
  ASIGNACION_PROVISIONAL:           'ASIGNACION_PROVISIONAL',
  INSTRUCTOR_PLANTA_JORNADA_NOCTURNA: 'INSTRUCTOR_PLANTA_JORNADA_NOCTURNA',
} as const;
```

---

## Errores criticos

```ts
// ❌ Limites hardcodeados sin constante
if (totalHoras > 40) generarAlerta('HORAS_EXCEDIDAS');

// ❌ Mismo limite para todos sin importar tipo_contrato
const limites = { min: 20, max: 40 };  // ← ignorando tipo_contrato

// ❌ No recalcular al DESHABILITAR bloques
await horarioModel.update(id, { activo: false });
// (falta llamar evaluarCarga despues)

// ❌ Calcular horas desde RAPs en lugar de desde bloques de horario

// ❌ Validar ambiente en jornada virtual
// (jornada.nombre === 'virtual' → skip validacion de ambiente)

// ❌ Usar campo `fecha` en horarios — no existe en schema v4
// Usar `dia_semana` + `semana` en su lugar
```
