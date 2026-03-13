import { app } from './app';
import { env } from './config/env';
import { query } from './config/db';
import { logger } from './common/logger';

const start = async () => {
  await query('select 1');
  app.listen(env.PORT, () => {
    logger.info({ port: env.PORT, env: env.NODE_ENV }, 'server started');
  });
};

start().catch((err) => {
  logger.error({ err }, 'startup failed');
  process.exit(1);
});
