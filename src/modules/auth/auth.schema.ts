import { z } from 'zod';
import { Gender, Role, UserStatus } from '../../common/enums';

const phone = z.string().min(7).max(20);
const password = z.string().min(8).max(100);

export const signupSchema = z.object({
  name: z.string().min(1),
  f_name: z.string().min(1),
  email: z.string().email(),
  password,
  contact: phone,
  dob: z.string().min(1),
  address: z.string().optional(),
  city: z.string().optional(),
  country: z.string().optional(),
  gender: z.nativeEnum(Gender)
});

export const signinSchema = z.object({ email: z.string().email(), password });

export const forgotPasswordSchema = z.object({ email: z.string().email() });

export const resetPasswordSchema = z.object({
  email: z.string().email(),
  otp: z.string().length(6),
  new_password: password
});

export const updatePasswordSchema = z.object({
  current_password: password,
  new_password: password
});

export const createUserSchema = signupSchema.extend({
  role: z.nativeEnum(Role).default(Role.USER),
  status: z.nativeEnum(UserStatus).default(UserStatus.ACTIVE)
});

export const blockUserSchema = z.object({
  status: z.nativeEnum(UserStatus).refine((v) => v === UserStatus.ACTIVE || v === UserStatus.BLOCKED)
});
