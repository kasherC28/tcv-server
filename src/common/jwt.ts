import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { Role } from './enums';

type Payload = { sub: number; role: Role; email: string };

export const signAccessToken = (payload: Payload) =>
  jwt.sign(payload, env.JWT_SECRET, { expiresIn: '1d' });

export const verifyAccessToken = (token: string) =>
  jwt.verify(token, env.JWT_SECRET) as Payload & jwt.JwtPayload;
