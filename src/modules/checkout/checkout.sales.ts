import * as salesRepo from '../sales/sales.repo';

export const createConfirmedSales = async (
  userId: number,
  requestId: number,
  items: Array<{ code: string }>,
  now: number,
) =>
  salesRepo.createSales(
    userId,
    `CHK-${requestId}`,
    items.map((item) => ({ code: item.code, count: 1 })),
    now,
  );
