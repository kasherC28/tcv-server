import { Router } from 'express';
import { asyncWrap } from '../../common/http';
import { Role } from '../../common/enums';
import { auth } from '../../middleware/auth';
import { allowRoles } from '../../middleware/role';
import { contactLimiter } from '../../middleware/rate-limit';
import { validate } from '../../middleware/validate';
import * as controller from './contact.controller';
import { createContactSchema } from './contact.schema';

const router = Router();

router.post('/', contactLimiter, validate(createContactSchema), asyncWrap(controller.create));
router.get('/', auth, allowRoles(Role.ADMIN), asyncWrap(controller.list));

export default router;
