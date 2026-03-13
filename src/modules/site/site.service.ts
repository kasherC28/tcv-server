import { env } from '../../config/env';

export const getPublicConfig = () => ({
  whatsapp: env.WAPP_CONTACT,
  email: env.SUPPORT_EMAIL,
  payment_method: 'Easypaisa',
  delivery_message: 'The code / voucher will be emailed to you within 06 hours.',
});
