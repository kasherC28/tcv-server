import pino from 'pino';
import { env } from '../config/env';
import { SERVICE_NAME } from '../config/constants';

export const logger = pino({
  name: SERVICE_NAME,
  level: env.NODE_ENV === 'DEV' ? 'debug' : 'info',
  transport:
    env.NODE_ENV === 'DEV'
      ? {
          target: 'pino-pretty',
          options: { singleLine: true, colorize: true, ignore: 'pid,hostname' }
        }
      : undefined,
  base: { service: SERVICE_NAME },
  timestamp: pino.stdTimeFunctions.isoTime
});

export const log = (scope: string) => logger.child({ scope });
