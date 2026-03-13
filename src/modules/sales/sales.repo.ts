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
