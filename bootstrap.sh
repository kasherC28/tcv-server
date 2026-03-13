#!/usr/bin/env bash
set -euo pipefail

cat > package.json <<'EOF'
{
  "name": "tcv-server",
  "version": "1.0.0",
  "private": true,
  "type": "commonjs",
  "main": "dist/server.js",
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "migrate": "tsx src/scripts/run-migrations.ts",
    "seed:admin": "tsx src/scripts/seed-admin.ts",
    "format": "prettier --write ."
  }
}
EOF

cat > .gitignore <<'EOF'
node_modules
dist
.env
coverage
*.log
EOF

cat > .prettierrc <<'EOF'
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "tabWidth": 2,
  "printWidth": 100
}
EOF

cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "CommonJS",
    "moduleResolution": "Node",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "types": ["node"]
  },
  "include": ["src/**/*.ts"]
}
EOF

cat > .env.example <<'EOF'
PORT=4000
NODE_ENV=DEV
DATABASE_URL=postgres://postgres@localhost:5432/tcv_server
JWT_SECRET=replace_me
WAPP_CONTACT=923001234567

GOOGLE_APP_NAME=TCV Server
GOOGLE_ACCOUNT=your_email@gmail.com
GOOGLE_APP_PASS=your_google_app_password

OTP_TTL_MINUTES=10
CORS_ORIGIN=http://localhost:3000
SEED_ADMIN_NAME=Admin
SEED_ADMIN_F_NAME=Root
SEED_ADMIN_EMAIL=admin@example.com
SEED_ADMIN_PASSWORD=Admin@12345
SEED_ADMIN_CONTACT=03001234567
SEED_ADMIN_DOB=1990-01-01
SEED_ADMIN_GENDER=1
SEED_ADMIN_ADDRESS=Karachi
SEED_ADMIN_CITY=Karachi
SEED_ADMIN_COUNTRY=Pakistan
EOF

cat > src/config/constants.ts <<'EOF'
export const SERVICE_NAME = 'tcv-server';
export const PK_TZ = 'Asia/Karachi';
export const DEV = 'DEV';
export const PROD = 'PROD';
EOF

cat > src/config/env.ts <<'EOF'
import 'dotenv/config';
import { z } from 'zod';

const schema = z.object({
  PORT: z.coerce.number().default(4000),
  NODE_ENV: z.enum(['DEV', 'PROD', 'TEST']).default('DEV'),
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(16),
  WAPP_CONTACT: z.string().min(1),
  GOOGLE_APP_NAME: z.string().min(1),
  GOOGLE_ACCOUNT: z.string().email(),
  GOOGLE_APP_PASS: z.string().min(1),
  OTP_TTL_MINUTES: z.coerce.number().default(10),
  CORS_ORIGIN: z.string().default('*'),
  SEED_ADMIN_NAME: z.string().default('Admin'),
  SEED_ADMIN_F_NAME: z.string().default('Root'),
  SEED_ADMIN_EMAIL: z.string().email().default('admin@example.com'),
  SEED_ADMIN_PASSWORD: z.string().min(8).default('Admin@12345'),
  SEED_ADMIN_CONTACT: z.string().default('03001234567'),
  SEED_ADMIN_DOB: z.string().default('1990-01-01'),
  SEED_ADMIN_GENDER: z.coerce.number().default(1),
  SEED_ADMIN_ADDRESS: z.string().default('Karachi'),
  SEED_ADMIN_CITY: z.string().default('Karachi'),
  SEED_ADMIN_COUNTRY: z.string().default('Pakistan')
});

export const env = schema.parse(process.env);
EOF

cat > src/config/db.ts <<'EOF'
import { Pool, PoolClient, QueryResult } from 'pg';
import { env } from './env';
import { logger } from '../common/logger';

export const pool = new Pool({ connectionString: env.DATABASE_URL });

pool.on('error', (err) => logger.error({ err }, 'db pool error'));

export const query = <T = unknown>(text: string, params: unknown[] = []) =>
  pool.query(text, params) as Promise<QueryResult<T>>;

export const withTx = async <T>(fn: (client: PoolClient) => Promise<T>) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const data = await fn(client);
    await client.query('COMMIT');
    return data;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};
EOF

cat > src/config/smtp.ts <<'EOF'
import nodemailer from 'nodemailer';
import { env } from './env';

