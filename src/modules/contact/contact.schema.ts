import { z } from 'zod';
import { ContactTopic } from '../../common/enums';

export const createContactSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  contact: z.string().min(7).max(20),
  subject: z.nativeEnum(ContactTopic).default(ContactTopic.ORDER_INQUIRY),
  message: z.string().min(1).max(2000)
});
