export const buildTimestamp = () => {
  const now = new Date();
  const offset = now.getTimezoneOffset();
  const hours = String(Math.abs(Math.floor(offset / 60))).padStart(2, '0');
  const minutes = String(Math.abs(offset % 60)).padStart(2, '0');
  const sign = offset <= 0 ? '+' : '-';
  return `${now.toISOString().slice(0, -1)}${sign}${hours}:${minutes}`;
};

export const buildTransactionId = () =>
  `${Date.now()}${Math.floor(Math.random() * 1000)}`;

export const asArray = <T>(value: T | T[] | undefined): T[] =>
  Array.isArray(value) ? value : value ? [value] : [];

export const textValue = (value: unknown): string => {
  if (value == null) return '';
  if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') {
    return String(value);
  }
  if (typeof value === 'object' && '#text' in (value as Record<string, unknown>)) {
    return textValue((value as Record<string, unknown>)['#text']);
  }
  return '';
};