export const smtp = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: env.GOOGLE_ACCOUNT,
    pass: env.GOOGLE_APP_PASS
  }
});
EOF

cat > src/common/enums.ts <<'EOF'
export enum Role {
  USER = 1,
  ADMIN = 2
}

export enum UserStatus {
  ACTIVE = 1,
  BLOCKED = 2
}

export enum Gender {
  M = 1,
  F = 2
}

export enum ContactTopic {
  ORDER_INQUIRY = 1,
  IRRELEVANCE = 2,
  TECHNICAL_ISSUE = 3,
  GENERAL_QUESTION = 4,
  FEEDBACK = 5
}
EOF

cat > src/common/logger.ts <<'EOF'
import pino from 'pino';
import { env } from '../config/env';
import { SERVICE_NAME } from '../config/constants';

export const logger = pino({
  name: SERVICE_NAME,
  level: env.NODE_ENV === 'DEV' ? 'debug' : 'info',
  transport:
    env.NODE_ENV === 'DEV'
      ? {
          target: 'pino-pretty',
          options: { singleLine: true, colorize: true, ignore: 'pid,hostname' }
        }
      : undefined,
  base: { service: SERVICE_NAME },
  timestamp: pino.stdTimeFunctions.isoTime
});

export const log = (scope: string) => logger.child({ scope });
EOF

cat > src/common/http.ts <<'EOF'
import { NextFunction, Request, Response } from 'express';

export const asyncWrap =
  (fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>) =>
  (req: Request, res: Response, next: NextFunction) =>
    Promise.resolve(fn(req, res, next)).catch(next);

export const badRequest = (message: string) =>
  Object.assign(new Error(message), { statusCode: 400 });

export const unauthorized = (message = 'Unauthorized') =>
  Object.assign(new Error(message), { statusCode: 401 });

export const forbidden = (message = 'Forbidden') =>
  Object.assign(new Error(message), { statusCode: 403 });

export const notFound = (message = 'Not Found') =>
  Object.assign(new Error(message), { statusCode: 404 });
EOF

cat > src/common/time.ts <<'EOF'
import { PK_TZ } from '../config/constants';

export const nowUtc = () => Math.floor(Date.now() / 1000);

export const toTimezone = (epoch: number, tz = PK_TZ) =>
  new Intl.DateTimeFormat('en-PK', {
    timeZone: tz,
    dateStyle: 'medium',
    timeStyle: 'medium',
    hour12: true
  }).format(new Date(epoch * 1000));
EOF

cat > src/common/jwt.ts <<'EOF'
import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { Role } from './enums';

type Payload = { sub: number; role: Role; email: string };

export const signAccessToken = (payload: Payload) =>
  jwt.sign(payload, env.JWT_SECRET, { expiresIn: '1d' });

export const verifyAccessToken = (token: string) =>
  jwt.verify(token, env.JWT_SECRET) as Payload & jwt.JwtPayload;
EOF

cat > src/common/password.ts <<'EOF'
import bcrypt from 'bcryptjs';

export const hashPassword = (value: string) => bcrypt.hash(value, 12);
export const comparePassword = (value: string, hash: string) =>
  bcrypt.compare(value, hash);
EOF

cat > src/common/otp.ts <<'EOF'
export const generateOtp = () =>
  String(Math.floor(100000 + Math.random() * 900000));
EOF

cat > src/common/presenter.ts <<'EOF'
import { toTimezone } from './time';

const shape = (row: Record<string, unknown>) => ({
  ...row,
  recorded_pk: typeof row.recorded === 'number' ? toTimezone(row.recorded) : null,
  modified_pk: typeof row.modified === 'number' ? toTimezone(row.modified) : null
});

export const present = <T>(data: T) => {
  if (Array.isArray(data)) return data.map((x) => shape(x as Record<string, unknown>));
  if (data && typeof data === 'object') return shape(data as Record<string, unknown>);
  return data;
};
EOF

cat > src/middleware/request-logger.ts <<'EOF'
import pinoHttp from 'pino-http';
import { logger } from '../common/logger';

export const requestLogger = pinoHttp({
  logger,
  customLogLevel(_, res, err) {
    if (err || res.statusCode >= 500) return 'error';
    if (res.statusCode >= 400) return 'warn';
    return 'info';
  },
  customSuccessMessage(req, res) {
    return `${req.method} ${req.url} ${res.statusCode}`;
  },
  customErrorMessage(req, res) {
    return `${req.method} ${req.url} ${res.statusCode}`;
  }
});
EOF

