import { nowUtc } from '../../common/time';
import { badRequest, notFound } from '../../common/http';
import { present } from '../../common/presenter';
import * as repo from './users.repo';

export const getMe = async (id: number) => {
  const user = await repo.findById(id);
  if (!user) throw notFound('User not found');
  return present(user);
};

export const updateMe = async (id: number, body: Record<string, unknown>) => {
  const user = await repo.updateUser(id, { ...body, modified: nowUtc() });
  if (!user) throw notFound('User not found');
  return present(user);
};

export const getUser = async (id: number) => {
  const user = await repo.findById(id);
  if (!user) throw notFound('User not found');
  return present(user);
};

export const listUsers = async (limit = 20, offset = 0) =>
  present(await repo.listUsers(limit, offset));

export const updateUser = async (id: number, body: Record<string, unknown>) => {
  if (Object.keys(body).length === 0) throw badRequest('No fields to update');
  const user = await repo.updateUser(id, { ...body, modified: nowUtc() });
  if (!user) throw notFound('User not found');
  return present(user);
};
