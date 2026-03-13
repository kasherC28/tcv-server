import { query } from '../../config/db';
import { PasswordOtpRow } from '../../common/types';

export const createOtp = async (
  userId: number,
  otpHash: string,
  expiresAt: number,
  now: number,
) =>
  query(
    'insert into password_otps (user_id, otp_hash, expires_at, used, attempts, recorded, modified) values ($1,$2,$3,0,0,$4,$4)',
    [userId, otpHash, expiresAt, now],
  );

export const getLatestOtp = async (
  userId: number,
): Promise<PasswordOtpRow | null> =>
  (
    await query<PasswordOtpRow>(
      'select * from password_otps where user_id = $1 and used = 0 order by id desc limit 1',
      [userId],
    )
  ).rows[0] || null;

export const useOtp = async (id: number, attempts: number) =>
  query('update password_otps set used = 1, attempts = $2 where id = $1', [
    id,
    attempts,
  ]);

export const addOtpAttempt = async (id: number, attempts: number) =>
  query('update password_otps set attempts = $2 where id = $1', [id, attempts]);
