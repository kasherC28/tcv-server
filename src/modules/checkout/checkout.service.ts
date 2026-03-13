import { badRequest, notFound } from '../../common/http';
import { CheckoutStatus } from '../../common/enums';
import { present } from '../../common/presenter';
import { nowUtc } from '../../common/time';
import * as usersRepo from '../users/users.repo';
import * as repo from './checkout.repo';
import { createConfirmedSales } from './checkout.sales';
import { purchaseProduct } from '../cardwalla/cardwalla.purchase';

export const create = async (userId: number, body: Record<string, unknown>) =>
  present(await repo.createCheckoutRequest({ ...body, user_id: userId, status: CheckoutStatus.PENDING, recorded: nowUtc() }));

export const list = async () => present(await repo.listCheckoutRequests());

export const confirm = async (id: number, adminId: number) => {
  const request = await repo.getCheckoutRequest(id);
  if (!request) throw notFound('Checkout request not found');
  if (request.status !== CheckoutStatus.PENDING) throw badRequest('Checkout request already processed');
  const user = await usersRepo.findById(request.user_id);
  if (!user) throw notFound('User not found');
  const items = (request.items as Array<{ code: string; quantity: number }>).flatMap((item) =>
    Array.from({ length: item.quantity }, () => ({ code: item.code })));
  for (const item of items) await purchaseProduct(item.code, user.email, user.contact);
  const now = nowUtc();
  await createConfirmedSales(user.id, request.id, items, now);
  return present(await repo.updateCheckoutRequest(id, { status: CheckoutStatus.CONFIRMED, confirmed_by: adminId, confirmed_at: now, modified: now }));
};

export const reject = async (id: number, adminId: number, notes: string) => {
  const request = await repo.getCheckoutRequest(id);
  if (!request) throw notFound('Checkout request not found');
  if (request.status !== CheckoutStatus.PENDING) throw badRequest('Checkout request already processed');
  return present(await repo.updateCheckoutRequest(id, { status: CheckoutStatus.REJECTED, notes, confirmed_by: adminId, confirmed_at: nowUtc(), modified: nowUtc() }));
};
