import { NextFunction, Request, Response } from 'express';
import { logger } from '../common/logger';

export const errorHandler = (
  err: Error & { statusCode?: number },
  req: Request,
  res: Response,
  _: NextFunction
) => {
  const status = err.statusCode || 500;
  req.log[status >= 500 ? 'error' : 'warn']({ err }, err.message);
  if (status >= 500) logger.error({ err }, 'unhandled error');
  res.status(status).json({ success: false, message: err.message || 'Server error' });
};
