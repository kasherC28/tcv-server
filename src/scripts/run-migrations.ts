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
