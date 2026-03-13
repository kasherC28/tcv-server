import { Pool, PoolClient, QueryResult, QueryResultRow } from 'pg';
import { env } from './env';
import { logger } from '../common/logger';

export const pool = new Pool({ connectionString: env.DATABASE_URL });

pool.on('error', (err) => logger.error({ err }, 'db pool error'));

export const query = <T extends QueryResultRow = QueryResultRow>(
  text: string,
  params: unknown[] = [],
) => pool.query<T>(text, params) as Promise<QueryResult<T>>;

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