cat > src/middleware/rate-limit.ts <<'EOF'
import rateLimit from 'express-rate-limit';

export const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  standardHeaders: true,
  legacyHeaders: false
});

export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 25,
  standardHeaders: true,
  legacyHeaders: false
});

export const contactLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 15,
  standardHeaders: true,
  legacyHeaders: false
});
EOF

cat > src/middleware/validate.ts <<'EOF'
import { NextFunction, Request, Response } from 'express';
import { ZodTypeAny } from 'zod';

export const validate =
  (schema: ZodTypeAny, key: 'body' | 'query' | 'params' = 'body') =>
  (req: Request, _: Response, next: NextFunction) => {
    const parsed = schema.safeParse(req[key]);
    if (!parsed.success) return next(Object.assign(new Error(parsed.error.issues[0].message), { statusCode: 400 }));
    req[key] = parsed.data;
    next();
  };
EOF

cat > src/middleware/not-found.ts <<'EOF'
import { Request, Response, NextFunction } from 'express';

export const notFoundHandler = (_: Request, __: Response, next: NextFunction) =>
  next(Object.assign(new Error('Route not found'), { statusCode: 404 }));
EOF

cat > src/middleware/error-handler.ts <<'EOF'
import { NextFunction, Request, Response } from 'express';
import { logger } from '../common/logger';

export const errorHandler = (
  err: Error & { statusCode?: number },
  req: Request,
  res: Response,
  _: NextFunction
) => {
  const status = err.statusCode || 500;
  req.log[status >= 500 ? 'error' : 'warn']({ err }, err.message);
  if (status >= 500) logger.error({ err }, 'unhandled error');
  res.status(status).json({ success: false, message: err.message || 'Server error' });
};
EOF

cat > src/middleware/role.ts <<'EOF'
import { NextFunction, Request, Response } from 'express';
import { Role } from '../common/enums';

export const allowRoles =
  (...roles: Role[]) =>
  (req: Request, _: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(Object.assign(new Error('Forbidden'), { statusCode: 403 }));
    }
    next();
  };
EOF

cat > src/middleware/auth.ts <<'EOF'
import { NextFunction, Request, Response } from 'express';
import { verifyAccessToken } from '../common/jwt';
import { unauthorized } from '../common/http';
import * as usersRepo from '../modules/users/users.repo';
import { UserStatus } from '../common/enums';

export const auth = async (req: Request, _: Response, next: NextFunction) => {
  try {
    const header = req.headers.authorization;
    const token = header?.startsWith('Bearer ') ? header.slice(7) : '';
    if (!token) throw unauthorized();
    const payload = verifyAccessToken(token);
    const user = await usersRepo.findById(Number(payload.sub));
    if (!user || user.status !== UserStatus.ACTIVE) throw unauthorized();
    req.user = user;
    next();
  } catch {
    next(unauthorized());
  }
};
EOF

cat > src/modules/auth/auth.lockout.ts <<'EOF'
const attempts = new Map<string, { count: number; until: number }>();

export const assertAllowed = (key: string) => {
  const item = attempts.get(key);
  if (item && item.until > Date.now()) {
    throw Object.assign(new Error('Too many failed attempts. Try later.'), { statusCode: 429 });
  }
};

export const addFailure = (key: string) => {
  const item = attempts.get(key) || { count: 0, until: 0 };
  const count = item.count + 1;
  const until = count >= 5 ? Date.now() + 15 * 60 * 1000 : 0;
  attempts.set(key, { count: until ? 0 : count, until });
};

export const clearFailures = (key: string) => attempts.delete(key);
EOF

cat > src/modules/users/users.repo.ts <<'EOF'
import { query } from '../../config/db';

export const findById = async (id: number) =>
  (await query('select * from users where id = $1 limit 1', [id])).rows[0] || null;

export const findByEmail = async (email: string) =>
  (await query('select * from users where email = $1 limit 1', [email.toLowerCase()])).rows[0] || null;

export const listUsers = async (limit: number, offset: number) =>
  (await query('select * from users order by id desc limit $1 offset $2', [limit, offset])).rows;

