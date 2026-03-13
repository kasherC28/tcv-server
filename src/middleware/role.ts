import { NextFunction, Request, Response } from 'express';
import { Role } from '../common/enums';

export const allowRoles =
  (...roles: Role[]) =>
  (req: Request, _: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(Object.assign(new Error('Forbidden'), { statusCode: 403 }));
    }
    next();
  };
