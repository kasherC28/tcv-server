import { toTimezone } from './time';

const shape = (row: Record<string, unknown>) => ({
  ...row,
  recorded_pk: typeof row.recorded === 'number' ? toTimezone(row.recorded) : null,
  modified_pk: typeof row.modified === 'number' ? toTimezone(row.modified) : null
});

export const present = <T>(data: T) => {
  if (Array.isArray(data)) return data.map((x) => shape(x as Record<string, unknown>));
  if (data && typeof data === 'object') return shape(data as Record<string, unknown>);
  return data;
};
