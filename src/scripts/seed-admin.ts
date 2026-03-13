import { env } from '../config/env';
import { hashPassword } from '../common/password';
import { nowUtc } from '../common/time';
import { Gender, Role, UserStatus } from '../common/enums';
import * as usersRepo from '../modules/users/users.repo';
import { logger } from '../common/logger';

const run = async () => {
  const exists = await usersRepo.findByEmail(env.SEED_ADMIN_EMAIL);
  const now = nowUtc();

  const payload = {
    name: env.SEED_ADMIN_NAME,
    f_name: env.SEED_ADMIN_F_NAME,
    email: env.SEED_ADMIN_EMAIL.toLowerCase(),
    password: await hashPassword(env.SEED_ADMIN_PASSWORD),
    role: Role.ADMIN,
    status: UserStatus.ACTIVE,
    contact: env.SEED_ADMIN_CONTACT,
    dob: env.SEED_ADMIN_DOB,
    address: env.SEED_ADMIN_ADDRESS,
    city: env.SEED_ADMIN_CITY,
    country: env.SEED_ADMIN_COUNTRY,
    gender: Number(env.SEED_ADMIN_GENDER || Gender.M),
    recorded: now,
    modified: now,
  };

  const user = exists
    ? await usersRepo.updateUser(exists.id, payload)
    : await usersRepo.createUser(payload);

  if (!user) {
    throw new Error('Failed to seed admin');
  }

  logger.info({ id: user.id, email: user.email }, 'admin seeded');
  process.exit(0);
};

run().catch((err) => {
  logger.error({ err }, 'seed failed');
  process.exit(1);
});
