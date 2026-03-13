import { Request, Response, NextFunction } from 'express';

export const notFoundHandler = (_: Request, __: Response, next: NextFunction) =>
  next(Object.assign(new Error('Route not found'), { statusCode: 404 }));
