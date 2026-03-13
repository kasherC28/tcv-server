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