export const createUser = async (data: Record<string, unknown>) => {
  const keys = Object.keys(data);
  const cols = keys.join(', ');
  const vals = keys.map((_, i) => `$${i + 1}`).join(', ');
  const res = await query(
    `insert into users (${cols}) values (${vals}) returning *`,
    keys.map((k) => data[k])
  );
  return res.rows[0];
};

export const updateUser = async (id: number, data: Record<string, unknown>) => {
  const keys = Object.keys(data);
  const set = keys.map((k, i) => `${k} = $${i + 2}`).join(', ');
  const res = await query(
    `update users set ${set} where id = $1 returning *`,
    [id, ...keys.map((k) => data[k])]
  );
  return res.rows[0] || null;
};
EOF

cat > src/modules/users/users.schema.ts <<'EOF'
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
EOF

cat > src/modules/users/users.service.ts <<'EOF'
import { nowUtc } from '../../common/time';
import { badRequest, notFound } from '../../common/http';
import { present } from '../../common/presenter';
import * as repo from './users.repo';

export const getMe = async (id: number) => {
  const user = await repo.findById(id);
  if (!user) throw notFound('User not found');
  return present(user);
};

export const updateMe = async (id: number, body: Record<string, unknown>) => {
  const user = await repo.updateUser(id, { ...body, modified: nowUtc() });
  if (!user) throw notFound('User not found');
  return present(user);
};

export const getUser = async (id: number) => {
  const user = await repo.findById(id);
  if (!user) throw notFound('User not found');
  return present(user);
};

export const listUsers = async (limit = 20, offset = 0) =>
  present(await repo.listUsers(limit, offset));

export const updateUser = async (id: number, body: Record<string, unknown>) => {
  if (Object.keys(body).length === 0) throw badRequest('No fields to update');
  const user = await repo.updateUser(id, { ...body, modified: nowUtc() });
  if (!user) throw notFound('User not found');
  return present(user);
};
EOF

cat > src/modules/users/users.controller.ts <<'EOF'
import { Request, Response } from 'express';
import * as service from './users.service';

export const me = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.getMe(req.user!.id) });

export const updateMe = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.updateMe(req.user!.id, req.body) });

export const one = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.getUser(Number(req.params.id)) });

export const list = async (req: Request, res: Response) => {
  const limit = Number(req.query.limit || 20);
  const offset = Number(req.query.offset || 0);
  res.json({ success: true, data: await service.listUsers(limit, offset) });
};

export const update = async (req: Request, res: Response) =>
  res.json({ success: true, data: await service.updateUser(Number(req.params.id), req.body) });
EOF

cat > src/modules/users/users.routes.ts <<'EOF'
import { Router } from 'express';
import { asyncWrap } from '../../common/http';
import { auth } from '../../middleware/auth';
import { allowRoles } from '../../middleware/role';
import { validate } from '../../middleware/validate';
import { Role } from '../../common/enums';
import * as controller from './users.controller';
import { idParamSchema, updateMeSchema, updateUserSchema } from './users.schema';

const router = Router();

router.get('/me', auth, asyncWrap(controller.me));
router.patch('/me', auth, validate(updateMeSchema), asyncWrap(controller.updateMe));
router.get('/', auth, allowRoles(Role.ADMIN), asyncWrap(controller.list));
router.get('/:id', auth, allowRoles(Role.ADMIN), validate(idParamSchema, 'params'), asyncWrap(controller.one));
router.patch('/:id', auth, allowRoles(Role.ADMIN), validate(idParamSchema, 'params'), validate(updateUserSchema), asyncWrap(controller.update));

export default router;
EOF

cat > src/modules/auth/auth.repo.ts <<'EOF'
import { query } from '../../config/db';

export const createOtp = async (userId: number, otpHash: string, expiresAt: number, now: number) =>
  query(
    'insert into password_otps (user_id, otp_hash, expires_at, used, attempts, recorded, modified) values ($1,$2,$3,0,0,$4,$4)',
    [userId, otpHash, expiresAt, now]
  );

export const getLatestOtp = async (userId: number) =>
  (await query(
    'select * from password_otps where user_id = $1 and used = 0 order by id desc limit 1',
    [userId]
  )).rows[0] || null;

export const useOtp = async (id: number, attempts: number) =>
  query('update password_otps set used = 1, attempts = $2 where id = $1', [id, attempts]);

export const addOtpAttempt = async (id: number, attempts: number) =>
  query('update password_otps set attempts = $2 where id = $1', [id, attempts]);
EOF

