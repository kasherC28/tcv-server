import { Request, Response } from 'express';
import * as service from './contact.service';

export const create = async (req: Request, res: Response) =>
  res.status(201).json({ success: true, data: await service.create(req.body) });

export const list = async (req: Request, res: Response) => {
  const limit = Number(req.query.limit || 20);
  const offset = Number(req.query.offset || 0);
  res.json({ success: true, data: await service.list(limit, offset) });
};
