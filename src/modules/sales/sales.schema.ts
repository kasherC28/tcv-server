import { z } from 'zod';

export const createSaleSchema = z.object({
  transaction: z.string().min(1).max(100),
  items: z.array(
    z.object({
      code: z.string().min(1).max(100),
      count: z.coerce.number().int().positive()
    })
  ).min(1)
});
