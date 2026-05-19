import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/errors.js';

export const errorHandler = (
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
) => {
  if (process.env.NODE_ENV === 'development') {
    console.error('[ERROR]', err);
  }
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
    });
  }

  console.error('[ERROR]', err);

  return res.status(500).json({
    success: false,
    message: 'Error interno del servidor',
  });
};

export default errorHandler;
