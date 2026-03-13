import { nowUtc } from '../../common/time';
import { present } from '../../common/presenter';
import * as repo from './sales.repo';

export const create = async (userId: number, body: { transaction: string; items: Array<{ code: string; count: number }> }) =>
  present(await repo.createSales(userId, body.transaction, body.items, nowUtc()));

export const listMine = async (userId: number, limit = 20, offset = 0) =>
  present(await repo.listSalesByUser(userId, limit, offset));
