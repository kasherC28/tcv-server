import { fetchProducts } from '../cardwalla/cardwalla.products';

let cache: { data: unknown[]; expiresAt: number } | null = null;

export const listProducts = async () => {
  if (cache && cache.expiresAt > Date.now()) return cache.data;
  const data = await fetchProducts();
  cache = { data, expiresAt: Date.now() + 5 * 60 * 1000 };
  return data;
};
