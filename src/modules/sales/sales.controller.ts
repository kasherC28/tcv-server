import { Request, Response } from 'express';
import * as service from './sales.service';

export const create = async (req: Request, res: Response) =>
  res.status(201).json({ success: true, data: await service.create(req.user!.id, req.body) });

export const listMine = async (req: Request, res: Response) => {
  const limit = Number(req.query.limit || 20);
  const offset = Number(req.query.offset || 0);
  res.json({ success: true, data: await service.listMine(req.user!.id, limit, offset) });
};
