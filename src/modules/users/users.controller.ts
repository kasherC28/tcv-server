import { Request, Response } from 'express';
import * as service from './users.service';

export const me = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.getMe(req.user!.id) });

export const updateMe = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.updateMe(req.user!.id, req.body) });

export const one = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.getUser(Number(req.params.id)) });

export const list = async (req: Request, res: Response) => {
  const limit = Number(req.query.limit || 20);
  const offset = Number(req.query.offset || 0);
  res.json({ success: true, data: await service.listUsers(limit, offset) });
};

export const update = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.updateUser(Number(req.params.id), req.body) });
