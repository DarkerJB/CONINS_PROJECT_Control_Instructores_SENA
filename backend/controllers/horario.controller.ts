import { Request, Response } from 'express';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiResponse } from '../utils/response.js';
import { HorarioService } from '../services/horario.service.js';

export const getAll = asyncHandler(async (_req: Request, res: Response) => {
  const horarios = await HorarioService.getAll();
  ApiResponse.success(res, horarios);
});

export const getById = asyncHandler(async (req: Request, res: Response) => {
  const horario = await HorarioService.getById(Number(req.params.id));
  ApiResponse.success(res, horario);
});

export const create = asyncHandler(async (req: Request, res: Response) => {
  const result = await HorarioService.create(req.body);

  if (result.alerta_ambiente_ocupado) {
    return res.status(201).json({
      success: true,
      message: 'Horario registrado con alerta de ambiente ocupado (RN-05)',
      data: result,
      alerta: 'AMBIENTE_OCUPADO',
    });
  }

  ApiResponse.created(res, result, 'Horario registrado exitosamente');
});

export const update = asyncHandler(async (req: Request, res: Response) => {
  const horario = await HorarioService.update(Number(req.params.id), req.body);
  ApiResponse.success(res, horario, 'Horario actualizado exitosamente');
});

export const toggleActivo = asyncHandler(async (req: Request, res: Response) => {
  const { motivo } = req.body;
  const result = await HorarioService.toggleActivo(Number(req.params.id), motivo);
  const message = result.activo ? 'Horario habilitado' : 'Horario deshabilitado';
  ApiResponse.success(res, result, message);
});
