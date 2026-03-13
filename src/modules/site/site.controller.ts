import { Request, Response } from 'express';
import * as service from './site.service';

export const getConfig = async (_: Request, res: Response) =>
  res.json({ success: true, data: service.getPublicConfig() });
