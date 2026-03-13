import { nowUtc } from '../../common/time';
import { present } from '../../common/presenter';
import * as repo from './contact.repo';

export const create = async (body: Record<string, unknown>) =>
  present(await repo.createContact({ ...body, recorded: nowUtc() }));

export const list = async (limit = 20, offset = 0) =>
  present(await repo.listContacts(limit, offset));
