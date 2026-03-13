import { CheckoutStatus, ContactTopic, Gender, Role, UserStatus } from './enums';

export interface UserRow {
  id: number;
  name: string;
  f_name: string;
  email: string;
  password: string;
  role: Role;
  status: UserStatus;
  contact: string;
  dob: string;
  address: string | null;
  city: string | null;
  country: string | null;
  gender: Gender;
  recorded: number;
  modified: number;
}

export interface PasswordOtpRow {
  id: number;
  user_id: number;
  otp_hash: string;
  expires_at: number;
  used: number;
  attempts: number;
  recorded: number;
  modified: number;
}

export interface SaleRow {
  id: number;
  user_id: number;
  transaction: string;
  code: string;
  count: number;
  recorded: number;
  modified: number;
}

export interface ContactRow {
  id: number;
  name: string;
  email: string;
  contact: string;
  subject: ContactTopic;
  message: string;
  recorded: number;
  modified: number;
}

export interface CheckoutRequestRow {
  id: number;
  user_id: number;
  status: CheckoutStatus;
  payment_method: string;
  items: Array<Record<string, unknown>>;
  receipt_sent_whatsapp: number;
  receipt_sent_email: number;
  notes: string | null;
  confirmed_by: number | null;
  confirmed_at: number | null;
  recorded: number;
  modified: number;
}
