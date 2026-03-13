import { NextFunction, Request, Response } from 'express';

export const asyncWrap =
  (fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>) =>
  (req: Request, res: Response, next: NextFunction) =>
    Promise.resolve(fn(req, res, next)).catch(next);

export const badRequest = (message: string) =>
  Object.assign(new Error(message), { statusCode: 400 });

export const unauthorized = (message = 'Unauthorized') =>
  Object.assign(new Error(message), { statusCode: 401 });

export const forbidden = (message = 'Forbidden') =>
  Object.assign(new Error(message), { statusCode: 403 });

export const notFound = (message = 'Not Found') =>
  Object.assign(new Error(message), { statusCode: 404 });
