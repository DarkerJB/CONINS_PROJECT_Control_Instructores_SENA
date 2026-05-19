import pool from '../config/db.js';

export const InstructorModel = {
  async findByUsuarioId(usuarioId: number): Promise<{ id: number; tipo_contrato: string; tipo_area: string } | null> {
    const [rows] = await pool.query(
      'SELECT id, tipo_contrato, tipo_area FROM instructores WHERE usuario_id = ? AND activo = TRUE',
      [usuarioId],
    );
    return (rows as any[])[0] ?? null;
  },

  async create(usuarioId: number, tipo_contrato: string, tipo_area: string): Promise<void> {
    await pool.query(
      'INSERT INTO instructores (usuario_id, tipo_contrato, tipo_area) VALUES (?, ?, ?)',
      [usuarioId, tipo_contrato, tipo_area],
    );
  },

  async hasActiveCompetencias(usuarioId: number): Promise<boolean> {
    const [rows] = await pool.query(
      `SELECT 1 FROM asignacion_competencia ac
       JOIN asignacion a ON ac.asignacion_id = a.id
       JOIN instructores i ON a.instructor_id = i.id
       WHERE i.usuario_id = ? AND ac.activo = TRUE
       LIMIT 1`,
      [usuarioId],
    );
    return (rows as any[]).length > 0;
  },

  async deleteByUsuarioId(usuarioId: number): Promise<void> {
    await pool.query('DELETE FROM instructores WHERE usuario_id = ?', [usuarioId]);
  },
};
