import { z } from 'zod';

const checkoutItemSchema = z.object({
  code: z.string().min(1).max(100),
  quantity: z.coerce.number().int().positive(),
  description: z.string().min(1).max(255),
  price: z.coerce.number().nonnegative(),
  currency: z.string().min(1).max(10)
});

export const createCheckoutSchema = z.object({
  payment_method: z.literal('Easypaisa').default('Easypaisa'),
  receipt_sent_whatsapp: z.literal(true),
  receipt_sent_email: z.literal(true),
  items: z.array(checkoutItemSchema).min(1),
  notes: z.string().max(1000).optional().or(z.literal(''))
});
