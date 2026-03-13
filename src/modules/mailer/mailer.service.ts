import { smtp } from '../../config/smtp';
import { env } from '../../config/env';

export const sendOtpMail = async (email: string, otp: string) =>
  smtp.sendMail({
    from: `"${env.GOOGLE_APP_NAME}" <${env.GOOGLE_ACCOUNT}>`,
    to: email,
    subject: 'Password Reset OTP',
    text: `Your OTP is ${otp}. It expires in ${env.OTP_TTL_MINUTES} minutes.`
  });
