import { Request, Response } from 'express';
import * as service from './products.service';

export const list = async (_: Request, res: Response) =>
  res.json({ success: true, data: await service.listProducts() });
