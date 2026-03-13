const attempts = new Map<string, { count: number; until: number }>();

export const assertAllowed = (key: string) => {
  const item = attempts.get(key);
  if (item && item.until > Date.now()) {
    throw Object.assign(new Error('Too many failed attempts. Try later.'), { statusCode: 429 });
  }
};

export const addFailure = (key: string) => {
  const item = attempts.get(key) || { count: 0, until: 0 };
  const count = item.count + 1;
  const until = count >= 5 ? Date.now() + 15 * 60 * 1000 : 0;
  attempts.set(key, { count: until ? 0 : count, until });
};

export const clearFailures = (key: string) => attempts.delete(key);