cat > src/modules/auth/auth.schema.ts <<'EOF'
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
EOF

cat > src/modules/mailer/mailer.service.ts <<'EOF'
import { smtp } from '../../config/smtp';
import { env } from '../../config/env';

export const sendOtpMail = async (email: string, otp: string) =>
  smtp.sendMail({
    from: `"${env.GOOGLE_APP_NAME}" <${env.GOOGLE_ACCOUNT}>`,
    to: email,
    subject: 'Password Reset OTP',
    text: `Your OTP is ${otp}. It expires in ${env.OTP_TTL_MINUTES} minutes.`
  });
EOF

cat > src/modules/auth/auth.service.ts <<'EOF'
import bcrypt from 'bcryptjs';
import { signAccessToken } from '../../common/jwt';
import { comparePassword, hashPassword } from '../../common/password';
import { generateOtp } from '../../common/otp';
import { badRequest, notFound, unauthorized } from '../../common/http';
import { nowUtc } from '../../common/time';
import { present } from '../../common/presenter';
import { Role, UserStatus } from '../../common/enums';
import * as usersRepo from '../users/users.repo';
import * as authRepo from './auth.repo';
import * as mailer from '../mailer/mailer.service';
import { addFailure, assertAllowed, clearFailures } from './auth.lockout';

export const signup = async (body: Record<string, unknown>) => {
  if (await usersRepo.findByEmail(String(body.email))) throw badRequest('Email already exists');
  const now = nowUtc();
  const user = await usersRepo.createUser({
    ...body, email: String(body.email).toLowerCase(), password: await hashPassword(String(body.password)),
    role: Role.USER, status: UserStatus.ACTIVE, recorded: now, modified: now
  });
  const token = signAccessToken({ sub: user.id, role: user.role, email: user.email });
  return { token, user: present(user) };
};

export const signin = async (email: string, password: string) => {
  const key = email.toLowerCase();
  assertAllowed(key);
  const user = await usersRepo.findByEmail(key);
  if (!user || !(await comparePassword(password, user.password))) {
    addFailure(key);
    throw unauthorized('Invalid credentials');
  }
  if (user.status !== UserStatus.ACTIVE) throw unauthorized('User is blocked');
  clearFailures(key);
  return { token: signAccessToken({ sub: user.id, role: user.role, email: user.email }), user: present(user) };
};

export const forgotPassword = async (email: string) => {
  const user = await usersRepo.findByEmail(email.toLowerCase());
  if (!user) return { message: 'If the email exists, OTP has been sent.' };
  const otp = generateOtp();
  const now = nowUtc();
  await authRepo.createOtp(user.id, await bcrypt.hash(otp, 10), now + 600, now);
  await mailer.sendOtpMail(user.email, otp);
  return { message: 'If the email exists, OTP has been sent.' };
};

export const resetPassword = async (email: string, otp: string, newPassword: string) => {
  const user = await usersRepo.findByEmail(email.toLowerCase());
  if (!user) throw notFound('User not found');
  const record = await authRepo.getLatestOtp(user.id);
  if (!record || record.expires_at < nowUtc()) throw badRequest('OTP expired or invalid');
  const matched = await bcrypt.compare(otp, record.otp_hash);
  const attempts = Number(record.attempts || 0) + 1;
  if (!matched) {
    await authRepo.addOtpAttempt(record.id, attempts);
    throw badRequest('Invalid OTP');
  }
  await usersRepo.updateUser(user.id, { password: await hashPassword(newPassword), modified: nowUtc() });
  await authRepo.useOtp(record.id, attempts);
  return { message: 'Password updated successfully' };
};

export const updatePassword = async (userId: number, current: string, next: string) => {
  const user = await usersRepo.findById(userId);
  if (!user || !(await comparePassword(current, user.password))) throw badRequest('Current password is invalid');
  await usersRepo.updateUser(userId, { password: await hashPassword(next), modified: nowUtc() });
  return { message: 'Password updated successfully' };
};

export const createUserByAdmin = async (body: Record<string, unknown>) => {
  if (await usersRepo.findByEmail(String(body.email))) throw badRequest('Email already exists');
  const now = nowUtc();
  return present(await usersRepo.createUser({ ...body, email: String(body.email).toLowerCase(), password: await hashPassword(String(body.password)), recorded: now, modified: now }));
};

