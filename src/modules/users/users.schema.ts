import { z } from 'zod';
import { Gender, Role, UserStatus } from '../../common/enums';

const phone = z.string().min(7).max(20);

export const idParamSchema = z.object({ id: z.coerce.number().int().positive() });

export const updateMeSchema = z.object({
  name: z.string().min(1).optional(),
  f_name: z.string().min(1).optional(),
  contact: phone.optional(),
  dob: z.string().min(1).optional(),
  address: z.string().optional(),
  city: z.string().optional(),
  country: z.string().optional(),
  gender: z.nativeEnum(Gender).optional()
});

export const updateUserSchema = updateMeSchema.extend({
  email: z.string().email().optional(),
  role: z.nativeEnum(Role).optional(),
  status: z.nativeEnum(UserStatus).optional()
});
