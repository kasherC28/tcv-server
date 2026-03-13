import { z } from 'zod';
import { idParamSchema } from '../users/users.schema';

export const confirmCheckoutParamsSchema = idParamSchema;

export const rejectCheckoutSchema = z.object({
  notes: z.string().min(1).max(1000)
});