export const blockUser = async (id: number, status: UserStatus) => {
  const user = await usersRepo.updateUser(id, { status, modified: nowUtc() });
  if (!user) throw notFound('User not found');
  return present(user);
};
EOF

cat > src/modules/auth/auth.controller.ts <<'EOF'
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
EOF

cat > src/modules/auth/auth.routes.ts <<'EOF'
import { Router } from 'express';
import { asyncWrap } from '../../common/http';
import { Role } from '../../common/enums';
import { auth } from '../../middleware/auth';
import { allowRoles } from '../../middleware/role';
import { authLimiter } from '../../middleware/rate-limit';
import { validate } from '../../middleware/validate';
import * as controller from './auth.controller';
import { blockUserSchema, createUserSchema, forgotPasswordSchema, resetPasswordSchema, signinSchema, signupSchema, updatePasswordSchema } from './auth.schema';
import { idParamSchema } from '../users/users.schema';

const router = Router();

router.post('/signup', authLimiter, validate(signupSchema), asyncWrap(controller.signup));
router.post('/signin', authLimiter, validate(signinSchema), asyncWrap(controller.signin));
router.post('/forgot-password', authLimiter, validate(forgotPasswordSchema), asyncWrap(controller.forgotPassword));
router.post('/reset-password', authLimiter, validate(resetPasswordSchema), asyncWrap(controller.resetPassword));
router.post('/update-password', auth, validate(updatePasswordSchema), asyncWrap(controller.updatePassword));
router.post('/users', auth, allowRoles(Role.ADMIN), validate(createUserSchema), asyncWrap(controller.createUser));
router.patch('/users/:id/block', auth, allowRoles(Role.ADMIN), validate(idParamSchema, 'params'), validate(blockUserSchema), asyncWrap(controller.blockUser));

export default router;
EOF

cat > src/modules/sales/sales.repo.ts <<'EOF'
import { PoolClient } from 'pg';
import { query, withTx } from '../../config/db';

export const createSales = async (userId: number, transaction: string, items: Array<{ code: string; count: number }>, now: number) =>
  withTx(async (client: PoolClient) => {
    const rows = [];
    for (const item of items) {
      const res = await client.query(
        'insert into sales (user_id, transaction, code, count, recorded, modified) values ($1,$2,$3,$4,$5,$5) returning *',
        [userId, transaction, item.code, item.count, now]
      );
      rows.push(res.rows[0]);
    }
    return rows;
  });

export const listSalesByUser = async (userId: number, limit: number, offset: number) =>
  (await query('select * from sales where user_id = $1 order by id desc limit $2 offset $3', [userId, limit, offset])).rows;
EOF

cat > src/modules/sales/sales.schema.ts <<'EOF'
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
EOF

cat > src/modules/sales/sales.service.ts <<'EOF'
import { nowUtc } from '../../common/time';
import { present } from '../../common/presenter';
import * as repo from './sales.repo';

export const create = async (userId: number, body: { transaction: string; items: Array<{ code: string; count: number }> }) =>
  present(await repo.createSales(userId, body.transaction, body.items, nowUtc()));

export const listMine = async (userId: number, limit = 20, offset = 0) =>
  present(await repo.listSalesByUser(userId, limit, offset));
EOF

cat > src/modules/sales/sales.controller.ts <<'EOF'
import { Request, Response } from 'express';
import * as service from './sales.service';

export const create = async (req: Request, res: Response) =>
  res.status(201).json({ success: true, data: await service.create(req.user!.id, req.body) });

export const listMine = async (req: Request, res: Response) => {
  const limit = Number(req.query.limit || 20);
  const offset = Number(req.query.offset || 0);
  res.json({ success: true, data: await service.listMine(req.user!.id, limit, offset) });
};
EOF

cat > src/modules/sales/sales.routes.ts <<'EOF'
import { Router } from 'express';
import { asyncWrap } from '../../common/http';
import { auth } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import * as controller from './sales.controller';
import { createSaleSchema } from './sales.schema';

const router = Router();

router.post('/', auth, validate(createSaleSchema), asyncWrap(controller.create));
router.get('/', auth, asyncWrap(controller.listMine));

export default router;
EOF

cat > src/modules/contact/contact.repo.ts <<'EOF'
import { query } from '../../config/db';

