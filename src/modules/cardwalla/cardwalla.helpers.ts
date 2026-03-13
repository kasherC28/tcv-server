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

export const textValue = (value: unknown) =>
  value == null ? '' : String(value);
