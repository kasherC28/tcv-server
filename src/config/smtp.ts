import nodemailer from 'nodemailer';
import { env } from './env';

export const smtp = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: env.GOOGLE_ACCOUNT,
    pass: env.GOOGLE_APP_PASS
  }
});