export const createContact = async (data: Record<string, unknown>) =>
  (await query(
    'insert into contact_us (name, email, contact, subject, message, recorded, modified) values ($1,$2,$3,$4,$5,$6,$6) returning *',
    [data.name, data.email, data.contact, data.subject, data.message, data.recorded]
  )).rows[0];

export const listContacts = async (limit: number, offset: number) =>
  (await query('select * from contact_us order by id desc limit $1 offset $2', [limit, offset])).rows;
EOF

cat > src/modules/contact/contact.schema.ts <<'EOF'
import { z } from 'zod';
import { ContactTopic } from '../../common/enums';

export const createContactSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  contact: z.string().min(7).max(20),
  subject: z.nativeEnum(ContactTopic).default(ContactTopic.ORDER_INQUIRY),
  message: z.string().min(1).max(2000)
});
EOF

cat > src/modules/contact/contact.service.ts <<'EOF'
import { nowUtc } from '../../common/time';
import { present } from '../../common/presenter';
import * as repo from './contact.repo';

export const create = async (body: Record<string, unknown>) =>
  present(await repo.createContact({ ...body, recorded: nowUtc() }));

export const list = async (limit = 20, offset = 0) =>
  present(await repo.listContacts(limit, offset));
EOF

cat > src/modules/contact/contact.controller.ts <<'EOF'
import { Request, Response } from 'express';
import * as service from './contact.service';

export const create = async (req: Request, res: Response) =>
  res.status(201).json({ success: true, data: await service.create(req.body) });

export const list = async (req: Request, res: Response) => {
  const limit = Number(req.query.limit || 20);
  const offset = Number(req.query.offset || 0);
  res.json({ success: true, data: await service.list(limit, offset) });
};
EOF

cat > src/modules/contact/contact.routes.ts <<'EOF'
import { Router } from 'express';
import { asyncWrap } from '../../common/http';
import { Role } from '../../common/enums';
import { auth } from '../../middleware/auth';
import { allowRoles } from '../../middleware/role';
import { contactLimiter } from '../../middleware/rate-limit';
import { validate } from '../../middleware/validate';
import * as controller from './contact.controller';
import { createContactSchema } from './contact.schema';

const router = Router();

router.post('/', contactLimiter, validate(createContactSchema), asyncWrap(controller.create));
router.get('/', auth, allowRoles(Role.ADMIN), asyncWrap(controller.list));

export default router;
EOF

cat > src/app.ts <<'EOF'
import express from 'express';
import compression from 'compression';
import cors from 'cors';
import helmet from 'helmet';
import hpp from 'hpp';
import authRoutes from './modules/auth/auth.routes';
import usersRoutes from './modules/users/users.routes';
import salesRoutes from './modules/sales/sales.routes';
import contactRoutes from './modules/contact/contact.routes';
import { globalLimiter } from './middleware/rate-limit';
import { requestLogger } from './middleware/request-logger';
import { notFoundHandler } from './middleware/not-found';
import { errorHandler } from './middleware/error-handler';
import { env } from './config/env';

export const app = express();

app.disable('x-powered-by');
app.use(requestLogger);
app.use(helmet());
app.use(hpp());
app.use(compression());
app.use(globalLimiter);
app.use(cors({ origin: env.CORS_ORIGIN === '*' ? true : env.CORS_ORIGIN }));
app.use(express.json({ limit: '100kb' }));
app.use(express.urlencoded({ extended: false }));

app.get('/health', (_, res) => res.json({ success: true, message: 'ok' }));
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/sales', salesRoutes);
app.use('/api/contact-us', contactRoutes);

app.use(notFoundHandler);
app.use(errorHandler);
EOF

cat > src/server.ts <<'EOF'
import { app } from './app';
import { env } from './config/env';
import { query } from './config/db';
import { logger } from './common/logger';

const start = async () => {
  await query('select 1');
  app.listen(env.PORT, () => {
    logger.info({ port: env.PORT, env: env.NODE_ENV }, 'server started');
  });
};

start().catch((err) => {
  logger.error({ err }, 'startup failed');
  process.exit(1);
});
EOF

cat > src/scripts/run-migrations.ts <<'EOF'
import fs from 'fs';
import path from 'path';
import { pool } from '../config/db';
import { logger } from '../common/logger';

