import { HorarioModel } from '../models/horario.model.js';
import { InstructorModel } from '../models/instructor.model.js';
import { NotFoundError, ValidationError } from '../utils/errors.js';

function getLunesSemanaActual(): string {
  const now = new Date();
  const day = now.getDay();
  const diff = day === 0 ? -6 : 1 - day;
  const lunes = new Date(now);
  lunes.setDate(now.getDate() + diff);
  return lunes.toISOString().split('T')[0];
}

export const HorarioService = {
  async getAll() {
    return HorarioModel.findAll();
  },

  async getById(id: number) {
    const horario = await HorarioModel.findById(id);
    if (!horario) throw new NotFoundError('Horario no encontrado');
    return horario;
  },

  async create(data: {
    ficha_id: number;
    instructor_id: number;
    competencia_id: number;
    dia_semana: number;
    hora_inicio: string;
    hora_fin: string;
    jornada_id: number;
    semana?: string;
  }) {
    const instructor = await InstructorModel.findById(data.instructor_id);
    if (!instructor) throw new NotFoundError('Instructor no encontrado');

    const semana = data.semana ?? getLunesSemanaActual();
    const horasActuales = await HorarioModel.getHorasPorInstructor(data.instructor_id, semana);
    const nuevasHoras = ((new Date(`2000-01-01T${data.hora_fin}`).getTime() - new Date(`2000-01-01T${data.hora_inicio}`).getTime()) / (1000 * 60 * 60));
    const totalHoras = horasActuales + nuevasHoras;

    if (totalHoras > 40) {
      throw new ValidationError(`El instructor excede el limite de 40 horas semanales (actual: ${horasActuales}h, nuevas: ${nuevasHoras}h)`);
    }

    const id = await HorarioModel.create({ ...data, semana });
    return HorarioModel.findById(id);
  },

  async update(id: number, data: {
    dia_semana?: number;
    hora_inicio?: string;
    hora_fin?: string;
    competencia_id?: number;
  }) {
    const horario = await HorarioModel.findById(id);
    if (!horario) throw new NotFoundError('Horario no encontrado');

    await HorarioModel.update(id, data);
    return HorarioModel.findById(id);
  },

  async toggleActivo(id: number, motivo?: string) {
    const horario = await HorarioModel.findById(id);
    if (!horario) throw new NotFoundError('Horario no encontrado');

    const nuevoEstado = await HorarioModel.toggleActivo(id, motivo);
    return { activo: nuevoEstado };
  },
};
