import { NextFunction, Request, Response } from 'express';
import { ZodTypeAny } from 'zod';

export const validate =
  (schema: ZodTypeAny, key: 'body' | 'query' | 'params' = 'body') =>
  (req: Request, _: Response, next: NextFunction) => {
    const parsed = schema.safeParse(req[key]);
    if (!parsed.success) return next(Object.assign(new Error(parsed.error.issues[0].message), { statusCode: 400 }));
    req[key] = parsed.data;
    next();
  };
