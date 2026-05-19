import { Request, Response } from 'express';
import { asyncHandler } from '../utils/asyncHandler.js';

export const listar = asyncHandler(async (_req: Request, res: Response) => {
  res.json({ message: 'instructor.listar — TODO' });
});

export const crear = asyncHandler(async (_req: Request, res: Response) => {
  res.json({ message: 'instructor.crear — TODO' });
});

export const actualizar = asyncHandler(async (_req: Request, res: Response) => {
  res.json({ message: 'instructor.actualizar — TODO' });
});

export const registrarNovedad = asyncHandler(async (_req: Request, res: Response) => {
  res.json({ message: 'instructor.registrarNovedad — TODO' });
});

export const listarCompetenciasHabilitadas = asyncHandler(async (_req: Request, res: Response) => {
  res.json({ message: 'instructor.listarCompetenciasHabilitadas — TODO' });
});

export const actualizarCompetenciasHabilitadas = asyncHandler(async (_req: Request, res: Response) => {
  res.json({ message: 'instructor.actualizarCompetenciasHabilitadas — TODO' });
});
