import { Request, Response } from 'express';
import * as service from './auth.service';

export const signup = async (req: Request, res: Response) =>
  res.status(201).json({ success: true, data: await service.signup(req.body) });

export const signin = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.signin(req.body.email, req.body.password) });

export const forgotPassword = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.forgotPassword(req.body.email) });

export const resetPassword = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.resetPassword(req.body.email, req.body.otp, req.body.new_password) });

export const updatePassword = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.updatePassword(req.user!.id, req.body.current_password, req.body.new_password) });

export const createUser = async (req: Request, res: Response) =>
  res.status(201).json({ success: true, data: await service.createUserByAdmin(req.body) });

export const blockUser = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.blockUser(Number(req.params.id), req.body.status) });
