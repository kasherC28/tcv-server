import { query } from '../../config/db';
import { CheckoutRequestRow } from '../../common/types';

const asFlag = (value: unknown) => (value ? 1 : 0);

export const createCheckoutRequest = async (data: Record<string, unknown>) =>
  (await query<CheckoutRequestRow>(
    'insert into checkout_requests (user_id, status, payment_method, items, receipt_sent_whatsapp, receipt_sent_email, notes, recorded, modified) values ($1,$2,$3,$4,$5,$6,$7,$8,$8) returning *',
    [
      data.user_id,
      data.status,
      data.payment_method,
      JSON.stringify(data.items),
      asFlag(data.receipt_sent_whatsapp),
      asFlag(data.receipt_sent_email),
      data.notes || null,
      data.recorded,
    ],
  )).rows[0];

export const getCheckoutRequest = async (id: number) =>
  (await query<CheckoutRequestRow>('select * from checkout_requests where id = $1 limit 1', [id])).rows[0] || null;

export const listCheckoutRequests = async () =>
  (await query<CheckoutRequestRow>('select * from checkout_requests order by id desc', [])).rows;

export const updateCheckoutRequest = async (id: number, data: Record<string, unknown>) =>
  (await query<CheckoutRequestRow>(
    'update checkout_requests set status = $2, notes = $3, confirmed_by = $4, confirmed_at = $5, modified = $6 where id = $1 returning *',
    [id, data.status, data.notes || null, data.confirmed_by || null, data.confirmed_at || null, data.modified],
  )).rows[0] || null;
