import pool from '../config/db.js';
import { ForbiddenError } from '../utils/errors.js';

export const PermisoService = {
  async validarAlcanceLider(usuarioId: number, fichaId: number): Promise<void> {
    const [rows] = await pool.query(
      `SELECT 1 FROM lider_programa lp
       JOIN fichas f ON f.programa_id = lp.programa_id
       JOIN instructores i ON lp.instructor_id = i.id
       WHERE i.usuario_id = ? AND f.id = ?
       LIMIT 1`,
      [usuarioId, fichaId],
    );
    if ((rows as any[]).length === 0) {
      throw new ForbiddenError('El lider solo puede asignar dentro de sus programas (RN-12)');
    }
  },

  // 01/07/2026: lider_programa ya NO es un rol del sistema → esta validación
  // se conserva por compatibilidad pero nunca bloqueará (esLider siempre false).
  async validarNoLiderParaProvisional(_usuarioId: number): Promise<void> {
    // Lider de programa es ahora una marca informativa (tabla lider_programa),
    // no un rol de sistema. La restricción de asignaciones provisionales para
    // líderes fue removida. Función mantenida para no romper callers.
    return;
  },

  // 01/07/2026: la distinción medular/transversal fue eliminada (feedback coordinadora).
  // Coordinadora Academica y Asistente Coordinacion gestionan todas las fichas.
  // Función conservada para no romper callers; ya no aplica restricción de tipo_linea.
  async validarAlcanceCoordinador(_usuarioId: number, _fichaId: number): Promise<void> {
    return;
  },
};