const run = async () => {
  await pool.query('create table if not exists schema_migrations (name text primary key)');
  const dir = path.join(process.cwd(), 'migrations');
  const files = fs.readdirSync(dir).filter((f) => f.endsWith('.sql')).sort();
  for (const file of files) {
    const exists = await pool.query('select 1 from schema_migrations where name = $1', [file]);
    if (exists.rowCount) continue;
    const sql = fs.readFileSync(path.join(dir, file), 'utf8');
    await pool.query('begin');
    try {
      await pool.query(sql);
      await pool.query('insert into schema_migrations (name) values ($1)', [file]);
      await pool.query('commit');
      logger.info({ file }, 'migration applied');
    } catch (err) {
      await pool.query('rollback');
      throw err;
    }
  }
  await pool.end();
};

run().catch((err) => {
  logger.error({ err }, 'migration failed');
  process.exit(1);
});
EOF

cat > src/scripts/seed-admin.ts <<'EOF'
import { env } from '../config/env';
import { hashPassword } from '../common/password';
import { nowUtc } from '../common/time';
import { Gender, Role, UserStatus } from '../common/enums';
import * as usersRepo from '../modules/users/users.repo';
import { logger } from '../common/logger';

const run = async () => {
  const exists = await usersRepo.findByEmail(env.SEED_ADMIN_EMAIL);
  const now = nowUtc();
  const payload = {
    name: env.SEED_ADMIN_NAME,
    f_name: env.SEED_ADMIN_F_NAME,
    email: env.SEED_ADMIN_EMAIL.toLowerCase(),
    password: await hashPassword(env.SEED_ADMIN_PASSWORD),
    role: Role.ADMIN,
    status: UserStatus.ACTIVE,
    contact: env.SEED_ADMIN_CONTACT,
    dob: env.SEED_ADMIN_DOB,
    address: env.SEED_ADMIN_ADDRESS,
    city: env.SEED_ADMIN_CITY,
    country: env.SEED_ADMIN_COUNTRY,
    gender: Number(env.SEED_ADMIN_GENDER || Gender.M),
    recorded: now,
    modified: now
  };
  const user = exists ? await usersRepo.updateUser(exists.id, payload) : await usersRepo.createUser(payload);
  logger.info({ id: user.id, email: user.email }, 'admin seeded');
  process.exit(0);
};

run().catch((err) => {
  logger.error({ err }, 'seed failed');
  process.exit(1);
});
EOF

cat > migrations/001_users.sql <<'EOF'
create table if not exists users (
  id bigserial primary key,
  name varchar(100) not null,
  f_name varchar(100) not null,
  email varchar(255) not null unique,
  password varchar(255) not null,
  role smallint not null default 1,
  status smallint not null default 1,
  contact varchar(20) not null,
  dob varchar(20) not null,
  address varchar(255),
  city varchar(100),
  country varchar(100),
  gender smallint not null,
  recorded bigint not null,
  modified bigint not null
);

create index if not exists idx_users_email on users(email);
create index if not exists idx_users_role on users(role);
create index if not exists idx_users_status on users(status);
EOF

cat > migrations/002_sales.sql <<'EOF'
create table if not exists sales (
  id bigserial primary key,
  user_id bigint not null references users(id) on delete cascade,
  transaction varchar(100) not null,
  code varchar(100) not null,
  count integer not null check (count > 0),
  recorded bigint not null,
  modified bigint not null
);

create index if not exists idx_sales_user_id on sales(user_id);
create index if not exists idx_sales_transaction on sales(transaction);
EOF

cat > migrations/003_contact_us.sql <<'EOF'
create table if not exists contact_us (
  id bigserial primary key,
  name varchar(100) not null,
  email varchar(255) not null,
  contact varchar(20) not null,
  subject smallint not null default 1,
  message text not null,
  recorded bigint not null,
  modified bigint not null
);

create index if not exists idx_contact_us_email on contact_us(email);
create index if not exists idx_contact_us_subject on contact_us(subject);
EOF

cat > migrations/004_password_otps.sql <<'EOF'
create table if not exists password_otps (
  id bigserial primary key,
  user_id bigint not null references users(id) on delete cascade,
  otp_hash varchar(255) not null,
  expires_at bigint not null,
  used smallint not null default 0,
  attempts integer not null default 0,
  recorded bigint not null,
  modified bigint not null
);

create index if not exists idx_password_otps_user_id on password_otps(user_id);
create index if not exists idx_password_otps_expires_at on password_otps(expires_at);
EOF

chmod +x bootstrap.sh
echo "Bootstrap files created."
