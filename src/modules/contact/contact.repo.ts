import { query } from '../../config/db';

export const createContact = async (data: Record<string, unknown>) =>
  (await query(
    'insert into contact_us (name, email, contact, subject, message, recorded, modified) values ($1,$2,$3,$4,$5,$6,$6) returning *',
    [data.name, data.email, data.contact, data.subject, data.message, data.recorded]
  )).rows[0];

export const listContacts = async (limit: number, offset: number) =>
  (await query('select * from contact_us order by id desc limit $1 offset $2', [limit, offset])).rows;
