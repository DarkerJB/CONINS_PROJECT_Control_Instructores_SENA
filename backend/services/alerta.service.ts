import { AlertaModel, AlertaInput } from '../models/alerta.model.js';
import { AsignacionRapModel } from '../models/asignacion-rap.model.js';
import { NotificacionService } from './notificacion.service.js';

// Genera y persiste alertas SOFT (no bloquean la carga). Quedan visibles en
// GET /api/alertas mientras atendida = FALSE; el admin las acepta/omite con
// PATCH /api/alertas/:id/atendida. Best-effort: un fallo al alertar nunca debe
// tumbar la operacion de negocio que la origino.
export const TIPOS_ALERTA = {
  HORAS_EXCEDIDAS: 'HORAS_EXCEDIDAS',
  HORAS_INSUFICIENTES: 'HORAS_INSUFICIENTES',
  AMBIENTE_OCUPADO: 'AMBIENTE_OCUPADO',
  ASIGNACION_PROVISIONAL: 'ASIGNACION_PROVISIONAL',
  JORNADA_RESTRINGIDA: 'INSTRUCTOR_PLANTA_JORNADA_NOCTURNA',
  RAP_COMPARTIDO: 'RAP_COMPARTIDO',
} as const;

// Tipos que NO encienden la campanita (quedan visibles solo en la pagina de
// Alertas). HORAS_INSUFICIENTES es esperado (baja carga real), no accionable.
const TIPOS_SIN_CAMPANITA = new Set<string>([TIPOS_ALERTA.HORAS_INSUFICIENTES]);

export const AlertaService = {
  // Devuelve true si se creo una alerta NUEVA (no habia una abierta igual). Se
  // usa para disparar la notificacion de campanita solo en alertas nuevas.
  async crear(a: AlertaInput): Promise<boolean> {
    try {
      if (await AlertaModel.existsAbierta(a)) return false;
      await AlertaModel.crear(a);
      // Enciende la campanita para coordinacion/subdireccion en alertas nuevas
      // ACCIONABLES (ambiente ocupado, carga excedida, provisional, RAP, etc.).
      // HORAS_INSUFICIENTES se excluye del contador: la baja carga es real (los
      // instructores completan horas con otros programas), asi que solo queda
      // visible en la pagina de Alertas sin inundar la campanita.
      // Best-effort: si falla la notificacion, la alerta ya quedo registrada.
      if (!TIPOS_SIN_CAMPANITA.has(a.tipo)) {
        try {
          await NotificacionService.notificarCoordinadoresYSubdirector(a.tipo, a.mensaje);
        } catch (e) {
          console.error('[alerta] alerta creada pero no se pudo notificar:', e);
        }
      }
      return true;
    } catch (err) {
      console.error('[alerta] no se pudo registrar la alerta:', err);
      return false;
    }
  },

  // RN-06 (regla firme, confirmada con coordinacion y lider tecnico): un RAP no
  // puede estar a cargo de dos instructores en el mismo grupo, porque al
  // evaluarlo los aprendices no pueden tener dos juicios distintos del mismo RAP.
  // No se bloquea la carga masiva (para no rechazar el archivo real); se levanta
  // una alerta persistente que queda visible hasta que se CORRIJA el dato
  // (reasignar el RAP a un solo instructor) o el admin/lider la marque atendida.
  async rapCompartido(instructor_id: number, ficha_id: number, rap_id: number): Promise<void> {
    // Mensaje legible para coordinacion: nombre del resultado de aprendizaje,
    // grupo e instructores involucrados (para saber donde esta el error).
    const ctx = await AlertaModel.contextoRapCompartido(ficha_id, rap_id);
    const quienes = ctx.instructores.length >= 2
      ? ctx.instructores.join(' y ')
      : (ctx.instructores[0] ?? 'varios instructores');
    const mensaje = `El resultado de aprendizaje "${ctx.rapNombre}" quedo a cargo de ${ctx.instructores.length || 'varios'} instructores (${quienes}) en el grupo ${ctx.fichaNumero}. Debe quedar con un solo instructor para poder evaluarlo. Revisa y corrige la asignacion.`;

    const creada = await this.crear({ instructor_id, tipo: TIPOS_ALERTA.RAP_COMPARTIDO, mensaje, ficha_id, rap_id });
    if (!creada) return;
    // crear() ya notifico a coordinacion/subdireccion. Aqui solo agregamos a los
    // LIDERES del programa del grupo (ellos arman el Excel y corrigen), que es
    // especifico de RAP compartido.
    try {
      await NotificacionService.notificarLideresPrograma(ficha_id, TIPOS_ALERTA.RAP_COMPARTIDO, mensaje);
    } catch (err) {
      console.error('[alerta] no se pudo notificar a lideres (RAP compartido):', err);
    }
  },

  async cerrarRapCompartido(ficha_id: number, rap_id: number): Promise<void> {
    try {
      await AlertaModel.cerrarEstructural(TIPOS_ALERTA.RAP_COMPARTIDO, ficha_id, rap_id);
    } catch (err) {
      console.error('[alerta] no se pudo cerrar la alerta estructural:', err);
    }
  },

  // Tras una edicion en el grupo, cierra las alertas de RAP compartido que ya
  // quedaron resueltas (el RAP dejo de estar a cargo de 2+ instructores).
  async recomputarRapCompartido(ficha_id: number): Promise<void> {
    try {
      const abiertas = await AlertaModel.rapCompartidoAbiertasByFicha(ficha_id);
      for (const { rap_id } of abiertas) {
        const n = await AsignacionRapModel.countInstructoresConRap(ficha_id, rap_id);
        if (n < 2) {
          await AlertaModel.cerrarEstructural(TIPOS_ALERTA.RAP_COMPARTIDO, ficha_id, rap_id);
        }
      }
    } catch (err) {
      console.error('[alerta] no se pudo recomputar RAP compartido:', err);
    }
  },
};
