import { Request, Response } from 'express';
import * as service from './checkout.service';

export const create = async (req: Request, res: Response) =>
  res.status(201).json({ success: true, data: await service.create(req.user!.id, req.body) });

export const list = async (_: Request, res: Response) =>
  res.json({ success: true, data: await service.list() });

export const confirm = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.confirm(Number(req.params.id), req.user!.id) });

export const reject = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.reject(Number(req.params.id), req.user!.id, req.body.notes) });
