import { PK_TZ } from '../config/constants';

export const nowUtc = () => Math.floor(Date.now() / 1000);

export const toTimezone = (epoch: number, tz = PK_TZ) =>
  new Intl.DateTimeFormat('en-PK', {
    timeZone: tz,
    dateStyle: 'medium',
    timeStyle: 'medium',
    hour12: true
  }).format(new Date(epoch * 1000));
