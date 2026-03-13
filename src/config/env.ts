import 'dotenv/config';
import { z } from 'zod';

const schema = z.object({
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['DEV', 'PROD', 'TEST']).default('DEV'),
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(16),
  WAPP_CONTACT: z.string().min(1),
  SUPPORT_EMAIL: z.email(),
  GOOGLE_APP_NAME: z.string().min(1),
  GOOGLE_ACCOUNT: z.email(),
  GOOGLE_APP_PASS: z.string().min(1),
  OTP_TTL_MINUTES: z.coerce.number().default(10),
  CARDWALLA_BASE_URL: z.string().url(),
  CARDWALLA_TERMINAL_ID: z.string().min(1),
  CARDWALLA_USERNAME: z.string().min(1),
  CARDWALLA_PASSWORD: z.string().min(1),
  CARDWALLA_SESSION_TTL_MINUTES: z.coerce.number().default(45),
  CORS_ORIGIN: z.string().default('*'),
  SEED_ADMIN_NAME: z.string().default('Admin'),
  SEED_ADMIN_F_NAME: z.string().default('Root'),
  SEED_ADMIN_EMAIL: z.email().default('admin@thecardwalla.com'),
  SEED_ADMIN_PASSWORD: z.string().min(8).default('Admin@12345'),
  SEED_ADMIN_CONTACT: z.string().default('03001234567'),
  SEED_ADMIN_DOB: z.string().default('01-01-1990'),
  SEED_ADMIN_GENDER: z.coerce.number().default(1),
  SEED_ADMIN_ADDRESS: z.string().default('Islamabad'),
  SEED_ADMIN_CITY: z.string().default('Islamabad'),
  SEED_ADMIN_COUNTRY: z.string().default('Pakistan')
});

export const env = schema.parse(process.env);
