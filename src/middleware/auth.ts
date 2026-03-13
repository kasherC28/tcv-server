import { NextFunction, Request, Response } from 'express';
import { verifyAccessToken } from '../common/jwt';
import { unauthorized } from '../common/http';
import * as usersRepo from '../modules/users/users.repo';
import { UserStatus } from '../common/enums';

export const auth = async (req: Request, _: Response, next: NextFunction) => {
  try {
    const header = req.headers.authorization;
    const token = header?.startsWith('Bearer ') ? header.slice(7) : '';
    if (!token) throw unauthorized();
    const payload = verifyAccessToken(token);
    const user = await usersRepo.findById(Number(payload.sub));
    if (!user || user.status !== UserStatus.ACTIVE) throw unauthorized();
    req.user = user;
    next();
  } catch {
    next(unauthorized());
  }
};
