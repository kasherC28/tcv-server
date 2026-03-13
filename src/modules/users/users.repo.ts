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
